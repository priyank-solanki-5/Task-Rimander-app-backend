import Category from "../models/Category.js";

class CategoryDao {
  async createCategory(categoryData) {
    return await Category.create(categoryData);
  }

  async findAllCategories() {
    return await Category.findAll({
      order: [
        ["isPredefined", "DESC"],
        ["name", "ASC"],
      ],
    });
  }

  async findCategoryById(id) {
    return await Category.findByPk(id);
  }

  async findCategoryByName(name) {
    return await Category.findOne({ where: { name } });
  }

  async findPredefinedCategories() {
    return await Category.findAll({
      where: { isPredefined: true },
      order: [["name", "ASC"]],
    });
  }

  async findCustomCategories() {
    return await Category.findAll({
      where: { isPredefined: false },
      order: [["name", "ASC"]],
    });
  }

  async updateCategory(category, data) {
    return await category.update(data);
  }

  async deleteCategory(id) {
    return await Category.destroy({ where: { id } });
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
