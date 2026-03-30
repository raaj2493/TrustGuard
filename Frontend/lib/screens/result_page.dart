// ignore_for_file: deprecated_member_use, curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:trust_guard/widgets/custom_navbar.dart';
import 'package:trust_guard/widgets/glass_card.dart';
import 'package:trust_guard/widgets/trust_meter.dart';
import 'package:trust_guard/utils/app_theme.dart';

class ResultPage extends StatelessWidget {
  final Map<String, dynamic> resultData;

  const ResultPage({super.key, required this.resultData});

  @override
  Widget build(BuildContext context) {
    final double score = resultData['score'];
    final String status = resultData['status'];
    final String explanation = resultData['explanation'];
    final List<Map<String, dynamic>> details = resultData['details'];

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
                    (score > 50 ? AppTheme.warningColor : AppTheme.dangerColor)
                        .withOpacity(0.1),
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
                    if (index == 0)
                      Navigator.popUntil(context, (route) => route.isFirst);
                    // Simple nav logic for now
                  },
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // Meter Section
                        TrustMeter(score: score),

                        const SizedBox(height: 20),
                        Text(
                          status.toUpperCase(),
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                color: score >= 80
                                    ? AppTheme.accentColor
                                    : (score >= 50
                                          ? AppTheme.warningColor
                                          : AppTheme.dangerColor),
                                letterSpacing: 2,
                              ),
                        ),

                        const SizedBox(height: 40),

                        // Explanation Card
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 800),
                          child: GlassCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.analytics,
                                      color: AppTheme.primaryColor,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      "AI Analysis",
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleLarge,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  explanation,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodyLarge?.copyWith(height: 1.6),
                                ),
                                const SizedBox(height: 24),

                                // Risk Factors
                                Text(
                                  "Risk Factors",
                                  style: Theme.of(context).textTheme.titleMedium
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
                                        borderRadius: BorderRadius.circular(10),
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
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Recommendation Card
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 800),
                          child: GlassCard(
                            color: AppTheme.primaryColor.withOpacity(0.05),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.shield,
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
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        resultData['recommendation'],
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
                        ),

                        const SizedBox(height: 40),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context); // Go back to detection
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text("Analyze Another"),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 20,
                            ),
                            backgroundColor: Colors.white10,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
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
