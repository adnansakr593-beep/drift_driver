import 'package:drift_driver/models/ride_request_model.dart';

abstract class RideRequestsState {}

class RideRequestsInitial extends RideRequestsState {}

class RideRequestsLoading extends RideRequestsState {}

class RideRequestsLoaded extends RideRequestsState {
  final List<RideRequestModel> requests;
  RideRequestsLoaded({required this.requests});
}

class RideRequestsEmpty extends RideRequestsState {}

class RideRequestsError extends RideRequestsState {
  final String message;
  RideRequestsError({required this.message});
}
