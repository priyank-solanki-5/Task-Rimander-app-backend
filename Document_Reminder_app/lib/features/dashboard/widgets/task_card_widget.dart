import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../app/routes.dart';
import '../../../core/constants/dummy_data.dart';

class TaskCardWidget extends StatelessWidget {
  final Task task;
  final bool isDue;

  const TaskCardWidget({
    super.key,
    required this.task,
    this.isDue = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isDue ? const Color(0xFFFEE2E2) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDue ? const Color(0xFFEF4444) : Colors.transparent,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.taskDetail,
            arguments: task,
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      task.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  if (isDue)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'OVERDUE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.person_outline, size: 16, color: Color(0xFF64748B)),
                  const SizedBox(width: 4),
                  Text(
                    task.memberName,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.description_outlined, size: 16, color: Color(0xFF64748B)),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      task.documentType,
                      style: Theme.of(context).textTheme.bodyMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: isDue ? const Color(0xFFEF4444) : const Color(0xFF64748B),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Due: ${DateFormat('MMM dd, yyyy').format(task.dueDate)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isDue ? const Color(0xFFEF4444) : null,
                          fontWeight: isDue ? FontWeight.w600 : null,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
