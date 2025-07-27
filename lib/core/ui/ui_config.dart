import 'package:flutter/material.dart';
import 'app_colors.dart';

class UiConfig {
  UiConfig._();

  static String title = 'Boost Sys Weblurk';

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        fontFamily: 'Ibrand',
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontFamily: 'Ibrand'),
          displayMedium: TextStyle(fontFamily: 'Ibrand'),
          displaySmall: TextStyle(fontFamily: 'Ibrand'),
          headlineLarge: TextStyle(fontFamily: 'Ibrand'),
          headlineMedium: TextStyle(fontFamily: 'Ibrand'),
          headlineSmall: TextStyle(fontFamily: 'Ibrand'),
          titleLarge: TextStyle(fontFamily: 'Ibrand'),
          titleMedium: TextStyle(fontFamily: 'Ibrand'),
          titleSmall: TextStyle(fontFamily: 'Ibrand'),
          bodyLarge: TextStyle(fontFamily: 'Ibrand'),
          bodyMedium: TextStyle(fontFamily: 'Ibrand'),
          bodySmall: TextStyle(fontFamily: 'Ibrand'),
          labelLarge: TextStyle(fontFamily: 'Ibrand'),
          labelMedium: TextStyle(fontFamily: 'Ibrand'),
          labelSmall: TextStyle(fontFamily: 'Ibrand'),
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          elevation: 4,
        ),
        tabBarTheme: TabBarThemeData(
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withValues(alpha: 0.7),
        ),
      );

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        fontFamily: 'Ibrand',
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.dark,
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontFamily: 'Ibrand'),
          displayMedium: TextStyle(fontFamily: 'Ibrand'),
          displaySmall: TextStyle(fontFamily: 'Ibrand'),
          headlineLarge: TextStyle(fontFamily: 'Ibrand'),
          headlineMedium: TextStyle(fontFamily: 'Ibrand'),
          headlineSmall: TextStyle(fontFamily: 'Ibrand'),
          titleLarge: TextStyle(fontFamily: 'Ibrand'),
          titleMedium: TextStyle(fontFamily: 'Ibrand'),
          titleSmall: TextStyle(fontFamily: 'Ibrand'),
          bodyLarge: TextStyle(fontFamily: 'Ibrand'),
          bodyMedium: TextStyle(fontFamily: 'Ibrand'),
          bodySmall: TextStyle(fontFamily: 'Ibrand'),
          labelLarge: TextStyle(fontFamily: 'Ibrand'),
          labelMedium: TextStyle(fontFamily: 'Ibrand'),
          labelSmall: TextStyle(fontFamily: 'Ibrand'),
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          elevation: 4,
        ),
        tabBarTheme: TabBarThemeData(
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withValues(alpha: 0.7),
        ),
      );

  static ThemeData get theme => lightTheme;
}
