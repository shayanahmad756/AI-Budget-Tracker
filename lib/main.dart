import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ai_budget_tracker/services/database_service.dart';
import 'package:ai_budget_tracker/providers/transaction_provider.dart';
import 'package:ai_budget_tracker/providers/theme_provider.dart';
import 'package:ai_budget_tracker/screens/splash_screen.dart';
import 'package:ai_budget_tracker/screens/home_screen.dart';
import 'package:ai_budget_tracker/utils/constants.dart';

/// Entry point of the AI Budget Tracker application.
///
/// Initialises the SQLite database before launching the widget tree.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseService.instance.database;
  runApp(const MyApp());
}

/// Root widget that configures theming and state management.
class MyApp extends StatelessWidget {
  /// Creates a [MyApp].
  const MyApp({super.key});

  /// Builds the light theme.
  static ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.cardBackground,
        foregroundColor: AppColors.textPrimary,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  /// Builds the dark theme.
  static ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: const Color(0xFF1A1A2E),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Color(0xFF16213E),
        foregroundColor: Color(0xFFE0E0E0),
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        color: const Color(0xFF16213E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<TransactionProvider>(
          create: (_) => TransactionProvider()..loadTransactions(),
        ),
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Budget Tracker',
            debugShowCheckedModeBanner: false,
            theme: _buildLightTheme(),
            darkTheme: _buildDarkTheme(),
            themeMode:
                themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const SplashScreen(),
            routes: {
              '/home': (context) => const HomeScreen(),
            },
          );
        },
      ),
    );
  }
}
