import 'package:flutter/material.dart';
import 'app_color.dart';
import 'app_text_style.dart';

class AppTheme {
  //  Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      scaffoldBackgroundColor: AppColors.lightBackground,

      colorScheme: const ColorScheme.light(
        primary: AppColors.lightPrimary,
        background: AppColors.lightBackground,
        surface: AppColors.lightSurface,
        onPrimary: Colors.white,
        onBackground: AppColors.lightText,
        onSurface: Colors.black,
        error: AppColors.error,
      ),

      textTheme: TextTheme(
        //  العناوين الكبيرة (على الخلفية الزرقاء) - بيضاء
        displayLarge: AppTextStyles.displayLarge.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: AppTextStyles.displayMedium.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        displaySmall: AppTextStyles.displaySmall.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),

        headlineLarge: AppTextStyles.headlineLarge.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: AppTextStyles.headlineMedium.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        headlineSmall: AppTextStyles.headlineSmall.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),

        //  عناوين المحتوى (داخل الكروت البيضاء) - سوداء
        titleLarge: AppTextStyles.titleLarge.copyWith(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
        titleMedium: AppTextStyles.titleMedium.copyWith(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
        titleSmall: AppTextStyles.titleSmall.copyWith(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),

        // النصوص العادية (داخل الكروت البيضاء) - سوداء
        bodyLarge: AppTextStyles.bodyLarge.copyWith(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
        bodyMedium: AppTextStyles.bodyMedium.copyWith(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
        bodySmall: AppTextStyles.bodySmall.copyWith(
          color: AppColors.lightIcon,
          fontWeight: FontWeight.bold,
        ),

        labelLarge: AppTextStyles.labelLarge.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        labelMedium: AppTextStyles.labelMedium.copyWith(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
        labelSmall: AppTextStyles.labelSmall.copyWith(
          color: AppColors.lightIcon,
          fontWeight: FontWeight.bold,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: Colors.white),
      ),
      //  AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.lightPrimary,
        foregroundColor: Colors.white,
        elevation: 2,
        titleTextStyle: AppTextStyles.titleLarge.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),

      iconTheme: const IconThemeData(
        color: Color.fromARGB(255, 71, 157, 168),
        size: 24,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.lightSurface,
          foregroundColor: Colors.black,
          textStyle: AppTextStyles.labelLarge.copyWith(
            fontWeight: FontWeight.bold,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: const BorderSide(
            color: Color.fromARGB(255, 198, 198, 209),
            width: 1,
          ),
        ),
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.lightPrimary,
        foregroundColor: Colors.white,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: AppColors.lightPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: Colors.grey,
          fontWeight: FontWeight.bold,
        ),
        labelStyle: AppTextStyles.labelMedium.copyWith(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
        prefixIconColor: const Color.fromARGB(255, 79, 148, 165),
      ),

      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.resolveWith(
          (states) =>
              states.contains(MaterialState.selected)
                  ? AppColors.lightPrimary
                  : AppColors.lightIcon,
        ),
      ),

      cardTheme: const CardThemeData(
        color: AppColors.lightSurface,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: Colors.green,
        contentTextStyle: AppTextStyles.bodyMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
        elevation: 4,
      ),
    );
  }

  //  Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      scaffoldBackgroundColor: AppColors.darkBackground,

      colorScheme: const ColorScheme.dark(
        primary: AppColors.darkPrimary,
        background: AppColors.darkBackground,
        surface: AppColors.darkSurface,
        onPrimary: Colors.black,
        onBackground: AppColors.darkText,
        onSurface: AppColors.darkText,
        error: AppColors.error,
      ),

      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayLarge.copyWith(
          color: AppColors.darkText,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: AppTextStyles.displayMedium.copyWith(
          color: AppColors.darkText,
          fontWeight: FontWeight.bold,
        ),
        displaySmall: AppTextStyles.displaySmall.copyWith(
          color: AppColors.darkText,
          fontWeight: FontWeight.bold,
        ),

        headlineLarge: AppTextStyles.headlineLarge.copyWith(
          color: AppColors.darkText,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: AppTextStyles.headlineMedium.copyWith(
          color: AppColors.darkText,
          fontWeight: FontWeight.bold,
        ),
        headlineSmall: AppTextStyles.headlineSmall.copyWith(
          color: AppColors.darkText,
          fontWeight: FontWeight.bold,
        ),

        titleLarge: AppTextStyles.titleLarge.copyWith(
          color: AppColors.darkText,
          fontWeight: FontWeight.bold,
        ),
        titleMedium: AppTextStyles.titleMedium.copyWith(
          color: AppColors.darkText,
          fontWeight: FontWeight.bold,
        ),
        titleSmall: AppTextStyles.titleSmall.copyWith(
          color: AppColors.darkText,
          fontWeight: FontWeight.bold,
        ),

        bodyLarge: AppTextStyles.bodyLarge.copyWith(
          color: AppColors.darkText,
          fontWeight: FontWeight.bold,
        ),
        bodyMedium: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.darkText,
          fontWeight: FontWeight.bold,
        ),
        bodySmall: AppTextStyles.bodySmall.copyWith(
          color: AppColors.darkIcon,
          fontWeight: FontWeight.bold,
        ),

        labelLarge: AppTextStyles.labelLarge.copyWith(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.darkText),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.darkText,
        titleTextStyle: AppTextStyles.titleLarge.copyWith(
          color: AppColors.darkText,
          fontWeight: FontWeight.bold,
        ),
      ),

      iconTheme: const IconThemeData(color: AppColors.darkIcon, size: 24),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkPrimary,
          foregroundColor: Colors.black,
          textStyle: AppTextStyles.labelLarge.copyWith(
            fontWeight: FontWeight.bold,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurface,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: AppColors.darkPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: Colors.grey,
          fontWeight: FontWeight.bold,
        ),
        labelStyle: AppTextStyles.labelMedium.copyWith(
          color: AppColors.darkText,
          fontWeight: FontWeight.bold,
        ),
        prefixIconColor: AppColors.darkIcon,
      ),

      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.resolveWith(
          (states) =>
              states.contains(MaterialState.selected)
                  ? AppColors.darkPrimary
                  : AppColors.darkIcon,
        ),
      ),

      cardTheme: const CardThemeData(
        color: AppColors.darkSurface,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: Colors.green,
        contentTextStyle: AppTextStyles.bodyMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
        elevation: 4,
      ),
    );
  }
}
