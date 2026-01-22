import express from "express";
import userController from "../controller/user.controller.js";
import authMiddleware from "../utils/authMiddleware.js";
import { authLimiter, apiLimiter } from "../utils/rateLimitMiddleware.js";
import {
  validateUserRegistration,
  validateUserLogin,
  validateChangePassword,
  validateNotificationPreferences,
  validateUserSettings,
} from "../utils/validationMiddleware.js";

const router = express.Router();

// ===== PUBLIC ROUTES (No Authentication) =====

// Register user - Validation and rate limiting disabled for testing
router.post("/register", (req, res) => userController.register(req, res));

// Login user - Validation and rate limiting disabled for testing
router.post("/login", (req, res) => userController.login(req, res));

// Change password (public - requires email + mobile verification)
router.put(
  "/change-password",
  authLimiter,
  validateChangePassword,
  (req, res) => userController.changePassword(req, res),
);

// ===== PROTECTED ROUTES (Require Authentication) =====

// Get user profile
router.get("/profile", authMiddleware, apiLimiter, (req, res) =>
  userController.getProfile(req, res),
);

// ===== NOTIFICATION PREFERENCES =====

// Get notification preferences
router.get(
  "/notification-preferences",
  authMiddleware,
  apiLimiter,
  (req, res) => userController.getNotificationPreferences(req, res),
);

// Update notification preferences
router.put(
  "/notification-preferences",
  authMiddleware,
  apiLimiter,
  validateNotificationPreferences,
  (req, res) => userController.updateNotificationPreferences(req, res),
);

// ===== USER SETTINGS =====

// Get user settings
router.get("/settings", authMiddleware, apiLimiter, (req, res) =>
  userController.getSettings(req, res),
);

// Update user settings
router.put(
  "/settings",
  authMiddleware,
  apiLimiter,
  validateUserSettings,
  (req, res) => userController.updateSettings(req, res),
);

// ===== METADATA =====

// Update user metadata
router.put("/metadata", authMiddleware, apiLimiter, (req, res) =>
  userController.updateMetadata(req, res),
);

export default router;
