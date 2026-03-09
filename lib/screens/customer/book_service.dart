import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/data_provider.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../utils/ui_utils.dart';

class BookService extends StatelessWidget {
  const BookService({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final vehicles = Provider.of<DataProvider>(context).customerVehicles;
    final vehicleOptions = vehicles.map((v) => '${v['make']} ${v['model']}').toList();
    if (vehicleOptions.isEmpty) vehicleOptions.add('No vehicles found');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Book a Service', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 24),
          CustomCard(
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                  Text('Select Vehicle', style: Theme.of(context).textTheme.labelLarge),
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
                        value: vehicleOptions.first,
                        items: vehicleOptions.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (_) {},
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const CustomTextField(label: 'Service Type', hintText: 'Maintenance / Repair'),
                  const SizedBox(height: 16),
                  const CustomTextField(label: 'Preferred Date', hintText: 'DD/MM/YYYY'),
                  const SizedBox(height: 24),
               ],
             )
          ),
          const SizedBox(height: 16),
          CustomButton(text: 'Schedule Appointment', isFullWidth: true, onPressed: () {
             UiUtils.showToast(context, 'Appointment scheduled successfully!');
          }),

          const SizedBox(height: 48),

          Text('Live Emergency Tracking', style: Theme.of(context).textTheme.headlineMedium),
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
                           Text('Tow Truck en route', style: Theme.of(context).textTheme.titleLarge),
                           const SizedBox(height: 4),
                           const Text('ETA: 15 mins • Driver: Mike'),
                         ],
                       ),
                       const Icon(Icons.location_on, color: Colors.red),
                     ],
                   ),
                )
              ],
            )
          )
        ],
      ),
    );
  }
}
