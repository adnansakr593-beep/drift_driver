// ignore_for_file: deprecated_member_use
import 'package:drift_driver/cubits/earnings/earnings_cubit.dart';
import 'package:drift_driver/cubits/earnings/earnings_state.dart';
import 'package:drift_driver/helper/const.dart';
import 'package:drift_driver/models/active_trip_model.dart';
import 'package:drift_driver/widgets/glass_cont.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EarningsPage extends StatefulWidget {
  const EarningsPage({super.key});
  static String id = 'earnings_page';

  @override
  State<EarningsPage> createState() => _EarningsPageState();
}

class _EarningsPageState extends State<EarningsPage> {
  @override
  void initState() {
    super.initState();
    context.read<EarningsCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colors.surface.withOpacity(0.7),
                colors.background,
                colors.surface.withOpacity(0.7),
                colors.background,
              ],
            ),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: BlocBuilder<EarningsCubit, EarningsState>(
            builder: (context, state) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: Column(
                  children: [
                    // ── Header ────────────────────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      child: GlassCont(
                        height: 280,
                        bottom: BorderSide(
                            color: colors.onBackground.withOpacity(0.4),
                            width: 1.5),
                        right: BorderSide(
                            color: colors.onBackground.withOpacity(0.4),
                            width: 1.5),
                        left: BorderSide(
                            color: colors.onBackground.withOpacity(0.4),
                            width: 1.5),
                        child: SafeArea(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: Icon(Icons.arrow_back_ios_new,
                                    size: 30, color: colors.onSurface),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Text(
                                  'Earnings',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontFamily: fontFamily,
                                    color: colors.onSurface,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),

                              // Stats row
                              if (state is EarningsLoaded) ...[
                                const SizedBox(height: 10),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Row(
                                    children: [
                                      _StatCard(
                                        label: 'Total Earned',
                                        value:
                                            'EGP ${state.driver.earnings.toStringAsFixed(0)}',
                                        icon: Icons.attach_money_rounded,
                                        color: const Color(0xFF00C9A7),
                                      ),
                                      const SizedBox(width: 10),
                                      _StatCard(
                                        label: 'Total Trips',
                                        value: '${state.driver.totalTrips}',
                                        icon: Icons.route_rounded,
                                        color: const Color(0xFF6C63FF),
                                      ),
                                      const SizedBox(width: 10),
                                      _StatCard(
                                        label: 'Rating',
                                        value:
                                            '${state.driver.rating.toStringAsFixed(1)} ⭐',
                                        icon: Icons.star_rounded,
                                        color: const Color(0xFFFFBE0B),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ── Trip history ──────────────────────────────────────────
                    Expanded(
                      child: () {
                        if (state is EarningsLoading) {
                          return Center(
                            child: CircularProgressIndicator(
                                color: colors.primary),
                          );
                        }
                        if (state is EarningsLoaded) {
                          if (state.completedTrips.isEmpty) {
                            return _EmptyTrips();
                          }
                          return ListView.builder(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 4),
                            itemCount: state.completedTrips.length,
                            itemBuilder: (_, i) =>
                                _TripHistoryCard(trip: state.completedTrips[i]),
                          );
                        }
                        if (state is EarningsError) {
                          return Center(
                            child: Text(
                              state.message,
                              style: TextStyle(color: colors.onSurface),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      }(),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── Stat card ─────────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: colors.onSurface,
                fontWeight: FontWeight.w800,
                fontSize: 14,
                fontFamily: fontFamily,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: colors.onSurface.withOpacity(0.4),
                fontSize: 10,
                fontFamily: fontFamily,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Trip history card ─────────────────────────────────────────────────────────
class _TripHistoryCard extends StatelessWidget {
  final ActiveTripModel trip;
  const _TripHistoryCard({required this.trip});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final completedAt = trip.completedAt;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.onSurface.withOpacity(0.15), width: 1),
      ),
      child: Row(
        children: [
          // Mode icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF00C9A7).withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_rounded,
                color: Color(0xFF00C9A7), size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trip.userName,
                  style: TextStyle(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    fontFamily: fontFamily,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  trip.destinationName,
                  style: TextStyle(
                    color: colors.onSurface.withOpacity(0.5),
                    fontSize: 12,
                    fontFamily: fontFamily,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (completedAt != null)
                  Text(
                    _formatDate(completedAt),
                    style: TextStyle(
                      color: colors.onSurface.withOpacity(0.35),
                      fontSize: 10,
                      fontFamily: fontFamily,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            '+EGP ${trip.offeredPrice.toStringAsFixed(0)}',
            style: const TextStyle(
              color: Color(0xFF00C9A7),
              fontWeight: FontWeight.w800,
              fontSize: 16,
              fontFamily: fontFamily,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────
class _EmptyTrips extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.route_rounded,
              size: 70, color: colors.onSurface.withOpacity(0.2)),
          const SizedBox(height: 16),
          Text(
            'No completed trips yet',
            style: TextStyle(
              color: colors.onSurface.withOpacity(0.5),
              fontFamily: fontFamily,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Go online to start accepting rides',
            style: TextStyle(
              color: colors.onSurface.withOpacity(0.35),
              fontFamily: fontFamily,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
