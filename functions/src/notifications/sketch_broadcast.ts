import {onDocumentCreated} from "firebase-functions/v2/firestore";
import * as admin from "firebase-admin";
import * as logger from "firebase-functions/logger";
import {
  FriendshipDocument,
  SketchPostDocument,
} from "../types/notification";

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

export const onSketchPostCreated = onDocumentCreated(
  {
    document: "sketch_posts/{sketchId}",
    region: "asia-northeast3",
    retry: false,
  },
  async (event) => {
    const snapshot = event.data;
    if (!snapshot) {
      logger.warn(
        "이벤트 스냅샷이 누락되어 스케치 알림 브로드캐스트를 중단합니다.",
        {eventId: event.id}
      );
      return;
    }
    const sketchId = event.params.sketchId;
    const sketchData = snapshot.data() as SketchPostDocument | undefined;
    if (!sketchData) {
      logger.warn("스케치 데이터가 비어있어 처리를 중단합니다.", {sketchId});
      return;
    }

    if (sketchData.deletedAt != null) {
      logger.info(
        "삭제 처리된 스케치 게시물이므로 알림 생성을 건너뜁니다.",
        {sketchId}
      );
      return;
    }
    const {authorId, author} = sketchData;
    if (!authorId || !author || typeof authorId !== "string") {
      logger.warn(
        "스케치 작성자 정보가 유효하지 않습니다.",
        {sketchId, authorId, author}
      );
      return;
    }
    const firestore = admin.firestore();
    try {
      const friendshipsSnapshot = await firestore
        .collection("friendships")
        .where("members", "array-contains", authorId)
        .where("status", "==", "accepted")
        .get();
      if (friendshipsSnapshot.empty) {
        logger.info(
          "해당 작성자와 맺어진 친구 관계가 없어 알림 생성을 종료합니다.",
          {sketchId, authorId}
        );
        return;
      }

      const recipientUidSet = new Set<string>();
      for (const friendshipDoc of friendshipsSnapshot.docs) {
        const friendship = friendshipDoc.data() as FriendshipDocument;
        const members = friendship.members;
        const favorites = friendship.favorites;
        if (!Array.isArray(members) || !Array.isArray(favorites)) {
          continue;
        }

        const friendUid = members.find((memberUid) => memberUid !== authorId);
        if (!friendUid) {
          continue;
        }

        if (favorites.includes(friendUid)) {
          recipientUidSet.add(friendUid);
        }
      }
      const targetRecipientUids = Array.from(recipientUidSet);
      if (targetRecipientUids.length === 0) {
        logger.info(
          "작성자를 관심 친구로 등록한 친구가 존재하지 않습니다.",
          {sketchId, authorId}
        );
        return;
      }
      logger.info("관심 친구 스케치 알림 대상자 선별 완료", {
        sketchId,
        authorId,
        recipientCount: targetRecipientUids.length,
      });
      const recipientChunks = chunkArray(
        targetRecipientUids,
        FIRESTORE_BATCH_CHUNK_LIMIT
      );

      await Promise.all(
        recipientChunks.map(async (chunk) => {
          const batch = firestore.batch();
          for (const recipientId of chunk) {
            const notificationRef = firestore.collection("notifications").doc();
            batch.set(notificationRef, {
              id: notificationRef.id,
              recipientId,
              sender: {
                uid: author.uid,
                username: author.username ?? "",
                nickname: author.nickname ?? "",
                imageUrl: author.imageUrl ?? null,
              },
              type: "sketch",
              targetSketchId: sketchId,
              targetCommentId: null,
              targetNoticeId: null,
              noticeTitle: null,
              isRead: false,
              createdAt: admin.firestore.FieldValue.serverTimestamp(),
            });
          }
          await batch.commit();
        })
      );
      logger.info("관심 친구 스케치 알림 문서 일괄 생성 완료", {
        sketchId,
        authorId,
        totalCreatedCount: targetRecipientUids.length,
      });
    } catch (error) {
      logger.error("스케치 알림 브로드캐스트 처리 중 예외 발생:", {
        sketchId,
        authorId,
        error,
      });
    }
  }
);
