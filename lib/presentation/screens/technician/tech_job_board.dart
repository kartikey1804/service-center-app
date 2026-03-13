import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider_pkg;
import '../../providers/data_provider.dart';
import '../../providers/pipeline_providers.dart';
import '../../../core/pipeline/pipeline_stage.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_badge.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../utils/ui_utils.dart';
import 'package:lucide_icons/lucide_icons.dart';

class TechJobBoard extends ConsumerWidget {
  const TechJobBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataProvider = provider_pkg.Provider.of<DataProvider>(context);
    final jobsState = ref.watch(servicePipelineProvider);

    return jobsState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error: $e')),
      data: (jobs) {
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
                    _buildKanbanColumn(context, ref, 'To Start', jobs, dataProvider),
                    const SizedBox(width: 16),
                    _buildKanbanColumn(context, ref, 'In Progress', jobs, dataProvider),
                    const SizedBox(width: 16),
                    _buildKanbanColumn(context, ref, 'Ready', jobs, dataProvider),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showJobDetails(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> job,
    DataProvider provider,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _JobDetailsSheet(job: job, provider: provider, ref: ref),
    );
  }

  Widget _buildKanbanColumn(
    BuildContext context,
    WidgetRef ref,
    String statusKey,
    List<Map<String, dynamic>> jobs,
    DataProvider dataProvider,
  ) {
    final filteredJobs = jobs
        .where((j) => j['status'] == statusKey)
        .toList();

    return DragTarget<String>(
      onAcceptWithDetails: (details) {
        // Map statusKey to PipelineStageType
        PipelineStageType nextStage;
        PipelineStageType fromStage;
        
        // This is a simplified mapping for the demo UI
        if (statusKey == 'In Progress') {
          fromStage = PipelineStageType.TECHNICIAN_ASSIGNED;
          nextStage = PipelineStageType.SERVICE_STARTED;
        } else if (statusKey == 'Ready') {
          fromStage = PipelineStageType.SERVICE_STARTED;
          nextStage = PipelineStageType.SERVICE_COMPLETED;
        } else {
          return; // Ignore for now or handle reversions
        }

        ref.read(servicePipelineProvider.notifier).transition(
          jobId: details.data,
          from: fromStage,
          to: nextStage,
          userId: 'tech-1', // Mock user for now
        );
        
        UiUtils.showToast(context, 'Pipeline: Moved to $statusKey');
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
                        child: _buildJobCard(context, ref, job, dataProvider),
                      ),
                    ),
                    childWhenDragging: Opacity(
                      opacity: 0.5,
                      child: _buildJobCard(context, ref, job, dataProvider),
                    ),
                    child: _buildJobCard(context, ref, job, dataProvider),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildJobCard(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> job,
    DataProvider dataProvider,
  ) {
    return CustomCard(
      onTap: () => _showJobDetails(context, ref, job, dataProvider),
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
              backgroundColor: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest,
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
    if (status == 'To Start') {
      return const CustomBadge(text: 'To Start', type: BadgeType.gray);
    }
    if (status == 'In Progress') {
      return const CustomBadge(text: 'In Progress', type: BadgeType.blue);
    }
    if (status == 'Ready') {
      return const CustomBadge(text: 'Ready', type: BadgeType.green);
    }
    return CustomBadge(text: status);
  }
}

class _JobDetailsSheet extends StatefulWidget {
  final Map<String, dynamic> job;
  final DataProvider provider;
  final WidgetRef ref;

  const _JobDetailsSheet({
    super.key,
    required this.job,
    required this.provider,
    required this.ref,
  });

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
                    'Assigned Technicians',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  provider_pkg.Consumer<DataProvider>(
                    builder: (context, dataProvider, child) {
                      final assignedTechnicianIds =
                          (widget.job['assignedTechnicians'] as List?)
                              ?.cast<String>() ??
                          [];
                      final assignedTechnicians = dataProvider.staff
                          .where(
                            (staffMember) => assignedTechnicianIds.contains(
                              staffMember['id'],
                            ),
                          )
                          .toList();

                      if (assignedTechnicians.isEmpty) {
                        return const Text('No technicians assigned.');
                      }
                      return Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: assignedTechnicians.map((tech) {
                          return Chip(
                            label: Text(tech['name']),
                            onDeleted: () {
                              widget.provider.removeTechnicianFromJob(
                                widget.job['id'],
                                tech['id'],
                              );
                            },
                          );
                        }).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomButton(
                    text: 'Assign/Reassign Technicians',
                    onPressed: () {
                      final dataProvider = provider_pkg.Provider.of<DataProvider>(
                        context,
                        listen: false,
                      );
                      final allTechnicians = dataProvider.staff;
                      final currentlyAssigned =
                          (widget.job['assignedTechnicians'] as List?)
                              ?.cast<String>() ??
                          [];
                      List<String> selectedTechnicians = List.from(
                        currentlyAssigned,
                      );

                      UiUtils.showCustomDialog(
                        context: context,
                        title: 'Assign Technicians',
                        content: StatefulBuilder(
                          builder:
                              (BuildContext context, StateSetter setState) {
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: allTechnicians.map((tech) {
                                    return CheckboxListTile(
                                      title: Text(tech['name']),
                                      value: selectedTechnicians.contains(
                                        tech['id'],
                                      ),
                                      onChanged: (bool? value) {
                                        setState(() {
                                          if (value == true) {
                                            selectedTechnicians.add(tech['id']);
                                          } else {
                                            selectedTechnicians.remove(
                                              tech['id'],
                                            );
                                          }
                                        });
                                      },
                                    );
                                  }).toList(),
                                );
                              },
                        ),
                        actions: [
                          CustomButton(
                            text: 'Cancel',
                            onPressed: () => Navigator.pop(context),
                          ),
                          CustomButton(
                            text: 'Save',
                            onPressed: () {
                              // Remove technicians no longer selected
                              for (var techId in currentlyAssigned) {
                                if (!selectedTechnicians.contains(techId)) {
                                  widget.provider.removeTechnicianFromJob(
                                    widget.job['id'],
                                    techId,
                                  );
                                }
                              }
                              // Add newly selected technicians
                              for (var techId in selectedTechnicians) {
                                if (!currentlyAssigned.contains(techId)) {
                                  widget.provider.assignTechnicianToJob(
                                    widget.job['id'],
                                    techId,
                                  );
                                }
                              }
                              Navigator.pop(context);
                              UiUtils.showToast(
                                context,
                                'Technicians assigned.',
                              );
                            },
                          ),
                        ],
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
                  }),

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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Parts Requisition',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      CustomButton(
                        text: 'Order Part',
                        icon: Icons.add_shopping_cart,
                        type: ButtonType.secondary,
                        onPressed: () {
                          final TextEditingController partNameController =
                              TextEditingController();
                          UiUtils.showCustomDialog(
                            context: context,
                            title: 'Request Parts to Bay',
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CustomTextField(
                                  controller: partNameController,
                                  label: 'Part Name',
                                  hintText: 'Enter part name...',
                                ),
                                const SizedBox(height: 16),
                                // Display available inventory for selection (mock for now)
                                ...widget.provider.inventory.take(3).map((
                                  item,
                                ) {
                                  return ListTile(
                                    title: Text(item['name']),
                                    subtitle: Text('Stock: ${item['stock']}'),
                                    trailing: CustomButton(
                                      text: 'Request',
                                      onPressed: () {
                                        Navigator.pop(context);
                                        widget.ref.read(partPipelineProvider.notifier).initiate(
                                          requestId: 'PR-${DateTime.now().millisecondsSinceEpoch}',
                                          to: PipelineStageType.PART_REQUISITION_CREATED,
                                          userId: 'tech-1',
                                          data: {
                                            'partName': item['name'],
                                            'jobId': widget.job['id'],
                                            'inventoryId': item['id'],
                                            'priority': 'Medium',
                                            'estimatedPrice': item['price'],
                                          },
                                        );
                                        UiUtils.showToast(
                                          context,
                                          'Requested ${item['name']} via Part Pipeline',
                                        );
                                      },
                                    ),
                                  );
                                }),
                              ],
                            ),
                            actions: [
                              CustomButton(
                                text: 'Cancel',
                                onPressed: () => Navigator.pop(context),
                              ),
                              CustomButton(
                                text: 'Request Custom Part',
                                onPressed: () {
                                  if (partNameController.text.isNotEmpty) {
                                    Navigator.pop(context);
                                    _showPartsDetailsDialog(context, widget.provider, partNameController.text, widget.job['id']);
                                  }
                                },
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Consumer(
                    builder: (context, ref, child) {
                      final partsState = ref.watch(partPipelineProvider);
                      return partsState.when(
                        loading: () => const LinearProgressIndicator(),
                        error: (e, s) => Text('Error loading parts: $e'),
                        data: (parts) {
                          final jobPartsRequests = parts
                              .where((req) => req['jobId'] == widget.job['id'])
                              .toList();
                          if (jobPartsRequests.isEmpty) {
                            return const Text('No parts requested for this job.');
                          }
                           return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: jobPartsRequests.map((request) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: CustomCard(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Part: ${request['partName']}',
                                            style: Theme.of(context).textTheme.titleMedium,
                                          ),
                                          CustomBadge(
                                            text: request['priority'] ?? 'Medium',
                                            type: _getPriorityBadgeType(request['priority']),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Status: ${request['status']}',
                                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                          color: _getStatusColor(request['status']),
                                        ),
                                      ),
                                      Text(
                                        'Est. Price: \$${request['estimatedPrice']}',
                                        style: Theme.of(context).textTheme.bodyMedium,
                                      ),
                                      Text(
                                        'Requested: ${request['requestDate']}',
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        },
                      );
                    },
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
                    })
                  else
                    const Text('No communication logged yet.'),
                  const SizedBox(height: 16),
                  CustomButton(
                    text: 'Add Log Entry',
                    onPressed: () {
                      final TextEditingController logController =
                          TextEditingController();
                      UiUtils.showCustomDialog(
                        context: context,
                        title: 'Add Communication Log',
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CustomTextField(
                              controller: logController,
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
                              initialValue: 'Call',
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
                              if (logController.text.isNotEmpty) {
                                widget.provider.addCustomerCommunicationLogEntry(
                                  widget.job['id'],
                                  'Call', // Defaulting to Call for now, can be dynamic from dropdown
                                  logController.text,
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
                        }),

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
                        : (_isCompletionChecklistComplete() ? 'Complete & Generate Invoice' : 'Update Status'),
                    type: _isCompletionChecklistComplete() ? ButtonType.primary : ButtonType.secondary,
                    onPressed: () async {
                      if (_isCompletionChecklistComplete()) {
                        await widget.ref.read(servicePipelineProvider.notifier).transition(
                          jobId: widget.job['id'],
                          from: PipelineStageType.values.firstWhere((e) => e.name == widget.job['status']),
                          to: PipelineStageType.SERVICE_COMPLETED,
                          userId: 'tech-1',
                        );
                        // Follow up actions like invoice can be triggered by stage listeners or manually
                        await widget.provider.generateInvoice(widget.job['id']);
                        Navigator.pop(context);
                        UiUtils.showToast(context, 'Job Completed & Invoice Generated');
                      } else {
                        await widget.ref.read(servicePipelineProvider.notifier).transition(
                          jobId: widget.job['id'],
                          from: PipelineStageType.values.firstWhere((e) => e.name == widget.job['status'], orElse: () => PipelineStageType.TECHNICIAN_ASSIGNED),
                          to: PipelineStageType.SERVICE_STARTED,
                          userId: 'tech-1',
                        );
                        Navigator.pop(context);
                        UiUtils.showToast(context, 'Job Status Updated');
                      }
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

  void _showPartsDetailsDialog(BuildContext context, DataProvider provider, String partName, String jobId) {
    String priority = 'Medium';
    final priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Request Details: $partName'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: priority,
                decoration: const InputDecoration(labelText: 'Priority Level'),
                items: ['Low', 'Medium', 'High', 'Critical'].map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                onChanged: (val) { if (val != null) setState(() => priority = val); },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Estimated Price', prefixText: '\$'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                await widget.ref.read(servicePipelineProvider.notifier).transition(
                  jobId: jobId,
                  from: PipelineStageType.values.firstWhere((e) => e.name == widget.job['status']),
                  to: PipelineStageType.PART_REQUESTED,
                  userId: 'tech-1',
                  data: {
                    'partName': partName,
                    'priority': priority,
                    'estimatedPrice': double.tryParse(priceController.text) ?? 0.0,
                  },
                );
                Navigator.pop(context);
                UiUtils.showToast(context, 'Parts Request Submitted via Pipeline');
              },
              child: const Text('Submit Request'),
            ),
          ],
        ),
      ),
    );
  }

  BadgeType _getPriorityBadgeType(String? priority) {
    switch (priority) {
      case 'Critical': return BadgeType.red;
      case 'High': return BadgeType.orange;
      case 'Medium': return BadgeType.blue;
      default: return BadgeType.gray;
    }
  }

  Color _getStatusColor(String? status) {
    if (status == 'Approved') return Colors.green;
    if (status == 'Rejected') return Colors.red;
    return Colors.orange;
  }
}
