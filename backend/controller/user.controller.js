import userService from "../services/user.service.js";

class UserController {
  async register(req, res) {
    try {
      const { username, mobilenumber, email, password, adminKey, isAdmin } =
        req.body;

      // Validate input
      if (!username || !mobilenumber || !email || !password) {
        return res.status(400).json({
          error: "All fields are required",
        });
      }

      // Validate admin key only if registering as admin
      if (isAdmin && !adminKey) {
        return res.status(400).json({
          error: "Admin key is required for admin registration",
        });
      }

      const user = await userService.registerUser(
        username,
        mobilenumber,
        email,
        password,
        adminKey,
        isAdmin,
      );

      res.status(201).json({
        message: "User registered successfully",
        data: {
          id: user.id,
          username: user.username,
          email: user.email,
          mobilenumber: user.mobilenumber,
        },
      });
    } catch (error) {
      res.status(400).json({ error: error.message });
    }
  }

  async login(req, res) {
    try {
      const { email, password } = req.body;

      // Validate input
      if (!email || !password) {
        return res.status(400).json({
          error: "Email and password are required",
        });
      }

      const result = await userService.loginUser(email, password);

      res.status(200).json({
        message: "Login successful",
        data: result.user,
        token: result.token,
      });
    } catch (error) {
      res.status(401).json({ error: error.message });
    }
  }

  async changePassword(req, res) {
    try {
      const { email, mobilenumber, newPassword } = req.body;

      // Validate input
      if (!email || !mobilenumber || !newPassword) {
        return res.status(400).json({
          error: "Email, mobile number, and new password are required",
        });
      }

      const result = await userService.changePassword(
        email,
        mobilenumber,
        newPassword,
      );

      res.status(200).json(result);
    } catch (error) {
      res.status(404).json({ error: error.message });
    }
  }

  /**
   * Refresh JWT token for persistent login
   * POST /api/users/refresh-token
   * Requires: valid JWT token in Authorization header
   */
  async refreshToken(req, res) {
    try {
      const userId = req.user.id;

      const result = await userService.refreshUserToken(userId);

      res.status(200).json({
        message: "Token refreshed successfully",
        token: result,
      });
    } catch (error) {
      res.status(401).json({ error: error.message });
    }
  }

  /**
   * Get user profile
   * GET /api/users/profile
   */
  async getProfile(req, res) {
    try {
      const userId = req.user.id;

      const result = await userService.getUserProfile(userId);

      res.status(200).json(result);
    } catch (error) {
      res.status(404).json({
        success: false,
        error: error.message,
      });
    }
  }

  /**
   * Update notification preferences
   * PUT /api/users/notification-preferences
   */
  async updateNotificationPreferences(req, res) {
    try {
      const userId = req.user.id;
      const preferences = req.body;

      if (!preferences || Object.keys(preferences).length === 0) {
        return res.status(400).json({
          success: false,
          error: "Preferences object is required",
        });
      }

      const result = await userService.updateNotificationPreferences(
        userId,
        preferences,
      );

      res.status(200).json(result);
    } catch (error) {
      res.status(400).json({
        success: false,
        error: error.message,
      });
    }
  }

  /**
   * Get notification preferences
   * GET /api/users/notification-preferences
   */
  async getNotificationPreferences(req, res) {
    try {
      const userId = req.user.id;

      const result = await userService.getNotificationPreferences(userId);

      res.status(200).json(result);
    } catch (error) {
      res.status(404).json({
        success: false,
        error: error.message,
      });
    }
  }

  /**
   * Update user settings
   * PUT /api/users/settings
   */
  async updateSettings(req, res) {
    try {
      const userId = req.user.id;
      const settings = req.body;

      if (!settings || Object.keys(settings).length === 0) {
        return res.status(400).json({
          success: false,
          error: "Settings object is required",
        });
      }

      const result = await userService.updateSettings(userId, settings);

      res.status(200).json(result);
    } catch (error) {
      res.status(400).json({
        success: false,
        error: error.message,
      });
    }
  }

  /**
   * Get user settings
   * GET /api/users/settings
   */
  async getSettings(req, res) {
    try {
      const userId = req.user.id;

      const result = await userService.getSettings(userId);

      res.status(200).json(result);
    } catch (error) {
      res.status(404).json({
        success: false,
        error: error.message,
      });
    }
  }

  /**
   * Update user metadata
   * PUT /api/users/metadata
   */
  async updateMetadata(req, res) {
    try {
      const userId = req.user.id;
      const metadata = req.body;

      if (!metadata || Object.keys(metadata).length === 0) {
        return res.status(400).json({
          success: false,
          error: "Metadata object is required",
        });
      }

      const result = await userService.updateMetadata(userId, metadata);

      res.status(200).json(result);
    } catch (error) {
      res.status(400).json({
        success: false,
        error: error.message,
      });
    }
  }
}

export default new UserController();
