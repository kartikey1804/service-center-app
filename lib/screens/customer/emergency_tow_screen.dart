import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_textfield.dart';
import '../../utils/ui_utils.dart';
import '../../providers/data_provider.dart';
import '../main_scaffold.dart';

class EmergencyTowScreen extends StatefulWidget {
  const EmergencyTowScreen({Key? key}) : super(key: key);

  @override
  State<EmergencyTowScreen> createState() => _EmergencyTowScreenState();
}

class _EmergencyTowScreenState extends State<EmergencyTowScreen> {
  int _currentStep = 0;
  String? _selectedVehicle;
  String _vehicleNumber = '';
  String _reasonForTowing = 'Breakdown';
  String _contactNumber = '';
  String _otp = '';
  bool _otpSent = false;
  bool _managerApproved = false;
  bool _towDispatched = false;
  String _latitude = '';
  String _longitude = '';
  String _searchPlace = '';
  bool _isNewVehicle = false;
  int _managerApprovalTimeLeft = 1; // 1 second for demo
  Timer? _managerApprovalTimer;
  int _eta = 15; // Initial ETA in minutes
  Timer? _etaTimer;

  @override
  void dispose() {
    _managerApprovalTimer?.cancel();
    _etaTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vehicles = Provider.of<DataProvider>(context).customerVehicles;
    final vehicleOptions = vehicles.isEmpty
        ? <String>['No vehicles']
        : vehicles.map((v) => '${v['make']} ${v['model']}').toList();

    if (_selectedVehicle == null && vehicleOptions.isNotEmpty) {
      _selectedVehicle = vehicleOptions.first;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Emergency Towing Request')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Get immediate assistance. Complete the steps below.',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStepIndicator(0, 'Vehicle Details'),
                _buildStepIndicator(1, 'Location Details'),
                _buildStepIndicator(2, 'Verification'),
                _buildStepIndicator(3, 'Assignment'),
              ],
            ),
            const SizedBox(height: 32),
            CustomCard(child: _buildStepContent(context, vehicleOptions)),
            const SizedBox(height: 24),
            _buildNavigationButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator(int step, String title) {
    final isActive = _currentStep >= step;
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: isActive
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
          child: Text(
            '${step + 1}',
            style: TextStyle(
              color: isActive
                  ? Colors.white
                  : Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            color: isActive ? Theme.of(context).colorScheme.primary : null,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildStepContent(BuildContext context, List<String> vehicleOptions) {
    List<String> currentVehicleOptions = List.from(vehicleOptions);
    if (!currentVehicleOptions.contains('Add New Vehicle')) {
      currentVehicleOptions.add('Add New Vehicle');
    }

    switch (_currentStep) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Upload Vehicle Image',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Choose File',
                    type: ButtonType.secondary,
                    onPressed: () {
                      UiUtils.showToast(context, 'Mock file picker opening...');
                    },
                  ),
                ),
                const SizedBox(width: 16),
                const Text('No file chosen'),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Select Vehicle',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: _selectedVehicle,
                items: currentVehicleOptions
                    .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedVehicle = val;
                    _isNewVehicle = (val == 'Add New Vehicle');
                  });
                },
              ),
            ),
            if (_isNewVehicle) ...[
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Vehicle Number',
                hintText: 'e.g., MH12AB1234',
                onChanged: (val) => setState(() => _vehicleNumber = val),
              ),
              const SizedBox(height: 16),
              CustomButton(
                text: 'Simulate OCR',
                type: ButtonType.secondary,
                onPressed: () {
                  UiUtils.showToast(context, 'Simulating OCR...');
                  setState(() {
                    _vehicleNumber = 'MH12AB1234'; // Mock OCR result
                  });
                },
              ),
            ] else ...[
              const SizedBox(height: 24),
              CustomTextField(
                label: 'Vehicle Number',
                hintText: 'e.g., MH12AB1234',
                onChanged: (val) => setState(() => _vehicleNumber = val),
                controller: TextEditingController(text: _vehicleNumber),
              ),
              const SizedBox(height: 16),
              CustomButton(
                text: 'Simulate OCR',
                type: ButtonType.secondary,
                onPressed: () {
                  UiUtils.showToast(context, 'Simulating OCR...');
                  setState(() {
                    _vehicleNumber = 'MH12AB1234'; // Mock OCR result
                  });
                },
              ),
            ],
            const SizedBox(height: 24),
            Text(
              'Reason for Towing',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: _reasonForTowing,
                items: <String>['Breakdown', 'Accident', 'Flat Tire', 'Other']
                    .map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    })
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    _reasonForTowing = val!;
                  });
                },
              ),
            ),
          ],
        );
      case 1: // Location Details
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Location Details',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            CustomButton(
              text: 'Use Current Location (Mock)',
              onPressed: () {
                UiUtils.showToast(context, 'Fetching current location...');
                setState(() {
                  _latitude = '34.0522';
                  _longitude = '-118.2437';
                });
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Latitude',
              hintText: 'e.g., 34.0522',
              keyboardType: TextInputType.number,
              onChanged: (val) => setState(() => _latitude = val),
              controller: TextEditingController(text: _latitude),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Longitude',
              hintText: 'e.g., -118.2437',
              keyboardType: TextInputType.number,
              onChanged: (val) => setState(() => _longitude = val),
              controller: TextEditingController(text: _longitude),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Search Place',
              hintText: 'e.g., Hollywood Blvd',
              onChanged: (val) => setState(() => _searchPlace = val),
              controller: TextEditingController(text: _searchPlace),
            ),
            const SizedBox(height: 24),
            Container(
              height: 150,
              width: double.infinity,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
              alignment: Alignment.center,
              child: const Text(
                'Map Preview (Mock)',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        );
      case 2: // Verification
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextField(
              label: 'Contact Number',
              hintText: '+1 234 567 8900',
              keyboardType: TextInputType.phone,
              onChanged: (val) => setState(() => _contactNumber = val),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    label: 'OTP Verification',
                    hintText: '1234',
                    keyboardType: TextInputType.number,
                    onChanged: (val) => setState(() => _otp = val),
                  ),
                ),
                const SizedBox(width: 16),
                CustomButton(
                  text: 'Send OTP',
                  type: ButtonType.secondary,
                  onPressed: _otpSent
                      ? null
                      : () {
                          UiUtils.showToast(
                            context,
                            'OTP sent to $_contactNumber',
                          );
                          setState(() {
                            _otpSent = true;
                          });
                        },
                ),
              ],
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Verify & Simulate Assignment',
              isFullWidth: true,
              onPressed: () async {
                if (_otp == '1234') {
                  UiUtils.showToast(
                    context,
                    'OTP Verified. Simulating manager approval...',
                  );
                  setState(() {
                    _managerApproved = true;
                    _currentStep = 3; // Move to assignment step
                  });
                  _startManagerApprovalTimer();
                } else {
                  UiUtils.showToast(context, 'Invalid OTP', isError: true);
                }
              },
            ),
          ],
        );
      case 3: // Assignment
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (_towDispatched) ...[
              const Icon(Icons.check_circle, color: Colors.green, size: 80),
              const SizedBox(height: 16),
              Text(
                'Towing Dispatched!',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              const Text('A tow truck has been assigned and is on its way.'),
              const SizedBox(height: 16),
              Text(
                'Est. Arrival: $_eta mins',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Text(
                'Tow Truck Details:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Truck Number: ABC-123',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              Text(
                'Truck Model: Ford F-Series',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              Text(
                'Driver Contact:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Name: John Doe',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              Text(
                'Phone: +1 (555) 123-4567',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Chat with Driver',
                type: ButtonType.secondary,
                onPressed: () {
                  UiUtils.showToast(context, 'Opening chat with John Doe...');
                },
              ),
              const SizedBox(height: 16),
              CustomButton(
                text: 'Go to Live Tracking',
                isFullWidth: true,
                onPressed: () {
                  Navigator.pop(context); // Close EmergencyTowScreen
                  context.findAncestorStateOfType<MainScaffoldState>()?.setTab(
                    1,
                  ); // Navigate to Book Service tab
                },
              ),
            ] else if (_managerApproved) ...[
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Waiting for Tow Truck Dispatch...',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ] else ...[
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Waiting for Manager Approval... (approx. 5 min)',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ],
          ],
        );
      default:
        return const Text('Unknown step');
    }
  }

  Widget _buildNavigationButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (_currentStep > 0 && !_towDispatched)
          CustomButton(
            text: 'Back',
            type: ButtonType.secondary,
            onPressed: () {
              setState(() {
                _currentStep--;
              });
            },
          ),
        if (_currentStep < 3 && !_towDispatched)
          CustomButton(
            text: 'Next',
            onPressed: () {
              setState(() {
                _currentStep++;
              });
            },
          ),
      ],
    );
  }

  void _startManagerApprovalTimer() {
    _managerApprovalTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_managerApprovalTimeLeft == 0) {
        timer.cancel();
        setState(() {
          _towDispatched = true;
          _startEtaTimer();
        });
      } else {
        setState(() {
          _managerApprovalTimeLeft--;
        });
      }
    });
  }

  void _startEtaTimer() {
    _etaTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (_eta == 0) {
        timer.cancel();
      } else {
        setState(() {
          _eta--;
        });
      }
    });
  }
}
