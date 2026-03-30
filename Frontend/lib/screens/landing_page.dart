// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:trust_guard/screens/detection_page.dart';
import 'package:trust_guard/screens/history_page.dart';
import 'package:trust_guard/widgets/custom_navbar.dart';
import 'package:trust_guard/utils/app_theme.dart';
import 'dart:math' as math;

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutQuart));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              "assets/background.png",
              fit: BoxFit.cover,
              color: const Color(
                0xFF000000,
              ).withValues(alpha: 0.7), // Dark overlay
              colorBlendMode: BlendMode.darken,
            ),
          ),

          // Main Content

          // Main Content
          SingleChildScrollView(
            child: Column(
              children: [
                CustomNavbar(
                  currentIndex: 0,
                  onNavigate: (index) {
                    if (index == 1) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DetectionPage(),
                        ),
                      );
                    } else if (index == 2) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const HistoryPage()),
                      );
                    }
                  },
                ),

                const SizedBox(height: 80),

                // Hero Section
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          // Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: AppTheme.primaryColor.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.auto_awesome,
                                  color: AppTheme.primaryColor,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "AI-Powered Threat Detection",
                                  style: TextStyle(
                                    color: AppTheme.primaryColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Title
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: Theme.of(context).textTheme.displayLarge
                                  ?.copyWith(
                                    fontSize: 64,
                                    height: 1.1,
                                    letterSpacing: -1.5,
                                  ),
                              children: [
                                const TextSpan(text: "Detect "),
                                TextSpan(
                                  text: "Scams & Fakes",
                                  style: TextStyle(
                                    color: Colors.transparent,
                                    shadows: [
                                      Shadow(
                                        offset: const Offset(0, 0),
                                        blurRadius: 20,
                                        color: AppTheme.primaryColor
                                            .withOpacity(0.5),
                                      ),
                                    ],
                                    decoration: TextDecoration.none,
                                    // Gradient text hack
                                    background: Paint()
                                      ..color = AppTheme.primaryColor
                                      ..shader =
                                          const LinearGradient(
                                            colors: [
                                              AppTheme.primaryColor,
                                              AppTheme.accentColor,
                                            ],
                                          ).createShader(
                                            const Rect.fromLTWH(0, 0, 400, 100),
                                          ),
                                  ),
                                ),
                                const TextSpan(text: "\nBefore They Strike"),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Subtitle
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 700),
                            child: Text(
                              "Paste any text, URL, or message and let our AI instantly analyze it for phishing, misinformation, and scam patterns. Get a clear trust score in seconds.",
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                    fontSize: 18,
                                    color: Colors.white60,
                                    height: 1.6,
                                  ),
                            ),
                          ),

                          const SizedBox(height: 48),

                          // CTA Buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const DetectionPage(),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryColor,
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 32,
                                    vertical: 24,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  textStyle: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.shield_outlined, size: 20),
                                    const SizedBox(width: 8),
                                    const Text("Check Now"),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.arrow_forward, size: 16),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 20),
                              OutlinedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const HistoryPage(),
                                    ),
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  side: BorderSide(
                                    color: Colors.white.withOpacity(0.2),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 32,
                                    vertical: 24,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  textStyle: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                child: const Text("View History"),
                              ),
                            ],
                          ),

                          const SizedBox(height: 80),

                          // Stats
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 40,
                            runSpacing: 20,
                            children: [
                              _buildStatItem(
                                context,
                                "99.2%",
                                "Detection Rate",
                              ),
                              if (MediaQuery.of(context).size.width > 600)
                                _buildStatDivider(),
                              _buildStatItem(context, "<3s", "Scan Speed"),
                              if (MediaQuery.of(context).size.width > 600)
                                _buildStatDivider(),
                              _buildStatItem(
                                context,
                                "50K+",
                                "Scans Protected",
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 120),

                // Features Section
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    children: [
                      Text(
                        "Why TrustGuard?",
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Enterprise-grade AI threat detection, accessible to everyone.",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 60),

                      LayoutBuilder(
                        builder: (context, constraints) {
                          // Grid logic
                          double cardWidth = 350;
                          int crossAxisCount =
                              (constraints.maxWidth / cardWidth).floor();
                          crossAxisCount = math.max(
                            1,
                            math.min(3, crossAxisCount),
                          );

                          return Wrap(
                            spacing: 24,
                            runSpacing: 24,
                            alignment: WrapAlignment.center,
                            children: [
                              _buildFeatureCard(
                                context,
                                Icons.psychology,
                                "AI-Powered Analysis",
                                "Advanced machine learning models trained on millions of data points to detect threats with precision.",
                                width: (constraints.maxWidth > 800)
                                    ? (constraints.maxWidth - 100) / 3
                                    : 350,
                              ),
                              _buildFeatureCard(
                                context,
                                Icons.flash_on,
                                "Instant Results",
                                "Get your trust score and detailed analysis in under 3 seconds with real-time processing.",
                                width: (constraints.maxWidth > 800)
                                    ? (constraints.maxWidth - 100) / 3
                                    : 350,
                              ),
                              _buildFeatureCard(
                                context,
                                Icons.verified_user_outlined,
                                "Phishing Detection",
                                "Identifies social engineering tactics, fake login pages, and credential harvesting attempts.",
                                width: (constraints.maxWidth > 800)
                                    ? (constraints.maxWidth - 100) / 3
                                    : 350,
                              ),
                              _buildFeatureCard(
                                context,
                                Icons.lock_outline,
                                "Privacy First",
                                "Your data is never stored or shared. All analysis happens securely with zero data retention.",
                                width: (constraints.maxWidth > 800)
                                    ? (constraints.maxWidth - 100) / 3
                                    : 350,
                              ),
                              _buildFeatureCard(
                                context,
                                Icons.bar_chart,
                                "Detailed Reports",
                                "Comprehensive breakdown with risk indicators, evidence, and actionable safety recommendations.",
                                width: (constraints.maxWidth > 800)
                                    ? (constraints.maxWidth - 100) / 3
                                    : 350,
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 120),

                // Footer
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 60,
                  ),
                  color: const Color(0xFF05070B),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1200),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Brand
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.shield_outlined,
                                          color: AppTheme.primaryColor,
                                          size: 24,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          "TrustGuard",
                                          style: Theme.of(
                                            context,
                                          ).textTheme.titleLarge,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      "AI-powered threat detection to protect you from fake news, scams, and phishing attempts. Stay safe in the digital world.",
                                      style: TextStyle(
                                        color: Colors.white54,
                                        height: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 80),
                              // Links
                              if (MediaQuery.of(context).size.width > 600)
                                Row(
                                  children: [
                                    _buildFooterColumn("Product", [
                                      "Scan Content",
                                      "Scan History",
                                    ]),
                                    const SizedBox(width: 40),
                                    _buildFooterColumn("Connect", [
                                      "GitHub",
                                      "Twitter",
                                    ]),
                                  ],
                                ),
                            ],
                          ),
                          const SizedBox(height: 60),
                          const Divider(color: Colors.white10),
                          const SizedBox(height: 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "© 2026 TrustGuard. All rights reserved.",
                                style: TextStyle(
                                  color: Colors.white30,
                                  fontSize: 12,
                                ),
                              ),
                              const Text(
                                "Powered by AI • Built for Safety",
                                style: TextStyle(
                                  color: Colors.white30,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
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

  Widget _buildStatItem(BuildContext context, String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.white10,
      margin: const EdgeInsets.symmetric(horizontal: 40),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    IconData icon,
    String title,
    String desc, {
    double width = 350,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF0F121A), // Dark card bg
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.primaryColor, size: 24),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            desc,
            style: const TextStyle(color: Colors.white60, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterColumn(String title, List<String> links) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        ...links.map(
          (l) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              l,
              style: const TextStyle(color: Colors.white54, fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..strokeWidth = 1;

    // Draw vertical lines
    for (double i = 0; i < size.width; i += 60) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    // Draw horizontal lines
    for (double i = 0; i < size.height; i += 60) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
