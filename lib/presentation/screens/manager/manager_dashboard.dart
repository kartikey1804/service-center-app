import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as provider_pkg;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/pipeline_providers.dart';
import '../../utils/ui_utils.dart';
import '../../providers/data_provider.dart';
import '../../widgets/custom_card.dart';

class ManagerDashboard extends ConsumerStatefulWidget {
  const ManagerDashboard({super.key});

  @override
  ConsumerState<ManagerDashboard> createState() => _ManagerDashboardState();
}

class _ManagerDashboardState extends ConsumerState<ManagerDashboard> {
  @override
  void initState() {
    super.initState();
    // Listen for new tow requests to show immediate feedback
    Future.microtask(() {
      ref.listenManual(towPipelineProvider, (previous, next) {
        next.whenData((jobs) {
          if (previous != null && previous.hasValue) {
            final prevJobs = previous.value!;
            if (jobs.length > prevJobs.length) {
              final newJob = jobs.last;
              UiUtils.showToast(
                context,
                '🚨 NEW EMERGENCY TOW: ${newJob['id']}',
                isError: false,
              );
            }
          }
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final stats = provider_pkg.Provider.of<DataProvider>(context).stats;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Manager Overview',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 24),
          GridView.count(
            crossAxisCount: MediaQuery.of(context).size.width > 800 ? 4 : 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.5,
            children: [
              _buildStatCard(
                context,
                'Revenue Today',
                '\$${stats['revenueToday'] ?? 0}',
                Colors.green,
              ),
              _buildStatCard(
                context,
                'Active Jobs',
                '${stats['activeJobs'] ?? 0}',
                Colors.blue,
              ),
              _buildStatCard(
                context,
                'Completed',
                '${stats['completedJobs'] ?? 0}',
                Colors.indigo,
              ),
              _buildStatCard(
                context,
                'Techs Online',
                '${stats['techniciansOnline'] ?? 0}',
                Colors.orange,
              ),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            'Recent Alerts',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          provider_pkg.Consumer<DataProvider>(
            builder: (context, dataProvider, child) {
              final notifications = dataProvider.notifications;
              if (notifications.isEmpty) {
                return const Text('No recent alerts.');
              }
              return CustomCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: notifications.map((notification) {
                    return Column(
                      children: [
                        ListTile(
                          leading: Icon(
                            notification['isRead'] == true
                                ? Icons.info_outline
                                : Icons.warning,
                            color: notification['isRead'] == true
                                ? Colors.blue
                                : Colors.red,
                          ),
                          title: Text(notification['title']),
                          subtitle: Text(notification['time']),
                          trailing: TextButton(
                            onPressed: () {
                              // Mark as read or navigate to details
                              dataProvider.markNotificationAsRead(
                                notification['id'],
                              );
                            },
                            child: notification['isRead'] == true
                                ? const Text('Read')
                                : const Text('Mark as Read'),
                          ),
                        ),
                        const Divider(height: 1),
                      ],
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    Color color,
  ) {
    return CustomCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
