import 'package:hive_flutter/hive_flutter.dart';
import '../models/note.dart';
import '../models/category.dart';
import '../models/summary_history.dart';

/// DatabaseService - Handles all Hive database operations
/// This is where your data persistence happens with instant read/write
class DatabaseService {
  static const String notesBoxName = 'notes';
  static const String categoriesBoxName = 'categories';
  static const String historyBoxName = 'summary_history';
  static const String settingsBoxName = 'settings';

  static late Box<Map> _notesBox;
  static late Box<Map> _categoriesBox;
  static late Box<Map> _historyBox;
  static late Box _settingsBox;

  static bool _isInitialized = false;

  /// Initialize Hive and open all boxes
  static Future<void> initialize() async {
    if (_isInitialized) return;

    await Hive.initFlutter();

    _notesBox = await Hive.openBox<Map>(notesBoxName);
    _categoriesBox = await Hive.openBox<Map>(categoriesBoxName);
    _historyBox = await Hive.openBox<Map>(historyBoxName);
    _settingsBox = await Hive.openBox(settingsBoxName);

    _isInitialized = true;
  }

  // ============== NOTES OPERATIONS ==============

  /// Get all notes from database
  static List<Note> getAllNotes() {
    final List<Note> notes = [];
    for (var key in _notesBox.keys) {
      final data = _notesBox.get(key);
      if (data != null) {
        try {
          notes.add(Note.fromJson(Map<String, dynamic>.from(data)));
        } catch (e) {
          // Skip corrupted data
        }
      }
    }
    return notes;
  }

  /// Save a note (create or update) - INSTANT
  static Future<void> saveNote(Note note) async {
    await _notesBox.put(note.id, note.toJson());
  }

  /// Delete a note by ID
  static Future<void> deleteNote(String id) async {
    await _notesBox.delete(id);
  }

  /// Get a single note by ID
  static Note? getNote(String id) {
    final data = _notesBox.get(id);
    if (data != null) {
      return Note.fromJson(Map<String, dynamic>.from(data));
    }
    return null;
  }

  // ============== CATEGORIES OPERATIONS ==============

  /// Get all custom categories
  static List<Category> getAllCategories() {
    final List<Category> categories = [];
    for (var key in _categoriesBox.keys) {
      final data = _categoriesBox.get(key);
      if (data != null) {
        try {
          categories.add(Category.fromJson(Map<String, dynamic>.from(data)));
        } catch (e) {
          // Skip corrupted data
        }
      }
    }
    return categories;
  }

  /// Save a category
  static Future<void> saveCategory(Category category) async {
    await _categoriesBox.put(category.id, category.toJson());
  }

  /// Delete a category
  static Future<void> deleteCategory(String id) async {
    await _categoriesBox.delete(id);
  }

  // ============== SUMMARY HISTORY OPERATIONS ==============

  /// Get all summary history
  static List<SummaryHistory> getAllHistory() {
    final List<SummaryHistory> history = [];
    for (var key in _historyBox.keys) {
      final data = _historyBox.get(key);
      if (data != null) {
        try {
          history.add(SummaryHistory.fromJson(Map<String, dynamic>.from(data)));
        } catch (e) {
          // Skip corrupted data
        }
      }
    }
    // Sort by date, newest first
    history.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return history;
  }

  /// Save a summary history entry
  static Future<void> saveSummaryHistory(SummaryHistory history) async {
    await _historyBox.put(history.id, history.toJson());
  }

  /// Delete a history entry
  static Future<void> deleteHistory(String id) async {
    await _historyBox.delete(id);
  }

  /// Clear all history
  static Future<void> clearAllHistory() async {
    await _historyBox.clear();
  }

  // ============== SETTINGS OPERATIONS ==============

  /// Get a setting value
  static T? getSetting<T>(String key, {T? defaultValue}) {
    return _settingsBox.get(key, defaultValue: defaultValue) as T?;
  }

  /// Save a setting
  static Future<void> saveSetting(String key, dynamic value) async {
    await _settingsBox.put(key, value);
  }

  /// Get theme mode setting
  static bool isDarkMode() {
    return _settingsBox.get('isDarkMode', defaultValue: false) as bool;
  }

  /// Save theme mode setting
  static Future<void> setDarkMode(bool isDark) async {
    await _settingsBox.put('isDarkMode', isDark);
  }

  // ============== UTILITY OPERATIONS ==============

  /// Clear all data (for testing/reset)
  static Future<void> clearAllData() async {
    await _notesBox.clear();
    await _categoriesBox.clear();
    await _historyBox.clear();
  }

  /// Close all boxes
  static Future<void> close() async {
    await _notesBox.close();
    await _categoriesBox.close();
    await _historyBox.close();
    await _settingsBox.close();
  }

  /// Get database stats
  static Map<String, int> getStats() {
    return {
      'notes': _notesBox.length,
      'categories': _categoriesBox.length,
      'history': _historyBox.length,
    };
  }
}
