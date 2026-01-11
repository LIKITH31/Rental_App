import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/item_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FirestoreService(this._firestore, this._auth);

  // Add a new item
  Future<String> addItem(ItemModel item) async {
    try {
      final docRef = await _firestore.collection('items').add(item.toFirestore());
      return docRef.id;
    } catch (e) {
      throw 'Failed to add item: $e';
    }
  }

  // Update an item
  Future<void> updateItem(String itemId, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection('items').doc(itemId).update(updates);
    } catch (e) {
      throw 'Failed to update item: $e';
    }
  }

  // Delete an item
  Future<void> deleteItem(String itemId) async {
    try {
      await _firestore.collection('items').doc(itemId).delete();
    } catch (e) {
      throw 'Failed to delete item: $e';
    }
  }

  // Get items by owner
  Stream<List<ItemModel>> getItemsByOwner(String ownerId) {
    return _firestore
        .collection('items')
        .where('ownerId', isEqualTo: ownerId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => ItemModel.fromFirestore(doc)).toList();
    });
  }

  // Get all available items
  Stream<List<ItemModel>> getAllAvailableItems() {
    return _firestore
        .collection('items')
        .where('status', isEqualTo: 'available')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => ItemModel.fromFirestore(doc)).toList();
    });
  }

  // Get item by ID
  Future<ItemModel?> getItemById(String itemId) async {
    try {
      final doc = await _firestore.collection('items').doc(itemId).get();
      if (doc.exists) {
        return ItemModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw 'Failed to get item: $e';
    }
  }

  // Create user profile
  Future<void> createUserProfile(User user) async {
    try {
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName ?? 'User',
        'photoURL': user.photoURL,
        'createdAt': FieldValue.serverTimestamp(),
        'itemsListed': 0,
        'rentalsCount': 0,
        'rating': 0.0,
      }, SetOptions(merge: true));
    } catch (e) {
      // Don't block sign up if profile creation fails due to permissions
      print('Warning: Failed to create user profile: $e');
    }
  }

  // Get user profile
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      return doc.data();
    } catch (e) {
      throw 'Failed to get user profile: $e';
    }
  }

  // Increment items listed count
  Future<void> incrementItemsListed(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'itemsListed': FieldValue.increment(1),
      });
    } catch (e) {
      throw 'Failed to update items count: $e';
    }
  }
}
