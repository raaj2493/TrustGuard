import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:trust_guard/main.dart';
import 'package:trust_guard/screens/detection_page.dart';
import 'package:trust_guard/screens/result_page.dart';

void main() {
  testWidgets('Landing page renders TrustGuard branding', (WidgetTester tester) async {
    await tester.pumpWidget(const TrustGuardApp());

    expect(find.text('TrustGuard'), findsOneWidget);
    expect(find.text('Check Now'), findsOneWidget);
    expect(find.text('View History'), findsOneWidget);
    expect(find.text('AI-Powered Threat Detection'), findsOneWidget);
  });

  testWidgets('Landing page shows stats section', (WidgetTester tester) async {
    await tester.pumpWidget(const TrustGuardApp());

    expect(find.text('99.2%'), findsOneWidget);
    expect(find.text('Detection Rate'), findsOneWidget);
    expect(find.text('50K+'), findsOneWidget);
  });

  testWidgets('Landing page shows features section', (WidgetTester tester) async {
    await tester.pumpWidget(const TrustGuardApp());

    expect(find.text('Why TrustGuard?'), findsOneWidget);
    expect(find.text('AI-Powered Analysis'), findsOneWidget);
    expect(find.text('Instant Results'), findsOneWidget);
    expect(find.text('Phishing Detection'), findsOneWidget);
    expect(find.text('Privacy First'), findsOneWidget);
    expect(find.text('Detailed Reports'), findsOneWidget);
  });

  testWidgets('Detection page renders Text and URL tabs with samples', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: DetectionPage()));

    expect(find.text('Analyze Content'), findsOneWidget);
    expect(find.text('Text'), findsOneWidget);
    expect(find.text('URL'), findsOneWidget);
    expect(find.text('ANALYZE TEXT'), findsOneWidget);

    // Switch to URL tab
    await tester.tap(find.text('URL'));
    await tester.pumpAndSettle();

    expect(find.text('Enter Web Article or News Link'), findsOneWidget);
    expect(find.text('ANALYZE URL'), findsOneWidget);
    expect(find.text('🌐 Wikipedia: Earth'), findsOneWidget);
    expect(find.text('🔭 NASA Official'), findsOneWidget);
  });

  testWidgets('Result page renders Grounding Sources & Fact Checks card', (WidgetTester tester) async {
    final mockResultData = {
      "score": 92.0,
      "status": "Verified / Real",
      "explanation": "Factually verified through official research papers and scientific consensus.",
      "original_text": "Scientists discover new water ice deposits on asteroid surfaces.",
      "scraped_title": "NASA Asteroid Discovery",
      "scraped_url": "https://nasa.gov/news/asteroid",
      "metrics": {
        "trust_score": 92,
        "toxicity": 0,
        "spam": 0,
        "clickbait": 5,
      },
      "flagged_sentences": <Map<String, dynamic>>[],
      "search_queries": ["NASA asteroid water ice discovery", "planetary formation ice"],
      "sources": [
        {"title": "nasa.gov", "url": "https://nasa.gov/news/asteroid"},
        {"title": "nature.com", "url": "https://nature.com/articles/asteroid-ice"},
      ],
      "recommendation": "This information appears to be reliable based on live fact-checking.",
      "details": [
        {"icon": Icons.analytics, "text": "AI Confidence: 95%"},
      ],
    };

    await tester.pumpWidget(MaterialApp(home: ResultPage(resultData: mockResultData)));

    expect(find.text('VERIFIED / REAL'), findsOneWidget);
    expect(find.text('Analyzed Web Article'), findsOneWidget);
    expect(find.text('NASA Asteroid Discovery'), findsOneWidget);
    expect(find.text('Live Web Grounding & Fact Checks'), findsOneWidget);
    expect(find.text('NASA asteroid water ice discovery'), findsOneWidget);
    expect(find.text('nasa.gov'), findsOneWidget);
    expect(find.text('nature.com'), findsOneWidget);
  });
}
