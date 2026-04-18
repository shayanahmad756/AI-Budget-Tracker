import 'package:ai_budget_tracker/models/transaction_model.dart';

/// Lightweight, rule-based "AI" service that provides categorisation,
/// spending insights, and a financial health score without requiring
/// any external API or ML model.
///
/// All methods are static so callers can use them without instantiation.
class AIService {
  AIService._();

  // ─── Keyword → Category mapping tables ───────────────────────────

  static const Map<String, List<String>> _categoryKeywords = {
    'Food': [
      'food', 'biryani', 'restaurant', 'lunch', 'dinner', 'breakfast', 'meal',
    ],
    'Travel': [
      'uber', 'petrol', 'fuel', 'taxi', 'bus', 'train', 'flight',
    ],
    'Bills': [
      'rent', 'bill', 'electricity', 'water', 'internet', 'phone',
    ],
    'Shopping': [
      'shopping', 'amazon', 'flipkart', 'clothes', 'shoes',
    ],
    'Entertainment': [
      'movie', 'netflix', 'game', 'concert',
    ],
    'Health': [
      'doctor', 'medicine', 'hospital', 'gym',
    ],
    'Education': [
      'course', 'book', 'school', 'college', 'tuition',
    ],
  };

  /// Determines the most likely spending category for [text] using
  /// simple keyword matching.
  ///
  /// The input is lowercased and checked against known keyword lists.
  /// Returns `"Other"` when no keywords match.
  static String categorizeExpense(String text) {
    final lower = text.toLowerCase();

    for (final entry in _categoryKeywords.entries) {
      for (final keyword in entry.value) {
        if (lower.contains(keyword)) {
          return entry.key;
        }
      }
    }

    return 'Other';
  }

  /// Analyses [transactions] and returns a list of human-readable insight
  /// strings (typically 2–3 items).
  ///
  /// Insights include:
  /// * Highest-spending category
  /// * 7-day transaction-count trend (rising / falling / steady)
  /// * Warning when expenses exceed income
  static List<String> generateInsights(List<TransactionModel> transactions) {
    if (transactions.isEmpty) {
      return ['Add some transactions to see AI insights!'];
    }

    final insights = <String>[];

    // --- Calculate totals by category (expenses only) ---
    final categoryTotals = <String, double>{};
    double totalExpenses = 0;
    double totalIncome = 0;

    for (final t in transactions) {
      if (t.type == 'expense') {
        categoryTotals[t.category] =
            (categoryTotals[t.category] ?? 0) + t.amount;
        totalExpenses += t.amount;
      } else {
        totalIncome += t.amount;
      }
    }

    // --- Highest spending category ---
    if (categoryTotals.isNotEmpty) {
      final highest = categoryTotals.entries
          .reduce((a, b) => a.value >= b.value ? a : b);
      insights.add(
        'You spent the most on ${highest.key} this period',
      );
    }

    // --- 7-day trend comparison ---
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));
    final fourteenDaysAgo = now.subtract(const Duration(days: 14));

    final recentCount = transactions
        .where((t) => t.date.isAfter(sevenDaysAgo))
        .length;
    final previousCount = transactions
        .where((t) =>
            t.date.isAfter(fourteenDaysAgo) &&
            t.date.isBefore(sevenDaysAgo))
        .length;

    if (recentCount > previousCount) {
      insights.add(
        'Your transaction activity is rising — $recentCount transactions in the last 7 days vs $previousCount before that.',
      );
    } else if (recentCount < previousCount) {
      insights.add(
        'Your transaction activity is slowing down — $recentCount transactions in the last 7 days vs $previousCount before that.',
      );
    } else {
      insights.add(
        'Your transaction activity is steady — $recentCount transactions in each of the last two weeks.',
      );
    }

    // --- Expense vs Income warning ---
    if (totalExpenses > totalIncome) {
      insights.add('Warning: Your expenses exceed your income!');
    }

    return insights;
  }

  /// Computes a 0–100 financial health score based on the ratio between
  /// income and expenses.
  ///
  /// * 100 = all income is saved
  /// * ~50 = half is saved
  /// *  0  = expenses far exceed income
  ///
  /// Returns `50.0` when [totalIncome] is zero (no data to evaluate).
  static double calculateHealthScore(
    double totalIncome,
    double totalExpenses,
  ) {
    // No income data — neutral score
    if (totalIncome == 0) return 50.0;

    // Savings ratio: positive means surplus, negative means deficit
    final savingsRatio = (totalIncome - totalExpenses) / totalIncome;

    double score;

    if (totalExpenses > totalIncome) {
      // Overflow: how much expenses exceed income, as a percentage
      final overflowPercent =
          ((totalExpenses - totalIncome) / totalIncome) * 100;
      score = (20 - overflowPercent).clamp(0, 100).toDouble();
    } else {
      // Normal: map savings ratio to 0-100
      score = (savingsRatio * 100).clamp(0, 100).toDouble();
    }

    // Round to 1 decimal place
    return double.parse(score.toStringAsFixed(1));
  }
}
