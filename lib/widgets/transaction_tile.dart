import 'package:flutter/material.dart';
import 'package:ai_budget_tracker/models/transaction_model.dart';
import 'package:ai_budget_tracker/utils/constants.dart';
import 'package:intl/intl.dart';

/// Displays a single [TransactionModel] as a card list-tile.
///
/// Shows the category icon, title, category + date subtitle,
/// and a colour-coded amount.  Supports optional swipe-to-delete
/// via the [onDelete] callback.
class TransactionTile extends StatelessWidget {
  /// The transaction to render.
  final TransactionModel transaction;

  /// Called when the user swipes to delete.  If `null`, the tile is
  /// not dismissible.
  final VoidCallback? onDelete;

  /// Creates a [TransactionTile].
  const TransactionTile({super.key, required this.transaction, this.onDelete});

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == 'income';
    final amountColor = isIncome ? AppColors.income : AppColors.expense;
    final amountPrefix = isIncome ? '+' : '-';
    final formattedDate = DateFormat('MMM dd, yyyy').format(transaction.date);

    final categoryIcon =
        CategoryHelper.categoryIcons[transaction.category] ?? Icons.category;
    final categoryColor =
        CategoryHelper.categoryColors[transaction.category] ??
        AppColors.textSecondary;

    Widget tile = Card(
      elevation: 1,
      color: AppColors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.defaultPadding,
          vertical: 8,
        ),
        // ── Leading: category icon in coloured circle ──────────
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: categoryColor.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(categoryIcon, color: categoryColor, size: 22),
        ),
        // ── Title & subtitle ───────────────────────────────────
        title: Text(
          transaction.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          '${transaction.category} \u2022 $formattedDate',
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        // ── Trailing: amount + delete button ──────────────────
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${amountPrefix}Rs.${transaction.amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: amountColor,
              ),
            ),
            if (onDelete != null) ...[
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  color: AppColors.expense,
                ),
                iconSize: 20,
                splashRadius: 20,
                onPressed: onDelete,
                tooltip: 'Delete transaction',
              ),
            ],
          ],
        ),
      ),
    );

    // ── Optional swipe-to-delete ──────────────────────────────────
    if (onDelete != null) {
      tile = Dismissible(
        key: ValueKey(transaction.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: AppColors.expense.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
          ),
          child: const Icon(Icons.delete, color: AppColors.expense),
        ),
        onDismissed: (_) => onDelete!(),
        child: tile,
      );
    }

    return tile;
  }
}
