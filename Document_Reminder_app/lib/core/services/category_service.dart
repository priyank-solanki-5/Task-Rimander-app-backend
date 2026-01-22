import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../database/database_helper.dart';
import '../models/category.dart';
import 'token_storage.dart';

class CategoryService {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final Uuid _uuid = const Uuid();

  /// Get all categories (predefined + custom)
  Future<List<Category>> getAllCategories() async {
    try {
      final userId = await TokenStorage.getToken(); // Assuming token signifies user, but ideally we need userId.
      // Note: TokenStorage might store userId separately. Let's check TokenStorage usage.
      // For now, I'll fetch everything or filter by userId if available.
      
      final db = await _dbHelper.database;
      
      // Get all categories (predefined OR belonging to user)
      // If we don't have a reliable userId locally, we might show all custom categories?
      // Let's assume we can get userId.
      // Checking TokenStorage implementation...
      // Just in case, let's fetch all for now or filter if we can.
      
      final List<Map<String, dynamic>> maps = await db.query('categories');
      
      return List.generate(maps.length, (i) {
        // Convert integer 1/0 back to boolean for isPredefined
        var map = Map<String, dynamic>.from(maps[i]);
        map['isPredefined'] = map['isPredefined'] == 1; 
        return Category.fromJson(map);
      });
    } catch (e) {
      debugPrint('❌ Error getting all categories: $e');
      return [];
    }
  }

  /// Get predefined categories only
  Future<List<Category>> getPredefinedCategories() async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'categories',
        where: 'isPredefined = ?',
        whereArgs: [1],
      );
      
      return List.generate(maps.length, (i) {
        var map = Map<String, dynamic>.from(maps[i]);
        map['isPredefined'] = true;
        return Category.fromJson(map);
      });
    } catch (e) {
      debugPrint('❌ Error getting predefined categories: $e');
      return [];
    }
  }

  /// Get category by ID
  Future<Category?> getCategoryById(String id) async {
    try {
      final map = await _dbHelper.queryById('categories', 'id', id);
      if (map != null) {
        var mutableMap = Map<String, dynamic>.from(map);
        mutableMap['isPredefined'] = mutableMap['isPredefined'] == 1;
        return Category.fromJson(mutableMap);
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error getting category by ID: $e');
      return null;
    }
  }

  /// Create a custom category
  Future<Category?> createCategory(Category category) async {
    try {
      final now = DateTime.now().toIso8601String();
      final String id = _uuid.v4();
      
      final newCategory = category.copyWith(
        id: id,
        createdAt: DateTime.now(), // update local model
        updatedAt: DateTime.now(),
        isPredefined: false,
      );

      final map = newCategory.toJson();
      // SQLite needs int for bool
      map['isPredefined'] = 0;
      map['createdAt'] = now;
      map['updatedAt'] = now;
      // Remove nulls if necessary, or handled by insert? 
      // sqflite handles nulls.

      await _dbHelper.insert('categories', map);
      
      debugPrint('✅ Category created locally: $id');
      return newCategory;
    } catch (e) {
      debugPrint('❌ Error creating category: $e');
      return null;
    }
  }

  /// Update a custom category
  Future<Category?> updateCategory(String id, Category category) async {
    try {
      final now = DateTime.now().toIso8601String();
      final updatedCategory = category.copyWith(
        updatedAt: DateTime.now(),
      );

      final map = updatedCategory.toJson();
      map['isPredefined'] = (map['isPredefined'] == true) ? 1 : 0;
      map['updatedAt'] = now;
      if (map['createdAt'] != null) map['createdAt'] = (category.createdAt ?? DateTime.now()).toIso8601String();

      await _dbHelper.update('categories', map, 'id', id);
      
      debugPrint('✅ Category updated locally: $id');
      return updatedCategory;
    } catch (e) {
      debugPrint('❌ Error updating category: $e');
      return null;
    }
  }

  /// Delete a custom category
  Future<bool> deleteCategory(String id) async {
    try {
      // Prevent deleting predefined categories? (Handled by logic usually, but good to check)
      final cat = await getCategoryById(id);
      if (cat?.isPredefined == true) {
        debugPrint('⚠️ Cannot delete predefined category');
        return false;
      }

      final count = await _dbHelper.delete('categories', 'id', id);
      return count > 0;
    } catch (e) {
      debugPrint('❌ Error deleting category: $e');
      return false;
    }
  }
}
