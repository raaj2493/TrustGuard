import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../widgets/shared.dart';

class HomeScreen extends StatelessWidget {
  final ValueChanged<int> onTabChanged;
  const HomeScreen({super.key, required this.onTabChanged});

  @override
  Widget build(BuildContext context) {
    return TGPageScaffold(
      currentTab: 0,
      onTabChanged: onTabChanged,
      body: Column(
        children: [
          _HeroSection(onTabChanged: onTabChanged),
          _FeaturesSection(),
        ],
      ),
    );
  }
}

// ─── Hero ─────────────────────────────────────────────────────────────────────
class _HeroSection extends StatelessWidget {
  final ValueChanged<int> onTabChanged;
  const _HeroSection({required this.onTabChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 24),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background hooded figure watermark (CSS-like SVG equivalent)
          Positioned.fill(
            child: Center(
              child: Opacity(
                opacity: 0.04,
                child: CustomPaint(
                  size: const Size(400, 450),
                  painter: _HoodedFigurePainter(),
                ),
              ),
            ),
          ),
          // Cyan glow
          Positioned(
            top: -80,
            child: Container(
              width: 600,
              height: 300,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.08),
                    Colors.transparent,
                  ],
                  radius: 0.8,
                ),
              ),
            ),
          ),
          Column(
            children: [
              // Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primary.withOpacity(0.25)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.auto_awesome,
                        size: 14, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text('AI-Powered Threat Detection',
                        style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primary)),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Detect ',
                      style: GoogleFonts.inter(
                          fontSize: 58,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          height: 1.1),
                    ),
                    TextSpan(
                      text: 'Scams & Fakes',
                      style: GoogleFonts.inter(
                          fontSize: 58,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                          height: 1.1),
                    ),
                  ],
                ),
              ),
              Text(
                'Before They Strike',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                    fontSize: 58,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    height: 1.1),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: 520,
                child: Text(
                  'Paste any text, URL, or message and let our AI instantly analyze it for phishing, misinformation, and scam patterns. Get a clear trust score in seconds.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                      fontSize: 16, color: AppColors.textBody, height: 1.6),
                ),
              ),
              const SizedBox(height: 36),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CyanButton(
                    label: 'Check Now →',
                    icon: Icons.shield_outlined,
                    onTap: () => onTabChanged(1),
                  ),
                  const SizedBox(width: 16),
                  GhostButton(
                    label: 'View History',
                    onTap: () => onTabChanged(2),
                  ),
                ],
              ),
              const SizedBox(height: 60),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  _StatItem(value: '99.2%', label: 'Detection Rate'),
                  SizedBox(width: 64),
                  _StatItem(value: '<3s', label: 'Scan Speed'),
                  SizedBox(width: 64),
                  _StatItem(value: '50K+', label: 'Scans Protected'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: GoogleFonts.inter(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: AppColors.primary)),
        const SizedBox(height: 4),
        Text(label,
            style: GoogleFonts.inter(fontSize: 13, color: AppColors.textBody)),
      ],
    );
  }
}

// ─── Features ────────────────────────────────────────────────────────────────
class _FeaturesSection extends StatelessWidget {
  final _features = const [
    _Feature(Icons.psychology_outlined, 'AI-Powered Analysis',
        'Advanced machine learning models trained on millions of data points to detect threats with precision.'),
    _Feature(Icons.bolt_outlined, 'Instant Results',
        'Get your trust score and detailed analysis in under 3 seconds with real-time processing.'),
    _Feature(Icons.radar_outlined, 'Multi-Layer Scanning',
        'Combines heuristic rules, semantic analysis, and pattern matching for maximum accuracy.'),
    _Feature(Icons.shield_outlined, 'Phishing Detection',
        'Identifies social engineering tactics, fake login pages, and credential harvesting attempts.'),
    _Feature(Icons.lock_outline, 'Privacy First',
        'Your data is never stored or shared. All analysis happens securely with zero data retention.'),
    _Feature(Icons.bar_chart_outlined, 'Detailed Reports',
        'Comprehensive breakdown with risk indicators, evidence, and actionable safety recommendations.'),
  ];

