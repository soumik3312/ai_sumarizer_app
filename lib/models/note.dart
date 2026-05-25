import 'category.dart';
import 'attachment.dart';

class Note {
  final String id;
  final String title;
  final String content;
  final String? summary;
  final List<String> keyPoints;
  final Category? category;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isFavorite;
  final bool isPinned;
  final int wordCount;
  final int readingTimeMinutes;
  final List<Attachment> attachments; // NEW: Support for images and PDFs

  Note({
    required this.id,
    required this.title,
    required this.content,
    this.summary,
    this.keyPoints = const [],
    this.category,
    this.tags = const [],
    required this.createdAt,
    required this.updatedAt,
    this.isFavorite = false,
    this.isPinned = false,
    this.wordCount = 0,
    this.readingTimeMinutes = 0,
    this.attachments = const [],
  });

  Note copyWith({
    String? id,
    String? title,
    String? content,
    String? summary,
    List<String>? keyPoints,
    Category? category,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isFavorite,
    bool? isPinned,
    int? wordCount,
    int? readingTimeMinutes,
    List<Attachment>? attachments,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      summary: summary ?? this.summary,
      keyPoints: keyPoints ?? this.keyPoints,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isFavorite: isFavorite ?? this.isFavorite,
      isPinned: isPinned ?? this.isPinned,
      wordCount: wordCount ?? this.wordCount,
      readingTimeMinutes: readingTimeMinutes ?? this.readingTimeMinutes,
      attachments: attachments ?? this.attachments,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'summary': summary,
      'keyPoints': keyPoints,
      'category': category?.toJson(),
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isFavorite': isFavorite,
      'isPinned': isPinned,
      'wordCount': wordCount,
      'readingTimeMinutes': readingTimeMinutes,
      'attachments': attachments.map((a) => a.toJson()).toList(),
    };
  }

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      summary: json['summary'],
      keyPoints: List<String>.from(json['keyPoints'] ?? []),
      category: json['category'] != null ? Category.fromJson(json['category']) : null,
      tags: List<String>.from(json['tags'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      isFavorite: json['isFavorite'] ?? false,
      isPinned: json['isPinned'] ?? false,
      wordCount: json['wordCount'] ?? 0,
      readingTimeMinutes: json['readingTimeMinutes'] ?? 0,
      attachments: (json['attachments'] as List<dynamic>?)
          ?.map((a) => Attachment.fromJson(Map<String, dynamic>.from(a)))
          .toList() ?? [],
    );
  }

  bool get hasAttachments => attachments.isNotEmpty;
  int get imageCount => attachments.where((a) => a.isImage).length;
  int get pdfCount => attachments.where((a) => a.isPdf).length;
}
