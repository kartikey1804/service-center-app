import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/data_provider.dart';
import '../../widgets/custom_card.dart';
import 'package:service_center_app/presentation/widgets/custom_dropdown.dart';
import 'package:service_center_app/presentation/widgets/custom_textfield.dart';
import '../../utils/ui_utils.dart';

class HqAnalytics extends StatefulWidget {
  const HqAnalytics({super.key});

  @override
  State<HqAnalytics> createState() => _HqAnalyticsState();
}

class _HqAnalyticsState extends State<HqAnalytics> {
  String _branch = 'All Branches';
  String _service = 'All Services';
  String _time = 'Last 7 Days';

  late TextEditingController _storeNameController;
  late TextEditingController _contactEmailController;
  late TextEditingController _phoneNumberController;

  @override
  void initState() {
    super.initState();
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    _storeNameController = TextEditingController(text: dataProvider.storeName);
    _contactEmailController = TextEditingController(
      text: 'contact@servicecenter.com', // Keep for now, but remove "Mock" context
    );
    _phoneNumberController = TextEditingController(text: '+1 (555) 123-4567');
  }

  @override
  void dispose() {
    _storeNameController.dispose();
    _contactEmailController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }


  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    Color color,
  ) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'HQ Analytics',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: CustomDropdown(
                  value: _branch,
                  items: const ['All Branches', 'Branch A', 'Branch B'],
                  onChanged: (val) {
                    setState(() {
                      _branch = val!;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomDropdown(
                  value: _service,
                  items: const ['All Services', 'Oil Change', 'Tire Rotation'],
                  onChanged: (val) {
                    setState(() {
                      _service = val!;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomDropdown(
                  value: _time,
                  items: const ['Last 7 Days', 'This Month', 'Year to Date'],
                  onChanged: (val) {
                    setState(() {
                      _time = val!;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Consumer<DataProvider>(
            builder: (context, dataProvider, child) {
              return FutureBuilder<List<int>>(
                future: Future.wait([
                  dataProvider.getCompletedJobsCount(),
                  dataProvider.getPendingJobsCount(),
                ]),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (snapshot.hasData && snapshot.data != null) {
                    final completedJobs = snapshot.data![0];
                    final pendingJobs = snapshot.data![1];
                    return GridView.count(
                      crossAxisCount: MediaQuery.of(context).size.width > 800
                          ? 4
                          : 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 1.5,
                      children: [
                        _buildStatCard(
                          context,
                          'Completed Jobs',
                          '$completedJobs',
                          Colors.green,
                        ),
                        _buildStatCard(
                          context,
                          'Pending Jobs',
                          '$pendingJobs',
                          Colors.orange,
                        ),
                      ],
                    );
                  } else {
                    return const Text('No job data available.');
                  }
                },
              );
            },
          ),
          const SizedBox(height: 32),
          Text(
            'Revenue Overview',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Consumer<DataProvider>(
            builder: (context, dataProvider, child) {
              return FutureBuilder<Map<String, double>>(
                future: dataProvider.getRevenueOverTime(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (snapshot.hasData && snapshot.data != null) {
                    final revenueData = snapshot.data!;
                    final List<BarChartGroupData> barGroups = [];
                    double maxY = 0;

                    // Sort dates to ensure correct order on the chart
                    final sortedDates = revenueData.keys.toList()..sort();

                    for (int i = 0; i < sortedDates.length; i++) {
                      final date = sortedDates[i];
                      final revenue = revenueData[date] ?? 0;
                      barGroups.add(
                        BarChartGroupData(
                          x: i,
                          barRods: [
                            BarChartRodData(
                              toY: revenue,
                              color: Theme.of(context).colorScheme.primary,
                              width: 16,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ],
                        ),
                      );
                      if (revenue > maxY) {
                        maxY = revenue;
                      }
                    }

                    return CustomCard(
                      child: SizedBox(
                        height: 300,
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: maxY * 1.2, // Add some padding to the top
                            barTouchData: BarTouchData(
                              enabled: true,
                              touchTooltipData: BarTouchTooltipData(
                                getTooltipColor: (_) =>
                                    Theme.of(context).colorScheme.surface,
                                getTooltipItem:
                                    (group, groupIndex, rod, rodIndex) {
                                      return BarTooltipItem(
                                        '\$${rod.toY.round()}',
                                        TextStyle(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      );
                                    },
                              ),
                            ),
                            titlesData: FlTitlesData(
                              show: true,
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (double value, TitleMeta meta) {
                                    final index = value.toInt();
                                    if (index >= 0 &&
                                        index < sortedDates.length) {
                                      final date = sortedDates[index];
                                      // Display only day for brevity, e.g., "12" from "2026-03-12"
                                      final day = date.split('-').last;
                                      return SideTitleWidget(
                                        meta: meta,
                                        child: Text(
                                          day,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      );
                                    }
                                    return const Text('');
                                  },
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 40,
                                  getTitlesWidget:
                                      (double value, TitleMeta meta) {
                                        return Text(
                                          '\$${(value / 1000).toInt()}k',
                                          style: const TextStyle(fontSize: 10),
                                        );
                                      },
                                ),
                              ),
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            barGroups: barGroups,
                          ),
                        ),
                      ),
                    );
                  } else {
                    return const CustomCard(
                      child: SizedBox(
                        height: 300,
                        child: Center(
                          child: Text('No revenue data available.'),
                        ),
                      ),
                    );
                  }
                },
              );
            },
          ),
          const SizedBox(height: 32),
          Text('Employee Performance', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          Consumer<DataProvider>(
            builder: (context, dataProvider, child) {
              final staff = dataProvider.staff;
              return CustomCard(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Name')),
                      DataColumn(label: Text('Role')),
                      DataColumn(label: Text('Jobs Done')),
                      DataColumn(label: Text('Time Spent')),
                      DataColumn(label: Text('Status')),
                    ],
                    rows: staff.map((member) {
                      final jobsDone = dataProvider.activeJobs.where((j) => 
                        (j['assignedTechnicians'] as List?)?.contains(member['id']) ?? false && 
                        j['status'] == 'Completed'
                      ).length;
                      
                      return DataRow(cells: [
                        DataCell(Text(member['name'] ?? 'N/A')),
                        DataCell(Text(member['role'] ?? 'N/A')),
                        DataCell(Text('$jobsDone')),
                        DataCell(Text(member['hours'] ?? '0h')),
                        DataCell(Row(
                          children: [
                            Icon(Icons.circle, size: 10, color: member['status'] == 'Active' ? Colors.green : Colors.grey),
                            const SizedBox(width: 4),
                            Text(member['status'] ?? 'Offline'),
                          ],
                        )),
                      ]);
                    }).toList(),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 32),
          Text('Emergency Tow Analytics', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          Consumer<DataProvider>(
            builder: (context, dataProvider, child) {
              final tows = dataProvider.towRequests;
              final accepted = tows.where((t) => t['status'] == 'Approved' || t['status'] == 'In Progress').length;
              final rejected = tows.where((t) => t['status'] == 'Rejected').length;

              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: _buildStatCard(context, 'Accepted', '$accepted', Colors.green)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildStatCard(context, 'Rejected', '$rejected', Colors.red)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (rejected > 0)
                    CustomCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Rejection Reasons', style: Theme.of(context).textTheme.titleMedium),
                          const Divider(),
                          ...tows.where((t) => t['status'] == 'Rejected').map((t) => ListTile(
                            title: Text(t['id'] ?? 'Unknown ID'),
                            subtitle: Text(t['rejectionReason'] ?? 'No reason provided'),
                            trailing: Text(t['createdAt']?.toString().split('T').first ?? ''),
                            dense: true,
                          )),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 32),
          Text('Attendance Overview', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          Consumer<DataProvider>(
            builder: (context, dataProvider, child) {
              return CustomCard(
                child: Column(
                  children: dataProvider.staff.map((member) {
                    return ListTile(
                      leading: CircleAvatar(child: Text(member['name']?[0] ?? 'E')),
                      title: Text(member['name'] ?? 'Unknown'),
                      subtitle: Text('Role: ${member['role']}'),
                      trailing: Text(member['status'] ?? 'Offline', style: TextStyle(
                        color: member['status'] == 'Active' ? Colors.green : Colors.grey,
                        fontWeight: FontWeight.bold,
                      )),
                    );
                  }).toList(),
                ),
              );
            },
          ),
          const SizedBox(height: 32),
          Text('Store Settings', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Store Name',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                CustomTextField(
                  controller: _storeNameController,
                  label: 'Store Name',
                  onChanged: (value) {
                    Provider.of<DataProvider>(context, listen: false).updateStoreName(value);
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  'Contact Email',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                CustomTextField(
                  controller: _contactEmailController,
                  label: 'Contact Email',
                  onChanged: (value) {
                    UiUtils.showToast(
                      context,
                      'Contact email updated to $value',
                    );
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  'Phone Number',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                CustomTextField(
                  controller: _phoneNumberController,
                  label: 'Phone Number',
                  onChanged: (value) {
                    UiUtils.showToast(
                      context,
                      'Phone number updated to $value',
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
