import dashboardDao from "../dao/dashboardDao.js";

class DashboardService {
  /**
   * Get all dashboard statistics for a user
   * Returns upcoming, completed, overdue, total, and pending counts
   */
  async getDashboardStatistics(userId) {
    try {
      const statistics = await dashboardDao.getAllTaskStatistics(userId);

      return {
        success: true,
        statistics: {
          upcoming: statistics.upcoming,
          completed: statistics.completed,
          overdue: statistics.overdue,
          total: statistics.total,
          pending: statistics.pending,
        },
        metadata: {
          timestamp: new Date(),
          userId,
        },
      };
    } catch (error) {
      throw error;
    }
  }

  /**
   * Get upcoming tasks count
   */
  async getUpcomingCount(userId) {
    try {
      const count = await dashboardDao.getUpcomingTasksCount(userId);
      return {
        success: true,
        count,
        type: "upcoming",
        metadata: {
          timestamp: new Date(),
          userId,
        },
      };
    } catch (error) {
      throw error;
    }
  }

  /**
   * Get completed tasks count
   */
  async getCompletedCount(userId) {
    try {
      const count = await dashboardDao.getCompletedTasksCount(userId);
      return {
        success: true,
        count,
        type: "completed",
        metadata: {
          timestamp: new Date(),
          userId,
        },
      };
    } catch (error) {
      throw error;
    }
  }

  /**
   * Get overdue tasks count
   */
  async getOverdueCount(userId) {
    try {
      const count = await dashboardDao.getOverdueTasksCount(userId);
      return {
        success: true,
        count,
        type: "overdue",
        metadata: {
          timestamp: new Date(),
          userId,
        },
      };
    } catch (error) {
      throw error;
    }
  }

  /**
   * Get upcoming tasks with details
   */
  async getUpcomingTasks(userId, limit = 10) {
    try {
      const tasks = await dashboardDao.getUpcomingTasks(userId, limit);
      return {
        success: true,
        count: tasks.length,
        tasks,
        metadata: {
          timestamp: new Date(),
          userId,
          limit,
        },
      };
    } catch (error) {
      throw error;
    }
  }

  /**
   * Get overdue tasks with details
   */
  async getOverdueTasks(userId, limit = 10) {
    try {
      const tasks = await dashboardDao.getOverdueTasks(userId, limit);
      return {
        success: true,
        count: tasks.length,
        tasks,
        metadata: {
          timestamp: new Date(),
          userId,
          limit,
        },
      };
    } catch (error) {
      throw error;
    }
  }

  /**
   * Get task breakdown by status
   */
  async getTasksByStatus(userId) {
    try {
      const breakdown = await dashboardDao.getTasksByStatus(userId);
      return {
        success: true,
        breakdown,
        metadata: {
          timestamp: new Date(),
          userId,
        },
      };
    } catch (error) {
      throw error;
    }
  }

  /**
   * Get comprehensive dashboard data
   * Includes statistics, upcoming tasks preview, and overdue tasks preview
   */
  async getComprehensiveDashboard(userId, previewLimit = 5) {
    try {
      const [statistics, upcomingTasks, overdueTasks] = await Promise.all([
        dashboardDao.getAllTaskStatistics(userId),
        dashboardDao.getUpcomingTasks(userId, previewLimit),
        dashboardDao.getOverdueTasks(userId, previewLimit),
      ]);

      return {
        success: true,
        statistics: {
          upcoming: statistics.upcoming,
          completed: statistics.completed,
          overdue: statistics.overdue,
          total: statistics.total,
          pending: statistics.pending,
        },
        preview: {
          upcomingTasks: {
            count: upcomingTasks.length,
            tasks: upcomingTasks,
          },
          overdueTasks: {
            count: overdueTasks.length,
            tasks: overdueTasks,
          },
        },
        metadata: {
          timestamp: new Date(),
          userId,
          previewLimit,
        },
      };
    } catch (error) {
      throw error;
    }
  }
}

export default new DashboardService();
