class AnalysisResult {
  final String toxicity;
  final bool spam;
  final double trustScore;
  final String summary;

  AnalysisResult({
    required this.toxicity,
    required this.spam,
    required this.trustScore,
    required this.summary,
  });

  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
    return AnalysisResult(
      toxicity: json['toxicity'] ?? 'low',
      spam: json['spam'] ?? false,
      trustScore: (json['trust_score'] as num?)?.toDouble() ?? 0.0,
      summary: json['summary'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'toxicity': toxicity,
        'spam': spam,
        'trust_score': trustScore,
        'summary': summary,
      };
}

class ScanRecord {
  final String text;
  final AnalysisResult analysis;
  final DateTime timestamp;

  ScanRecord({
    required this.text,
    required this.analysis,
    required this.timestamp,
  });

  factory ScanRecord.fromJson(Map<String, dynamic> json) {
    return ScanRecord(
      text: json['text'] ?? '',
      analysis: AnalysisResult.fromJson(json['analysis']),
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() => {
        'text': text,
        'analysis': analysis.toJson(),
        'timestamp': timestamp.toIso8601String(),
      };
}
