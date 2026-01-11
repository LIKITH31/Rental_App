# Rental App - Setup Instructions

## ✅ What's Already Done

- ✅ Flutter project created with package `com.rental.b3324.rental_app`
- ✅ All required packages installed (Firebase, Google Maps, Riverpod, Animations)
- ✅ Android configuration ready (minSdk 21, permissions added)
- ✅ Interactive 3D UI with smooth animations built
- ✅ Material 3 theme with light/dark mode
- ✅ Bottom navigation with 5 screens
- ✅ Beautiful animated home screen with 3D card carousel

## 🔧 Required Setup Steps

### 1. Download google-services.json from Firebase

**This is the MOST IMPORTANT step:**

1. Go to https://console.firebase.google.com/project/rental-b3324-project
2. Click the ⚙️ gear icon → **Project settings**
3. Scroll to "Your apps" section
4. Click **"Add app"** → Select **Android** (robot icon)
5. Enter these details:
   - **Android package name**: `com.rental.b3324.rental_app`
   - **App nickname** (optional): Rental App
   - **Debug signing certificate SHA-1** (optional for now, can add later)
6. Click **"Register app"**
7. **Download `google-services.json`**
8. Place the file here: `android/app/google-services.json`

### 2. Update Firebase Configuration

Open `lib/firebase_options.dart` and replace the placeholder values with your actual Firebase config:

1. In Firebase Console → Project settings → Your apps → Android app
2. Scroll to "SDK setup and configuration"
3. Copy the values and update these lines in `firebase_options.dart`:

```dart
apiKey: 'YOUR_ACTUAL_API_KEY',  // e.g., 'AIzaSyD...'
appId: 'YOUR_ACTUAL_APP_ID',    // e.g., '1:123456:android:abc123'
messagingSenderId: 'YOUR_SENDER_ID',  // e.g., '123456789'
```

### 3. Get Google Maps API Key

1. Go to https://console.cloud.google.com/
2. Select your Firebase project (rental-b3324-project)
3. Click **"APIs & Services"** → **"Library"**
4. Search and enable:
   - **Maps SDK for Android**
   - **Places API** (optional, for autocomplete)
5. Go to **"Credentials"** → **"Create Credentials"** → **"API Key"**
6. Copy the API key
7. Open `android/app/src/main/AndroidManifest.xml`
8. Replace `YOUR_GOOGLE_MAPS_API_KEY_HERE` with your actual API key

### 4. Enable Firebase Services

In Firebase Console, enable these services:

1. **Authentication**:
   - Go to Authentication → Get started
   - Enable **Email/Password**
   - Enable **Google** sign-in

2. **Firestore Database**:
   - Go to Firestore Database → Create database
   - Start in **test mode** (for development)
   - Choose a location (e.g., asia-south1)

3. **Storage**:
   - Go to Storage → Get started
   - Start in **test mode** (for development)

### 5. Optional: Enable Developer Mode (for symlinks)

If you see symlink warnings:

1. Press **Win + R**
2. Type: `ms-settings:developers`
3. Toggle **"Developer Mode"** ON

## 🚀 Running the App

Once you've completed steps 1-3 above:

```powershell
# Navigate to project
cd c:\Users\user\CascadeProjects\windsurf-project\rental_app

# Run the app
flutter run
```

## 📱 Features Implemented

### ✨ Interactive 3D UI
- **3D Card Carousel**: Swipe through featured items with perspective transforms
- **Smooth Animations**: Fade, scale, slide, shimmer effects using flutter_animate
- **Material 3 Design**: Modern, beautiful UI with gradient cards
- **Category Grid**: Animated category tiles with icons

### 🎨 Screens
1. **Home/Discover**: 3D carousel of featured items + category grid
2. **Map**: Placeholder for Google Maps integration
3. **Add Listing**: Placeholder for creating new listings
4. **My Rentals**: Placeholder for rental management
5. **Profile**: Placeholder for user profile

### 🔐 Auth Screen (Ready)
- Email/Password sign in/up with validation
- Google Sign-In button (needs Firebase config)
- Smooth gradient background with animations

## 🎯 Next Steps After Setup

1. **Test the app**: Run `flutter run` and see the beautiful 3D UI
2. **Implement Firebase Auth**: Wire up the auth screen to Firebase
3. **Add Firestore**: Create data models and CRUD operations
4. **Google Maps**: Implement map screen with location markers
5. **Image Upload**: Add multi-image picker for listings
6. **Search & Filters**: Implement search functionality

## 🐛 Troubleshooting

### Firebase initialization fails
- Ensure `google-services.json` is in `android/app/`
- Verify `firebase_options.dart` has correct values
- Check Firebase project ID matches: `rental-b3324-project`

### Maps not showing
- Verify API key in AndroidManifest.xml
- Ensure Maps SDK for Android is enabled in Google Cloud Console
- Check internet permission is in AndroidManifest (already added)

### Build errors
```powershell
# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

## 📦 Installed Packages

- `flutter_riverpod` - State management
- `firebase_core` - Firebase initialization
- `firebase_auth` - Authentication
- `cloud_firestore` - Database
- `firebase_storage` - File storage
- `google_sign_in` - Google OAuth
- `google_maps_flutter` - Maps integration
- `geolocator` - Location services
- `image_picker` - Image selection
- `flutter_animate` - Smooth animations
- `rive` - Advanced animations (for future use)
- `flutter_dotenv` - Environment variables

## 🎨 UI Highlights

The app features a **smooth, interactive 3D experience**:

- **Perspective transforms** on card carousel
- **Parallax effects** on scroll
- **Shimmer animations** on icons and buttons
- **Gradient backgrounds** throughout
- **Hero transitions** ready for navigation
- **Responsive design** for different screen sizes

---

**Status**: App is scaffolded and ready to run once you complete the 3 setup steps above! 🚀
