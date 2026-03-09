import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/data_provider.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_badge.dart';
import '../../widgets/custom_button.dart';
import '../../utils/ui_utils.dart';

class TechJobBoard extends StatelessWidget {
  const TechJobBoard({Key? key}) : super(key: key);

  void _showJobDetails(BuildContext context, Map<String, dynamic> job, DataProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _JobDetailsSheet(job: job, provider: provider),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context);
    final jobs = dataProvider.activeJobs;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Job Board', style: Theme.of(context).textTheme.headlineMedium),
              const Text('Drag & Drop cards to update status', style: TextStyle(color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 24),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildKanbanColumn(context, 'To Start', dataProvider),
                const SizedBox(width: 16),
                _buildKanbanColumn(context, 'In Progress', dataProvider),
                const SizedBox(width: 16),
                _buildKanbanColumn(context, 'Ready', dataProvider),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildKanbanColumn(BuildContext context, String statusKey, DataProvider dataProvider) {
    final jobs = dataProvider.activeJobs.where((j) => j['status'] == statusKey).toList();

    return DragTarget<String>(
      onAcceptWithDetails: (details) {
        dataProvider.updateJobStatus(details.data, statusKey);
        UiUtils.showToast(context, 'Moved to $statusKey');
      },
      builder: (context, candidateData, rejectedData) {
        final isHovered = candidateData.isNotEmpty;
        return Container(
          width: 320,
          padding: const EdgeInsets.all(16),
          constraints: const BoxConstraints(minHeight: 400),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isHovered ? Theme.of(context).colorScheme.primary : Theme.of(context).dividerColor,
              width: isHovered ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(statusKey, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  CustomBadge(text: '${jobs.length}', type: BadgeType.gray),
                ],
              ),
              const SizedBox(height: 16),
              if (jobs.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(child: Text('Drop jobs here.', style: TextStyle(color: Colors.grey))),
                ),
              ...jobs.map((job) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Draggable<String>(
                    data: job['id'],
                    feedback: Material(
                      type: MaterialType.transparency,
                      child: SizedBox(
                        width: 288, // 320 - 32 padding
                        child: _buildJobCard(context, job, dataProvider),
                      ),
                    ),
                    childWhenDragging: Opacity(
                      opacity: 0.5,
                      child: _buildJobCard(context, job, dataProvider),
                    ),
                    child: _buildJobCard(context, job, dataProvider),
                  ),
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildJobCard(BuildContext context, Map<String, dynamic> job, DataProvider dataProvider) {
    return CustomCard(
      onTap: () => _showJobDetails(context, job, dataProvider),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(job['id'], style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.primary)),
              _buildStatusBadge(job['status']),
            ],
          ),
          const SizedBox(height: 8),
          Text(job['service'], style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text('${job['vehicle']} • ${job['customer']}'),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(job['date'], style: Theme.of(context).textTheme.bodySmall),
              Icon(Icons.arrow_forward_ios, size: 16, color: Theme.of(context).dividerColor),
            ],
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

class _JobDetailsSheet extends StatefulWidget {
  final Map<String, dynamic> job;
  final DataProvider provider;

  const _JobDetailsSheet({Key? key, required this.job, required this.provider}) : super(key: key);

  @override
  State<_JobDetailsSheet> createState() => _JobDetailsSheetState();
}

class _JobDetailsSheetState extends State<_JobDetailsSheet> {
  final Map<String, bool> _checklist = {
    'Check Engine Oil': true,
    'Inspect Brake Pads': false,
    'Check Tire Pressure': false,
    'Test Battery Health': false,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.job['id'], style: Theme.of(context).textTheme.labelLarge),
                    Text(widget.job['service'], style: Theme.of(context).textTheme.headlineSmall),
                  ],
                ),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Vehicle Details', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text('${widget.job['vehicle']} • Owned by ${widget.job['customer']}'),
                  const SizedBox(height: 32),
                  
                  Text('Multi-Point Inspection', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  ..._checklist.keys.map((key) {
                    return CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(key),
                      value: _checklist[key],
                      activeColor: Theme.of(context).colorScheme.primary,
                      onChanged: (val) {
                        setState(() { _checklist[key] = val ?? false; });
                      },
                    );
                  }).toList(),
                  
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Evidence Upload', style: Theme.of(context).textTheme.titleLarge),
                    ],
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () {
                       UiUtils.showToast(context, 'Mock Camera/Gallery opening...');
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
                        border: Border.all(color: Theme.of(context).colorScheme.primary, style: BorderStyle.solid),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.camera_alt, size: 48, color: Theme.of(context).colorScheme.primary),
                          const SizedBox(height: 8),
                          Text('Tap to upload photos/video', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                       Text('Parts Requisition', style: Theme.of(context).textTheme.titleLarge),
                       CustomButton(
                         text: 'Order Part',
                         icon: Icons.add_shopping_cart,
                         type: ButtonType.secondary,
                         onPressed: () {
                            UiUtils.showCustomDialog(
                              context: context,
                              title: 'Request Parts to Bay',
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ...widget.provider.inventory.take(3).map((item) {
                                    return ListTile(
                                      title: Text(item['name']),
                                      subtitle: Text('Stock: ${item['stock']}'),
                                      trailing: CustomButton(
                                        text: 'Request',
                                        onPressed: () {
                                          Navigator.pop(context);
                                          UiUtils.showToast(context, 'Requested ${item['name']} from Inventory');
                                        }
                                      ),
                                    );
                                  })
                                ]
                              ),
                              actions: [CustomButton(text: 'Cancel', onPressed: () => Navigator.pop(context))]
                            );
                         }
                       )
                    ],
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: widget.job['status'] == 'Ready' ? 'Completed' : 'Mark In Progress',
                    type: ButtonType.primary,
                    onPressed: () {
                       widget.provider.updateJobStatus(widget.job['id'], 'In Progress');
                       Navigator.pop(context);
                       UiUtils.showToast(context, 'Job Status Updated');
                    },
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
