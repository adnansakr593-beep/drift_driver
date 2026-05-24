import 'package:drift_driver/cubits/theme_cubit/theme_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(ThemeState(ThemeMode.system)) {
    loadTheme();
  }

  Future<void> loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isDark = prefs.getBool('isDarkMode');
      if (isDark == null) {
        emit(ThemeState(ThemeMode.system));
      } else {
        emit(ThemeState(isDark ? ThemeMode.dark : ThemeMode.light));
      }
    } catch (_) {
      emit(ThemeState(ThemeMode.system));
    }
  }

  Future<void> toggleTheme(bool isDark) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isDarkMode', isDark);
      emit(ThemeState(isDark ? ThemeMode.dark : ThemeMode.light));
    } catch (_) {}
  }
}
