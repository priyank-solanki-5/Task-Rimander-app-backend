// Hide Flutter's Category annotation to avoid conflict with our Category model
import 'package:flutter/foundation.dart' hide Category;
import '../models/category.dart';
import '../services/category_service.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoryService _categoryService = CategoryService();

  List<Category> _categories = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Get predefined categories only
  List<Category> get predefinedCategories {
    return _categories.where((cat) => cat.isPredefined).toList();
  }

  // Get custom categories only
  List<Category> get customCategories {
    return _categories.where((cat) => !cat.isPredefined).toList();
  }

  // Get category by ID
  Category? getCategoryById(String id) {
    try {
      return _categories.firstWhere((cat) => cat.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get category name by ID
  String getCategoryName(String? id) {
    if (id == null) return 'Uncategorized';
    final category = getCategoryById(id);
    return category?.name ?? 'Unknown';
  }

  // Load all categories from API
  Future<void> loadCategories() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _categories = await _categoryService.getAllCategories();
      debugPrint('✅ Loaded ${_categories.length} categories from local DB');
    } catch (e) {
      _errorMessage = 'Failed to load categories: $e';
      debugPrint('❌ Error loading categories: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load predefined categories only
  Future<void> loadPredefinedCategories() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _categories = await _categoryService.getPredefinedCategories();
      debugPrint('✅ Loaded ${_categories.length} predefined categories');
    } catch (e) {
      _errorMessage = 'Failed to load categories: $e';
      debugPrint('❌ Error loading predefined categories: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create custom category
  Future<Category?> createCategory(Category category) async {
    try {
      final createdCategory = await _categoryService.createCategory(category);
      if (createdCategory != null) {
        _categories.add(createdCategory);
        notifyListeners();
        debugPrint('✅ Category created successfully: ${createdCategory.id}');
        return createdCategory;
      }
      return null;
    } catch (e) {
      _errorMessage = 'Failed to create category: $e';
      debugPrint('❌ Error creating category: $e');
      return null;
    }
  }

  // Update category
  Future<bool> updateCategory(Category category) async {
    try {
      final updatedCategory =
          await _categoryService.updateCategory(category.id!, category);
      if (updatedCategory != null) {
        final index = _categories.indexWhere((c) => c.id == category.id);
        if (index != -1) {
          _categories[index] = updatedCategory;
          notifyListeners();
        }
        debugPrint('✅ Category updated successfully');
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = 'Failed to update category: $e';
      debugPrint('❌ Error updating category: $e');
      return false;
    }
  }

  // Delete category
  Future<bool> deleteCategory(String id) async {
    try {
      final success = await _categoryService.deleteCategory(id);
      if (success) {
        _categories.removeWhere((c) => c.id == id);
        notifyListeners();
        debugPrint('✅ Category deleted successfully');
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = 'Failed to delete category: $e';
      debugPrint('❌ Error deleting category: $e');
      return false;
    }
  }

  // Refresh categories
  Future<void> refreshCategories() async {
    await loadCategories();
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
