import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ai_budget_tracker/providers/transaction_provider.dart';
import 'package:ai_budget_tracker/services/ai_service.dart';
import 'package:ai_budget_tracker/utils/constants.dart';
import 'package:ai_budget_tracker/models/transaction_model.dart';

/// AI Chatbot screen that displays financial suggestions in a chat bubble interface.
///
/// Shows AI-generated recommendations as chat messages with a back button
/// to return to the home screen.
class AIChatbotScreen extends StatefulWidget {
  /// Creates an [AIChatbotScreen].
  const AIChatbotScreen({super.key});

  @override
  State<AIChatbotScreen> createState() => _AIChatbotScreenState();
}

class _AIChatbotScreenState extends State<AIChatbotScreen> {
  late List<String> _suggestions;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _generateSuggestions();
  }

  /// Generates AI suggestions from current transactions.
  Future<void> _generateSuggestions() async {
    final provider = context.read<TransactionProvider>();
    final transactions = provider.transactions;

    setState(() => _isLoading = true);

    // Simulate a small delay for better UX
    await Future.delayed(const Duration(milliseconds: 500));

    final suggestions = AIService.generateDetailedSuggestions(transactions);

    setState(() {
      _suggestions = suggestions;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'AI Financial Assistant',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.cardBackground,
        foregroundColor: AppColors.textPrimary,
        surfaceTintColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: AppColors.border,
            height: 1,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            )
          : RefreshIndicator(
              color: AppColors.primary,
              onRefresh: _generateSuggestions,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.defaultPadding,
                  vertical: 16,
                ),
                itemCount: _suggestions.length,
                itemBuilder: (context, index) {
                  final suggestion = _suggestions[index];
                  return _buildChatBubble(suggestion, index);
                },
              ),
            ),
    );
  }

  /// Builds a chat bubble widget for each suggestion.
  Widget _buildChatBubble(String suggestion, int index) {
    // Alternate alignment: AI messages on left, user acknowledgment-style on right
    final isAiMessage = true; // All are AI messages

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isAiMessage) ...[
            // AI avatar with gradient
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primaryDark,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.smart_toy_outlined,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
          ],
          // Chat bubble
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
                ],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.border.withValues(alpha: 0.6),
                    width: 1.2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Suggestion number badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withValues(alpha: 0.15),
                            AppColors.primaryLight.withValues(alpha: 0.1),
                          ],
                        ),
                        borderRadius:
                            BorderRadius.circular(AppConstants.smallBorderRadius),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'Suggestion ${index + 1}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Suggestion text
                    Text(
                      suggestion,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                        height: 1.7,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
