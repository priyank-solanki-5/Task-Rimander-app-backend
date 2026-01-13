import express from "express";
import documentController from "../controller/document.controller.js";
import upload from "../utils/fileUpload.js";

const router = express.Router();

// Upload document
router.post("/upload", upload.single("document"), (req, res) =>
  documentController.uploadDocument(req, res)
);

// Get document by ID
router.get("/:id", (req, res) => documentController.getDocumentById(req, res));

// Get documents by task
router.get("/task/:taskId", (req, res) =>
  documentController.getDocumentsByTask(req, res)
);

// Get documents by user
router.get("/user/:userId", (req, res) =>
  documentController.getDocumentsByUser(req, res)
);

// Download document
router.get("/:id/download", (req, res) =>
  documentController.downloadDocument(req, res)
);

// Delete document
router.delete("/:id", (req, res) =>
  documentController.deleteDocument(req, res)
);

export default router;
