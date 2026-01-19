import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/dummy_data.dart';
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
  int? _selectedReminderDays;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      if (_selectedMember == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a member')),
        );
        return;
      }
      if (_selectedDocumentType == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select document type')),
        );
        return;
      }
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select due date')),
        );
        return;
      }
      if (_selectedReminderDays == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select reminder days')),
        );
        return;
      }

      // Mock save
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task added successfully!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Task'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
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
                      'Select Member',
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
                      'Document Type',
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
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        );
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
                      'Due / Expiry Date',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () => _selectDate(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today_outlined, color: Color(0xFF64748B)),
                            const SizedBox(width: 12),
                            Text(
                              _selectedDate == null
                                  ? 'Select date'
                                  : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Reminder Days Dropdown
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reminder (Days Before)',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<int>(
                      value: _selectedReminderDays,
                      decoration: const InputDecoration(
                        hintText: 'Select reminder days',
                        prefixIcon: Icon(Icons.notifications_outlined),
                      ),
                      items: AppConstants.reminderDays.map((days) {
                        return DropdownMenuItem(
                          value: days,
                          child: Text('$days days before'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedReminderDays = value;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                
                // Save Button
                CustomButton(
                  text: 'Save Task',
                  onPressed: _handleSave,
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
