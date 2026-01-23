import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/task_provider.dart';
import '../../../core/providers/category_provider.dart';
import '../../../core/models/task.dart';
import '../../../core/services/token_storage.dart';
import '../../../core/providers/member_provider.dart';

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
  String? _selectedMemberId;
  int _reminderDays = 3;
  TaskType _taskType = TaskType.oneTime;

  bool get isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    _loadUserId();

    if (isEditing) {
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description ?? '';
      _selectedCategoryId = widget.task!.categoryId;
      _selectedDate =
          widget.task!.dueDate ?? DateTime.now().add(const Duration(days: 7));
      _isRecurring = widget.task!.isRecurring;
      _recurrenceType = widget.task!.recurrenceType;
      _taskType = widget.task!.taskType;
      if (widget.task!.memberId != null) {
        _selectedMemberId = widget.task!.memberId;
      }
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
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(
        color: theme.colorScheme.outline.withValues(alpha: 0.2),
      ),
    );

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            isEditing ? 'Edit Task' : 'Add Task',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          centerTitle: true,
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              // Title
              TextFormField(
                controller: _titleController,
                style: theme.textTheme.titleMedium,
                decoration: InputDecoration(
                  labelText: 'Task Title',
                  hintText: 'What needs to be done?',
                  prefixIcon: const Icon(Icons.title_rounded),
                  border: inputBorder,
                  enabledBorder: inputBorder,
                  focusedBorder: inputBorder.copyWith(
                    borderSide: BorderSide(
                      color: theme.colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerLowest,
                  contentPadding: const EdgeInsets.all(16),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Please enter a title'
                    : null,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 20),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  hintText: 'Add details (optional)',
                  prefixIcon: const Icon(Icons.description_outlined),
                  border: inputBorder,
                  enabledBorder: inputBorder,
                  focusedBorder: inputBorder.copyWith(
                    borderSide: BorderSide(
                      color: theme.colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerLowest,
                  contentPadding: const EdgeInsets.all(16),
                ),
                maxLines: 4,
                minLines: 2,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 20),

              // Due Date
              InkWell(
                onTap: _selectDate,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: theme.colorScheme.outline.withValues(alpha: 0.2),
                    ),
                    borderRadius: BorderRadius.circular(16),
                    color: theme.colorScheme.surfaceContainerLowest,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Due Date', style: theme.textTheme.labelMedium),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat(
                              'EEEE, MMM d, yyyy',
                            ).format(_selectedDate),
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16,
                        color: theme.hintColor,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Member Selection
              Consumer<MemberProvider>(
                builder: (context, memberProvider, child) {
                  return DropdownButtonFormField<String>(
                    value: _selectedMemberId,
                    decoration: InputDecoration(
                      labelText: 'Assign Member',
                      prefixIcon: const Icon(Icons.person_outline_rounded),
                      border: inputBorder,
                      enabledBorder: inputBorder,
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerLowest,
                    ),
                    items: memberProvider.members.map((member) {
                      return DropdownMenuItem<String>(
                        value: member.id,
                        child: Text(member.name),
                      );
                    }).toList(),
                    onChanged: (value) =>
                        setState(() => _selectedMemberId = value),
                    validator: (value) =>
                        value == null ? 'Please assign a member' : null,
                  );
                },
              ),
              const SizedBox(height: 20),

              // Reminder & Task Type Group
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  ),
                  borderRadius: BorderRadius.circular(16),
                  color: theme.colorScheme.surfaceContainerLowest,
                ),
                child: Column(
                  children: [
                    // Start of Reminder Section
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: Row(
                        children: [
                          const Icon(Icons.notifications_outlined),
                          const SizedBox(width: 12),
                          Text('Remind me', style: theme.textTheme.bodyLarge),
                          const Spacer(),
                          Text(
                            '$_reminderDays days before',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Slider(
                      value: _reminderDays.toDouble(),
                      min: 1,
                      max: 30,
                      divisions: 29,
                      onChanged: (value) =>
                          setState(() => _reminderDays = value.toInt()),
                    ),
                    const Divider(height: 1),

                    // Task Type Section
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: RadioListTile<TaskType>(
                              title: const Text('One-time'),
                              value: TaskType.oneTime,
                              groupValue: _taskType,
                              onChanged: (val) =>
                                  setState(() => _taskType = val!),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<TaskType>(
                              title: const Text('Recurring'),
                              value: TaskType.recurring,
                              groupValue: _taskType,
                              onChanged: (val) =>
                                  setState(() => _taskType = val!),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: _isLoading ? null : _saveTask,
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          isEditing ? 'Save Changes' : 'Create Task',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
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
              content: Text(provider.errorMessage ?? 'Failed to save task'),
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
