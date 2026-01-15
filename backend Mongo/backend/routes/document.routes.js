import express from "express";
import documentController from "../controller/document.controller.js";
import upload from "../utils/fileUpload.js";
import authMiddleware from "../utils/authMiddleware.js";
import { apiLimiter, uploadLimiter } from "../utils/rateLimitMiddleware.js";
import {
  verifyDocumentOwnership,
  verifyTaskOwnership,
} from "../utils/ownershipMiddleware.js";
import { validateIdParam } from "../utils/validationMiddleware.js";

const router = express.Router();

// Apply authentication and rate limiting to all document routes
router.use(authMiddleware);
router.use(apiLimiter);

// Upload document (with rate limiting and task ownership verification)
router.post("/upload", uploadLimiter, upload.single("document"), (req, res) =>
  documentController.uploadDocument(req, res)
);

// Get all documents for authenticated user
router.get("/", (req, res) => documentController.getDocumentsByUser(req, res));

// Get documents by task (with task ownership verification)
router.get("/task/:taskId", validateIdParam, verifyTaskOwnership, (req, res) =>
  documentController.getDocumentsByTask(req, res)
);

// Get document by ID (with document ownership verification)
router.get("/:id", validateIdParam, verifyDocumentOwnership, (req, res) =>
  documentController.getDocumentById(req, res)
);

// Download document (with document ownership verification for file access protection)
router.get(
  "/:id/download",
  validateIdParam,
  verifyDocumentOwnership,
  (req, res) => documentController.downloadDocument(req, res)
);

// Delete document (with document ownership verification)
router.delete("/:id", validateIdParam, verifyDocumentOwnership, (req, res) =>
  documentController.deleteDocument(req, res)
);

export default router;
