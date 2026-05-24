import 'dart:async';
import 'package:drift_driver/cubits/active_trip/active_trip_state.dart';
import 'package:drift_driver/models/active_trip_model.dart';
import 'package:drift_driver/models/driver_model.dart';
import 'package:drift_driver/models/ride_request_model.dart';
import 'package:drift_driver/services/driver_firestore_service.dart';
import 'package:drift_driver/services/location_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';

class ActiveTripCubit extends Cubit<ActiveTripState> {
  ActiveTripCubit() : super(ActiveTripInitial());

  final _auth = FirebaseAuth.instance;
  StreamSubscription<ActiveTripModel>? _tripSub;
  StreamSubscription<LatLng>? _locationSub;
  String? _currentTripId;
  String? _currentRequestId;

  String? get currentTripId => _currentTripId;

  // ── Accept a ride request ──────────────────────────────────────────────────
  Future<void> acceptRequest({
    required RideRequestModel request,
    required DriverModel driver,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      emit(ActiveTripError(message: 'Not authenticated'));
      return;
    }

    emit(ActiveTripAccepting());

    try {
      final tripId = await DriverFirestoreService.acceptRequest(
        requestId: request.id,
        driverId: uid,
        driverName: driver.name,
        driverPhoto: driver.photo,
        vehicleModel: driver.vehicleModel,
        vehiclePlate: driver.vehiclePlate,
        driverRating: driver.rating,
        request: request,
      );

      _currentTripId = tripId;
      _currentRequestId = request.id;

      // Start streaming location to trip doc
      _locationSub = LocationService.getStream().listen((loc) {
        if (_currentTripId != null) {
          DriverFirestoreService.updateTripDriverLocation(_currentTripId!, loc);
        }
      });

      // Listen to trip doc changes (so we can react to user cancellations)
      _tripSub =
          DriverFirestoreService.activeTripStream(tripId).listen((trip) {
        if (trip.status == 'cancelled') {
          _cleanupSubscriptions();
          emit(ActiveTripCancelled());
        } else {
          emit(ActiveTripActive(trip: trip));
        }
      }, onError: (e) {
        emit(ActiveTripError(message: e.toString()));
      });
    } catch (e) {
      emit(ActiveTripError(message: e.toString()));
    }
  }

  // ── Driver arrived at pickup ───────────────────────────────────────────────
  Future<void> markArrived() async {
    if (_currentTripId == null) return;
    try {
      await DriverFirestoreService.updateTripStatus(_currentTripId!, 'arrived');
    } catch (e) {
      emit(ActiveTripError(message: e.toString()));
    }
  }

  // ── Start trip (passenger boarded) ────────────────────────────────────────
  Future<void> startTrip() async {
    if (_currentTripId == null) return;
    try {
      await DriverFirestoreService.updateTripStatus(
          _currentTripId!, 'inProgress');
    } catch (e) {
      emit(ActiveTripError(message: e.toString()));
    }
  }

  // ── Complete trip ──────────────────────────────────────────────────────────
  Future<void> completeTrip({required double earnedAmount}) async {
    if (_currentTripId == null || _currentRequestId == null) return;
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      await DriverFirestoreService.completeTrip(
        tripId: _currentTripId!,
        requestId: _currentRequestId!,
        driverId: uid,
        earnedAmount: earnedAmount,
      );

      _cleanupSubscriptions();
      emit(ActiveTripCompleted(earnedAmount: earnedAmount));
    } catch (e) {
      emit(ActiveTripError(message: e.toString()));
    }
  }

  // ── Cancel trip ────────────────────────────────────────────────────────────
  Future<void> cancelTrip() async {
    if (_currentTripId == null || _currentRequestId == null) return;
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      await DriverFirestoreService.cancelTrip(
        tripId: _currentTripId!,
        requestId: _currentRequestId!,
        driverId: uid,
      );

      _cleanupSubscriptions();
      emit(ActiveTripCancelled());
    } catch (e) {
      emit(ActiveTripError(message: e.toString()));
    }
  }

  // ── Internal ───────────────────────────────────────────────────────────────
  void _cleanupSubscriptions() {
    _tripSub?.cancel();
    _tripSub = null;
    _locationSub?.cancel();
    _locationSub = null;
    _currentTripId = null;
    _currentRequestId = null;
  }

  @override
  Future<void> close() {
    _cleanupSubscriptions();
    return super.close();
  }
}
