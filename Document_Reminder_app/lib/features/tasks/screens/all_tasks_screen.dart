import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/task_provider.dart';
import '../../dashboard/widgets/task_section.dart';

class AllTasksScreen extends StatelessWidget {
  const AllTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('All Tasks')),
      body: SafeArea(
        child: Consumer<TaskProvider>(
          builder: (context, taskProvider, child) {
            if (taskProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (taskProvider.tasks.isEmpty) {
              return Center(
                child: Text(
                  'No tasks available',
                  style: theme.textTheme.titleMedium,
                ),
              );
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TaskSection(
                  title: 'Due',
                  tasks: taskProvider.dueTasks,
                  memberNames: {
                    for (var task in taskProvider.tasks)
                      task.memberId ?? '': task.memberId ?? 'Unknown',
                  },
                  onTaskToggle: (taskId, isCompleted) {
                    taskProvider.toggleTaskCompletion(taskId, isCompleted);
                  },
                  titleColor: theme.colorScheme.error,
                  titleIcon: Icons.warning_amber_rounded,
                ),
                const SizedBox(height: 12),
                TaskSection(
                  title: 'Today',
                  tasks: taskProvider.currentTasks,
                  memberNames: {
                    for (var task in taskProvider.tasks)
                      task.memberId ?? '': task.memberId ?? 'Unknown',
                  },
                  onTaskToggle: (taskId, isCompleted) {
                    taskProvider.toggleTaskCompletion(taskId, isCompleted);
                  },
                  titleColor: theme.colorScheme.primary,
                  titleIcon: Icons.today_outlined,
                ),
                const SizedBox(height: 12),
                TaskSection(
                  title: 'Upcoming',
                  tasks: taskProvider.upcomingTasks,
                  memberNames: {
                    for (var task in taskProvider.tasks)
                      task.memberId ?? '': task.memberId ?? 'Unknown',
                  },
                  onTaskToggle: (taskId, isCompleted) {
                    taskProvider.toggleTaskCompletion(taskId, isCompleted);
                  },
                  titleColor: theme.colorScheme.secondary,
                  titleIcon: Icons.upcoming_outlined,
                ),
                const SizedBox(height: 12),
                TaskSection(
                  title: 'Completed',
                  tasks: taskProvider.completedTasks,
                  memberNames: {
                    for (var task in taskProvider.tasks)
                      task.memberId ?? '': task.memberId ?? 'Unknown',
                  },
                  onTaskToggle: (taskId, isCompleted) {
                    taskProvider.toggleTaskCompletion(taskId, isCompleted);
                  },
                  titleColor: theme.colorScheme.tertiary,
                  titleIcon: Icons.check_circle_outline,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
