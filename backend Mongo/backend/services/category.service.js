import categoryDao from "../dao/categoryDao.js";

class CategoryService {
  async getAllCategories() {
    return await categoryDao.findAllCategories();
  }

  async getPredefinedCategories() {
    return await categoryDao.findPredefinedCategories();
  }

  async getCustomCategories() {
    return await categoryDao.findCustomCategories();
  }

  async getCategoryById(id) {
    const category = await categoryDao.findCategoryById(id);
    if (!category) {
      throw new Error("Category not found");
    }
    return category;
  }

  async createCustomCategory(name, description) {
    // Check if category already exists
    const existing = await categoryDao.findCategoryByName(name);
    if (existing) {
      throw new Error("Category with this name already exists");
    }

    // Create custom category
    const category = await categoryDao.createCategory({
      name,
      description,
      isPredefined: false,
    });

    return category;
  }

  async updateCategory(id, name, description) {
    const category = await categoryDao.findCategoryById(id);
    if (!category) {
      throw new Error("Category not found");
    }

    // Prevent updating predefined categories
    if (category.isPredefined) {
      throw new Error("Cannot update predefined categories");
    }

    // Check if new name conflicts with existing category
    if (name && name !== category.name) {
      const existing = await categoryDao.findCategoryByName(name);
      if (existing) {
        throw new Error("Category with this name already exists");
      }
    }

    const updateData = {};
    if (name) updateData.name = name;
    if (description !== undefined) updateData.description = description;

    await categoryDao.updateCategory(category, updateData);
    return category;
  }

  async deleteCategory(id) {
    const category = await categoryDao.findCategoryById(id);
    if (!category) {
      throw new Error("Category not found");
    }

    // Prevent deleting predefined categories
    if (category.isPredefined) {
      throw new Error("Cannot delete predefined categories");
    }

    await categoryDao.deleteCategory(id);
    return { message: "Category deleted successfully" };
  }

  async seedPredefinedCategories() {
    await categoryDao.seedPredefinedCategories();
  }
}

export default new CategoryService();
