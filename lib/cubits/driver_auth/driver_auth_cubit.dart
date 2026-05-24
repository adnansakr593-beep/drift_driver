import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift_driver/cubits/driver_auth/driver_auth_state.dart';
import 'package:drift_driver/services/driver_firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DriverAuthCubit extends Cubit<DriverAuthState> {
  DriverAuthCubit() : super(DriverAuthInitial());

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  // ── Sign In ────────────────────────────────────────────────────────────────
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    emit(DriverAuthLoading());
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user!;

      final exists = await DriverFirestoreService.driverDocExists(user.uid);
      if (!exists) {
        emit(DriverAuthNeedsProfile(user: user));
      } else {
        await _firestore.collection('drivers').doc(user.uid).update({
          'lastSeen': FieldValue.serverTimestamp(),
        });
        emit(DriverAuthSuccess(user: user));
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        emit(DriverAuthFail(message: 'No driver found with this email'));
      } else if (e.code == 'wrong-password') {
        emit(DriverAuthFail(message: 'Wrong password'));
      } else {
        emit(DriverAuthFail(message: 'Error: ${e.code}'));
      }
    } catch (e) {
      emit(DriverAuthFail(message: e.toString()));
    }
  }

  // ── Register ───────────────────────────────────────────────────────────────
  Future<void> register({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String vehicleModel,
    required String vehiclePlate,
  }) async {
    emit(DriverAuthLoading());
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user!;

      await user.updateDisplayName(name);

      await DriverFirestoreService.createDriverDoc(
        uid: user.uid,
        name: name,
        email: email,
        phone: phone,
        vehicleModel: vehicleModel,
        vehiclePlate: vehiclePlate,
      );

      emit(DriverAuthSuccess(user: user));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        emit(DriverAuthFail(message: 'Email already in use'));
      } else if (e.code == 'weak-password') {
        emit(DriverAuthFail(message: 'Password too weak'));
      } else {
        emit(DriverAuthFail(message: 'Error: ${e.code}'));
      }
    } catch (e) {
      emit(DriverAuthFail(message: e.toString()));
    }
  }

  // ── Complete profile (after first sign-in if doc missing) ─────────────────
  Future<void> completeProfile({
    required String phone,
    required String vehicleModel,
    required String vehiclePlate,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      emit(DriverAuthFail(message: 'Not authenticated'));
      return;
    }
    emit(DriverAuthLoading());
    try {
      await DriverFirestoreService.createDriverDoc(
        uid: user.uid,
        name: user.displayName ?? user.email?.split('@')[0] ?? 'Driver',
        email: user.email ?? '',
        phone: phone,
        vehicleModel: vehicleModel,
        vehiclePlate: vehiclePlate,
        photo: user.photoURL,
      );
      emit(DriverAuthSuccess(user: user));
    } catch (e) {
      emit(DriverAuthFail(message: e.toString()));
    }
  }

  // ── Sign Out ───────────────────────────────────────────────────────────────
  Future<void> signOut() async {
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      try {
        await _firestore.collection('drivers').doc(uid).update({
          'isOnline': false,
          'isAvailable': false,
          'lastSeen': FieldValue.serverTimestamp(),
        });
      } catch (_) {}
    }
    await _auth.signOut();
    emit(DriverAuthSignedOut());
  }

  // ── Forgot Password ────────────────────────────────────────────────────────
  Future<void> forgotPassword(String email) async {
    emit(DriverAuthLoading());
    try {
      await _auth.sendPasswordResetEmail(email: email);
      emit(DriverAuthSignedOut()); // reuse signed-out state to trigger snackbar
    } catch (e) {
      emit(DriverAuthFail(message: 'Failed to send reset email'));
    }
  }
}
