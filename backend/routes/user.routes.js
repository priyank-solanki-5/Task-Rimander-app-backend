import express from "express";
import userController from "../controller/user.controller.js";

const router = express.Router();

// Register user
router.post("/register", (req, res) => userController.register(req, res));

// Login user
router.post("/login", (req, res) => userController.login(req, res));

// Change password
router.put("/change-password", (req, res) =>
  userController.changePassword(req, res)
);

export default router;
