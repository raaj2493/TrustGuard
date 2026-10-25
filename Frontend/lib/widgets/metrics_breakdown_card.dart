// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:trust_guard/widgets/glass_card.dart';
import 'package:trust_guard/utils/app_theme.dart';

class MetricsBreakdownCard extends StatelessWidget {
  final int trustScore;
  final int toxicity;
  final int spam;
  final int clickbait;

  const MetricsBreakdownCard({
    super.key,
    required this.trustScore,
    required this.toxicity,
    required this.spam,
    required this.clickbait,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bar_chart_rounded, color: AppTheme.primaryColor),
              const SizedBox(width: 10),
              Text(
                "Safety & Risk Breakdown",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildMetricRow(
            context: context,
            label: "Trust Score",
            value: trustScore,
            icon: Icons.verified_user_outlined,
            activeColor: trustScore >= 70
                ? AppTheme.accentColor
                : (trustScore >= 40
                    ? AppTheme.warningColor
                    : AppTheme.dangerColor),
            invertRisk: false,
          ),
          const SizedBox(height: 16),
          _buildMetricRow(
            context: context,
            label: "Toxicity Level",
            value: toxicity,
            icon: Icons.warning_amber_rounded,
            activeColor: toxicity > 50
                ? AppTheme.dangerColor
                : (toxicity > 20
                    ? AppTheme.warningColor
                    : AppTheme.accentColor),
            invertRisk: true,
          ),
          const SizedBox(height: 16),
          _buildMetricRow(
            context: context,
            label: "Spam Probability",
            value: spam,
            icon: Icons.mark_email_unread_outlined,
            activeColor: spam > 50
                ? AppTheme.dangerColor
                : (spam > 20 ? AppTheme.warningColor : AppTheme.accentColor),
            invertRisk: true,
          ),
          const SizedBox(height: 16),
          _buildMetricRow(
            context: context,
            label: "Clickbait Index",
            value: clickbait,
            icon: Icons.ads_click_rounded,
            activeColor: clickbait > 50
                ? AppTheme.dangerColor
                : (clickbait > 25
                    ? AppTheme.warningColor
                    : AppTheme.accentColor),
            invertRisk: true,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow({
    required BuildContext context,
    required String label,
    required int value,
    required IconData icon,
    required Color activeColor,
    required bool invertRisk,
  }) {
    final double percentage = (value.clamp(0, 100)) / 100.0;

    String ratingText;
    if (invertRisk) {
      if (value < 20) {
        ratingText = "LOW";
      } else if (value < 55) {
        ratingText = "MODERATE";
      } else {
        ratingText = "HIGH";
      }
    } else {
      if (value >= 80) {
        ratingText = "HIGH";
      } else if (value >= 50) {
        ratingText = "MODERATE";
      } else {
        ratingText = "LOW";
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: Colors.white70),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: activeColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: activeColor.withOpacity(0.4)),
                  ),
                  child: Text(
                    ratingText,
                    style: TextStyle(
                      color: activeColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "$value%",
                  style: TextStyle(
                    color: activeColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: percentage,
            minHeight: 8,
            backgroundColor: Colors.white.withOpacity(0.08),
            valueColor: AlwaysStoppedAnimation<Color>(activeColor),
          ),
        ),
      ],
    );
  }
}
