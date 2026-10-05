import {onDocumentCreated} from "firebase-functions/v2/firestore";
import * as admin from "firebase-admin";
import * as logger from "firebase-functions/logger";
import {
  AppNotificationDocument,
  NotificationType,
  UserDocument,
} from "../types/notification";

/**
 * 알림 타입별 푸시 메시지 본문(Body) 문자열을 생성한다.
 *
 * @param {string} senderNickname 발신자 닉네임
 * @param {NotificationType} type 알림 타입
 * @return {string} 포맷팅된 알림 메시지 문자열
 */
function buildNotificationBody(
  senderNickname: string,
  type: NotificationType
): string {
  switch (type) {
  case "comment":
    return `${senderNickname} 님이 내 스케치에 댓글을 달았어요.`;
  case "reply":
    return `${senderNickname} 님이 내 댓글에 답글을 달았어요.`;
  case "cheer":
    return `${senderNickname} 님이 내 스케치에 응원을 보냈어요.`;
  case "requestFriend":
    return `${senderNickname} 님이 친구 요청을 보냈어요.`;
  case "acceptFriend":
    return `${senderNickname} 님이 친구 요청을 수락했어요.`;
  default:
    return `${senderNickname} 님으로부터 새로운 알림이 도착했습니다.`;
  }
}

/**
 * 수신자의 알림 설정에 따라 해당 알림의 푸시 발송 허용 여부를 검증한다.
 *
 * @param {UserDocument} user 수신자 사용자 문서 데이터
 * @param {NotificationType} type 알림 타입
 * @return {boolean} 발송 허용 여부
 */
function isNotificationAllowed(
  user: UserDocument,
  type: NotificationType,
): boolean {
  const settings = user.notificationSettings;
  if (!settings) {
    return true;
  }

  if (settings.pushEnabled === false) {
    return false;
  }

  switch (type) {
  case "requestFriend":
  case "acceptFriend":
    return settings.friendNotification ?? true;
  case "comment":
  case "reply":
  case "cheer":
    return settings.responseNotification ?? true;
  default:
    return true;
  }
}

export const onNotificationCreated = onDocumentCreated(
  {
    document: "notifications/{notificationId}",
    region: "asia-northeast3",
    retry: false,
  },
  async (event) => {
    const snapshot = event.data;
    if (!snapshot) {
      logger.warn("이벤트 스냅샷이 누락되었습니다.", {eventId: event.id});
      return;
    }

    const notification = snapshot.data() as AppNotificationDocument;
    const {recipientId, sender, type} = notification;

    if (recipientId === sender.uid) {
      logger.info("발신자와 수신자가 동일하므로 푸시 발송을 생략합니다.", {
        recipientId,
        type,
      });
      return;
    }

    const db = admin.firestore();

    const userDocSnapshot = await db.collection("users").doc(recipientId).get();
    if (!userDocSnapshot.exists) {
      logger.warn("수신자를 찾을 수 없습니다.", {recipientId});
      return;
    }

    const userData = userDocSnapshot.data() as UserDocument;

    const fcmToken = userData.fcmToken;
    if (!fcmToken || typeof fcmToken !== "string" || fcmToken.trim() === "") {
      logger.info("수신자의 등록된 FCM 토큰이 없어 푸시 발송을 건너뜁니다.", {
        recipientId,
      });
      return;
    }

    if (!isNotificationAllowed(userData, type)) {
      logger.info("수신자의 알림 설정에 의해 푸시 발송이 차단되었습니다.", {
        recipientId,
        type,
        settings: userData.notificationSettings,
      });
      return;
    }

    const title = "무브스케치";
    const body = buildNotificationBody(sender.nickname, type);

    const message: admin.messaging.Message = {
      token: fcmToken,
      notification: {
        title,
        body,
      },
      data: {
        type: String(type),
        targetSketchId: String(notification.targetSketchId ?? ""),
        senderUsername: String(sender.username ?? ""),
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
      const response = await admin.messaging().send(message);
      logger.info("푸시 알림이 성공적으로 전송되었습니다.", {
        recipientId,
        type,
        messageId: response,
      });
    } catch (error: unknown) {
      const firebaseError = error as {code?: string; message?: string};
      logger.error("푸시 알림 전송 실패:", {
        recipientId,
        errorCode: firebaseError.code,
        errorMessage: firebaseError.message,
      });

      if (
        firebaseError.code === "messaging/registration-token-not-registered" ||
        firebaseError.code === "messaging/invalid-registration-token"
      ) {
        logger.info("만료된 FCM 토큰을 사용자 문서에서 제거합니다.", {
          recipientId,
        });
        await db.collection("users").doc(recipientId).update({
          fcmToken: admin.firestore.FieldValue.delete(),
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      }
    }
  }
);
