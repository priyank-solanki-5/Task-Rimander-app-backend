import 'package:flutter/material.dart';
import '../../../core/constants/dummy_data.dart';
import '../widgets/task_card_widget.dart';

class DueTasksWidget extends StatelessWidget {
  const DueTasksWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final dueTasks = DummyData.tasks.where((task) => task.isDue).toList();

    if (dueTasks.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444)),
              const SizedBox(width: 8),
              Text(
                'Due Tasks',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: dueTasks.length,
          itemBuilder: (context, index) {
            return TaskCardWidget(task: dueTasks[index], isDue: true);
          },
        ),
      ],
    );
  }
}
