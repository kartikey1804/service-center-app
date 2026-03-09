import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/data_provider.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_badge.dart';
import '../../widgets/custom_button.dart';
import '../../utils/ui_utils.dart';
import 'payment_screen.dart';

class ServiceHistory extends StatelessWidget {
  const ServiceHistory({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context);
    final quotes = dataProvider.customerQuotes;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Service Quotes', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 16),
          if (quotes.isEmpty)
            const Text("No pending quotes.")
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: quotes.length,
              itemBuilder: (context, index) {
                final q = quotes[index];
                final isPending = q['status'] == 'Pending';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: CustomCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(q['vehicle'], style: Theme.of(context).textTheme.titleLarge),
                            CustomBadge(
                              text: q['status'],
                              type: isPending ? BadgeType.yellow : (q['status'] == 'Approved' ? BadgeType.green : BadgeType.red),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(q['description'], style: Theme.of(context).textTheme.bodyMedium),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('\$${q['amount'].toStringAsFixed(2)}', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Theme.of(context).colorScheme.primary)),
                            if (isPending) Row(
                              children: [
                                CustomButton(
                                  text: 'Deny',
                                  type: ButtonType.secondary,
                                  onPressed: () {
                                    dataProvider.denyQuote(q['id']!);
                                    UiUtils.showToast(context, 'Quote Denied', isError: true);
                                  },
                                ),
                                const SizedBox(width: 8),
                                CustomButton(
                                  text: 'Approve',
                                  type: ButtonType.primary,
                                  onPressed: () {
                                    dataProvider.approveQuote(q['id']!);
                                    UiUtils.showToast(context, 'Quote Approved successfully');
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            
          const SizedBox(height: 32),
          Text('Service History', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 16),
          CustomCard(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Maintenance & Oil Change'),
              subtitle: const Text('Honda Civic 2019 • Oct 10, 2026'),
              trailing: CustomButton(
                text: 'Pay \$120',
                type: ButtonType.secondary,
                onPressed: () {
                   Navigator.push(context, MaterialPageRoute(
                     builder: (_) => const PaymentScreen(amount: 120.0, description: 'Maintenance & Oil Change'),
                   ));
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}
