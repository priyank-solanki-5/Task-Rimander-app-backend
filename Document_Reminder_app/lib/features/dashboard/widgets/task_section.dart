import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../core/models/task.dart';
import '../screens/add_edit_task_screen.dart';
import 'task_card.dart';

class TaskSection extends StatelessWidget {
  final String title;
  final List<Task> tasks;
  final Function(String, bool) onTaskToggle;
  final Color? titleColor;
  final IconData? titleIcon;
  final Map<String, String>? memberNames;

  const TaskSection({
    super.key,
    required this.title,
    required this.tasks,
    required this.onTaskToggle,
    this.titleColor,
    this.titleIcon,
    this.memberNames,
  });

  @override
  Widget build(BuildContext context) {
    // Don't show section if no tasks
    if (tasks.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              if (titleIcon != null) ...[
                Icon(
                  titleIcon,
                  size: 20,
                  color: titleColor ?? theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
              ],
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: titleColor ?? theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: (titleColor ?? theme.colorScheme.primary).withValues(
                    alpha: 0.1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${tasks.length}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: titleColor ?? theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Task list with entrance animations
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];

            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 375),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: TaskCard(
                    task: task,
                    memberName: memberNames?[task.userId],
                    onCheckboxChanged: (value) {
                      if (value != null) {
                        onTaskToggle(task.id!, value);
                      }
                    },
                    onTap: () async {
                      // Navigate to edit task screen
                      final result = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddEditTaskScreen(task: task),
                        ),
                      );
                      if (result == true && context.mounted) {
                        // Refresh task list
                        onTaskToggle(task.id!, task.isCompleted);
                      }
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
