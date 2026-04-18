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

  /// Generates detailed, actionable financial suggestions based on
  /// [transactions]. Returns 3-5 personalized recommendations.
  ///
  /// Suggests improvements in:
  /// * Spending by category (highest spenders)
  /// * Savings potential
  /// * Income vs expense trends
  /// * Financial health alerts
  static List<String> generateDetailedSuggestions(
      List<TransactionModel> transactions) {
    if (transactions.isEmpty) {
      return [
        'Start adding transactions to get personalized financial suggestions!'
      ];
    }

    final suggestions = <String>[];

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

    // --- Suggestion 1: Highest spending category ---
    if (categoryTotals.isNotEmpty) {
      final highest = categoryTotals.entries
          .reduce((a, b) => a.value >= b.value ? a : b);
      final percentage = (highest.value / totalExpenses * 100).toStringAsFixed(0);
      suggestions.add(
        '💰 You spent Rs.${highest.value.toStringAsFixed(0)} on ${highest.key} ($percentage% of total). '
        'Consider budgeting this category more carefully.',
      );
    }

    // --- Suggestion 2: Top 2 categories comparison ---
    if (categoryTotals.length >= 2) {
      final sorted = categoryTotals.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      final top1 = sorted[0];
      final top2 = sorted[1];
      final ratio = (top1.value / top2.value).toStringAsFixed(1);
      suggestions.add(
        '📊 Your ${top1.key} spending is $ratio× higher than ${top2.key}. '
        'Try reducing ${top1.key} expenses by 10-15% to boost savings.',
      );
    }

    // --- Suggestion 3: Savings potential ---
    if (totalIncome > 0 && totalExpenses > 0) {
      final savingsRate = ((totalIncome - totalExpenses) / totalIncome * 100);
      if (savingsRate < 20) {
        suggestions.add(
          '🎯 Your savings rate is only ${savingsRate.toStringAsFixed(1)}%. '
          'Aim for at least 20% savings by cutting non-essential expenses.',
        );
      } else if (savingsRate >= 20 && savingsRate < 50) {
        suggestions.add(
          '✅ Great! You\'re saving ${savingsRate.toStringAsFixed(1)}% of your income. '
          'Keep up this momentum and consider investing your savings.',
        );
      } else {
        suggestions.add(
          '🌟 Excellent! You\'re saving ${savingsRate.toStringAsFixed(1)}% of your income. '
          'You\'re ahead of most people. Consider long-term investment goals.',
        );
      }
    }

    // --- Suggestion 4: Month-over-month trend ---
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    final sixtyDaysAgo = now.subtract(const Duration(days: 60));

    final recentExpenses = transactions
        .where((t) => t.type == 'expense' && t.date.isAfter(thirtyDaysAgo))
        .fold<double>(0, (sum, t) => sum + t.amount);

    final previousExpenses = transactions
        .where((t) =>
            t.type == 'expense' &&
            t.date.isAfter(sixtyDaysAgo) &&
            t.date.isBefore(thirtyDaysAgo))
        .fold<double>(0, (sum, t) => sum + t.amount);

    if (previousExpenses > 0) {
      final changePercent =
          ((recentExpenses - previousExpenses) / previousExpenses * 100);
      if (changePercent > 10) {
        suggestions.add(
          '⚠️ Your spending increased by ${changePercent.toStringAsFixed(1)}% this month. '
          'Review recent transactions to identify unnecessary expenses.',
        );
      } else if (changePercent < -10) {
        suggestions.add(
          '🎉 Your spending decreased by ${(-changePercent).toStringAsFixed(1)}% this month. '
          'Excellent expense control! Keep this up.',
        );
      }
    }

    // --- Suggestion 5: Income vs Expense alert ---
    if (totalExpenses > totalIncome && totalIncome > 0) {
      final deficit = totalExpenses - totalIncome;
      suggestions.add(
        '🚨 Alert: You\'re spending Rs.${deficit.toStringAsFixed(0)} more than you earn. '
        'Review your budget and cut non-essential expenses immediately.',
      );
    } else if (totalIncome > totalExpenses && totalExpenses > 0) {
      final surplus = totalIncome - totalExpenses;
      suggestions.add(
        '💚 Great! You have a surplus of Rs.${surplus.toStringAsFixed(0)} after all expenses. '
        'Consider saving or investing this amount.',
      );
    }

    return suggestions.isEmpty ? ['Keep tracking your finances!'] : suggestions;
  }
}
