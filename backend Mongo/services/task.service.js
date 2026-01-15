import taskDao from "../dao/taskDao.js";
import categoryDao from "../dao/categoryDao.js";
import userDao from "../dao/userDao.js";
import RecurrenceHelper from "../utils/recurrenceHelper.js";

class TaskService {
  async createTask(
    userId,
    title,
    description,
    status,
    dueDate,
    categoryId,
    isRecurring,
    recurrenceType
  ) {
    // Validate user exists
    const user = await userDao.findUserByEmail(userId);
    if (!user) {
      throw new Error("User not found");
    }

    // Validate category if provided
    if (categoryId) {
      const category = await categoryDao.findCategoryById(categoryId);
      if (!category) {
        throw new Error("Category not found");
      }
    }

    // Validate recurrence
    if (isRecurring && !recurrenceType) {
      throw new Error("Recurrence type is required for recurring tasks");
    }

    if (
      recurrenceType &&
      !RecurrenceHelper.isValidRecurrenceType(recurrenceType)
    ) {
      throw new Error("Invalid recurrence type");
    }

    // Calculate next occurrence for recurring tasks
    let nextOccurrence = null;
    if (isRecurring && dueDate) {
      nextOccurrence = RecurrenceHelper.calculateNextOccurrence(
        new Date(dueDate),
        recurrenceType
      );
    }

    // Create task
    const task = await taskDao.createTask({
      userId,
      title,
      description,
      status: status || "Pending",
      dueDate: dueDate ? new Date(dueDate) : null,
      categoryId: categoryId || null,
      isRecurring: isRecurring || false,
      recurrenceType: recurrenceType || null,
      nextOccurrence,
    });

    return task;
  }

  async getAllTasksByUser(userId, filters = {}) {
    return await taskDao.findAllTasksByUser(userId, filters);
  }

  async getTaskById(id, userId) {
    const task = await taskDao.findTaskById(id, userId);
    if (!task) {
      throw new Error("Task not found");
    }
    return task;
  }

  async updateTask(id, userId, updateData) {
    const task = await taskDao.findTaskById(id, userId);
    if (!task) {
      throw new Error("Task not found");
    }

    // Validate category if being updated
    if (updateData.categoryId) {
      const category = await categoryDao.findCategoryById(
        updateData.categoryId
      );
      if (!category) {
        throw new Error("Category not found");
      }
    }

    // Prepare update data
    const dataToUpdate = {};
    if (updateData.title !== undefined) dataToUpdate.title = updateData.title;
    if (updateData.description !== undefined)
      dataToUpdate.description = updateData.description;
    if (updateData.status !== undefined)
      dataToUpdate.status = updateData.status;
    if (updateData.dueDate !== undefined)
      dataToUpdate.dueDate = updateData.dueDate
        ? new Date(updateData.dueDate)
        : null;
    if (updateData.categoryId !== undefined)
      dataToUpdate.categoryId = updateData.categoryId || null;
    if (updateData.isRecurring !== undefined)
      dataToUpdate.isRecurring = updateData.isRecurring;
    if (updateData.recurrenceType !== undefined) {
      if (
        updateData.recurrenceType &&
        !RecurrenceHelper.isValidRecurrenceType(updateData.recurrenceType)
      ) {
        throw new Error("Invalid recurrence type");
      }
      dataToUpdate.recurrenceType = updateData.recurrenceType || null;
    }

    // Recalculate next occurrence if recurrence data changed
    if (
      (updateData.isRecurring !== undefined ||
        updateData.recurrenceType !== undefined ||
        updateData.dueDate !== undefined) &&
      (dataToUpdate.isRecurring || task.isRecurring)
    ) {
      const dueDate = dataToUpdate.dueDate || task.dueDate;
      const recurrenceType = dataToUpdate.recurrenceType || task.recurrenceType;
      if (dueDate && recurrenceType) {
        dataToUpdate.nextOccurrence = RecurrenceHelper.calculateNextOccurrence(
          dueDate,
          recurrenceType
        );
      }
    }

    await taskDao.updateTask(task, dataToUpdate);
    return task;
  }

