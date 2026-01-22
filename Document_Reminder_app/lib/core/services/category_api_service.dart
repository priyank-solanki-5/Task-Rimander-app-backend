import 'api_client.dart';

class CategoryApiService {
  final ApiClient _apiClient = ApiClient();

  /// Get all categories
  Future<Map<String, dynamic>> getAllCategories() async {
    try {
      final response = await _apiClient.get('/category/get-all-categories');
      return {'success': true, 'data': response.data};
    } catch (e) {
      return {'success': false, 'message': 'Failed to fetch categories: $e'};
    }
  }

  /// Get category by ID
  Future<Map<String, dynamic>> getCategoryById(String categoryId) async {
    try {
      final response = await _apiClient.get('/category/get/$categoryId');
      return {'success': true, 'data': response.data};
    } catch (e) {
      return {'success': false, 'message': 'Failed to fetch category: $e'};
    }
  }

  /// Create a new category
  Future<Map<String, dynamic>> createCategory({
    required String name,
    String? description,
    String? color,
  }) async {
    try {
      final response = await _apiClient.post(
        '/category/create',
        data: {'name': name, 'description': description, 'color': color},
      );
      return {'success': true, 'data': response.data};
    } catch (e) {
      return {'success': false, 'message': 'Failed to create category: $e'};
    }
  }

  /// Update a category
  Future<Map<String, dynamic>> updateCategory(
    String categoryId, {
    required String name,
    String? description,
    String? color,
  }) async {
    try {
      final response = await _apiClient.put(
        '/category/update/$categoryId',
        data: {'name': name, 'description': description, 'color': color},
      );
      return {'success': true, 'data': response.data};
    } catch (e) {
      return {'success': false, 'message': 'Failed to update category: $e'};
    }
  }

  /// Delete a category
  Future<Map<String, dynamic>> deleteCategory(String categoryId) async {
    try {
      final response = await _apiClient.delete('/category/delete/$categoryId');
      return {'success': true, 'data': response.data};
    } catch (e) {
      return {'success': false, 'message': 'Failed to delete category: $e'};
    }
  }
}
