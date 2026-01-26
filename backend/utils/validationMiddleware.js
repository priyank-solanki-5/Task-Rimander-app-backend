import { body, param, query, validationResult } from "express-validator";

/**
 * Validation middleware to check for validation errors
 */
export const validate = (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({
      success: false,
      error: "Validation failed",
      details: errors.array(),
    });
  }
  next();
};

/**
 * User Registration Validation
 */
export const validateUserRegistration = [
  body("username")
    .trim()
    .notEmpty()
    .withMessage("Username is required")
    .isLength({ min: 3, max: 50 })
    .withMessage("Username must be between 3 and 50 characters"),
  body("email")
    .trim()
    .notEmpty()
    .withMessage("Email is required")
    .isEmail()
    .withMessage("Invalid email format")
    .normalizeEmail(),
  body("mobilenumber")
    .trim()
    .notEmpty()
    .withMessage("Mobile number is required")
    .matches(/^[0-9]{10}$/)
    .withMessage("Mobile number must be 10 digits"),
  body("password")
    .notEmpty()
    .withMessage("Password is required")
    .isLength({ min: 6 })
    .withMessage("Password must be at least 6 characters"),
  validate,
];

/**
 * User Login Validation
 */
export const validateUserLogin = [
  body("email")
    .trim()
    .notEmpty()
    .withMessage("Email is required")
    .isEmail()
    .withMessage("Invalid email format")
    .normalizeEmail(),
  body("password").notEmpty().withMessage("Password is required"),
  validate,
];

/**
 * Change Password Validation
 */
export const validateChangePassword = [
  body("email")
    .trim()
    .notEmpty()
    .withMessage("Email is required")
    .isEmail()
    .withMessage("Invalid email format"),
  body("mobilenumber")
    .trim()
    .notEmpty()
    .withMessage("Mobile number is required")
    .matches(/^[0-9]{10}$/)
    .withMessage("Mobile number must be 10 digits"),
  body("newPassword")
    .notEmpty()
    .withMessage("New password is required")
    .isLength({ min: 6 })
    .withMessage("Password must be at least 6 characters"),
  validate,
];

/**
 * Task Creation Validation
 */
export const validateTaskCreation = [
  body("title")
    .trim()
    .notEmpty()
    .withMessage("Task title is required")
    .isLength({ min: 1, max: 255 })
    .withMessage("Title must be between 1 and 255 characters"),
  body("description")
    .optional()
    .trim()
    .isLength({ max: 5000 })
    .withMessage("Description must not exceed 5000 characters"),
  body("status")
    .optional()
    .isIn(["Pending", "Completed"])
    .withMessage("Status must be either 'Pending' or 'Completed'"),
  body("dueDate").optional().isISO8601().withMessage("Invalid date format"),
  body("categoryId")
    .optional()
    .isInt()
    .withMessage("Category ID must be an integer"),
  body("isRecurring")
    .optional()
    .isBoolean()
    .withMessage("isRecurring must be boolean"),
  body("recurrenceType")
    .optional()
    .isIn(["Monthly", "Every 3 months", "Every 6 months", "Yearly"])
    .withMessage("Invalid recurrence type"),
  validate,
];

/**
 * Task Update Validation
 */
export const validateTaskUpdate = [
  param("id")
    .custom((value) => {
      const isMongoId = /^[0-9a-fA-F]{24}$/.test(value);
      const isInt = Number.isInteger(Number(value)) && Number(value) > 0;
      if (!isMongoId && !isInt) {
        throw new Error("ID must be a valid MongoDB ID or a positive integer");
      }
      return true;
    }),
  body("title")
    .optional()
    .trim()
    .isLength({ min: 1, max: 255 })
    .withMessage("Title must be between 1 and 255 characters"),
  body("description")
    .optional()
    .trim()
    .isLength({ max: 5000 })
    .withMessage("Description must not exceed 5000 characters"),
  body("status")
    .optional()
    .isIn(["Pending", "Completed"])
    .withMessage("Status must be either 'Pending' or 'Completed'"),
  body("dueDate").optional().isISO8601().withMessage("Invalid date format"),
  validate,
];

/**
 * ID Parameter Validation
 */
