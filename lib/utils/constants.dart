import 'package:flutter/material.dart';

/// Fintech-style colour palette used throughout the application.
///
/// Centralising colours here keeps the UI consistent and makes
/// theme changes a single-file edit.
class AppColors {
  AppColors._(); // prevent instantiation

  /// Primary brand colour — dark teal.
  static const Color primary = Color(0xFF0D7377);

  /// Colour used to represent income amounts and indicators.
  static const Color income = Color(0xFF2ECC71);

  /// Colour used to represent expense amounts and indicators.
  static const Color expense = Color(0xFFE74C3C);

  /// Overall app background — light grey.
  static const Color background = Color(0xFFF5F6FA);

  /// Card / surface background — white.
  static const Color cardBackground = Color(0xFFFFFFFF);

  /// Primary text colour — near-black.
  static const Color textPrimary = Color(0xFF2D3436);

  /// Secondary / muted text colour — grey.
  static const Color textSecondary = Color(0xFF636E72);
}

/// Application-wide numeric constants (budgets, dimensions, radii).
class AppConstants {
  AppConstants._();

  /// Default monthly budget value in the user's currency.
  static const double defaultMonthlyBudget = 50000.0;

  /// Standard symmetric padding used in layouts.
  static const double defaultPadding = 16.0;

  /// Border radius applied to card widgets.
  static const double cardBorderRadius = 16.0;
}

/// Helpers for transaction categories — labels, icons, and pie-chart colours.
class CategoryHelper {
  CategoryHelper._();

  /// Ordered list of all supported spending categories.
  static const List<String> categories = [
    'Food',
    'Travel',
    'Bills',
    'Shopping',
    'Entertainment',
    'Health',
    'Education',
    'Other',
  ];

  /// Maps each category to a representative Material icon.
  static const Map<String, IconData> categoryIcons = {
    'Food': Icons.restaurant,
    'Travel': Icons.directions_car,
    'Bills': Icons.receipt_long,
    'Shopping': Icons.shopping_bag,
    'Entertainment': Icons.movie,
    'Health': Icons.favorite,
    'Education': Icons.school,
    'Other': Icons.category,
  };

  /// Maps each category to a distinct colour for charts and badges.
  static const Map<String, Color> categoryColors = {
    'Food': Color(0xFFFF6B6B),
    'Travel': Color(0xFF4ECDC4),
    'Bills': Color(0xFFFFE66D),
    'Shopping': Color(0xFFA29BFE),
    'Entertainment': Color(0xFFFF9FF3),
    'Health': Color(0xFF55E6C1),
    'Education': Color(0xFF48DBFB),
    'Other': Color(0xFFB8B8B8),
  };
}
