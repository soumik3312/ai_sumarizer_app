import 'dart:io';
import 'package:flutter/material.dart';
import '../models/attachment.dart';
import '../theme/app_theme.dart';

/// Widget to display attachment previews (images and PDFs)
class AttachmentPreview extends StatelessWidget {
  final Attachment attachment;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;
  final VoidCallback? onSummarize;
  final bool showActions;

  const AttachmentPreview({
    super.key,
    required this.attachment,
    this.onTap,
    this.onRemove,
    this.onSummarize,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkCard : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppTheme.darkBorder : Colors.grey[300]!,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Preview area
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(11),
                    ),
                    child: attachment.isImage
                        ? _buildImagePreview()
                        : _buildPdfPreview(isDark),
                  ),
                  // Remove button
                  if (showActions && onRemove != null)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: onRemove,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  // File type badge
                  Positioned(
                    bottom: 4,
                    left: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: attachment.isPdf
                            ? Colors.red.withOpacity(0.9)
                            : AppTheme.primaryColor.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        attachment.isPdf ? 'PDF' : 'IMG',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // File info and actions
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    attachment.fileName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppTheme.textPrimary : Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    attachment.fileSizeFormatted,
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark ? AppTheme.textMuted : Colors.grey[500],
                    ),
                  ),
                  if (showActions && onSummarize != null) ...[
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: onSummarize,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.auto_awesome,
                              size: 12,
                              color: Colors.white,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Scan',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Image.file(
        File(attachment.filePath),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[300],
            child: const Icon(
              Icons.broken_image,
              color: Colors.grey,
              size: 32,
            ),
          );
        },
      ),
    );
  }

  Widget _buildPdfPreview(bool isDark) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: isDark ? AppTheme.darkCard : Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.picture_as_pdf,
            size: 40,
            color: Colors.red[400],
          ),
          const SizedBox(height: 4),
          Text(
            'PDF',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.red[400],
            ),
          ),
        ],
      ),
    );
  }
}

/// Grid view for multiple attachments
class AttachmentGrid extends StatelessWidget {
  final List<Attachment> attachments;
  final Function(Attachment)? onTap;
  final Function(Attachment)? onRemove;
  final Function(Attachment)? onSummarize;

  const AttachmentGrid({
    super.key,
    required this.attachments,
    this.onTap,
    this.onRemove,
    this.onSummarize,
  });

  @override
  Widget build(BuildContext context) {
    if (attachments.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: attachments.length,
        itemBuilder: (context, index) {
          final attachment = attachments[index];
          return AttachmentPreview(
            attachment: attachment,
            onTap: onTap != null ? () => onTap!(attachment) : null,
            onRemove: onRemove != null ? () => onRemove!(attachment) : null,
            onSummarize: onSummarize != null ? () => onSummarize!(attachment) : null,
          );
        },
      ),
    );
  }
}
 