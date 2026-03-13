import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/data_provider.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../utils/ui_utils.dart';

class EmployeeManagement extends StatefulWidget {
  const EmployeeManagement({super.key});

  @override
  State<EmployeeManagement> createState() => _EmployeeManagementState();
}

class _EmployeeManagementState extends State<EmployeeManagement> {
  final _nameController = TextEditingController();
  final _idController = TextEditingController();
  final _passController = TextEditingController();
  String _selectedRole = 'technician';

  @override
  void dispose() {
    _nameController.dispose();
    _idController.dispose();
    _passController.dispose();
    super.dispose();
  }

  void _showAddEmployeeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Employee'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                controller: _nameController,
                label: 'Full Name',
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _idController,
                label: 'Employee ID / Username',
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _passController,
                label: 'Initial Password',
                obscureText: true,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: const InputDecoration(labelText: 'Role'),
                items: ['technician', 'manager', 'admin', 'owner']
                    .map((role) => DropdownMenuItem(
                          value: role,
                          child: Text(role.toUpperCase()),
                        ))
                    .toList(),
                onChanged: (val) => setState(() => _selectedRole = val!),
              ),
            ],
          ),
        ),
        actions: [
          CustomButton(
            text: 'Cancel',
            type: ButtonType.secondary,
            onPressed: () => Navigator.pop(context),
          ),
          CustomButton(
            text: 'Add',
            onPressed: () {
              if (_nameController.text.isNotEmpty && _idController.text.isNotEmpty) {
                Provider.of<DataProvider>(context, listen: false).addStaffMember({
                  'name': _nameController.text,
                  'id': _idController.text,
                  'role': _selectedRole,
                  'status': 'Offline',
                  'lastLogin': 'Never',
                  'password': _passController.text,
                });
                Navigator.pop(context);
                UiUtils.showToast(context, 'Employee Added Successfully');
                _nameController.clear();
                _idController.clear();
                _passController.clear();
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: _showAddEmployeeDialog,
          ),
        ],
      ),
      body: Consumer<DataProvider>(
        builder: (context, dataProvider, child) {
          final staff = dataProvider.staff;
          if (staff.isEmpty) {
            return const Center(child: Text('No employees found.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: staff.length,
            itemBuilder: (context, index) {
              final employee = staff[index];
              return CustomCard(
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(employee['name']?[0] ?? 'E'),
                  ),
                  title: Text(employee['name'] ?? 'Unknown'),
                  subtitle: Text('${employee['role']?.toUpperCase()} | ID: ${employee['id']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          // TODO: Implement Edit
                          UiUtils.showToast(context, 'Edit functionality coming soon');
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          UiUtils.showCustomDialog(
                            context: context,
                            title: 'Terminate Employee',
                            content: Text('Are you sure you want to remove ${employee['name']}? This action cannot be undone.'),
                            actions: [
                              CustomButton(
                                text: 'Cancel',
                                onPressed: () => Navigator.pop(context),
                              ),
                              CustomButton(
                                text: 'Terminate',
                                type: ButtonType.danger,
                                onPressed: () {
                                  dataProvider.deleteDocument('staff', employee['id']);
                                  Navigator.pop(context);
                                  UiUtils.showToast(context, 'Employee Terminated');
                                },
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
