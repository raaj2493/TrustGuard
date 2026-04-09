import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../models/analysis.dart';

// ─── Shield SVG icon ────────────────────────────────────────────────────────
class ShieldIcon extends StatelessWidget {
  final double size;
  final Color color;
  const ShieldIcon({super.key, this.size = 24, this.color = AppColors.primary});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _ShieldPainter(color: color)),
    );
  }
}

class _ShieldPainter extends CustomPainter {
  final Color color;
  _ShieldPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.08
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    final w = size.width;
    final h = size.height;
    path.moveTo(w * 0.5, h * 0.04);
    path.lineTo(w * 0.92, h * 0.22);
    path.lineTo(w * 0.92, h * 0.52);
    path.quadraticBezierTo(w * 0.92, h * 0.82, w * 0.5, h * 0.97);
    path.quadraticBezierTo(w * 0.08, h * 0.82, w * 0.08, h * 0.52);
    path.lineTo(w * 0.08, h * 0.22);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── Logo ────────────────────────────────────────────────────────────────────
class TrustGuardLogo extends StatelessWidget {
  final double iconSize;
  final double fontSize;
  const TrustGuardLogo({super.key, this.iconSize = 28, this.fontSize = 20});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ShieldIcon(size: iconSize),
        const SizedBox(width: 8),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Trust',
                style: GoogleFonts.inter(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              TextSpan(
                text: 'Guard',
                style: GoogleFonts.inter(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Navbar ──────────────────────────────────────────────────────────────────
class TrustGuardNavbar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabChanged;

  const TrustGuardNavbar({
    super.key,
    required this.currentIndex,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    final tabs = ['Home', 'Detect', 'History'];
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: Color(0xFF0D0D0D),
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => onTabChanged(0),
              child: const TrustGuardLogo(),
            ),
          ),
          const Spacer(),
          Row(
            children: List.generate(tabs.length, (i) {
              final active = i == currentIndex;
              return MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => onTabChanged(i),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    decoration: active
                        ? const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: AppColors.primary,
                                width: 2,
                              ),
                            ),
                          )
                        : null,
                    child: Text(
                      tabs[i],
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color:
                            active ? AppColors.textPrimary : AppColors.textBody,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(width: 32),
          _CyanButton(
            label: 'Scan Now',
            icon: Icons.shield_outlined,
            onTap: () => onTabChanged(1),
            small: true,
          ),
        ],
      ),
    );
  }
}

// ─── Footer ──────────────────────────────────────────────────────────────────
class TrustGuardFooter extends StatelessWidget {
  final ValueChanged<int> onTabChanged;
  const TrustGuardFooter({super.key, required this.onTabChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 48),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const TrustGuardLogo(iconSize: 24, fontSize: 18),
                    const SizedBox(height: 12),
                    Text(
                      'AI-powered threat detection to protect you from fake news,\nscams, and phishing attempts. Stay safe in the digital world.',
                      style: GoogleFonts.inter(
                          fontSize: 13, color: AppColors.textBody, height: 1.6),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 64),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Product',
                        style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary)),
                    const SizedBox(height: 16),
                    _FooterLink('Scan Content', () => onTabChanged(1)),
                    const SizedBox(height: 8),
                    _FooterLink('Scan History', () => onTabChanged(2)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Connect',
                        style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _SocialIcon(icon: Icons.code, label: 'GitHub'),
                        const SizedBox(width: 12),
                        _SocialIcon(
                            icon: Icons.alternate_email, label: 'Twitter'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          const Divider(color: AppColors.border),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('© 2026 TrustGuard. All rights reserved.',
                  style: GoogleFonts.inter(
                      fontSize: 12, color: AppColors.textMuted)),
              Text('Powered by AI · Built for Safety',
                  style: GoogleFonts.inter(
                      fontSize: 12, color: AppColors.textMuted)),
            ],
          ),
        ],
      ),
    );
  }
}

Widget _FooterLink(String label, VoidCallback onTap) => MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Text(label,
            style: GoogleFonts.inter(fontSize: 13, color: AppColors.textBody)),
      ),
    );

class _SocialIcon extends StatefulWidget {
  final IconData icon;
  final String label;
  const _SocialIcon({required this.icon, required this.label});

  @override
  State<_SocialIcon> createState() => _SocialIconState();
}

class _SocialIconState extends State<_SocialIcon> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _hovered ? AppColors.border : Colors.transparent,
          border: Border.all(
              color: _hovered ? AppColors.borderHover : AppColors.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(widget.icon, size: 16, color: AppColors.textBody),
      ),
    );
  }
}

// ─── Buttons ─────────────────────────────────────────────────────────────────
class _CyanButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onTap;
  final bool small;

  const _CyanButton(
      {required this.label,
      this.icon,
      required this.onTap,
      this.small = false});

  @override
  State<_CyanButton> createState() => _CyanButtonState();
}

