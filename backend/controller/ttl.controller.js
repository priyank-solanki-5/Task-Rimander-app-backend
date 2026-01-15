import ttlService from "../services/ttl.service.js";

/**
 * TTL (Time To Live) Controller
 * Handles TTL management endpoints for cleanup operations
 */
class TTLController {
  /**
   * GET /api/ttl/cleanup
   * Manually trigger TTL cleanup for all services
   * Admin only operation
   */
  async triggerCleanup(req, res) {
    try {
      const result = await ttlService.cleanExpiredRecords();

      return res.status(200).json({
        success: true,
        message: "TTL cleanup executed successfully",
        data: result,
        metadata: {
          timestamp: new Date().toISOString(),
          userId: req.user?.id,
        },
      });
    } catch (error) {
      console.error("❌ Error in TTL cleanup:", error);
      return res.status(500).json({
        success: false,
        error: "Failed to execute TTL cleanup",
        message: error.message,
        metadata: {
          timestamp: new Date().toISOString(),
          userId: req.user?.id,
        },
      });
    }
  }

  /**
   * GET /api/ttl/statistics
   * Get statistics about TTL-eligible records
   * Useful for previewing what will be deleted
   */
  async getStatistics(req, res) {
    try {
      const stats = await ttlService.getTTLStatistics();

      return res.status(200).json({
        success: true,
        message: "TTL statistics retrieved successfully",
        data: stats,
        metadata: {
          timestamp: new Date().toISOString(),
          userId: req.user?.id,
        },
      });
    } catch (error) {
      console.error("❌ Error getting TTL statistics:", error);
      return res.status(500).json({
        success: false,
        error: "Failed to retrieve TTL statistics",
        message: error.message,
        metadata: {
          timestamp: new Date().toISOString(),
          userId: req.user?.id,
        },
      });
    }
  }

  /**
   * GET /api/ttl/policies
   * Get all retention policies
   */
  async getRetentionPolicies(req, res) {
    try {
      const policies = ttlService.getAllRetentionPolicies();

      return res.status(200).json({
        success: true,
        message: "Retention policies retrieved successfully",
        data: policies,
        metadata: {
          timestamp: new Date().toISOString(),
          userId: req.user?.id,
        },
      });
    } catch (error) {
      console.error("❌ Error getting retention policies:", error);
      return res.status(500).json({
        success: false,
        error: "Failed to retrieve retention policies",
        message: error.message,
        metadata: {
          timestamp: new Date().toISOString(),
          userId: req.user?.id,
        },
      });
    }
  }

  /**
   * GET /api/ttl/policies/:resourceType
   * Get retention policy for a specific resource type
   */
  async getResourcePolicy(req, res) {
    try {
      const { resourceType } = req.params;
      const policy = ttlService.getRetentionPolicy(resourceType);

      if (!policy) {
        return res.status(404).json({
          success: false,
          error: "Resource type not found",
          message: `No retention policy found for resource type: ${resourceType}`,
          metadata: {
            timestamp: new Date().toISOString(),
            userId: req.user?.id,
          },
        });
      }

      return res.status(200).json({
        success: true,
        message: `Retention policy for ${resourceType} retrieved successfully`,
        data: { resourceType, policy },
        metadata: {
          timestamp: new Date().toISOString(),
          userId: req.user?.id,
        },
      });
    } catch (error) {
      console.error("❌ Error getting resource policy:", error);
      return res.status(500).json({
        success: false,
        error: "Failed to retrieve resource policy",
        message: error.message,
        metadata: {
          timestamp: new Date().toISOString(),
          userId: req.user?.id,
        },
      });
    }
  }

  /**
   * PUT /api/ttl/policies/:resourceType
   * Update retention policy for a specific resource type
   * Admin only operation
   */
  async updateResourcePolicy(req, res) {
    try {
      const { resourceType } = req.params;
      const policyUpdates = req.body;

      const updatedPolicy = ttlService.updateRetentionPolicy(
        resourceType,
        policyUpdates
      );

      return res.status(200).json({
        success: true,
        message: `Retention policy for ${resourceType} updated successfully`,
        data: { resourceType, policy: updatedPolicy },
        metadata: {
          timestamp: new Date().toISOString(),
          userId: req.user?.id,
        },
      });
    } catch (error) {
      console.error("❌ Error updating resource policy:", error);

      // Handle invalid resource type
      if (error.message.includes("Unknown resource type")) {
        return res.status(404).json({
          success: false,
          error: "Resource type not found",
          message: error.message,
          metadata: {
            timestamp: new Date().toISOString(),
            userId: req.user?.id,
          },
        });
      }

      return res.status(500).json({
        success: false,
        error: "Failed to update resource policy",
        message: error.message,
        metadata: {
          timestamp: new Date().toISOString(),
          userId: req.user?.id,
        },
      });
    }
  }

  /**
   * POST /api/ttl/cleanup/:resourceType
   * Manually trigger cleanup for a specific resource type
   * Admin only operation
   */
  async cleanupResourceType(req, res) {
    try {
      const { resourceType } = req.params;
      let result;

      switch (resourceType.toLowerCase()) {
        case "notification":
          result = await ttlService.cleanExpiredNotifications();
          break;
        case "reminder":
          result = await ttlService.cleanExpiredReminders();
          break;
        case "document":
          result = await ttlService.cleanExpiredDocuments();
          break;
        case "task":
          result = await ttlService.cleanExpiredTasks();
          break;
        default:
          return res.status(404).json({
            success: false,
            error: "Unknown resource type",
            message: `No cleanup handler found for resource type: ${resourceType}`,
            metadata: {
              timestamp: new Date().toISOString(),
              userId: req.user?.id,
            },
          });
      }

      return res.status(200).json({
        success: true,
        message: `${resourceType} cleanup executed successfully`,
        data: result,
        metadata: {
          timestamp: new Date().toISOString(),
          userId: req.user?.id,
        },
      });
    } catch (error) {
      console.error("❌ Error in resource cleanup:", error);
      return res.status(500).json({
        success: false,
        error: "Failed to execute resource cleanup",
        message: error.message,
        metadata: {
          timestamp: new Date().toISOString(),
          userId: req.user?.id,
        },
      });
    }
  }
}

export default new TTLController();
