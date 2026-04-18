import 'package:flutter/foundation.dart';
import 'package:ai_budget_tracker/models/transaction_model.dart';
import 'package:ai_budget_tracker/services/database_service.dart';
import 'package:ai_budget_tracker/services/ai_service.dart';
import 'package:ai_budget_tracker/utils/constants.dart';

/// Central state-management layer for all transaction data.
///
/// Wraps [DatabaseService] for persistence and [AIService] for
/// categorisation / insights.  Consumers (screens, widgets) should
/// listen to this provider via `context.watch<TransactionProvider>()`.
class TransactionProvider extends ChangeNotifier {
  // ─── Private state ──────────────────────────────────────────────

  List<TransactionModel> _transactions = [];
  bool _isLoading = false;

  // ─── Public getters ─────────────────────────────────────────────

  /// The full list of transactions, most-recent first.
  List<TransactionModel> get transactions => _transactions;

  /// Whether a database operation is currently in progress.
  bool get isLoading => _isLoading;

  // ─── CRUD operations ───────────────────────────────────────────

  /// Fetches all transactions from [DatabaseService] and updates
  /// the local list.
  Future<void> loadTransactions() async {
    _isLoading = true;
    notifyListeners();

    try {
      _transactions = await DatabaseService.instance.getTransactions();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Creates a new transaction, auto-categorising it via [AIService].
  ///
  /// [title] is used for keyword-based categorisation.
  /// [amount] is the monetary value.
  /// [type] must be `"income"` or `"expense"`.
  Future<void> addTransaction({
    required String title,
    required double amount,
    required String type,
    String? category,
  }) async {
    final finalCategory = type == 'income'
        ? 'Income'
        : category ?? AIService.categorizeExpense(title);

    final transaction = TransactionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      amount: amount,
      category: finalCategory,
      date: DateTime.now(),
      type: type,
    );

    await DatabaseService.instance.insertTransaction(transaction);
    await loadTransactions();
  }

  /// Deletes the transaction identified by [id] and reloads the list.
  Future<void> deleteTransaction(String id) async {
    await DatabaseService.instance.deleteTransaction(id);
    await loadTransactions();
  }

  // ─── Computed properties ───────────────────────────────────────

  /// Sum of all income transaction amounts.
  double get totalIncome => _transactions
      .where((t) => t.type == 'income')
      .fold(0.0, (sum, t) => sum + t.amount);

  /// Sum of all expense transaction amounts.
  double get totalExpenses => _transactions
      .where((t) => t.type == 'expense')
      .fold(0.0, (sum, t) => sum + t.amount);

  /// Net balance (income minus expenses).
  double get balance => totalIncome - totalExpenses;

  /// Groups expense transactions by category and sums the amounts.
  ///
  /// Useful for rendering pie / donut charts.
  Map<String, double> get categoryBreakdown {
    final map = <String, double>{};
    for (final t in _transactions) {
      if (t.type == 'expense') {
        map[t.category] = (map[t.category] ?? 0) + t.amount;
      }
    }
    return map;
  }

  /// AI-generated insight strings based on current transactions.
  List<String> get insights => AIService.generateInsights(_transactions);

  /// Financial health score (0–100) computed by [AIService].
  double get healthScore =>
      AIService.calculateHealthScore(totalIncome, totalExpenses);

  /// Percentage of [AppConstants.defaultMonthlyBudget] consumed by expenses.
  ///
  /// Can exceed 100 when spending surpasses the budget.
  double get budgetUsagePercent =>
      (totalExpenses / AppConstants.defaultMonthlyBudget) * 100;

  /// Whether the user should see a budget-warning indicator.
  ///
  /// Returns `true` when 80 % or more of the monthly budget is spent.
  bool get isBudgetWarning => budgetUsagePercent >= 80;
}
