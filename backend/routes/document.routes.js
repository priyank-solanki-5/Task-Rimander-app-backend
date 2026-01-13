import express from "express";
import documentController from "../controller/document.controller.js";
import upload from "../utils/fileUpload.js";
import authMiddleware from "../utils/authMiddleware.js";

const router = express.Router();

// Apply authentication middleware to all document routes
router.use(authMiddleware);

// Upload document
router.post("/upload", upload.single("document"), (req, res) =>
  documentController.uploadDocument(req, res)
);

// Get all documents for authenticated user
router.get("/", (req, res) => documentController.getDocumentsByUser(req, res));

// Get documents by task
router.get("/task/:taskId", (req, res) =>
  documentController.getDocumentsByTask(req, res)
);

// Get document by ID
router.get("/:id", (req, res) => documentController.getDocumentById(req, res));

// Download document
router.get("/:id/download", (req, res) =>
  documentController.downloadDocument(req, res)
);

// Delete document
router.delete("/:id", (req, res) =>
  documentController.deleteDocument(req, res)
);

export default router;