export const validateIdParam = [
  param("id")
    .custom((value) => {
      // Allow integer IDs (if any legacy) OR MongoDB ObjectIds (24 hex chars)
      const isMongoId = /^[0-9a-fA-F]{24}$/.test(value);
      const isInt = Number.isInteger(Number(value)) && Number(value) > 0;
      if (!isMongoId && !isInt) {
        throw new Error("ID must be a valid MongoDB ID or a positive integer");
      }
      return true;
    }),
  validate,
];

/**
 * Category Creation Validation
 */
export const validateCategoryCreation = [
  body("name")
    .trim()
    .notEmpty()
    .withMessage("Category name is required")
    .isLength({ min: 1, max: 100 })
    .withMessage("Category name must be between 1 and 100 characters"),
  validate,
];

/**
 * Search Query Validation
 */
export const validateSearchQuery = [
  query("q")
    .trim()
    .notEmpty()
    .withMessage("Search query 'q' is required")
    .isLength({ min: 1, max: 255 })
    .withMessage("Search query must be between 1 and 255 characters"),
  validate,
];

/**
 * Filter Query Validation
 */
export const validateFilterQuery = [
  query("status")
    .optional()
    .isIn(["Pending", "Completed"])
    .withMessage("Status must be either 'Pending' or 'Completed'"),
  query("categoryId")
    .optional()
    .isInt()
    .withMessage("Category ID must be an integer"),
  query("startDate")
    .optional()
    .isISO8601()
    .withMessage("Invalid start date format"),
  query("endDate")
    .optional()
    .isISO8601()
    .withMessage("Invalid end date format"),
  query("isRecurring")
    .optional()
    .isBoolean()
    .withMessage("isRecurring must be boolean"),
  validate,
];

/**
 * Reminder Creation Validation
 */
export const validateReminderCreation = [
  body("taskId")
    .notEmpty()
    .isInt()
    .withMessage("Task ID is required and must be an integer"),
  body("daysBeforeDue")
    .optional()
    .isInt({ min: 0, max: 365 })
    .withMessage("Days before due must be between 0 and 365"),
  body("type")
    .optional()
    .isIn(["email", "sms", "push", "in-app"])
    .withMessage("Type must be one of: email, sms, push, in-app"),
  validate,
];

/**
 * Notification Preferences Validation
 */
export const validateNotificationPreferences = [
  body("email").optional().isBoolean().withMessage("email must be boolean"),
  body("push").optional().isBoolean().withMessage("push must be boolean"),
  body("sms").optional().isBoolean().withMessage("sms must be boolean"),
  body("inApp").optional().isBoolean().withMessage("inApp must be boolean"),
  body("remindersBefore")
    .optional()
    .isInt({ min: 0, max: 30 })
    .withMessage("remindersBefore must be between 0 and 30 days"),
  body("overdueNotifications")
    .optional()
    .isBoolean()
    .withMessage("overdueNotifications must be boolean"),
  body("completionNotifications")
    .optional()
    .isBoolean()
    .withMessage("completionNotifications must be boolean"),
  body("recurringNotifications")
    .optional()
    .isBoolean()
    .withMessage("recurringNotifications must be boolean"),
  validate,
];

/**
 * User Settings Validation
 */
export const validateUserSettings = [
  body("theme")
    .optional()
    .isIn(["light", "dark", "system"])
    .withMessage("Theme must be 'light', 'dark', or 'system'"),
  body("language")
    .optional()
    .isLength({ min: 2, max: 5 })
    .withMessage("Language code must be 2-5 characters"),
  body("timezone")
    .optional()
    .isString()
    .withMessage("Timezone must be a string"),
  body("dateFormat")
    .optional()
    .isString()
    .withMessage("Date format must be a string"),
  body("timeFormat")
    .optional()
    .isIn(["12h", "24h"])
    .withMessage("Time format must be '12h' or '24h'"),
  body("weekStartsOn")
    .optional()
    .isIn(["monday", "sunday"])
    .withMessage("Week starts on must be 'monday' or 'sunday'"),
  validate,
];

export default {
  validate,
  validateUserRegistration,
  validateUserLogin,
  validateChangePassword,
  validateTaskCreation,
  validateTaskUpdate,
  validateIdParam,
  validateCategoryCreation,
  validateSearchQuery,
  validateFilterQuery,
  validateReminderCreation,
  validateNotificationPreferences,
  validateUserSettings,
};
