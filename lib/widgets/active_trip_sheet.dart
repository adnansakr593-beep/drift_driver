// ignore_for_file: unused_local_variable, deprecated_member_use
import 'package:drift_driver/cubits/active_trip/active_trip_cubit.dart';
import 'package:drift_driver/helper/const.dart';
import 'package:drift_driver/models/active_trip_model.dart';
import 'package:drift_driver/widgets/custom_button.dart';
import 'package:drift_driver/widgets/glass_cont.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ActiveTripSheet extends StatelessWidget {
  final ActiveTripModel trip;

  const ActiveTripSheet({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return GlassCont(
      top: BorderSide(color: colors.onSurface.withOpacity(0.3), width: 1),
      left: BorderSide(color: colors.onSurface.withOpacity(0.3), width: 1),
      right: BorderSide(color: colors.onSurface.withOpacity(0.3), width: 1),
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: colors.onSurface.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Status indicator
            _StatusBanner(status: trip.status),

            const SizedBox(height: 14),

            // User info row
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: colors.surface,
                  backgroundImage: trip.userPhoto != null
                      ? NetworkImage(trip.userPhoto!)
                      : null,
                  child: trip.userPhoto == null
                      ? Icon(Icons.person_rounded,
                          color: colors.onSurface, size: 24)
                      : null,
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
                          fontSize: 16,
                          fontFamily: fontFamily,
                        ),
                      ),
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
                    ],
                  ),
                ),
                Text(
                  'EGP ${trip.offeredPrice.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: Color(0xFF00C9A7),
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    fontFamily: fontFamily,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Action button based on status
            _ActionButton(trip: trip),

            const SizedBox(height: 8),

            // Cancel button (only when en-route or arrived)
            if (trip.status == 'driverEnRoute' || trip.status == 'arrived')
              SizedBox(
                width: double.infinity,
                child: GestureDetector(
                  onTap: () => _showCancelConfirm(context, colors),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: Colors.red.withOpacity(0.3), width: 1),
                    ),
                    child: const Center(
                      child: Text(
                        'Cancel Trip',
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          fontFamily: fontFamily,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showCancelConfirm(BuildContext context, ColorScheme colors) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          'Cancel trip?',
          style: TextStyle(
              color: colors.onSurface,
              fontFamily: fontFamily,
              fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to cancel this trip?',
          style: TextStyle(
              color: colors.onSurface.withOpacity(0.7), fontFamily: fontFamily),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('No',
                style: TextStyle(
                    color: colors.onSurface, fontFamily: fontFamily)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<ActiveTripCubit>().cancelTrip();
            },
            child: const Text('Yes, Cancel',
                style: TextStyle(
                    color: Colors.redAccent, fontFamily: fontFamily)),
          ),
        ],
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final String status;
  const _StatusBanner({required this.status});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final info = _statusInfo(status);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: info.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: info.color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(info.icon, color: info.color, size: 16),
          const SizedBox(width: 8),
          Text(
            info.label,
            style: TextStyle(
              color: info.color,
              fontWeight: FontWeight.w700,
              fontSize: 13,
              fontFamily: fontFamily,
            ),
          ),
        ],
      ),
    );
  }

  _StatusInfo _statusInfo(String status) {
    switch (status) {
      case 'driverEnRoute':
        return _StatusInfo(
          icon: Icons.directions_car_rounded,
          label: 'Heading to pickup',
          color: const Color(0xFF6C63FF),
        );
      case 'arrived':
        return _StatusInfo(
          icon: Icons.location_on_rounded,
          label: 'Arrived at pickup',
          color: const Color(0xFFFFBE0B),
        );
      case 'inProgress':
        return _StatusInfo(
          icon: Icons.play_circle_rounded,
          label: 'Trip in progress',
          color: const Color(0xFF00C9A7),
        );
      case 'completed':
        return _StatusInfo(
          icon: Icons.check_circle_rounded,
          label: 'Trip completed',
          color: const Color(0xFF00C9A7),
        );
      default:
        return _StatusInfo(
          icon: Icons.info_rounded,
          label: status,
          color: const Color(0xFF4285F4),
        );
    }
  }
}

class _StatusInfo {
  final IconData icon;
  final String label;
  final Color color;
  _StatusInfo(
      {required this.icon, required this.label, required this.color});
}

class _ActionButton extends StatelessWidget {
  final ActiveTripModel trip;
  const _ActionButton({required this.trip});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ActiveTripCubit>();

    switch (trip.status) {
      case 'driverEnRoute':
        return CustomButtom(
          backgroundColor: const Color(0xFFFFBE0B).withOpacity(0.15),
          borderColor: const Color(0xFFFFBE0B),
          text: "I've Arrived",
          textColor: const Color(0xFFFFBE0B),
          fontSize: 16,
          icon: const Icon(Icons.location_on_rounded,
              color: Color(0xFFFFBE0B), size: 20),
          onTap: () => cubit.markArrived(),
        );
      case 'arrived':
        return CustomButtom(
          backgroundColor: const Color(0xFF00C9A7).withOpacity(0.15),
          borderColor: const Color(0xFF00C9A7),
          text: 'Start Trip',
          textColor: const Color(0xFF00C9A7),
          fontSize: 16,
          icon: const Icon(Icons.play_arrow_rounded,
              color: Color(0xFF00C9A7), size: 22),
          onTap: () => cubit.startTrip(),
        );
      case 'inProgress':
        return CustomButtom(
          backgroundColor: const Color(0xFF6C63FF).withOpacity(0.15),
          borderColor: const Color(0xFF6C63FF),
          text: 'Complete Trip',
          textColor: const Color(0xFF6C63FF),
          fontSize: 16,
          icon: const Icon(Icons.flag_rounded,
              color: Color(0xFF6C63FF), size: 20),
          onTap: () => cubit.completeTrip(earnedAmount: trip.offeredPrice),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
