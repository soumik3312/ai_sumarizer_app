class SummaryHistory {
  final String id;
  final String noteId;
  final String noteTitle;
  final String originalContent;
  final String summary;
  final List<String> keyPoints;
  final DateTime createdAt;
  final String summaryType; // 'brief', 'detailed', 'bullet_points'

  SummaryHistory({
    required this.id,
    required this.noteId,
    required this.noteTitle,
    required this.originalContent,
    required this.summary,
    required this.keyPoints,
    required this.createdAt,
    required this.summaryType,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'noteId': noteId,
      'noteTitle': noteTitle,
      'originalContent': originalContent,
      'summary': summary,
      'keyPoints': keyPoints,
      'createdAt': createdAt.toIso8601String(),
      'summaryType': summaryType,
    };
  }

  factory SummaryHistory.fromJson(Map<String, dynamic> json) {
    return SummaryHistory(
      id: json['id'],
      noteId: json['noteId'],
      noteTitle: json['noteTitle'],
      originalContent: json['originalContent'],
      summary: json['summary'],
      keyPoints: List<String>.from(json['keyPoints'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      summaryType: json['summaryType'],
    );
  }
}
