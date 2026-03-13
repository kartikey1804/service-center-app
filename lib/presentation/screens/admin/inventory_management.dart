import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/data_provider.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_badge.dart';
import '../../widgets/custom_button.dart';
import '../../utils/ui_utils.dart';

class InventoryManagement extends StatefulWidget {
  const InventoryManagement({super.key});

  @override
  State<InventoryManagement> createState() => _InventoryManagementState();
}

class _InventoryManagementState extends State<InventoryManagement> {
  final _formKey = GlobalKey<FormState>();
  final _partNameController = TextEditingController();
  final _stockController = TextEditingController();
  final _minThresholdController = TextEditingController();
  final _unitPriceController = TextEditingController();

  @override
  void dispose() {
    _partNameController.dispose();
    _stockController.dispose();
    _minThresholdController.dispose();
    _unitPriceController.dispose();
    super.dispose();
  }

  Future<void> _showAddPartDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Part'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _partNameController,
                    decoration: const InputDecoration(labelText: 'Part Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a part name';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _stockController,
                    decoration: const InputDecoration(
                      labelText: 'Current Stock',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter current stock';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _minThresholdController,
                    decoration: const InputDecoration(
                      labelText: 'Minimum Threshold',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter minimum threshold';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _unitPriceController,
                    decoration: const InputDecoration(labelText: 'Unit Price'),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter unit price';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _formKey.currentState?.reset();
                _partNameController.clear();
                _stockController.clear();
                _minThresholdController.clear();
                _unitPriceController.clear();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  final dataProvider = Provider.of<DataProvider>(
                    context,
                    listen: false,
                  );
                  dataProvider.addInventoryItem({
                    'name': _partNameController.text,
                    'stock': int.parse(_stockController.text),
                    'minThreshold': int.parse(_minThresholdController.text),
                    'price': double.parse(_unitPriceController.text),
                  });
                  Navigator.of(context).pop();
                  UiUtils.showToast(context, 'Part added successfully!');
                  _formKey.currentState?.reset();
                  _partNameController.clear();
                  _stockController.clear();
                  _minThresholdController.clear();
                  _unitPriceController.clear();
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showEditPartDialog(
    BuildContext context,
    Map<String, dynamic> item,
  ) async {
    _partNameController.text = item['name'];
    _stockController.text = item['stock'].toString();
    _minThresholdController.text = item['minThreshold'].toString();
    _unitPriceController.text = item['price'].toString();

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Part'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _partNameController,
                    decoration: const InputDecoration(labelText: 'Part Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a part name';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _stockController,
                    decoration: const InputDecoration(
                      labelText: 'Current Stock',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter current stock';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _minThresholdController,
                    decoration: const InputDecoration(
                      labelText: 'Minimum Threshold',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter minimum threshold';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _unitPriceController,
                    decoration: const InputDecoration(labelText: 'Unit Price'),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter unit price';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _formKey.currentState?.reset();
                _partNameController.clear();
                _stockController.clear();
                _minThresholdController.clear();
                _unitPriceController.clear();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  final dataProvider = Provider.of<DataProvider>(
                    context,
                    listen: false,
                  );
                  dataProvider.updateInventoryItem(item['id'], {
                    'name': _partNameController.text,
                    'stock': int.parse(_stockController.text),
                    'minThreshold': int.parse(_minThresholdController.text),
                    'price': double.parse(_unitPriceController.text),
                  });
                  Navigator.of(context).pop();
                  UiUtils.showToast(context, 'Part updated successfully!');
                  _formKey.currentState?.reset();
                  _partNameController.clear();
                  _stockController.clear();
                  _minThresholdController.clear();
                  _unitPriceController.clear();
                }
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDeleteConfirmationDialog(
    BuildContext context,
    String partId,
  ) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Part'),
          content: const Text('Are you sure you want to delete this part?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final dataProvider = Provider.of<DataProvider>(
                  context,
                  listen: false,
                );
                dataProvider.deleteInventoryItem(partId);
                Navigator.of(context).pop();
                UiUtils.showToast(context, 'Part deleted successfully!');
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

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
              Text(
                'Inventory Management',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              CustomButton(
                text: 'Add Part',
                icon: Icons.add,
                onPressed: () {
                  _showAddPartDialog(context);
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
                  final isLow =
                      (item['stock'] as int) < (item['minThreshold'] as int);
                  return DataRow(
                    cells: [
                      DataCell(
                        Row(
                          children: [
                            _getPartIcon(item['name']),
                            const SizedBox(width: 12),
                            Text(
                              item['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      DataCell(
                        Text(
                          '${item['stock']} units',
                          style: TextStyle(
                            color: isLow ? Colors.red : null,
                            fontWeight: isLow
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                      DataCell(Text('${item['minThreshold']} units')),
                      DataCell(Text('\$${item['price'].toStringAsFixed(2)}')),
                      DataCell(
                        CustomBadge(
                          text: isLow ? 'Low Stock' : 'Good',
                          type: isLow ? BadgeType.red : BadgeType.green,
                        ),
                      ),
                      DataCell(
                        Row(
                          children: [
                            CustomButton(
                              text: 'Edit',
                              type: ButtonType.secondary,
                              onPressed: () {
                                _showEditPartDialog(context, item);
                              },
                            ),
                            const SizedBox(width: 8),
                            CustomButton(
                              text: 'Delete',
                              type: ButtonType.danger,
                              onPressed: () {
                                _showDeleteConfirmationDialog(
                                  context,
                                  item['id'],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Pending Requisitions (Admin Approval)',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: provider.getPartsRequisitions(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const CircularProgressIndicator();
              final requisitions = (snapshot.data ?? []).where((r) => r['status'] == 'Pending Approval').toList();
              if (requisitions.isEmpty) return const Text('No pending requisitions.');

              return CustomCard(
                padding: EdgeInsets.zero,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Part Name')),
                      DataColumn(label: Text('Job ID')),
                      DataColumn(label: Text('Priority')),
                      DataColumn(label: Text('Est. Price')),
                      DataColumn(label: Text('Actions')),
                    ],
                    rows: requisitions.map((req) {
                      return DataRow(cells: [
                        DataCell(Text(req['partName'])),
                        DataCell(Text(req['jobId'])),
                        DataCell(CustomBadge(
                          text: req['priority'] ?? 'Medium',
                          type: req['priority'] == 'Critical' ? BadgeType.red : BadgeType.orange,
                        )),
                        DataCell(Text('\$${req['estimatedPrice']}')),
                        DataCell(Row(
                          children: [
                            TextButton(
                              onPressed: () => provider.updatePartsRequisitionStatus(req['id'], 'Approved'),
                              child: const Text('Approve', style: TextStyle(color: Colors.green)),
                            ),
                            TextButton(
                              onPressed: () => provider.updatePartsRequisitionStatus(req['id'], 'Rejected'),
                              child: const Text('Reject', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        )),
                      ]);
                    }).toList(),
                  ),
                ),
              );
            },
          ),
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
