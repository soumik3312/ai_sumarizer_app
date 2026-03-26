import 'package:flutter/material.dart';
import '../models/note.dart';
import '../models/category.dart';
import '../models/summary_history.dart';
import '../services/database_service.dart';

class NotesProvider extends ChangeNotifier {
  List<Note> _notes = [];
  List<Category> _categories = DefaultCategories.all;
  List<SummaryHistory> _summaryHistory = [];
  String _searchQuery = '';
  Category? _selectedCategory;
  bool _showFavoritesOnly = false;
  bool _isLoading = false;
  bool _isInitialized = false;

  // Getters
  List<Note> get notes => _filteredNotes;
  List<Note> get allNotes => List.unmodifiable(_notes);
  List<Category> get categories => List.unmodifiable(_categories);
  List<SummaryHistory> get summaryHistory => List.unmodifiable(_summaryHistory);
  String get searchQuery => _searchQuery;
  Category? get selectedCategory => _selectedCategory;
  bool get showFavoritesOnly => _showFavoritesOnly;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;

  List<Note> get _filteredNotes {
    List<Note> filtered = List.from(_notes);
    
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((note) =>
        note.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        note.content.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        note.tags.any((tag) => tag.toLowerCase().contains(_searchQuery.toLowerCase()))
      ).toList();
    }

    if (_selectedCategory != null) {
      filtered = filtered.where((note) => note.category?.id == _selectedCategory!.id).toList();
    }

    if (_showFavoritesOnly) {
      filtered = filtered.where((note) => note.isFavorite).toList();
    }

    // Sort: pinned first, then by date
    filtered.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return b.updatedAt.compareTo(a.updatedAt);
    });

    return filtered;
  }

  List<Note> get recentNotes => allNotes
    .where((n) => n.updatedAt.isAfter(DateTime.now().subtract(const Duration(days: 7))))
    .toList()
    ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

  List<Note> get favoriteNotes => allNotes.where((n) => n.isFavorite).toList();

  int get totalNotes => _notes.length;
  int get totalSummaries => _summaryHistory.length;

  /// Initialize provider and load data from Hive
  Future<void> initialize() async {
    if (_isInitialized) return;

    _isLoading = true;
    notifyListeners();

    try {
      // Load notes from Hive
      _notes = DatabaseService.getAllNotes();
      
      // Load custom categories and merge with defaults
      final customCategories = DatabaseService.getAllCategories();
      if (customCategories.isNotEmpty) {
        _categories = [...DefaultCategories.all, ...customCategories];
      }
      
      // Load summary history
      _summaryHistory = DatabaseService.getAllHistory();
      
      // Update category counts
      _updateCategoryCounts();
      
      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing NotesProvider: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Methods
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedCategory(Category? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void toggleFavoritesOnly() {
    _showFavoritesOnly = !_showFavoritesOnly;
    notifyListeners();
  }

  /// Add a new note - saves to Hive and updates UI immediately
  Future<void> addNote(Note note) async {
    _notes.insert(0, note); // Add to beginning for immediate visibility
    _updateCategoryCounts();
    notifyListeners(); // Update UI immediately
    
    // Persist to database in background
    await DatabaseService.saveNote(note);
  }

  /// Update an existing note - saves to Hive and updates UI immediately
  Future<void> updateNote(Note note) async {
    final index = _notes.indexWhere((n) => n.id == note.id);
    if (index != -1) {
      _notes[index] = note;
      _updateCategoryCounts();
      notifyListeners(); // Update UI immediately
      
      // Persist to database in background
      await DatabaseService.saveNote(note);
    }
  }

  /// Delete a note - removes from Hive and updates UI immediately
  Future<void> deleteNote(String id) async {
    _notes.removeWhere((n) => n.id == id);
    _updateCategoryCounts();
    notifyListeners(); // Update UI immediately
    
    // Remove from database in background
    await DatabaseService.deleteNote(id);
  }

  /// Toggle favorite status
  Future<void> toggleFavorite(String id) async {
    final index = _notes.indexWhere((n) => n.id == id);
    if (index != -1) {
      final updatedNote = _notes[index].copyWith(
        isFavorite: !_notes[index].isFavorite,
        updatedAt: DateTime.now(),
      );
      _notes[index] = updatedNote;
      notifyListeners(); // Update UI immediately
      
      await DatabaseService.saveNote(updatedNote);
    }
  }

  /// Toggle pin status
  Future<void> togglePin(String id) async {
    final index = _notes.indexWhere((n) => n.id == id);
    if (index != -1) {
      final updatedNote = _notes[index].copyWith(
        isPinned: !_notes[index].isPinned,
        updatedAt: DateTime.now(),
      );
      _notes[index] = updatedNote;
      notifyListeners(); // Update UI immediately
      
      await DatabaseService.saveNote(updatedNote);
    }
  }

  /// Add summary to history
  Future<void> addSummaryToHistory(SummaryHistory summary) async {
    _summaryHistory.insert(0, summary);
    notifyListeners();
    
    await DatabaseService.saveSummaryHistory(summary);
  }

  /// Clear all history
  Future<void> clearAllHistory() async {
    _summaryHistory.clear();
    notifyListeners();
    
    await DatabaseService.clearAllHistory();
  }

  /// Add a new category
  Future<void> addCategory(Category category) async {
    _categories.add(category);
    notifyListeners();
    
    await DatabaseService.saveCategory(category);
  }

  void _updateCategoryCounts() {
    _categories = _categories.map((cat) {
      final count = _notes.where((n) => n.category?.id == cat.id).length;
      return cat.copyWith(noteCount: count);
    }).toList();
  }

  Note? getNoteById(String id) {
    try {
      return _notes.firstWhere((n) => n.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Refresh data from database
  Future<void> refresh() async {
    _notes = DatabaseService.getAllNotes();
    _summaryHistory = DatabaseService.getAllHistory();
    _updateCategoryCounts();
    notifyListeners();
  }
}

class NotesProviderInherited extends InheritedWidget {
  final NotesProvider provider;

  const NotesProviderInherited({
    super.key,
    required this.provider,
    required super.child,
  });

  static NotesProvider of(BuildContext context) {
    final widget = context.dependOnInheritedWidgetOfExactType<NotesProviderInherited>();
    return widget!.provider;
  }

  @override
  bool updateShouldNotify(NotesProviderInherited oldWidget) => true;
}
