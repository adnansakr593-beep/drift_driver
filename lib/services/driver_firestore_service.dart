import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';
import '../models/driver_model.dart';
import '../models/ride_request_model.dart';
import '../models/active_trip_model.dart';

// ══ Firestore Collections ══════════════════════════════════════════════════
//
//  drivers/
//   └── {driverUid}: name, email, photo, phone, vehicleModel, vehiclePlate,
//                    isOnline, isAvailable, currentLocation (GeoPoint),
//                    lastSeen, rating, totalTrips, earnings
//
//  ride_requests/
//   └── {requestId}: userId, userName, userPhoto, userLocation, destination,
//                    destinationName, distanceKm, durationMin, offeredPrice,
//                    tripMode, status, acceptedBy, createdAt
//
//  trips/
//   └── {tripId}: requestId, userId, userName, userPhoto,
//                 driverId, driverName, driverPhoto, vehicleModel, vehiclePlate,
//                 driverRating, originLocation, destination, destinationName,
//                 driverLocation, offeredPrice, tripMode,
//                 status, startedAt, completedAt, createdAt
//
// ══════════════════════════════════════════════════════════════════════════

class DriverFirestoreService {
  static final _db = FirebaseFirestore.instance;

  // ── Driver doc ─────────────────────────────────────────────────────────────
  static Future<void> createDriverDoc({
    required String uid,
    required String name,
    required String email,
    required String phone,
    required String vehicleModel,
    required String vehiclePlate,
    String? photo,
  }) async {
    await _db.collection('drivers').doc(uid).set({
      'name': name,
      'email': email,
      'photo': photo,
      'phone': phone,
      'vehicleModel': vehicleModel,
      'vehiclePlate': vehiclePlate,
      'isOnline': false,
      'isAvailable': false,
      'rating': 5.0,
      'totalTrips': 0,
      'earnings': 0.0,
      'createdAt': FieldValue.serverTimestamp(),
      'lastSeen': FieldValue.serverTimestamp(),
    });
  }

  static Future<bool> driverDocExists(String uid) async {
    final doc = await _db.collection('drivers').doc(uid).get();
    return doc.exists;
  }

  static Future<DriverModel?> getDriver(String uid) async {
    final doc = await _db.collection('drivers').doc(uid).get();
    if (!doc.exists) return null;
    return DriverModel.fromMap(uid, doc.data()!);
  }

  static Stream<DriverModel> driverStream(String uid) {
    return _db.collection('drivers').doc(uid).snapshots().map(
          (snap) => DriverModel.fromMap(uid, snap.data() ?? {}),
        );
  }

