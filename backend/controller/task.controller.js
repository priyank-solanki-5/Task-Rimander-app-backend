import taskService from "../services/task.service.js";

class TaskController {
  async createTask(req, res) {
    try {
      const {
        title,
        description,
        status,
        dueDate,
        categoryId,
        isRecurring,
        recurrenceType,
        memberId,
        remindMeBeforeDays,
      } = req.body;

      const userId = req.user.id; // Get from authenticated token

      // Validate required fields
      if (!title) {
        return res.status(400).json({
          error: "Title is required",
        });
      }

      // Validate status if provided
      if (status && !["Pending", "Completed"].includes(status)) {
        return res.status(400).json({
          error: "Status must be either 'Pending' or 'Completed'",
        });
      }

      // Validate recurrence
      if (isRecurring && !recurrenceType) {
        return res.status(400).json({
          error: "Recurrence type is required for recurring tasks",
        });
      }

      const task = await taskService.createTask(
        userId,
        title,
        description,
        status,
        dueDate,
        categoryId,
        isRecurring,
        recurrenceType,
        memberId,
        remindMeBeforeDays,
      );

      res.status(201).json({
        message: "Task created successfully",
        data: task,
      });
    } catch (error) {
      res.status(400).json({ error: error.message });
    }
  }

  async getAllTasks(req, res) {
    try {
      const userId = req.user.id; // Get from authenticated token
      const { status, categoryId } = req.query;

      const filters = {};
      if (status) filters.status = status;
      if (categoryId) filters.categoryId = categoryId;

      const tasks = await taskService.getAllTasksByUser(userId, filters);

      res.status(200).json({
        message: "Tasks fetched successfully",
        data: tasks,
      });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }

  async getTaskById(req, res) {
    try {
      const { id } = req.params;
      const userId = req.user.id; // Get from authenticated token

      const task = await taskService.getTaskById(id, userId);

      res.status(200).json({
        message: "Task fetched successfully",
        data: task,
      });
    } catch (error) {
      res.status(404).json({ error: error.message });
    }
  }

  async updateTask(req, res) {
    try {
      const { id } = req.params;
      const {
        title,
        description,
        status,
        dueDate,
        categoryId,
        isRecurring,
        recurrenceType,
<<<<<<< HEAD
=======

>>>>>>> a6d6125a85741bd9ff1a633af40c1edbe2bdef05
        memberId,
        remindMeBeforeDays,
      } = req.body;

      const userId = req.user.id; // Get from authenticated token

      // Validate status if provided
      if (status && !["Pending", "Completed"].includes(status)) {
        return res.status(400).json({
          error: "Status must be either 'Pending' or 'Completed'",
        });
      }

      const task = await taskService.updateTask(id, userId, {
        title,
        description,
        status,
        dueDate,
        categoryId,
        isRecurring,
        recurrenceType,
        memberId,
        remindMeBeforeDays,
      });

      res.status(200).json({
        message: "Task updated successfully",
        data: task,
      });
    } catch (error) {
      res.status(400).json({ error: error.message });
    }
  }

  async deleteTask(req, res) {
    try {
      const { id } = req.params;
      const userId = req.user.id; // Get from authenticated token

      const result = await taskService.deleteTask(id, userId);

      res.status(200).json(result);
    } catch (error) {
      res.status(400).json({ error: error.message });
    }
  }

  async markTaskComplete(req, res) {
    try {
      const { id } = req.params;
      const userId = req.user.id; // Get from authenticated token

      const task = await taskService.markTaskComplete(id, userId);

      res.status(200).json({
        message: "Task marked as completed",
        data: task,
      });
    } catch (error) {
      res.status(400).json({ error: error.message });
    }
  }

  async markTaskPending(req, res) {
    try {
      const { id } = req.params;
      const userId = req.user.id; // Get from authenticated token

      const task = await taskService.markTaskPending(id, userId);

      res.status(200).json({
        message: "Task marked as pending",
        data: task,
      });
    } catch (error) {
      res.status(400).json({ error: error.message });
    }
  }

  async getOverdueTasks(req, res) {
    try {
      const userId = req.user.id; // Get from authenticated token

      const tasks = await taskService.getOverdueTasks(userId);

      res.status(200).json({
        message: "Overdue tasks fetched successfully",
        data: tasks,
      });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }

  async getUpcomingTasks(req, res) {
    try {
      const userId = req.user.id; // Get from authenticated token
      const { days } = req.query;

      const tasks = await taskService.getUpcomingTasks(
        userId,
        days ? parseInt(days) : 7,
      );

      res.status(200).json({
        message: "Upcoming tasks fetched successfully",
        data: tasks,
      });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }

  async stopRecurrence(req, res) {
    try {
      const { id } = req.params;
      const userId = req.user.id; // Get from authenticated token

      const result = await taskService.stopRecurrence(id, userId);

      res.status(200).json(result);
    } catch (error) {
      res.status(400).json({ error: error.message });
    }
  }

  async getRecurringTasks(req, res) {
    try {
      const userId = req.user.id; // Get from authenticated token

      const tasks = await taskService.getRecurringTasks(userId);

      res.status(200).json({
        message: "Recurring tasks fetched successfully",
        data: tasks,
      });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }

  async processRecurringTasks(req, res) {
    try {
      const result = await taskService.processRecurringTasks();

      res.status(200).json({
        message: "Recurring tasks processed successfully",
        data: result,
      });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }

  /**
   * Search tasks by name
   * GET /api/tasks/search?q=searchTerm
   */
  async searchTasks(req, res) {
    try {
      const userId = req.user.id;
      const { q } = req.query;

      if (!q) {
        return res.status(400).json({
          success: false,
          error: "Search query parameter 'q' is required",
        });
      }

      const result = await taskService.searchTasks(userId, q);

      res.status(200).json(result);
    } catch (error) {
      res.status(400).json({
        success: false,
        error: error.message,
      });
    }
  }

  /**
   * Filter tasks by category, status, date range
   * GET /api/tasks/filter?status=Pending&categoryId=1&startDate=2026-01-01&endDate=2026-12-31
   */
  async filterTasks(req, res) {
    try {
      const userId = req.user.id;
      const { status, categoryId, startDate, endDate, isRecurring } = req.query;

      const filters = {};

      if (status) {
        if (!["Pending", "Completed"].includes(status)) {
          return res.status(400).json({
            success: false,
            error: "Status must be either 'Pending' or 'Completed'",
          });
        }
        filters.status = status;
      }

      if (categoryId) {
        filters.categoryId = parseInt(categoryId);
      }

      if (startDate) {
        filters.startDate = startDate;
      }

      if (endDate) {
        filters.endDate = endDate;
      }

      if (isRecurring !== undefined) {
        filters.isRecurring = isRecurring === "true";
      }

      const result = await taskService.filterTasks(userId, filters);

      res.status(200).json(result);
    } catch (error) {
      res.status(500).json({
        success: false,
        error: error.message,
      });
    }
  }

  /**
   * Combined search and filter
   * GET /api/tasks/search-filter?q=searchTerm&status=Pending&categoryId=1
   */
  async searchAndFilter(req, res) {
    try {
      const userId = req.user.id;
      const { q, status, categoryId, startDate, endDate } = req.query;

      const filters = {};

      if (status) {
        filters.status = status;
      }

      if (categoryId) {
        filters.categoryId = parseInt(categoryId);
      }

      if (startDate) {
        filters.startDate = startDate;
      }

      if (endDate) {
        filters.endDate = endDate;
      }

      const result = await taskService.searchAndFilter(userId, q, filters);

      res.status(200).json(result);
    } catch (error) {
      res.status(500).json({
        success: false,
        error: error.message,
      });
    }
  }
}

export default new TaskController();
