import 'package:drift_driver/models/active_trip_model.dart';

abstract class ActiveTripState {}

class ActiveTripInitial extends ActiveTripState {}

class ActiveTripAccepting extends ActiveTripState {}

class ActiveTripActive extends ActiveTripState {
  final ActiveTripModel trip;
  ActiveTripActive({required this.trip});
}

class ActiveTripCompleted extends ActiveTripState {
  final double earnedAmount;
  ActiveTripCompleted({required this.earnedAmount});
}

class ActiveTripCancelled extends ActiveTripState {}

class ActiveTripError extends ActiveTripState {
  final String message;
  ActiveTripError({required this.message});
}
