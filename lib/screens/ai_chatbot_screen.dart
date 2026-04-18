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
        title: const Text('AI Financial Assistant'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
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
            // AI avatar
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Icon(
                Icons.smart_toy_outlined,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
          ],
          // Chat bubble
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isAiMessage
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : AppColors.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Suggestion number badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Suggestion ${index + 1}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Suggestion text with proper line height for multi-line content
                  Text(
                    suggestion,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
