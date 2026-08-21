import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'SIK';
  static const String appSubtitle = 'HOTEL / RESTAURANT';

  // Settings keys (stored in the local `settings` table)
  static const String keyAdminPasswordHash = 'admin_password_hash';
  static const String keyAdminUsername = 'admin_username';
  static const String keyNextBillNumber = 'next_bill_number';
  static const String keyShopName = 'shop_name';
  static const String keyPrinterWidth = 'printer_width_mm'; // 58 or 80

  static const String defaultUsername = 'admin';
  static const String defaultPassword = 'admin123';

  static const String billPrefix = 'SIK-';
  static const int billNumberPadding = 6;
}

class AppColors {
  static const Color primary = Color(0xFF1B5E20); // deep green, hotel/food feel
  static const Color primaryLight = Color(0xFF4C8C4A);
  static const Color accent = Color(0xFFEF6C00); // warm orange
  static const Color background = Color(0xFFF5F5F0);
  static const Color danger = Color(0xFFC62828);
  static const Color cardBorder = Color(0xFFE0E0E0);
}

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.cardBorder),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      cardTheme: CardThemeData(
        elevation: 1.5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      ),
      fontFamily: 'Roboto',
    );
  }
}
