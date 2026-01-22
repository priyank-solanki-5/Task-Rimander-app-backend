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

    if (_userId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Add Task')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
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

            // Category Selection
            Consumer<CategoryProvider>(
              builder: (context, categoryProvider, child) {
                if (categoryProvider.isLoading) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  );
                }

                if (categoryProvider.categories.isEmpty) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'No categories available. Categories will be loaded from the server.',
                      ),
                    ),
                  );
                }

                return DropdownButtonFormField<String>(
                  value: _selectedCategoryId,
                  decoration: const InputDecoration(
                    labelText: 'Category (Optional)',
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('No Category'),
                    ),
                    ...categoryProvider.categories.map((category) {
                      return DropdownMenuItem<String>(
                        value: category.id,
                        child: Text(category.name),
                      );
                    }).toList(),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedCategoryId = value;
                    });
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
              subtitle: Text(DateFormat('MMM dd, yyyy').format(_selectedDate)),
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

            // Recurring Task
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Recurring Task'),
              subtitle: const Text('Task repeats automatically'),
              value: _isRecurring,
              onChanged: (value) {
                setState(() {
                  _isRecurring = value;
                  if (!value) {
                    _recurrenceType = null;
                  }
                });
              },
            ),

            // Recurrence Type (only if recurring)
            if (_isRecurring) ...[
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _recurrenceType,
                decoration: const InputDecoration(
                  labelText: 'Recurrence Pattern',
                  prefixIcon: Icon(Icons.repeat),
                ),
                items: _recurrenceOptions.map((option) {
                  return DropdownMenuItem<String>(
                    value: option,
                    child: Text(option),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _recurrenceType = value;
                  });
                },
                validator: (value) {
                  if (_isRecurring && value == null) {
                    return 'Please select a recurrence pattern';
                  }
                  return null;
                },
              ),
            ],
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
