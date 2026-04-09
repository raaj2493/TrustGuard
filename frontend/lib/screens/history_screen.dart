import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../widgets/shared.dart';
import '../models/analysis.dart';
import '../services/history_service.dart';

class HistoryScreen extends StatefulWidget {
  final ValueChanged<int> onTabChanged;
  const HistoryScreen({super.key, required this.onTabChanged});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _service = HistoryService();
  List<ScanRecord>? _records;
  int? _expanded;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final records = await _service.getHistory();
    setState(() => _records = records);
  }

  Future<void> _clearAll() async {
    await _service.clearHistory();
    setState(() {
      _records = [];
      _expanded = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TGPageScaffold(
      currentTab: 2,
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
                child: const Icon(Icons.history,
                    color: AppColors.primary, size: 28),
              ),
              const SizedBox(height: 20),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(children: [
                  TextSpan(
                    text: 'Scan ',
                    style: GoogleFonts.inter(
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary),
                  ),
                  TextSpan(
                    text: 'History',
                    style: GoogleFonts.inter(
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary),
                  ),
                ]),
              ),
              const SizedBox(height: 12),
              Text(
                'Review your previous threat analysis results.',
                textAlign: TextAlign.center,
                style:
                    GoogleFonts.inter(fontSize: 15, color: AppColors.textBody),
              ),
              const SizedBox(height: 40),

              if (_records == null)
                const CircularProgressIndicator(color: AppColors.primary)
              else if (_records!.isEmpty)
                _EmptyState(onTabChanged: widget.onTabChanged)
              else
                _PopulatedState(
                  records: _records!,
                  expanded: _expanded,
                  onExpand: (i) =>
                      setState(() => _expanded = _expanded == i ? null : i),
                  onClear: _clearAll,
                ),

              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final ValueChanged<int> onTabChanged;
  const _EmptyState({required this.onTabChanged});

  @override
  Widget build(BuildContext context) {
    return TGCard(
      child: Column(
        children: [
          const SizedBox(height: 16),
          Icon(Icons.shield_outlined,
              size: 48, color: AppColors.textMuted.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text('No scans yet',
              style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          Text('Start by analyzing some content.',
              style:
                  GoogleFonts.inter(fontSize: 14, color: AppColors.textBody)),
          const SizedBox(height: 24),
          CyanButton(
            label: 'Start Scanning',
            icon: Icons.shield_outlined,
            onTap: () => onTabChanged(1),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _PopulatedState extends StatelessWidget {
  final List<ScanRecord> records;
  final int? expanded;
  final ValueChanged<int> onExpand;
  final VoidCallback onClear;

  const _PopulatedState({
    required this.records,
    required this.expanded,
    required this.onExpand,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${records.length} scan${records.length == 1 ? '' : 's'}',
                style: GoogleFonts.inter(
                    fontSize: 14, color: AppColors.textMuted)),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: onClear,
                child: Text('Clear All',
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.danger,
                        fontWeight: FontWeight.w500)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...records.asMap().entries.map((e) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _HistoryCard(
              record: e.value,
              isExpanded: expanded == e.key,
              onTap: () => onExpand(e.key),
            ),
          );
        }),
      ],
    );
  }
}

class _HistoryCard extends StatefulWidget {
  final ScanRecord record;
  final bool isExpanded;
  final VoidCallback onTap;

  const _HistoryCard({
    required this.record,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  State<_HistoryCard> createState() => _HistoryCardState();
}

class _HistoryCardState extends State<_HistoryCard> {
  bool _hovered = false;

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.record;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _hovered ? const Color(0xFF161616) : AppColors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: widget.isExpanded
                    ? AppColors.primary.withOpacity(0.3)
                    : _hovered
                        ? AppColors.borderHover
                        : AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      r.text.length > 80
                          ? '${r.text.substring(0, 80)}...'
                          : r.text,
                      style: GoogleFonts.inter(
                          fontSize: 13, color: AppColors.textBody),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(_formatTime(r.timestamp),
                      style: GoogleFonts.inter(
                          fontSize: 12, color: AppColors.textMuted)),
                  const SizedBox(width: 8),
                  Icon(
                    widget.isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: AppColors.textMuted,
                    size: 18,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  ToxicityBadge(toxicity: r.analysis.toxicity),
                  const SizedBox(width: 8),
                  SpamBadge(spam: r.analysis.spam),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Score: ${r.analysis.trustScore.toStringAsFixed(2)}',
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary),
                    ),
                  ),
                ],
              ),
              if (widget.isExpanded) ...[
                const SizedBox(height: 16),
                const Divider(color: AppColors.border, height: 1),
                const SizedBox(height: 16),
                TrustScoreBar(score: r.analysis.trustScore),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.inputBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Full Text',
                          style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textMuted)),
                      const SizedBox(height: 8),
                      Text(r.text,
                          style: GoogleFonts.inter(
                              fontSize: 13,
                              color: AppColors.textBody,
                              height: 1.6)),
                    ],
                  ),
                ),
                if (r.analysis.summary.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.inputBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Summary',
                            style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textMuted)),
                        const SizedBox(height: 8),
                        Text(r.analysis.summary,
                            style: GoogleFonts.inter(
                                fontSize: 13,
                                color: AppColors.textBody,
                                height: 1.6)),
                      ],
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
