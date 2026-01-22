import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/category.dart' as models;
import 'mongo_service.dart';
import 'token_storage.dart';

class CategoryService {
  final MongoService _mongoService = MongoService();
  final Uuid _uuid = const Uuid();

  /// Get all categories (predefined + custom)
  Future<List<models.Category>> getAllCategories() async {
    try {
      final userId = await TokenStorage.getUserId();
      final query = userId != null ? {
        '\$or': [
          {'isPredefined': true},
          {'userId': userId}
        ]
      } : {'isPredefined': true};
      
      final List<Map<String, dynamic>> maps = await _mongoService.findAll(
        'categories',
        query: query,
      );
      
      return maps.map((map) => models.Category.fromJson(map)).toList();
    } catch (e) {
      debugPrint('❌ Error getting all categories: $e');
      return [];
    }
  }

  /// Get predefined categories only
  Future<List<models.Category>> getPredefinedCategories() async {
    try {
      final List<Map<String, dynamic>> maps = await _mongoService.findAll(
        'categories',
        query: {'isPredefined': true},
      );
      
      return maps.map((map) => models.Category.fromJson(map)).toList();
    } catch (e) {
      debugPrint('❌ Error getting predefined categories: $e');
      return [];
    }
  }

  /// Get category by ID
  Future<models.Category?> getCategoryById(String id) async {
    try {
      final map = await _mongoService.findById('categories', id);
      if (map != null) {
        return models.Category.fromJson(map);
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error getting category by ID: $e');
      return null;
    }
  }

  /// Create a custom category
  Future<models.Category?> createCategory(models.Category category) async {
    try {
      final userId = await TokenStorage.getUserId();
      
      final newCategory = category.copyWith(
        id: _uuid.v4(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isPredefined: false,
        userId: userId,
      );

      final map = newCategory.toJson();
      map.remove('_id'); // Remove _id as MongoDB will generate it
      
      final categoryId = await _mongoService.insertOne('categories', map);
      
      debugPrint('✅ Category created: $categoryId');
      return newCategory.copyWith(id: categoryId);
    } catch (e) {
      debugPrint('❌ Error creating category: $e');
      return null;
    }
  }

  /// Update a custom category
  Future<models.Category?> updateCategory(String id, models.Category category) async {
    try {
      final updatedCategory = category.copyWith(
        updatedAt: DateTime.now(),
      );

      final map = updatedCategory.toJson();
      map.remove('_id'); // Remove _id as it shouldn't be updated
      
      await _mongoService.updateOne('categories', id, map);
      
      debugPrint('✅ Category updated: $id');
      return updatedCategory.copyWith(id: id);
    } catch (e) {
      debugPrint('❌ Error updating category: $e');
      return null;
    }
  }

  /// Delete a custom category
  Future<bool> deleteCategory(String id) async {
    try {
      // Prevent deleting predefined categories
      final cat = await getCategoryById(id);
      if (cat?.isPredefined == true) {
        debugPrint('⚠️ Cannot delete predefined category');
        return false;
      }

      await _mongoService.deleteOne('categories', id);
      debugPrint('✅ Category deleted: $id');
      return true;
    } catch (e) {
      debugPrint('❌ Error deleting category: $e');
      return false;
    }
  }
}
