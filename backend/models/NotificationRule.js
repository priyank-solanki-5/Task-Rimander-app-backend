import mongoose from "mongoose";

const notificationRuleSchema = new mongoose.Schema(
  {
    taskId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Task",
      required: true,
    },
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },
    type: {
      type: String,
      enum: ["email", "sms", "push", "in-app"],
      default: "in-app",
    },
    triggerType: {
      type: String,
      enum: [
        "on_due_date",
        "before_due_date",
        "after_due_date",
        "on_completion",
      ],
      default: "on_due_date",
    },
    hoursBeforeDue: {
      type: Number,
      default: null,
    },
    isActive: {
      type: Boolean,
      default: true,
    },
  },
  {
    timestamps: true,
  }
);

notificationRuleSchema.index({ userId: 1, taskId: 1 });
notificationRuleSchema.index({ isActive: 1 });

const NotificationRule = mongoose.model(
  "NotificationRule",
  notificationRuleSchema
);

export default NotificationRule;
