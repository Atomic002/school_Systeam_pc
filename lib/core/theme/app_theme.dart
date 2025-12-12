// lib/core/theme/app_theme.dart
// IZOH: Bu fayl ilovaning vizual ko'rinishini (tema) belgilaydi.
// Ranglar, shriftlar, button stillari va boshqa UI elementlar uchun.

import 'package:flutter/material.dart';
import '../../config/constants.dart';

class AppTheme {
  // Yorug' tema (Light Theme)
  static ThemeData get lightTheme {
    return ThemeData(
      // Asosiy rang
      primaryColor: AppConstants.primaryColor,

      // Material 3 dizayn tili
      useMaterial3: true,

      // Rang sxemasi
      colorScheme: ColorScheme.light(
        primary: AppConstants.primaryColor,
        secondary: AppConstants.secondaryColor,
        error: AppConstants.errorColor,
        background: AppConstants.backgroundLight,
        surface: AppConstants.cardColor,
      ),

      // Scaffold fon rangi
      scaffoldBackgroundColor: AppConstants.backgroundLight,

      // AppBar teması
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: AppConstants.textPrimaryColor,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppConstants.textPrimaryColor,
          fontSize: AppConstants.fontSizeXXLarge,
          fontWeight: FontWeight.bold,
        ),
      ),

      // Card teması
      cardTheme: CardThemeData(),

      // Button temalari
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.primaryColor,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(
            horizontal: AppConstants.paddingLarge,
            vertical: AppConstants.paddingMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppConstants.borderRadiusMedium,
            ),
          ),
          elevation: 2,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppConstants.primaryColor,
          padding: EdgeInsets.symmetric(
            horizontal: AppConstants.paddingLarge,
            vertical: AppConstants.paddingMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppConstants.borderRadiusMedium,
            ),
          ),
          side: BorderSide(color: AppConstants.primaryColor),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppConstants.primaryColor,
          padding: EdgeInsets.symmetric(
            horizontal: AppConstants.paddingMedium,
            vertical: AppConstants.paddingSmall,
          ),
        ),
      ),

      // Input field teması
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppConstants.paddingMedium,
          vertical: AppConstants.paddingMedium,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          borderSide: BorderSide(color: AppConstants.primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          borderSide: BorderSide(color: AppConstants.errorColor),
        ),
        labelStyle: TextStyle(
          color: AppConstants.textSecondaryColor,
          fontSize: AppConstants.fontSizeMedium,
        ),
      ),

      // Text temalari
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: AppConstants.fontSizeTitle,
          fontWeight: FontWeight.bold,
          color: AppConstants.textPrimaryColor,
        ),
        displayMedium: TextStyle(
          fontSize: AppConstants.fontSizeXXLarge,
          fontWeight: FontWeight.bold,
          color: AppConstants.textPrimaryColor,
        ),
        bodyLarge: TextStyle(
          fontSize: AppConstants.fontSizeLarge,
          color: AppConstants.textPrimaryColor,
        ),
        bodyMedium: TextStyle(
          fontSize: AppConstants.fontSizeMedium,
          color: AppConstants.textSecondaryColor,
        ),
        bodySmall: TextStyle(
          fontSize: AppConstants.fontSizeSmall,
          color: AppConstants.textLightColor,
        ),
      ),

      // Icon tema
      iconTheme: IconThemeData(
        color: AppConstants.primaryColor,
        size: AppConstants.iconSizeMedium,
      ),
    );
  }

  // Qorong'i tema (Dark Theme)
  static ThemeData get darkTheme {
    return ThemeData(
      primaryColor: AppConstants.primaryColor,
      useMaterial3: true,
      colorScheme: ColorScheme.dark(
        primary: AppConstants.primaryColor,
        secondary: AppConstants.secondaryColor,
        error: AppConstants.errorColor,
        background: AppConstants.backgroundDark,
        surface: Color(0xFF374151),
      ),
      scaffoldBackgroundColor: AppConstants.backgroundDark,

      appBarTheme: AppBarTheme(
        backgroundColor: Color(0xFF374151),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: AppConstants.fontSizeXXLarge,
          fontWeight: FontWeight.bold,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Color(0xFF374151),
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppConstants.paddingMedium,
          vertical: AppConstants.paddingMedium,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          borderSide: BorderSide(color: Colors.grey.shade700),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          borderSide: BorderSide(color: Colors.grey.shade700),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          borderSide: BorderSide(color: AppConstants.primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          borderSide: BorderSide(color: AppConstants.errorColor),
        ),
        labelStyle: TextStyle(
          color: Colors.grey.shade400,
          fontSize: AppConstants.fontSizeMedium,
        ),
      ),
    );
  }
}
