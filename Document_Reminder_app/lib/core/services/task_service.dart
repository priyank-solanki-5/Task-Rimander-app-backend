import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/task.dart';
import 'mongo_service.dart';
import 'token_storage.dart';

class TaskService {
  final MongoService _mongoService = MongoService();
  final Uuid _uuid = const Uuid();

  /// Get all tasks
  Future<List<Task>> getAllTasks() async {
    try {
      final userId = await TokenStorage.getUserId();
      final query = userId != null ? {'userId': userId} : {};
      
      final List<Map<String, dynamic>> maps = await _mongoService.findAll(
        'tasks',
        query: query,
        sort: {'dueDate': 1},
      );
      
      return maps.map((map) => Task.fromJson(map)).toList();
    } catch (e) {
      debugPrint('❌ Error getting all tasks: $e');
      return [];
    }
  }

  /// Get task by ID
  Future<Task?> getTaskById(String id) async {
    try {
      final map = await _mongoService.findById('tasks', id);
      if (map != null) {
        return Task.fromJson(map);
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error getting task by ID: $e');
      return null;
    }
  }

  /// Create a new task
  Future<Task?> createTask(Task task) async {
    try {
      final userId = await TokenStorage.getUserId() ?? task.userId;
      
      final newTask = task.copyWith(
        id: _uuid.v4(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        userId: userId,
      );

      final map = newTask.toJson();
      map.remove('_id'); // Remove _id as MongoDB will generate it
      
      final taskId = await _mongoService.insertOne('tasks', map);
      
      debugPrint('✅ Task created: $taskId');
      return newTask.copyWith(id: taskId);
    } catch (e) {
      debugPrint('❌ Error creating task: $e');
      return null;
    }
  }

  /// Update a task
  Future<Task?> updateTask(String id, Task task) async {
    try {
      final updatedTask = task.copyWith(
        updatedAt: DateTime.now(),
      );

      final map = updatedTask.toJson();
      map.remove('_id'); // Remove _id as it shouldn't be updated
      
      await _mongoService.updateOne('tasks', id, map);
      
      debugPrint('✅ Task updated: $id');
      return updatedTask.copyWith(id: id);
    } catch (e) {
      debugPrint('❌ Error updating task: $e');
      return null;
    }
  }

  /// Delete a task
  Future<bool> deleteTask(String id) async {
    try {
      await _mongoService.deleteOne('tasks', id);
      debugPrint('✅ Task deleted: $id');
      return true;
    } catch (e) {
      debugPrint('❌ Error deleting task: $e');
      return false;
    }
  }

  /// Mark task as complete
  Future<Task?> markTaskComplete(String id) async {
    try {
      final task = await getTaskById(id);
      if (task != null) {
        final updated = task.copyWith(status: TaskStatus.completed);
        return await updateTask(id, updated);
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error marking task complete: $e');
      return null;
    }
  }
  
  /// Mark task as pending
  Future<Task?> markTaskPending(String id) async {
    try {
      final task = await getTaskById(id);
      if (task != null) {
        final updated = task.copyWith(status: TaskStatus.pending);
        return await updateTask(id, updated);
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error marking task pending: $e');
      return null;
    }
  }

  /// Search tasks
  Future<List<Task>> searchTasks(String query) async {
    try {
      final userId = await TokenStorage.getUserId();
      final searchQuery = {
        if (userId != null) 'userId': userId,
        '\$or': [
          {'title': {'\$regex': query, '\$options': 'i'}},
          {'description': {'\$regex': query, '\$options': 'i'}},
        ],
      };
      
      final List<Map<String, dynamic>> maps = await _mongoService.findAll(
        'tasks',
        query: searchQuery,
        sort: {'dueDate': 1},
      );
      
      return maps.map((map) => Task.fromJson(map)).toList();
    } catch (e) {
      debugPrint('❌ Error searching tasks: $e');
      return [];
    }
  }
  
  /// Filter tasks by status, category, date
  Future<List<Task>> filterTasks({TaskStatus? status, String? categoryId, DateTime? date}) async {
    try {
      final userId = await TokenStorage.getUserId();
      Map<String, dynamic> query = {};
      
      if (userId != null) {
        query['userId'] = userId;
      }
      
      if (status != null) {
        query['status'] = status == TaskStatus.completed ? 'Completed' : 'Pending';
      }
      
      if (categoryId != null) {
        query['categoryId'] = categoryId;
      }
      
      if (date != null) {
        final dateStr = date.toIso8601String().split('T')[0];
        query['dueDate'] = {'\$regex': '^$dateStr'};
      }

      final List<Map<String, dynamic>> maps = await _mongoService.findAll(
        'tasks',
        query: query,
        sort: {'dueDate': 1},
      );
      
      return maps.map((map) => Task.fromJson(map)).toList();
    } catch (e) {
      debugPrint('❌ Error filtering tasks: $e');
      return [];
    }
  }
      
  /// Get overdue tasks
  Future<List<Task>> getOverdueTasks() async {
    try {
      final userId = await TokenStorage.getUserId();
      final now = DateTime.now().toIso8601String();
      
      final query = {
        if (userId != null) 'userId': userId,
        'dueDate': {'\$lt': now},
        'status': {'\$ne': 'Completed'},
      };
      
      final List<Map<String, dynamic>> maps = await _mongoService.findAll(
        'tasks',
        query: query,
        sort: {'dueDate': 1},
      );
      
      return maps.map((map) => Task.fromJson(map)).toList();
    } catch (e) {
      debugPrint('❌ Error getting overdue tasks: $e');
      return [];
    }
  }

  /// Get upcoming tasks
  Future<List<Task>> getUpcomingTasks({int days = 7}) async {
    try {
      final userId = await TokenStorage.getUserId();
      final now = DateTime.now();
      final end = now.add(Duration(days: days));
      
      final nowStr = now.toIso8601String();
      final endStr = end.toIso8601String();

      final query = {
        if (userId != null) 'userId': userId,
        'dueDate': {'\$gte': nowStr, '\$lte': endStr},
        'status': {'\$ne': 'Completed'},
      };

      final List<Map<String, dynamic>> maps = await _mongoService.findAll(
        'tasks',
        query: query,
        sort: {'dueDate': 1},
      );
      
      return maps.map((map) => Task.fromJson(map)).toList();
    } catch (e) {
      debugPrint('❌ Error getting upcoming tasks: $e');
      return [];
    }
  }
}
