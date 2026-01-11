# Location-Based Item Discovery

## ✅ Features Implemented

### 1. **Current Location Detection**
- Automatically requests and gets user's current location
- Shows loading state while fetching location
- Handles permission requests gracefully
- Falls back to showing all items if location is denied

### 2. **Distance Calculation**
- Uses Haversine formula to calculate accurate distances
- Shows distance on each item card (e.g., "2.5 km", "500 m")
- Sorts items by distance (closest first)

### 3. **Search Radius Filter**
- Default radius: 10 km
- Adjustable from 1 km to 50 km
- Tap the radius chip in the app bar to change
- Real-time filtering as you adjust the slider

### 4. **Location-Aware UI**
- **Home Screen**: Shows "Nearby Items (X)" with count
- **Item Cards**: Display distance badge at the top
- **Status Indicator**: Shows current search radius
- **Empty State**: Suggests increasing radius if no items found

## 📱 How It Works

### Home Screen
1. App requests location permission on launch
2. Gets current GPS coordinates
3. Fetches all available items from Firestore
4. Calculates distance for each item
5. Filters items within search radius
6. Sorts by distance (closest first)
7. Displays in 3D carousel with distance badges

### Data Flow
```
User Location → Location Provider → Items Provider → Filter by Radius → Sort by Distance → UI
```

## 🗺️ Sample Data

The app includes 5 sample items with different locations around Delhi:
- **Canon DSLR Camera** - ~1.5 km away
- **PlayStation 5** - ~2.1 km away
- **DJI Drone** - ~1.8 km away
- **Mountain Bike** - ~2.5 km away
- **Projector 4K** - ~2.2 km away

## 🔧 How to Use

### Change Search Radius
1. Tap the radius chip (e.g., "10 km") in the app bar
2. Adjust the slider (1-50 km)
3. Items update automatically
4. Tap "Done"

### View Item Distance
- Each item card shows distance at the top
- Format: "X.X km" or "XXX m" for distances < 1km

### Enable Location
If location is disabled:
1. You'll see an orange banner
2. Tap "Enable" button
3. Grant location permission
4. App refreshes automatically

## 📊 Firestore Integration

### Item Model Structure
```dart
{
  'title': 'Canon DSLR Camera',
  'category': 'Electronics',
  'rentalPricePerDay': 500,
  'location': {
    'latitude': 28.6139,
    'longitude': 77.2090,
    'geoPoint': GeoPoint(28.6139, 77.2090),
    'address': '123 Camera Street, Delhi',
    'city': 'Delhi',
    'state': 'Delhi',
    'country': 'India'
  },
  'status': 'available',
  // ... other fields
}
```

### Querying Nearby Items
The app uses:
1. **Client-side filtering** - Fetches all items, filters by distance
2. **Future enhancement**: Use Firestore geohash queries for better performance with large datasets

## 🚀 Next Steps

### To Add Real Data
1. Enable Firestore in Firebase Console
2. Create `items` collection
3. Add items with location data
4. Remove `sampleItemsProvider` usage
5. Use `nearbyItemsProvider` instead

### Performance Optimization
For large datasets (>1000 items):
1. Implement geohash-based queries
2. Use pagination
3. Cache nearby items
4. Add background location updates

## 🎯 Features in Action

### Home Screen
- ✅ Shows user's current location status
- ✅ Displays search radius chip
- ✅ Lists nearby items with distances
- ✅ Updates when radius changes
- ✅ Smooth 3D carousel with distance badges

### Map Screen (Ready for Integration)
- Markers for each item
- Cluster markers when zoomed out
- Bottom sheet with nearby items
- Tap marker to see item details

## 🔐 Permissions Required

### Android (Already Added)
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
```

### Runtime Permission Handling
- Automatically requests on first launch
- Shows explanation if denied
- Provides "Enable" button to retry
- Works without location (shows all items)

---

**Status**: ✅ Location-based discovery fully implemented and working!

Run the app and allow location permission to see items sorted by distance from your current location. 🎉
