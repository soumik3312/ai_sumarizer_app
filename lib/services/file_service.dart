import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../models/attachment.dart';

/// ============================================================
/// FILE SERVICE
/// ============================================================
/// Handles picking, saving, and managing images and PDFs locally.
/// Files are copied to app's documents directory for persistence.
/// ============================================================

class FileService {
  static final ImagePicker _imagePicker = ImagePicker();

  /// ============================================================
  /// PICK IMAGE FROM GALLERY
  /// ============================================================
  static Future<File?> pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 85,
      );
      if (image != null) {
        return File(image.path);
      }
    } catch (e) {
      debugPrint('Error picking image from gallery: $e');
    }
    return null;
  }

  /// ============================================================
  /// CAPTURE IMAGE FROM CAMERA
  /// ============================================================
  static Future<File?> captureImageFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 85,
      );
      if (image != null) {
        return File(image.path);
      }
    } catch (e) {
      debugPrint('Error capturing image: $e');
    }
    return null;
  }

  /// ============================================================
  /// PICK PDF FILE
  /// ============================================================
  static Future<File?> pickPdfFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );
      if (result != null && result.files.single.path != null) {
        return File(result.files.single.path!);
      }
    } catch (e) {
      debugPrint('Error picking PDF: $e');
    }
    return null;
  }

  /// ============================================================
  /// PICK MULTIPLE FILES (Images + PDFs)
  /// ============================================================
  static Future<List<File>> pickMultipleFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'gif', 'webp'],
        allowMultiple: true,
      );
      if (result != null) {
        return result.files
            .where((f) => f.path != null)
            .map((f) => File(f.path!))
            .toList();
      }
    } catch (e) {
      debugPrint('Error picking files: $e');
    }
    return [];
  }

  /// ============================================================
  /// SAVE FILE TO APP DIRECTORY
  /// ============================================================
  /// Copies the picked file to app's documents directory for persistence
  static Future<String> saveFileToAppDirectory(File file, String noteId) async {
    final appDir = await getApplicationDocumentsDirectory();
    final attachmentsDir = Directory('${appDir.path}/attachments/$noteId');
    
    if (!await attachmentsDir.exists()) {
      await attachmentsDir.create(recursive: true);
    }

    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(file.path)}';
    final savedFile = await file.copy('${attachmentsDir.path}/$fileName');
    
    return savedFile.path;
  }

  /// ============================================================
  /// CREATE ATTACHMENT OBJECT
  /// ============================================================
  static Future<Attachment> createAttachment({
    required File file,
    required String noteId,
  }) async {
    final savedPath = await saveFileToAppDirectory(file, noteId);
    final fileName = path.basename(file.path);
    final fileSize = await file.length();
    final extension = path.extension(fileName).toLowerCase();
    
    final type = extension == '.pdf' 
        ? AttachmentType.pdf 
        : AttachmentType.image;

    return Attachment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      noteId: noteId,
      fileName: fileName,
      filePath: savedPath,
      type: type,
      fileSize: fileSize,
      createdAt: DateTime.now(),
    );
  }

  /// ============================================================
  /// DELETE ATTACHMENT FILE
  /// ============================================================
  static Future<void> deleteAttachmentFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint('Error deleting file: $e');
    }
  }

  /// ============================================================
  /// DELETE ALL ATTACHMENTS FOR A NOTE
  /// ============================================================
  static Future<void> deleteAllAttachmentsForNote(String noteId) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final attachmentsDir = Directory('${appDir.path}/attachments/$noteId');
      
      if (await attachmentsDir.exists()) {
        await attachmentsDir.delete(recursive: true);
      }
    } catch (e) {
      debugPrint('Error deleting attachments directory: $e');
    }
  }

  /// ============================================================
  /// GET FILE TYPE FROM PATH
  /// ============================================================
  static AttachmentType getFileType(String filePath) {
    final extension = path.extension(filePath).toLowerCase();
    if (extension == '.pdf') {
      return AttachmentType.pdf;
    }
    return AttachmentType.image;
  }

  /// ============================================================
  /// CHECK IF FILE EXISTS
  /// ============================================================
  static Future<bool> fileExists(String filePath) async {
    return await File(filePath).exists();
  }
}
