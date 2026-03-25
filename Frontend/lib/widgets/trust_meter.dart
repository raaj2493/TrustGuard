import 'package:flutter/material.dart';
import 'package:trust_guard/utils/app_theme.dart';

class TrustMeter extends StatelessWidget {
  final double score; // 0 to 100

  const TrustMeter({super.key, required this.score});

  Color _getColor(double score) {
    if (score >= 80) return AppTheme.accentColor; // Safe
    if (score >= 50) return AppTheme.warningColor; // Suspicious
    return AppTheme.dangerColor; // Dangerous
  }

  String _getLabel(double score) {
    if (score >= 80) return "SAFE";
    if (score >= 50) return "SUSPICIOUS";
    return "DANGEROUS";
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: score),
      duration: const Duration(seconds: 2),
      curve: Curves.easeOutQuart,
      builder: (context, value, child) {
        return Column(
          children: [
            SizedBox(
              width: 200,
              height: 200,
              child: Stack(
                children: [
                  // Background Circle
                  Center(
                    child: SizedBox(
                      width: 200,
                      height: 200,
                      child: CircularProgressIndicator(
                        value: 1.0,
                        strokeWidth: 15,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  ),
                  // Progress Circle
                  Center(
                    child: SizedBox(
                      width: 200,
                      height: 200,
                      child: CircularProgressIndicator(
                        value: value / 100,
                        strokeWidth: 15,
                        color: _getColor(value),
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                  ),
                  // Score Text
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "${value.toInt()}",
                          style: Theme.of(context).textTheme.displayMedium
                              ?.copyWith(color: _getColor(value)),
                        ),
                        Text(
                          "Trust Score",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: _getColor(score).withOpacity(0.1),
                border: Border.all(color: _getColor(score)),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _getLabel(score),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: _getColor(score),
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
