import User from "../models/User.js";

class UserDao {
  async createUser(userData) {
    return await User.create(userData);
  }

  async findUserByEmail(email) {
    return await User.findOne({ where: { email } });
  }

  async findUserByEmailAndPassword(email, password) {
    return await User.findOne({ where: { email, password } });
  }

  async findUserByEmailAndMobile(email, mobilenumber) {
    return await User.findOne({ where: { email, mobilenumber } });
  }

  async updateUser(user) {
    return await user.save();
  }

  /**
   * Update user notification preferences
   */
  async updateNotificationPreferences(userId, preferences) {
    const user = await User.findByPk(userId);
    if (!user) {
      throw new Error("User not found");
    }

    // Merge with existing preferences
    const currentPreferences = user.notificationPreferences || {};
    user.notificationPreferences = {
      ...currentPreferences,
      ...preferences,
    };

    return await user.save();
  }

  /**
   * Update user settings
   */
  async updateSettings(userId, settings) {
    const user = await User.findByPk(userId);
    if (!user) {
      throw new Error("User not found");
    }

    // Merge with existing settings
    const currentSettings = user.settings || {};
    user.settings = {
      ...currentSettings,
      ...settings,
    };

    return await user.save();
  }

  /**
   * Update user metadata
   */
  async updateMetadata(userId, metadata) {
    const user = await User.findByPk(userId);
    if (!user) {
      throw new Error("User not found");
    }

    // Merge with existing metadata
    const currentMetadata = user.metadata || {};
    user.metadata = {
      ...currentMetadata,
      ...metadata,
    };

    return await user.save();
  }

  /**
   * Get user by ID
   */
  async findUserById(userId) {
    return await User.findByPk(userId, {
      attributes: { exclude: ["password"] },
    });
  }

  /**
   * Update last login timestamp
   */
  async updateLastLogin(userId) {
    const user = await User.findByPk(userId);
    if (!user) {
      throw new Error("User not found");
    }

    user.lastLogin = new Date();
    return await user.save();
  }

  /**
   * Get user notification preferences
   */
  async getNotificationPreferences(userId) {
    const user = await User.findByPk(userId);
    if (!user) {
      throw new Error("User not found");
    }
    return user.notificationPreferences || {};
  }

  /**
   * Get user settings
   */
  async getSettings(userId) {
    const user = await User.findByPk(userId);
    if (!user) {
      throw new Error("User not found");
    }
    return user.settings || {};
  }
}

export default new UserDao();
