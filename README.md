# Drift Driver App

Built as the driver-side companion to the [Drift User App](https://github.com/adnansakr593-beep/Drift.git).
Same Firebase project, same UI language, same architecture.

---

## Project Structure

```
lib/
├── main.dart                          # Entry point, MultiBlocProvider, AuthWrapper
├── firebase_options.dart              # Same Firebase project as user app (drift-11)
├── helper/
│   └── const.dart                     # fontFamily, logo paths
├── themes/
│   ├── dark_theme.dart
│   └── light_theme.dart
├── models/
│   ├── driver_model.dart              # drivers/{uid}
│   ├── ride_request_model.dart        # ride_requests/{id}
│   ├── active_trip_model.dart         # trips/{id}
│   └── route_info.dart               # polyline + distance helpers
├── services/
│   ├── location_service.dart          # GPS — identical to user app
│   ├── routing_service.dart           # OSRM routing — identical to user app
│   └── driver_firestore_service.dart  # All Firestore reads/writes
├── cubits/
│   ├── driver_auth/                   # Sign in, register, complete profile, sign out
│   ├── driver_status/                 # Online/offline toggle + location streaming
│   ├── ride_requests/                 # Real-time pending requests listener
│   ├── active_trip/                   # Accept → arrived → inProgress → complete
│   ├── earnings/                      # Driver stats + completed trips stream
│   └── theme_cubit/                   # Dark/light toggle (shared preferences)
├── pages/
│   ├── driver_signin_page.dart
│   ├── driver_register_page.dart
│   ├── complete_profile_page.dart
│   ├── driver_home_page.dart          # Main map + requests + active trip
│   └── earnings_page.dart
└── widgets/
    ├── glass_cont.dart                # Glassmorphism card (identical to user app)
    ├── custom_button.dart
    ├── custom_text_form_field.dart
    ├── map_markers.dart               # DriverMarker, UserLocationMarker, DestinationMarker
    ├── fab_btn.dart
    ├── ride_request_card.dart         # Accept/decline card shown to driver
    ├── active_trip_sheet.dart         # Bottom sheet during live trip
    └── driver_status_toggle.dart      # Online/offline toggle sheet
```

---

## Firestore Collections

The driver app shares the same Firebase project and writes to these collections:

### `drivers/{driverUid}`
```
name, email, photo, phone,
vehicleModel, vehiclePlate,
isOnline, isAvailable,
currentLocation (GeoPoint),
lastSeen (Timestamp),
rating, totalTrips, earnings,
createdAt
```

### `ride_requests/{requestId}`
Written by the **User App** when a user taps "Start Trip".
```
userId, userName, userPhoto,
userLocation (GeoPoint),
destination (GeoPoint), destinationName,
distanceKm, durationMin, offeredPrice,
tripMode, status, acceptedBy, createdAt
```

### `trips/{tripId}`
Created by the **Driver App** when a driver accepts a request.
```
requestId, userId, userName, userPhoto,
driverId, driverName, driverPhoto,
vehicleModel, vehiclePlate, driverRating,
originLocation, destination, destinationName,
driverLocation (updated live),
offeredPrice, tripMode,
status: driverEnRoute → arrived → inProgress → completed,
startedAt, completedAt, createdAt
```

---

## Setup Steps

### 1. Create Flutter project
```bash
flutter create drift_driver
cd drift_driver
```

### 2. Replace generated files with this project's files
Copy everything from this repo into the `drift_driver/` folder.

### 3. Copy assets from User App
Copy the same asset folders from the user app:
```
assets/images/          → drift_logo.png, logo02.png
assets/fonts/           → Space_Grotesk/static/*.ttf
```

### 4. Add Android permissions
In `android/app/src/main/AndroidManifest.xml`, inside `<manifest>`:
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION"/>
<uses-permission android:name="android.permission.INTERNET"/>
```

### 5. Add iOS permissions
In `ios/Runner/Info.plist`:
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Drift Driver needs your location to accept rides.</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>Drift Driver needs your location while driving.</string>
```

### 6. Add google-services.json / GoogleService-Info.plist
Use the **same** files from the user app (same Firebase project `drift-11`).
- Android: `android/app/google-services.json`
- iOS: `ios/Runner/GoogleService-Info.plist`

### 7. Install dependencies
```bash
flutter pub get
```

### 8. Run
```bash
flutter run
```

---

## Firestore Rules Required

Add these rules to your Firebase Console → Firestore → Rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Drivers can read/write their own document
    match /drivers/{driverId} {
      allow read, write: if request.auth != null && request.auth.uid == driverId;
    }

    // Ride requests: users create, drivers read & update status
    match /ride_requests/{requestId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update: if request.auth != null;
    }

    // Trips: driver or user of the trip can read/write
    match /trips/{tripId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update: if request.auth != null
        && (resource.data.driverId == request.auth.uid
            || resource.data.userId == request.auth.uid);
    }

    // Users collection (user app): drivers read-only for user info
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

---

## User App Integration

For the user app to show the driver's live location, add this stream listener
in the User App's `MapPage` or a new `TripTrackingCubit`:

```dart
// Listen to trips/{tripId} for live driverLocation updates
FirebaseFirestore.instance
  .collection('trips')
  .doc(tripId)
  .snapshots()
  .listen((snap) {
    final data = snap.data();
    final geo = data?['driverLocation'] as GeoPoint?;
    if (geo != null) {
      // Update driver marker on user's map
    }
  });
```

---

## Data Flow Summary

```
User App                              Driver App
─────────────────────────────────────────────────────────
User sets destination
  ↓ taps "Start Trip"
ride_requests/{id} created
  status: pending
                              ←── Driver app listens
                                  RideRequestsCubit
                              ←── Driver sees request card
                              ←── Driver taps Accept
                                  ActiveTripCubit.acceptRequest()
                                  → ride_requests/{id} status: accepted
                                  → trips/{id} created, status: driverEnRoute
                                  → drivers/{uid} isAvailable: false
User app listens to trips/{id} ───→ Sees driver info + live location
                              ←── Driver taps "I've Arrived"
                                  trips/{id} status: arrived
                              ←── Driver taps "Start Trip"
                                  trips/{id} status: inProgress
                              ←── Driver taps "Complete Trip"
                                  trips/{id} status: completed
                                  ride_requests/{id} status: completed
                                  drivers/{uid} earnings += price, totalTrips++
```
