import documentService from "../services/document.service.js";
import fs from "fs/promises";

class DocumentController {
  async uploadDocument(req, res) {
    try {
      const { taskId, memberId } = req.body;
      const userId = req.user.id; // Get from authenticated token

      // Validate file exists
      if (!req.file) {
        return res.status(400).json({
          error: "No file uploaded",
        });
      }

      const document = await documentService.uploadDocument(
        userId,
        taskId,
        req.file,
        memberId
      );

      res.status(201).json({
        message: "Document uploaded successfully",
        data: {
          id: document.id,
          filename: document.filename,
          originalName: document.originalName,
          mimeType: document.mimeType,
          fileSize: document.fileSize,
          taskId: document.taskId,
          memberId: document.memberId,
        },
      });
    } catch (error) {
      // Clean up uploaded file on error
      if (req.file) {
        await fs.unlink(req.file.path).catch((err) => {
          console.error("Failed to delete temp file:", err);
        });
      }
      res.status(400).json({ error: error.message });
    }
  }

  async getDocumentById(req, res) {
    try {
      const { id } = req.params;
      const userId = req.user.id; // Get from authenticated token

      const document = await documentService.getDocumentById(id, userId);

      res.status(200).json({
        message: "Document fetched successfully",
        data: document,
      });
    } catch (error) {
      res.status(404).json({ error: error.message });
    }
  }

  async getDocumentsByTask(req, res) {
    try {
      const { taskId } = req.params;
      const userId = req.user.id; // Get from authenticated token

      const documents = await documentService.getDocumentsByTask(
        taskId,
        userId
      );

      res.status(200).json({
        message: "Documents fetched successfully",
        data: documents,
      });
    } catch (error) {
      res.status(404).json({ error: error.message });
    }
  }

  async getDocumentsByUser(req, res) {
    try {
      const userId = req.user.id; // Get from authenticated token

      const documents = await documentService.getDocumentsByUser(userId);

      res.status(200).json({
        message: "Documents fetched successfully",
        data: documents,
      });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }

  async downloadDocument(req, res) {
    try {
      const { id } = req.params;
      const userId = req.user.id; // Get from authenticated token

      const { path, originalName, mimeType } =
        await documentService.getDocumentPath(id, userId);

      // Set headers for file download
      res.setHeader("Content-Type", mimeType);
      res.setHeader(
        "Content-Disposition",
        `attachment; filename="${originalName}"`
      );

      // Stream file to response
      const fileStream = await fs.readFile(path);
      res.send(fileStream);
    } catch (error) {
      res.status(404).json({ error: error.message });
    }
  }

  async deleteDocument(req, res) {
    try {
      const { id } = req.params;
      const userId = req.user.id; // Get from authenticated token

      const result = await documentService.deleteDocument(id, userId);

      res.status(200).json(result);
    } catch (error) {
      res.status(400).json({ error: error.message });
    }
  }
}

export default new DocumentController();
