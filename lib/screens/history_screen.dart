import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ai_budget_tracker/providers/transaction_provider.dart';
import 'package:ai_budget_tracker/utils/constants.dart';
import 'package:ai_budget_tracker/widgets/transaction_tile.dart';

/// Screen that displays the full history of all transactions.
///
/// Transactions are listed newest-first using [TransactionTile] widgets.
/// Each tile supports swipe-to-delete with a confirmation dialog.
class HistoryScreen extends StatelessWidget {
  /// Creates a [HistoryScreen].
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Transaction History'),
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, _) {
          final transactions = provider.transactions;

          if (transactions.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.receipt_long,
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No transactions yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Add your first transaction to get started!',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final transaction = transactions[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: TransactionTile(
                  transaction: transaction,
                  onDelete: () => _confirmDelete(context, provider, transaction.id),
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// Shows a confirmation dialog and deletes the transaction if confirmed.
  void _confirmDelete(
    BuildContext context,
    TransactionProvider provider,
    String id,
  ) {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: const Text(
          'Are you sure you want to delete this transaction?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.expense),
            child: const Text('Delete'),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true) {
        provider.deleteTransaction(id);
      }
    });
  }
}
