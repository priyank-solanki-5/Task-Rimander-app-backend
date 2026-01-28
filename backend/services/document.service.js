import documentDao from "../dao/documentDao.js";
import taskDao from "../dao/taskDao.js";
import fs from "fs/promises";
import path from "path";
import { fileURLToPath } from "url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Get absolute path to uploads directory
const UPLOADS_DIR = path.join(__dirname, "../uploads/documents");

class DocumentService {
  async uploadDocument(userId, taskId, file, memberId = null) {
    // Validate task exists and belongs to user ONLY if taskId is provided
    if (taskId && taskId !== "null" && taskId !== "undefined") {
      const task = await taskDao.findTaskById(taskId, userId);
      if (!task) {
        // Delete uploaded file if task validation fails
        await fs.unlink(file.path).catch(() => {});
        throw new Error("Task not found or unauthorized");
      }
    }

    // Prepare document data
    const docData = {
      filename: file.originalname,
      originalName: file.originalname,
      mimeType: file.mimetype,
      fileSize: file.size,
      filePath: `uploads/documents/${file.originalname}`,
      userId,
    };

    // Add optional fields if they exist
    if (taskId && taskId !== "null" && taskId !== "undefined") {
      docData.taskId = taskId;
    }

    if (memberId && memberId !== "null" && memberId !== "undefined") {
      docData.memberId = memberId;
    }

    // Create document record
    const document = await documentDao.createDocument(docData);

    return document;
  }

  async getDocumentById(id, userId) {
    const document = await documentDao.findDocumentById(id, userId);
    if (!document) {
      throw new Error("Document not found or unauthorized");
    }
    return document;
  }

  async getDocumentsByTask(taskId, userId) {
    // Verify task belongs to user
    const task = await taskDao.findTaskById(taskId, userId);
    if (!task) {
      throw new Error("Task not found or unauthorized");
    }

    return await documentDao.findDocumentsByTask(taskId, userId);
  }

  async getDocumentsByUser(userId) {
    return await documentDao.findDocumentsByUser(userId);
  }

  async deleteDocument(id, userId) {
    const document = await documentDao.findDocumentById(id, userId);
    if (!document) {
      throw new Error("Document not found or unauthorized");
    }

    // Delete physical file using absolute path
    try {
      const absolutePath = path.join(UPLOADS_DIR, document.filename);
      await fs.unlink(absolutePath);
    } catch (error) {
      console.error("Error deleting physical file:", error);
    }

    // Delete database record
    await documentDao.deleteDocument(id, userId);
    return { message: "Document deleted successfully" };
  }

  async getDocumentPath(id, userId) {
    const document = await documentDao.findDocumentById(id, userId);
    if (!document) {
      throw new Error("Document not found or unauthorized");
    }

    // Get absolute path for file access
    const absolutePath = path.join(UPLOADS_DIR, document.filename);

    // Check if file exists
    try {
      await fs.access(absolutePath);
    } catch (error) {
      throw new Error("File not found on server");
    }

    return {
      path: absolutePath,
      originalName: document.originalName,
      mimeType: document.mimeType,
    };
  }
}

export default new DocumentService();
