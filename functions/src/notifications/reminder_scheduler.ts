import {onSchedule} from "firebase-functions/v2/scheduler";
import * as admin from "firebase-admin";
import * as logger from "firebase-functions/logger";
import {UserDocument} from "../types/notification";

export const sendDailyReminderNotification = onSchedule(
  {
    schedule: "0 * * * *", // 매시간 정각 실행
    timeZone: "Asia/Seoul",
    region: "asia-northeast3",
    retryCount: 1,
  },
  async () => {
    const db = admin.firestore();
    const now = new Date();

    const formatter = new Intl.DateTimeFormat("en-US", {
      timeZone: "Asia/Seoul",
      year: "numeric",
      month: "2-digit",
      day: "2-digit",
      hour: "numeric",
      hourCycle: "h23",
      weekday: "short",
    });
    const parts = formatter.formatToParts(now);
    const partMap = Object.fromEntries(
      parts.map((part) => [part.type, part.value])
    );
    const currentHour = parseInt(partMap.hour, 10);
    const weekdayMap: Record<string, number> = {
      Mon: 1,
      Tue: 2,
      Wed: 3,
      Thu: 4,
      Fri: 5,
      Sat: 6,
      Sun: 7,
    };
    const currentWeekday = weekdayMap[partMap.weekday] ?? 1;

    const todayStartKst = new Date(
      `${partMap.year}-${partMap.month}-${partMap.day}T00:00:00+09:00`
    );
    logger.info("운동 리마인더 스케줄러 실행", {
      currentHour,
      currentWeekday,
      todayStartKst: todayStartKst.toISOString(),
    });

    const usersSnapshot = await db
      .collection("users")
      .where("notificationSettings.pushEnabled", "==", true)
      .where("notificationSettings.reminderNotification", "==", true)
      .where("notificationSettings.reminderHour", "==", currentHour)
      .get();
    if (usersSnapshot.empty) {
      logger.info("해당 시간대 리마인더 수신 대상 사용자가 없습니다.");
      return;
    }

    const eligibleUsers: UserDocument[] = [];
    for (const doc of usersSnapshot.docs) {
      const user = doc.data() as UserDocument;
      const reminderDays =
        user.notificationSettings?.reminderDays ?? [1, 2, 3, 4, 5];
      if (
        reminderDays.includes(currentWeekday) &&
        user.fcmToken &&
        user.fcmToken.trim().length > 0
      ) {
        eligibleUsers.push(user);
      }
    }
    if (eligibleUsers.length === 0) {
      logger.info(
        "요일 설정 또는 FCM 토큰 조건을 만족하는 대상 사용자가 없습니다."
      );
      return;
    }

    const messagesToSend: admin.messaging.Message[] = [];
    for (const user of eligibleUsers) {
      const sessionsSnapshot = await db
        .collection("session_results")
        .where("userId", "==", user.uid)
        .where(
          "endedAt",
          ">=",
          admin.firestore.Timestamp.fromDate(todayStartKst)
        )
        .where("deletedAt", "==", null)
        .limit(1)
        .get();

      if (!sessionsSnapshot.empty) {
        logger.info(
          `사용자 ${user.uid} (${user.nickname})님은 오늘 이미 운동을 완료하여 리마인더 발송을 생략합니다.`
        );
        continue;
      }

      const fcmToken = user.fcmToken;
      if (!fcmToken) {
        continue;
      }

      messagesToSend.push({
        token: fcmToken,
        notification: {
          title: "무브스케치",
          body: `${user.nickname}님, 오늘 정해둔 운동 시간이에요! 가볍게 몸을 움직여볼까요?`,
        },
        data: {
          type: "reminder",
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
      });
    }
    if (messagesToSend.length === 0) {
      logger.info(
        "발송 대상 사용자가 없습니다 (모두 오늘 이미 운동을 완료함)."
      );
      return;
    }

    const batchResponse = await admin.messaging().sendEach(messagesToSend);
    logger.info(
      "리마인더 푸시 발송 완료: " +
      `성공 ${batchResponse.successCount}건, ` +
      `실패 ${batchResponse.failureCount}건`
    );
  }
);
