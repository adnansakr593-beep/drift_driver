// ignore_for_file: deprecated_member_use
import 'package:drift_driver/cubits/driver_status/driver_status_cubit.dart';
import 'package:drift_driver/cubits/driver_status/driver_status_state.dart';
import 'package:drift_driver/helper/const.dart';
import 'package:drift_driver/widgets/glass_cont.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DriverStatusToggle extends StatelessWidget {
  const DriverStatusToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return GlassCont(
      top: BorderSide(color: colors.onSurface.withOpacity(0.3), width: 1),
      left: BorderSide(color: colors.onSurface.withOpacity(0.3), width: 1),
      right: BorderSide(color: colors.onSurface.withOpacity(0.3), width: 1),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
      child: BlocConsumer<DriverStatusCubit, DriverStatusState>(
        listener: (context, state) {
          if (state is DriverStatusError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.message,
                  style: TextStyle(
                    color: colors.onSurface,
                    fontFamily: fontFamily,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          final isOnline = state is DriverStatusOnline;
          final isLoading = state is DriverStatusLoading;

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: colors.onSurface.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isOnline ? 'You are Online' : 'You are Offline',
                          style: TextStyle(
                            color: colors.onSurface,
                            fontFamily: fontFamily,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isOnline
                              ? 'Accepting ride requests nearby'
                              : 'Go online to start earning',
                          style: TextStyle(
                            color: colors.onSurface.withOpacity(0.5),
                            fontFamily: fontFamily,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Animated toggle
                  GestureDetector(
                    onTap: isLoading
                        ? null
                        : () =>
                            context.read<DriverStatusCubit>().toggleStatus(),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 72,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: isLoading
                            ? Colors.grey.withOpacity(0.3)
                            : isOnline
                                ? const Color(0xFF00C9A7).withOpacity(0.2)
                                : colors.surface,
                        border: Border.all(
                          color: isOnline
                              ? const Color(0xFF00C9A7)
                              : colors.onSurface.withOpacity(0.4),
                          width: 1.5,
                        ),
                      ),
                      child: isLoading
                          ? Center(
                              child: SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: colors.onSurface,
                                ),
                              ),
                            )
                          : AnimatedAlign(
                              duration: const Duration(milliseconds: 300),
                              alignment: isOnline
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 4),
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isOnline
                                      ? const Color(0xFF00C9A7)
                                      : colors.onSurface.withOpacity(0.4),
                                ),
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
