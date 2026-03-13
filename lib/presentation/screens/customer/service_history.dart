import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as old_provider;
import '../../providers/data_provider.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_badge.dart';
import '../../widgets/custom_button.dart';
import '../../utils/ui_utils.dart';
import 'payment_screen.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/pipeline_providers.dart';
import '../../../core/pipeline/pipeline_stage.dart';

class ServiceHistory extends ConsumerWidget {
  const ServiceHistory({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const String currentUserId = 'customer-1';
    final jobsState = ref.watch(servicePipelineProvider);

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: old_provider.Provider.of<DataProvider>(
        context,
      ).getCustomerQuotes(currentUserId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData && snapshot.data != null) {
          final quotes = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Service Quotes',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 16),
                if (quotes.isEmpty)
                  const Text("No pending quotes.")
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: quotes.length,
                    itemBuilder: (context, index) {
                      final q = quotes[index];
                      final isPending = q['status'] == 'Pending';
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: CustomCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    q['vehicle'],
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleLarge,
                                  ),
                                  CustomBadge(
                                    text: q['status'],
                                    type: isPending
                                        ? BadgeType.yellow
                                        : (q['status'] == 'Approved'
                                              ? BadgeType.green
                                              : BadgeType.red),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                q['description'],
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '\$${q['amount'].toStringAsFixed(2)}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                        ),
                                  ),
                                  if (isPending)
                                    Row(
                                      children: [
                                        CustomButton(
                                          text: 'Deny',
                                          type: ButtonType.secondary,
                                          onPressed: () {
                                            old_provider.Provider.of<DataProvider>(
                                              context,
                                              listen: false,
                                            ).denyQuote(q['id']!);
                                            UiUtils.showToast(
                                              context,
                                              'Quote Denied',
                                              isError: true,
                                            );
                                          },
                                        ),
                                        const SizedBox(width: 8),
                                        CustomButton(
                                          text: 'Approve',
                                          type: ButtonType.primary,
                                          onPressed: () {
                                            old_provider.Provider.of<DataProvider>(
                                              context,
                                              listen: false,
                                            ).approveQuote(q['id']!);
                                            UiUtils.showToast(
                                              context,
                                              'Quote Approved successfully',
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                const SizedBox(height: 32),
                Text(
                  'Service History',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 16),
                jobsState.when(
                  loading: () => const CircularProgressIndicator(),
                  error: (e, s) => Text('Error: $e'),
                  data: (history) {
                    final completedJobs = history
                        .where((j) => (j['status'] == 'Completed' || j['status'] == 'REVIEW_SUBMITTED') && j['customerId'] == currentUserId)
                        .toList();
                    if (completedJobs.isEmpty) return const Text('No completed services yet.');

                    return Column(
                      children: completedJobs.map((job) {
                        final hasReview = job.containsKey('review');
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: CustomCard(
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(job['serviceType'] ?? 'General Service'),
                              subtitle: Text('${job['vehicleId'] ?? 'Vehicle'} • ${job['appointmentDate']}'),
                              trailing: hasReview 
                                ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.star, color: Colors.amber, size: 20),
                                      Text('${job['review']['rating']}'),
                                    ],
                                  )
                                : CustomButton(
                                    text: 'Rate Service',
                                    type: ButtonType.secondary,
                                    onPressed: () => _showRatingDialog(context, ref, job),
                                  ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          );
        } else {
          return const Center(child: Text("No service history found."));
        }
      },
    );
  }

  void _showRatingDialog(BuildContext context, WidgetRef ref, Map<String, dynamic> job) {
    double rating = 5.0;
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Rate Your Service'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) => IconButton(
                  icon: Icon(
                    index < rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                  ),
                  onPressed: () => setState(() => rating = index + 1.0),
                )),
              ),
              TextField(
                controller: commentController,
                decoration: const InputDecoration(hintText: 'Add a comment...'),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                await ref.read(servicePipelineProvider.notifier).transition(
                  jobId: job['id'],
                  from: PipelineStageType.values.firstWhere((e) => e.name == job['status'], orElse: () => PipelineStageType.SERVICE_COMPLETED),
                  to: PipelineStageType.REVIEW_SUBMITTED,
                  userId: 'customer-1',
                  data: {
                    'rating': rating,
                    'comment': commentController.text,
                  },
                );
                Navigator.pop(context);
                UiUtils.showToast(context, 'Thank you for your feedback! Pipeline updated.');
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
