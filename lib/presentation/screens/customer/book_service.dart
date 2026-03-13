import 'package:flutter/material.dart';
import '../../providers/data_provider.dart';
import 'package:provider/provider.dart' as old_provider;
import '../../widgets/custom_card.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../utils/ui_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/pipeline_providers.dart';
import '../../../core/pipeline/pipeline_stage.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import '../main_scaffold.dart';

class BookService extends ConsumerStatefulWidget {
  const BookService({super.key});

  @override
  ConsumerState<BookService> createState() => _BookServiceState();
}

class _BookServiceState extends ConsumerState<BookService> {
  String? _selectedVehicleId;
  String? _selectedDate;
  String? _selectedTime;
  String? _selectedServiceType;
  String? _selectedServiceOption = 'Service Center Visit';
  bool _showOtherServiceField = false;
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _otherServiceController = TextEditingController();

  @override
  void dispose() {
    _otherServiceController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const String currentUserId = 'customer-1';

    return old_provider.Consumer<DataProvider>(
      builder: (context, dataProvider, child) {
        final vehicles = dataProvider.customerVehicles
            .where((v) => v['userId'] == currentUserId)
            .toList();

        // Use WidgetsBinding to initialize state if needed without triggering build-phase side effects
        if (_selectedVehicleId == null && vehicles.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && _selectedVehicleId == null) {
              setState(() {
                _selectedVehicleId = vehicles.first['plate'];
              });
            }
          });
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Book a Service',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 24),
              Text(
                'Service Mode',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Pickup'),
                      value: 'Home Pickup',
                      groupValue: _selectedServiceOption,
                      onChanged: (val) => setState(() => _selectedServiceOption = val),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Visit'),
                      value: 'Service Center Visit',
                      groupValue: _selectedServiceOption,
                      onChanged: (val) => setState(() => _selectedServiceOption = val),
                    ),
                  ),
                ],
              ),
              CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Vehicle',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 8),
                    vehicles.isEmpty
                        ? const Text('Please add a vehicle to your garage first.')
                        : Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              border: Border.all(color: Theme.of(context).dividerColor),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: _selectedVehicleId,
                                items: vehicles.map((v) {
                                  return DropdownMenuItem<String>(
                                    value: v['plate'],
                                    child: Text('${v['make']} ${v['model']} (${v['plate']})'),
                                  );
                                }).toList(),
                                onChanged: (val) => setState(() => _selectedVehicleId = val),
                              ),
                            ),
                          ),
                    const SizedBox(height: 16),
                    Text(
                      'Service Type',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Theme.of(context).dividerColor),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: _selectedServiceType,
                          hint: const Text('Select Service Type'),
                          items: [
                            'General Service',
                            'Repairing',
                            'Washing',
                            'Detailing',
                            'Denting',
                            'Other'
                          ].map((String value) => DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    ))
                              .toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedServiceType = val;
                              _showOtherServiceField = (val == 'Other');
                            });
                          },
                        ),
                      ),
                    ),
                    if (_showOtherServiceField) ...[
                      const SizedBox(height: 16),
                      CustomTextField(
                        label: 'Describe your required service',
                        hintText: 'e.g., Engine making clicking sound',
                        controller: _otherServiceController,
                      ),
                    ],
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Appointment Date',
                      hintText: 'Select Date',
                      readOnly: true,
                      controller: _dateController,
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 30)),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            _selectedDate =
                                "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                            _dateController.text = _selectedDate!;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Time Slot',
                      hintText: 'Select Time',
                      readOnly: true,
                      controller: TextEditingController(text: _selectedTime ?? ''),
                      onTap: () async {
                        TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (pickedTime != null) {
                          setState(() => _selectedTime = pickedTime.format(context));
                        }
                      },
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              CustomButton(
                text: 'Schedule Appointment',
                isFullWidth: true,
                onPressed: () async {
                  if (_selectedServiceType == null ||
                      _selectedVehicleId == null ||
                      _selectedDate == null ||
                      _selectedTime == null ||
                      _selectedServiceOption == null) {
                    UiUtils.showToast(context, 'Please fill all mandatory fields');
                    return;
                  }
                  if (_selectedServiceType == 'Other' &&
                      _otherServiceController.text.isEmpty) {
                    UiUtils.showToast(context, 'Please describe your required service');
                    return;
                  }

                  final requestData = {
                    'customerId': currentUserId,
                    'vehicleId': _selectedVehicleId,
                    'serviceType': _selectedServiceType,
                    'description': _otherServiceController.text,
                    'mode': _selectedServiceOption,
                    'appointmentDate': _selectedDate,
                    'timeSlot': _selectedTime,
                    'status': 'Pending Approval',
                  };
                  
                  final jobId = 'J-${DateTime.now().millisecondsSinceEpoch}';

                  await ref.read(servicePipelineProvider.notifier).initiate(
                    jobId: jobId,
                    to: PipelineStageType.BOOKING_CREATED,
                    userId: currentUserId,
                    data: requestData,
                  );

                  // Update DataProvider local state so the UI reflects the new job
                  await old_provider.Provider.of<DataProvider>(context, listen: false)
                      .addServiceRequest({...requestData, 'id': jobId});


                  // Ensure we show toast before navigation
                  if (context.mounted) {
                    UiUtils.showToast(context, 'Appointment scheduled successfully!');
                    context.findAncestorStateOfType<MainScaffoldState>()?.setTab(0);
                  }
                },
              ),
              const SizedBox(height: 48),
              Text(
                'Live Emergency Tracking',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              CustomCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    Container(
                      height: 200,
                      width: double.infinity,
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      child: const Center(
                        child: Icon(Icons.map, size: 64, color: Colors.grey),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tow Truck en route',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 4),
                              const Text('ETA: 15 mins • Driver: Mike'),
                            ],
                          ),
                          const Icon(Icons.location_on, color: Colors.red),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
