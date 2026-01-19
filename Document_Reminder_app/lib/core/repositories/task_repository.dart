import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../database/tables.dart';
import '../models/task.dart';

class TaskRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Get all tasks
  Future<List<Task>> getAllTasks() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      Tables.tasks,
      orderBy: '${Tables.taskDueDate} ASC',
    );
    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  // Get tasks by completion status
  Future<List<Task>> getTasksByStatus({required bool isCompleted}) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      Tables.tasks,
      where: '${Tables.taskIsCompleted} = ?',
      whereArgs: [isCompleted ? 1 : 0],
      orderBy: '${Tables.taskDueDate} ASC',
    );
    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  // Get due tasks (overdue and not completed)
  Future<List<Task>> getDueTasks() async {
    final db = await _dbHelper.database;
    final now = DateTime.now().toIso8601String();
    final List<Map<String, dynamic>> maps = await db.query(
      Tables.tasks,
      where: '${Tables.taskDueDate} < ? AND ${Tables.taskIsCompleted} = ?',
      whereArgs: [now, 0],
      orderBy: '${Tables.taskDueDate} ASC',
    );
    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  // Get current tasks (due today and not completed)
  Future<List<Task>> getCurrentTasks() async {
    final db = await _dbHelper.database;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    
    final List<Map<String, dynamic>> maps = await db.query(
      Tables.tasks,
      where: '${Tables.taskDueDate} >= ? AND ${Tables.taskDueDate} < ? AND ${Tables.taskIsCompleted} = ?',
      whereArgs: [today.toIso8601String(), tomorrow.toIso8601String(), 0],
      orderBy: '${Tables.taskDueDate} ASC',
    );
    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  // Get upcoming tasks (next 10 days, not completed)
  Future<List<Task>> getUpcomingTasks({int days = 10}) async {
    final db = await _dbHelper.database;
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));
    final futureDate = now.add(Duration(days: days + 1));
    
    final List<Map<String, dynamic>> maps = await db.query(
      Tables.tasks,
      where: '${Tables.taskDueDate} >= ? AND ${Tables.taskDueDate} < ? AND ${Tables.taskIsCompleted} = ?',
      whereArgs: [tomorrow.toIso8601String(), futureDate.toIso8601String(), 0],
      orderBy: '${Tables.taskDueDate} ASC',
    );
    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  // Get tasks by member
  Future<List<Task>> getTasksByMember(int memberId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      Tables.tasks,
      where: '${Tables.taskMemberId} = ?',
      whereArgs: [memberId],
      orderBy: '${Tables.taskDueDate} ASC',
    );
    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  // Get task by ID
  Future<Task?> getTaskById(int id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      Tables.tasks,
      where: '${Tables.taskId} = ?',
      whereArgs: [id],
    );
    
    if (maps.isEmpty) return null;
    return Task.fromMap(maps.first);
  }

  // Insert task
  Future<int> insertTask(Task task) async {
    final db = await _dbHelper.database;
    return await db.insert(Tables.tasks, task.toMap());
  }

  // Update task
  Future<bool> updateTask(Task task) async {
    try {
      final db = await _dbHelper.database;
      final count = await db.update(
        Tables.tasks,
        task.toMap(),
        where: '${Tables.taskId} = ?',
        whereArgs: [task.id],
      );
      return count > 0;
    } catch (e) {
      print('Error updating task: $e');
      return false;
    }
  }

  // Toggle task completion
  Future<bool> toggleTaskCompletion(int taskId, bool isCompleted) async {
    try {
      final db = await _dbHelper.database;
      final count = await db.update(
        Tables.tasks,
        {
          Tables.taskIsCompleted: isCompleted ? 1 : 0,
          Tables.taskIsNotificationEnabled: isCompleted ? 0 : 1,
        },
        where: '${Tables.taskId} = ?',
        whereArgs: [taskId],
      );
      return count > 0;
    } catch (e) {
      print('Error toggling task completion: $e');
      return false;
    }
  }

  // Delete task
  Future<bool> deleteTask(int id) async {
    try {
      final db = await _dbHelper.database;
      final count = await db.delete(
        Tables.tasks,
        where: '${Tables.taskId} = ?',
        whereArgs: [id],
      );
      return count > 0;
    } catch (e) {
      print('Error deleting task: $e');
      return false;
    }
  }

  // Get task count
  Future<int> getTaskCount() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM ${Tables.tasks}');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
