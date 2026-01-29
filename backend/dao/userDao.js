import User from "../models/User.js";
import bcrypt from "bcryptjs";

class UserDao {
  async createUser(userData) {
    // Hash password before saving
    if (userData.password) {
      const salt = await bcrypt.genSalt(10);
      userData.password = await bcrypt.hash(userData.password, salt);
    }
    const user = new User(userData);
    return await user.save();
  }

  async findUserByEmail(email) {
    return await User.findOne({ email });
  }

  async findUserByEmailAndPassword(email, password) {
    // Find user by email first
    const user = await User.findOne({ email });
    if (!user) {
      return null;
    }

    // If password is already hashed, compare using bcrypt
    const isHashed =
      typeof user.password === "string" &&
      (user.password.startsWith("$2a$") || user.password.startsWith("$2b$"));

    if (isHashed) {
      const isPasswordValid = await bcrypt.compare(password, user.password);
      if (!isPasswordValid) {
        return null;
      }
    } else {
      // Legacy/plaintext password path: compare directly, then upgrade to bcrypt hash
      if (user.password !== password) {
        return null;
      }

      const salt = await bcrypt.genSalt(10);
      user.password = await bcrypt.hash(password, salt);
      await user.save();
    }

    return user;
  }

  async findUserByEmailAndMobile(email, mobilenumber) {
    return await User.findOne({ email, mobilenumber });
  }

  async updateUser(user) {
    // Hash password if it's being updated
    if (user.isModified("password")) {
      const salt = await bcrypt.genSalt(10);
      user.password = await bcrypt.hash(user.password, salt);
    }
    return await user.save();
  }

  /**
   * Update user notification preferences
   */
  async updateNotificationPreferences(userId, preferences) {
    const user = await User.findById(userId);
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
    const user = await User.findById(userId);
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
    const user = await User.findById(userId);
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
    return await User.findById(userId).select("-password");
  }

  /**
   * Update last login timestamp
   */
  async updateLastLogin(userId) {
    const user = await User.findById(userId);
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
    const user = await User.findById(userId);
    if (!user) {
      throw new Error("User not found");
    }
    return user.notificationPreferences || {};
  }

  /**
   * Get user settings
   */
  async getSettings(userId) {
    const user = await User.findById(userId);
    if (!user) {
      throw new Error("User not found");
    }
    return user.settings || {};
  }
}

export default new UserDao();
