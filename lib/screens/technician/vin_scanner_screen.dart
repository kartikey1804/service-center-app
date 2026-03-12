import 'package:flutter/material.dart';
import '../../widgets/custom_button.dart';
import '../../utils/ui_utils.dart';
import 'dart:math';

class VinScannerScreen extends StatefulWidget {
  const VinScannerScreen({Key? key}) : super(key: key);

  @override
  State<VinScannerScreen> createState() => _VinScannerScreenState();
}

class _VinScannerScreenState extends State<VinScannerScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  final Map<String, dynamic> _mockVehicleHistory = {
    'vin': 'VIN-MOCK-12345',
    'make': 'Toyota',
    'model': 'Camry',
    'year': 2020,
    'color': 'Silver',
    'mileage': '55,000 miles',
    'engine': '2.5L I4',
    'serviceHistory': [
      {'date': '2023-01-15', 'service': 'Oil Change', 'notes': 'Used synthetic oil'},
      {'date': '2023-07-22', 'service': 'Tire Rotation', 'notes': 'Checked tire pressure'},
      {'date': '2024-02-10', 'service': 'Brake Inspection', 'notes': 'Front pads at 50%'},
    ],
    'recalls': [
      {'date': '2022-05-01', 'description': 'Fuel pump recall (completed)'},
    ],
    'ownerHistory': 'Single owner, no accidents reported',
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _animation = Tween<double>(begin: 0, end: 300).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _simulateScan() {
    UiUtils.showToast(context, 'VIN Scanned Successfully!');
    Future.delayed(const Duration(seconds: 1), () {
        if (!mounted) return;
        Navigator.pop(context, _mockVehicleHistory);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Scan VIN / Barcode'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      body: Stack(
        children: [
          // Mock Camera Viewport
          Center(
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).colorScheme.primary, width: 3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(
                children: [
                  AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return Positioned(
                        top: _animation.value,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            boxShadow: [
                               BoxShadow(
                                 color: Theme.of(context).colorScheme.primary.withAlpha(100),
                                 blurRadius: 10,
                                 spreadRadius: 2,
                               )
                            ],
                          ),
                        ),
                      );
                    },
                  )
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Center(
              child: Column(
                children: [
                  const Text('Align VIN or QR Code within frame', style: TextStyle(color: Colors.white, fontSize: 16)),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: 'Simulate Successful Scan',
                    icon: Icons.camera_alt,
                    onPressed: _simulateScan,
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
