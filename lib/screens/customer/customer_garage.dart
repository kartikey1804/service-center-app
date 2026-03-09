import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/data_provider.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_badge.dart';

class CustomerGarage extends StatelessWidget {
  const CustomerGarage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context);
    final vehicles = dataProvider.customerVehicles;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('My Garage', style: Theme.of(context).textTheme.headlineMedium),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                color: Theme.of(context).colorScheme.primary,
                onPressed: () {
                  // Mock Add vehicle
                },
              )
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${v['make']} ${v['model']}', style: Theme.of(context).textTheme.titleLarge),
                            const SizedBox(height: 4),
                            Text('${v['year']} • License: ${v['plate']}', style: Theme.of(context).textTheme.bodyMedium),
                            const SizedBox(height: 12),
                            Text('Next Service: ${v['nextService']}', style: Theme.of(context).textTheme.labelLarge),
                          ],
                        ),
                        const CustomBadge(text: 'Active', type: BadgeType.green),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
