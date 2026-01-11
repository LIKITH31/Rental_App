import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart'; // Ensure this matches existing model path

class FirestoreOrderRepository {
  final FirebaseFirestore _firestore;

  FirestoreOrderRepository(this._firestore);

  Stream<List<OrderModel>> watchUserOrders(String userId) {
    print('OrderRepository: Watching orders for user $userId');
    return _firestore
        .collection('orders')
        .where('customerId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      print('OrderRepository: Got snapshot with ${snapshot.docs.length} docs');
      if (snapshot.docs.isNotEmpty) {
        print('OrderRepository: First doc data: ${snapshot.docs.first.data()}');
      }
      return snapshot.docs.map((doc) => OrderModel.fromFirestore(doc)).toList();
    }).handleError((e) {
      print('OrderRepository: Error fetching orders: $e');
      throw e; 
    });
  }

  Future<OrderModel?> getOrder(String orderId) async {
    final doc = await _firestore.collection('orders').doc(orderId).get();
    if (doc.exists) {
      return OrderModel.fromFirestore(doc);
    }
    return null;
  }
}
