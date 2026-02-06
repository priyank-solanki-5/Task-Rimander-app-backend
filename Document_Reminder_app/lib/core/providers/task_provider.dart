import 'package:flutter/foundation.dart';
import '../models/task.dart';
import '../services/task_api_service.dart';
import '../../services/local_notification_service.dart';

class TaskProvider extends ChangeNotifier {
  final TaskApiService _taskApiService = TaskApiService();

  List<Task> _tasks = [];
  bool _isLoading = false;
  bool _showAllUpcoming = false;
  String? _errorMessage;
  String? _selectedTaskId;

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  bool get showAllUpcoming => _showAllUpcoming;
  String? get errorMessage => _errorMessage;
  String? get selectedTaskId => _selectedTaskId;

  void setSelectedTaskId(String? taskId) {
    _selectedTaskId = taskId;
    notifyListeners();
  }

  // Filtered task lists
  List<Task> get dueTasks {
    final due = _tasks.where((task) => task.isOverdue).toList();
    due.sort((a, b) => a.dueDate!.compareTo(b.dueDate!));
    return due;
  }

  List<Task> get currentTasks {
    final current = _tasks.where((task) => task.isDueToday).toList();
    current.sort((a, b) => a.dueDate!.compareTo(b.dueDate!));
    return current;
  }

  List<Task> get upcomingTasks {
    final upcoming = _tasks.where((task) => task.isUpcoming).toList();
    upcoming.sort((a, b) {
      if (a.dueDate == null && b.dueDate == null) return 0;
      if (a.dueDate == null) return 1;
      if (b.dueDate == null) return -1;
      return a.dueDate!.compareTo(b.dueDate!);
    });

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
  Future<void> loadTasks({bool forceRefresh = false}) async {
    if (_tasks.isNotEmpty && !forceRefresh) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _tasks = await _taskApiService.getAllTasks();
      debugPrint('✅ Loaded ${_tasks.length} tasks from API');
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
      // Optimistic update
      final index = _tasks.indexWhere((t) => t.id == taskId);
      if (index != -1) {
        final originalTask = _tasks[index];
        _tasks[index] = originalTask.copyWith(
          status: isCompleted ? TaskStatus.completed : TaskStatus.pending,
        );
        notifyListeners();

        try {
          final updatedTask = isCompleted
              ? await _taskApiService.markTaskComplete(taskId)
              : await _taskApiService.markTaskPending(taskId);

          // Update with server data to be sure
          _tasks[index] = updatedTask;

          // Handle notifications
          if (isCompleted) {
            await _cancelNotifications(taskId);
          } else {
            // Reschedule if pending
            await _scheduleNotifications(updatedTask);
          }

          notifyListeners();
          debugPrint('✅ Task completion toggled on server: $isCompleted');
          return true;
        } catch (e) {
          // Revert optimistic update on failure
          _tasks[index] = originalTask;
          notifyListeners();
          rethrow;
        }
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
      final createdTask = await _taskApiService.createTask(task);
      _tasks.add(createdTask);

      // Schedule notifications
      await _scheduleNotifications(createdTask);

      notifyListeners();
      debugPrint('✅ Task added successfully: ${createdTask.id}');
      return createdTask;
    } catch (e) {
      _errorMessage = 'Failed to add task: $e';
      debugPrint('❌ Error adding task: $e');
      return null;
    }
  }

  // Update task
  Future<bool> updateTask(Task task) async {
    try {
      if (task.id == null) return false;
      final updatedTask = await _taskApiService.updateTask(task.id!, task);
      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _tasks[index] = updatedTask;

        // Reschedule notifications
        await _cancelNotifications(updatedTask.id!);
        await _scheduleNotifications(updatedTask);

        notifyListeners();
      }
      debugPrint('✅ Task updated successfully');
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update task: $e';
      debugPrint('❌ Error updating task: $e');
      return false;
    }
  }

