import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';
import 'theme/theme_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final themeProvider = ThemeProvider();
  runApp(TechSpecsApp(themeProvider: themeProvider));
}

class TechSpecsApp extends StatelessWidget {
  final ThemeProvider themeProvider;

  const TechSpecsApp({super.key, required this.themeProvider});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: themeProvider,
      builder: (context, _) {
        return MaterialApp(
          title: 'Laptop Database',
          debugShowCheckedModeBanner: false,
          themeMode: themeProvider.themeMode,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          home: HomeScreen(themeProvider: themeProvider),
        );
      },
    );
  }
}
