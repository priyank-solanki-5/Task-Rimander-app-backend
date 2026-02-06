import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/dummy_data.dart' hide Task;
import '../../../core/models/task.dart' as model;
import '../../../core/providers/task_provider.dart';
import '../../../core/services/token_storage.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_textfield.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedMember;
  String? _selectedDocumentType;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _selectedRecurrence;
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: _selectedTime ?? TimeOfDay.now(),
        builder: (context, child) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Theme(
                  data: Theme.of(context).copyWith(
                    useMaterial3: true,
                    timePickerTheme: TimePickerThemeData(
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      dialHandColor: Theme.of(context).colorScheme.primary,
                      dialBackgroundColor: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      hourMinuteTextColor: Theme.of(
                        context,
                      ).colorScheme.onSurface,
                      dayPeriodTextColor: Theme.of(
                        context,
                      ).colorScheme.onSurface,
                    ),
                  ),
                  child: MediaQuery(
                    data: MediaQuery.of(
                      context,
                    ).copyWith(alwaysUse24HourFormat: false),
                    child: child!,
                  ),
                ),
              ),
            ],
          );
        },
      );

      if (pickedTime != null) {
        setState(() {
          _selectedTime = pickedTime;
          _selectedDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  String _formatSelectedDateTime() {
    if (_selectedDate == null) return 'Select date & time';
    return DateFormat('EEE, MMM d, yyyy • h:mm a').format(_selectedDate!);
  }

  Future<void> _handleSave() async {
    if (_formKey.currentState!.validate()) {
      // Member and Document Type are now OPTIONAL

      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select due date & time')),
        );
        return;
      }
      if (_selectedRecurrence == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select recurrence type')),
        );
        return;
      }

      setState(() => _isSaving = true);

      try {
        final userId = await TokenStorage.getUserId();
        if (userId == null) {
          throw Exception('Session expired. Please log in again.');
        }

        final provider = context.read<TaskProvider>();

        final isRecurring = _selectedRecurrence != 'One Time';
        final task = model.Task(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          status: model.TaskStatus.pending,
          dueDate: _selectedDate,
          isRecurring: isRecurring,
          recurrenceType: isRecurring ? _selectedRecurrence : null,
          userId: userId,
          memberId: _selectedMember,
          categoryId: null, // No category selection on this form
          taskType: isRecurring
              ? model.TaskType.recurring
              : model.TaskType.oneTime,
          remindMeBeforeDays: null,
        );

        final created = await provider.addTask(task);
        if (created != null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Task added successfully!')),
          );
          Navigator.pop(context, true);
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                provider.errorMessage ?? 'Failed to add task. Please retry.',
              ),
            ),
          );
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      } finally {
        if (mounted) setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text('Add Task')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Member Dropdown
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Member (Optional)',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedMember,
                      decoration: const InputDecoration(
                        hintText: 'Choose member',
                        prefixIcon: Icon(Icons.person_outlined),
                      ),
                      items: DummyData.members.map((member) {
                        return DropdownMenuItem(
                          value: member.id,
                          child: Text(member.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedMember = value;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Task Title
                CustomTextField(
                  label: 'Task Title',
                  hint: 'Enter task title',
                  controller: _titleController,
                  prefixIcon: const Icon(Icons.title_outlined),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter task title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Task Description
                CustomTextField(
                  label: 'Task Description',
                  hint: 'Enter task description',
                  controller: _descriptionController,
                  prefixIcon: const Icon(Icons.description_outlined),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter task description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Document Type Dropdown
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Document Type (Optional)',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedDocumentType,
                      decoration: const InputDecoration(
                        hintText: 'Select document type',
                        prefixIcon: Icon(Icons.insert_drive_file_outlined),
                      ),
                      items: AppConstants.documentTypes.map((type) {
                        return DropdownMenuItem(value: type, child: Text(type));
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedDocumentType = value;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Due Date Picker
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Due / Expiry Date & Time',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () => _selectDateTime(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_outlined,
                              color: Color(0xFF64748B),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _formatSelectedDateTime(),
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Recurrence Type Dropdown
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recurrence Type',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedRecurrence,
                      decoration: const InputDecoration(
                        hintText: 'Select recurrence type',
                        prefixIcon: Icon(Icons.repeat_outlined),
                      ),
                      items:
                          const [
                            'One Time',
                            'Monthly',
                            'Quarterly',
                            'Half-Yearly',
                            'Yearly',
                          ].map((type) {
                            return DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            );
                          }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedRecurrence = value;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Save Button
                CustomButton(
                  text: _isSaving ? 'Saving...' : 'Save Task',
                  onPressed: _isSaving ? () {} : () => _handleSave(),
                  icon: Icons.check,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
