import 'dart:async';
import 'package:drift_driver/cubits/driver_status/driver_status_state.dart';
import 'package:drift_driver/services/driver_firestore_service.dart';
import 'package:drift_driver/services/location_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';

class DriverStatusCubit extends Cubit<DriverStatusState> {
  DriverStatusCubit() : super(DriverStatusInitial());

  final _auth = FirebaseAuth.instance;
  StreamSubscription<LatLng>? _locationSub;
  bool _isOnline = false;

  bool get isOnline => _isOnline;

  // ── Go Online ──────────────────────────────────────────────────────────────
  Future<void> goOnline() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      emit(DriverStatusError(message: 'Not authenticated'));
      return;
    }

    emit(DriverStatusLoading());

    try {
      final initialLoc = await LocationService.getCurrentLocation();

      await DriverFirestoreService.setOnline(uid, initialLoc);

      _isOnline = true;
      emit(DriverStatusOnline(
        lat: initialLoc.latitude,
        lng: initialLoc.longitude,
      ));

      // Stream location updates to Firestore
      _locationSub = LocationService.getStream().listen((loc) {
        if (!_isOnline) return;
        DriverFirestoreService.updateLocation(uid, loc);
        emit(DriverStatusOnline(lat: loc.latitude, lng: loc.longitude));
      });
    } catch (e) {
      emit(DriverStatusError(message: e.toString()));
    }
  }

  // ── Go Offline ─────────────────────────────────────────────────────────────
  Future<void> goOffline() async {
    final uid = _auth.currentUser?.uid;

    _locationSub?.cancel();
    _locationSub = null;
    _isOnline = false;

    if (uid != null) {
      try {
        await DriverFirestoreService.setOffline(uid);
      } catch (_) {}
    }

    emit(DriverStatusOffline());
  }

  // ── Toggle ─────────────────────────────────────────────────────────────────
  Future<void> toggleStatus() async {
    if (_isOnline) {
      await goOffline();
    } else {
      await goOnline();
    }
  }

  @override
  Future<void> close() {
    _locationSub?.cancel();
    return super.close();
  }
}
