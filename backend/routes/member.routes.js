import express from "express";
import memberController from "../controller/member.controller.js";
import authMiddleware from "../utils/authMiddleware.js";
import { apiLimiter, uploadLimiter } from "../utils/rateLimitMiddleware.js";
import upload from "../utils/fileUpload.js";

const router = express.Router();

// All member routes require authentication
router.use(authMiddleware);
router.use(apiLimiter);

// ===== MEMBER MANAGEMENT =====

// Add a new member
router.post("/", (req, res) => memberController.addMember(req, res));

// Get all members for the user
router.get("/", (req, res) => memberController.getMembers(req, res));

// Get member statistics
router.get("/stats/overview", (req, res) =>
  memberController.getMemberStatistics(req, res),
);

// Get emergency contacts
router.get("/emergency/contacts", (req, res) =>
  memberController.getEmergencyContacts(req, res),
);

// Search members
router.get("/search", (req, res) => memberController.searchMembers(req, res));

// Get specific member details
router.get("/:id", (req, res) => memberController.getMemberDetails(req, res));

// Update member
router.put("/:id", (req, res) => memberController.updateMember(req, res));

// Delete member
router.delete("/:id", (req, res) => memberController.deleteMember(req, res));

// Get member's documents
router.get("/:id/documents", (req, res) =>
  memberController.getMemberDocuments(req, res),
);

// Upload document for a member
router.post(
  "/:id/upload-document",
  uploadLimiter,
  upload.single("document"),
  (req, res) => memberController.uploadMemberDocument(req, res),
);

export default router;
