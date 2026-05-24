abstract class DriverStatusState {}

class DriverStatusInitial extends DriverStatusState {}

class DriverStatusLoading extends DriverStatusState {}

class DriverStatusOnline extends DriverStatusState {
  final double lat;
  final double lng;
  DriverStatusOnline({required this.lat, required this.lng});
}

class DriverStatusOffline extends DriverStatusState {}

class DriverStatusError extends DriverStatusState {
  final String message;
  DriverStatusError({required this.message});
}
