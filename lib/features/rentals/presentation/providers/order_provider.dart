import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/repositories/order_repository.dart';
import '../../../../core/models/order_model.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Real auth
import '../../../../core/providers/auth_provider.dart';

final orderRepositoryProvider = Provider<FirestoreOrderRepository>((ref) {
  return FirestoreOrderRepository(FirebaseFirestore.instance);
});

final userOrdersProvider = StreamProvider<List<OrderModel>>((ref) {
  final user = ref.watch(currentUserProvider);
  final repository = ref.watch(orderRepositoryProvider);
  
  if (user == null) return Stream.value([]);
  
  return repository.watchUserOrders(user.uid);
});

final authStateChangesProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});
