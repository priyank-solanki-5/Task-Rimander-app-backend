import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_textfield.dart';

class AddMemberScreen extends StatefulWidget {
  const AddMemberScreen({super.key});

  @override
  State<AddMemberScreen> createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends State<AddMemberScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String? _selectedRelation;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      // Mock save
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Member added successfully!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Member'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name Field
                CustomTextField(
                  label: 'Member Name',
                  hint: 'Enter member name',
                  controller: _nameController,
                  prefixIcon: const Icon(Icons.person_outlined),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter member name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                
                // Relation Dropdown
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Relation (Optional)',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedRelation,
                      decoration: const InputDecoration(
                        hintText: 'Select relation',
                        prefixIcon: Icon(Icons.family_restroom_outlined),
                      ),
                      items: AppConstants.relations.map((relation) {
                        return DropdownMenuItem(
                          value: relation,
                          child: Text(relation),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedRelation = value;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                
                // Save Button
                CustomButton(
                  text: 'Save Member',
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
