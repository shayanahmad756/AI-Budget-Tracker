import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:ai_budget_tracker/providers/transaction_provider.dart';
import 'package:ai_budget_tracker/utils/constants.dart';
import 'package:ai_budget_tracker/widgets/summary_card.dart';
import 'package:ai_budget_tracker/widgets/insight_card.dart';
import 'package:ai_budget_tracker/screens/add_transaction_screen.dart';
import 'package:ai_budget_tracker/screens/history_screen.dart';
import 'package:ai_budget_tracker/screens/ai_suggestions_screen.dart';
import 'package:ai_budget_tracker/screens/ai_chatbot_screen.dart';

/// Main dashboard screen of the AI Budget Tracker.
///
/// Displays summary cards, budget progress, financial health score,
/// a category breakdown pie chart, and AI-generated insights.
class HomeScreen extends StatelessWidget {
  /// Creates a [HomeScreen].
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('AI Budget Tracker'),
            actions: [
              IconButton(
                icon: const Icon(Icons.history),
                tooltip: 'Transaction History',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HistoryScreen()),
                  );
                },
              ),
            ],
          ),
          body: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Summary Cards ─────────────────────────────
                      _buildSummaryCards(provider),
                      const SizedBox(height: 24),

                      // ── Budget Progress ───────────────────────────
                      _buildBudgetProgress(provider),
                      const SizedBox(height: 24),

                      // ── Financial Health Score ────────────────────
                      _buildHealthScore(provider),
                      const SizedBox(height: 24),

                      // ── Category Breakdown Pie Chart ──────────────
                      _buildCategoryBreakdown(provider),
                      const SizedBox(height: 200), // space for multiple FABs
                    ],
                  ),
                ),
          floatingActionButton: Stack(
            alignment: Alignment.bottomRight,
            children: [
              // ── Secondary FAB: AI Chatbot ─────────────────────
              Positioned(
                bottom: 160,
                right: 0,
                child: FloatingActionButton.extended(
                  heroTag: 'chatbot_fab',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AIChatbotScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: const Text('Chat'),
                  backgroundColor: Colors.teal.withValues(alpha: 0.8),
                ),
              ),

              // ── Secondary FAB: Smart Suggestions ───────────────
              Positioned(
                bottom: 80,
                right: 0,
                child: FloatingActionButton.extended(
                  heroTag: 'suggestions_fab',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AISuggestionsScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.lightbulb_outline),
                  label: const Text('Suggestions'),
                  backgroundColor: AppColors.primary.withValues(alpha: 0.8),
                ),
              ),

              // ── Primary FAB: Add Transaction ───────────────────
              FloatingActionButton(
                heroTag: 'add_fab',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AddTransactionScreen(),
                    ),
                  );
                },
                child: const Icon(Icons.add),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Builds the three summary cards row: Balance, Income, Expenses.
  Widget _buildSummaryCards(TransactionProvider provider) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          SizedBox(
            width: 200,
            child: SummaryCard(
              title: 'Balance',
              amount: provider.balance,
              icon: Icons.account_balance_wallet,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 200,
            child: SummaryCard(
              title: 'Income',
              amount: provider.totalIncome,
              icon: Icons.arrow_upward,
              color: AppColors.income,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 200,
            child: SummaryCard(
              title: 'Expenses',
              amount: provider.totalExpenses,
              icon: Icons.arrow_downward,
              color: AppColors.expense,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the monthly budget progress section with a linear indicator.
  Widget _buildBudgetProgress(TransactionProvider provider) {
    final usagePercent = provider.budgetUsagePercent;
    final clampedValue = (usagePercent / 100).clamp(0.0, 1.0);

    return Card(
      elevation: 2,
      color: AppColors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Monthly Budget',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: clampedValue,
                minHeight: 10,
                backgroundColor: AppColors.background,
                valueColor: AlwaysStoppedAnimation<Color>(
                  provider.isBudgetWarning
                      ? AppColors.expense
                      : AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Rs.${provider.totalExpenses.toStringAsFixed(0)} / Rs.${AppConstants.defaultMonthlyBudget.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            if (provider.isBudgetWarning) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade700),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.amber.shade800,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        "Warning: You've used over 80% of your monthly budget!",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Builds the financial health score section with a circular indicator.
  Widget _buildHealthScore(TransactionProvider provider) {
    final score = provider.healthScore;
    final scoreColor = score > 70
        ? AppColors.income
        : score > 40
        ? Colors.amber
        : AppColors.expense;

    return Card(
      elevation: 2,
      color: AppColors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Financial Health Score',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: SizedBox(
                width: 120,
                height: 120,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: CircularProgressIndicator(
                        value: (score / 100).clamp(0.0, 1.0),
                        strokeWidth: 10,
                        backgroundColor: AppColors.background,
                        valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                      ),
                    ),
                    Text(
                      '${score.toInt()}',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: scoreColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the category breakdown pie chart with legend.
  Widget _buildCategoryBreakdown(TransactionProvider provider) {
    final breakdown = provider.categoryBreakdown;

    return Card(
      elevation: 2,
      color: AppColors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Spending by Category',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            if (breakdown.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.pie_chart_outline,
                        size: 48,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'No expense data yet',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else ...[
              SizedBox(
                height: 200,
                child: PieChart(
                  PieChartData(
                    sections: _buildPieSections(breakdown),
                    centerSpaceRadius: 40,
                    sectionsSpace: 2,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildLegend(breakdown),
            ],
          ],
        ),
      ),
    );
  }

  /// Creates [PieChartSectionData] list from category breakdown map.
  List<PieChartSectionData> _buildPieSections(Map<String, double> breakdown) {
    final total = breakdown.values.fold(0.0, (a, b) => a + b);
    return breakdown.entries.map((entry) {
      final percent = (entry.value / total * 100);
      final color =
          CategoryHelper.categoryColors[entry.key] ?? AppColors.textSecondary;
      return PieChartSectionData(
        value: entry.value,
        color: color,
        title: '${percent.toStringAsFixed(0)}%',
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        radius: 50,
      );
    }).toList();
  }

  /// Builds the pie chart legend showing colored dots, names, and amounts.
  Widget _buildLegend(Map<String, double> breakdown) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: breakdown.entries.map((entry) {
        final color =
            CategoryHelper.categoryColors[entry.key] ?? AppColors.textSecondary;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 4),
            Text(
              '${entry.key}: Rs.${entry.value.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  /// Builds the AI insights section.
}
