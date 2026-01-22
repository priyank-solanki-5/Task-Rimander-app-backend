import 'package:flutter/foundation.dart';
import '../models/task.dart';
import '../services/task_service.dart';
import '../services/token_storage.dart';

class TaskProvider extends ChangeNotifier {
  final TaskService _taskService = TaskService();

  List<Task> _tasks = [];
  bool _isLoading = false;
  bool _showAllUpcoming = false;
  String? _errorMessage;

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  bool get showAllUpcoming => _showAllUpcoming;
  String? get errorMessage => _errorMessage;

  // Filtered task lists
  List<Task> get dueTasks {
    return _tasks.where((task) => task.isOverdue).toList();
  }

  List<Task> get currentTasks {
    return _tasks.where((task) => task.isDueToday).toList();
  }

  List<Task> get upcomingTasks {
    final upcoming = _tasks.where((task) => task.isUpcoming).toList();
    if (_showAllUpcoming) {
      return upcoming;
    }
    return upcoming.take(5).toList();
  }

  List<Task> get completedTasks {
    return _tasks.where((task) => task.isCompleted).toList();
  }

  List<Task> get pendingTasks {
    return _tasks.where((task) => !task.isCompleted).toList();
  }

  // Toggle show all upcoming tasks
  void toggleShowAllUpcoming() {
    _showAllUpcoming = !_showAllUpcoming;
    notifyListeners();
  }

  // Load all tasks from API
  Future<void> loadTasks() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _tasks = await _taskService.getAllTasks();
      debugPrint('✅ Loaded ${_tasks.length} tasks from local DB');
    } catch (e) {
      _errorMessage = 'Failed to load tasks: $e';
      debugPrint('❌ Error loading tasks: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Toggle task completion
  Future<bool> toggleTaskCompletion(String taskId, bool isCompleted) async {
    try {
      final updatedTask = isCompleted
          ? await _taskService.markTaskComplete(taskId)
          : await _taskService.markTaskPending(taskId);

      if (updatedTask != null) {
        // Update local list
        final index = _tasks.indexWhere((t) => t.id == taskId);
        if (index != -1) {
          _tasks[index] = updatedTask;
          notifyListeners();
        }
        debugPrint('✅ Task completion toggled: $isCompleted');
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = 'Failed to update task: $e';
      debugPrint('❌ Error toggling task completion: $e');
      return false;
    }
  }

  // Add task
  Future<Task?> addTask(Task task) async {
    try {
      final createdTask = await _taskService.createTask(task);
      if (createdTask != null) {
        _tasks.add(createdTask);
        notifyListeners();
        debugPrint('✅ Task added successfully: ${createdTask.id}');
        return createdTask;
      }
      return null;
    } catch (e) {
      _errorMessage = 'Failed to add task: $e';
      debugPrint('❌ Error adding task: $e');
      return null;
    }
  }

  // Update task
  Future<bool> updateTask(Task task) async {
    try {
      final updatedTask = await _taskService.updateTask(task.id!, task);
      if (updatedTask != null) {
        final index = _tasks.indexWhere((t) => t.id == task.id);
        if (index != -1) {
          _tasks[index] = updatedTask;
          notifyListeners();
        }
        debugPrint('✅ Task updated successfully');
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = 'Failed to update task: $e';
      debugPrint('❌ Error updating task: $e');
      return false;
    }
  }

  // Delete task
  Future<bool> deleteTask(String id) async {
    try {
      final success = await _taskService.deleteTask(id);
      if (success) {
        _tasks.removeWhere((t) => t.id == id);
        notifyListeners();
        debugPrint('✅ Task deleted successfully');
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = 'Failed to delete task: $e';
      debugPrint('❌ Error deleting task: $e');
      return false;
    }
  }

  // Search tasks
  Future<void> searchTasks(String query) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _tasks = await _taskService.searchTasks(query);
      debugPrint('✅ Search completed: ${_tasks.length} results');
    } catch (e) {
      _errorMessage = 'Search failed: $e';
      debugPrint('❌ Error searching tasks: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Filter tasks
  Future<void> filterTasks({
    String? status,
    String? categoryId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _tasks = await _taskService.filterTasks(
        status: status != null ? (status == 'Completed' ? TaskStatus.completed : TaskStatus.pending) : null, // Convert string to enum if needed, or update filterTasks to accept enum
        categoryId: categoryId,
        // startDate: startDate, // TaskService filterTasks might need update for date range or we pass date
        // endDate: endDate,
        date: startDate, // Mapping startDate to date for simple check? Or update TaskService?
      );
      debugPrint('✅ Filter completed: ${_tasks.length} results');
    } catch (e) {
      _errorMessage = 'Filter failed: $e';
      debugPrint('❌ Error filtering tasks: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get overdue tasks
  Future<void> loadOverdueTasks() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _tasks = await _taskService.getOverdueTasks();
      debugPrint('✅ Loaded ${_tasks.length} overdue tasks');
    } catch (e) {
      _errorMessage = 'Failed to load overdue tasks: $e';
      debugPrint('❌ Error loading overdue tasks: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get upcoming tasks
  Future<void> loadUpcomingTasks({int days = 7}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _tasks = await _taskService.getUpcomingTasks(days: days);
      debugPrint('✅ Loaded ${_tasks.length} upcoming tasks');
    } catch (e) {
      _errorMessage = 'Failed to load upcoming tasks: $e';
      debugPrint('❌ Error loading upcoming tasks: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Refresh tasks
  Future<void> refreshTasks() async {
    await loadTasks();
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
