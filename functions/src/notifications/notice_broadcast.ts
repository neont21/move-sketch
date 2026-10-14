import {onDocumentCreated} from "firebase-functions/v2/firestore";
import * as admin from "firebase-admin";
import * as logger from "firebase-functions/logger";
import {NoticeDocument, UserDocument} from "../types/notification";

const FCM_MULTICAST_CHUNK_LIMIT = 500;
const FIRESTORE_BATCH_CHUNK_LIMIT = 500;

/**
 * 배열을 지정된 청크 크기 단위의 2차원 배열로 분할한다.
 *
 * @template ItemType
 * @param {Array<ItemType>} items 분할할 원본 배열
 * @param {number} chunkSize 분할할 청크의 최대 원소 크기
 * @return {Array<Array<ItemType>>} 분할된 2차원 청크 배열
 */
function chunkArray<ItemType>(
  items: readonly ItemType[],
  chunkSize: number
): ItemType[][] {
  if (chunkSize <= 0) {
    return [items.slice()];
  }
  const chunkedList: ItemType[][] = [];
  for (let index = 0; index < items.length; index += chunkSize) {
    chunkedList.push(items.slice(index, index + chunkSize));
  }
  return chunkedList;
}

/**
 * 푸시 알림 제목을 공지사항 중요도에 따라 포맷팅한다.
 *
 * @param {string} title 공지사항 원본 제목
 * @param {boolean} isImportant 중요 공지 여부
 * @return {string} 포맷팅된 푸시 알림 제목
 */
function formatNotificationTitle(title: string, isImportant: boolean): string {
  if (isImportant) {
    return `[중요] ${title}`;
  }
  return `[공지] ${title}`;
}

/**
 * 푸시 알림 본문 요약 문자열을 생성한다.
 * 모바일 알림 센터 가독성을 위해 최대 길이를 초과하는 경우 말줄임표(...)를 부착한다.
 *
 * @param {string} content 공지사항 본문 내용
 * @param {number} maxLength 최대 표시 문자열 길이
 * @return {string} 요약된 푸시 알림 본문
 */
function formatNotificationBody(content: string, maxLength = 120): string {
  const trimmed = content.trim();
  if (trimmed.length <= maxLength) {
    return trimmed;
  }
  return `${trimmed.slice(0, maxLength - 3)}...`;
}

export const onNoticeCreated = onDocumentCreated(
  {
    document: "notices/{noticeId}",
    region: "asia-northeast3",
    retry: false,
  },
  async (event) => {
    const snapshot = event.data;
    if (!snapshot) {
      logger.warn("이벤트 스냅샷이 누락되어 공지 푸시 발송을 중단합니다.", {
        eventId: event.id,
      });
      return;
    }
    const noticeId = event.params.noticeId;
    const notice = snapshot.data() as NoticeDocument;
    logger.info("신규 공지사항 감지, 푸시 브로드캐스트 준비 시작", {
      noticeId,
      title: notice.title,
      isImportant: Boolean(notice.isImportant),
    });
    const firestore = admin.firestore();

    const usersSnapshot = await firestore
      .collection("users")
      .where("fcmToken", ">", "")
      .get();
    if (usersSnapshot.empty) {
      logger.info("등록된 FCM 토큰을 보유한 사용자가 존재하지 않습니다.");
      return;
    }

    const tokenToUserUidMap = new Map<string, string>();
    const activeTokens: string[] = [];
    for (const userDocumentSnapshot of usersSnapshot.docs) {
      const userData = userDocumentSnapshot.data() as UserDocument;
      if (userData.notificationSettings?.pushEnabled === false) {
        continue;
      }
      const rawToken = userData.fcmToken;
      if (rawToken && typeof rawToken === "string") {
        const trimmedToken = rawToken.trim();
        if (trimmedToken.length > 0) {
          tokenToUserUidMap.set(trimmedToken, userDocumentSnapshot.id);
          activeTokens.push(trimmedToken);
        }
      }
    }
    if (activeTokens.length === 0) {
      logger.info(
        "푸시 수신을 허용한 유효 토큰 보유자가 없어 발송을 종료합니다."
      );
      return;
    }
    logger.info("공지사항 푸시 발송 대상자 선별 완료", {
      totalFoundTokens: activeTokens.length,
    });

    const notificationTitle = formatNotificationTitle(
      notice.title,
      Boolean(notice.isImportant)
    );
    const notificationBody = formatNotificationBody(notice.content);

    const tokenChunks = chunkArray(activeTokens, FCM_MULTICAST_CHUNK_LIMIT);
    let totalSuccessCount = 0;
    let totalFailureCount = 0;
    const invalidTokens: string[] = [];

    await Promise.all(
      tokenChunks.map(async (chunk, chunkIndex) => {
        const multicastMessage: admin.messaging.MulticastMessage = {
          tokens: chunk,
          notification: {
            title: notificationTitle,
            body: notificationBody,
          },
          data: {
            type: "notice",
            noticeId: String(noticeId),
            targetNoticeId: String(noticeId),
            isImportant: String(Boolean(notice.isImportant)),
            actionUrl: String(notice.actionUrl ?? ""),
          },
          android: {
            priority: "high",
            notification: {
              channelId: "high_importance_channel",
              sound: "default",
            },
          },
          apns: {
            payload: {
              aps: {
                sound: "default",
                badge: 1,
              },
            },
          },
        };
        try {
          const batchResponse = await admin
            .messaging()
            .sendEachForMulticast(multicastMessage);
          totalSuccessCount += batchResponse.successCount;
          totalFailureCount += batchResponse.failureCount;
          batchResponse.responses.forEach((responseItem, responseIndex) => {
            if (!responseItem.success) {
              const errorCode = responseItem.error?.code;
              if (
                errorCode ===
                  "messaging/registration-token-not-registered" ||
                errorCode === "messaging/invalid-registration-token"
              ) {
                const targetToken = chunk[responseIndex];
                if (targetToken) {
                  invalidTokens.push(targetToken);
                }
              }
            }
          });
        } catch (error) {
          logger.error(`청크 #${chunkIndex + 1} 멀티캐스트 전송 중 예외 발생:`, {
            error,
          });
        }
      })
    );
    logger.info("공지사항 푸시 브로드캐스트 전송 완료", {
      noticeId,
      totalTargetCount: activeTokens.length,
      successCount: totalSuccessCount,
      failureCount: totalFailureCount,
    });

    if (invalidTokens.length > 0) {
      logger.info(
        `만료된 토큰 ${invalidTokens.length}개에 대한 Firestore 일괄 정리 시작`
      );
      const targetUserUids: string[] = [];
      for (const token of invalidTokens) {
        const userUid = tokenToUserUidMap.get(token);
        if (userUid) {
          targetUserUids.push(userUid);
        }
      }
      const uidChunks = chunkArray(targetUserUids, FIRESTORE_BATCH_CHUNK_LIMIT);
      await Promise.all(
        uidChunks.map(async (uidChunk) => {
          const batch = firestore.batch();
          for (const userUid of uidChunk) {
            const userReference = firestore.collection("users").doc(userUid);
            batch.update(userReference, {
              fcmToken: admin.firestore.FieldValue.delete(),
              updatedAt: admin.firestore.FieldValue.serverTimestamp(),
            });
          }
          await batch.commit();
        })
      );
      logger.info("만료된 FCM 토큰 정리 완료", {
        cleanedUserCount: targetUserUids.length,
      });
    }
  }
);
