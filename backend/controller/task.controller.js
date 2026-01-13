import taskService from "../services/task.service.js";

class TaskController {
  async createTask(req, res) {
    try {
      const {
        userId,
        title,
        description,
        status,
        dueDate,
        categoryId,
        isRecurring,
        recurrenceType,
      } = req.body;

      // Validate required fields
      if (!userId || !title) {
        return res.status(400).json({
          error: "User ID and title are required",
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
        recurrenceType
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
      const { userId } = req.params;
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
      const { userId } = req.query;

      if (!userId) {
        return res.status(400).json({ error: "User ID is required" });
      }

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
        userId,
        title,
        description,
        status,
        dueDate,
        categoryId,
        isRecurring,
        recurrenceType,
      } = req.body;

      if (!userId) {
        return res.status(400).json({ error: "User ID is required" });
      }

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
      const { userId } = req.query;

      if (!userId) {
        return res.status(400).json({ error: "User ID is required" });
      }

      const result = await taskService.deleteTask(id, userId);

      res.status(200).json(result);
    } catch (error) {
      res.status(400).json({ error: error.message });
    }
  }

  async markTaskComplete(req, res) {
    try {
      const { id } = req.params;
      const { userId } = req.body;

      if (!userId) {
        return res.status(400).json({ error: "User ID is required" });
      }

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
      const { userId } = req.body;

      if (!userId) {
        return res.status(400).json({ error: "User ID is required" });
      }

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
      const { userId } = req.params;

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
      const { userId } = req.params;
      const { days } = req.query;

      const tasks = await taskService.getUpcomingTasks(
        userId,
        days ? parseInt(days) : 7
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
      const { userId } = req.body;

      if (!userId) {
        return res.status(400).json({ error: "User ID is required" });
      }

      const result = await taskService.stopRecurrence(id, userId);

      res.status(200).json(result);
    } catch (error) {
      res.status(400).json({ error: error.message });
    }
  }

  async getRecurringTasks(req, res) {
    try {
      const { userId } = req.params;

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
}

export default new TaskController();
