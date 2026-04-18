import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ai_budget_tracker/services/database_service.dart';
import 'package:ai_budget_tracker/providers/transaction_provider.dart';
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

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<TransactionProvider>(
          create: (_) => TransactionProvider()..loadTransactions(),
        ),
      ],
      child: MaterialApp(
        title: 'AI Budget Tracker',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: AppColors.background,
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
          ),
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(AppConstants.cardBorderRadius),
            ),
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
