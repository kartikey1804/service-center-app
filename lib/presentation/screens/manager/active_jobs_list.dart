import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/data_provider.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_badge.dart';

class ActiveJobsList extends StatelessWidget {
  const ActiveJobsList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context);
    final jobs = dataProvider.activeJobs;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Job Lifecycle Management', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 24),
          CustomCard(
            padding: EdgeInsets.zero,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Vehicle')),
                  DataColumn(label: Text('Service')),
                  DataColumn(label: Text('Date/Time')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Role Actions')),
                ],
                rows: jobs.map((job) {
                  return DataRow(cells: [
                    DataCell(Text(job['vehicleId'] ?? 'Unknown')),
                    DataCell(Text(job['serviceType'] ?? job['service'] ?? 'Unknown')),
                    DataCell(Text('${job['appointmentDate']} @ ${job['timeSlot']}')),
                    DataCell(_buildStatusBadge(job['status'])),
                    DataCell(
                      Row(
                        children: [
                          if (job['status'] == 'Pending Approval') ...[
                            TextButton(
                              onPressed: () => _showApproveDialog(context, dataProvider, job),
                              child: const Text('Approve', style: TextStyle(color: Colors.green)),
                            ),
                            TextButton(
                              onPressed: () => dataProvider.rejectServiceRequest(job['id']),
                              child: const Text('Reject', style: TextStyle(color: Colors.red)),
                            ),
                          ] else ...[
                            TextButton(
                              onPressed: () => _showApproveDialog(context, dataProvider, job), // Reuse for reassign
                              child: const Text('Reassign'),
                            ),
                          ]
                        ],
                      ),
                    ),
                  ]);
                }).toList(),
              ),
            ),
          )
        ],
      ),
    );
  }

  void _showApproveDialog(BuildContext context, DataProvider dataProvider, Map<String, dynamic> job) async {
    final techs = await dataProvider.getTechnicians();
    List<String> selectedTechIds = List<String>.from(job['assignedTechnicians'] ?? []);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Assign Technicians'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: techs.map((t) => CheckboxListTile(
              title: Text(t['name']),
              subtitle: Text(t['role']),
              value: selectedTechIds.contains(t['id']),
              onChanged: (val) {
                setState(() {
                  if (val == true) selectedTechIds.add(t['id']);
                  else selectedTechIds.remove(t['id']);
                });
              },
            )).toList(),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                await dataProvider.approveServiceRequest(job['id'], selectedTechIds);
                Navigator.pop(context);
              },
              child: const Text('Confirm & Notify'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    if (status == 'Pending Approval') return const CustomBadge(text: 'Pending', type: BadgeType.red);
    if (status == 'Appointment Approved') return const CustomBadge(text: 'Approved', type: BadgeType.green);
    if (status == 'To Start') return const CustomBadge(text: 'To Start', type: BadgeType.gray);
    if (status == 'In Progress') return const CustomBadge(text: 'In Progress', type: BadgeType.blue);
    if (status == 'Ready') return const CustomBadge(text: 'Ready', type: BadgeType.green);
    return CustomBadge(text: status);
  }
}
