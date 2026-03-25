import 'package:flutter/material.dart';
import 'package:trust_guard/utils/app_theme.dart';
import 'package:trust_guard/screens/landing_page.dart';

void main() {
  runApp(const TrustGuardApp());
}

class TrustGuardApp extends StatelessWidget {
  const TrustGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TrustGuard',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark, // Default to dark for that Cyberpunk feel
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        physics: const BouncingScrollPhysics(),
        scrollbars: false,
      ),
      home: const LandingPage(),
    );
  }
}
