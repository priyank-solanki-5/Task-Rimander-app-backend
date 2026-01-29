import jwt from "jsonwebtoken";

class AuthService {
  // Generate JWT token with 30-day expiry for persistent login
  generateToken(user) {
    const payload = {
      id: user.id,
      email: user.email,
      username: user.username,
      generatedAt: new Date().toISOString(),
    };

    // Token expires in 30 days for persistent login
    return jwt.sign(payload, process.env.JWT_SECRET || "your-secret-key", {
      expiresIn: "30d",
    });
  }

  // Refresh JWT token (generate new token with fresh expiry)
  refreshToken(user) {
    const payload = {
      id: user.id,
      email: user.email,
      username: user.username,
      refreshedAt: new Date().toISOString(),
    };

    // Token expires in 30 days
    return jwt.sign(payload, process.env.JWT_SECRET || "your-secret-key", {
      expiresIn: "30d",
    });
  }

  // Verify JWT token
  verifyToken(token) {
    try {
      return jwt.verify(token, process.env.JWT_SECRET || "your-secret-key");
    } catch (error) {
      return error;
    }
  }

  // Decode token without verification (for checking expired tokens)
  decodeToken(token) {
    return jwt.decode(token);
  }
}

export default new AuthService();
