import 'package:flutter/material.dart';

/// Modern fintech-style colour palette with professional gradients.
///
/// Centralising colours here keeps the UI consistent and makes
/// theme changes a single-file edit.
class AppColors {
  AppColors._(); // prevent instantiation

  /// Primary brand colour — modern deep blue/purple.
  static const Color primary = Color(0xFF5B4E96);

  /// Primary dark variant for darker backgrounds.
  static const Color primaryDark = Color(0xFF4A3E7A);

  /// Primary light variant for highlights.
  static const Color primaryLight = Color(0xFF7B6FB1);

  /// Colour used to represent income amounts and indicators.
  static const Color income = Color(0xFF10B981);

  /// Colour used to represent expense amounts and indicators.
  static const Color expense = Color(0xFFEF4444);

  /// Overall app background — clean light.
  static const Color background = Color(0xFFFAFAFC);

  /// Card / surface background — white.
  static const Color cardBackground = Color(0xFFFFFFFF);

  /// Primary text colour — dark charcoal.
  static const Color textPrimary = Color(0xFF1F2937);

  /// Secondary / muted text colour — soft grey.
  static const Color textSecondary = Color(0xFF6B7280);

  /// Subtle border color.
  static const Color border = Color(0xFFE5E7EB);

  /// Accent color for highlights.
  static const Color accent = Color(0xFFF59E0B);
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

  /// Small border radius for buttons and chips.
  static const double smallBorderRadius = 8.0;
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
    'Food': Color(0xFFF87171),
    'Travel': Color(0xFF0EA5E9),
    'Bills': Color(0xFFFBBF24),
    'Shopping': Color(0xFFA78BFA),
    'Entertainment': Color(0xFFF472B6),
    'Health': Color(0xFF34D399),
    'Education': Color(0xFF60A5FA),
    'Other': Color(0xFF9CA3AF),
  };
}
