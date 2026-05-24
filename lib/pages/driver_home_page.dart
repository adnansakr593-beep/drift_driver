// ignore_for_file: use_build_context_synchronously, deprecated_member_use
import 'dart:async';
import 'package:drift_driver/cubits/active_trip/active_trip_cubit.dart';
import 'package:drift_driver/cubits/active_trip/active_trip_state.dart';
import 'package:drift_driver/cubits/driver_status/driver_status_cubit.dart';
import 'package:drift_driver/cubits/driver_status/driver_status_state.dart';
import 'package:drift_driver/cubits/earnings/earnings_cubit.dart';
import 'package:drift_driver/cubits/ride_requests/ride_requests_cubit.dart';
import 'package:drift_driver/cubits/ride_requests/ride_requests_state.dart';
import 'package:drift_driver/cubits/theme_cubit/theme_cubit.dart';
import 'package:drift_driver/cubits/theme_cubit/theme_state.dart';
import 'package:drift_driver/helper/const.dart';
import 'package:drift_driver/models/driver_model.dart';
import 'package:drift_driver/models/ride_request_model.dart';
import 'package:drift_driver/pages/earnings_page.dart';
import 'package:drift_driver/services/driver_firestore_service.dart';
import 'package:drift_driver/services/routing_service.dart';
import 'package:drift_driver/widgets/active_trip_sheet.dart';
import 'package:drift_driver/widgets/custom_drawer.dart';
import 'package:drift_driver/widgets/driver_status_toggle.dart';
import 'package:drift_driver/widgets/fab_btn.dart';
import 'package:drift_driver/widgets/glass_cont.dart';
import 'package:drift_driver/widgets/map_markers.dart';
import 'package:drift_driver/widgets/ride_request_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/route_info.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  static String id = 'driver_home';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final _mapCtrl = MapController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _tileUrl =
      'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png';

  DriverModel? _driverModel;
  RouteInfo? _route;
  // ignore: unused_field
  LatLng? _routeDestination;
  bool _loadingRoute = false;

  // Dismissed request IDs (so cards don't reappear in same session)
  final Set<String> _dismissedIds = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadDriverModel();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final statusCubit = context.read<DriverStatusCubit>();
    if (state == AppLifecycleState.paused && statusCubit.isOnline) {
      statusCubit.goOffline();
      context.read<RideRequestsCubit>().stopListening();
    }
  }

  Future<void> _loadDriverModel() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final driver = await DriverFirestoreService.getDriver(uid);
    if (mounted) setState(() => _driverModel = driver);
  }

  // ── Draw route on map ──────────────────────────────────────────────────────
  Future<void> _drawRoute(LatLng from, LatLng to) async {
    setState(() {
      _loadingRoute = true;
      _routeDestination = to;
    });
    try {
      final route =
          await RoutingService.getRoute(origin: from, destination: to);
      if (!mounted) return;
      setState(() {
        _route = route;
        _loadingRoute = false;
      });
      _mapCtrl.fitCamera(
        CameraFit.bounds(
          bounds: LatLngBounds.fromPoints(route.points),
          padding: const EdgeInsets.all(70),
        ),
      );
    } catch (_) {
      if (mounted) setState(() => _loadingRoute = false);
    }
  }

  void _clearRoute() {
    setState(() {
      _route = null;
      _routeDestination = null;
    });
  }

  // ── Accept request ─────────────────────────────────────────────────────────
  Future<void> _acceptRequest(RideRequestModel request) async {
    if (_driverModel == null) {
      await _loadDriverModel();
      if (_driverModel == null) return;
    }

    // Draw route to pickup first
    final statusState = context.read<DriverStatusCubit>().state;
    if (statusState is DriverStatusOnline) {
      final driverLoc = LatLng(statusState.lat, statusState.lng);
      await _drawRoute(driverLoc, request.userLocation);
    }

    if (!mounted) return;
    await context.read<ActiveTripCubit>().acceptRequest(
          request: request,
          driver: _driverModel!,
        );

    // Stop showing new requests while on a trip
    context.read<RideRequestsCubit>().stopListening();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final topPad = MediaQuery.of(context).padding.top;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      key: _scaffoldKey,
      endDrawer: CustomDrawer(),
      body: Stack(
        children: [
          // ══ MAP ════════════════════════════════════════════════════════════
          BlocConsumer<DriverStatusCubit, DriverStatusState>(
            listener: (context, state) {
              if (state is DriverStatusOnline) {
                final loc = LatLng(state.lat, state.lng);
                _mapCtrl.move(loc, 16);
                // Start listening to requests with current driver location
                context.read<RideRequestsCubit>().startListening(
                      driverLocation: loc,
                    );
              } else if (state is DriverStatusOffline) {
                context.read<RideRequestsCubit>().stopListening();
                _clearRoute();
              }
            },
            builder: (context, statusState) {
              LatLng? driverLoc;
              LatLng? tripUserLoc;
              LatLng? tripDestLoc;

              if (statusState is DriverStatusOnline) {
                driverLoc = LatLng(statusState.lat, statusState.lng);
              }

              // Also pull trip destination for marker
              final tripState = context.watch<ActiveTripCubit>().state;
              if (tripState is ActiveTripActive) {
                tripUserLoc = tripState.trip.originLocation;
                tripDestLoc = tripState.trip.destination;
              }

              return FlutterMap(
                mapController: _mapCtrl,
                options: const MapOptions(
                  initialCenter: LatLng(30.0444, 31.2357),
                  initialZoom: 13,
                  minZoom: 5,
                  maxZoom: 19,
                ),
                children: [
                  BlocListener<ThemeCubit, ThemeState>(
                    listener: (context, state) {
                      setState(() {
                        _tileUrl = state.themeMode == ThemeMode.light
                            ? 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png'
                            : 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png';
                      });
                    },
                    child: TileLayer(
                      urlTemplate: _tileUrl,
                      subdomains: const ['a', 'b', 'c', 'd'],
                      userAgentPackageName: 'com.example.driftDriver',
                      maxZoom: 19,
                    ),
                  ),

                  // Route polyline
                  if (_route != null)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: _route!.points,
                          strokeWidth: 7,
                          color: colors.primary,
                          borderStrokeWidth: 2,
                          borderColor: Colors.white.withOpacity(0.5),
                        ),
                      ],
                    ),

                  MarkerLayer(
                    markers: [
                      // Driver marker
                      if (driverLoc != null)
                        Marker(
                          point: driverLoc,
                          width: 44,
                          height: 44,
                          child: const DriverMarker(),
                        ),
                      // Pickup marker (user location)
                      if (tripUserLoc != null)
                        Marker(
                          point: tripUserLoc,
                          width: 44,
                          height: 44,
                          child: const UserLocationMarker(),
                        ),
                      // Destination marker
                      if (tripDestLoc != null)
                        Marker(
                          point: tripDestLoc,
                          width: 44,
                          height: 44,
                          child: const DestinationMarker(),
                        ),
                    ],
                  ),
                ],
              );
            },
          ),

          // ══ TOP BAR ════════════════════════════════════════════════════════
          Positioned(
            top: topPad + 5,
            left: 5,
            right: 5,
            child: Row(
              children: [
                _TopBar(driverModel: _driverModel),
                const SizedBox(
                  width: 5,
                ),
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                          color: colors.background.withOpacity(0.5),
                          blurStyle: BlurStyle.inner),
                    ],
                    borderRadius: BorderRadius.circular(19),
                    //shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.05),
                    border: Border.all(
                        color: colors.onSurface.withOpacity(0.4), width: 1),
                  ),
                  child: IconButton(
                    onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
                    icon: Icon(Icons.menu_rounded, color: colors.onSurface),
                  ),
                ),
              ],
            ),
          ),

          // ══ FAB BUTTONS ════════════════════════════════════════════════════
          Positioned(
            bottom: 230,
            right: 16,
            child: Column(
              children: [
                FabBtn(
                  icon: Icons.light_mode,
                  color: colors.onSurface,
                  onTap: () => setState(() => _tileUrl =
                      'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png'),
                ),
                const SizedBox(height: 8),
                FabBtn(
                  icon: Icons.dark_mode,
                  color: colors.onSurface,
                  onTap: () => setState(() => _tileUrl =
                      'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png'),
                ),
                const SizedBox(height: 8),
                BlocBuilder<DriverStatusCubit, DriverStatusState>(
                  builder: (context, state) => FabBtn(
                    icon: Icons.my_location_rounded,
                    color: colors.onSurface,
                    onTap: () {
                      if (state is DriverStatusOnline) {
                        _mapCtrl.move(LatLng(state.lat, state.lng), 16);
                      }
                    },
                  ),
                ),
                const SizedBox(height: 8),
                FabBtn(
                  icon: Icons.attach_money_rounded,
                  color: const Color(0xFF00C9A7),
                  onTap: () => Navigator.pushNamed(context, EarningsPage.id),
                ),
                if (_route != null) ...[
                  const SizedBox(height: 8),
                  FabBtn(
                    icon: Icons.clear_rounded,
                    color: Colors.red,
                    onTap: _clearRoute,
                  ),
                ],
              ],
            ),
          ),

          // ══ ROUTE LOADING INDICATOR ════════════════════════════════════════
          if (_loadingRoute)
            Positioned(
              bottom: bottomPad + 200,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.1), blurRadius: 12),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Color(0xFF4285F4),
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Calculating route...',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // ══ ACTIVE TRIP SHEET (shown when trip is active) ══════════════════
          BlocConsumer<ActiveTripCubit, ActiveTripState>(
            listener: (context, state) {
              if (state is ActiveTripCompleted) {
                _clearRoute();
                context.read<EarningsCubit>().load();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Trip completed! +EGP ${state.earnedAmount.toStringAsFixed(0)}',
                      style: TextStyle(
                        color: colors.onSurface,
                        fontFamily: fontFamily,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    backgroundColor: const Color(0xFF00C9A7),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                );
              } else if (state is ActiveTripCancelled) {
                _clearRoute();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Trip cancelled',
                      style: TextStyle(
                          color: colors.onSurface, fontFamily: fontFamily),
                    ),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                // Resume listening for new requests
                final statusState = context.read<DriverStatusCubit>().state;
                if (statusState is DriverStatusOnline) {
                  context.read<RideRequestsCubit>().startListening(
                        driverLocation:
                            LatLng(statusState.lat, statusState.lng),
                      );
                }
              } else if (state is ActiveTripActive) {
                // Update route when trip status changes to inProgress
                // → route to destination instead of pickup
                final trip = state.trip;
                final statusState = context.read<DriverStatusCubit>().state;
                if (trip.status == 'inProgress' &&
                    statusState is DriverStatusOnline) {
                  _drawRoute(
                    LatLng(statusState.lat, statusState.lng),
                    trip.destination,
                  );
                }
              } else if (state is ActiveTripError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            builder: (context, tripState) {
              if (tripState is ActiveTripActive) {
                return Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: ActiveTripSheet(trip: tripState.trip),
                );
              }

              if (tripState is ActiveTripAccepting) {
                return Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _AcceptingLoader(),
                );
              }

              // ── IDLE: show status toggle + request list ─────────────────
              return Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Request cards (shown only when online)
                    BlocBuilder<DriverStatusCubit, DriverStatusState>(
                      builder: (context, statusState) {
                        if (statusState is! DriverStatusOnline) {
                          return const SizedBox.shrink();
                        }
                        return BlocBuilder<RideRequestsCubit,
                            RideRequestsState>(
                          builder: (context, reqState) {
                            if (reqState is RideRequestsLoaded) {
                              final visible = reqState.requests
                                  .where((r) => !_dismissedIds.contains(r.id))
                                  .toList();

                              if (visible.isEmpty) {
                                return const SizedBox.shrink();
                              }

                              return SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.48,
                                child: ListView.builder(
                                  padding:
                                      const EdgeInsets.only(bottom: 8, top: 4),
                                  itemCount: visible.length,
                                  itemBuilder: (_, i) {
                                    final req = visible[i];
                                    return RideRequestCard(
                                      request: req,
                                      onAccept: () => _acceptRequest(req),
                                      onDecline: () => setState(
                                          () => _dismissedIds.add(req.id)),
                                    );
                                  },
                                ),
                              );
                            }
                            if (reqState is RideRequestsEmpty) {
                              return _NoRequestsBanner();
                            }
                            return const SizedBox.shrink();
                          },
                        );
                      },
                    ),

                    // Status toggle
                    const DriverStatusToggle(),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ── Top bar ───────────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  final DriverModel? driverModel;
  const _TopBar({this.driverModel});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return BlocBuilder<DriverStatusCubit, DriverStatusState>(
      builder: (context, state) {
        final isOnline = state is DriverStatusOnline;
        final isLoading = state is DriverStatusLoading;

        return GlassCont(
          width: 280,
          border:
              Border.all(color: colors.onSurface.withOpacity(0.3), width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              // Status dot
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isLoading
                      ? Colors.orange
                      : isOnline
                          ? const Color(0xFF00C9A7)
                          : Colors.grey.withOpacity(0.6),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  isLoading
                      ? 'Connecting...'
                      : isOnline
                          ? 'Online • Looking for rides'
                          : 'Offline',
                  style: TextStyle(
                    color: colors.onSurface,
                    fontFamily: fontFamily,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              // Driver name chip
              if (driverModel != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: colors.surface.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: colors.onSurface.withOpacity(0.2), width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.directions_car_rounded,
                          size: 13, color: colors.onSurface.withOpacity(0.7)),
                      const SizedBox(width: 5),
                      Text(
                        driverModel!.vehiclePlate,
                        style: TextStyle(
                          color: colors.onSurface,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          fontFamily: fontFamily,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

// ── No requests banner ────────────────────────────────────────────────────────
class _NoRequestsBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.onSurface.withOpacity(0.15), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_rounded,
              color: colors.onSurface.withOpacity(0.4), size: 18),
          const SizedBox(width: 10),
          Text(
            'No ride requests nearby',
            style: TextStyle(
              color: colors.onSurface.withOpacity(0.5),
              fontFamily: fontFamily,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Accepting loader ──────────────────────────────────────────────────────────
class _AcceptingLoader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return GlassCont(
      top: BorderSide(color: colors.onSurface.withOpacity(0.3), width: 1),
      left: BorderSide(color: colors.onSurface.withOpacity(0.3), width: 1),
      right: BorderSide(color: colors.onSurface.withOpacity(0.3), width: 1),
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(
            color: Color(0xFF00C9A7),
            strokeWidth: 3,
          ),
          const SizedBox(height: 14),
          Text(
            'Accepting ride...',
            style: TextStyle(
              color: colors.onSurface,
              fontFamily: fontFamily,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
