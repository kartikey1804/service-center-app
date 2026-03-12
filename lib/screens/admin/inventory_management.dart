import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/data_provider.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_badge.dart';
import '../../widgets/custom_button.dart';
import '../../utils/ui_utils.dart';

class InventoryManagement extends StatelessWidget {
  const InventoryManagement({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DataProvider>(context);
    final inventory = provider.inventory;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Inventory Management', style: Theme.of(context).textTheme.headlineMedium),
              CustomButton(
                text: 'Add Part',
                icon: Icons.add,
                onPressed: () {
                   UiUtils.showToast(context, 'Mock: Add new part modal');
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          CustomCard(
            padding: EdgeInsets.zero,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Part Name')),
                  DataColumn(label: Text('Current Stock')),
                  DataColumn(label: Text('Min Threshold')),
                  DataColumn(label: Text('Unit Price')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: inventory.map((item) {
                  final isLow = (item['stock'] as int) < (item['minThreshold'] as int);
                  return DataRow(cells: [
                    DataCell(
                      Row(
                        children: [
                          _getPartIcon(item['name']),
                          const SizedBox(width: 12),
                          Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    DataCell(Text('${item['stock']} units', style: TextStyle(color: isLow ? Colors.red : null, fontWeight: isLow ? FontWeight.bold : FontWeight.normal))),
                    DataCell(Text('${item['minThreshold']} units')),
                    DataCell(Text('\$${item['price'].toStringAsFixed(2)}')),
                    DataCell(CustomBadge(text: isLow ? 'Low Stock' : 'Good', type: isLow ? BadgeType.red : BadgeType.green)),
                    DataCell(
                      isLow 
                        ? CustomButton(
                           text: 'Order Stock',
                           type: ButtonType.primary,
                           onPressed: () {
                             provider.orderPart(item['id']);
                             UiUtils.showToast(context, 'Order placed successfully');
                           },
                        ) 
                        : const SizedBox.shrink()
                    ),
                  ]);
                }).toList(),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _getPartIcon(String name) {
    IconData icon = Icons.settings;
    if (name.contains('Oil')) icon = Icons.opacity;
    if (name.contains('Brake')) icon = Icons.vibration;
    if (name.contains('Filter')) icon = Icons.filter_alt;
    if (name.contains('Spark')) icon = Icons.bolt;
    
    return Icon(icon, size: 20, color: Colors.grey);
  }
}
