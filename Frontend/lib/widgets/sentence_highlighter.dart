// ignore_for_file: deprecated_member_use

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:trust_guard/widgets/glass_card.dart';
import 'package:trust_guard/utils/app_theme.dart';

class SentenceHighlighter extends StatelessWidget {
  final String fullText;
  final List<Map<String, dynamic>> flaggedSentences;

  const SentenceHighlighter({
    super.key,
    required this.fullText,
    required this.flaggedSentences,
  });

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'unverified':
      case 'fake':
        return Colors.orangeAccent;
      case 'toxic':
      case 'harmful':
        return AppTheme.dangerColor;
      case 'clickbait':
      case 'exaggerated':
      case 'sensational':
        return Colors.amberAccent;
      default:
        return AppTheme.primaryColor;
    }
  }

  void _showExplanationDialog(
    BuildContext context,
    String sentence,
    String category,
    String reason,
  ) {
    final color = _getCategoryColor(category);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E2640),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: color.withOpacity(0.5)),
        ),
        title: Row(
          children: [
            Icon(Icons.flag_rounded, color: color),
            const SizedBox(width: 8),
            Text(
              "Flagged (${category.toUpperCase()})",
              style: TextStyle(color: color, fontSize: 16),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '"$sentence"',
                style: const TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.white70,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "AI Finding:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              reason.isNotEmpty
                  ? reason
                  : "This sentence contains flagged attributes.",
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CLOSE", style: TextStyle(color: Colors.white70)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (fullText.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    // Build rich text spans
    final List<InlineSpan> spans = [];

    // Simple sentence matching scanner
    String remaining = fullText;

    while (remaining.isNotEmpty) {
      int earliestIndex = -1;
      Map<String, dynamic>? matchingFlag;

      for (final flag in flaggedSentences) {
        final sentence = flag['sentence'] as String? ?? '';
        if (sentence.isEmpty) continue;

        final idx = remaining.toLowerCase().indexOf(sentence.toLowerCase());
        if (idx != -1 && (earliestIndex == -1 || idx < earliestIndex)) {
          earliestIndex = idx;
          matchingFlag = flag;
        }
      }

      if (earliestIndex == -1 || matchingFlag == null) {
        spans.add(
          TextSpan(
            text: remaining,
            style: const TextStyle(color: Colors.white70, height: 1.6),
          ),
        );
        break;
      }

      if (earliestIndex > 0) {
        spans.add(
          TextSpan(
            text: remaining.substring(0, earliestIndex),
            style: const TextStyle(color: Colors.white70, height: 1.6),
          ),
        );
      }

      final matchedSentence = matchingFlag['sentence'] as String;
      final category = matchingFlag['category'] as String? ?? 'flagged';
      final reason = matchingFlag['reason'] as String? ?? '';
      final color = _getCategoryColor(category);

      final matchedTextInRemaining = remaining.substring(
        earliestIndex,
        earliestIndex + matchedSentence.length,
      );

      spans.add(
        TextSpan(
          text: matchedTextInRemaining,
          style: TextStyle(
            color: Colors.white,
            backgroundColor: color.withOpacity(0.25),
            fontWeight: FontWeight.w600,
            decoration: TextDecoration.underline,
            decorationColor: color,
            decorationStyle: TextDecorationStyle.dotted,
            height: 1.6,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              _showExplanationDialog(
                context,
                matchedTextInRemaining,
                category,
                reason,
              );
            },
        ),
      );

      remaining = remaining.substring(earliestIndex + matchedSentence.length);
    }

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.find_in_page_outlined,
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "Interactive Sentence Inspector",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              if (flaggedSentences.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.warningColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.warningColor.withOpacity(0.4),
                    ),
                  ),
                  child: Text(
                    "${flaggedSentences.length} Flagged",
                    style: const TextStyle(
                      color: AppTheme.warningColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            "Tap on highlighted text fragments to view specific AI findings.",
            style: TextStyle(color: Colors.white54, fontSize: 13),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10),
            ),
            child: RichText(
              text: TextSpan(
                children: spans,
                style: const TextStyle(fontSize: 15, fontFamily: 'Roboto'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
