import Task from "../models/Task.js";
import Category from "../models/Category.js";
import User from "../models/User.js";

class TaskDao {
  async createTask(taskData) {
    const task = new Task(taskData);
    return await task.save();
  }

  async findAllTasksByUser(userId, filters = {}) {
    const query = { userId };

    // Add status filter if provided
    if (filters.status) {
      query.status = filters.status;
    }

    // Add category filter if provided
    if (filters.categoryId) {
      query.categoryId = filters.categoryId;
    }

    return await Task.find(query)
      .populate("categoryId", "id name isPredefined")
      .populate("memberId", "id name")
      .sort({ dueDate: 1, createdAt: -1 });
  }

  async findTaskById(id, userId) {
    return await Task.findOne({ _id: id, userId })
      .populate("categoryId", "id name isPredefined")
      .populate("memberId", "id name");
  }

  async updateTask(task, updateData) {
    Object.assign(task, updateData);
    return await task.save();
  }

  async deleteTask(id, userId) {
    return await Task.findOneAndDelete({ _id: id, userId });
  }

  async findOverdueTasks(userId) {
    return await Task.find({
      userId,
      status: "Pending",
      dueDate: { $lt: new Date() },
    })
      .populate("categoryId", "id name")
      .sort({ dueDate: 1 });
  }

  async findUpcomingTasks(userId, days = 7) {
    const startDate = new Date();
    const endDate = new Date();
    endDate.setDate(endDate.getDate() + days);

    return await Task.find({
      userId,
      status: "Pending",
      dueDate: { $gte: startDate, $lte: endDate },
    })
      .populate("categoryId", "id name")
      .sort({ dueDate: 1 });
  }

  async findRecurringTasks(userId) {
    return await Task.find({
      userId,
      isRecurring: true,
    })
      .populate("categoryId", "id name")
      .sort({ nextOccurrence: 1 });
  }

  async findTasksDueForRecurrence() {
    const now = new Date();
    return await Task.find({
      isRecurring: true,
      status: "Completed",
      nextOccurrence: { $lte: now },
    }).populate("categoryId", "id name");
  }

  /**
   * Search tasks by name (title)
   * Supports partial matching using regex
   */
  async searchTasksByName(userId, searchTerm) {
    return await Task.find({
      userId,
      title: { $regex: searchTerm, $options: "i" },
    })
      .populate("categoryId", "id name isPredefined")
      .sort({ dueDate: 1, createdAt: -1 });
  }

  /**
   * Advanced filter for tasks
   * Supports: name search, category filter, status filter, date range
   */
  async filterTasks(userId, filters = {}) {
    const query = { userId };

    // Search by name (partial match)
    if (filters.search) {
      query.title = { $regex: filters.search, $options: "i" };
    }

    // Filter by status (exact match)
    if (filters.status) {
      query.status = filters.status;
    }

    // Filter by category (exact match)
    if (filters.categoryId) {
      query.categoryId = filters.categoryId;
    }

    // Filter by date range
    if (filters.startDate || filters.endDate) {
      query.dueDate = {};
      if (filters.startDate) {
        query.dueDate.$gte = new Date(filters.startDate);
      }
      if (filters.endDate) {
        query.dueDate.$lte = new Date(filters.endDate);
      }
    }

    // Filter by recurring status
    if (filters.isRecurring !== undefined) {
      query.isRecurring = filters.isRecurring;
    }

    return await Task.find(query)
      .populate("categoryId", "id name isPredefined")
      .sort({ dueDate: 1, createdAt: -1 });
  }

  /**
   * Get task count by filters
   */
  async getTaskCountByFilters(userId, filters = {}) {
    const query = { userId };

    if (filters.search) {
      query.title = { $regex: filters.search, $options: "i" };
    }

    if (filters.status) {
      query.status = filters.status;
    }

    if (filters.categoryId) {
      query.categoryId = filters.categoryId;
    }

    return await Task.countDocuments(query);
  }
}

export default new TaskDao();
