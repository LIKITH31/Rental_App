import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import '../models/item_model.dart';
import '../services/firestore_service.dart';
import 'location_provider.dart';
import 'auth_provider.dart';

// Firestore instance
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

// Firestore service provider
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  final firestore = ref.watch(firestoreProvider);
  final auth = ref.watch(firebaseAuthProvider);
  return FirestoreService(firestore, auth);
});

// All items provider (fetches from Firestore)
final allItemsProvider = StreamProvider<List<ItemModel>>((ref) {
  final firestore = ref.watch(firestoreProvider);
  
  return firestore
      .collection('items')
      .where('status', isEqualTo: 'available')
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) => ItemModel.fromFirestore(doc)).toList();
  });
});

// Nearby items provider (filters by location and radius)
final nearbyItemsProvider = Provider<AsyncValue<List<ItemModel>>>((ref) {
  final allItemsAsync = ref.watch(allItemsProvider);
  final currentLocationAsync = ref.watch(currentLocationProvider);
  final searchRadius = ref.watch(searchRadiusProvider);
  final selectedLocation = ref.watch(selectedLocationProvider);

  return allItemsAsync.when(
    data: (items) {
      return currentLocationAsync.when(
        data: (currentPos) {
          // Use selected location if available, otherwise use current location
          final searchPos = selectedLocation ?? currentPos;
          
          if (searchPos == null) {
            return AsyncValue.data(items); // Return all if no location
          }

          // Filter items by distance
          final nearbyItems = items.where((item) {
            final distance = item.distanceFrom(
              searchPos.latitude,
              searchPos.longitude,
            );
            return distance <= searchRadius;
          }).toList();

          // Sort by distance (closest first)
          nearbyItems.sort((a, b) {
            final distA = a.distanceFrom(searchPos.latitude, searchPos.longitude);
            final distB = b.distanceFrom(searchPos.latitude, searchPos.longitude);
            return distA.compareTo(distB);
          });

          return AsyncValue.data(nearbyItems);
        },
        loading: () => const AsyncValue.loading(),
        error: (err, stack) => AsyncValue.data(items), // Return all on error
      );
    },
    loading: () => const AsyncValue.loading(),
    error: (err, stack) => AsyncValue.error(err, stack),
  );
});

// Items by category provider
final itemsByCategoryProvider = Provider.family<AsyncValue<List<ItemModel>>, String>((ref, category) {
  final nearbyItemsAsync = ref.watch(nearbyItemsProvider);
  
  return nearbyItemsAsync.when(
    data: (items) {
      final filtered = items.where((item) => item.category == category).toList();
      return AsyncValue.data(filtered);
    },
    loading: () => const AsyncValue.loading(),
    error: (err, stack) => AsyncValue.error(err, stack),
  );
});

// Selected category provider
// final categoryFilterProvider = StateProvider<String?>((ref) => null);

// Filtered items provider
// final filteredItemsProvider = Provider<List<ItemModel>>((ref) {
//   final allItems = ref.watch(sampleItemsProvider);
//   final category = ref.watch(categoryFilterProvider);
//   
//   if (category == null) return allItems;
//   return allItems.where((item) => item.category == category).toList();
// });

// Sample data provider (for demo purposes - remove when Firestore is populated)
final sampleItemsProvider = Provider<List<ItemModel>>((ref) {
  final currentLocationAsync = ref.watch(currentLocationProvider);
  
  return currentLocationAsync.when(
    data: (position) {
      final baseLat = position?.latitude ?? 28.6139;
      final baseLng = position?.longitude ?? 77.2090;
      
      return [
        ItemModel(
          id: '1',
          title: 'Canon DSLR Camera',
          description: 'Professional DSLR camera with 24MP sensor',
          category: 'Electronics',
          rentalPricePerDay: 500,
          rentalPricePerWeek: 3000,
          rentalPricePerMonth: 10000,
          salePrice: 45000,
          securityDeposit: 5000,
          images: [],
          ownerId: 'user1',
          ownerName: 'John Doe',
          location: ItemLocation(
            latitude: baseLat + 0.01,
            longitude: baseLng + 0.01,
            address: '123 Camera Street, Delhi',
            city: 'Delhi',
            state: 'Delhi',
            country: 'India',
          ),
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
          status: 'available',
        ),
        ItemModel(
          id: '2',
          title: 'PlayStation 5',
          description: 'Latest gaming console with 2 controllers',
          category: 'Electronics',
          rentalPricePerDay: 800,
          rentalPricePerWeek: 5000,
          securityDeposit: 10000,
          images: [],
          ownerId: 'user2',
          ownerName: 'Jane Smith',
          location: ItemLocation(
            latitude: baseLat + 0.015,
            longitude: baseLng - 0.01,
            address: '456 Gaming Avenue, Delhi',
            city: 'Delhi',
            state: 'Delhi',
            country: 'India',
          ),
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
          status: 'available',
        ),
        ItemModel(
          id: '3',
          title: 'DJI Drone',
          description: '4K camera drone with gimbal stabilization',
          category: 'Electronics',
          rentalPricePerDay: 1200,
          rentalPricePerWeek: 7000,
          salePrice: 65000,
          securityDeposit: 15000,
          images: [],
          ownerId: 'user3',
          ownerName: 'Mike Johnson',
          location: ItemLocation(
            latitude: baseLat - 0.01,
            longitude: baseLng + 0.015,
            address: '789 Drone Park, Delhi',
            city: 'Delhi',
            state: 'Delhi',
            country: 'India',
          ),
          createdAt: DateTime.now().subtract(const Duration(days: 7)),
          status: 'available',
        ),
        ItemModel(
          id: '4',
          title: 'Mountain Bike',
          description: 'Professional mountain bike, 21-speed',
          category: 'Vehicles',
          rentalPricePerDay: 200,
          rentalPricePerWeek: 1200,
          salePrice: 15000,
          securityDeposit: 2000,
          images: [],
          ownerId: 'user4',
          ownerName: 'Sarah Wilson',
          location: ItemLocation(
            latitude: baseLat + 0.02,
            longitude: baseLng - 0.015,
            address: '321 Bike Lane, Delhi',
            city: 'Delhi',
            state: 'Delhi',
            country: 'India',
          ),
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          status: 'available',
        ),
        ItemModel(
          id: '5',
          title: 'Projector 4K',
          description: 'Home theater projector with 4K resolution',
          category: 'Electronics',
          rentalPricePerDay: 600,
          rentalPricePerWeek: 3500,
          securityDeposit: 8000,
          images: [],
          ownerId: 'user5',
          ownerName: 'David Brown',
          location: ItemLocation(
            latitude: baseLat - 0.005,
            longitude: baseLng - 0.02,
            address: '654 Theater Road, Delhi',
            city: 'Delhi',
            state: 'Delhi',
            country: 'India',
          ),
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          status: 'available',
        ),
      ];
    },
    loading: () => [],
    error: (_, __) => [],
  );
});
