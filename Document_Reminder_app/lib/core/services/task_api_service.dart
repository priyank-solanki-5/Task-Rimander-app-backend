import 'api_client.dart';

class TaskApiService {
  final ApiClient _apiClient = ApiClient();

  /// Get all tasks
  Future<Map<String, dynamic>> getAllTasks() async {
    try {
      final response = await _apiClient.get('/task/get-all-tasks');
      return {'success': true, 'data': response.data};
    } catch (e) {
      return {'success': false, 'message': 'Failed to fetch tasks: $e'};
    }
  }

  /// Get task by ID
  Future<Map<String, dynamic>> getTaskById(String taskId) async {
    try {
      final response = await _apiClient.get('/task/get/$taskId');
      return {'success': true, 'data': response.data};
    } catch (e) {
      return {'success': false, 'message': 'Failed to fetch task: $e'};
    }
  }

  /// Create a new task
  Future<Map<String, dynamic>> createTask({
    required String title,
    required String description,
    required String status,
    String? dueDate,
    bool isRecurring = false,
    String? recurrenceType,
    String? categoryId,
  }) async {
    try {
      final response = await _apiClient.post(
        '/task/create',
        data: {
          'title': title,
          'description': description,
          'status': status,
          'dueDate': dueDate,
          'isRecurring': isRecurring,
          'recurrenceType': recurrenceType,
          'categoryId': categoryId,
        },
      );
      return {'success': true, 'data': response.data};
    } catch (e) {
      return {'success': false, 'message': 'Failed to create task: $e'};
    }
  }

  /// Update a task
  Future<Map<String, dynamic>> updateTask(
    String taskId, {
    required String title,
    required String description,
    required String status,
    String? dueDate,
    bool isRecurring = false,
    String? recurrenceType,
    String? categoryId,
  }) async {
    try {
      final response = await _apiClient.put(
        '/task/update/$taskId',
        data: {
          'title': title,
          'description': description,
          'status': status,
          'dueDate': dueDate,
          'isRecurring': isRecurring,
          'recurrenceType': recurrenceType,
          'categoryId': categoryId,
        },
      );
      return {'success': true, 'data': response.data};
    } catch (e) {
      return {'success': false, 'message': 'Failed to update task: $e'};
    }
  }

  /// Delete a task
  Future<Map<String, dynamic>> deleteTask(String taskId) async {
    try {
      final response = await _apiClient.delete('/task/delete/$taskId');
      return {'success': true, 'data': response.data};
    } catch (e) {
      return {'success': false, 'message': 'Failed to delete task: $e'};
    }
  }

  /// Get tasks by category
  Future<Map<String, dynamic>> getTasksByCategory(String categoryId) async {
    try {
      final response = await _apiClient.get('/task/by-category/$categoryId');
      return {'success': true, 'data': response.data};
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to fetch tasks by category: $e',
      };
    }
  }

  /// Get recurring tasks
  Future<Map<String, dynamic>> getRecurringTasks() async {
    try {
      final response = await _apiClient.get('/task/recurring');
      return {'success': true, 'data': response.data};
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to fetch recurring tasks: $e',
      };
    }
  }
}
