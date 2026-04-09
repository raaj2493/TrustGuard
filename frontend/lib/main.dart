import 'package:flutter/material.dart';
import 'theme.dart';
import 'screens/home_screen.dart';
import 'screens/detect_screen.dart';
import 'screens/history_screen.dart';

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
      theme: AppTheme.dark,
      home: const TrustGuardShell(),
    );
  }
}

class TrustGuardShell extends StatefulWidget {
  const TrustGuardShell({super.key});

  @override
  State<TrustGuardShell> createState() => _TrustGuardShellState();
}

class _TrustGuardShellState extends State<TrustGuardShell> {
  int _currentTab = 0;

  void _navigate(int index) {
    setState(() => _currentTab = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: IndexedStack(
        index: _currentTab,
        children: [
          HomeScreen(onTabChanged: _navigate),
          DetectScreen(onTabChanged: _navigate),
          HistoryScreen(onTabChanged: _navigate),
        ],
      ),
    );
  }
}
