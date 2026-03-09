import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/data_provider.dart';
import '../../widgets/custom_card.dart';

class ManagerDashboard extends StatelessWidget {
  const ManagerDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final stats = Provider.of<DataProvider>(context).stats;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Manager Overview', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 24),
          GridView.count(
            crossAxisCount: MediaQuery.of(context).size.width > 800 ? 4 : 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.5,
            children: [
              _buildStatCard(context, 'Revenue Today', '\$${stats['revenueToday'] ?? 0}', Colors.green),
              _buildStatCard(context, 'Active Jobs', '${stats['activeJobs'] ?? 0}', Colors.blue),
              _buildStatCard(context, 'Completed', '${stats['completedJobs'] ?? 0}', Colors.indigo),
              _buildStatCard(context, 'Techs Online', '${stats['techniciansOnline'] ?? 0}', Colors.orange),
            ],
          ),
          const SizedBox(height: 32),
          Text('Recent Alerts', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          CustomCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.warning, color: Colors.red),
                  title: const Text('Low Inventory: Spark Plugs'),
                  subtitle: const Text('Stock is below minimum threshold (20)'),
                  trailing: TextButton(onPressed: () {}, child: const Text('View')),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.info, color: Colors.blue),
                  title: const Text('New Appointment Request'),
                  subtitle: const Text('Customer: Alice Smith - MT-07'),
                  trailing: TextButton(onPressed: () {}, child: const Text('Review')),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, Color color) {
    return CustomCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Theme.of(context).textTheme.bodySmall?.color)),
          const SizedBox(height: 8),
          Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
