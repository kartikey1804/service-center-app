import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/data_provider.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_badge.dart';

class CustomerGarage extends StatelessWidget {
  const CustomerGarage({super.key});

  @override
  Widget build(BuildContext context) {
    const String currentUserId = 'customer-1'; // Placeholder userId

    return Consumer<DataProvider>(
      builder: (context, dataProvider, child) {
        final vehicles = dataProvider.customerVehicles
            .where((v) => v['userId'] == currentUserId)
            .toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'My Garage',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    color: Theme.of(context).colorScheme.primary,
                    onPressed: () {
                      _showAddVehicleDialog(context, dataProvider, currentUserId);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (vehicles.isEmpty)
                const Center(child: Text("No vehicles in your garage."))
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: vehicles.length,
                  itemBuilder: (context, index) {
                    final v = vehicles[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: CustomCard(
                        child: Row(
                          children: [
                            if (v['image'] != null)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.asset(
                                  v['image'],
                                  width: 100,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Icon(Icons.car_repair, size: 50, color: Colors.grey),
                                ),
                              ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${v['make']} ${v['model']}',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${v['year']} • License: ${v['plate']}',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Next Service: ${v['nextService']}',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.labelLarge,
                                  ),
                                ],
                              ),
                            ),
                            const CustomBadge(
                              text: 'Active',
                              type: BadgeType.green,
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () {
                                dataProvider.deleteCustomerVehicle(v['id']);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  void _showAddVehicleDialog(
    BuildContext context,
    DataProvider dataProvider,
    String userId,
  ) {
    final vehicleNumberController = TextEditingController();
    final brandController = TextEditingController();
    final modelController = TextEditingController();
    final yearController = TextEditingController();
    String fuelType = 'Petrol';

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: const Text('Add New Vehicle'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: vehicleNumberController,
                          decoration: const InputDecoration(
                            labelText: 'Vehicle Number',
                            hintText: 'e.g., MH 12 AB 1234',
                          ),
                        ),
                        TextField(
                          controller: brandController,
                          decoration: const InputDecoration(labelText: 'Brand'),
                        ),
                        TextField(
                          controller: modelController,
                          decoration: const InputDecoration(labelText: 'Model'),
                        ),
                        DropdownButtonFormField<String>(
                          value: fuelType,
                          decoration: const InputDecoration(
                            labelText: 'Fuel Type',
                          ),
                          items:
                              ['Petrol', 'Diesel', 'Electric', 'CNG']
                                  .map(
                                    (e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(e),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) {
                            if (value != null) setState(() => fuelType = value);
                          },
                        ),
                        TextField(
                          controller: yearController,
                          decoration: const InputDecoration(labelText: 'Year'),
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (vehicleNumberController.text.isNotEmpty &&
                            brandController.text.isNotEmpty) {
                          await dataProvider.addCustomerVehicle({
                            'userId': userId,
                            'plate': vehicleNumberController.text,
                            'make': brandController.text,
                            'model': modelController.text,
                            'fuelType': fuelType,
                            'year': yearController.text,
                            'nextService': 'Schedule Now',
                            'image': 'assets/images/car_placeholder.png', // Default placeholder
                          });
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Add'),
                    ),
                  ],
                ),
          ),
    );
  }
}
