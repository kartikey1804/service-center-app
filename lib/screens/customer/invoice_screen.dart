import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/data_provider.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_button.dart';

class InvoiceScreen extends StatelessWidget {
  const InvoiceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final invoices = Provider.of<DataProvider>(context).invoices;
    if (invoices.isEmpty) {
       return Scaffold(
         appBar: AppBar(title: const Text('Invoice Details')),
         body: const Center(child: Text('No invoices available.')),
       );
    }

    final latestInvoice = invoices.first; // Default to latest for demo

    return Scaffold(
      appBar: AppBar(title: const Text('Invoice Details')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
               children: [
                 CustomCard(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('INVOICE', style: Theme.of(context).textTheme.headlineMedium?.copyWith(letterSpacing: 2, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
                                const SizedBox(height: 8),
                                Text(latestInvoice['id'], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(Provider.of<DataProvider>(context).storeName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                const Text('123 Service Road\nAuto City, NY 10001', textAlign: TextAlign.right, style: TextStyle(color: Colors.grey)),
                              ],
                            )
                          ],
                        ),
                        const SizedBox(height: 40),
                        const Divider(),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Service Provided', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.grey)),
                            Text('Amount', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.grey)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(latestInvoice['vehicle'], style: Theme.of(context).textTheme.bodyLarge),
                            Text('\$${(latestInvoice['amount'] as double).toStringAsFixed(2)}', style: Theme.of(context).textTheme.bodyLarge),
                          ],
                        ),
                        const SizedBox(height: 40),
                        const Divider(),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('TOTAL PAID', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                            Text('\$${(latestInvoice['amount'] as double).toStringAsFixed(2)}', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.green)),
                          ],
                        ),
                        const SizedBox(height: 48),
                        const Center(child: Text('Thank you for your business!', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey))),
                      ]
                    )
                 ),
                 const SizedBox(height: 24),
                 Row(
                   mainAxisAlignment: MainAxisAlignment.center,
                   children: [
                     CustomButton(
                        text: 'Download PDF',
                        icon: Icons.download,
                        type: ButtonType.secondary,
                        onPressed: () {},
                     ),
                     const SizedBox(width: 16),
                     CustomButton(
                        text: 'Return to Dashboard',
                        onPressed: () => Navigator.pop(context),
                     )
                   ],
                 )
               ],
            ),
          )
        )
      )
    );
  }
}