  const _FeaturesSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 64),
      child: Column(
        children: [
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Why ',
                  style: GoogleFonts.inter(
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary),
                ),
                TextSpan(
                  text: 'TrustGuard',
                  style: GoogleFonts.inter(
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary),
                ),
                TextSpan(
                  text: '?',
                  style: GoogleFonts.inter(
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Enterprise-grade AI threat detection, accessible to everyone. Six pillars of protection.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 15, color: AppColors.textBody),
          ),
          const SizedBox(height: 48),
          LayoutBuilder(builder: (ctx, constraints) {
            final crossCount = constraints.maxWidth > 900 ? 3 : 2;
            return _FeatureGrid(features: _features, crossCount: crossCount);
          }),
        ],
      ),
    );
  }
}

class _FeatureGrid extends StatelessWidget {
  final List<_Feature> features;
  final int crossCount;
  const _FeatureGrid({required this.features, required this.crossCount});

  @override
  Widget build(BuildContext context) {
    // Build rows manually for responsive grid
    final rows = <Widget>[];
    for (int i = 0; i < features.length; i += crossCount) {
      final rowItems = features.skip(i).take(crossCount).toList();
      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: rowItems.asMap().entries.map((e) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: e.key == 0 ? 0 : 12,
                    right: e.key == rowItems.length - 1 ? 0 : 12,
                  ),
                  child: _FeatureCard(feature: e.value),
                ),
              );
            }).toList(),
          ),
        ),
      );
      if (i + crossCount < features.length) rows.add(const SizedBox(height: 16));
    }
    return Column(children: rows);
  }
}

class _Feature {
  final IconData icon;
  final String title;
  final String desc;
  const _Feature(this.icon, this.title, this.desc);
}

class _FeatureCard extends StatefulWidget {
  final _Feature feature;
  const _FeatureCard({super.key, required this.feature});

  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _hovered ? const Color(0xFF161616) : AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: _hovered ? AppColors.borderHover : AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconBox(icon: widget.feature.icon),
            const SizedBox(height: 16),
            Text(widget.feature.title,
                style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Text(widget.feature.desc,
                style: GoogleFonts.inter(
                    fontSize: 13, color: AppColors.textBody, height: 1.6)),
          ],
        ),
      ),
    );
  }
}

// ─── Hooded figure background painter ────────────────────────────────────────
class _HoodedFigurePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final w = size.width;
    final h = size.height;

    // Shield outline
    final shield = Path();
    shield.moveTo(w * 0.5, h * 0.02);
    shield.lineTo(w * 0.9, h * 0.15);
    shield.lineTo(w * 0.9, h * 0.5);
    shield.quadraticBezierTo(w * 0.9, h * 0.8, w * 0.5, h * 0.95);
    shield.quadraticBezierTo(w * 0.1, h * 0.8, w * 0.1, h * 0.5);
    shield.lineTo(w * 0.1, h * 0.15);
    shield.close();
    canvas.drawPath(shield, paint);

    // Head silhouette
    final head = Path();
    head.addOval(Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.27), width: w * 0.22, height: h * 0.18));
    canvas.drawPath(head, paint);

    // Hood
    final hood = Path();
    hood.moveTo(w * 0.28, h * 0.24);
    hood.quadraticBezierTo(w * 0.3, h * 0.12, w * 0.5, h * 0.1);
    hood.quadraticBezierTo(w * 0.7, h * 0.12, w * 0.72, h * 0.24);
    canvas.drawPath(hood, paint);

    // Body
    final body = Path();
    body.moveTo(w * 0.3, h * 0.36);
    body.quadraticBezierTo(w * 0.25, h * 0.55, w * 0.22, h * 0.7);
    body.lineTo(w * 0.78, h * 0.7);
    body.quadraticBezierTo(w * 0.75, h * 0.55, w * 0.7, h * 0.36);
    canvas.drawPath(body, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
