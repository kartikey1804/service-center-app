import 'package:flutter/material.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_button.dart';
import '../../utils/ui_utils.dart';
import 'vin_scanner_screen.dart';

class TechDashboard extends StatefulWidget {
  const TechDashboard({Key? key}) : super(key: key);

  @override
  State<TechDashboard> createState() => _TechDashboardState();
}

class _TechDashboardState extends State<TechDashboard> {
  bool _isClockedIn = false;
  Duration _workedTime = const Duration(hours: 3, minutes: 45); // Mock

  void _toggleClock() {
    setState(() {
      _isClockedIn = !_isClockedIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Technician Hub', style: Theme.of(context).textTheme.headlineMedium),
              Row(
                children: [
                  CustomButton(
                    text: 'Scan VIN',
                    icon: Icons.qr_code_scanner,
                    onPressed: () async {
                       final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const VinScannerScreen()));
                       if (result != null) {
                          if (!context.mounted) return;
                          UiUtils.showCustomDialog(
                            context: context,
                            title: 'Vehicle Found',
                            content: Text('Details pulled for VIN: $result'),
                            actions: [CustomButton(text: 'Close', onPressed: () => Navigator.pop(context))]
                          );
                       }
                    },
                  ),
                  const SizedBox(width: 8),
                  CustomBadgeStatus(isClockedIn: _isClockedIn),
                ],
              )
            ],
          ),
          const SizedBox(height: 24),
          CustomCard(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Today\'s Shift', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 4),
                    Text(
                      _isClockedIn ? 'Clocked In' : 'Clocked Out',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: _isClockedIn ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      '${_workedTime.inHours}h ${_workedTime.inMinutes % 60}m',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(width: 16),
                    CustomButton(
                      text: _isClockedIn ? 'Clock Out' : 'Clock In',
                      type: _isClockedIn ? ButtonType.danger : ButtonType.primary,
                      onPressed: _toggleClock,
                      icon: _isClockedIn ? Icons.stop : Icons.play_arrow,
                    )
                  ],
                )
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('Key Metrics', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: CustomCard(
                  child: Column(
                    children: [
                      const Icon(Icons.check_circle_outline, size: 32, color: Colors.green),
                      const SizedBox(height: 8),
                      Text('4', style: Theme.of(context).textTheme.headlineMedium),
                      const Text('Completed'),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomCard(
                  child: Column(
                    children: [
                      const Icon(Icons.pending_actions, size: 32, color: Colors.orange),
                      const SizedBox(height: 8),
                      Text('2', style: Theme.of(context).textTheme.headlineMedium),
                      const Text('Pending'),
                    ],
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class CustomBadgeStatus extends StatelessWidget {
  final bool isClockedIn;
  const CustomBadgeStatus({Key? key, required this.isClockedIn}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isClockedIn ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isClockedIn ? Colors.green : Colors.red),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isClockedIn ? Colors.green : Colors.red,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            isClockedIn ? 'Active' : 'Offline',
            style: TextStyle(color: isClockedIn ? Colors.green : Colors.red, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
