import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_button.dart';
import '../main_scaffold.dart';
import '../../utils/ui_utils.dart';
import 'emergency_tow_screen.dart';

class CustomerDashboard extends StatelessWidget {
  const CustomerDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome back, John!',
            style: Theme.of(context).textTheme.headlineMedium,
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
            child: ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.1),
                    child: Icon(
                      LucideIcons.checkCircle,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  title: const Text('Service Completed: Tesla Model 3'),
                  subtitle: const Text('Yesterday at 4:30 PM'),
                ),
                const Divider(height: 1),
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
                  title: const Text('Quote Approved: Iron 883'),
                  subtitle: const Text('Oct 12, 2026'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
