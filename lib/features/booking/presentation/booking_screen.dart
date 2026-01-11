import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../../../core/models/item_model.dart';
import '../../../core/models/order_model.dart';
import 'payment_screen.dart';

class BookingScreen extends StatefulWidget {
  final ItemModel item;
  const BookingScreen({super.key, required this.item});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTimeRange? _selectedDateRange;
  bool _isLoading = false;

  int get _durationDays => _selectedDateRange?.duration.inDays ?? 0;
  double get _totalPrice => (_durationDays * widget.item.rentalPricePerDay);

  Future<void> _selectDates() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  Future<void> _confirmBooking() async {
    if (_selectedDateRange == null) return;
    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw 'User not logged in';

      final userId = user.uid;
      final userName = user.displayName ?? user.email ?? 'Unknown User';
      final userPhone = user.phoneNumber ?? 'Not Provided';

      final startStr = DateFormat('dd MMM yyyy').format(_selectedDateRange!.start);
      final endStr = DateFormat('dd MMM yyyy').format(_selectedDateRange!.end);
      final orderId = '#ORD-${const Uuid().v4().substring(0, 8).toUpperCase()}';

      final order = OrderModel(
        id: orderId,
        itemName: widget.item.title,
        itemId: widget.item.id,
        customerName: userName,
        customerPhone: userPhone,
        customerId: userId,
        status: 'Requested', // Important: Matches Admin App
        startDate: startStr,
        endDate: endStr,
        totalAmount: _totalPrice.toStringAsFixed(0),
        createdAt: DateTime.now(),
      );

      /* Order creation moved to Payment Screen */
      // await FirebaseFirestore.instance.collection('orders').doc(orderId).set(order.toFirestore());

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentScreen(order: order),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book Item')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Item Info
            Text(widget.item.title, style: Theme.of(context).textTheme.headlineSmall),
            Text('\$${widget.item.rentalPricePerDay}/day', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 24),

            // Date Picker
            InkWell(
              onTap: _selectDates,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedDateRange == null 
                        ? 'Select Dates' 
                        : '${DateFormat("dd MMM").format(_selectedDateRange!.start)} - ${DateFormat("dd MMM").format(_selectedDateRange!.end)}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Icon(Icons.calendar_today),
                  ],
                ),
              ),
            ),
            
            // Summary
            if (_selectedDateRange != null) ...[
              const SizedBox(height: 24),
              const Text('Booking Summary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Duration: $_durationDays days'),
                  Text('\$${_totalPrice.toStringAsFixed(2)}'),
                ],
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('\$${_totalPrice.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
            ],

            const SizedBox(height: 48),

            // Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _selectedDateRange == null || _isLoading ? null : _confirmBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF781C2E), // Match Admin Theme
                  foregroundColor: Colors.white,
                ),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white) 
                  : const Text('CONFIRM BOOKING'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
