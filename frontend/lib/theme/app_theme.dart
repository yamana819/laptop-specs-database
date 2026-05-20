import 'dart:ui';
import 'package:flutter/material.dart';

class AppTheme {
  // Cyberpunk Neon Colors
  static const neonPink = Color(0xFFF92672);
  static const neonCyan = Color(0xFF00F0FF);
  static const sweetPurple = Color(0xFFB877DB);
  static const successColor = Color(0xFFC3E88D);
  static const errorColor = Color(0xFFFF5370);

  // Background Gradient Widget
  static Widget buildBackground(BuildContext context, {required Widget child}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [Color(0xFF09090E), Color(0xFF160B24), Color(0xFF05131F)]
              : const [Color(0xFFF4F2FF), Color(0xFFE6F7FF), Color(0xFFFFF0F5)],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: child,
    );
  }

  // Glassmorphism Container Helper
  static Widget glassContainer(
    BuildContext context, {
    required Widget child,
    double borderRadius = 12.0,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    bool isHovered = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Base colors
    final bgColor = isDark ? Colors.white.withValues(alpha: 0.03) : Colors.white.withValues(alpha: 0.6);
    final hoverBgColor = isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white.withValues(alpha: 0.8);
    final borderColor = isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05);
    final hoverBorderColor = isDark ? neonPink.withValues(alpha: 0.5) : neonCyan.withValues(alpha: 0.5);

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: padding,
          margin: margin,
          decoration: BoxDecoration(
            color: isHovered ? hoverBgColor : bgColor,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: isHovered ? hoverBorderColor : borderColor, width: 1.5),
            boxShadow: isHovered
                ? [
                    BoxShadow(
                      color: (isDark ? neonPink : neonCyan).withValues(alpha: 0.2),
                      blurRadius: 20,
                      spreadRadius: 2,
                    )
                  ]
                : [],
          ),
          child: child,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      scaffoldBackgroundColor: Colors.transparent, // Transparent to show gradient
      cardColor: Colors.transparent, // Handled by glass
      dividerColor: Colors.white.withValues(alpha: 0.1),
      hoverColor: Colors.transparent,
      colorScheme: ColorScheme.dark(
        primary: neonPink,
        secondary: neonCyan,
        tertiary: sweetPurple,
        surface: Colors.transparent,
        surfaceContainerHighest: Colors.white.withValues(alpha: 0.05),
        onSurface: Colors.white,
        onSurfaceVariant: const Color(0xFFA6ACCD),
        error: errorColor,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.black.withValues(alpha: 0.2),
        labelStyle: const TextStyle(color: Color(0xFFA6ACCD), fontSize: 13),
        hintStyle: const TextStyle(color: Color(0xFF676E95)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: neonCyan, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: neonPink,
          foregroundColor: Colors.white,
          elevation: 8,
          shadowColor: neonPink.withValues(alpha: 0.6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: neonCyan,
          side: const BorderSide(color: neonCyan),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      iconTheme: const IconThemeData(color: neonCyan),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
      scaffoldBackgroundColor: Colors.transparent,
      cardColor: Colors.transparent,
      dividerColor: Colors.black.withValues(alpha: 0.05),
      hoverColor: Colors.transparent,
      colorScheme: ColorScheme.light(
        primary: const Color(0xFFD81B60), // Deeper magenta
        secondary: const Color(0xFF00ACC1),
        tertiary: const Color(0xFF8E24AA),
        surface: Colors.transparent,
        surfaceContainerHighest: Colors.black.withValues(alpha: 0.03),
        onSurface: const Color(0xFF111111),
        onSurfaceVariant: const Color(0xFF555555),
        error: errorColor,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: Color(0xFF111111)),
        titleTextStyle: TextStyle(color: Color(0xFF111111), fontSize: 20, fontWeight: FontWeight.bold),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.5),
        labelStyle: const TextStyle(color: Color(0xFF555555), fontSize: 13),
        hintStyle: const TextStyle(color: Color(0xFF888888)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.05)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.05)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFD81B60), width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD81B60),
          foregroundColor: Colors.white,
          elevation: 8,
          shadowColor: const Color(0xFFD81B60).withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF00ACC1),
          side: const BorderSide(color: Color(0xFF00ACC1)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      iconTheme: const IconThemeData(color: Color(0xFF00ACC1)),
    );
  }
}
