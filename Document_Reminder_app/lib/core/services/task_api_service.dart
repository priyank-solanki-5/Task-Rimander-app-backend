import '../config/api_config.dart';
import '../models/task.dart';
import 'api_client.dart';

class TaskApiService {
  final ApiClient _apiClient = ApiClient();

  /// Get all tasks
  Future<List<Task>> getAllTasks({String? status, String? categoryId}) async {
    try {
      final response = await _apiClient.get(
        ApiConfig.tasks,
        queryParameters: {
          if (status != null) 'status': status,
          if (categoryId != null) 'categoryId': categoryId,
        },
      );
      final List<dynamic> data = response.data['data'] as List<dynamic>;
      return data.map((json) => Task.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch tasks: $e');
    }
  }

  /// Get task by ID
  Future<Task?> getTaskById(String taskId) async {
    try {
      final response = await _apiClient.get('${ApiConfig.tasks}/$taskId');
      return Task.fromJson(response.data['data']);
    } catch (e) {
      // Return null or rethrow depending on needs. Rethrowing lets provider handle it.
      throw Exception('Failed to fetch task: $e');
    }
  }

  /// Create a new task
  Future<Task> createTask(Task task) async {
    try {
      final response = await _apiClient.post(
        ApiConfig.tasks,
        data: task.toJson(),
      );
      return Task.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to create task: $e');
    }
  }

  /// Update a task
  Future<Task> updateTask(String taskId, Task task) async {
    try {
      final response = await _apiClient.put(
        '${ApiConfig.tasks}/$taskId',
        data: task.toJson(),
      );
      return Task.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to update task: $e');
    }
  }

  /// Delete a task
  Future<bool> deleteTask(String taskId) async {
    try {
      await _apiClient.delete('${ApiConfig.tasks}/$taskId');
      return true;
    } catch (e) {
      throw Exception('Failed to delete task: $e');
    }
  }

  /// Mark task as complete
  Future<Task> markTaskComplete(String taskId) async {
    try {
      final response = await _apiClient.patch(
        '${ApiConfig.tasks}/$taskId/complete',
      );
      return Task.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to mark task complete: $e');
    }
  }

  /// Mark task as pending
  Future<Task> markTaskPending(String taskId) async {
    try {
      final response = await _apiClient.patch(
        '${ApiConfig.tasks}/$taskId/pending',
      );
      return Task.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to mark task pending: $e');
    }
  }

  /// Search tasks
  Future<List<Task>> searchTasks(String query) async {
    try {
      final response = await _apiClient.get(
        ApiConfig.taskSearch,
        queryParameters: {'q': query},
      );
      final List<dynamic> data = response.data['data'] as List<dynamic>;
      return data.map((json) => Task.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to search tasks: $e');
    }
  }

  /// Filter tasks
  Future<List<Task>> filterTasks({
    String? status,
    String? categoryId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (status != null) queryParams['status'] = status;
      if (categoryId != null) queryParams['categoryId'] = categoryId;
      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String().split('T')[0];
      }
      if (endDate != null) {
        queryParams['endDate'] = endDate.toIso8601String().split('T')[0];
      }

      final response = await _apiClient.get(
        ApiConfig.taskFilter,
        queryParameters: queryParams,
      );
      final List<dynamic> data = response.data['data'] as List<dynamic>;
      return data.map((json) => Task.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to filter tasks: $e');
    }
  }

  /// Get overdue tasks
  Future<List<Task>> getOverdueTasks() async {
    try {
      final response = await _apiClient.get(ApiConfig.taskOverdue);
      final List<dynamic> data = response.data['data'] as List<dynamic>;
      return data.map((json) => Task.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch overdue tasks: $e');
    }
  }

  /// Get upcoming tasks
  Future<List<Task>> getUpcomingTasks({int days = 7}) async {
    try {
      final response = await _apiClient.get(
        ApiConfig.taskUpcoming,
        queryParameters: {'days': days},
      );
      final List<dynamic> data = response.data['data'] as List<dynamic>;
      return data.map((json) => Task.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch upcoming tasks: $e');
    }
  }

  /// Get recurring tasks
  Future<List<Task>> getRecurringTasks() async {
    try {
      final response = await _apiClient.get(ApiConfig.taskRecurring);
      final List<dynamic> data = response.data['data'] as List<dynamic>;
      return data.map((json) => Task.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch recurring tasks: $e');
    }
  }
}
