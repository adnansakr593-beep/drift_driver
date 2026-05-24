// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';

class DestinationMarker extends StatelessWidget {
  const DestinationMarker({super.key});

  @override
  Widget build(BuildContext context) {
    return const Icon(
      Icons.location_on_rounded,
      color: Color(0xFFEA4335),
      size: 40,
      shadows: [
        Shadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 2)),
      ],
    );
  }
}

class UserLocationMarker extends StatefulWidget {
  const UserLocationMarker({super.key});
  @override
  State<UserLocationMarker> createState() => _UserLocationMarkerState();
}

class _UserLocationMarkerState extends State<UserLocationMarker>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _anim = Tween(begin: 0.3, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, __) => Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 40 * _anim.value,
            height: 40 * _anim.value,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.surface,
            ),
          ),
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF4285F4),
              border: Border.all(color: colors.onSurface, width: 3),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4285F4).withOpacity(0.4),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Driver marker — uses a car icon with pulse animation
class DriverMarker extends StatefulWidget {
  const DriverMarker({super.key});
  @override
  State<DriverMarker> createState() => _DriverMarkerState();
}

class _DriverMarkerState extends State<DriverMarker>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _anim = Tween(begin: 0.4, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 44 * _anim.value,
            height: 44 * _anim.value,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF00C9A7).withOpacity(0.15 * _anim.value),
            ),
          ),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF00C9A7),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00C9A7).withOpacity(0.5),
                  blurRadius: 8,
                ),
              ],
            ),
            child: const Icon(
              Icons.directions_car_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}
