import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/data_provider.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_badge.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../utils/ui_utils.dart';

class TechJobBoard extends StatelessWidget {
  const TechJobBoard({Key? key}) : super(key: key);

  void _showJobDetails(
    BuildContext context,
    Map<String, dynamic> job,
    DataProvider provider,
  ) {
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
              Text(
                'Job Board',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const Text(
                'Drag & Drop cards to update status',
                style: TextStyle(color: Colors.grey),
              ),
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
          ),
        ],
      ),
    );
  }

  Widget _buildKanbanColumn(
    BuildContext context,
    String statusKey,
    DataProvider dataProvider,
  ) {
    final jobs = dataProvider.activeJobs
        .where((j) => j['status'] == statusKey)
        .toList();

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
              color: isHovered
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).dividerColor,
              width: isHovered ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    statusKey,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  CustomBadge(text: '${jobs.length}', type: BadgeType.gray),
                ],
              ),
              const SizedBox(height: 16),
              if (jobs.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: Text(
                      'Drop jobs here.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
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

  Widget _buildJobCard(
    BuildContext context,
    Map<String, dynamic> job,
    DataProvider dataProvider,
  ) {
    return CustomCard(
      onTap: () => _showJobDetails(context, job, dataProvider),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                job['id'],
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              _buildStatusBadge(job['status']),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (job['image'] != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.asset(
                    job['image'],
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                ),
              if (job['image'] != null) const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job['service'],
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      job['vehicle'],
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      job['customer'],
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(job['date'], style: Theme.of(context).textTheme.bodySmall),
              if (job.containsKey('estimatedCompletionTime'))
                Text(
                  'Est: ${job['estimatedCompletionTime']}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                ),
              Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: Theme.of(context).dividerColor,
              ),
            ],
          ),
          if (job.containsKey('inspectionChecklist')) ...[
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value:
                  (job['inspectionChecklist'] as Map<String, bool>).values
                      .where((e) => e)
                      .length /
                  (job['inspectionChecklist'] as Map<String, bool>).length,
              backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 4),
            Text(
              'Inspection Progress: ${((job['inspectionChecklist'] as Map<String, bool>).values.where((e) => e).length / (job['inspectionChecklist'] as Map<String, bool>).length * 100).toInt()}%',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    if (status == 'To Start')
      return const CustomBadge(text: 'To Start', type: BadgeType.gray);
    if (status == 'In Progress')
      return const CustomBadge(text: 'In Progress', type: BadgeType.blue);
    if (status == 'Ready')
      return const CustomBadge(text: 'Ready', type: BadgeType.green);
    return CustomBadge(text: status);
  }
}

class _JobDetailsSheet extends StatefulWidget {
  final Map<String, dynamic> job;
  final DataProvider provider;

  const _JobDetailsSheet({Key? key, required this.job, required this.provider})
    : super(key: key);

  @override
  State<_JobDetailsSheet> createState() => _JobDetailsSheetState();
}

class _JobDetailsSheetState extends State<_JobDetailsSheet> {
  late Map<String, bool> _checklist;
  late TextEditingController _estimatedTimeController;

  @override
  void initState() {
    super.initState();
    _checklist = Map<String, bool>.from(
      widget.job['inspectionChecklist'] ?? {},
    );
    _estimatedTimeController = TextEditingController(
      text: widget.job['estimatedCompletionTime'] ?? 'N/A',
    );
  }

  @override
  void dispose() {
    _estimatedTimeController.dispose();
    super.dispose();
  }

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
              border: Border(
                bottom: BorderSide(color: Theme.of(context).dividerColor),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.job['id'],
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    Text(
                      widget.job['service'],
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Vehicle Details',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.job['vehicle']} • Owned by ${widget.job['customer']}',
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Estimated Completion Time',
                    controller: _estimatedTimeController,
                    onChanged: (value) {
                      widget.provider.updateJobEstimatedTime(
                        widget.job['id'],
                        value,
                      );
                    },
                  ),
                  const SizedBox(height: 32),

                  Text(
                    'Multi-Point Inspection',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  ..._checklist.keys.map((key) {
                    return CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(key),
                      value: _checklist[key],
                      activeColor: Theme.of(context).colorScheme.primary,
                      onChanged: (val) {
                        setState(() {
                          _checklist[key] = val ?? false;
                        });
                        widget.provider.updateInspectionChecklistItem(
                          widget.job['id'],
                          key,
                          val ?? false,
                        );
                      },
                    );
                  }).toList(),

                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Evidence Upload',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () {
                      UiUtils.showToast(
                        context,
                        'Mock Camera/Gallery opening...',
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.05),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary,
                          style: BorderStyle.solid,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.camera_alt,
                            size: 48,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap to upload photos/video',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  Text(
                    'Customer Communication Log',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  if (widget.job.containsKey('customerCommunicationLog') &&
                      (widget.job['customerCommunicationLog'] as List)
                          .isNotEmpty)
                    ...(widget.job['customerCommunicationLog'] as List).map((
                      entry,
                    ) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: CustomCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${entry['type']} - ${entry['timestamp']}',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: Colors.grey),
                              ),
                              const SizedBox(height: 4),
                              Text(entry['message']),
                            ],
                          ),
                        ),
                      );
                    }).toList()
                  else
                    const Text('No communication logged yet.'),
                  const SizedBox(height: 16),
                  CustomButton(
                    text: 'Add Log Entry',
                    onPressed: () {
                      final TextEditingController _logController =
                          TextEditingController();
                      UiUtils.showCustomDialog(
                        context: context,
                        title: 'Add Communication Log',
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CustomTextField(
                              controller: _logController,
                              label: 'Message',
                              hintText: 'Enter communication details...',
                              maxLines: 3,
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                labelText: 'Communication Type',
                                border: OutlineInputBorder(),
                              ),
                              value: 'Call',
                              items: ['Call', 'SMS', 'Email', 'In-Person'].map((
                                type,
                              ) {
                                return DropdownMenuItem(
                                  value: type,
                                  child: Text(type),
                                );
                              }).toList(),
                              onChanged: (value) {
                                // Handle type change if needed
                              },
                            ),
                          ],
                        ),
                        actions: [
                          CustomButton(
                            text: 'Cancel',
                            onPressed: () => Navigator.pop(context),
                          ),
                          CustomButton(
                            text: 'Add',
                            onPressed: () {
                              if (_logController.text.isNotEmpty) {
                                widget.provider.addCustomerCommunicationLogEntry(
                                  widget.job['id'],
                                  'Call', // Defaulting to Call for now, can be dynamic from dropdown
                                  _logController.text,
                                );
                                Navigator.pop(context);
                                UiUtils.showToast(
                                  context,
                                  'Communication log added.',
                                );
                              }
                            },
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 32),

                  Text(
                    'Job Completion Checklist',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  if (widget.job.containsKey('completionChecklist'))
                    ...(widget.job['completionChecklist'] as Map<String, bool>)
                        .keys
                        .map((key) {
                          return CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(key),
                            value:
                                (widget.job['completionChecklist']
                                    as Map<String, bool>)[key],
                            activeColor: Theme.of(context).colorScheme.primary,
                            onChanged: (val) {
                              widget.provider.updateCompletionChecklistItem(
                                widget.job['id'],
                                key,
                                val ?? false,
                              );
                            },
                          );
                        })
                        .toList(),

                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: 'Complete Job',
                          type: ButtonType.primary,
                          onPressed: _isCompletionChecklistComplete()
                              ? () {
                                  widget.provider.updateJobStatus(
                                    widget.job['id'],
                                    'Completed',
                                  );
                                  Navigator.pop(context);
                                  UiUtils.showToast(
                                    context,
                                    'Job Marked as Completed!',
                                  );
                                }
                              : null, // Disable button if checklist not complete
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Theme.of(context).dividerColor),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: widget.job['status'] == 'Ready'
                        ? 'Mark In Progress'
                        : 'Update Status',
                    type: ButtonType.secondary,
                    onPressed: () {
                      widget.provider.updateJobStatus(
                        widget.job['id'],
                        'In Progress',
                      );
                      Navigator.pop(context);
                      UiUtils.showToast(context, 'Job Status Updated');
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _isCompletionChecklistComplete() {
    if (!widget.job.containsKey('completionChecklist')) return false;
    return (widget.job['completionChecklist'] as Map<String, bool>).values
        .every((element) => element);
  }
}
