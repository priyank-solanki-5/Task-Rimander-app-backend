import 'package:flutter/material.dart';
import 'core/services/auth_api_service.dart';
import 'core/services/task_api_service.dart';
import 'core/services/category_api_service.dart';
import 'core/models/task.dart';
import 'core/services/token_storage.dart';

/// Example usage of the new API services
/// This file demonstrates how to use the API services in your app
class ApiUsageExample {
  final AuthApiService _authService = AuthApiService();
  final TaskApiService _taskService = TaskApiService();
  final CategoryApiService _categoryService = CategoryApiService();

  /// Example: Complete user registration and login flow
  Future<void> exampleAuthFlow() async {
    // 1. Register a new user
    final registerResult = await _authService.register(
      username: 'John Doe',
      email: 'john@example.com',
      mobilenumber: '1234567890',
      password: 'securePassword123',
    );

    if (registerResult['success']) {
      debugPrint('✅ Registration successful: ${registerResult['message']}');

      // 2. Login with the registered user
      final loginResult = await _authService.login(
        email: 'john@example.com',
        password: 'securePassword123',
      );

      if (loginResult['success']) {
        debugPrint('✅ Login successful');
        debugPrint('Token: ${loginResult['token']}');
        debugPrint('User: ${loginResult['user']}');

        // Token is automatically saved in secure storage
        // All subsequent API calls will include the token automatically
      } else {
        debugPrint('❌ Login failed: ${loginResult['message']}');
      }
    } else {
      debugPrint('❌ Registration failed: ${registerResult['message']}');
    }
  }

  /// Example: Working with tasks
  Future<void> exampleTaskOperations() async {
    // Ensure user is logged in first
    final isAuth = await TokenStorage.isAuthenticated();
    if (!isAuth) {
      debugPrint('❌ User not authenticated. Please login first.');
      return;
    }

    final userId = await TokenStorage.getUserId();
    if (userId == null) {
      debugPrint('❌ User ID not found');
      return;
    }

    // 1. Get all categories first
    final categories = await _categoryService.getAllCategories();
    debugPrint('📁 Found ${categories.length} categories');

    // 2. Create a new task
    final newTask = Task(
      title: 'Renew Passport',
      description: 'Passport expires next month',
      userId: userId,
      dueDate: DateTime.now().add(const Duration(days: 30)),
      status: TaskStatus.pending,
      isRecurring: false,
      categoryId: categories.isNotEmpty ? categories.first.id : null,
    );

    final createdTask = await _taskService.createTask(newTask);
    if (createdTask != null) {
      debugPrint('✅ Task created: ${createdTask.title}');

      // 3. Get all tasks
      final allTasks = await _taskService.getAllTasks();
      debugPrint('📋 Total tasks: ${allTasks.length}');

      // 4. Update the task
      final updatedTask = createdTask.copyWith(
        description: 'Updated description - Don\'t forget documents!',
      );
      final result = await _taskService.updateTask(
        createdTask.id!,
        updatedTask,
      );
      if (result != null) {
        debugPrint('✅ Task updated successfully');
      }

      // 5. Mark task as complete
      final completedTask = await _taskService.markTaskComplete(createdTask.id!);
      if (completedTask != null) {
        debugPrint('✅ Task marked as complete');
      }

      // 6. Get upcoming tasks
      final upcomingTasks = await _taskService.getUpcomingTasks(days: 7);
      debugPrint('📅 Upcoming tasks (next 7 days): ${upcomingTasks.length}');

      // 7. Search tasks
      final searchResults = await _taskService.searchTasks('passport');
      debugPrint('🔍 Search results for "passport": ${searchResults.length}');

      // 8. Delete the task
      final deleted = await _taskService.deleteTask(createdTask.id!);
      if (deleted) {
        debugPrint('✅ Task deleted successfully');
      }
    } else {
      debugPrint('❌ Failed to create task');
    }
  }

  /// Example: Working with categories
  Future<void> exampleCategoryOperations() async {
    // 1. Get all categories
    final allCategories = await _categoryService.getAllCategories();
    debugPrint('📁 All categories: ${allCategories.length}');

    // 2. Get only predefined categories
    final predefinedCategories =
        await _categoryService.getPredefinedCategories();
    debugPrint('📁 Predefined categories: ${predefinedCategories.length}');

    // 3. Create a custom category
    final userId = await TokenStorage.getUserId();
    if (userId != null) {
      // Note: Category model needs userId for custom categories
      // The backend will automatically set it from the authenticated user
    }
  }

  /// Example: Error handling
  Future<void> exampleErrorHandling() async {
    try {
      // Attempt to login with wrong credentials
      final result = await _authService.login(
        email: 'wrong@example.com',
        password: 'wrongpassword',
      );

      if (!result['success']) {
        // Handle error gracefully
        final errorMessage = result['message'] ?? 'Unknown error';
        debugPrint('❌ Error: $errorMessage');

        // Show error to user
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text(errorMessage)),
        // );
      }
    } catch (e) {
      debugPrint('❌ Unexpected error: $e');
    }
  }

  /// Example: Logout
  Future<void> exampleLogout() async {
    await _authService.logout();
    debugPrint('✅ User logged out');

    // Verify logout
    final isAuth = await TokenStorage.isAuthenticated();
    debugPrint('Is authenticated: $isAuth'); // Should be false
  }
}

/// Widget example showing how to use API services in a StatefulWidget
class ExampleTaskScreen extends StatefulWidget {
  const ExampleTaskScreen({Key? key}) : super(key: key);

  @override
  State<ExampleTaskScreen> createState() => _ExampleTaskScreenState();
}

class _ExampleTaskScreenState extends State<ExampleTaskScreen> {
  final TaskApiService _taskService = TaskApiService();
  List<Task> _tasks = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final tasks = await _taskService.getAllTasks();
      setState(() {
        _tasks = tasks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load tasks: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleTaskStatus(Task task) async {
    final updatedTask = task.isCompleted
        ? await _taskService.markTaskPending(task.id!)
        : await _taskService.markTaskComplete(task.id!);

    if (updatedTask != null) {
      // Reload tasks to reflect changes
      await _loadTasks();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update task')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTasks,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadTasks,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_tasks.isEmpty) {
      return const Center(child: Text('No tasks found'));
    }

    return ListView.builder(
      itemCount: _tasks.length,
      itemBuilder: (context, index) {
        final task = _tasks[index];
        return ListTile(
          title: Text(task.title),
          subtitle: Text(task.description ?? ''),
          trailing: Checkbox(
            value: task.isCompleted,
            onChanged: (_) => _toggleTaskStatus(task),
          ),
        );
      },
    );
  }
}
