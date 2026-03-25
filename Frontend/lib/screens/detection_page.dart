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
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _analyze() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    // Dummy Result Data
    final result = {
      "score": 45.0, // Example Suspicious
      "status": "Suspicious",
      "explanation":
          "The text contains patterns often associated with phishing attempts. The urgency in the language 'Act Now' is a common indicator.",
      "recommendation":
          "Do not click any links provided in the message. verify the sender's identity independently.",
      "details": [
        {"icon": Icons.warning, "text": "Urgency Detected"},
        {"icon": Icons.link_off, "text": "Unverified Link"},
        {"icon": Icons.history, "text": "Similar Scam Reported"},
      ],
    };

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ResultPage(resultData: result)),
    );
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
                              "Paste text, URL, or upload an image to check for safety.",
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 40),

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
                                    height: 300,
                                    padding: const EdgeInsets.all(24),
                                    child: TabBarView(
                                      controller: _tabController,
                                      children: [
                                        // Text Input
                                        TextField(
                                          controller: _textController,
                                          maxLines: 10,
                                          decoration: InputDecoration(
                                            hintText:
                                                "Paste the message or article text here...",
                                            hintStyle: TextStyle(
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
                                        // URL Input
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            TextField(
                                              decoration: InputDecoration(
                                                prefixIcon: const Icon(
                                                  Icons.link,
                                                  color: Colors.white54,
                                                ),
                                                hintText: "https://example.com",
                                                hintStyle: TextStyle(
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
                                      : const Text(
                                          "ANALYZE",
                                          style: TextStyle(
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
}
