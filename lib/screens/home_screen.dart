import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../providers/notes_provider.dart';
import '../providers/theme_provider.dart';
import '../models/note.dart';
import '../models/category.dart';
import '../widgets/note_card.dart';
import '../widgets/category_chip.dart';
import '../widgets/stats_card.dart';
import '../widgets/empty_state.dart';
import 'note_editor_screen.dart';
import 'settings_screen.dart';
import 'history_screen.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notesProvider = NotesProviderInherited.of(context);
    final themeProvider = ThemeProviderInherited.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: [
            _buildHomeTab(context, notesProvider, isDark),
            const HistoryScreen(),
            const SettingsScreen(),
          ],
        ),
      ),
      floatingActionButton: _currentIndex == 0
          ? Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: AppTheme.primaryGradient,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const NoteEditorScreen()),
                  );
                },
                backgroundColor: Colors.transparent,
                elevation: 0,
                child: const Icon(Icons.add, size: 28),
              ),
            )
          : null,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkSurface : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.home_outlined, Icons.home, 'Home', 0),
                _buildNavItem(Icons.history_outlined, Icons.history, 'History', 1),
                _buildNavItem(Icons.settings_outlined, Icons.settings, 'Settings', 2),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, IconData activeIcon, String label, int index) {
    final isSelected = _currentIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected
                  ? AppTheme.primaryColor
                  : (isDark ? AppTheme.textMuted : Colors.grey),
              size: 24,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHomeTab(BuildContext context, NotesProvider notesProvider, bool isDark) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, isDark),
                const SizedBox(height: 24),
                _buildSearchBar(context, isDark),
                const SizedBox(height: 24),
                _buildStatsSection(notesProvider),
                const SizedBox(height: 24),
                _buildCategoriesSection(notesProvider),
                const SizedBox(height: 24),
                _buildNotesHeader(notesProvider),
              ],
            ),
          ),
        ),
        _buildNotesList(notesProvider, isDark),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppTheme.textSecondary : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [AppTheme.primaryColor, AppTheme.accentCyan],
              ).createShader(bounds),
              child: const Text(
                'NoteAI',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkCard : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: Icon(
                  Icons.notifications_outlined,
                  color: isDark ? AppTheme.textSecondary : Colors.grey[700],
                ),
                onPressed: () {},
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  'U',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context, bool isDark) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SearchScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkCard : Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppTheme.darkBorder : Colors.grey[200]!,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.search,
              color: isDark ? AppTheme.textMuted : Colors.grey[500],
            ),
            const SizedBox(width: 12),
            Text(
              'Search notes, tags, or content...',
              style: TextStyle(
                color: isDark ? AppTheme.textMuted : Colors.grey[500],
                fontSize: 15,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkBorder : Colors.grey[200],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Ctrl+K',
                style: TextStyle(
                  color: isDark ? AppTheme.textMuted : Colors.grey[600],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(NotesProvider notesProvider) {
    return Row(
      children: [
        Expanded(
          child: StatsCard(
            icon: Icons.description_outlined,
            label: 'Total Notes',
            value: notesProvider.totalNotes.toString(),
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatsCard(
            icon: Icons.auto_awesome_outlined,
            label: 'Summaries',
            value: notesProvider.totalSummaries.toString(),
            color: AppTheme.accentCyan,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatsCard(
            icon: Icons.favorite_outline,
            label: 'Favorites',
            value: notesProvider.favoriteNotes.length.toString(),
            color: AppTheme.accentPink,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoriesSection(NotesProvider notesProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Categories',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('See all'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: notesProvider.categories.length + 1,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              if (index == 0) {
                return CategoryChip(
                  label: 'All',
                  icon: Icons.grid_view_rounded,
                  isSelected: notesProvider.selectedCategory == null,
                  onTap: () => notesProvider.setSelectedCategory(null),
                );
              }
              final category = notesProvider.categories[index - 1];
              return CategoryChip(
                label: category.name,
                icon: category.icon,
                color: category.color,
                isSelected: notesProvider.selectedCategory?.id == category.id,
                onTap: () => notesProvider.setSelectedCategory(category),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNotesHeader(NotesProvider notesProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Recent Notes',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: Icon(
                notesProvider.showFavoritesOnly
                    ? Icons.favorite
                    : Icons.favorite_border,
                color: notesProvider.showFavoritesOnly
                    ? AppTheme.accentPink
                    : null,
              ),
              onPressed: () => notesProvider.toggleFavoritesOnly(),
            ),
            IconButton(
              icon: const Icon(Icons.sort),
              onPressed: () {},
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNotesList(NotesProvider notesProvider, bool isDark) {
    final notes = notesProvider.notes;

    if (notes.isEmpty) {
      return const SliverFillRemaining(
        child: EmptyState(
          icon: Icons.note_add_outlined,
          title: 'No notes yet',
          subtitle: 'Create your first note and let AI summarize it for you',
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final note = notes[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: NoteCard(
                note: note,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => NoteEditorScreen(note: note),
                    ),
                  );
                },
                onFavorite: () => notesProvider.toggleFavorite(note.id),
                onPin: () => notesProvider.togglePin(note.id),
                onDelete: () => notesProvider.deleteNote(note.id),
              ),
            );
          },
          childCount: notes.length,
        ),
      ),
    );
  }
}
