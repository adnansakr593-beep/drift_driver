// ignore_for_file: deprecated_member_use
import 'package:drift_driver/helper/const.dart';
import 'package:drift_driver/models/ride_request_model.dart';
import 'package:flutter/material.dart';

class RideRequestCard extends StatelessWidget {
  final RideRequestModel request;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const RideRequestCard({
    super.key,
    required this.request,
    required this.onAccept,
    required this.onDecline,
  });

  static const Map<String, _ModeStyle> _modeStyles = {
    'ride': _ModeStyle(
      icon: Icons.directions_car_rounded,
      label: 'Ride',
      color: Color(0xFF6C63FF),
    ),
    'cityToCity': _ModeStyle(
      icon: Icons.route_rounded,
      label: 'City to City',
      color: Color(0xFF00C9A7),
    ),
    'delivery': _ModeStyle(
      icon: Icons.delivery_dining_rounded,
      label: 'Delivery',
      color: Color(0xFFFF6B6B),
    ),
    'takeMeOut': _ModeStyle(
      icon: Icons.explore_rounded,
      label: 'Take Me Out',
      color: Color(0xFFFFBE0B),
    ),
  };

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final mode = _modeStyles[request.tripMode] ?? _modeStyles['ride']!;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.onSurface.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: colors.background.withOpacity(0.4),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header: user info + mode badge ──────────────────────────────
          Row(
            children: [
              // User avatar
              CircleAvatar(
                radius: 22,
                backgroundColor: colors.surface,
                backgroundImage: request.userPhoto != null
                    ? NetworkImage(request.userPhoto!)
                    : null,
                child: request.userPhoto == null
                    ? Icon(Icons.person_rounded,
                        color: colors.onSurface, size: 22)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.userName,
                      style: TextStyle(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        fontFamily: fontFamily,
                      ),
                    ),
                    Text(
                      _timeAgo(request.createdAt),
                      style: TextStyle(
                        color: colors.onSurface.withOpacity(0.4),
                        fontSize: 11,
                        fontFamily: fontFamily,
                      ),
                    ),
                  ],
                ),
              ),
              // Mode badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: mode.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                  border:
                      Border.all(color: mode.color.withOpacity(0.4), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(mode.icon, color: mode.color, size: 13),
                    const SizedBox(width: 4),
                    Text(
                      mode.label,
                      style: TextStyle(
                        color: mode.color,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        fontFamily: fontFamily,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ── Route info ───────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.surface.withOpacity(0.4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Column(
                  children: [
                    const Icon(Icons.radio_button_checked,
                        color: Color(0xFF4285F4), size: 14),
                    Container(
                      width: 1.5,
                      height: 20,
                      color: colors.onSurface.withOpacity(0.2),
                    ),
                    const Icon(Icons.location_on_rounded,
                        color: Color(0xFFEA4335), size: 14),
                  ],
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pickup location',
                        style: TextStyle(
                          color: colors.onSurface.withOpacity(0.4),
                          fontSize: 10,
                          fontFamily: fontFamily,
                        ),
                      ),
                      Text(
                        '${request.userLocation.latitude.toStringAsFixed(4)}, '
                        '${request.userLocation.longitude.toStringAsFixed(4)}',
                        style: TextStyle(
                          color: colors.onSurface,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          fontFamily: fontFamily,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Drop off',
                        style: TextStyle(
                          color: colors.onSurface.withOpacity(0.4),
                          fontSize: 10,
                          fontFamily: fontFamily,
                        ),
                      ),
                      Text(
                        request.destinationName,
                        style: TextStyle(
                          color: colors.onSurface,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          fontFamily: fontFamily,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── Trip stats ───────────────────────────────────────────────────
          Row(
            children: [
              _StatChip(
                icon: Icons.straighten_rounded,
                label: '${request.distanceKm.toStringAsFixed(1)} km',
                color: colors.onSurface,
              ),
              const SizedBox(width: 8),
              _StatChip(
                icon: Icons.timer_outlined,
                label: '${request.durationMin.toStringAsFixed(0)} min',
                color: colors.onSurface,
              ),
              const Spacer(),
              // Price
              Text(
                'EGP ${request.offeredPrice.toStringAsFixed(0)}',
                style: TextStyle(
                  color: mode.color,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  fontFamily: fontFamily,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ── Action buttons ───────────────────────────────────────────────
          Row(
            children: [
              // Decline
              Expanded(
                child: GestureDetector(
                  onTap: onDecline,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: Colors.red.withOpacity(0.3), width: 1),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.close_rounded,
                            color: Colors.redAccent, size: 18),
                        SizedBox(width: 6),
                        Text(
                          'Decline',
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            fontFamily: fontFamily,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Accept
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: onAccept,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF00C9A7),
                          const Color(0xFF00C9A7).withOpacity(0.75)
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00C9A7).withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_rounded,
                            color: Colors.white, size: 18),
                        SizedBox(width: 6),
                        Text(
                          'Accept',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            fontFamily: fontFamily,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    return '${diff.inHours}h ago';
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _StatChip(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colors.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color.withOpacity(0.6)),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color.withOpacity(0.8),
              fontSize: 11,
              fontWeight: FontWeight.w600,
              fontFamily: fontFamily,
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeStyle {
  final IconData icon;
  final String label;
  final Color color;
  const _ModeStyle(
      {required this.icon, required this.label, required this.color});
}
