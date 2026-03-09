import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/data_provider.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_badge.dart';

class ActiveJobsList extends StatelessWidget {
  const ActiveJobsList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final jobs = Provider.of<DataProvider>(context).activeJobs;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('All Active Jobs', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 24),
          CustomCard(
            padding: EdgeInsets.zero,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Job ID')),
                  DataColumn(label: Text('Vehicle')),
                  DataColumn(label: Text('Service')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Assigned Tech')),
                  DataColumn(label: Text('Action')),
                ],
                rows: jobs.map((job) {
                  return DataRow(cells: [
                    DataCell(Text(job['id'], style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold))),
                    DataCell(Text(job['vehicle'])),
                    DataCell(Text(job['service'])),
                    DataCell(_buildStatusBadge(job['status'])),
                    DataCell(const Text('Mike (Tech-01)')),
                    DataCell(
                      TextButton(
                        onPressed: () {},
                        child: const Text('Reassign', style: TextStyle(fontSize: 12)),
                      )
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

  Widget _buildStatusBadge(String status) {
    if (status == 'To Start') return const CustomBadge(text: 'To Start', type: BadgeType.gray);
    if (status == 'In Progress') return const CustomBadge(text: 'In Progress', type: BadgeType.blue);
    if (status == 'Ready') return const CustomBadge(text: 'Ready', type: BadgeType.green);
    return CustomBadge(text: status);
  }
}
