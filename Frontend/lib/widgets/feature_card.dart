import 'package:flutter/material.dart';
import 'package:trust_guard/widgets/glass_card.dart';
import 'package:trust_guard/utils/app_theme.dart';

class FeatureCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String description;

  const FeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  State<FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<FeatureCard>
    with SingleTickerProviderStateMixin {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()..translate(0, isHovered ? -10.0 : 0.0),
        child: GlassCard(
          color: isHovered ? AppTheme.darkSurface.withOpacity(0.8) : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  widget.icon,
                  color: AppTheme.primaryColor,
                  size: 30,
                ),
              ),
              const SizedBox(height: 20),
              Text(widget.title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 10),
              Text(
                widget.description,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
