import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String id;
  final String itemName;
  final String itemId; // Link to actual Item
  final String customerName;
  final String customerPhone;
  final String customerId; // Link to actual User
  final String status; // 'Requested', 'Confirmed', 'Picked Up', 'In Use', 'Returned', 'Completed'
  final String startDate; // stored as String "15 Dec 2024" to match Admin App
  final String endDate;
  final String totalAmount; // stored as String
  final String? deliveryPartner; // Name of partner
  final DateTime createdAt;

  OrderModel({
    required this.id,
    required this.itemName,
    required this.itemId,
    required this.customerName,
    required this.customerPhone,
    required this.customerId,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.totalAmount,
    this.deliveryPartner,
    required this.createdAt,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'itemName': itemName,
      'itemId': itemId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'customerId': customerId,
      'status': status,
      'startDate': startDate,
      'endDate': endDate,
      'totalAmount': totalAmount,
      'deliveryPartner': deliveryPartner,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OrderModel(
      id: data['id'] ?? '',
      itemName: data['itemName'] ?? '',
      itemId: data['itemId'] ?? '',
      customerName: data['customerName'] ?? '',
      customerPhone: data['customerPhone'] ?? '',
      customerId: data['customerId'] ?? '',
      status: data['status'] ?? 'Requested',
      startDate: data['startDate'] ?? '',
      endDate: data['endDate'] ?? '',
      totalAmount: data['totalAmount'] ?? '0',
      deliveryPartner: data['deliveryPartner'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
