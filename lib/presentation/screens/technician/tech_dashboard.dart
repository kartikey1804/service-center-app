import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_button.dart';
import '../../utils/ui_utils.dart';
import 'vin_scanner_screen.dart';
import '../../providers/data_provider.dart';
import '../../providers/auth_provider.dart';
import 'tech_chat_screen.dart';

class TechDashboard extends StatefulWidget {
  const TechDashboard({super.key});

  @override
  State<TechDashboard> createState() => _TechDashboardState();
}

class _TechDashboardState extends State<TechDashboard> {
  bool _isClockedIn = false;
  Duration _workedTime = Duration.zero; // Initialize to zero
  DateTime? _clockInTime;
  DateTime? _lastTickTime;
  Timer? _timer;
  String? _currentTechnicianId;

  @override
  void initState() {
    super.initState();
    _isClockedIn = false; 
    _workedTime = Duration.zero;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      setState(() {
        _currentTechnicianId = auth.currentUser?.id ?? 'tech-default';
      });
      if (_isClockedIn) {
        _startTimer();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _lastTickTime = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isClockedIn) {
        _timer?.cancel();
        return;
      }
      final now = DateTime.now();
      setState(() {
        _workedTime += now.difference(_lastTickTime!);
        _lastTickTime = now;
      });
    });
  }

  void _toggleClock() async {
    if (_currentTechnicianId == null) return;
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    setState(() {
      _isClockedIn = !_isClockedIn;
      if (_isClockedIn) {
        _clockInTime = DateTime.now();
        _startTimer();
        dataProvider.recordClockIn(_currentTechnicianId!);
        UiUtils.showToast(context, 'Clocked In!');
      } else {
        _timer?.cancel();
        if (_clockInTime != null) {
          dataProvider.recordClockOut(_currentTechnicianId!, _clockInTime!);
        }
        UiUtils.showToast(context, 'Clocked Out!');
      }
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
              Text(
                'Technician Hub',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Row(
                children: [
                  CustomButton(
                    text: 'Scan VIN',
                    icon: Icons.qr_code_scanner,
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const VinScannerScreen(),
                        ),
                      );
                      if (result != null && result is Map<String, dynamic>) {
                        if (!context.mounted) return;
                        UiUtils.showCustomDialog(
                          context: context,
                          title: 'Vehicle Details',
                          content: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('VIN: ${result['vin']}'),
                              Text('Make: ${result['make']}'),
                              Text('Model: ${result['model']}'),
                              Text('Year: ${result['year']}'),
                              Text('Color: ${result['color']}'),
                              Text('Mileage: ${result['mileage']}'),
                              Text('Engine: ${result['engine']}'),
                              const SizedBox(height: 16),
                              Text(
                                'Service History:',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              ...(result['serviceHistory'] as List).map(
                                (entry) => Text(
                                  '${entry['date']}: ${entry['service']} - ${entry['notes']}',
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Recalls:',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              ...(result['recalls'] as List).map(
                                (entry) => Text(
                                  '${entry['date']}: ${entry['description']}',
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text('Owner History: ${result['ownerHistory']}'),
                            ],
                          ),
                          actions: [
                            CustomButton(
                              text: 'Close',
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        );
                      } else if (result != null) {
                        if (!context.mounted) return;
                        UiUtils.showCustomDialog(
                          context: context,
                          title: 'VIN Scanned',
                          content: Text('Scanned VIN: $result'),
                          actions: [
                            CustomButton(
                              text: 'Close',
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        );
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  Consumer<DataProvider>(
                    builder: (context, dataProvider, child) {
                      final unreadNotifications = dataProvider.notifications
                          .where((n) => !n['isRead'])
                          .length;
                      return Stack(
                        children: [
                          CustomButton(
                            text: 'Notifications',
                            icon: Icons.notifications_none,
                            onPressed: () {
                              UiUtils.showCustomDialog(
                                context: context,
                                title: 'Notifications',
                                content: SizedBox(
                                  width: double.maxFinite,
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount:
                                        dataProvider.notifications.length,
                                    itemBuilder: (context, index) {
                                      final notification =
                                          dataProvider.notifications[index];
                                      return ListTile(
                                        title: Text(notification['title']),
                                        subtitle: Text(notification['time']),
                                        trailing: notification['isRead']
                                            ? null
                                            : const Icon(
                                                Icons.circle,
                                                color: Colors.blue,
                                                size: 10,
                                              ),
                                        onTap: () {
                                          dataProvider.markNotificationAsRead(
                                            notification['id'],
                                          );
                                          UiUtils.showToast(
                                            context,
                                            'Notification marked as read',
                                          );
                                          Navigator.pop(
                                            context,
                                          ); // Close dialog after viewing
                                        },
                                      );
                                    },
                                  ),
                                ),
                                actions: [
                                  CustomButton(
                                    text: 'Close',
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                ],
                              );
                            },
                          ),
                          if (unreadNotifications > 0)
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 20,
                                  minHeight: 20,
                                ),
                                child: Text(
                                  '$unreadNotifications',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  CustomButton(
                    text: 'Internal Chat',
                    icon: Icons.chat,
                    onPressed: () {
                      final dataProvider = Provider.of<DataProvider>(
                        context,
                        listen: false,
                      );
                      // Try to find a conversation for this technician
                      final myChat = dataProvider.chatConversations.firstWhere(
                        (chat) => (chat['participants'] as List).contains(_currentTechnicianId),
                        orElse: () => dataProvider.chatConversations.isNotEmpty 
                            ? dataProvider.chatConversations.first 
                            : {'id': 'internal-general'},
                      );
                      
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TechChatScreen(
                            chatId: myChat['id'],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  CustomBadgeStatus(isClockedIn: _isClockedIn),
                ],
              ),
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
                    Text(
                      'Today\'s Shift',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
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
                      type: _isClockedIn
                          ? ButtonType.danger
                          : ButtonType.primary,
                      onPressed: _toggleClock,
                      icon: _isClockedIn ? Icons.stop : Icons.play_arrow,
                    ),
                  ],
                ),
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
                      const Icon(
                        Icons.check_circle_outline,
                        size: 32,
                        color: Colors.green,
                      ),
                      const SizedBox(height: 8),
                      Consumer<DataProvider>(
                        builder: (context, dataProvider, child) {
                          return FutureBuilder<int>(
                            future: dataProvider.getCompletedJobsCount(
                              technicianId: _currentTechnicianId,
                            ),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              } else if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              } else {
                                return Text(
                                  '${snapshot.data ?? 0}',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.headlineMedium,
                                );
                              }
                            },
                          );
                        },
                      ),
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
                      const Icon(
                        Icons.pending_actions,
                        size: 32,
                        color: Colors.orange,
                      ),
                      const SizedBox(height: 8),
                      Consumer<DataProvider>(
                        builder: (context, dataProvider, child) {
                          return FutureBuilder<int>(
                            future: dataProvider.getPendingJobsCount(
                              technicianId: _currentTechnicianId,
                            ),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              } else if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              } else {
                                return Text(
                                  '${snapshot.data ?? 0}',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.headlineMedium,
                                );
                              }
                            },
                          );
                        },
                      ),
                      const Text('Pending'),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text('Next Job', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          Consumer<DataProvider>(
            builder: (context, dataProvider, child) {
              if (_currentTechnicianId == null) return const CircularProgressIndicator();

              final techJobs = dataProvider.activeJobs.where((job) {
                final techs = job['assignedTechnicians'] as List?;
                return techs != null && techs.contains(_currentTechnicianId);
              }).toList();

              final nextJob = techJobs.isEmpty
                  ? null
                  : techJobs.firstWhere(
                    (j) => j['status'] != 'Ready' && j['status'] != 'Completed',
                    orElse: () => techJobs.first,
                  );

              if (nextJob == null) {
                return const Text('No upcoming jobs.');
              }

              return CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Job ID: ${nextJob['id']}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Vehicle: ${nextJob['vehicle'] ?? 'Unknown'}',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    Text(
                      'Customer: ${nextJob['customer'] ?? 'Unknown'}',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    Text(
                      'Due: ${nextJob['estimatedCompletionTime'] ?? 'Scheduled'}',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16),
                    CustomButton(
                      text: 'View Job Details',
                      onPressed: () {
                        UiUtils.showToast(
                          context,
                          'Navigating to Job ID: ${nextJob['id']}',
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          Text(
            'Assigned Jobs',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Consumer<DataProvider>(
            builder: (context, dataProvider, child) {
              final assignedJobs = dataProvider.activeJobs.where((job) {
                final techs = job['assignedTechnicians'] as List?;
                return techs != null && techs.contains(_currentTechnicianId);
              }).take(3).toList();
              if (assignedJobs.isEmpty) {
                return const Text('No assigned jobs currently.');
              }
              return Column(
                children: assignedJobs.map((job) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: CustomCard(
                      onTap: () {
                        // Navigate to job details screen or show a dialog
                        UiUtils.showToast(
                          context,
                          'Navigating to Job ID: ${job['id']}',
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Job ID: ${job['id']}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Vehicle: ${job['vehicle']}',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          Text(
                            'Customer: ${job['customer']}',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          Text(
                            'Status: ${job['status']}',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 24),
          Text(
            'Parts Request Status',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Consumer<DataProvider>(
            builder: (context, dataProvider, child) {
              final pendingRequests = dataProvider.partsRequests
                  .where((req) => req['status'] != 'Received')
                  .toList();
              if (pendingRequests.isEmpty) {
                return const Text('No pending parts requests.');
              }
              return Column(
                children: pendingRequests.map((request) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: CustomCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Part: ${request['partName']}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Job ID: ${request['jobId']}',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          Text(
                            'Status: ${request['status']}',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          Text(
                            'Requested: ${request['requestDate']}',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 24),
          Text(
            'Performance Metrics',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Consumer<DataProvider>(
            builder: (context, dataProvider, child) {
              final metrics = dataProvider.technicianPerformanceMetrics;
              return Column(
                children: [
                  CustomCard(
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.timer),
                          title: const Text('Avg. Completion Time'),
                          trailing: Text(metrics['averageCompletionTime']),
                        ),
                        ListTile(
                          leading: const Icon(Icons.star),
                          title: const Text('Customer Satisfaction'),
                          trailing: Text(metrics['customerSatisfaction']),
                        ),
                        ListTile(
                          leading: const Icon(Icons.speed),
                          title: const Text('Efficiency Score'),
                          trailing: Text(metrics['efficiencyScore']),
                        ),
                        ListTile(
                          leading: const Icon(Icons.check_circle_outline),
                          title: const Text('Jobs Completed (Last Week)'),
                          trailing: Text('${metrics['jobsCompletedLastWeek']}'),
                        ),
                        ListTile(
                          leading: const Icon(Icons.build),
                          title: const Text('Parts Used (Last Week)'),
                          trailing: Text('${metrics['partsUsedLastWeek']}'),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          Text(
            'Monthly Time Tracking History',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Consumer<DataProvider>(
            builder: (context, dataProvider, child) {
              return FutureBuilder<List<Map<String, dynamic>>>(
                future: _currentTechnicianId == null 
                    ? Future.value([]) 
                    : dataProvider.getMonthlyTimeTrackingHistory(
                        _currentTechnicianId!,
                        DateTime.now().month,
                        DateTime.now().year,
                      ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text('No time tracking data for this month.');
                  } else {
                    return Column(
                      children: snapshot.data!.map((entry) {
                        final clockIn = DateTime.parse(entry['clockInTime']);
                        final clockOut = entry['clockOutTime'] != null
                            ? DateTime.parse(entry['clockOutTime'])
                            : null;
                        final duration = entry['duration'] != null
                            ? '${entry['duration']} minutes'
                            : 'N/A';
                        return CustomCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Clock In: ${clockIn.toLocal().toString().split('.')[0]}',
                              ),
                              Text(
                                'Clock Out: ${clockOut?.toLocal().toString().split('.')[0] ?? 'Still Clocked In'}',
                              ),
                              Text('Duration: $duration'),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class CustomBadgeStatus extends StatelessWidget {
  final bool isClockedIn;
  const CustomBadgeStatus({super.key, required this.isClockedIn});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isClockedIn
            ? Colors.green.withOpacity(0.1)
            : Colors.red.withOpacity(0.1),
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
            style: TextStyle(
              color: isClockedIn ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
