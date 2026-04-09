import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../widgets/shared.dart';
import '../models/analysis.dart';
import '../services/api_service.dart';
import '../services/history_service.dart';

class DetectScreen extends StatefulWidget {
  final ValueChanged<int> onTabChanged;
  const DetectScreen({super.key, required this.onTabChanged});

  @override
  State<DetectScreen> createState() => _DetectScreenState();
}

class _DetectScreenState extends State<DetectScreen> {
  final _controller = TextEditingController();
  final _api = ApiService();
  final _history = HistoryService();

  bool _loading = false;
  bool _isUrlTab = false;
  String? _error;
  String? _validationError;
  AnalysisResult? _result;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _analyze() async {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      setState(() => _validationError = 'Please enter some text to analyze');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
      _validationError = null;
      _result = null;
    });

    try {
      final result = await _api.analyze(text);
      await _history.addRecord(ScanRecord(
        text: text,
        analysis: result,
        timestamp: DateTime.now(),
      ));
      setState(() {
        _result = result;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return TGPageScaffold(
      currentTab: 1,
      onTabChanged: widget.onTabChanged,
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 720),
          padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
          child: Column(
            children: [
              // Icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: const Center(child: ShieldIcon(size: 28)),
              ),
              const SizedBox(height: 20),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(children: [
                  TextSpan(
                    text: 'Threat ',
                    style: GoogleFonts.inter(
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary),
                  ),
                  TextSpan(
                    text: 'Detector',
                    style: GoogleFonts.inter(
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary),
                  ),
                ]),
              ),
              const SizedBox(height: 12),
              Text(
                'Paste any text, URL, or message below and our AI will analyze it for potential threats.',
                textAlign: TextAlign.center,
                style:
                    GoogleFonts.inter(fontSize: 15, color: AppColors.textBody),
              ),
              const SizedBox(height: 40),

              // Analysis card
              TGCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tabs
                    Row(
                      children: [
                        _Tab(
                          label: 'Text / Message',
                          icon: Icons.description_outlined,
                          active: !_isUrlTab,
                          onTap: () => setState(() => _isUrlTab = false),
                        ),
                        const SizedBox(width: 8),
                        _Tab(
                          label: 'URL',
                          icon: Icons.link,
                          active: _isUrlTab,
                          onTap: () => setState(() => _isUrlTab = true),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Textarea
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.inputBg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: _validationError != null
                                ? AppColors.danger
                                : AppColors.border),
                      ),
                      child: TextField(
                        controller: _controller,
                        maxLines: 8,
                        style: GoogleFonts.inter(
                            fontSize: 14, color: AppColors.textPrimary),
                        decoration: InputDecoration(
                          hintText: _isUrlTab
                              ? 'Paste a URL to analyze...'
                              : 'Paste any suspicious text, email, or message here...',
                          hintStyle: GoogleFonts.inter(
                              fontSize: 14, color: AppColors.textMuted),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(16),
                        ),
                        onChanged: (_) {
                          if (_validationError != null) {
                            setState(() => _validationError = null);
                          }
                        },
                      ),
                    ),

                    if (_validationError != null) ...[
                      const SizedBox(height: 8),
                      Text(_validationError!,
                          style: GoogleFonts.inter(
                              fontSize: 12, color: AppColors.danger)),
                    ],

                    const SizedBox(height: 16),

                    // Bottom bar
                    Row(
                      children: [
                        ValueListenableBuilder(
                          valueListenable: _controller,
                          builder: (_, val, __) => Text(
                            val.text.isEmpty
                                ? 'Paste content to analyze'
                                : '${val.text.length} characters',
                            style: GoogleFonts.inter(
                                fontSize: 12, color: AppColors.textMuted),
                          ),
                        ),
                        const Spacer(),
                        CyanButton(
                          label: 'Analyze →',
                          onTap: _loading ? () {} : _analyze,
                          loading: _loading,
                          small: true,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Error banner
              if (_error != null) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.dangerBg,
                    borderRadius: BorderRadius.circular(8),
                    border:
                        Border.all(color: AppColors.danger.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: AppColors.danger, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(_error!,
                            style: GoogleFonts.inter(
                                fontSize: 13, color: AppColors.danger)),
                      ),
                    ],
                  ),
                ),
              ],

              // Results
              if (_result != null) ...[
                const SizedBox(height: 24),
                _ResultsSection(result: _result!),
              ],

              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  const _Tab(
      {required this.label,
      required this.icon,
      required this.active,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: active
                ? AppColors.primary.withOpacity(0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                color: active
                    ? AppColors.primary.withOpacity(0.4)
                    : Colors.transparent),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon,
                  size: 14,
                  color: active ? AppColors.primary : AppColors.textMuted),
              const SizedBox(width: 6),
              Text(label,
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                      color: active ? AppColors.primary : AppColors.textMuted)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultsSection extends StatelessWidget {
  final AnalysisResult result;
  const _ResultsSection({required this.result});

  @override
  Widget build(BuildContext context) {
    return TGCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.analytics_outlined,
                  color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Text('Analysis Results',
                  style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              ToxicityBadge(toxicity: result.toxicity),
              const SizedBox(width: 10),
              SpamBadge(spam: result.spam),
            ],
          ),
          const SizedBox(height: 20),
          TrustScoreBar(score: result.trustScore),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.inputBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Summary',
                    style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted)),
                const SizedBox(height: 8),
                Text(result.summary,
                    style: GoogleFonts.inter(
                        fontSize: 14, color: AppColors.textBody, height: 1.6)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
