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
      'food',
      'biryani',
      'restaurant',
      'lunch',
      'dinner',
      'breakfast',
      'meal',
    ],
    'Travel': ['uber', 'petrol', 'fuel', 'taxi', 'bus', 'train', 'flight'],
    'Bills': ['rent', 'bill', 'electricity', 'water', 'internet', 'phone'],
    'Shopping': ['shopping', 'amazon', 'flipkart', 'clothes', 'shoes'],
    'Entertainment': ['movie', 'netflix', 'game', 'concert'],
    'Health': ['doctor', 'medicine', 'hospital', 'gym'],
    'Education': ['course', 'book', 'school', 'college', 'tuition'],
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
      final highest = categoryTotals.entries.reduce(
        (a, b) => a.value >= b.value ? a : b,
      );
      insights.add('You spent the most on ${highest.key} this period');
    }

    // --- 7-day trend comparison ---
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));
    final fourteenDaysAgo = now.subtract(const Duration(days: 14));

    final recentCount = transactions
        .where((t) => t.date.isAfter(sevenDaysAgo))
        .length;
    final previousCount = transactions
        .where(
          (t) =>
              t.date.isAfter(fourteenDaysAgo) && t.date.isBefore(sevenDaysAgo),
        )
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
  static double calculateHealthScore(double totalIncome, double totalExpenses) {
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
    List<TransactionModel> transactions,
  ) {
    if (transactions.isEmpty) {
      return [
        'Start adding transactions to get personalized financial suggestions!',
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
      final highest = categoryTotals.entries.reduce(
        (a, b) => a.value >= b.value ? a : b,
      );
      final percentage = (highest.value / totalExpenses * 100).toStringAsFixed(
        0,
      );
      final tips = _getImprovementTipsForCategory(highest.key);
      suggestions.add(
        'You spent Rs.${highest.value.toStringAsFixed(0)} on ${highest.key} ($percentage% of total).\n'
        'How to improve: $tips',
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
        'Your ${top1.key} spending is $ratio× higher than ${top2.key}.\n'
        'Action: Try reducing ${top1.key} expenses by 10-15% to boost savings.',
      );
    }

    // --- Suggestion 3: Savings potential ---
    if (totalIncome > 0 && totalExpenses > 0) {
      final savingsRate = ((totalIncome - totalExpenses) / totalIncome * 100);
      if (savingsRate < 20) {
        suggestions.add(
          'Your savings rate is only ${savingsRate.toStringAsFixed(1)}% - Below target of 20%.\n'
          'Action steps: (1) Track all expenses for 2 weeks, (2) Cut non-essentials like subscriptions, (3) Reduce dining out, (4) Set automatic savings on payday, (5) Build 3-month emergency fund.',
        );
      } else if (savingsRate >= 20 && savingsRate < 50) {
        suggestions.add(
          'Great! You are saving ${savingsRate.toStringAsFixed(1)}% of your income.\n'
          'Next steps: (1) Open high-interest savings account, (2) Invest in mutual fund SIP (10-12% returns), (3) Build 6-month emergency fund, (4) Start retirement planning.',
        );
      } else {
        suggestions.add(
          'Excellent! You are saving ${savingsRate.toStringAsFixed(1)}% of your income - ahead of most people.\n'
          'Advanced goals: (1) Diversify investments (stocks, bonds, real estate), (2) Build passive income streams, (3) Plan for early retirement, (4) Create long-term wealth strategy.',
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
        .where(
          (t) =>
              t.type == 'expense' &&
              t.date.isAfter(sixtyDaysAgo) &&
              t.date.isBefore(thirtyDaysAgo),
        )
        .fold<double>(0, (sum, t) => sum + t.amount);

    if (previousExpenses > 0) {
      final changePercent =
          ((recentExpenses - previousExpenses) / previousExpenses * 100);
      if (changePercent > 10) {
        suggestions.add(
          'WARNING: Your spending increased by ${changePercent.toStringAsFixed(1)}% this month.\n'
          'How to fix: (1) Identify unusual transactions, (2) Stop discretionary purchases for 1 month, (3) Return to previous spending level, (4) Set category budgets to prevent overspending.',
        );
      } else if (changePercent < -10) {
        suggestions.add(
          'Excellent! Your spending decreased by ${(-changePercent).toStringAsFixed(1)}% this month.\n'
          'How to maintain: Continue same habits, invest the savings, celebrate progress, and inspire others with your discipline.',
        );
      }
    }

    // --- Suggestion 5: Income vs Expense alert ---
    if (totalExpenses > totalIncome && totalIncome > 0) {
      final deficit = totalExpenses - totalIncome;
      final deficitPercent = (deficit / totalIncome * 100).toStringAsFixed(1);
      suggestions.add(
        'ALERT: You are spending Rs.${deficit.toStringAsFixed(0)} more than you earn ($deficitPercent% deficit).\n'
        'Urgent actions: (1) Stop all non-essential spending immediately, (2) Cut each category by 20-30%, (3) Find side income or freelance work, (4) Create realistic budget, (5) Track daily spending.',
      );
    } else if (totalIncome > totalExpenses && totalExpenses > 0) {
      final surplus = totalIncome - totalExpenses;
      final surplusPercent = (surplus / totalIncome * 100).toStringAsFixed(1);
      suggestions.add(
        'Great! You have surplus of Rs.${surplus.toStringAsFixed(0)} ($surplusPercent% after expenses).\n'
        'Money allocation: (1) 50% - Emergency fund (6 months expenses), (2) 30% - Investments/Retirement, (3) 15% - Personal goals, (4) 5% - Charity/Helping others.',
      );
    }

    return suggestions.isEmpty ? ['Keep tracking your finances!'] : suggestions;
  }

  /// Returns category-specific improvement tips.
  static String _getImprovementTipsForCategory(String category) {
    switch (category) {
      case 'Food':
        return 'Plan meals weekly, cook at home, limit dining out to 2x/month, buy in bulk, use cashback apps.';
      case 'Travel':
        return 'Carpool when possible, use public transport, combine trips, maintain vehicle regularly, work-from-home days.';
      case 'Shopping':
        return 'Make shopping list, wait 24hrs before buying, use coupons, avoid impulse purchases, shop only when needed.';
      case 'Entertainment':
        return 'Share subscriptions with family, use free entertainment options, limit dining out, enjoy free outdoor activities.';
      case 'Bills':
        return 'Negotiate bills, switch providers for better rates, unsubscribe unused services, use energy-saving practices.';
      case 'Health':
        return 'Use generic medicines, focus on preventive care, exercise at home, use fitness tracking apps.';
      case 'Education':
        return 'Use free online courses, share resources, study in groups, buy used books, watch educational videos.';
      default:
        return 'Review these expenses, eliminate unnecessary ones, and track daily to find spending patterns.';
    }
  }
}
