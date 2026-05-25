/// Attachment model for storing files (PDFs and Images) attached to notes
enum AttachmentType { image, pdf }

class Attachment {
  final String id;
  final String noteId;
  final String fileName;
  final String filePath;
  final AttachmentType type;
  final int fileSize;
  final DateTime createdAt;
  final String? extractedText; // Text extracted by AI (OCR for images, text extraction for PDFs)
  final String? thumbnailPath;

  Attachment({
    required this.id,
    required this.noteId,
    required this.fileName,
    required this.filePath,
    required this.type,
    required this.fileSize,
    required this.createdAt,
    this.extractedText,
    this.thumbnailPath,
  });

  Attachment copyWith({
    String? id,
    String? noteId,
    String? fileName,
    String? filePath,
    AttachmentType? type,
    int? fileSize,
    DateTime? createdAt,
    String? extractedText,
    String? thumbnailPath,
  }) {
    return Attachment(
      id: id ?? this.id,
      noteId: noteId ?? this.noteId,
      fileName: fileName ?? this.fileName,
      filePath: filePath ?? this.filePath,
      type: type ?? this.type,
      fileSize: fileSize ?? this.fileSize,
      createdAt: createdAt ?? this.createdAt,
      extractedText: extractedText ?? this.extractedText,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'noteId': noteId,
      'fileName': fileName,
      'filePath': filePath,
      'type': type.name,
      'fileSize': fileSize,
      'createdAt': createdAt.toIso8601String(),
      'extractedText': extractedText,
      'thumbnailPath': thumbnailPath,
    };
  }

  factory Attachment.fromJson(Map<String, dynamic> json) {
    return Attachment(
      id: json['id'],
      noteId: json['noteId'],
      fileName: json['fileName'],
      filePath: json['filePath'],
      type: AttachmentType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AttachmentType.image,
      ),
      fileSize: json['fileSize'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
      extractedText: json['extractedText'],
      thumbnailPath: json['thumbnailPath'],
    );
  }

  String get fileSizeFormatted {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  bool get isImage => type == AttachmentType.image;
  bool get isPdf => type == AttachmentType.pdf;
}
