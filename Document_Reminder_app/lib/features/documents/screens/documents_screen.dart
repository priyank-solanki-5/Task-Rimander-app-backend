import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/document_provider.dart';
import '../../../widgets/double_back_to_exit_wrapper.dart';
import '../../../core/providers/member_provider.dart';
import '../../../core/models/document.dart';
import 'add_document_screen.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DocumentProvider>().loadDocuments();
      context.read<MemberProvider>().loadMembers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Documents'),
        actions: [
          // Sort menu
          Consumer<DocumentProvider>(
            builder: (context, provider, child) {
              return PopupMenuButton<SortType>(
                icon: const Icon(Icons.sort),
                onSelected: (sortType) {
                  provider.setSortType(sortType);
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: SortType.uploadDate,
                    child: Row(
                      children: [
                        Icon(
                          provider.sortType == SortType.uploadDate
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text('Upload Date'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: SortType.alphabetical,
                    child: Row(
                      children: [
                        Icon(
                          provider.sortType == SortType.alphabetical
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text('Alphabetical'),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Member filter dropdown
            Consumer2<DocumentProvider, MemberProvider>(
              builder: (context, docProvider, memberProvider, child) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  color: theme.colorScheme.surface,
                  child: DropdownButtonFormField<String?>(
                    value: docProvider.selectedMemberId,
                    decoration: InputDecoration(
                      labelText: 'Filter by Member',
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: 'myself',
                        child: Text('Myself'),
                      ),
                      const DropdownMenuItem<String?>(
                        value: 'all',
                        child: Text('All Members'),
                      ),
                      ...memberProvider.members.map((member) {
                        return DropdownMenuItem<String?>(
                          value: member.id,
                          child: Text(member.name),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      docProvider.setMemberFilter(value);
                    },
                  ),
                );
              },
            ),

            // Document list
            Expanded(
              child: Consumer2<DocumentProvider, MemberProvider>(
                builder: (context, provider, memberProvider, child) {
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: provider.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : RefreshIndicator(
                            onRefresh: () => provider.refreshDocuments(),
                            child: _buildDocumentBody(
                              context,
                              provider,
                              memberProvider,
                              theme,
                            ),
                          ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final docProvider = context.read<DocumentProvider>();
          final selectedMemberId = docProvider.selectedMemberId;

          // Only pass specific member IDs, not 'all' or 'myself'
          final initialMemberId =
              (selectedMemberId == 'all' || selectedMemberId == 'myself')
              ? null
              : selectedMemberId;

          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (context) => DoubleBackToExitWrapper(
                child: AddDocumentScreen(initialMemberId: initialMemberId),
              ),
            ),
          );
          if (!context.mounted) return;
          if (result == true) {
            context.read<DocumentProvider>().refreshDocuments();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Document'),
      ),
    );
  }

  Future<void> _viewDocument(Document document) async {
    await context.read<DocumentProvider>().viewDocument(document);
  }

  Future<void> _deleteDocument(Document document) async {
    final documentProvider = context.read<DocumentProvider>();
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Document'),
        content: Text(
          'Are you sure you want to delete "${document.originalName}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (!context.mounted) return;
    if (confirmed == true) {
      await documentProvider.deleteDocument(document.id!);
      if (!context.mounted) return;
      messenger.showSnackBar(const SnackBar(content: Text('Document deleted')));
    }
  }

  Widget _buildDocumentBody(
    BuildContext context,
    DocumentProvider provider,
    MemberProvider memberProvider,
    ThemeData theme,
  ) {
    final documents = provider.filteredDocuments;

    if (documents.isEmpty) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.folder_open,
                size: 64,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'No documents found',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Pull to refresh or upload your first document',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () async {
                  final selectedMemberId = provider.selectedMemberId;
                  final initialMemberId =
                      (selectedMemberId == 'all' ||
                          selectedMemberId == 'myself')
                      ? null
                      : selectedMemberId;

                  final result = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          AddDocumentScreen(initialMemberId: initialMemberId),
                    ),
                  );
                  if (!context.mounted) return;
                  if (result == true) {
                    context.read<DocumentProvider>().refreshDocuments();
                  }
                },
                icon: const Icon(Icons.upload_file),
                label: const Text('Add Document'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: documents.length,
      itemBuilder: (context, index) {
        final document = documents[index];
        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 300 + (index * 50)),
          tween: Tween(begin: 0.0, end: 1.0),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: Opacity(opacity: value, child: child),
            );
          },
          child: _DocumentCard(
            document: document,
            memberName: memberProvider.getMemberName(document.memberId),
            onView: () => _viewDocument(document),
            onDelete: () => _deleteDocument(document),
          ),
        );
      },
    );
  }
}

class _DocumentCard extends StatelessWidget {
  final Document document;
  final String memberName;
  final VoidCallback onView;
  final VoidCallback onDelete;

  const _DocumentCard({
    required this.document,
    required this.memberName,
    required this.onView,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Icon(
            Icons.description_outlined,
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(document.originalName, style: theme.textTheme.titleMedium),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.person_outline,
                  size: 14,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 4),
                Text(memberName),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 14,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 4),
                Text(
                  document.createdAt != null
                      ? DateFormat('MMM dd, yyyy').format(document.createdAt!)
                      : 'N/A',
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.visibility_outlined),
              onPressed: onView,
              tooltip: 'View',
            ),
            IconButton(
              icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
              onPressed: onDelete,
              tooltip: 'Delete',
            ),
          ],
        ),
      ),
    );
  }
}
