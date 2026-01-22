import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/task_provider.dart';
import '../../../core/providers/theme_provider.dart';
import '../widgets/task_section.dart';
import 'add_edit_task_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Load tasks when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().loadTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        actions: [
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return IconButton(
                icon: Icon(
                  themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                ),
                onPressed: () {
                  themeProvider.toggleTheme();
                },
                tooltip: themeProvider.isDarkMode
                    ? 'Switch to Light Mode'
                    : 'Switch to Dark Mode',
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<TaskProvider>().refreshTasks(),
        child: Consumer<TaskProvider>(
          builder: (context, taskProvider, child) {
            if (taskProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return CustomScrollView(
              slivers: [
                // Header with profile photo
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // Profile photo
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: theme.colorScheme.primary,
                          child: Icon(
                            Icons.person,
                            color: theme.colorScheme.onPrimary,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome back!',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Stay organized and on track',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.6,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Due Tasks Section (Conditional)
                SliverToBoxAdapter(
                  child: TaskSection(
                    title: 'Due Tasks',
                    tasks: taskProvider.dueTasks,
                    onTaskToggle: (taskId, isCompleted) {
                      taskProvider.toggleTaskCompletion(taskId, isCompleted);
                    },
                    titleColor: theme.colorScheme.error,
                    titleIcon: Icons.warning_amber_rounded,
                  ),
                ),

                // Current Tasks Section (Conditional)
                SliverToBoxAdapter(
                  child: TaskSection(
                    title: 'Today',
                    tasks: taskProvider.currentTasks,
                    onTaskToggle: (taskId, isCompleted) {
                      taskProvider.toggleTaskCompletion(taskId, isCompleted);
                    },
                    titleColor: theme.colorScheme.primary,
                    titleIcon: Icons.today_outlined,
                  ),
                ),

                // Upcoming Tasks Section (Conditional)
                SliverToBoxAdapter(
                  child: TaskSection(
                    title: 'Upcoming',
                    tasks: taskProvider.upcomingTasks,
                    onTaskToggle: (taskId, isCompleted) {
                      taskProvider.toggleTaskCompletion(taskId, isCompleted);
                    },
                    titleColor: theme.colorScheme.secondary,
                    titleIcon: Icons.upcoming_outlined,
                  ),
                ),

                // Show All button (only if there are more upcoming tasks)
                if (taskProvider.upcomingTasks.isNotEmpty &&
                    !taskProvider.showAllUpcoming)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: OutlinedButton(
                        onPressed: () {
                          taskProvider.toggleShowAllUpcoming();
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Show All Upcoming Tasks'),
                      ),
                    ),
                  ),

                // Empty state
                if (taskProvider.dueTasks.isEmpty &&
                    taskProvider.currentTasks.isEmpty &&
                    taskProvider.upcomingTasks.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.task_alt,
                            size: 64,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.3,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No tasks yet',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'All caught up! 🎉',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Bottom padding
                const SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (context) => const AddEditTaskScreen()),
          );
          if (!context.mounted) return;
          if (result == true) {
            context.read<TaskProvider>().refreshTasks();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
      ),
    );
  }
}
