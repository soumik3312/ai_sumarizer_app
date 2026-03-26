import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../providers/notes_provider.dart';
import '../widgets/note_card.dart';
import 'note_editor_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final notesProvider = NotesProviderInherited.of(context);

    final filteredNotes = _searchQuery.isEmpty
        ? []
        : notesProvider.allNotes.where((note) {
            final query = _searchQuery.toLowerCase();
            return note.title.toLowerCase().contains(query) ||
                note.content.toLowerCase().contains(query) ||
                note.tags.any((tag) => tag.toLowerCase().contains(query)) ||
                (note.summary?.toLowerCase().contains(query) ?? false);
          }).toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextField(
          controller: _searchController,
          focusNode: _focusNode,
          onChanged: (value) => setState(() => _searchQuery = value),
          style: TextStyle(
            color: isDark ? AppTheme.textPrimary : Colors.black,
          ),
          decoration: InputDecoration(
            hintText: 'Search notes...',
            hintStyle: TextStyle(
              color: isDark ? AppTheme.textMuted : Colors.grey[500],
            ),
            border: InputBorder.none,
          ),
        ),
        actions: [
          if (_searchQuery.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                _searchController.clear();
                setState(() => _searchQuery = '');
              },
            ),
        ],
      ),
      body: _searchQuery.isEmpty
          ? _buildRecentSearches(isDark)
          : _buildSearchResults(filteredNotes, notesProvider, isDark),
    );
  }

  Widget _buildRecentSearches(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Filters',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? AppTheme.textPrimary : Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _buildFilterChip(Icons.favorite, 'Favorites', AppTheme.accentPink),
              _buildFilterChip(Icons.push_pin, 'Pinned', AppTheme.accentOrange),
              _buildFilterChip(Icons.auto_awesome, 'Summarized', AppTheme.primaryColor),
              _buildFilterChip(Icons.access_time, 'Recent', AppTheme.accentCyan),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            'Search Tips',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? AppTheme.textPrimary : Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          _buildTip('Search by note title or content'),
          _buildTip('Use tags to filter quickly'),
          _buildTip('Search within summaries too'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(IconData icon, String label, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        // Apply filter
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTip(String text) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            Icons.lightbulb_outline,
            size: 16,
            color: AppTheme.accentOrange,
          ),
          const SizedBox(width: 10),
          Text(
            text,
            style: TextStyle(
              color: isDark ? AppTheme.textSecondary : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(
    List notes,
    NotesProvider notesProvider,
    bool isDark,
  ) {
    if (notes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: isDark ? AppTheme.textMuted : Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No results found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? AppTheme.textSecondary : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try a different search term',
              style: TextStyle(
                color: isDark ? AppTheme.textMuted : Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: notes.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final note = notes[index];
        return NoteCard(
          note: note,
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => NoteEditorScreen(note: note),
              ),
            );
          },
          onFavorite: () => notesProvider.toggleFavorite(note.id),
          onPin: () => notesProvider.togglePin(note.id),
          onDelete: () => notesProvider.deleteNote(note.id),
          searchQuery: _searchQuery,
        );
      },
    );
  }
}
