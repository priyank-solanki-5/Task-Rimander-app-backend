// Hide Flutter's Category annotation to avoid conflict with our Category model
import 'package:flutter/foundation.dart' hide Category;
import '../models/category.dart';
import '../services/category_api_service.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoryApiService _categoryService = CategoryApiService();

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
  Future<void> loadCategories({bool forceRefresh = false}) async {
    if (_categories.isNotEmpty && !forceRefresh) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _categoryService.getAllCategories();
      if (result['success'] == true) {
        final data = result['data'];
        if (data is List) {
          _categories = data.map((json) => Category.fromJson(json)).toList();
        } else if (data is Map && data.containsKey('categories')) {
          // Handle case where data might be { categories: [...] }
          final list = data['categories'] as List;
          _categories = list.map((json) => Category.fromJson(json)).toList();
        } else {
          // Fallback or assume data itself is the list if possible, or inspection needed.
          // Based on typical API response structure from TaskApiService which returns data['data'] as list,
          // but here getAllCategories returns {'success': true, 'data': response.data}.
          // If response.data IS the list, then `data` is the list.
          // If response.data is { data: [...] }, then `data` is that map.
          // Looking at TaskApiService, it did `response.data['data']`.
          // Here `CategoryApiService` does `return {'success': true, 'data': response.data}`.
          // So if backend returns standard `{ status: ..., data: [...] }`, then `result['data']` is that whole object.
          // This seems slightly inconsistent wrapper.
          // Let's assume response.data IS the list or contains it.
          // Safer to try casting.
          if (data is List) {
            _categories = data.map((json) => Category.fromJson(json)).toList();
          } else if (data is Map && data.containsKey('data')) {
            final list = data['data'] as List;
            _categories = list.map((json) => Category.fromJson(json)).toList();
          }
        }
        debugPrint('✅ Loaded ${_categories.length} categories from API');
      } else {
        _errorMessage = result['message'];
      }
    } catch (e) {
      _errorMessage = 'Failed to load categories: $e';
      debugPrint('❌ Error loading categories: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create custom category
  Future<Category?> createCategory(Category category) async {
    try {
      final result = await _categoryService.createCategory(
        name: category.name,
        description: category.description,
        color: category.color,
      );

      if (result['success'] == true) {
        // Adjust based on actual API response structure
        // Assuming result['data'] is the created category object or contains it
        final data = result['data'];
        final createdCategory = Category.fromJson(
          data is Map<String, dynamic> && data.containsKey('data')
              ? data['data']
              : data,
        );

        _categories.add(createdCategory);
        notifyListeners();
        debugPrint('✅ Category created successfully: ${createdCategory.id}');
        return createdCategory;
      }
      _errorMessage = result['message'];
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
      if (category.id == null) return false;

      final result = await _categoryService.updateCategory(
        category.id!,
        name: category.name,
        description: category.description,
        color: category.color,
      );

      if (result['success'] == true) {
        final data = result['data'];
        final updatedCategory = Category.fromJson(
          data is Map<String, dynamic> && data.containsKey('data')
              ? data['data']
              : data,
        );

        final index = _categories.indexWhere((c) => c.id == category.id);
        if (index != -1) {
          _categories[index] = updatedCategory;
          notifyListeners();
        }
        debugPrint('✅ Category updated successfully');
        return true;
      }
      _errorMessage = result['message'];
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
      final result = await _categoryService.deleteCategory(id);

      if (result['success'] == true) {
        _categories.removeWhere((c) => c.id == id);
        notifyListeners();
        debugPrint('✅ Category deleted successfully');
        return true;
      }
      _errorMessage = result['message'];
      return false;
    } catch (e) {
      _errorMessage = 'Failed to delete category: $e';
      debugPrint('❌ Error deleting category: $e');
      return false;
    }
  }

  // Refresh categories
  Future<void> refreshCategories() async {
    await loadCategories(forceRefresh: true);
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
