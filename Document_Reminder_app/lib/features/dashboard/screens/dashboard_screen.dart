// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:provider/provider.dart';
// import 'package:intl/intl.dart';
// import '../../../core/providers/document_provider.dart';
// import '../../../core/providers/task_provider.dart';
// import '../../../core/providers/theme_provider.dart';
// import '../../../core/services/token_storage.dart';
// import '../../../core/models/document.dart';
// import '../widgets/task_section.dart';
// import 'add_edit_task_screen.dart';
// import '../../documents/screens/documents_screen.dart';
// import '../../tasks/screens/all_tasks_screen.dart';
// import '../../../widgets/double_back_to_exit_wrapper.dart';

// class DashboardScreen extends StatefulWidget {
//   const DashboardScreen({super.key});

//   @override
//   State<DashboardScreen> createState() => _DashboardScreenState();
// }

// class _DashboardScreenState extends State<DashboardScreen> {
//   @override
//   void initState() {
//     super.initState();
//     // Load tasks and documents when screen initializes
//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       final taskProvider = context.read<TaskProvider>();
//       final documentProvider = context.read<DocumentProvider>();

//       taskProvider.loadTasks();

//       final userId = await TokenStorage.getUserId();
//       if (!mounted) return;
//       if (userId != null) {
//         documentProvider.loadDocumentsForUser(userId);
//       } else {
//         documentProvider.loadDocuments();
//       }
//     });
//   }

//   void _handleTaskToggle(
//     BuildContext context,
//     TaskProvider provider,
//     String taskId,
//     bool isCompleted,
//   ) {
//     HapticFeedback.lightImpact();
//     provider.toggleTaskCompletion(taskId, isCompleted);

//     if (isCompleted) {
//       ScaffoldMessenger.of(context).clearSnackBars();
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: const Text('Task completed'),
//           behavior: SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(10),
//           ),
//           action: SnackBarAction(
//             label: 'UNDO',
//             onPressed: () {
//               HapticFeedback.lightImpact();
//               provider.toggleTaskCompletion(taskId, !isCompleted);
//             },
//           ),
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final today = DateTime.now();

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'My Tasks',
//           style: theme.textTheme.titleLarge?.copyWith(
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         centerTitle: false,
//         elevation: 0,
//         backgroundColor: Colors.transparent,
//         actions: [
//           Consumer<ThemeProvider>(
//             builder: (context, themeProvider, child) {
//               return IconButton(
//                 icon: Icon(
//                   themeProvider.isDarkMode
//                       ? Icons.light_mode_rounded
//                       : Icons.dark_mode_rounded,
//                 ),
//                 onPressed: () {
//                   themeProvider.toggleTheme();
//                 },
//                 tooltip: themeProvider.isDarkMode
//                     ? 'Switch to Light Mode'
//                     : 'Switch to Dark Mode',
//               );
//             },
//           ),
//           const SizedBox(width: 8),
//         ],
//       ),
//       body: SafeArea(
//         child: RefreshIndicator(
//           onRefresh: () async {
//             final taskProvider = context.read<TaskProvider>();
//             final documentProvider = context.read<DocumentProvider>();
//             final userId = await TokenStorage.getUserId();

//             await Future.wait([
//               taskProvider.refreshTasks(),
//               if (userId != null)
//                 documentProvider.loadDocumentsForUser(userId)
//               else
//                 documentProvider.loadDocuments(),
//             ]);
//           },
//           child: Consumer2<TaskProvider, DocumentProvider>(
//             builder: (context, taskProvider, documentProvider, child) {
//               final isLoading =
//                   taskProvider.isLoading || documentProvider.isLoading;

//               if (isLoading) {
//                 return const Center(child: CircularProgressIndicator());
//               }

