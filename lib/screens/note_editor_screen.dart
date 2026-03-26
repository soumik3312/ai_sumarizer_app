import 'dart:io';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/note.dart';
import '../models/category.dart';
import '../models/attachment.dart';
import '../models/summary_history.dart';
import '../providers/notes_provider.dart';
import '../services/api_service.dart';
import '../services/file_service.dart';
import '../widgets/summary_bottom_sheet.dart';
import '../widgets/category_selector.dart';
import '../widgets/tag_input.dart';
import '../widgets/attachment_preview.dart';

class NoteEditorScreen extends StatefulWidget {
  final Note? note;

  const NoteEditorScreen({super.key, this.note});

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  Category? _selectedCategory;
  List<String> _tags = [];
  bool _isLoading = false;
  bool _hasChanges = false;
  String? _summary;
  List<String> _keyPoints = [];
  List<Attachment> _attachments = [];
  String _loadingMessage = 'Processing...';

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(text: widget.note?.content ?? '');
    _selectedCategory = widget.note?.category;
    _tags = List.from(widget.note?.tags ?? []);
    _summary = widget.note?.summary;
    _keyPoints = List.from(widget.note?.keyPoints ?? []);
    _attachments = List.from(widget.note?.attachments ?? []);

    _titleController.addListener(_onChanged);
    _contentController.addListener(_onChanged);
  }

  void _onChanged() {
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  int get _wordCount {
    final content = _contentController.text.trim();
    if (content.isEmpty) return 0;
    return content.split(RegExp(r'\s+')).length;
  }

  int get _readingTime {
    return (_wordCount / 200).ceil();
  }

  // ============================================================
  // ATTACHMENT METHODS
  // ============================================================

  /// Show attachment picker bottom sheet
  void _showAttachmentPicker() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkSurface : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkBorder : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Add Attachment',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? AppTheme.textPrimary : Colors.grey[800],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAttachmentOption(
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  color: Colors.blue,
                  onTap: () async {
                    Navigator.pop(context);
                    await _pickImageFromCamera();
                  },
                ),
                _buildAttachmentOption(
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  color: Colors.green,
                  onTap: () async {
                    Navigator.pop(context);
                    await _pickImageFromGallery();
                  },
                ),
                _buildAttachmentOption(
                  icon: Icons.picture_as_pdf,
                  label: 'PDF',
                  color: Colors.red,
                  onTap: () async {
                    Navigator.pop(context);
                    await _pickPdfFile();
                  },
                ),
                _buildAttachmentOption(
                  icon: Icons.folder_open,
                  label: 'Files',
                  color: Colors.orange,
                  onTap: () async {
                    Navigator.pop(context);
                    await _pickMultipleFiles();
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImageFromCamera() async {
    final file = await FileService.captureImageFromCamera();
    if (file != null) {
      await _addAttachment(file);
    }
  }

  Future<void> _pickImageFromGallery() async {
    final file = await FileService.pickImageFromGallery();
    if (file != null) {
      await _addAttachment(file);
    }
  }

  Future<void> _pickPdfFile() async {
    final file = await FileService.pickPdfFile();
    if (file != null) {
      await _addAttachment(file);
    }
  }

  Future<void> _pickMultipleFiles() async {
    final files = await FileService.pickMultipleFiles();
    for (final file in files) {
      await _addAttachment(file);
    }
  }

  Future<void> _addAttachment(File file) async {
    setState(() {
      _isLoading = true;
      _loadingMessage = 'Adding attachment...';
    });

    try {
      final noteId = widget.note?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
      final attachment = await FileService.createAttachment(
        file: file,
        noteId: noteId,
      );

      setState(() {
        _attachments.add(attachment);
        _hasChanges = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add attachment: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _removeAttachment(Attachment attachment) {
    setState(() {
      _attachments.removeWhere((a) => a.id == attachment.id);
      _hasChanges = true;
    });
    // Also delete the file from storage
    FileService.deleteAttachmentFile(attachment.filePath);
  }

  /// ============================================================
  /// SUMMARIZE ATTACHMENT (Image or PDF)
  /// ============================================================
  /// This sends the file to Python backend for:
  /// 1. Text extraction (OCR for images, text extraction for PDFs)
  /// 2. AI summarization of extracted text
  Future<void> _summarizeAttachment(Attachment attachment) async {
    setState(() {
      _isLoading = true;
      _loadingMessage = attachment.isImage
          ? 'Scanning image with AI...'
          : 'Extracting text from PDF...';
    });

    try {
      final file = File(attachment.filePath);
      
      // Call Python backend to extract text and summarize
      final result = await ApiService.summarizeFile(
        file: file,
        summaryType: 'brief',
        isImage: attachment.isImage,
      );

      if (result['success'] == true) {
        final extractedText = result['extractedText'] ?? '';
        final summary = result['summary'] ?? '';
        final keyPoints = List<String>.from(result['keyPoints'] ?? []);

        // Update the attachment with extracted text
        final updatedAttachment = attachment.copyWith(
          extractedText: extractedText,
        );
        
        setState(() {
          final index = _attachments.indexWhere((a) => a.id == attachment.id);
          if (index != -1) {
            _attachments[index] = updatedAttachment;
          }
          _summary = summary;
          _keyPoints = keyPoints;
        });

        // Optionally append extracted text to note content
        _showExtractedTextDialog(extractedText, summary, keyPoints);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['error'] ?? 'Failed to process file')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showExtractedTextDialog(String extractedText, String summary, List<String> keyPoints) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkSurface : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Extracted Content',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppTheme.textPrimary : Colors.grey[800],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Summary section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'AI Summary',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    summary,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Key points
            if (keyPoints.isNotEmpty) ...[
              Text(
                'Key Points',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppTheme.textPrimary : Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              ...keyPoints.map((point) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle, size: 16, color: AppTheme.primaryColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        point,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? AppTheme.textSecondary : Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
              )),
              const SizedBox(height: 16),
            ],
            
            // Extracted text
            Text(
              'Full Extracted Text',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? AppTheme.textPrimary : Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkCard : Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    extractedText,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? AppTheme.textSecondary : Colors.grey[700],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _contentController.text += '\n\n--- Extracted Text ---\n$extractedText';
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Text added to note')),
                      );
                    },
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add to Note'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _contentController.text += '\n\n--- Summary ---\n$summary';
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Summary added to note')),
                      );
                    },
                    icon: const Icon(Icons.summarize, size: 18),
                    label: const Text('Add Summary'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _viewAttachment(Attachment attachment) {
    // TODO: Implement full-screen viewer for images and PDFs
    if (attachment.isImage) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(title: Text(attachment.fileName)),
            body: Center(
              child: InteractiveViewer(
                child: Image.file(File(attachment.filePath)),
              ),
            ),
          ),
        ),
      );
    }
  }

  // ============================================================
  // SUMMARIZE TEXT NOTE
  // ============================================================
  Future<void> _summarizeNote(String type) async {
    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add some content first')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _loadingMessage = 'AI is summarizing...';
    });

    try {
      final result = await ApiService.summarizeNote(
        content: _contentController.text,
        summaryType: type,
      );

      if (result['success'] == true) {
        setState(() {
          _summary = result['summary'];
          _keyPoints = List<String>.from(result['keyPoints'] ?? []);
        });

        final notesProvider = NotesProviderInherited.of(context);
        notesProvider.addSummaryToHistory(SummaryHistory(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          noteId: widget.note?.id ?? 'new',
          noteTitle: _titleController.text.isNotEmpty
              ? _titleController.text
              : 'Untitled Note',
          originalContent: _contentController.text,
          summary: _summary!,
          keyPoints: _keyPoints,
          createdAt: DateTime.now(),
          summaryType: type,
        ));

        _showSummarySheet();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['error'] ?? 'Failed to summarize')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _generateTitle() async {
    if (_contentController.text.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _loadingMessage = 'Generating title...';
    });

    try {
      final result = await ApiService.generateTitle(_contentController.text);
      if (result['success'] == true) {
        _titleController.text = result['title'];
      }
    } catch (e) {
      // Handle error silently
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _extractKeywords() async {
    if (_contentController.text.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _loadingMessage = 'Extracting keywords...';
    });

    try {
      final result = await ApiService.extractKeywords(_contentController.text);
      if (result['success'] == true) {
        setState(() {
          _tags = List<String>.from(result['keywords'] ?? []);
        });
      }
    } catch (e) {
      // Handle error
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSummarySheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SummaryBottomSheet(
        summary: _summary ?? '',
        keyPoints: _keyPoints,
        onClose: () => Navigator.pop(context),
      ),
    );
  }

  void _saveNote() {
    final notesProvider = NotesProviderInherited.of(context);
    final now = DateTime.now();

    final note = Note(
      id: widget.note?.id ?? now.millisecondsSinceEpoch.toString(),
      title: _titleController.text.isNotEmpty
          ? _titleController.text
          : 'Untitled Note',
      content: _contentController.text,
      summary: _summary,
      keyPoints: _keyPoints,
      category: _selectedCategory,
      tags: _tags,
      createdAt: widget.note?.createdAt ?? now,
      updatedAt: now,
      isFavorite: widget.note?.isFavorite ?? false,
      isPinned: widget.note?.isPinned ?? false,
      wordCount: _wordCount,
      readingTimeMinutes: _readingTime,
      attachments: _attachments,
    );

    if (widget.note != null) {
      notesProvider.updateNote(note);
    } else {
      notesProvider.addNote(note);
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Note saved successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.note == null ? 'New Note' : 'Edit Note'),
        actions: [
          // Attachment button
          IconButton(
            icon: Badge(
              isLabelVisible: _attachments.isNotEmpty,
              label: Text('${_attachments.length}'),
              child: const Icon(Icons.attach_file),
            ),
            onPressed: _showAttachmentPicker,
          ),
          if (_hasChanges)
            TextButton(
              onPressed: _saveNote,
              child: const Text('Save'),
            ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'generate_title':
                  _generateTitle();
                  break;
                case 'extract_tags':
                  _extractKeywords();
                  break;
                case 'export':
                  // TODO: Implement export
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'generate_title',
                child: Row(
                  children: [
                    Icon(Icons.auto_fix_high, size: 20),
                    SizedBox(width: 12),
                    Text('Generate Title'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'extract_tags',
                child: Row(
                  children: [
                    Icon(Icons.tag, size: 20),
                    SizedBox(width: 12),
                    Text('Extract Tags'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.ios_share, size: 20),
                    SizedBox(width: 12),
                    Text('Export'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title Input
                TextField(
                  controller: _titleController,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Note title...',
                    hintStyle: TextStyle(
                      color: isDark ? AppTheme.textMuted : Colors.grey[400],
                      fontWeight: FontWeight.bold,
                    ),
                    border: InputBorder.none,
                    filled: false,
                  ),
                  maxLines: null,
                ),
                const SizedBox(height: 8),

                // Category & Stats Row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            backgroundColor: Colors.transparent,
                            builder: (context) => CategorySelector(
                              selectedCategory: _selectedCategory,
                              onSelect: (category) {
                                setState(() => _selectedCategory = category);
                                _onChanged();
                                Navigator.pop(context);
                              },
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _selectedCategory?.color.withOpacity(0.1) ??
                                (isDark ? AppTheme.darkCard : Colors.grey[100]),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _selectedCategory?.color.withOpacity(0.3) ??
                                  (isDark ? AppTheme.darkBorder : Colors.grey[300]!),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _selectedCategory?.icon ?? Icons.folder_outlined,
                                size: 16,
                                color: _selectedCategory?.color ??
                                    (isDark ? AppTheme.textMuted : Colors.grey[600]),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _selectedCategory?.name ?? 'Category',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: _selectedCategory?.color ??
                                      (isDark ? AppTheme.textMuted : Colors.grey[600]),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isDark ? AppTheme.darkCard : Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$_wordCount words',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? AppTheme.textMuted : Colors.grey[600],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isDark ? AppTheme.darkCard : Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$_readingTime min read',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? AppTheme.textMuted : Colors.grey[600],
                          ),
                        ),
                      ),
                      if (_attachments.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.attach_file,
                                size: 14,
                                color: AppTheme.primaryColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${_attachments.length} files',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Tags
                TagInput(
                  tags: _tags,
                  onTagsChanged: (tags) {
                    setState(() => _tags = tags);
                    _onChanged();
                  },
                ),
                const SizedBox(height: 16),

                // Attachments Preview
                if (_attachments.isNotEmpty) ...[
                  Text(
                    'Attachments',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppTheme.textSecondary : Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  AttachmentGrid(
                    attachments: _attachments,
                    onTap: _viewAttachment,
                    onRemove: _removeAttachment,
                    onSummarize: _summarizeAttachment,
                  ),
                  const SizedBox(height: 16),
                ],

                // Content Input
                TextField(
                  controller: _contentController,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.6,
                    color: isDark ? AppTheme.textPrimary : Colors.grey[800],
                  ),
                  decoration: InputDecoration(
                    hintText: 'Start writing your note...\n\nTip: Add images or PDFs and let AI scan and summarize them!',
                    hintStyle: TextStyle(
                      color: isDark ? AppTheme.textMuted : Colors.grey[400],
                    ),
                    border: InputBorder.none,
                    filled: false,
                  ),
                  maxLines: null,
                  minLines: 15,
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),

          // Loading overlay
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.darkSurface : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(AppTheme.primaryColor),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _loadingMessage,
                        style: TextStyle(
                          color: isDark ? AppTheme.textPrimary : Colors.grey[800],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkSurface : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.auto_awesome,
                  label: 'Brief',
                  onTap: () => _summarizeNote('brief'),
                  isPrimary: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.description_outlined,
                  label: 'Detailed',
                  onTap: () => _summarizeNote('detailed'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.format_list_bulleted,
                  label: 'Bullets',
                  onTap: () => _summarizeNote('bullet_points'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: _isLoading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: isPrimary ? AppTheme.primaryGradient : null,
          color: isPrimary
              ? null
              : (isDark ? AppTheme.darkCard : Colors.grey[100]),
          borderRadius: BorderRadius.circular(12),
          border: isPrimary
              ? null
              : Border.all(
                  color: isDark ? AppTheme.darkBorder : Colors.grey[300]!,
                ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isPrimary
                  ? Colors.white
                  : (isDark ? AppTheme.textSecondary : Colors.grey[700]),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isPrimary
                    ? Colors.white
                    : (isDark ? AppTheme.textSecondary : Colors.grey[700]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
