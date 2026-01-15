import { Op } from "sequelize";
import Task from "../models/Task.js";
import Category from "../models/Category.js";
import User from "../models/User.js";

class TaskDao {
  async createTask(taskData) {
    return await Task.create(taskData);
  }

  async findAllTasksByUser(userId, filters = {}) {
    const whereClause = { userId };

    // Add status filter if provided
    if (filters.status) {
      whereClause.status = filters.status;
    }

    // Add category filter if provided
    if (filters.categoryId) {
      whereClause.categoryId = filters.categoryId;
    }

    return await Task.findAll({
      where: whereClause,
      include: [
        {
          model: Category,
          as: "category",
          attributes: ["id", "name", "isPredefined"],
        },
      ],
      order: [
        ["dueDate", "ASC"],
        ["createdAt", "DESC"],
      ],
    });
  }

  async findTaskById(id, userId) {
    return await Task.findOne({
      where: { id, userId },
      include: [
        {
          model: Category,
          as: "category",
          attributes: ["id", "name", "isPredefined"],
        },
      ],
    });
  }

  async updateTask(task, updateData) {
    return await task.update(updateData);
  }

  async deleteTask(id, userId) {
    return await Task.destroy({ where: { id, userId } });
  }

  async findOverdueTasks(userId) {
    return await Task.findAll({
      where: {
        userId,
        status: "Pending",
        dueDate: {
          [Op.lt]: new Date(),
        },
      },
      include: [
        {
          model: Category,
          as: "category",
          attributes: ["id", "name"],
        },
      ],
      order: [["dueDate", "ASC"]],
    });
  }

  async findUpcomingTasks(userId, days = 7) {
    const startDate = new Date();
    const endDate = new Date();
    endDate.setDate(endDate.getDate() + days);

    return await Task.findAll({
      where: {
        userId,
        status: "Pending",
        dueDate: {
          [Op.between]: [startDate, endDate],
        },
      },
      include: [
        {
          model: Category,
          as: "category",
          attributes: ["id", "name"],
        },
      ],
      order: [["dueDate", "ASC"]],
    });
  }

  async findRecurringTasks(userId) {
    return await Task.findAll({
      where: {
        userId,
        isRecurring: true,
      },
      include: [
        {
          model: Category,
          as: "category",
          attributes: ["id", "name"],
        },
      ],
      order: [["nextOccurrence", "ASC"]],
    });
  }

  async findTasksDueForRecurrence() {
    const now = new Date();
    return await Task.findAll({
      where: {
        isRecurring: true,
        status: "Completed",
        nextOccurrence: {
          [Op.lte]: now,
        },
      },
      include: [
        {
          model: Category,
          as: "category",
          attributes: ["id", "name"],
        },
      ],
    });
  }

  /**
   * Search tasks by name (title)
   * Supports partial matching using LIKE
   */
  async searchTasksByName(userId, searchTerm) {
    return await Task.findAll({
      where: {
        userId,
        title: {
          [Op.like]: `%${searchTerm}%`,
        },
      },
      include: [
        {
          model: Category,
          as: "category",
          attributes: ["id", "name", "isPredefined"],
        },
      ],
      order: [
        ["dueDate", "ASC"],
        ["createdAt", "DESC"],
      ],
    });
  }

  /**
   * Advanced filter for tasks
   * Supports: name search, category filter, status filter, date range
   */
  async filterTasks(userId, filters = {}) {
    const whereClause = { userId };

    // Search by name (partial match)
    if (filters.search) {
      whereClause.title = {
        [Op.like]: `%${filters.search}%`,
      };
    }

    // Filter by status (exact match)
    if (filters.status) {
      whereClause.status = filters.status;
    }

    // Filter by category (exact match)
    if (filters.categoryId) {
      whereClause.categoryId = filters.categoryId;
    }

    // Filter by date range
    if (filters.startDate || filters.endDate) {
      whereClause.dueDate = {};
      if (filters.startDate) {
        whereClause.dueDate[Op.gte] = new Date(filters.startDate);
      }
      if (filters.endDate) {
        whereClause.dueDate[Op.lte] = new Date(filters.endDate);
      }
    }

    // Filter by recurring status
    if (filters.isRecurring !== undefined) {
      whereClause.isRecurring = filters.isRecurring;
    }

    return await Task.findAll({
      where: whereClause,
      include: [
        {
          model: Category,
          as: "category",
          attributes: ["id", "name", "isPredefined"],
        },
      ],
      order: [
        ["dueDate", "ASC"],
        ["createdAt", "DESC"],
      ],
    });
  }

  /**
   * Get task count by filters
   */
  async getTaskCountByFilters(userId, filters = {}) {
    const whereClause = { userId };

    if (filters.search) {
      whereClause.title = {
        [Op.like]: `%${filters.search}%`,
      };
    }

    if (filters.status) {
      whereClause.status = filters.status;
    }

    if (filters.categoryId) {
      whereClause.categoryId = filters.categoryId;
    }

    return await Task.count({ where: whereClause });
  }
}

export default new TaskDao();