  // ── Online/Offline ─────────────────────────────────────────────────────────
  static Future<void> setOnline(String uid, LatLng location) async {
    await _db.collection('drivers').doc(uid).update({
      'isOnline': true,
      'isAvailable': true,
      'currentLocation': GeoPoint(location.latitude, location.longitude),
      'lastSeen': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> setOffline(String uid) async {
    await _db.collection('drivers').doc(uid).update({
      'isOnline': false,
      'isAvailable': false,
      'lastSeen': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> updateLocation(String uid, LatLng location) async {
    await _db.collection('drivers').doc(uid).update({
      'currentLocation': GeoPoint(location.latitude, location.longitude),
      'lastSeen': FieldValue.serverTimestamp(),
    });
  }

  // ── Ride Requests ──────────────────────────────────────────────────────────
  static Stream<List<RideRequestModel>> pendingRequestsStream() {
    return _db
        .collection('ride_requests')
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => RideRequestModel.fromMap(d.id, d.data()))
            .toList());
  }

  /// Accept a request atomically — prevents two drivers accepting same trip
  static Future<String> acceptRequest({
    required String requestId,
    required String driverId,
    required String driverName,
    required String? driverPhoto,
    required String vehicleModel,
    required String vehiclePlate,
    required double driverRating,
    required RideRequestModel request,
  }) async {
    final requestRef = _db.collection('ride_requests').doc(requestId);
    final tripRef = _db.collection('trips').doc();

    await _db.runTransaction((tx) async {
      final snap = await tx.get(requestRef);
      if (!snap.exists) throw Exception('Request no longer exists');

      final currentStatus = snap.data()?['status'] as String? ?? '';
      if (currentStatus != 'pending') {
        throw Exception('Request already taken');
      }

      // Mark request as accepted
      tx.update(requestRef, {
        'status': 'accepted',
        'acceptedBy': driverId,
      });

      // Create trip document
      tx.set(tripRef, {
        'requestId': requestId,
        'userId': request.userId,
        'userName': request.userName,
        'userPhoto': request.userPhoto,
        'driverId': driverId,
        'driverName': driverName,
        'driverPhoto': driverPhoto,
        'vehicleModel': vehicleModel,
        'vehiclePlate': vehiclePlate,
        'driverRating': driverRating,
        'originLocation': GeoPoint(
          request.userLocation.latitude,
          request.userLocation.longitude,
        ),
        'destination': GeoPoint(
          request.destination.latitude,
          request.destination.longitude,
        ),
        'destinationName': request.destinationName,
        'driverLocation': GeoPoint(
          request.userLocation.latitude,
          request.userLocation.longitude,
        ),
        'offeredPrice': request.offeredPrice,
        'tripMode': request.tripMode,
        'status': 'driverEnRoute',
        'startedAt': null,
        'completedAt': null,
        'createdAt': FieldValue.serverTimestamp(),
      });
    });

    // Mark driver as unavailable
    await _db.collection('drivers').doc(driverId).update({
      'isAvailable': false,
    });

    return tripRef.id;
  }

  // ── Active Trip ────────────────────────────────────────────────────────────
  static Stream<ActiveTripModel> activeTripStream(String tripId) {
    return _db.collection('trips').doc(tripId).snapshots().map(
          (snap) => ActiveTripModel.fromMap(tripId, snap.data() ?? {}),
        );
  }

  static Future<void> updateTripDriverLocation(
      String tripId, LatLng location) async {
    await _db.collection('trips').doc(tripId).update({
      'driverLocation': GeoPoint(location.latitude, location.longitude),
    });
  }

  static Future<void> updateTripStatus(String tripId, String status) async {
    final Map<String, dynamic> data = {'status': status};
    if (status == 'inProgress') {
      data['startedAt'] = FieldValue.serverTimestamp();
    } else if (status == 'completed') {
      data['completedAt'] = FieldValue.serverTimestamp();
    }
    await _db.collection('trips').doc(tripId).update(data);
  }

  static Future<void> completeTrip({
    required String tripId,
    required String requestId,
    required String driverId,
    required double earnedAmount,
  }) async {
    final batch = _db.batch();

    batch.update(_db.collection('trips').doc(tripId), {
      'status': 'completed',
      'completedAt': FieldValue.serverTimestamp(),
    });

    batch.update(_db.collection('ride_requests').doc(requestId), {
      'status': 'completed',
    });

    batch.update(_db.collection('drivers').doc(driverId), {
      'isAvailable': true,
      'earnings': FieldValue.increment(earnedAmount),
      'totalTrips': FieldValue.increment(1),
      'lastSeen': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  static Future<void> cancelTrip({
    required String tripId,
    required String requestId,
    required String driverId,
  }) async {
    final batch = _db.batch();

    batch.update(_db.collection('trips').doc(tripId), {
      'status': 'cancelled',
    });

    batch.update(_db.collection('ride_requests').doc(requestId), {
      'status': 'cancelled',
      'acceptedBy': null,
    });

    batch.update(_db.collection('drivers').doc(driverId), {
      'isAvailable': true,
    });

    await batch.commit();
  }

  // ── Earnings history ───────────────────────────────────────────────────────
  static Stream<List<ActiveTripModel>> completedTripsStream(String driverId) {
    return _db
        .collection('trips')
        .where('driverId', isEqualTo: driverId)
        .where('status', isEqualTo: 'completed')
        .orderBy('completedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => ActiveTripModel.fromMap(d.id, d.data()))
            .toList());
  }
}
