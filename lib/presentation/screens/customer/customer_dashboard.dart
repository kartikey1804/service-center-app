import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../providers/data_provider.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_button.dart';
import '../main_scaffold.dart';
import '../../utils/ui_utils.dart';
import 'emergency_tow_screen.dart';

class CustomerDashboard extends StatelessWidget {
  const CustomerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Consumer<DataProvider>(
            builder: (context, dataProvider, child) {
              // Placeholder userId for now
              const String currentUserId = 'customer-1';
              return FutureBuilder<Map<String, dynamic>?>(
                future: dataProvider.getUserById(currentUserId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Text('Loading...');
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (snapshot.hasData && snapshot.data != null) {
                    final customerName = snapshot.data!['name'] ?? 'User';
                    return Text(
                      'Welcome back, $customerName!',
                      style: Theme.of(context).textTheme.headlineMedium,
                    );
                  } else {
                    return Text(
                      'Welcome back!',
                      style: Theme.of(context).textTheme.headlineMedium,
                    );
                  }
                },
              );
            },
          ),
          const SizedBox(height: 8),
          Text(
            'Your vehicles are looking great.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
          const SizedBox(height: 32),
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Quick Actions',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Icon(
                      LucideIcons.zap,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: 'Book Service',
                        icon: LucideIcons.calendar,
                        type: ButtonType.primary,
                        onPressed: () {
                          context
                              .findAncestorStateOfType<MainScaffoldState>()
                              ?.setTab(1);
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomButton(
                        text: 'Emergency Tow',
                        icon: LucideIcons.alertTriangle,
                        type: ButtonType.danger,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EmergencyTowScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomButton(
                        text: 'Support Chat',
                        icon: LucideIcons.messageSquare,
                        type: ButtonType.secondary,
                        onPressed: () {
                          UiUtils.showToast(context, 'Opening support chat...');
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Recent Activity',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          CustomCard(
            padding: EdgeInsets.zero,
            child: Consumer<DataProvider>(
              builder: (context, dataProvider, child) {
                const String currentUserId = 'customer-1'; // Placeholder userId
                final customerVehicles = dataProvider.customerVehicles
                    .where((v) => v['userId'] == currentUserId)
                    .toList();
                final customerQuotes = dataProvider.customerQuotes
                    .where((q) => q['userId'] == currentUserId)
                    .toList();

                final List<Widget> activityTiles = [];

                // Add vehicles to activity
                for (var vehicle in customerVehicles) {
                  activityTiles.add(
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.1),
                        child: Icon(
                          LucideIcons.car,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      title: Text(
                        'Vehicle: ${vehicle['make']} ${vehicle['model']}',
                      ),
                      subtitle: Text('Plate: ${vehicle['plate']}'),
                    ),
                  );
                  activityTiles.add(const Divider(height: 1));
                }

                // Add quotes to activity
                for (var quote in customerQuotes) {
                  activityTiles.add(
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.secondary.withOpacity(0.1),
                        child: Icon(
                          LucideIcons.fileText,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      title: Text('Quote: ${quote['description']}'),
                      subtitle: Text('Status: ${quote['status']}'),
                    ),
                  );
                  activityTiles.add(const Divider(height: 1));
                }

                if (activityTiles.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('No recent activity.'),
                  );
                }

                return ListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: activityTiles,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
