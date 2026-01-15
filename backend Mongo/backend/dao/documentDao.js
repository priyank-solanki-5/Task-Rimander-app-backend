import Document from "../models/Document.js";
import Task from "../models/Task.js";

class DocumentDao {
  async createDocument(documentData) {
    const document = new Document(documentData);
    return await document.save();
  }

  async findDocumentById(id, userId) {
    return await Document.findOne({ _id: id, userId }).populate(
      "taskId",
      "id title"
    );
  }

  async findDocumentsByTask(taskId, userId) {
    return await Document.find({ taskId, userId }).sort({ createdAt: -1 });
  }

  async findDocumentsByUser(userId) {
    return await Document.find({ userId })
      .populate("taskId", "id title")
      .sort({ createdAt: -1 });
  }

  async deleteDocument(id, userId) {
    return await Document.findOneAndDelete({ _id: id, userId });
  }

  async countDocumentsByTask(taskId) {
    return await Document.countDocuments({ taskId });
  }
}

export default new DocumentDao();
