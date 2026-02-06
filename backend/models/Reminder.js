import mongoose from "mongoose";

const reminderSchema = new mongoose.Schema(
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
    minutesBeforeDue: {
      type: Number,
      required: true,
    },
    reminderDate: {
      type: Date,
      default: null,
    },
    isTriggered: {
      type: Boolean,
      default: false,
    },
    isActive: {
      type: Boolean,
      default: true,
    },
    triggeredAt: {
      type: Date,
      default: null,
    },
    metadata: {
      type: mongoose.Schema.Types.Mixed,
      default: null,
    },
    history: {
      type: [
        {
          triggeredAt: Date,
          status: String,
        },
      ],
      default: [],
    },
    type: {
      type: String,
      enum: ["email", "sms", "push", "in-app"],
      default: "in-app",
    },
  },
  {
    timestamps: true,
  }
);

reminderSchema.index({ userId: 1, isActive: 1 });
reminderSchema.index({ reminderDate: 1 });

const Reminder = mongoose.model("Reminder", reminderSchema);

export default Reminder;
