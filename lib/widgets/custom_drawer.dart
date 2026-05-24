import 'package:drift_driver/cubits/theme_cubit/theme_cubit.dart';
import 'package:drift_driver/cubits/theme_cubit/theme_state.dart';
import 'package:drift_driver/pages/earnings_page.dart';
import 'package:drift_driver/widgets/confirme_logout.dart';
import 'package:drift_driver/widgets/custom_switch.dart';
import 'package:drift_driver/widgets/drawer_lists.dart';
import 'package:drift_driver/widgets/glass_cont.dart';
import 'package:drift_driver/widgets/show_dialog.dart';
import 'package:drift_driver/widgets/show_user_info.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CustomDrawer extends StatelessWidget {
  CustomDrawer({super.key});

  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return GlassCont(
      top: BorderSide(color: colors.onSurface.withOpacity(0.3), width: 1),
      bottom: BorderSide(color: colors.onSurface.withOpacity(0.3), width: 1),
      left: BorderSide(color: colors.onSurface.withOpacity(0.3), width: 1),
      padding: const EdgeInsets.only(left: 55, top: 31, bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // ── User Info ──────────────────────────────────────────
          const ShowUserInfo(),

          // ── Theme Toggle ───────────────────────────────────────
          BlocBuilder<ThemeCubit, ThemeState>(
            builder: (context, themeState) {
              final isDark = themeState.themeMode == ThemeMode.dark;
              return CustomSwitch(
                title: isDark ? 'Dark Mode' : 'Light Mode',
                child: Switch(
                  value: isDark,
                  onChanged: (value) async {
                    await context.read<ThemeCubit>().toggleTheme(value);
                  },
                  activeColor: colors.background,
                ),
              );
            },
          ),

          // ── Notifications ──────────────────────────────────────
          DrawerLists(
            title: 'History',
            width: 220,
            icon: Icon(Icons.history,
                color: colors.onSurface.withOpacity(0.8), size: 30),
            onTap: () {
              Navigator.pushNamed(context, EarningsPage.id);
            },
          ),

          // ── About ──────────────────────────────────────────────
          DrawerLists(
            title: 'About',
            width: 220,
            icon: Icon(
              Icons.info_outline_rounded,
              color: colors.onSurface.withOpacity(0.8),
              size: 30,
            ),
            onTap: () {
              customDialog(context, colors);
            },
          ),

          // ── Log Out ────────────────────────────────────────────
          DrawerLists(
            width: 220,
            title: 'Log Out',
            onTap: () => confirmeLogOut(context, colors),
            icon: Icon(
              Icons.logout_rounded,
              color: colors.onSurface.withOpacity(0.8),
              size: 30,
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
