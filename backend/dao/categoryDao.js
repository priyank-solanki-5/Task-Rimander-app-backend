import Category from "../models/Category.js";

class CategoryDao {
  async createCategory(categoryData) {
    const category = new Category(categoryData);
    return await category.save();
  }

  async findAllCategories() {
    return await Category.find().sort({ isPredefined: -1, name: 1 });
  }

  async findCategoryById(id) {
    return await Category.findById(id);
  }

  async findCategoryByName(name) {
    return await Category.findOne({ name });
  }

  async findPredefinedCategories() {
    return await Category.find({ isPredefined: true }).sort({ name: 1 });
  }

  async findCustomCategories() {
    return await Category.find({ isPredefined: false }).sort({ name: 1 });
  }

  async updateCategory(category, data) {
    Object.assign(category, data);
    return await category.save();
  }

  async deleteCategory(id) {
    return await Category.findByIdAndDelete(id);
  }

  async seedPredefinedCategories() {
    const predefinedCategories = [
      {
        name: "House",
        isPredefined: true,
        description: "Home and household tasks",
      },
      {
        name: "Vehicle",
        isPredefined: true,
        description: "Vehicle maintenance and related tasks",
      },
      {
        name: "Financial",
        isPredefined: true,
        description: "Financial and money related tasks",
      },
      {
        name: "Personal",
        isPredefined: true,
        description: "Personal tasks and activities",
      },
    ];

    for (const category of predefinedCategories) {
      const existing = await this.findCategoryByName(category.name);
      if (!existing) {
        await this.createCategory(category);
      }
    }
  }
}

export default new CategoryDao();
