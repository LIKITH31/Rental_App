import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/models/order_model.dart';

class PaymentScreen extends StatefulWidget {
  final OrderModel order;
  const PaymentScreen({super.key, required this.order});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _isProcessing = false;
  int _selectedMethod = 0;

  Future<void> _processPayment() async {
    setState(() => _isProcessing = true);

    // Simulate Network Delay
    await Future.delayed(const Duration(seconds: 2));

    try {
      // Create Order in Firestore
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(widget.order.id)
          .set(widget.order.toFirestore());

      if (mounted) {
        // Navigate to Success
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const PaymentSuccessScreen()),
          (route) => route.isFirst,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Amount', style: TextStyle(color: Colors.black)),
                      Text(
                        '\$${widget.order.totalAmount}', 
                        style: const TextStyle(
                          fontWeight: FontWeight.bold, 
                          fontSize: 18,
                          color: Colors.black, // Make explicit dark color
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(widget.order.itemName, style: const TextStyle(color: Colors.black54)),
                ],
              ),
            ),
            const SizedBox(height: 32),

            const Text('Payment Method', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 16),
            
            _buildMethodTile(0, 'Credit / Debit Card', Icons.credit_card),
            _buildMethodTile(1, 'UPI (Google Pay / PhonePe)', Icons.qr_code_scanner),
            _buildMethodTile(2, 'Netbanking', Icons.account_balance),
            _buildMethodTile(3, 'Wallets', Icons.account_balance_wallet),
            _buildMethodTile(4, 'Cash on Delivery', Icons.money),

            const SizedBox(height: 48),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF781C2E),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isProcessing 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('PAY & BOOK NOW', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodTile(int index, String title, IconData icon) {
    final isSelected = _selectedMethod == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: isSelected ? const Color(0xFF781C2E) : Colors.grey[300]!, width: isSelected ? 2 : 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? const Color(0xFF781C2E) : Colors.grey),
            const SizedBox(width: 16),
            Text(title, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
            const Spacer(),
            if (isSelected) const Icon(Icons.check_circle, color: Color(0xFF781C2E)),
          ],
        ),
      ),
    );
  }
}

class PaymentSuccessScreen extends StatelessWidget {
  const PaymentSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 100)
                .animate().scale(curve: Curves.elasticOut, duration: 800.ms),
            const SizedBox(height: 24),
            const Text('Booking Confirmed!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Text('Your order has been placed successfully.', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}
