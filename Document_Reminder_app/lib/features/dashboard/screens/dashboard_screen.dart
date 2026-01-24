import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
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

  void _handleTaskToggle(
    BuildContext context,
    TaskProvider provider,
    String taskId,
    bool isCompleted,
  ) {
    HapticFeedback.lightImpact();
    provider.toggleTaskCompletion(taskId, isCompleted);

    if (isCompleted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Task completed'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          action: SnackBarAction(
            label: 'UNDO',
            onPressed: () {
              HapticFeedback.lightImpact();
              provider.toggleTaskCompletion(taskId, !isCompleted);
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Tasks',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return IconButton(
                icon: Icon(
                  themeProvider.isDarkMode
                      ? Icons.light_mode_rounded
                      : Icons.dark_mode_rounded,
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
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => context.read<TaskProvider>().refreshTasks(),
          child: Consumer<TaskProvider>(
            builder: (context, taskProvider, child) {
              if (taskProvider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // Header with profile photo
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  DateFormat(
                                    'EEEE, MMM d',
                                  ).format(today).toUpperCase(),
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Welcome back!',
                                  style: theme.textTheme.headlineMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.onSurface,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'You have ${taskProvider.dueTasks.length + taskProvider.currentTasks.length} tasks for today',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: theme.colorScheme.primary.withValues(
                                  alpha: 0.2,
                                ),
                                width: 2,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 24,
                              backgroundColor:
                                  theme.colorScheme.surfaceContainerHighest,
                              child: Icon(
                                Icons.person_rounded,
                                color: theme.colorScheme.primary,
                                size: 28,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Due Tasks Section (Conditional)
                  if (taskProvider.dueTasks.isNotEmpty)
                    SliverToBoxAdapter(
                      child: TaskSection(
                        title: 'Due Tasks',
                        tasks: taskProvider.dueTasks,
                        memberNames: {
                          for (var task in taskProvider.tasks)
                            task.memberId ?? '': task.memberId ?? 'Unknown',
                        },
                        onTaskToggle: (taskId, isCompleted) {
                          _handleTaskToggle(
                            context,
                            taskProvider,
                            taskId,
                            isCompleted,
                          );
                        },
                        titleColor: theme.colorScheme.error,
                        titleIcon: Icons.warning_amber_rounded,
                      ),
                    ),

                  // Current Tasks Section (Conditional)
                  if (taskProvider.currentTasks.isNotEmpty)
                    SliverToBoxAdapter(
                      child: TaskSection(
                        title: 'Today',
                        tasks: taskProvider.currentTasks,
                        memberNames: {
                          for (var task in taskProvider.tasks)
                            task.memberId ?? '': task.memberId ?? 'Unknown',
                        },
                        onTaskToggle: (taskId, isCompleted) {
                          taskProvider.toggleTaskCompletion(
                            taskId,
                            isCompleted,
                          );
                        },
                        titleColor: theme.colorScheme.primary,
                        titleIcon: Icons.today_outlined,
                      ),
                    ),

                  // Upcoming Tasks Section (Conditional)
                  if (taskProvider.upcomingTasks.isNotEmpty)
                    SliverToBoxAdapter(
                      child: TaskSection(
                        title: 'Upcoming',
                        tasks: taskProvider.upcomingTasks,
                        memberNames: {
                          for (var task in taskProvider.tasks)
                            task.memberId ?? '': task.memberId ?? 'Unknown',
                        },
                        onTaskToggle: (taskId, isCompleted) {
                          taskProvider.toggleTaskCompletion(
                            taskId,
                            isCompleted,
                          );
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
                        child: Center(
                          child: TextButton.icon(
                            onPressed: () {
                              taskProvider.toggleShowAllUpcoming();
                            },
                            icon: const Icon(Icons.keyboard_arrow_down_rounded),
                            label: const Text('Show All Upcoming Tasks'),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Empty state
                  if (taskProvider.dueTasks.isEmpty &&
                      taskProvider.currentTasks.isEmpty &&
                      taskProvider.upcomingTasks.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withValues(
                                    alpha: 0.1,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.task_alt_rounded,
                                  size: 64,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'No tasks yet',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'You\'re all caught up! Create a new task to get started.',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.6,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),
                              FilledButton.icon(
                                onPressed: () async {
                                  final taskProvider = context
                                      .read<TaskProvider>();
                                  final result = await Navigator.push<bool>(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const AddEditTaskScreen(),
                                    ),
                                  );
                                  if (!context.mounted) return;
                                  if (result == true) {
                                    taskProvider.refreshTasks();
                                  }
                                },
                                icon: const Icon(Icons.add),
                                label: const Text('Create New Task'),
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 32,
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                            ],
                          ),
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
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final taskProvider = context.read<TaskProvider>();
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const AddEditTaskScreen()),
          );
          if (!mounted) return;
          if (result == true) {
            taskProvider.refreshTasks();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
      ),
    );
  }
}
