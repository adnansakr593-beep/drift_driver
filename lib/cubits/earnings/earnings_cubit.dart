import 'dart:async';
import 'package:drift_driver/cubits/earnings/earnings_state.dart';
import 'package:drift_driver/models/active_trip_model.dart';
import 'package:drift_driver/models/driver_model.dart';
import 'package:drift_driver/services/driver_firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EarningsCubit extends Cubit<EarningsState> {
  EarningsCubit() : super(EarningsInitial());

  final _auth = FirebaseAuth.instance;
  StreamSubscription<DriverModel>? _driverSub;
  StreamSubscription<List<ActiveTripModel>>? _tripsSub;

  DriverModel? _driver;
  List<ActiveTripModel> _trips = [];

  void load() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      emit(EarningsError(message: 'Not authenticated'));
      return;
    }
    emit(EarningsLoading());

    _driverSub = DriverFirestoreService.driverStream(uid).listen((driver) {
      _driver = driver;
      _emitLoaded();
    });

    _tripsSub =
        DriverFirestoreService.completedTripsStream(uid).listen((trips) {
      _trips = trips;
      _emitLoaded();
    }, onError: (e) {
      emit(EarningsError(message: e.toString()));
    });
  }

  void _emitLoaded() {
    if (_driver != null) {
      emit(EarningsLoaded(driver: _driver!, completedTrips: _trips));
    }
  }

  @override
  Future<void> close() {
    _driverSub?.cancel();
    _tripsSub?.cancel();
    return super.close();
  }
}
