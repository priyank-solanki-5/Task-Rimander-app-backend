import Document from "../models/Document.js";
import Task from "../models/Task.js";

class DocumentDao {
  async createDocument(documentData) {
    return await Document.create(documentData);
  }

  async findDocumentById(id, userId) {
    return await Document.findOne({
      where: { id, userId },
      include: [
        {
          model: Task,
          as: "task",
          attributes: ["id", "title"],
        },
      ],
    });
  }

  async findDocumentsByTask(taskId, userId) {
    return await Document.findAll({
      where: { taskId, userId },
      order: [["createdAt", "DESC"]],
    });
  }

  async findDocumentsByUser(userId) {
    return await Document.findAll({
      where: { userId },
      include: [
        {
          model: Task,
          as: "task",
          attributes: ["id", "title"],
        },
      ],
      order: [["createdAt", "DESC"]],
    });
  }

  async deleteDocument(id, userId) {
    return await Document.destroy({ where: { id, userId } });
  }

  async countDocumentsByTask(taskId) {
    return await Document.count({ where: { taskId } });
  }
}

export default new DocumentDao();
