import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/task_provider.dart';
import '../../../core/providers/category_provider.dart';
import '../../../core/models/task.dart';
import '../../../core/services/token_storage.dart';

class AddEditTaskScreen extends StatefulWidget {
  final Task? task;

  const AddEditTaskScreen({super.key, this.task});

  @override
  State<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedCategoryId;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 7));
  bool _isRecurring = false;
  String? _recurrenceType;
  bool _isLoading = false;
  String? _userId;

  bool get isEditing => widget.task != null;

  final List<String> _recurrenceOptions = [
    'Monthly',
    'Every 3 months',
    'Every 6 months',
    'Yearly',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserId();

    if (isEditing) {
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description ?? '';
      _selectedCategoryId = widget.task!.categoryId;
      _selectedDate = widget.task!.dueDate ?? DateTime.now().add(const Duration(days: 7));
      _isRecurring = widget.task!.isRecurring;
      _recurrenceType = widget.task!.recurrenceType;
    }

    // Load categories
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().loadCategories();
    });
  }

  Future<void> _loadUserId() async {
    final userId = await TokenStorage.getUserId();
    setState(() {
      _userId = userId;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: Text(isEditing ? 'Edit Task' : 'Add Task')),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Task Title',
                  hintText: 'Enter task title',
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a task title';
                  }
                  return null;
                },
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 16),

              // Member Selection
              Consumer<MemberProvider>(
                builder: (context, memberProvider, child) {
                  if (memberProvider.members.isEmpty) {
                    return const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'No members available. Please add a member first.',
                        ),
                      ),
                    );
                  }

                  return DropdownButtonFormField<int>(
                    value: _selectedMemberId,
                    decoration: const InputDecoration(
                      labelText: 'Select Member',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    items: memberProvider.members.map((member) {
                      return DropdownMenuItem<int>(
                        value: member.id,
                        child: Text(member.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedMemberId = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a member';
                      }
                      return null;
                    },
                  );
                },
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  hintText: 'Enter task description',
                  prefixIcon: Icon(Icons.description_outlined),
                ),
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 16),

              // Due Date
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today_outlined),
                title: const Text('Due Date'),
                subtitle: Text(
                  DateFormat('MMM dd, yyyy').format(_selectedDate),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: _selectDate,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: theme.colorScheme.outline.withValues(alpha: 0.3),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Reminder Days
              Row(
                children: [
                  const Icon(Icons.notifications_outlined),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Remind $_reminderDays days before',
                          style: theme.textTheme.titleMedium,
                        ),
                        Slider(
                          value: _reminderDays.toDouble(),
                          min: 1,
                          max: 30,
                          divisions: 29,
                          label: '$_reminderDays days',
                          onChanged: (value) {
                            setState(() {
                              _reminderDays = value.toInt();
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Task Type
              const Text(
                'Task Type',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<TaskType>(
                      title: const Text('One-time'),
                      value: TaskType.oneTime,
                      groupValue: _taskType,
                      onChanged: (value) {
                        setState(() {
                          _taskType = value!;
                        });
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: _taskType == TaskType.oneTime
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outline.withValues(
                                  alpha: 0.3,
                                ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: RadioListTile<TaskType>(
                      title: const Text('Recurring'),
                      value: TaskType.recurring,
                      groupValue: _taskType,
                      onChanged: (value) {
                        setState(() {
                          _taskType = value!;
                        });
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: _taskType == TaskType.recurring
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outline.withValues(
                                  alpha: 0.3,
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Save Button
              ElevatedButton(
                onPressed: _isLoading ? null : _saveTask,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(isEditing ? 'Update Task' : 'Add Task'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final provider = context.read<TaskProvider>();

      final task = Task(
        id: isEditing ? widget.task!.id : null,
        title: _titleController.text.trim(),
        userId: _userId!,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        dueDate: _selectedDate,
        isRecurring: _isRecurring,
        recurrenceType: _recurrenceType,
        status: isEditing ? widget.task!.status : TaskStatus.pending,
        categoryId: _selectedCategoryId,
      );

      final success = isEditing
          ? await provider.updateTask(task)
          : await provider.addTask(task) != null;

      if (mounted) {
        if (success) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isEditing ? 'Task updated' : 'Task added'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                provider.errorMessage ?? 'Failed to save task',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
