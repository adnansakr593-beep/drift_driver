import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift_driver/cubits/active_trip/active_trip_cubit.dart';
import 'package:drift_driver/cubits/driver_auth/driver_auth_cubit.dart';
import 'package:drift_driver/cubits/driver_status/driver_status_cubit.dart';
import 'package:drift_driver/cubits/earnings/earnings_cubit.dart';
import 'package:drift_driver/cubits/forgot_password/forgot_pass_cubit.dart';
import 'package:drift_driver/cubits/google_signin/google_signin_cubit.dart';
import 'package:drift_driver/cubits/ride_requests/ride_requests_cubit.dart';
import 'package:drift_driver/cubits/theme_cubit/theme_cubit.dart';
import 'package:drift_driver/cubits/theme_cubit/theme_state.dart';
import 'package:drift_driver/cubits/user_profile_cubit/user_profile_cubit.dart';
import 'package:drift_driver/firebase_options.dart';
import 'package:drift_driver/pages/complete_profile_page.dart';
import 'package:drift_driver/pages/driver_home_page.dart';
import 'package:drift_driver/pages/driver_register_page.dart';
import 'package:drift_driver/pages/driver_signin_page.dart';
import 'package:drift_driver/pages/earnings_page.dart';
import 'package:drift_driver/themes/dark_theme.dart';
import 'package:drift_driver/themes/light_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const DriftDriverApp());
}

class DriftDriverApp extends StatelessWidget {
  const DriftDriverApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit()),
        BlocProvider(create: (_) => DriverAuthCubit()),
        BlocProvider(create: (_) => DriverStatusCubit()),
        BlocProvider(create: (_) => RideRequestsCubit()),
        BlocProvider(create: (_) => ActiveTripCubit()),
        BlocProvider(create: (_) => EarningsCubit()),
        BlocProvider(create: (_) => ForgotPassCubit()),
        BlocProvider(create: (_) => GoogleSigninCubit()),
        BlocProvider(create: (_) => UserProfileCubit()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp(
            title: 'Drift Driver',
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: themeState.themeMode,
            debugShowCheckedModeBanner: false,
            routes: {
              SigninPage.id: (_) => const SigninPage(),
              DriverRegisterPage.id: (_) => const DriverRegisterPage(),
              CompleteProfilePage.id: (_) => const CompleteProfilePage(),
              HomePage.id: (_) => const HomePage(),
              EarningsPage.id: (_) => const EarningsPage(),
            },
            home: const _AuthWrapper(),
          );
        },
      ),
    );
  }
}

// ── Auth Wrapper ───────────────────────────────────────────────────────────────
class _AuthWrapper extends StatefulWidget {
  const _AuthWrapper();

  @override
  State<_AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<_AuthWrapper>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) _updatePresence(user.uid, state);
  }

  Future<void> _updatePresence(String driverId, AppLifecycleState state) async {
    try {
      if (state == AppLifecycleState.hidden) return;
      final isOnline = state == AppLifecycleState.resumed;
      await FirebaseFirestore.instance
          .collection('drivers')
          .doc(driverId)
          .update({
        'isOnline': isOnline,
        'lastSeen': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          final colors = Theme.of(context).colorScheme;
          return Scaffold(
            backgroundColor: colors.background,
            body: Center(
              child: CircularProgressIndicator(color: colors.primary),
            ),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          // Update presence on resume
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _updatePresence(snapshot.data!.uid, AppLifecycleState.resumed);
          });
          return const HomePage();
        }

        return const SigninPage();
      },
    );
  }
}
