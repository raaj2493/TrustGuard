// ignore_for_file: deprecated_member_use, curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:trust_guard/widgets/custom_navbar.dart';
import 'package:trust_guard/widgets/glass_card.dart';
import 'package:trust_guard/widgets/trust_meter.dart';
import 'package:trust_guard/widgets/metrics_breakdown_card.dart';
import 'package:trust_guard/widgets/sentence_highlighter.dart';
import 'package:trust_guard/utils/app_theme.dart';

class ResultPage extends StatelessWidget {
  final Map<String, dynamic> resultData;

  const ResultPage({super.key, required this.resultData});

  Future<void> _launchURL(BuildContext context, String urlString) async {
    final Uri? uri = Uri.tryParse(urlString);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open link: $urlString')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double score = (resultData['score'] as num? ?? 0).toDouble();
    final String status = resultData['status'] as String? ?? 'Unknown';
    final String explanation = resultData['explanation'] as String? ?? '';
    final String originalText = resultData['original_text'] as String? ?? '';
    final List<Map<String, dynamic>> details =
        (resultData['details'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    final Map<String, dynamic> metrics =
        (resultData['metrics'] as Map<String, dynamic>?) ?? {};

    final List<Map<String, dynamic>> flaggedSentences =
        (resultData['flagged_sentences'] as List?)
                ?.cast<Map<String, dynamic>>() ??
            [];

    final List<Map<String, dynamic>> sources =
        (resultData['sources'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final List<String> searchQueries =
        (resultData['search_queries'] as List?)?.cast<String>() ?? [];
    final String? scrapedTitle = resultData['scraped_title'] as String?;
    final String? scrapedUrl = resultData['scraped_url'] as String?;

    final int trustScore = (metrics['trust_score'] as num? ?? score.toInt()).toInt();
    final int toxicity = (metrics['toxicity'] as num? ?? 0).toInt();
    final int spam = (metrics['spam'] as num? ?? 0).toInt();
    final int clickbait = (metrics['clickbait'] as num? ?? 0).toInt();

    final bool isMyth = status.toLowerCase().contains("myth") ||
        status.toLowerCase().contains("misconception");

    final Color statusColor = score >= 75
        ? AppTheme.accentColor
        : (isMyth || score >= 30
            ? AppTheme.warningColor
            : AppTheme.dangerColor);

    return Scaffold(
      body: Stack(
        children: [
          // Result Background
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topCenter,
                  radius: 1.5,
                  colors: [
                    statusColor.withOpacity(0.1),
                    AppTheme.darkBackground,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                CustomNavbar(
                  currentIndex: 1,
                  onNavigate: (index) {
                    if (index == 0) {
                      Navigator.popUntil(context, (route) => route.isFirst);
                    }
                  },
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 900),
                        child: Column(
                          children: [
                            if (scrapedUrl != null) ...[
                              Container(
                                margin: const EdgeInsets.only(bottom: 24),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppTheme.primaryColor.withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryColor.withOpacity(0.15),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.link_rounded,
                                        color: AppTheme.primaryColor,
                                        size: 18,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            "Analyzed Web Article",
                                            style: TextStyle(
                                              color: Colors.white54,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            scrapedTitle ?? scrapedUrl,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    TextButton.icon(
                                      onPressed: () =>
                                          _launchURL(context, scrapedUrl),
                                      icon: const Icon(
                                        Icons.open_in_new_rounded,
                                        size: 14,
                                      ),
                                      label: const Text("Visit Page"),
                                      style: TextButton.styleFrom(
                                        foregroundColor: AppTheme.primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            // Meter Section
                            TrustMeter(score: score),

                            const SizedBox(height: 20),
                            Text(
                              status.toUpperCase(),
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                    color: statusColor,
                                    letterSpacing: 2,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),

                            const SizedBox(height: 32),

                            // Metrics Breakdown Card (Visual Charts)
                            MetricsBreakdownCard(
                              trustScore: trustScore,
                              toxicity: toxicity,
                              spam: spam,
                              clickbait: clickbait,
                            ),

                            const SizedBox(height: 24),

                            // Sentence Highlighter (if text & flagged sentences exist)
                            if (originalText.isNotEmpty) ...[
                              SentenceHighlighter(
                                fullText: originalText,
                                flaggedSentences: flaggedSentences,
                              ),
                              const SizedBox(height: 24),
                            ],

                            // Explanation Card
                            GlassCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.analytics_outlined,
                                        color: AppTheme.primaryColor,
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        "AI Findings & Reasoning",
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleLarge?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    explanation,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.copyWith(height: 1.6),
                                  ),
                                  if (details.isNotEmpty) ...[
                                    const SizedBox(height: 24),
                                    Text(
                                      "Risk Indicators",
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(color: Colors.white70),
                                    ),
                                    const SizedBox(height: 12),
                                    Wrap(
                                      spacing: 12,
                                      runSpacing: 12,
                                      children: details.map((detail) {
                                        return Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 10,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.05),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            border: Border.all(
                                              color: Colors.white10,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                detail['icon'] as IconData,
                                                size: 18,
                                                color: AppTheme.warningColor,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                detail['text'] as String,
                                                style: const TextStyle(
                                                  color: Colors.white70,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ],
                              ),
                            ),

                            // Grounding Sources & Fact-Checks (if available)
                            if (sources.isNotEmpty || searchQueries.isNotEmpty) ...[
                              const SizedBox(height: 24),
                              GlassCard(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: AppTheme.primaryColor
                                                .withOpacity(0.12),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: const Icon(
                                            Icons.verified_outlined,
                                            color: AppTheme.primaryColor,
                                            size: 22,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Live Web Grounding & Fact Checks",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                              ),
                                              const SizedBox(height: 2),
                                              const Text(
                                                "Cross-referenced against real-time Google search indices and authoritative sources",
                                                style: TextStyle(
                                                  color: Colors.white54,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (searchQueries.isNotEmpty) ...[
                                      const SizedBox(height: 20),
                                      const Text(
                                        "Live Web Searches Performed:",
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: searchQueries.map((query) {
                                          return Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(0.06),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                color: Colors.white12,
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(
                                                  Icons.search,
                                                  size: 13,
                                                  color: AppTheme.primaryColor,
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  query,
                                                  style: const TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ],
                                    if (sources.isNotEmpty) ...[
                                      const SizedBox(height: 20),
                                      const Text(
                                        "Authoritative Sources & Citations:",
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Column(
                                        children: sources.map((src) {
                                          final String title =
                                              src['title'] as String? ??
                                                  'Source Link';
                                          final String url =
                                              src['url'] as String? ?? '';
                                          return Container(
                                            margin: const EdgeInsets.only(
                                                bottom: 8),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(0.04),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                color: Colors.white10,
                                              ),
                                            ),
                                            child: ListTile(
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 14,
                                                vertical: 2,
                                              ),
                                              leading: Container(
                                                padding: const EdgeInsets.all(6),
                                                decoration: BoxDecoration(
                                                  color: AppTheme.accentColor
                                                      .withOpacity(0.12),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(
                                                  Icons.language,
                                                  color: AppTheme.accentColor,
                                                  size: 18,
                                                ),
                                              ),
                                              title: Text(
                                                title,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              subtitle: Text(
                                                url,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  color: Colors.white38,
                                                  fontSize: 11,
                                                ),
                                              ),
                                              trailing: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  IconButton(
                                                    icon: const Icon(
                                                      Icons.copy_rounded,
                                                      size: 16,
                                                      color: Colors.white54,
                                                    ),
                                                    tooltip: "Copy Link",
                                                    onPressed: () {
                                                      Clipboard.setData(
                                                        ClipboardData(text: url),
                                                      );
                                                      ScaffoldMessenger.of(context)
                                                          .showSnackBar(
                                                        const SnackBar(
                                                          content: Text(
                                                            "Source link copied!",
                                                          ),
                                                          duration: Duration(
                                                              seconds: 1),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(
                                                      Icons.open_in_new_rounded,
                                                      size: 16,
                                                      color:
                                                          AppTheme.primaryColor,
                                                    ),
                                                    tooltip:
                                                        "Open Source in Browser",
                                                    onPressed: () =>
                                                        _launchURL(context, url),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],

                            const SizedBox(height: 24),

                            // Recommendation Card
                            GlassCard(
                              color: AppTheme.primaryColor.withOpacity(0.05),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.shield_outlined,
                                    color: AppTheme.accentColor,
                                    size: 40,
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Safety Recommendation",
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(
                                                color: AppTheme.accentColor,
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          resultData['recommendation'] ?? '',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodyMedium,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 32),
                            Wrap(
                              spacing: 16,
                              runSpacing: 16,
                              alignment: WrapAlignment.center,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () {
                                    final summaryText =
                                        "TrustGuard Analysis\nStatus: $status\nTrust Score: $trustScore%\nReason: $explanation";
                                    Clipboard.setData(
                                      ClipboardData(text: summaryText),
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Analysis summary copied to clipboard! 📋",
                                        ),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.copy_rounded, size: 18),
                                  label: const Text("Copy Summary"),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 18,
                                    ),
                                    backgroundColor: AppTheme.primaryColor
                                        .withOpacity(0.15),
                                    foregroundColor: AppTheme.primaryColor,
                                    side: BorderSide(
                                      color: AppTheme.primaryColor
                                          .withOpacity(0.4),
                                    ),
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  icon: const Icon(Icons.refresh_rounded, size: 18),
                                  label: const Text("Analyze Another"),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 28,
                                      vertical: 18,
                                    ),
                                    backgroundColor: Colors.white10,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

