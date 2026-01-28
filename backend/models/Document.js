import mongoose from "mongoose";

const documentSchema = new mongoose.Schema(
  {
    filename: {
      type: String,
      required: true,
    },
    originalName: {
      type: String,
      required: false,
    },
    mimeType: {
      type: String,
      required: true,
    },
    fileSize: {
      type: Number,
      required: false,
    },
    filePath: {
      type: String,
      required: true,
    },
    taskId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Task",
      required: false,
    },
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },
    // Optional member reference for member documents
    memberId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Member",
      required: false,
    },
  },
  {
    timestamps: true,
  },
);

documentSchema.index({ taskId: 1 });
documentSchema.index({ userId: 1 });
documentSchema.index({ memberId: 1 });

const Document = mongoose.model("Document", documentSchema);

export default Document;
