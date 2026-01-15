import categoryService from "../services/category.service.js";

class CategoryController {
  async getAllCategories(req, res) {
    try {
      const categories = await categoryService.getAllCategories();
      res.status(200).json({
        message: "Categories fetched successfully",
        data: categories,
      });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }

  async getPredefinedCategories(req, res) {
    try {
      const categories = await categoryService.getPredefinedCategories();
      res.status(200).json({
        message: "Predefined categories fetched successfully",
        data: categories,
      });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }

  async getCustomCategories(req, res) {
    try {
      const categories = await categoryService.getCustomCategories();
      res.status(200).json({
        message: "Custom categories fetched successfully",
        data: categories,
      });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }

  async getCategoryById(req, res) {
    try {
      const { id } = req.params;
      const category = await categoryService.getCategoryById(id);
      res.status(200).json({
        message: "Category fetched successfully",
        data: category,
      });
    } catch (error) {
      res.status(404).json({ error: error.message });
    }
  }

  async createCustomCategory(req, res) {
    try {
      const { name, description } = req.body;

      // Validate input
      if (!name || name.trim() === "") {
        return res.status(400).json({
          error: "Category name is required",
        });
      }

      const category = await categoryService.createCustomCategory(
        name,
        description
      );

      res.status(201).json({
        message: "Custom category created successfully",
        data: category,
      });
    } catch (error) {
      res.status(400).json({ error: error.message });
    }
  }

  async updateCategory(req, res) {
    try {
      const { id } = req.params;
      const { name, description } = req.body;

      const category = await categoryService.updateCategory(
        id,
        name,
        description
      );

      res.status(200).json({
        message: "Category updated successfully",
        data: category,
      });
    } catch (error) {
      res.status(400).json({ error: error.message });
    }
  }

  async deleteCategory(req, res) {
    try {
      const { id } = req.params;
      const result = await categoryService.deleteCategory(id);
      res.status(200).json(result);
    } catch (error) {
      res.status(400).json({ error: error.message });
    }
  }
}

export default new CategoryController();
