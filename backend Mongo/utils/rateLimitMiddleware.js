import rateLimit from "express-rate-limit";

/**
 * General API rate limiter
 * 100 requests per 15 minutes per IP
 */
export const apiLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // Limit each IP to 100 requests per windowMs
  message: {
    success: false,
    error: "Too many requests from this IP, please try again later.",
    retryAfter: "15 minutes",
  },
  standardHeaders: true, // Return rate limit info in the `RateLimit-*` headers
  legacyHeaders: false, // Disable the `X-RateLimit-*` headers
  handler: (req, res) => {
    res.status(429).json({
      success: false,
      error: "Too many requests. Please try again later.",
      retryAfter: Math.ceil(req.rateLimit.resetTime / 1000),
    });
  },
});

/**
 * Authentication rate limiter (stricter)
 * 5 requests per 15 minutes per IP
 * For login, register, change password endpoints
 */
export const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 5, // Limit each IP to 5 requests per windowMs
  skipSuccessfulRequests: false,
  message: {
    success: false,
    error: "Too many authentication attempts, please try again later.",
    retryAfter: "15 minutes",
  },
  handler: (req, res) => {
    res.status(429).json({
      success: false,
      error:
        "Too many authentication attempts. Please try again after 15 minutes.",
    });
  },
});

/**
 * File upload rate limiter
 * 10 uploads per hour per IP
 */
export const uploadLimiter = rateLimit({
  windowMs: 60 * 60 * 1000, // 1 hour
  max: 10, // Limit each IP to 10 uploads per hour
  message: {
    success: false,
    error: "Too many file uploads, please try again later.",
    retryAfter: "1 hour",
  },
  handler: (req, res) => {
    res.status(429).json({
      success: false,
      error: "Upload limit exceeded. Please try again after 1 hour.",
    });
  },
});

/**
 * Search rate limiter
 * 50 searches per 15 minutes per IP
 */
export const searchLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 50,
  message: {
    success: false,
    error: "Too many search requests, please try again later.",
  },
});

export default {
  apiLimiter,
  authLimiter,
  uploadLimiter,
  searchLimiter,
};
