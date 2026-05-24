import 'package:firebase_auth/firebase_auth.dart';

abstract class DriverAuthState {}

class DriverAuthInitial extends DriverAuthState {}

class DriverAuthLoading extends DriverAuthState {}

class DriverAuthSuccess extends DriverAuthState {
  final User user;
  DriverAuthSuccess({required this.user});
}

class DriverAuthNeedsProfile extends DriverAuthState {
  final User user;
  DriverAuthNeedsProfile({required this.user});
}

class DriverAuthFail extends DriverAuthState {
  final String message;
  DriverAuthFail({required this.message});
}

class DriverAuthSignedOut extends DriverAuthState {}
