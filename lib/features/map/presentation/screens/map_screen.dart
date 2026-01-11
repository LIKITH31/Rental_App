import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/providers/items_provider.dart';
import '../../../../core/providers/location_provider.dart';
import '../../../../core/models/item_model.dart';
import '../../../home/presentation/screens/item_details_screen.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  GoogleMapController? _mapController;
  
  // Default location (Delhi)
  static const CameraPosition _defaultPosition = CameraPosition(
    target: LatLng(28.6139, 77.2090), 
    zoom: 12,
  );

  @override
  Widget build(BuildContext context) {
    final allItemsAsync = ref.watch(allItemsProvider);
    final currentLocationAsync = ref.watch(currentLocationProvider);

    // Initial position based on user location
    CameraPosition initialPosition = _defaultPosition;
    currentLocationAsync.whenData((position) {
      if (position != null) {
        initialPosition = CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 13,
        );
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          allItemsAsync.when(
            data: (items) {
              final markers = items.map((item) {
                return Marker(
                  markerId: MarkerId(item.id),
                  position: LatLng(item.location.latitude, item.location.longitude),
                  infoWindow: InfoWindow(
                    title: item.title,
                    snippet: '₹${item.rentalPricePerDay}/day',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ItemDetailsScreen(item: item),
                        ),
                      );
                    },
                  ),
                );
              }).toSet();

              return GoogleMap(
                initialCameraPosition: initialPosition,
                markers: markers,
                onMapCreated: (controller) {
                  _mapController = controller;
                  // If we have a location, move to it once map is created
                  currentLocationAsync.whenData((position) {
                    if (position != null) {
                      controller.animateCamera(
                         CameraUpdate.newLatLng(LatLng(position.latitude, position.longitude))
                      );
                    }
                  });
                },
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
          ),
          
          // Search and Filters
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search location...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.filter_list),
                          onPressed: () {},
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 15,
                        ),
                      ),
                    ),
                  ).animate().fadeIn().slideY(begin: -0.3),
                ),
                const Spacer(),
                // Item Carousel
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: allItemsAsync.when(
                    data: (items) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'Nearby Items (${items.length})',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              final item = items[index];
                              return GestureDetector(
                                onTap: () {
                                  _mapController?.animateCamera(
                                    CameraUpdate.newLatLng(
                                      LatLng(item.location.latitude, item.location.longitude),
                                    ),
                                  );
                                },
                                child: _buildItemCard(context, item),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ).animate().slideY(begin: 1),
              ],
            ),
          ),
          
          // My location button
          Positioned(
            right: 16,
            bottom: 220,
            child: FloatingActionButton(
              mini: true,
              onPressed: () {
                ref.read(currentLocationProvider.future).then((position) {
                  if (position != null && _mapController != null) {
                    _mapController!.animateCamera(
                      CameraUpdate.newLatLng(LatLng(position.latitude, position.longitude)),
                    );
                  }
                });
              },
              child: const Icon(Icons.my_location),
            ).animate().fadeIn(delay: 500.ms).scale(),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(BuildContext context, ItemModel item) {
    // Map category to color
    Color color = Colors.indigo;
    IconData icon = Icons.inventory;
    
    // ... basic mapping can be improved or reused from HomeScreen logic if refactored
    
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12, bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).canvasColor, // Background
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                color: Colors.grey.shade200,
                image: item.images.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(item.images.first),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: item.images.isEmpty
                  ? const Center(child: Icon(Icons.image, color: Colors.grey))
                  : null,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '₹${item.rentalPricePerDay}/day',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
