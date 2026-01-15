import Task from "../models/Task.js";

class DashboardDao {
  /**
   * Get upcoming tasks count for a user
   * Upcoming = status is Pending AND dueDate is in the future
   */
  async getUpcomingTasksCount(userId) {
    const now = new Date();
    return await Task.countDocuments({
      userId,
      status: "Pending",
      dueDate: { $gte: now },
    });
  }

  /**
   * Get completed tasks count for a user
   * Completed = status is Completed
   */
  async getCompletedTasksCount(userId) {
    return await Task.countDocuments({
      userId,
      status: "Completed",
    });
  }

  /**
   * Get overdue tasks count for a user
   * Overdue = status is Pending AND dueDate is in the past
   */
  async getOverdueTasksCount(userId) {
    const now = new Date();
    return await Task.countDocuments({
      userId,
      status: "Pending",
      dueDate: { $lt: now },
    });
  }

  /**
   * Get all task statistics for a user
   * Returns upcoming, completed, and overdue counts in one query
   */
  async getAllTaskStatistics(userId) {
    const now = new Date();

    // Get all counts in parallel for better performance
    const [upcomingCount, completedCount, overdueCount, totalCount] =
      await Promise.all([
        Task.countDocuments({
          userId,
          status: "Pending",
          dueDate: { $gte: now },
        }),
        Task.countDocuments({
          userId,
          status: "Completed",
        }),
        Task.countDocuments({
          userId,
          status: "Pending",
          dueDate: { $lt: now },
        }),
        Task.countDocuments({
          userId,
        }),
      ]);

    return {
      upcoming: upcomingCount,
      completed: completedCount,
      overdue: overdueCount,
      total: totalCount,
      pending: upcomingCount + overdueCount, // All pending tasks
    };
  }

  /**
   * Get upcoming tasks with details (not just count)
   */
  async getUpcomingTasks(userId, limit = 10) {
    const now = new Date();
    return await Task.find({
      userId,
      status: "Pending",
      dueDate: { $gte: now },
    })
      .sort({ dueDate: 1 })
      .limit(limit);
  }

  /**
   * Get overdue tasks with details (not just count)
   */
  async getOverdueTasks(userId, limit = 10) {
    const now = new Date();
    return await Task.find({
      userId,
      status: "Pending",
      dueDate: { $lt: now },
    })
      .sort({ dueDate: 1 })
      .limit(limit);
  }

  /**
   * Get tasks by status count breakdown
   */
  async getTasksByStatus(userId) {
    const [pendingCount, completedCount] = await Promise.all([
      Task.countDocuments({
        userId,
        status: "Pending",
      }),
      Task.countDocuments({
        userId,
        status: "Completed",
      }),
    ]);

    return {
      pending: pendingCount,
      completed: completedCount,
    };
  }
}

export default new DashboardDao();
