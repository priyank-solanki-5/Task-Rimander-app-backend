import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../database/database_helper.dart';
import '../models/task.dart';
import 'token_storage.dart';

class TaskService {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final Uuid _uuid = const Uuid();

  /// Get all tasks
  Future<List<Task>> getAllTasks() async {
    try {
      final db = await _dbHelper.database;
      // Filter by userId if using authentication
      // final userId = await TokenStorage.getToken(); 
      // For now, get all.
      
      final List<Map<String, dynamic>> maps = await db.query('tasks', orderBy: 'dueDate ASC');
      
      return List.generate(maps.length, (i) {
        return Task.fromJson(_mapFromDb(maps[i]));
      });
    } catch (e) {
      debugPrint('❌ Error getting all tasks: $e');
      return [];
    }
  }

  /// Get task by ID
  Future<Task?> getTaskById(String id) async {
    try {
      final map = await _dbHelper.queryById('tasks', 'id', id);
      if (map != null) {
        return Task.fromJson(_mapFromDb(map));
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
      final now = DateTime.now().toIso8601String();
      final String id = _uuid.v4();
      
      // Assign default userId if missing (assuming single user offline or checking token)
      // Since auth is valid, we might want to store the real userId from token or defaults.
      // Ideally we decode the token to get userId. For now, let's assume the passed task has it
      // or we assign a placeholder.
      
      final newTask = task.copyWith(
        id: id,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final map = newTask.toJson();
      map['_id'] = id; // Model expects _id for json, but we use id in db. 
                       // Wait, toJson uses '_id' if id is not null.
                       // DB expects 'id'.
      
      // Adjust map for DB
      var dbMap = _mapToDb(map);
      
      await _dbHelper.insert('tasks', dbMap);
      
      debugPrint('✅ Task created locally: $id');
      return newTask;
    } catch (e) {
      debugPrint('❌ Error creating task: $e');
      return null;
    }
  }

  /// Update a task
  Future<Task?> updateTask(String id, Task task) async {
    try {
      final now = DateTime.now().toIso8601String();
      final updatedTask = task.copyWith(
        updatedAt: DateTime.now(),
      );

      final map = updatedTask.toJson();
      var dbMap = _mapToDb(map);
      
      await _dbHelper.update('tasks', dbMap, 'id', id);
      
      debugPrint('✅ Task updated locally: $id');
      return updatedTask;
    } catch (e) {
      debugPrint('❌ Error updating task: $e');
      return null;
    }
  }

  /// Delete a task
  Future<bool> deleteTask(String id) async {
    try {
      final count = await _dbHelper.delete('tasks', 'id', id);
      return count > 0;
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
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'tasks',
        where: 'title LIKE ? OR description LIKE ?',
        whereArgs: ['%$query%', '%$query%'],
        orderBy: 'dueDate ASC',
      );
      
      return List.generate(maps.length, (i) {
        return Task.fromJson(_mapFromDb(maps[i]));
      });
    } catch (e) {
      debugPrint('❌ Error searching tasks: $e');
      return [];
    }
  }
  
  /// Filter tasks by status, category, date
  Future<List<Task>> filterTasks({TaskStatus? status, String? categoryId, DateTime? date}) async {
    try {
      final db = await _dbHelper.database;
      
      String whereClause = '';
      List<dynamic> args = [];
      
      if (status != null) {
        whereClause += 'status = ?';
        args.add(status == TaskStatus.completed ? 'Completed' : 'Pending');
      }
      
      if (categoryId != null) {
        if (whereClause.isNotEmpty) whereClause += ' AND ';
        whereClause += 'categoryId = ?';
        args.add(categoryId);
      }
      
      // Date filtering might be tricky with string dates. 
      // Assuming naive string comparison works if ISO8601 YYYY-MM-DD matches start.
      if (date != null) {
        if (whereClause.isNotEmpty) whereClause += ' AND ';
        // Compare date part only
        // This is a simplification. Ideally check ranges.
        whereClause += 'dueDate LIKE ?';
        String dateStr = date.toIso8601String().split('T')[0];
        args.add('$dateStr%');
      }

      final List<Map<String, dynamic>> maps = await db.query(
        'tasks',
        where: whereClause.isEmpty ? null : whereClause,
        whereArgs: args.isEmpty ? null : args,
        orderBy: 'dueDate ASC',
      );
      
  /// Get overdue tasks
  Future<List<Task>> getOverdueTasks() async {
    try {
      final db = await _dbHelper.database;
      final now = DateTime.now().toIso8601String();
      
      final List<Map<String, dynamic>> maps = await db.query(
        'tasks',
        where: 'dueDate < ? AND status != ?',
        whereArgs: [now, 'Completed'], // Assuming 'Completed' is the string value stored
        orderBy: 'dueDate ASC',
      );
      
      return List.generate(maps.length, (i) {
        return Task.fromJson(_mapFromDb(maps[i]));
      });
    } catch (e) {
      debugPrint('❌ Error getting overdue tasks: $e');
      return [];
    }
  }

  /// Get upcoming tasks
  Future<List<Task>> getUpcomingTasks({int days = 7}) async {
    try {
      final db = await _dbHelper.database;
      final now = DateTime.now();
      final end = now.add(Duration(days: days));
      
      final nowStr = now.toIso8601String();
      final endStr = end.toIso8601String();

      final List<Map<String, dynamic>> maps = await db.query(
        'tasks',
        where: 'dueDate BETWEEN ? AND ? AND status != ?',
        whereArgs: [nowStr, endStr, 'Completed'],
        orderBy: 'dueDate ASC',
      );
      
      return List.generate(maps.length, (i) {
        return Task.fromJson(_mapFromDb(maps[i]));
      });
    } catch (e) {
      debugPrint('❌ Error getting upcoming tasks: $e');
      return [];
    }
  }


  // Helpers to convert DB map (Tasks table usually has 'isRecurring' as int) to JSON for Model
  Map<String, dynamic> _mapFromDb(Map<String, dynamic> dbMap) {
    var map = Map<String, dynamic>.from(dbMap);
    // Convert id back to _id if needed by Model?
    if (map['id'] != null) {
      map['_id'] = map['id'];
    }
    // Boolean conversion
    if (map['isRecurring'] is int) {
      map['isRecurring'] = map['isRecurring'] == 1;
    }
    return map;
  }
  
  Map<String, dynamic> _mapToDb(Map<String, dynamic> jsonMap) {
    var map = Map<String, dynamic>.from(jsonMap);
    // Ensure id exists
    if (map['_id'] != null) {
      map['id'] = map['_id'];
      map.remove('_id');
    }
    // Boolean conversion
    if (map['isRecurring'] is bool) {
      map['isRecurring'] = (map['isRecurring'] as bool) ? 1 : 0;
    }
    return map;
  }
}
