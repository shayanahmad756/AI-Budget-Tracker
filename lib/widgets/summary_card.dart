import 'package:flutter/material.dart';
import 'package:ai_budget_tracker/utils/constants.dart';

/// A reusable dashboard summary card showing a single metric.
///
/// Displays an [icon] inside a tinted circle, a small [title] label,
/// and the formatted [amount] in the given [color].
class SummaryCard extends StatelessWidget {
  /// Title label shown above the amount (e.g. "Income", "Expenses").
  final String title;

  /// Numeric value to display, formatted to two decimal places.
  final double amount;

  /// Leading icon representing the metric.
  final IconData icon;

  /// Accent colour used for the icon background and amount text.
  final Color color;

  /// Creates a [SummaryCard].
  const SummaryCard({
    super.key,
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: AppColors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Row(
          children: [
            // ── Icon badge ────────────────────────────────────
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),

            // ── Text column ───────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rs.${amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
