export type NotificationType =
  | "comment"
  | "reply"
  | "cheer"
  | "requestFriend"
  | "acceptFriend"
  | "reminder"
  | "notice"
  | "unknown";

export interface SenderSummary {
  readonly uid: string;
  readonly username: string;
  readonly nickname: string;
  readonly imageUrl?: string | null;
}

export interface AppNotificationDocument {
  readonly id: string;
  readonly recipientId: string;
  readonly sender: SenderSummary;
  readonly type: NotificationType;
  readonly targetSketchId?: string | null;
  readonly targetCommentId?: string | null;
  readonly isRead: boolean;
  readonly createdAt: string;
}

export interface NotificationSettings {
  readonly pushEnabled: boolean;
  readonly friendNotification: boolean;
  readonly responseNotification: boolean;
  readonly reminderNotification: boolean;
  readonly reminderDays?: number[];
  readonly reminderHour?: number;
}

export interface UserDocument {
  readonly uid: string;
  readonly username: string;
  readonly nickname: string;
  readonly fcmToken?: string | null;
  readonly notificationSettings?: NotificationSettings;
}

export interface NoticeDocument {
  readonly id?: string;
  readonly title: string;
  readonly content: string;
  readonly createdAt: string;
  readonly isImportant?: boolean;
  readonly actionUrl?: string | null;
  readonly actionButtonText?: string | null;
}
