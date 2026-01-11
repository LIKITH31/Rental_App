import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/order_provider.dart';
import '../../../../core/models/order_model.dart';
import 'order_tracking_screen.dart';

class RentalsScreen extends ConsumerStatefulWidget {
  const RentalsScreen({super.key});

  @override
  ConsumerState<RentalsScreen> createState() => _RentalsScreenState();
}

class _RentalsScreenState extends ConsumerState<RentalsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(userOrdersProvider);

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar.large(
              floating: true,
              pinned: true,
              title: const Text('My Rentals'),
              bottom: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Active'),
                  Tab(text: 'Pending'),
                  Tab(text: 'Completed'),
                ],
              ),
            ),
          ];
        },
        body: ordersAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
          data: (orders) {
            return TabBarView(
              controller: _tabController,
              children: [
                _buildRentalsList(orders, 'Active'),
                _buildRentalsList(orders, 'Pending'),
                _buildRentalsList(orders, 'Completed'),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildRentalsList(List<OrderModel> allOrders, String tabCategory) {
    // Filter logic
    final rentals = allOrders.where((order) {
      final s = order.status.toLowerCase();
      if (tabCategory == 'Pending') return s == 'requested';
      if (tabCategory == 'Active') return ['confirmed', 'picked up', 'in use'].contains(s);
      if (tabCategory == 'Completed') return ['returned', 'completed', 'cancelled'].contains(s);
      return false;
    }).toList();

    if (rentals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No $tabCategory rentals',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey),
            ),
          ],
        ).animate().fadeIn().scale(),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: rentals.length,
      itemBuilder: (context, index) {
        final rental = rentals[index];
        return _buildRentalCard(rental, index);
      },
    );
  }

  Widget _buildRentalCard(OrderModel order, int index) {
    // Helper to get color
    Color color;
    IconData icon;
    switch (order.status.toLowerCase()) {
      case 'requested': color = Colors.orange; icon = Icons.pending; break;
      case 'confirmed': color = Colors.blue; icon = Icons.check_circle; break;
      case 'picked up': color = Colors.deepPurple; icon = Icons.delivery_dining; break;
      case 'in use': color = Colors.green; icon = Icons.play_circle; break;
      case 'completed': color = Colors.grey; icon = Icons.task_alt; break;
      default: color = Colors.grey; icon = Icons.info;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          // Navigate to Tracking
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => OrderTrackingScreen(order: order)),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60, height: 60,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(order.itemName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text('${order.startDate} - ${order.endDate}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 8),
                    _buildStatusChip(order.status, color),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: (100 * index).ms).slideX(begin: -0.2);
  }

  Widget _buildStatusChip(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
