import * as admin from "firebase-admin";

admin.initializeApp();

export {onNotificationCreated} from "./notifications/send_push_notification";
export {
  sendDailyReminderNotification,
} from "./notifications/reminder_scheduler";
