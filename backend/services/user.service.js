import userDao from "../dao/userDao.js";
import authService from "./auth.service.js";

class UserService {
  async registerUser(
    username,
    mobilenumber,
    email,
    password,
    adminKey,
    isAdmin = false,
  ) {
    // Verify admin key only if registering as admin
    if (isAdmin) {
      const validAdminKey = process.env.ADMIN_API_KEY;
      if (!adminKey || adminKey !== validAdminKey) {
        throw new Error("Invalid admin key. Please contact the administrator.");
      }
    }

    // Check if user already exists
    const existingUser = await userDao.findUserByEmail(email);
    if (existingUser) {
      throw new Error("User with this email already exists");
    }

    // Create new user
    const user = await userDao.createUser({
      username,
      mobilenumber,
      email,
      password,
      isAdmin: isAdmin || false,
    });

    return user;
  }

  async loginUser(email, password) {
    const user = await userDao.findUserByEmailAndPassword(email, password);
    if (!user) {
      throw new Error("Invalid credentials");
    }

    // Update last login timestamp
    await userDao.updateLastLogin(user.id);

    // Generate JWT token
    const token = authService.generateToken(user);

    return {
      user: {
        id: user.id,
        username: user.username,
        email: user.email,
        mobilenumber: user.mobilenumber,
        isAdmin: user.isAdmin || false,
        notificationPreferences: user.notificationPreferences,
        settings: user.settings,
      },
      token,
    };
  }

  async changePassword(email, mobilenumber, newPassword) {
    const user = await userDao.findUserByEmailAndMobile(email, mobilenumber);
    if (!user) {
      throw new Error("User not found or email/mobile number does not match");
    }

    user.password = newPassword;
    await userDao.updateUser(user);

    return { message: "Password changed successfully" };
  }

  /**
   * Refresh user token for persistent login
   * Generates a new token with fresh 30-day expiry
   */
  async refreshUserToken(userId) {
    const user = await userDao.findUserById(userId);
    if (!user) {
      throw new Error("User not found");
    }

    // Generate new token with fresh 30-day expiry
    const newToken = authService.refreshToken(user);

    return newToken;
  }

  /**
   * Get user profile
   */
  async getUserProfile(userId) {
    const user = await userDao.findUserById(userId);
    if (!user) {
      throw new Error("User not found");
    }

    return {
      success: true,
      user: {
        id: user.id,
        username: user.username,
        email: user.email,
        mobilenumber: user.mobilenumber,
        isAdmin: user.isAdmin || false,
        notificationPreferences: user.notificationPreferences,
        settings: user.settings,
        metadata: user.metadata,
        lastLogin: user.lastLogin,
        isActive: user.isActive,
        createdAt: user.createdAt,
        updatedAt: user.updatedAt,
      },
    };
  }

  /**
   * Update notification preferences
   */
  async updateNotificationPreferences(userId, preferences) {
    // Validate preferences
    const validKeys = [
      "email",
      "push",
      "sms",
      "inApp",
      "remindersBefore",
      "overdueNotifications",
      "completionNotifications",
      "recurringNotifications",
    ];

    const invalidKeys = Object.keys(preferences).filter(
      (key) => !validKeys.includes(key),
    );

    if (invalidKeys.length > 0) {
      throw new Error(`Invalid preference keys: ${invalidKeys.join(", ")}`);
    }

    const user = await userDao.updateNotificationPreferences(
      userId,
      preferences,
    );

    return {
      success: true,
      message: "Notification preferences updated successfully",
      notificationPreferences: user.notificationPreferences,
      metadata: {
        timestamp: new Date(),
        userId,
      },
    };
  }

  /**
   * Get notification preferences
   */
  async getNotificationPreferences(userId) {
    const preferences = await userDao.getNotificationPreferences(userId);

    return {
      success: true,
      notificationPreferences: preferences,
      metadata: {
        timestamp: new Date(),
        userId,
      },
    };
  }

  /**
   * Update user settings
   */
  async updateSettings(userId, settings) {
    // Validate settings
    const validKeys = [
      "theme",
      "language",
      "timezone",
      "dateFormat",
      "timeFormat",
      "weekStartsOn",
    ];

    const invalidKeys = Object.keys(settings).filter(
      (key) => !validKeys.includes(key),
    );

    if (invalidKeys.length > 0) {
      throw new Error(`Invalid setting keys: ${invalidKeys.join(", ")}`);
    }

    const user = await userDao.updateSettings(userId, settings);

    return {
      success: true,
      message: "Settings updated successfully",
      settings: user.settings,
      metadata: {
        timestamp: new Date(),
        userId,
      },
    };
  }

  /**
   * Get user settings
   */
  async getSettings(userId) {
    const settings = await userDao.getSettings(userId);

    return {
      success: true,
      settings: settings,
      metadata: {
        timestamp: new Date(),
        userId,
      },
    };
  }

  /**
   * Update user metadata
   */
  async updateMetadata(userId, metadata) {
    const user = await userDao.updateMetadata(userId, metadata);

    return {
      success: true,
      message: "Metadata updated successfully",
      metadata: user.metadata,
      timestamp: new Date(),
    };
  }
}

export default new UserService();
