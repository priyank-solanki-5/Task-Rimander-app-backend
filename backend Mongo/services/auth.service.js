import jwt from "jsonwebtoken";

class AuthService {
  // Generate JWT token
  generateToken(user) {
    const payload = {
      id: user.id,
      email: user.email,
      username: user.username,
    };

    // Token expires in 30 days for multi-device access
    return jwt.sign(payload, process.env.JWT_SECRET || "your-secret-key", {
      expiresIn: "30d",
    });
  }

  // Verify JWT token
  verifyToken(token) {
    try {
      return jwt.verify(token, process.env.JWT_SECRET || "your-secret-key");
    } catch (error) {
      return null;
    }
  }

  // Decode token without verification (for checking expired tokens)
  decodeToken(token) {
    return jwt.decode(token);
  }
}

export default new AuthService();
