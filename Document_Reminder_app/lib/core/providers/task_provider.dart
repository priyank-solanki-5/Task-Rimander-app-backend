import 'package:flutter/foundation.dart';
import '../models/task.dart';
import '../models/member.dart';
import '../repositories/task_repository.dart';
import '../repositories/member_repository.dart';

class TaskProvider extends ChangeNotifier {
  final TaskRepository _taskRepository = TaskRepository();
  final MemberRepository _memberRepository = MemberRepository();

  List<Task> _tasks = [];
  Map<int, Member> _membersCache = {};
  bool _isLoading = false;
  bool _showAllUpcoming = false;

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  bool get showAllUpcoming => _showAllUpcoming;

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

  // Get member name by ID from cache
  String getMemberName(int memberId) {
    return _membersCache[memberId]?.name ?? 'Unknown';
  }

  // Toggle show all upcoming tasks
  void toggleShowAllUpcoming() {
    _showAllUpcoming = !_showAllUpcoming;
    notifyListeners();
  }

  // Load all tasks
  Future<void> loadTasks() async {
    _isLoading = true;
    notifyListeners();

    try {
      _tasks = await _taskRepository.getAllTasks();

      // Load members for cache
      final members = await _memberRepository.getAllMembers();
      _membersCache = {for (var member in members) member.id!: member};

      debugPrint('Loaded ${_tasks.length} tasks');
    } catch (e) {
      debugPrint('Error loading tasks: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Toggle task completion
  Future<void> toggleTaskCompletion(int taskId, bool isCompleted) async {
    try {
      final success = await _taskRepository.toggleTaskCompletion(
        taskId,
        isCompleted,
      );
      if (success) {
        // Reload all tasks to ensure UI is in sync
        await loadTasks();
        debugPrint('Task completion toggled: $isCompleted');
      }
    } catch (e) {
      debugPrint('Error toggling task completion: $e');
    }
  }

  // Add task
  Future<int?> addTask(Task task) async {
    try {
      final id = await _taskRepository.insertTask(task);
      // Reload all tasks to get the fresh data
      await loadTasks();
      debugPrint('Task added successfully with ID: $id');
      return id;
    } catch (e) {
      debugPrint('Error adding task: $e');
      return null;
    }
  }

  Future<bool> updateTask(Task task) async {
    try {
      final success = await _taskRepository.updateTask(task);
      if (success) {
        // Reload all tasks to get the fresh data
        await loadTasks();
        debugPrint('Task updated successfully');
      }
      return success;
    } catch (e) {
      debugPrint('Error updating task: $e');
      return false;
    }
  }

  Future<bool> deleteTask(int id) async {
    try {
      final success = await _taskRepository.deleteTask(id);
      if (success) {
        // Reload all tasks
        await loadTasks();
        debugPrint('Task deleted successfully');
      }
      return success;
    } catch (e) {
      debugPrint('Error deleting task: $e');
      return false;
    }
  }

  // Refresh tasks
  Future<void> refreshTasks() async {
    await loadTasks();
  }
}