  async deleteTask(id, userId) {
    const task = await taskDao.findTaskById(id, userId);
    if (!task) {
      throw new Error("Task not found");
    }

    await taskDao.deleteTask(id, userId);
    return { message: "Task deleted successfully" };
  }

  async markTaskComplete(id, userId) {
    const task = await taskDao.findTaskById(id, userId);
    if (!task) {
      throw new Error("Task not found");
    }

    // If task is recurring, generate next occurrence
    if (task.isRecurring && task.recurrenceType) {
      await this.generateNextRecurrence(task);
    }

    // Mark current task as completed
    return await this.updateTask(id, userId, { status: "Completed" });
  }

  async markTaskPending(id, userId) {
    return await this.updateTask(id, userId, { status: "Pending" });
  }

  async generateNextRecurrence(task) {
    // Calculate next due date
    const nextDueDate = RecurrenceHelper.calculateNextOccurrence(
      task.dueDate || new Date(),
      task.recurrenceType
    );

    if (!nextDueDate) {
      return null;
    }

    // Calculate next occurrence after that
    const nextOccurrence = RecurrenceHelper.calculateNextOccurrence(
      nextDueDate,
      task.recurrenceType
    );

    // Create new task for next cycle
    const newTask = await taskDao.createTask({
      userId: task.userId,
      title: task.title,
      description: task.description,
      status: "Pending",
      dueDate: nextDueDate,
      categoryId: task.categoryId,
      isRecurring: true,
      recurrenceType: task.recurrenceType,
      nextOccurrence,
    });

    return newTask;
  }

  async stopRecurrence(id, userId) {
    const task = await taskDao.findTaskById(id, userId);
    if (!task) {
      throw new Error("Task not found");
    }

    if (!task.isRecurring) {
      throw new Error("Task is not recurring");
    }

    await this.updateTask(id, userId, {
      isRecurring: false,
      recurrenceType: null,
      nextOccurrence: null,
    });

    return { message: "Recurrence stopped successfully" };
  }

  async getRecurringTasks(userId) {
    return await taskDao.findRecurringTasks(userId);
  }

  async processRecurringTasks() {
    const tasksDue = await taskDao.findTasksDueForRecurrence();
    const generatedTasks = [];

    for (const task of tasksDue) {
      const newTask = await this.generateNextRecurrence(task);
      if (newTask) {
        generatedTasks.push(newTask);
      }
    }

    return {
      processed: tasksDue.length,
      generated: generatedTasks.length,
      tasks: generatedTasks,
    };
  }

  async getOverdueTasks(userId) {
    return await taskDao.findOverdueTasks(userId);
  }

  async getUpcomingTasks(userId, days = 7) {
    return await taskDao.findUpcomingTasks(userId, days);
  }

  /**
   * Search tasks by name
   */
  async searchTasks(userId, searchTerm) {
    if (!searchTerm || searchTerm.trim() === "") {
      throw new Error("Search term is required");
    }

    const tasks = await taskDao.searchTasksByName(userId, searchTerm.trim());

    return {
      success: true,
      count: tasks.length,
      searchTerm,
      tasks,
      metadata: {
        timestamp: new Date(),
        userId,
      },
    };
  }

  /**
   * Filter tasks by category, status, date range, etc.
   */
  async filterTasks(userId, filters = {}) {
    const tasks = await taskDao.filterTasks(userId, filters);
    const totalCount = await taskDao.getTaskCountByFilters(userId, filters);

    return {
      success: true,
      count: tasks.length,
      totalCount,
      filters,
      tasks,
      metadata: {
        timestamp: new Date(),
        userId,
        appliedFilters: Object.keys(filters).filter((key) => filters[key]),
      },
    };
  }

  /**
   * Search and filter tasks combined
   */
  async searchAndFilter(userId, searchTerm, filters = {}) {
    const combinedFilters = { ...filters };

    if (searchTerm && searchTerm.trim() !== "") {
      combinedFilters.search = searchTerm.trim();
    }

    const tasks = await taskDao.filterTasks(userId, combinedFilters);

    return {
      success: true,
      count: tasks.length,
      searchTerm,
      filters,
      tasks,
      metadata: {
        timestamp: new Date(),
        userId,
      },
    };
  }
}

export default new TaskService();
