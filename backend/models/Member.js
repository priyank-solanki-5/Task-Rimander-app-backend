import mongoose from "mongoose";

const memberSchema = new mongoose.Schema(
  {
    // Owner of the member record
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },
    // Member details
    memberName: {
      type: String,
      required: true,
    },
    memberEmail: {
      type: String,
      lowercase: true,
    },
    memberPhone: {
      type: String,
    },
    // Address
    address: {
      street: String,
      city: String,
      state: String,
      zipCode: String,
      country: String,
    },
    // Additional contact info
    dateOfBirth: Date,
    isActive: {
      type: Boolean,
      default: true,
    },
    // Additional metadata
    metadata: {
      type: mongoose.Schema.Types.Mixed,
      default: {},
    },
    // Documents associated with this member
    documents: [
      {
        type: mongoose.Schema.Types.ObjectId,
        ref: "Document",
      },
    ],
  },
  {
    timestamps: true,
  },
);

memberSchema.index({ userId: 1 });
memberSchema.index({ userId: 1, memberName: 1 });
memberSchema.index({ memberEmail: 1 });

const Member = mongoose.model("Member", memberSchema);

export default Member;
