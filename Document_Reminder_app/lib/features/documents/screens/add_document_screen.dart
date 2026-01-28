import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/providers/document_provider.dart';
import '../../../core/providers/member_provider.dart';
import '../../../core/providers/task_provider.dart';
import '../../../core/services/token_storage.dart';

class AddDocumentScreen extends StatefulWidget {
  final String? initialMemberId;

  const AddDocumentScreen({super.key, this.initialMemberId});

  @override
  State<AddDocumentScreen> createState() => _AddDocumentScreenState();
}

class _AddDocumentScreenState extends State<AddDocumentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  String? _selectedMemberId;
  String? _selectedFilePath;
  List<int>? _selectedFileBytes;
  String? _selectedFileName;
  String? _selectedTaskId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedMemberId = widget.initialMemberId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MemberProvider>().loadMembers();
      context.read<TaskProvider>().loadTasks();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text('Add Document')),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Document Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Document Name',
                  hintText: 'e.g., Passport.pdf',
                  prefixIcon: Icon(Icons.description_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter document name';
                  }
                  return null;
                },
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),

              // Member Selection (Mandatory)
              Consumer<MemberProvider>(
                builder: (context, memberProvider, child) {
                  return DropdownButtonFormField<String?>(
                    value: _selectedMemberId,
                    decoration: const InputDecoration(
                      labelText: 'Select Member *', // Marked as mandatory
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('Myself'),
                      ),
                      ...memberProvider.members.map((member) {
                        return DropdownMenuItem<String?>(
                          value: member.id,
                          child: Text(member.name),
                        );
                      }),
                    ],
                    // Although 'Myself' (null) is valid, this validator ensures clarity
                    validator: (value) {
                      // Note: value can be null (for Myself), so we just return null to say "it's valid"
                      // If we wanted to FORCE a non-myself member, we'd check value == null.
                      // But the user said "Member could be the user itself", so null is fine.
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        _selectedMemberId = value;
                      });
                    },
                  );
                },
              ),
              const SizedBox(height: 16),

              // Task Selection (Optional)
              Consumer<TaskProvider>(
                builder: (context, taskProvider, child) {
                  return DropdownButtonFormField<String>(
                    value: _selectedTaskId,
                    decoration: const InputDecoration(
                      labelText: 'Select Task (Optional)',
                      prefixIcon: Icon(Icons.assignment_outlined),
                      helperText: 'Leave empty to assign directly to member',
                    ),
                    items: taskProvider.tasks.map((task) {
                      return DropdownMenuItem<String>(
                        value: task.id,
                        child: Text(
                          task.title.length > 30
                              ? '${task.title.substring(0, 30)}...'
                              : task.title,
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedTaskId = value;
                      });
                    },
                  );
                },
              ),
              const SizedBox(height: 16),

              // File Picker
              OutlinedButton.icon(
                onPressed: _pickFile,
                icon: const Icon(Icons.attach_file),
                label: Text(_selectedFileName ?? 'Select File'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
              if (_selectedFileName != null) ...[
                const SizedBox(height: 8),
                Card(
                  color: theme.colorScheme.primaryContainer.withValues(
                    alpha: 0.3,
                  ),
                  child: ListTile(
                    leading: Icon(
                      Icons.check_circle,
                      color: theme.colorScheme.primary,
                    ),
                    title: Text(_selectedFileName!),
                    subtitle: const Text('File selected'),
                  ),
                ),
              ],
              const SizedBox(height: 32),

              // Save Button
              ElevatedButton(
                onPressed: _isLoading ? null : _saveDocument,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Add Document'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        withData: kIsWeb, // Important for Web
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        setState(() {
          _selectedFilePath = file.path;
          _selectedFileBytes = file.bytes;
          _selectedFileName = file.name;

          // Auto-fill document name if empty
          if (_nameController.text.isEmpty) {
            _nameController.text = file.name;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking file: $e')));
      }
    }
  }

  Future<void> _saveDocument() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedFilePath == null && _selectedFileBytes == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a file')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userId = await TokenStorage.getUserId();
      if (userId == null) throw Exception('User not logged in');

      final provider = context.read<DocumentProvider>();

      await provider.uploadDocument(
        filePath: _selectedFilePath,
        fileBytes: _selectedFileBytes,
        fileName: _selectedFileName,
        taskId: _selectedTaskId, // Can be null
        memberId: _selectedMemberId, // Passed from widget.initialMemberId
        userId: userId,
        onProgress: (count, total) {
          // Optional: Handle progress
        },
      );

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Document added successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error adding document: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
