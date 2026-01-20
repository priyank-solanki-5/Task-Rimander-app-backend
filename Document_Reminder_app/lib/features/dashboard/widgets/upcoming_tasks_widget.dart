import 'package:flutter/material.dart';
import '../../../core/constants/dummy_data.dart';
import '../widgets/task_card_widget.dart';

class UpcomingTasksWidget extends StatelessWidget {
  const UpcomingTasksWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final upcomingTasks = DummyData.tasks.where((task) => task.isUpcoming).toList();

    if (upcomingTasks.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Upcoming Tasks',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: upcomingTasks.length,
          itemBuilder: (context, index) {
            return TaskCardWidget(task: upcomingTasks[index]);
          },
        ),
      ],
    );
  }
}
