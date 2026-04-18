import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ai_budget_tracker/providers/transaction_provider.dart';
import 'package:ai_budget_tracker/services/ai_service.dart';
import 'package:ai_budget_tracker/utils/constants.dart';

/// Read-only screen that displays auto-generated AI suggestions.
///
/// Fetches user's financial data and displays personalized,
/// actionable suggestions without any user input required.
/// Supports pull-to-refresh to regenerate suggestions.
class AISuggestionsScreen extends StatefulWidget {
  /// Creates an [AISuggestionsScreen].
  const AISuggestionsScreen({super.key});

  @override
  State<AISuggestionsScreen> createState() => _AISuggestionsScreenState();
}

class _AISuggestionsScreenState extends State<AISuggestionsScreen> {
  late List<String> _suggestions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _generateSuggestions();
  }

  /// Generates suggestions from the current transaction data.
  void _generateSuggestions() {
    setState(() => _isLoading = true);

    final provider = context.read<TransactionProvider>();
    _suggestions =
        AIService.generateDetailedSuggestions(provider.transactions);

    setState(() => _isLoading = false);
  }

  /// Gets an icon for each suggestion based on its emoji prefix.
  IconData _getIconForSuggestion(String suggestion) {
    if (suggestion.startsWith('💰')) {
      return Icons.monetization_on;
    } else if (suggestion.startsWith('📊')) {
      return Icons.bar_chart;
    } else if (suggestion.startsWith('🎯')) {
      return Icons.track_changes;
    } else if (suggestion.startsWith('⚠️')) {
      return Icons.warning_amber_rounded;
    } else if (suggestion.startsWith('🎉')) {
      return Icons.celebration;
    } else if (suggestion.startsWith('🚨')) {
      return Icons.error;
    } else if (suggestion.startsWith('💚')) {
      return Icons.favorite;
    } else if (suggestion.startsWith('✅')) {
      return Icons.check_circle;
    } else if (suggestion.startsWith('🌟')) {
      return Icons.star;
    }
    return Icons.lightbulb_outline;
  }

  /// Gets a color for each suggestion.
  Color _getColorForSuggestion(String suggestion) {
    if (suggestion.startsWith('⚠️') || suggestion.startsWith('🚨')) {
      return Colors.amber.shade700;
    } else if (suggestion.startsWith('🎉') ||
        suggestion.startsWith('✅') ||
        suggestion.startsWith('🌟') ||
        suggestion.startsWith('💚')) {
      return Colors.green;
    } else if (suggestion.startsWith('🎯')) {
      return AppColors.primary;
    }
    return AppColors.primary;
  }

  /// Removes emoji prefix from suggestion for cleaner display.
  String _cleanSuggestionText(String suggestion) {
    // Remove emoji and any leading space
    return suggestion.replaceAll(RegExp(r'^[^\w]*'), '').trim();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Smart Suggestions'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: () async => _generateSuggestions(),
              child: ListView.builder(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                itemCount: _suggestions.length,
                itemBuilder: (context, index) {
                  final suggestion = _suggestions[index];
                  final icon = _getIconForSuggestion(suggestion);
                  final color = _getColorForSuggestion(suggestion);
                  final cleanText = _cleanSuggestionText(suggestion);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildSuggestionCard(
                      icon: icon,
                      color: color,
                      text: cleanText,
                    ),
                  );
                },
              ),
            ),
    );
  }

  /// Builds a single suggestion card with icon and text.
  Widget _buildSuggestionCard({
    required IconData icon,
    required Color color,
    required String text,
  }) {
    return Card(
      elevation: 2,
      color: AppColors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius:
              BorderRadius.circular(AppConstants.cardBorderRadius),
          border: Border(
            left: BorderSide(color: color, width: 4),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
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
              const SizedBox(width: 16),

              // ── Suggestion text ───────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      text,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
