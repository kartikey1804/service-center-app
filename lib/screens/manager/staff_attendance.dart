import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../providers/data_provider.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_badge.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../utils/ui_utils.dart';

class StaffAttendance extends StatefulWidget {
  const StaffAttendance({Key? key}) : super(key: key);

  @override
  State<StaffAttendance> createState() => _StaffAttendanceState();
}

class _StaffAttendanceState extends State<StaffAttendance> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  void _showAddEmployeeModal(BuildContext context) {
    String name = '';
    String role = 'Technician';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add New Employee'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Full Name'),
              onChanged: (val) => name = val,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: role,
              items: ['Technician', 'Service Advisor', 'Mechanic', 'Manager']
                  .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                  .toList(),
              onChanged: (val) {
                if (val != null) role = val;
              },
              decoration: const InputDecoration(labelText: 'Role'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          CustomButton(
            text: 'Add',
            onPressed: () {
              if (name.isNotEmpty) {
                Provider.of<DataProvider>(context, listen: false).addStaffMember({
                  'name': name,
                  'role': role,
                  'status': 'Offline',
                  'hours': '0h 0m'
                });
                Navigator.pop(ctx);
                UiUtils.showToast(context, 'Employee Added');
              }
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final staff = Provider.of<DataProvider>(context).staff;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Staff & Scheduling', style: Theme.of(context).textTheme.headlineMedium),
              CustomButton(
                text: 'Add Employee',
                icon: Icons.person_add,
                onPressed: () => _showAddEmployeeModal(context),
              )
            ],
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: CustomCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Shift Scheduler', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 16),
                      TableCalendar(
                        firstDay: DateTime.utc(2020, 10, 16),
                        lastDay: DateTime.utc(2030, 3, 14),
                        focusedDay: _focusedDay,
                        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() {
                            _selectedDay = selectedDay;
                            _focusedDay = focusedDay;
                          });
                        },
                        calendarStyle: CalendarStyle(
                          todayDecoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          selectedDecoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 3,
                child: CustomCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Text('Daily Roster', style: Theme.of(context).textTheme.titleLarge),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('Name')),
                            DataColumn(label: Text('Role')),
                            DataColumn(label: Text('Status')),
                            DataColumn(label: Text('Hours Today')),
                            DataColumn(label: Text('Shift')),
                          ],
                          rows: staff.map((s) {
                            final isOnline = s['status'] == 'Online';
                            return DataRow(cells: [
                              DataCell(
                                Row(
                                  children: [
                                    if (s['image'] != null)
                                      CircleAvatar(
                                        radius: 14,
                                        backgroundImage: AssetImage(s['image']),
                                      ),
                                    if (s['image'] != null) const SizedBox(width: 12),
                                    Text(s['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                              DataCell(Text(s['role'])),
                              DataCell(CustomBadge(text: s['status'], type: isOnline ? BadgeType.green : BadgeType.gray)),
                              DataCell(Text(s['hours'])),
                              DataCell(const Text('09:00 AM - 05:00 PM')),
                            ]);
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

