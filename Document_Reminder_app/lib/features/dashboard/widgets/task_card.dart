import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/models/task.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final Function(bool?) onCheckboxChanged;
  final VoidCallback? onTap;
  final String? memberName;

  const TaskCard({
    super.key,
    required this.task,
    required this.onCheckboxChanged,
    this.onTap,
    this.memberName,
  });

  int get _daysUntilDue {
    if (task.dueDate == null) return 999;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(
      task.dueDate!.year,
      task.dueDate!.month,
      task.dueDate!.day,
    );
    return due.difference(today).inDays;
  }

  Color _getTaskStatusColor(ThemeData theme) {
    if (task.isCompleted) return theme.disabledColor;

    if (task.isOverdue) {
      return theme.colorScheme.error;
    } else if (_daysUntilDue <= 1) {
      return Colors.orange;
    } else {
      return theme.colorScheme.primary;
    }
  }

  String _getTaskStatusLabel() {
    if (task.isCompleted) return 'COMPLETED';

    if (task.isOverdue) {
      return 'OVERDUE';
    } else if (_daysUntilDue == 0) {
      return 'TODAY';
    } else if (_daysUntilDue == 1) {
      return 'TOMORROW';
    } else if (_daysUntilDue < 7) {
      return '$_daysUntilDue DAYS LEFT';
    } else {
      return 'UPCOMING';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOverdue = task.isOverdue && !task.isCompleted;
    final statusColor = _getTaskStatusColor(theme);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 2,
      shadowColor: theme.shadowColor.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isOverdue
            ? BorderSide(
                color: theme.colorScheme.error.withValues(alpha: 0.5),
                width: 1,
              )
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Checkbox
              Transform.scale(
                scale: 1.1,
                child: Checkbox(
                  value: task.isCompleted,
                  onChanged: onCheckboxChanged,
                  shape: const CircleBorder(),
                  activeColor: theme.colorScheme.primary,
                  side: BorderSide(
                    color: isOverdue
                        ? theme.colorScheme.error
                        : theme.unselectedWidgetColor,
                    width: 2,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Task details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      task.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                        color: task.isCompleted
                            ? theme.colorScheme.onSurface.withValues(alpha: 0.5)
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                    if (task.description != null &&
                        task.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        task.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),

                    // Footer Row (Date & Status)
                    Row(
                      children: [
                        // Due Date
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 14,
                          color: isOverdue
                              ? theme.colorScheme.error
                              : theme.colorScheme.onSurface.withValues(
                                  alpha: 0.6,
                                ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          task.dueDate != null
                              ? DateFormat('MMM dd').format(task.dueDate!)
                              : 'No date',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: isOverdue
                                ? theme.colorScheme.error
                                : theme.colorScheme.onSurface.withValues(
                                    alpha: 0.7,
                                  ),
                            fontWeight: isOverdue
                                ? FontWeight.bold
                                : FontWeight.w500,
                          ),
                        ),

                        const Spacer(),

                        // Status Badge
                        if (!task.isCompleted)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: statusColor.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Text(
                              _getTaskStatusLabel(),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),

                        // Recurring Badge
                        if (task.taskType == TaskType.recurring) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.secondary.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.repeat_rounded,
                              size: 14,
                              color: theme.colorScheme.secondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
