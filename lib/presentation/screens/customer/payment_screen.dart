import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/pipeline_providers.dart';
import '../../../core/pipeline/pipeline_stage.dart';
import '../../utils/ui_utils.dart';
import 'invoice_screen.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_card.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  final double amount;
  final String description;
  final String? entityId;
  final bool isTow;

  const PaymentScreen({
    Key? key,
    required this.amount,
    required this.description,
    this.entityId,
    this.isTow = false,
  }) : super(key: key);

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  bool _isProcessing = false;

  void _handlePayment() async {
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;

    if (widget.entityId != null) {
      if (widget.isTow) {
        await ref.read(towPipelineProvider.notifier).transition(
          requestId: widget.entityId!,
          from: PipelineStageType.VEHICLE_DELIVERED,
          to: PipelineStageType.TOW_PAYMENT_COMPLETED,
          userId: 'customer-1',
        );
      } else {
        await ref.read(servicePipelineProvider.notifier).transition(
          jobId: widget.entityId!,
          from: PipelineStageType.SERVICE_COMPLETED,
          to: PipelineStageType.PAYMENT_COMPLETED,
          userId: 'customer-1',
        );
      }
    }
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const InvoiceScreen(),
      )
    );
    UiUtils.showToast(context, 'Payment Successful! Pipeline updated.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            child: CustomCard(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lock, size: 48, color: Colors.green),
                  const SizedBox(height: 16),
                  Text('Secure Payment', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 8),
                  Text('Powered by MockStripe', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(widget.description, style: Theme.of(context).textTheme.titleMedium),
                      Text('\$${widget.amount.toStringAsFixed(2)}', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 32),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Card Number',
                      hintText: '0000 0000 0000 0000',
                      prefixIcon: const Icon(Icons.credit_card),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: 'Expiry',
                            hintText: 'MM/YY',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: 'CVC',
                            hintText: '123',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  CustomButton(
                    text: 'Pay \$${widget.amount.toStringAsFixed(2)}',
                    isFullWidth: true,
                    isLoading: _isProcessing,
                    onPressed: _handlePayment,
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel Return', style: TextStyle(color: Colors.grey)),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