  // Delete task
  Future<bool> deleteTask(String id) async {
    try {
      final success = await _taskApiService.deleteTask(id);
      if (success) {
        // Cancel notification
        await _cancelNotifications(id);

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
      _tasks = await _taskApiService.searchTasks(query);
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
      _tasks = await _taskApiService.filterTasks(
        status: status,
        categoryId: categoryId,
        startDate: startDate,
        endDate: endDate,
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
      _tasks = await _taskApiService.getOverdueTasks();
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
      _tasks = await _taskApiService.getUpcomingTasks(days: days);
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

  // Helper to schedule multiple notifications
  Future<void> _scheduleNotifications(Task task) async {
    if (task.dueDate == null || task.id == null || task.isCompleted) return;

    debugPrint('🔔 Scheduling notifications for task: ${task.title} (Due: ${task.dueDate})');

    // Show instant notification for new task
    if (task.status == TaskStatus.pending) {
      debugPrint('  - Showing instant notification for new task');
      await LocalNotificationService().showInstantNotification(
        title: 'Task Created',
        body: 'New task "${task.title}" has been added successfully',
        payload: 'task_${task.id}',
      );
    }

    // Schedule reminders for 5,4,3,2,1 minutes before due
    final minutes = [5, 4, 3, 2, 1];
    int scheduledCount = 0;
    
    for (final min in minutes) {
      final scheduledTime = task.dueDate!.subtract(Duration(minutes: min));
      final currentTime = DateTime.now();
      
      // Only schedule if: reminder time is in: future
      if (scheduledTime.isAfter(currentTime)) {
        debugPrint('  - Scheduling $min min reminder at $scheduledTime');
        try {
          await LocalNotificationService().scheduleNotification(
            id: (task.id! + '_$min').hashCode,
            title: 'Task Due Soon',
            body: 'Your task "${task.title}" is due in $min minutes',
            scheduledTime: scheduledTime,
            payload: 'task_${task.id}_reminder_$min',
          );
          scheduledCount++;
        } catch (e) {
          debugPrint('  - ❌ Failed to schedule $min min reminder: $e');
        }
      } else {
        debugPrint('  - Skipping $min min reminder (time passed: $scheduledTime, now: $currentTime)');
      }
    }
    
    // Schedule due time notification
    final currentTime = DateTime.now();
    if (task.dueDate!.isAfter(currentTime)) {
      debugPrint('  - Scheduling due time notification at ${task.dueDate}');
      try {
        await LocalNotificationService().scheduleNotification(
          id: (task.id! + '_due').hashCode,
          title: 'Task Due Now!',
          body: 'Your task "${task.title}" is due now!',
          scheduledTime: task.dueDate!,
          payload: 'task_${task.id}_due',
        );
        scheduledCount++;
      } catch (e) {
        debugPrint('  - ❌ Failed to schedule due time notification: $e');
      }
      
      // Schedule 2 additional notifications after due time
      for (int i = 1; i <= 2; i++) {
        final afterDueTime = task.dueDate!.add(Duration(minutes: i));
        debugPrint('  - Scheduling +$i min notification at $afterDueTime');
        try {
          await LocalNotificationService().scheduleNotification(
            id: (task.id! + '_after_$i').hashCode,
            title: 'Task Overdue',
            body: 'Your task "${task.title}" was due $i minute${i > 1 ? 's' : ''} ago!',
            scheduledTime: afterDueTime,
            payload: 'task_${task.id}_after_$i',
          );
          scheduledCount++;
        } catch (e) {
          debugPrint('  - ❌ Failed to schedule +$i min notification: $e');
        }
      }
    }
    
    debugPrint('✅ Scheduled $scheduledCount reminders for task: ${task.title}');
    
    // Debug: Show all pending notifications
    await LocalNotificationService().debugPendingNotifications();
  }

  // Helper to cancel all notifications for a task
  Future<void> _cancelNotifications(String taskId) async {
    // Cancel task creation notification
    await LocalNotificationService().cancelNotification(taskId.hashCode);
    
    // Cancel minute-based reminders
    final minutes = [5, 4, 3, 2, 1];
    for (final min in minutes) {
      await LocalNotificationService().cancelNotification(
        (taskId + '_$min').hashCode
      );
    }
    
    // Cancel due time notification
    await LocalNotificationService().cancelNotification((taskId + '_due').hashCode);
    
    // Cancel overdue notifications
    for (int i = 1; i <= 2; i++) {
      await LocalNotificationService().cancelNotification((taskId + '_after_$i').hashCode);
    }
  }
}
