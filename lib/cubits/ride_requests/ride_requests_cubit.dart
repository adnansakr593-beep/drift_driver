import 'dart:async';
import 'package:drift_driver/cubits/ride_requests/ride_requests_state.dart';
import 'package:drift_driver/models/ride_request_model.dart';
import 'package:drift_driver/services/driver_firestore_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';

class RideRequestsCubit extends Cubit<RideRequestsState> {
  RideRequestsCubit() : super(RideRequestsInitial());

  StreamSubscription<List<RideRequestModel>>? _sub;
  static const double _radiusKm = 15.0;

  // ── Start listening ────────────────────────────────────────────────────────
  void startListening({LatLng? driverLocation}) {
    emit(RideRequestsLoading());

    _sub?.cancel();
    _sub = DriverFirestoreService.pendingRequestsStream().listen(
      (allRequests) {
        List<RideRequestModel> filtered = allRequests;

        // Filter by proximity if driver location is known
        if (driverLocation != null) {
          const calc = Distance();
          filtered = allRequests.where((req) {
            final dist = calc.as(
              LengthUnit.Kilometer,
              driverLocation,
              req.userLocation,
            );
            return dist <= _radiusKm;
          }).toList();
        }

        if (filtered.isEmpty) {
          emit(RideRequestsEmpty());
        } else {
          emit(RideRequestsLoaded(requests: filtered));
        }
      },
      onError: (e) {
        emit(RideRequestsError(message: e.toString()));
      },
    );
  }

  // ── Stop listening ─────────────────────────────────────────────────────────
  void stopListening() {
    _sub?.cancel();
    _sub = null;
    emit(RideRequestsInitial());
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
