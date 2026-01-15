import express from "express";
import ttlController from "../controller/ttl.controller.js";
import authMiddleware from "../utils/authMiddleware.js";
import { apiLimiter } from "../utils/rateLimitMiddleware.js";

const router = express.Router();

/**
 * TTL (Time To Live) Management Routes
 * All endpoints require authentication and admin privileges
 */

// Apply auth middleware and rate limiting to all TTL routes
router.use(authMiddleware, apiLimiter);

/**
 * GET /api/ttl/cleanup
 * Manually trigger comprehensive TTL cleanup
 * Deletes all expired records across all services
 */
router.get("/cleanup", ttlController.triggerCleanup);

/**
 * GET /api/ttl/statistics
 * Get statistics about TTL-eligible records
 * Shows how many records would be deleted by policies
 */
router.get("/statistics", ttlController.getStatistics);

/**
 * GET /api/ttl/policies
 * Get all retention policies for all resource types
 */
router.get("/policies", ttlController.getRetentionPolicies);

/**
 * GET /api/ttl/policies/:resourceType
 * Get retention policy for specific resource type
 * Params: resourceType (notification|reminder|document|task)
 */
router.get("/policies/:resourceType", ttlController.getResourcePolicy);

/**
 * PUT /api/ttl/policies/:resourceType
 * Update retention policy for specific resource type
 * Params: resourceType (notification|reminder|document|task)
 * Body: { read: 90, unread: 180, all: 365 } (example for notification)
 */
router.put("/policies/:resourceType", ttlController.updateResourcePolicy);

/**
 * POST /api/ttl/cleanup/:resourceType
 * Manually trigger cleanup for specific resource type
 * Params: resourceType (notification|reminder|document|task)
 */
router.post("/cleanup/:resourceType", ttlController.cleanupResourceType);

export default router;
