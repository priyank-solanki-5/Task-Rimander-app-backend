import userService from "../services/user.service.js";

class UserController {
  async register(req, res) {
    try {
      const { username, mobilenumber, email, password } = req.body;

      // Validate input
      if (!username || !mobilenumber || !email || !password) {
        return res.status(400).json({
          error: "All fields are required",
        });
      }

      const user = await userService.registerUser(
        username,
        mobilenumber,
        email,
        password
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
        newPassword
      );

      res.status(200).json(result);
    } catch (error) {
      res.status(404).json({ error: error.message });
    }
  }
}

export default new UserController();
