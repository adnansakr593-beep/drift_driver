import 'package:drift_driver/models/active_trip_model.dart';
import 'package:drift_driver/models/driver_model.dart';

abstract class EarningsState {}

class EarningsInitial extends EarningsState {}

class EarningsLoading extends EarningsState {}

class EarningsLoaded extends EarningsState {
  final DriverModel driver;
  final List<ActiveTripModel> completedTrips;
  EarningsLoaded({required this.driver, required this.completedTrips});
}

class EarningsError extends EarningsState {
  final String message;
  EarningsError({required this.message});
}
