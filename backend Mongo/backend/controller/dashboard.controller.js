import dashboardService from "../services/dashboard.service.js";

class DashboardController {
  /**
   * Get all dashboard statistics
   * GET /api/dashboard/statistics
   */
  async getDashboardStatistics(req, res) {
    try {
      const userId = req.user.id;

      const result = await dashboardService.getDashboardStatistics(userId);

      return res.status(200).json(result);
    } catch (error) {
      console.error("Error fetching dashboard statistics:", error.message);
      return res.status(500).json({
        success: false,
        error: error.message,
      });
    }
  }

  /**
   * Get upcoming tasks count
   * GET /api/dashboard/upcoming/count
   */
  async getUpcomingCount(req, res) {
    try {
      const userId = req.user.id;

      const result = await dashboardService.getUpcomingCount(userId);

      return res.status(200).json(result);
    } catch (error) {
      console.error("Error fetching upcoming count:", error.message);
      return res.status(500).json({
        success: false,
        error: error.message,
      });
    }
  }

  /**
   * Get completed tasks count
   * GET /api/dashboard/completed/count
   */
  async getCompletedCount(req, res) {
    try {
      const userId = req.user.id;

      const result = await dashboardService.getCompletedCount(userId);

      return res.status(200).json(result);
    } catch (error) {
      console.error("Error fetching completed count:", error.message);
      return res.status(500).json({
        success: false,
        error: error.message,
      });
    }
  }

  /**
   * Get overdue tasks count
   * GET /api/dashboard/overdue/count
   */
  async getOverdueCount(req, res) {
    try {
      const userId = req.user.id;

      const result = await dashboardService.getOverdueCount(userId);

      return res.status(200).json(result);
    } catch (error) {
      console.error("Error fetching overdue count:", error.message);
      return res.status(500).json({
        success: false,
        error: error.message,
      });
    }
  }

  /**
   * Get upcoming tasks with details
   * GET /api/dashboard/upcoming?limit=10
   */
  async getUpcomingTasks(req, res) {
    try {
      const userId = req.user.id;
      const limit = parseInt(req.query.limit) || 10;

      const result = await dashboardService.getUpcomingTasks(userId, limit);

      return res.status(200).json(result);
    } catch (error) {
      console.error("Error fetching upcoming tasks:", error.message);
      return res.status(500).json({
        success: false,
        error: error.message,
      });
    }
  }

  /**
   * Get overdue tasks with details
   * GET /api/dashboard/overdue?limit=10
   */
  async getOverdueTasks(req, res) {
    try {
      const userId = req.user.id;
      const limit = parseInt(req.query.limit) || 10;

      const result = await dashboardService.getOverdueTasks(userId, limit);

      return res.status(200).json(result);
    } catch (error) {
      console.error("Error fetching overdue tasks:", error.message);
      return res.status(500).json({
        success: false,
        error: error.message,
      });
    }
  }

  /**
   * Get task breakdown by status
   * GET /api/dashboard/status-breakdown
   */
  async getTasksByStatus(req, res) {
    try {
      const userId = req.user.id;

      const result = await dashboardService.getTasksByStatus(userId);

      return res.status(200).json(result);
    } catch (error) {
      console.error("Error fetching tasks by status:", error.message);
      return res.status(500).json({
        success: false,
        error: error.message,
      });
    }
  }

  /**
   * Get comprehensive dashboard data
   * GET /api/dashboard
   */
  async getComprehensiveDashboard(req, res) {
    try {
      const userId = req.user.id;
      const previewLimit = parseInt(req.query.preview) || 5;

      const result = await dashboardService.getComprehensiveDashboard(
        userId,
        previewLimit
      );

      return res.status(200).json(result);
    } catch (error) {
      console.error("Error fetching comprehensive dashboard:", error.message);
      return res.status(500).json({
        success: false,
        error: error.message,
      });
    }
  }
}

export default new DashboardController();
