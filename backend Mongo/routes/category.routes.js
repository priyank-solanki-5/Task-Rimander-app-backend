import express from "express";
import categoryController from "../controller/category.controller.js";

const router = express.Router();

// Get all categories (predefined + custom)
router.get("/", (req, res) => categoryController.getAllCategories(req, res));

// Get predefined categories only
router.get("/predefined", (req, res) =>
  categoryController.getPredefinedCategories(req, res)
);

// Get custom categories only
router.get("/custom", (req, res) =>
  categoryController.getCustomCategories(req, res)
);

// Get category by ID
router.get("/:id", (req, res) => categoryController.getCategoryById(req, res));

// Create custom category
router.post("/", (req, res) =>
  categoryController.createCustomCategory(req, res)
);

// Update category (custom only)
router.put("/:id", (req, res) => categoryController.updateCategory(req, res));

// Delete category (custom only)
router.delete("/:id", (req, res) =>
  categoryController.deleteCategory(req, res)
);

export default router;
