import { DataTypes } from "sequelize";
import sequelize from "../config/database.js";
import User from "./User.js";
import Task from "./Task.js";

const Notification = sequelize.define(
  "Notification",
  {
    id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    userId: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: {
        model: User,
        key: "id",
      },
    },
    taskId: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: {
        model: Task,
        key: "id",
      },
    },
    // Notification type: email, sms, push, in-app
    type: {
      type: DataTypes.ENUM("email", "sms", "push", "in-app"),
      defaultValue: "in-app",
      allowNull: false,
    },
    // Message to display
    message: {
      type: DataTypes.TEXT,
      allowNull: false,
    },
    // Has the user read/seen this notification?
    isRead: {
      type: DataTypes.BOOLEAN,
      defaultValue: false,
      allowNull: false,
    },
    // Status: pending, sent, failed
    status: {
      type: DataTypes.ENUM("pending", "sent", "failed"),
      defaultValue: "pending",
      allowNull: false,
    },
    // When the notification was sent
    sentAt: {
      type: DataTypes.DATE,
      allowNull: true,
    },
    // If failed, store the reason
    errorMessage: {
      type: DataTypes.TEXT,
      allowNull: true,
    },
    // When user read/dismissed the notification
    readAt: {
      type: DataTypes.DATE,
      allowNull: true,
    },
    // Store metadata about the task at notification time
    metadata: {
      type: DataTypes.JSON,
      allowNull: true, // e.g., { taskTitle: "...", dueDate: "...", category: "..." }
    },
    createdAt: {
      type: DataTypes.DATE,
      defaultValue: DataTypes.NOW,
    },
    updatedAt: {
      type: DataTypes.DATE,
      defaultValue: DataTypes.NOW,
    },
  },
  {
    // TTL Indexes for efficient cleanup
    indexes: [
      // Index for finding read notifications (TTL cleanup)
      {
        fields: ["isRead", "readAt"],
        name: "idx_notification_read_ttl",
      },
      // Index for finding unread old notifications
      {
        fields: ["isRead", "createdAt"],
        name: "idx_notification_unread_ttl",
      },
      // Index for user-specific TTL queries
      {
        fields: ["userId", "createdAt"],
        name: "idx_notification_user_created_ttl",
      },
      // Index for status-based cleanup
      {
        fields: ["status", "sentAt"],
        name: "idx_notification_status_sent_ttl",
      },
    ],
  }
);

// Associations
Notification.belongsTo(User, { foreignKey: "userId" });
Notification.belongsTo(Task, { foreignKey: "taskId" });

export default Notification;
