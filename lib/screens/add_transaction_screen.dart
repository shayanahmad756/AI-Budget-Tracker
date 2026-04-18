import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ai_budget_tracker/providers/transaction_provider.dart';
import 'package:ai_budget_tracker/services/ai_service.dart';
import 'package:ai_budget_tracker/utils/constants.dart';

/// Form screen for adding a new income or expense transaction.
///
/// Provides fields for title, amount, and transaction type. The expense
/// category is auto-detected in real time using [AIService.categorizeExpense].
class AddTransactionScreen extends StatefulWidget {
  /// Creates an [AddTransactionScreen].
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();

  String _type = 'expense';
  String _detectedCategory = 'Other';
  String _aiSuggestedCategory = 'Other';

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  /// Saves the transaction via [TransactionProvider] after validating the form.
  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<TransactionProvider>();

    await provider.addTransaction(
      title: _titleController.text.trim(),
      amount: double.parse(_amountController.text.trim()),
      type: _type,
      category: _type == 'expense' ? _detectedCategory : null,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Transaction added successfully!'),
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Add Transaction'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Title Field ──────────────────────────────────────
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'e.g., Lunch at restaurant',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
                onChanged: (value) {
                  final aiCategory = AIService.categorizeExpense(value);
                  setState(() {
                    _aiSuggestedCategory = aiCategory;
                    _detectedCategory = aiCategory;
                  });
                },
              ),
              const SizedBox(height: 16),

              // ── Amount Field ─────────────────────────────────────
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixText: 'Rs. ',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.money),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter an amount';
                  }
                  final parsed = double.tryParse(value.trim());
                  if (parsed == null || parsed <= 0) {
                    return 'Please enter a valid positive number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ── Transaction Type Toggle ──────────────────────────
              const Text(
                'Transaction Type',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment<String>(
                    value: 'income',
                    label: Text('Income'),
                    icon: Icon(Icons.arrow_upward),
                  ),
                  ButtonSegment<String>(
                    value: 'expense',
                    label: Text('Expense'),
                    icon: Icon(Icons.arrow_downward),
                  ),
                ],
                selected: {_type},
                onSelectionChanged: (selection) {
                  setState(() {
                    _type = selection.first;
                  });
                },
              ),
              const SizedBox(height: 16),

              // ── Category Dropdown ─────────────────────────────────
              if (_type == 'expense') ...[
                DropdownButtonFormField<String>(
                  initialValue: _detectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: CategoryHelper.categories.map((category) {
                    final icon = CategoryHelper.categoryIcons[category] ??
                        Icons.category;
                    final color = CategoryHelper.categoryColors[category] ??
                        AppColors.primary;
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Row(
                        children: [
                          Icon(icon, color: color, size: 20),
                          const SizedBox(width: 8),
                          Text(category),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _detectedCategory = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 4),
                Text(
                  'AI suggested: $_aiSuggestedCategory',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
              const SizedBox(height: 24),

              // ── Save Button ──────────────────────────────────────
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveTransaction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Save Transaction',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
