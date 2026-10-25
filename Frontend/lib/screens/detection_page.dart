// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:trust_guard/screens/result_page.dart';
import 'package:trust_guard/screens/history_page.dart';
import 'package:trust_guard/widgets/custom_navbar.dart';
import 'package:trust_guard/widgets/glass_card.dart';
import 'package:trust_guard/utils/app_theme.dart';

class DetectionPage extends StatefulWidget {
  const DetectionPage({super.key});

  @override
  State<DetectionPage> createState() => _DetectionPageState();
}

class _DetectionPageState extends State<DetectionPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _textController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _analyze() async {
    final bool isUrlTab = _tabController.index == 1;

    String endpoint = 'http://localhost:8081/analyze';
    Map<String, dynamic> requestBody = {};
    String inputText = '';

    if (isUrlTab) {
      String url = _urlController.text.trim();
      if (url.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a website or article URL to analyze'),
          ),
        );
        return;
      }
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        url = 'https://$url';
        _urlController.text = url;
      }
      endpoint = 'http://localhost:8081/analyze-url';
      requestBody = {'url': url};
      inputText = url;
    } else {
      inputText = _textController.text.trim();
      if (inputText.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter some text to analyze')),
        );
        return;
      }
      requestBody = {'text': inputText};
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final metrics = data['metrics'] ?? {};

        final result = {
          "score": (metrics['trust_score'] ?? data['confidence'] ?? 0).toDouble(),
          "status": data['prediction'] ?? "Unknown",
          "explanation": data['reason'] ?? "No reason provided.",
          "original_text": isUrlTab ? (data['scraped_title'] ?? inputText) : inputText,
          "metrics": metrics,
          "flagged_sentences": data['flagged_sentences'] ?? [],
          "sources": data['sources'] ?? [],
          "search_queries": data['search_queries'] ?? [],
          "scraped_title": data['scraped_title'],
          "scraped_url": data['scraped_url'],
          "recommendation":
              data['prediction'] == "Dangerous Scam" ||
                      data['prediction'] == "Fake News / Misinformation" ||
                      data['prediction'] == "Fake News"
                  ? "Do not trust this information. Verify independently with official primary sources."
                  : (data['prediction'] == "Common Myth / Misconception"
                      ? "This statement is a widespread myth or urban legend. While not dangerous, it is factually inaccurate."
                      : "This information appears to be reliable based on live fact-checking and AI analysis."),
          "details": [
            {
              "icon": Icons.analytics,
              "text": "AI Confidence: ${data['confidence']}%",
            },
            {
              "icon":
                  data['prediction'] == "Fake News" ||
                          data['prediction'] == "Fake News / Misinformation"
                      ? Icons.warning
                      : Icons.check_circle,
              "text": data['prediction'],
            },
          ],
        };

        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ResultPage(resultData: result)),
        );
      } else {
        String errorMsg = 'Server error (${response.statusCode})';
        try {
          final errBody = jsonDecode(response.body);
          if (errBody['error'] != null) errorMsg = errBody['error'];
        } catch (_) {}
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $errorMsg')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error connecting to backend: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Elements (Reuse from Landing for consistency)
          Positioned(
            top: -150,
            left: -150,
            child: Container(
              width: 600,
              height: 600,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryColor.withOpacity(0.05),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 150,
                    spreadRadius: 20,
                    color: AppTheme.primaryColor.withOpacity(0.05),
                  ),
                ],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                CustomNavbar(
                  currentIndex: 1,
                  onNavigate: (index) {
                    if (index == 0) {
                      Navigator.popUntil(context, (route) => route.isFirst);
                    } else if (index == 2) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const HistoryPage()),
                      );
                    }
                  },
                ),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              "Analyze Content",
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.displaySmall,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "Paste text, URL, or select a sample claim to check for safety.",
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 30),

                            // Quick Try Examples
                            Row(
                              children: [
                                const Icon(
                                  Icons.lightbulb_outline_rounded,
                                  size: 16,
                                  color: AppTheme.primaryColor,
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  "Try a sample:",
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _buildSampleChip(
                                  "🏛️ Great Wall myth",
                                  "The Great Wall of China is visible from space with the naked eye.",
                                ),
                                _buildSampleChip(
                                  "🍋 Miracle Cure claim",
                                  "SHOCKING DISCOVERY! Drinking lemon water at midnight eliminates all diseases instantly!",
                                ),
                                _buildSampleChip(
                                  "⚠️ Bank Scam alert",
                                  "URGENT: Your bank account access has been suspended due to suspicious activity. Click http://secure-bank-login.xyz to verify immediately.",
                                ),
                                _buildSampleChip(
                                  "🔭 Verified News",
                                  "NASA scientists have published new observations from the James Webb Space Telescope revealing distant galaxy formations.",
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // Input Card
                            GlassCard(
                              padding: const EdgeInsets.all(0),
                              child: Column(
                                children: [
                                  // Tabs
                                  TabBar(
                                    controller: _tabController,
                                    labelColor: AppTheme.primaryColor,
                                    unselectedLabelColor: Colors.white60,
                                    indicatorColor: AppTheme.primaryColor,
                                    dividerColor: Colors.transparent,
                                    tabs: const [
                                      Tab(
                                        text: "Text",
                                        icon: Icon(Icons.text_fields),
                                      ),
                                      Tab(text: "URL", icon: Icon(Icons.link)),
                                      Tab(
                                        text: "Image",
                                        icon: Icon(Icons.image),
                                      ),
                                    ],
                                  ),

                                  // Content
                                  Container(
                                    height: 320,
                                    padding: const EdgeInsets.all(20),
                                    child: TabBarView(
                                      controller: _tabController,
                                      children: [
                                        // Text Input Column
                                        Column(
                                          children: [
                                            Expanded(
                                              child: Stack(
                                                children: [
                                                  TextField(
                                                    controller: _textController,
                                                    maxLines: 10,
                                                    onChanged: (_) => setState(() {}),
                                                    decoration: InputDecoration(
                                                      hintText:
                                                          "Paste the message, claim, or article text here to analyze...",
                                                      hintStyle: const TextStyle(
                                                        color: Colors.white30,
                                                      ),
                                                      border: OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(12),
                                                        borderSide: BorderSide.none,
                                                      ),
                                                      filled: true,
                                                      fillColor: Colors.black12,
                                                    ),
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  if (_textController.text.isNotEmpty)
                                                    Positioned(
                                                      top: 8,
                                                      right: 8,
                                                      child: IconButton(
                                                        icon: const Icon(
                                                          Icons.close,
                                                          size: 18,
                                                          color: Colors.white54,
                                                        ),
                                                        onPressed: () {
                                                          setState(() {
                                                            _textController.clear();
                                                          });
                                                        },
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceBetween,
                                              children: [
                                                const Expanded(
                                                  child: Text(
                                                    "Supports plain text, news clips, or social posts",
                                                    overflow: TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      color: Colors.white38,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  "${_textController.text.length} chars • ${_textController.text.trim().isEmpty ? 0 : _textController.text.trim().split(RegExp(r'\s+')).length} words",
                                                  style: const TextStyle(
                                                    color: Colors.white54,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        // URL Input
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 8),
                                            const Text(
                                              "Enter Web Article or News Link",
                                              style: TextStyle(
                                                color: Colors.white70,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            const Text(
                                              "TrustGuard automatically extracts article body text and fact-checks claims using live Google Search Grounding.",
                                              style: TextStyle(
                                                color: Colors.white38,
                                                fontSize: 12,
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                            TextField(
                                              controller: _urlController,
                                              onChanged: (_) => setState(() {}),
                                              decoration: InputDecoration(
                                                prefixIcon: const Icon(
                                                  Icons.link_rounded,
                                                  color: AppTheme.primaryColor,
                                                ),
                                                suffixIcon: _urlController.text.isNotEmpty
                                                    ? IconButton(
                                                        icon: const Icon(
                                                          Icons.close,
                                                          size: 18,
                                                          color: Colors.white54,
                                                        ),
                                                        onPressed: () {
                                                          setState(() {
                                                            _urlController.clear();
                                                          });
                                                        },
                                                      )
                                                    : null,
                                                hintText: "https://example.com/news-story",
                                                hintStyle: const TextStyle(
                                                  color: Colors.white30,
                                                ),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  borderSide: BorderSide(
                                                    color: AppTheme.primaryColor.withOpacity(0.3),
                                                  ),
                                                ),
                                                enabledBorder: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  borderSide: const BorderSide(
                                                    color: Colors.white12,
                                                  ),
                                                ),
                                                focusedBorder: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  borderSide: const BorderSide(
                                                    color: AppTheme.primaryColor,
                                                  ),
                                                ),
                                                filled: true,
                                                fillColor: Colors.black26,
                                              ),
                                              style: const TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                            const Text(
                                              "Quick test with sample links:",
                                              style: TextStyle(
                                                color: Colors.white54,
                                                fontSize: 12,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Wrap(
                                              spacing: 8,
                                              runSpacing: 8,
                                              children: [
                                                _buildSampleUrlChip(
                                                  "🌐 Wikipedia: Earth",
                                                  "https://en.wikipedia.org/wiki/Earth",
                                                ),
                                                _buildSampleUrlChip(
                                                  "🔭 NASA Official",
                                                  "https://www.nasa.gov",
                                                ),
                                                _buildSampleUrlChip(
                                                  "📰 BBC News",
                                                  "https://www.bbc.com",
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        // Image Input
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.cloud_upload_outlined,
                                              size: 64,
                                              color: Colors.white24,
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              "Drag and drop or click to upload",
                                              style: TextStyle(
                                                color: Colors.white54,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 30),

                            // Analyze Button
                            Center(
                              child: SizedBox(
                                width: 200,
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _analyze,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primaryColor,
                                    foregroundColor: Colors.black,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.black,
                                          ),
                                        )
                                      : Text(
                                          _tabController.index == 1
                                              ? "ANALYZE URL"
                                              : "ANALYZE TEXT",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ],
                        ),
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

  Widget _buildSampleChip(String label, String contentText) {
    return ActionChip(
      label: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: Colors.white.withOpacity(0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: AppTheme.primaryColor.withOpacity(0.3)),
      ),
      onPressed: () {
        setState(() {
          _textController.text = contentText;
        });
      },
    );
  }

  Widget _buildSampleUrlChip(String label, String targetUrl) {
    return ActionChip(
      label: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: Colors.white.withOpacity(0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: AppTheme.primaryColor.withOpacity(0.3)),
      ),
      onPressed: () {
        setState(() {
          _urlController.text = targetUrl;
        });
      },
    );
  }
}