class _CyanButtonState extends State<_CyanButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
            horizontal: widget.small ? 16 : 24,
            vertical: widget.small ? 10 : 14,
          ),
          decoration: BoxDecoration(
            color: _hovered ? const Color(0xFF00BFEE) : AppColors.primary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon,
                    size: widget.small ? 14 : 18, color: AppColors.bg),
                SizedBox(width: widget.small ? 6 : 8),
              ],
              Text(
                widget.label,
                style: GoogleFonts.inter(
                  fontSize: widget.small ? 13 : 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.bg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CyanButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onTap;
  final bool small;
  final bool loading;

  const CyanButton({
    super.key,
    required this.label,
    this.icon,
    required this.onTap,
    this.small = false,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: small ? 16 : 24,
          vertical: small ? 10 : 14,
        ),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.7),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.bg,
              ),
            ),
            const SizedBox(width: 8),
            Text('Analyzing...',
                style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.bg)),
          ],
        ),
      );
    }
    return _CyanButton(label: label, icon: icon, onTap: onTap, small: small);
  }
}

class GhostButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const GhostButton({super.key, required this.label, required this.onTap});

  @override
  State<GhostButton> createState() => _GhostButtonState();
}

class _GhostButtonState extends State<GhostButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: BoxDecoration(
            color:
                _hovered ? Colors.white.withOpacity(0.05) : Colors.transparent,
            border: Border.all(color: Colors.white.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            widget.label,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Analysis Badges ─────────────────────────────────────────────────────────
class ToxicityBadge extends StatelessWidget {
  final String toxicity;
  const ToxicityBadge({super.key, required this.toxicity});

  @override
  Widget build(BuildContext context) {
    Color bg, text;
    String label;
    switch (toxicity.toLowerCase()) {
      case 'high':
        bg = AppColors.dangerBg;
        text = AppColors.danger;
        label = 'High Risk';
        break;
      case 'medium':
        bg = AppColors.warningBg;
        text = AppColors.warning;
        label = 'Medium Risk';
        break;
      default:
        bg = AppColors.successBg;
        text = AppColors.success;
        label = 'Low Risk';
    }
    return _Badge(bg: bg, text: text, label: label);
  }
}

class SpamBadge extends StatelessWidget {
  final bool spam;
  const SpamBadge({super.key, required this.spam});

  @override
  Widget build(BuildContext context) {
    return _Badge(
      bg: spam ? AppColors.dangerBg : AppColors.successBg,
      text: spam ? AppColors.danger : AppColors.success,
      label: spam ? 'Spam Detected' : 'Not Spam',
    );
  }
}

class _Badge extends StatelessWidget {
  final Color bg, text;
  final String label;
  const _Badge({required this.bg, required this.text, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: text.withOpacity(0.3)),
      ),
      child: Text(label,
          style: GoogleFonts.inter(
              fontSize: 12, fontWeight: FontWeight.w600, color: text)),
    );
  }
}

// ─── Trust Score Bar ─────────────────────────────────────────────────────────
class TrustScoreBar extends StatefulWidget {
  final double score;
  const TrustScoreBar({super.key, required this.score});

  @override
  State<TrustScoreBar> createState() => _TrustScoreBarState();
}

class _TrustScoreBarState extends State<TrustScoreBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _animation = Tween<double>(begin: 0, end: widget.score)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _barColor {
    if (widget.score >= 0.7) return AppColors.success;
    if (widget.score >= 0.4) return AppColors.warning;
    return AppColors.danger;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Trust Score',
                style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textBody)),
            AnimatedBuilder(
              animation: _animation,
              builder: (_, __) => Text(
                _animation.value.toStringAsFixed(2),
                style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _barColor),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: AppColors.border,
            borderRadius: BorderRadius.circular(4),
          ),
          child: AnimatedBuilder(
            animation: _animation,
            builder: (_, __) => FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: _animation.value,
              child: Container(
                decoration: BoxDecoration(
                  color: _barColor,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(color: _barColor.withOpacity(0.4), blurRadius: 6)
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Shared Card ─────────────────────────────────────────────────────────────
class TGCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;

  const TGCard({super.key, required this.child, this.padding, this.onTap});

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: padding ?? const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
    if (onTap != null) {
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(onTap: onTap, child: card),
      );
    }
    return card;
  }
}

// ─── Icon Box ────────────────────────────────────────────────────────────────
class IconBox extends StatelessWidget {
  final IconData icon;
  const IconBox({super.key, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Icon(icon, color: AppColors.primary, size: 22),
    );
  }
}

// ─── Page Scaffold ────────────────────────────────────────────────────────────
class TGPageScaffold extends StatelessWidget {
  final int currentTab;
  final ValueChanged<int> onTabChanged;
  final Widget body;
  final bool scrollable;

  const TGPageScaffold({
    super.key,
    required this.currentTab,
    required this.onTabChanged,
    required this.body,
    this.scrollable = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TrustGuardNavbar(currentIndex: currentTab, onTabChanged: onTabChanged),
        Expanded(
          child: scrollable
              ? SingleChildScrollView(
                  child: Column(
                    children: [
                      body,
                      TrustGuardFooter(onTabChanged: onTabChanged),
                    ],
                  ),
                )
              : body,
        ),
      ],
    );
  }
}