//               return CustomScrollView(
//                 physics: const BouncingScrollPhysics(),
//                 slivers: [
//                   // Header with profile photo
//                   SliverToBoxAdapter(
//                     child: Padding(
//                       padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
//                       child: Row(
//                         children: [
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   DateFormat(
//                                     'EEEE, MMM d',
//                                   ).format(today).toUpperCase(),
//                                   style: theme.textTheme.labelMedium?.copyWith(
//                                     color: theme.colorScheme.primary,
//                                     fontWeight: FontWeight.bold,
//                                     letterSpacing: 1.2,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 4),
//                                 Text(
//                                   'Welcome back!',
//                                   style: theme.textTheme.headlineMedium
//                                       ?.copyWith(
//                                         fontWeight: FontWeight.bold,
//                                         color: theme.colorScheme.onSurface,
//                                       ),
//                                 ),
//                                 const SizedBox(height: 4),
//                                 Text(
//                                   'You have ${taskProvider.dueTasks.length + taskProvider.currentTasks.length} tasks for today',
//                                   style: theme.textTheme.bodyMedium?.copyWith(
//                                     color: theme.colorScheme.onSurface
//                                         .withValues(alpha: 0.6),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           Container(
//                             decoration: BoxDecoration(
//                               shape: BoxShape.circle,
//                               border: Border.all(
//                                 color: theme.colorScheme.primary.withValues(
//                                   alpha: 0.2,
//                                 ),
//                                 width: 2,
//                               ),
//                             ),
//                             child: CircleAvatar(
// Old Dashboard implementation removed.

//----------------------------------------------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../core/providers/document_provider.dart';
import '../../../core/providers/task_provider.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/services/token_storage.dart';
import '../../../core/models/document.dart';

import '../widgets/task_section.dart';
import 'add_edit_task_screen.dart';
import '../../tasks/screens/all_tasks_screen.dart';
import '../../../widgets/main_screen.dart';
import '../../../widgets/double_back_to_exit_wrapper.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final taskProvider = context.read<TaskProvider>();
      final documentProvider = context.read<DocumentProvider>();

      taskProvider.loadTasks();

      final userId = await TokenStorage.getUserId();
      if (!mounted) return;

      if (userId != null) {
        documentProvider.loadDocumentsForUser(userId);
      } else {
        documentProvider.loadDocuments();
      }
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
        title: const Text('My Tasks'),
        actions: [
          Consumer<ThemeProvider>(
            builder: (_, themeProvider, _) {
              return IconButton(
                icon: Icon(
                  themeProvider.isDarkMode
                      ? Icons.light_mode_rounded
                      : Icons.dark_mode_rounded,
                ),
                onPressed: themeProvider.toggleTheme,
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            final taskProvider = context.read<TaskProvider>();
            final documentProvider = context.read<DocumentProvider>();
            final userId = await TokenStorage.getUserId();

            await Future.wait([
              taskProvider.refreshTasks(),
              if (userId != null)
                documentProvider.loadDocumentsForUser(
                  userId,
                  forceRefresh: true,
                )
              else
                documentProvider.loadDocuments(forceRefresh: true),
            ]);
          },
          child: Consumer2<TaskProvider, DocumentProvider>(
            builder: (context, taskProvider, documentProvider, _) {
              if (taskProvider.isLoading || documentProvider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              return CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  /// HEADER
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
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
                                const SizedBox(height: 6),
                                Text(
                                  'Welcome back!',
                                  style: theme.textTheme.headlineMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 6),
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
                          CircleAvatar(
                            radius: 24,
                            backgroundColor:
                                theme.colorScheme.surfaceContainerHighest,
                            child: Icon(
                              Icons.person_rounded,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  /// DOCUMENTS
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: _DocumentsPreview(
                        documents: documentProvider.documents,
                        onSeeAll: () {
                          // Navigate to Documents tab via bottom nav
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (_) => const DoubleBackToExitWrapper(
                                child: MainScreen(initialIndex: 1),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  /// TASKS CONTAINER
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: _TasksContainer(
                        taskProvider: taskProvider,
                        onAddTask: () async {
                          final result = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const DoubleBackToExitWrapper(
                                child: AddEditTaskScreen(),
                              ),
                            ),
                          );
                          if (result == true && context.mounted) {
                            taskProvider.refreshTasks();
                          }
                        },
                        onViewAll: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const DoubleBackToExitWrapper(
                                child: AllTasksScreen(),
                              ),
                            ),
                          );
                        },
                        onToggle: (id, completed) => _handleTaskToggle(
                          context,
                          taskProvider,
                          id,
                          completed,
                        ),
                      ),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: MediaQuery.of(context).padding.bottom + 24,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// ================= TASKS BOX =================

class _TasksContainer extends StatelessWidget {
  final TaskProvider taskProvider;
  final VoidCallback onAddTask;
  final VoidCallback onViewAll;
  final void Function(String, bool) onToggle;

  const _TasksContainer({
    required this.taskProvider,
    required this.onAddTask,
    required this.onViewAll,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          /// HEADER
          Row(
            children: [
              Expanded(
                child: Text(
                  'Tasks',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              TextButton(onPressed: onViewAll, child: const Text('View all')),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: onAddTask,
                icon: const Icon(Icons.add),
                label: const Text('Add'),
              ),
            ],
          ),

          const SizedBox(height: 16),

          if (taskProvider.dueTasks.isNotEmpty)
            TaskSection(
              title: 'Due Tasks',
              tasks: taskProvider.dueTasks,
              memberNames: {
                for (var t in taskProvider.tasks)
                  t.memberId ?? '': t.memberId ?? 'Unknown',
              },
              onTaskToggle: onToggle,
              titleColor: theme.colorScheme.error,
              titleIcon: Icons.warning_amber_rounded,
            ),

          if (taskProvider.currentTasks.isNotEmpty)
            TaskSection(
              title: 'Today',
              tasks: taskProvider.currentTasks,
              memberNames: {
                for (var t in taskProvider.tasks)
                  t.memberId ?? '': t.memberId ?? 'Unknown',
              },
              onTaskToggle: onToggle,
              titleColor: theme.colorScheme.primary,
              titleIcon: Icons.today_outlined,
            ),

          if (taskProvider.upcomingTasks.isNotEmpty)
            TaskSection(
              title: 'Upcoming',
              tasks: taskProvider.upcomingTasks,
              memberNames: {
                for (var t in taskProvider.tasks)
                  t.memberId ?? '': t.memberId ?? 'Unknown',
              },
              onTaskToggle: onToggle,
              titleColor: theme.colorScheme.secondary,
              titleIcon: Icons.upcoming_outlined,
            ),

          if (taskProvider.dueTasks.isEmpty &&
              taskProvider.currentTasks.isEmpty &&
              taskProvider.upcomingTasks.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Column(
                children: [
                  Icon(
                    Icons.task_alt_rounded,
                    size: 48,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 12),
                  const Text('No tasks yet'),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// ================= DOCUMENTS BOX =================

class _DocumentsPreview extends StatelessWidget {
  final List<Document> documents;
  final VoidCallback onSeeAll;

  const _DocumentsPreview({required this.documents, required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final topDocs = documents.take(3).toList();

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'My Documents',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              TextButton(onPressed: onSeeAll, child: const Text('See all')),
            ],
          ),
          const SizedBox(height: 12),
          if (topDocs.isEmpty)
            const Text('No documents uploaded yet')
          else
            ...topDocs.map(
              (doc) => ListTile(
                onTap: () {
                  context.read<DocumentProvider>().viewDocument(doc);
                },
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.description_outlined),
                title: Text(
                  doc.originalName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  doc.createdAt != null
                      ? DateFormat('MMM dd, yyyy').format(doc.createdAt!)
                      : 'Unknown date',
                ),
                trailing: Text(doc.fileSizeDisplay),
              ),
            ),
        ],
      ),
    );
  }
}
