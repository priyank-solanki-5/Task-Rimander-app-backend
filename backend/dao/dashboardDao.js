import Task from "../models/Task.js";
import { Op } from "sequelize";

class DashboardDao {
  /**
   * Get upcoming tasks count for a user
   * Upcoming = status is Pending AND dueDate is in the future
   */
  async getUpcomingTasksCount(userId) {
    try {
      const now = new Date();
      const count = await Task.count({
        where: {
          userId,
          status: "Pending",
          dueDate: {
            [Op.gte]: now, // Greater than or equal to current date
          },
        },
      });
      return count;
    } catch (error) {
      throw error;
    }
  }

  /**
   * Get completed tasks count for a user
   * Completed = status is Completed
   */
  async getCompletedTasksCount(userId) {
    try {
      const count = await Task.count({
        where: {
          userId,
          status: "Completed",
        },
      });
      return count;
    } catch (error) {
      throw error;
    }
  }

  /**
   * Get overdue tasks count for a user
   * Overdue = status is Pending AND dueDate is in the past
   */
  async getOverdueTasksCount(userId) {
    try {
      const now = new Date();
      const count = await Task.count({
        where: {
          userId,
          status: "Pending",
          dueDate: {
            [Op.lt]: now, // Less than current date
          },
        },
      });
      return count;
    } catch (error) {
      throw error;
    }
  }

  /**
   * Get all task statistics for a user
   * Returns upcoming, completed, and overdue counts in one query
   */
  async getAllTaskStatistics(userId) {
    try {
      const now = new Date();

      // Get all counts in parallel for better performance
      const [upcomingCount, completedCount, overdueCount, totalCount] =
        await Promise.all([
          Task.count({
            where: {
              userId,
              status: "Pending",
              dueDate: {
                [Op.gte]: now,
              },
            },
          }),
          Task.count({
            where: {
              userId,
              status: "Completed",
            },
          }),
          Task.count({
            where: {
              userId,
              status: "Pending",
              dueDate: {
                [Op.lt]: now,
              },
            },
          }),
          Task.count({
            where: {
              userId,
            },
          }),
        ]);

      return {
        upcoming: upcomingCount,
        completed: completedCount,
        overdue: overdueCount,
        total: totalCount,
        pending: upcomingCount + overdueCount, // All pending tasks
      };
    } catch (error) {
      throw error;
    }
  }

  /**
   * Get upcoming tasks with details (not just count)
   */
  async getUpcomingTasks(userId, limit = 10) {
    try {
      const now = new Date();
      const tasks = await Task.findAll({
        where: {
          userId,
          status: "Pending",
          dueDate: {
            [Op.gte]: now,
          },
        },
        order: [["dueDate", "ASC"]],
        limit,
      });
      return tasks;
    } catch (error) {
      throw error;
    }
  }

  /**
   * Get overdue tasks with details (not just count)
   */
  async getOverdueTasks(userId, limit = 10) {
    try {
      const now = new Date();
      const tasks = await Task.findAll({
        where: {
          userId,
          status: "Pending",
          dueDate: {
            [Op.lt]: now,
          },
        },
        order: [["dueDate", "ASC"]],
        limit,
      });
      return tasks;
    } catch (error) {
      throw error;
    }
  }

  /**
   * Get tasks by status count breakdown
   */
  async getTasksByStatus(userId) {
    try {
      const [pendingCount, completedCount] = await Promise.all([
        Task.count({
          where: {
            userId,
            status: "Pending",
          },
        }),
        Task.count({
          where: {
            userId,
            status: "Completed",
          },
        }),
      ]);

      return {
        pending: pendingCount,
        completed: completedCount,
      };
    } catch (error) {
      throw error;
    }
  }
}

export default new DashboardDao();
