import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
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

  // Toggle Favorite
  Future<void> toggleFavorite(String userId, String itemId) async {
    try {
      final userDoc = _firestore.collection('users').doc(userId);
      final docSnapshot = await userDoc.get();
      
      if (docSnapshot.exists) {
        final List<dynamic> favorites = docSnapshot.data()?['favorites'] ?? [];
        if (favorites.contains(itemId)) {
          await userDoc.update({
            'favorites': FieldValue.arrayRemove([itemId])
          });
        } else {
          await userDoc.update({
            'favorites': FieldValue.arrayUnion([itemId])
          });
        }
      } else {
        // Create doc if it doesn't exist (shouldn't happen usually)
        await userDoc.set({
          'favorites': [itemId]
        }, SetOptions(merge: true));
      }
    } catch (e) {
      throw 'Failed to toggle favorite: $e';
    }
  }

  // Get favorites stream
  Stream<List<String>> getFavoritesStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((snapshot) {
      final data = snapshot.data();
      if (data == null || !data.containsKey('favorites')) return [];
      return List<String>.from(data['favorites']);
    });
  }

  // Get favorite items (full models)
  Future<List<ItemModel>> getFavoriteItems(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final List<dynamic> favoriteIds = userDoc.data()?['favorites'] ?? [];
      
      if (favoriteIds.isEmpty) return [];

      // Firestore 'in' query supports max 10/30 depending on version, 
      // but for simplicity we fetch in batches or individually if list is large.
      // Ideally use where('id', whereIn: favoriteIds) if < 30.
      
      if (favoriteIds.length > 30) {
        // Fallback or pagination logic needed, but for now take first 30
        favoriteIds.removeRange(30, favoriteIds.length);
      }

      final snapshot = await _firestore
          .collection('items')
          .where(FieldPath.documentId, whereIn: favoriteIds)
          .get();
      
      return snapshot.docs.map((doc) => ItemModel.fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint('Error fetching favorite items: $e');
      return []; // Return empty on error to prevent crash
    }
  }
}
