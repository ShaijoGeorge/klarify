import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:intl/intl.dart';
import '../../core/database/flashcard.dart';
import '../../core/theme/app_theme.dart';
import '../../main.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  List<Flashcard> _allCards = [];
  Map<String, List<Flashcard>> _groupedCards = {};
  bool _isLoading = true;

  String _activeGenderFilter = 'All';
  String _activeDateFilter = 'All Time';

  final TextEditingController _searchController = TextEditingController();

  static const _genderFilters = ['All', 'der', 'die', 'das', 'Other'];
  static const _dateFilters = ['All Time', 'Today', 'Yesterday', 'Past 7 Days'];

  @override
  void initState() {
    super.initState();
    _loadCards();
    _searchController.addListener(_applyFilter);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCards() async {
    // Sort by newest first
    final cards = await isarDb.flashcards.where().sortByCreatedAtDesc().findAll();
    setState(() {
      _allCards = cards;
      _isLoading = false;
    });
    _applyFilter();
  }

  void _applyFilter() {
    final query = _searchController.text.toLowerCase();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final weekAgo = today.subtract(const Duration(days: 7));

    final filtered = _allCards.where((card) {
      // 1. Gender filter
      if (_activeGenderFilter != 'All') {
        if (_activeGenderFilter == 'Other') {
          final art = (card.article ?? '').toLowerCase();
          if (art == 'der' || art == 'die' || art == 'das') return false;
        } else {
          if ((card.article ?? '').toLowerCase() != _activeGenderFilter.toLowerCase()) return false;
        }
      }

      // 2. Date filter
      if (_activeDateFilter != 'All Time') {
        final cardDate = card.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final cardDay = DateTime(cardDate.year, cardDate.month, cardDate.day);

        if (_activeDateFilter == 'Today' && cardDay != today) return false;
        if (_activeDateFilter == 'Yesterday' && cardDay != yesterday) return false;
        if (_activeDateFilter == 'Past 7 Days' && cardDay.isBefore(weekAgo)) return false;
      }

      // 3. Search filter
      if (query.isNotEmpty) {
        final word = (card.word ?? '').toLowerCase();
        final translation = (card.translation ?? '').toLowerCase();
        if (!word.contains(query) && !translation.contains(query)) return false;
      }
      return true;
    }).toList();

    // Group the filtered cards by Date
    final Map<String, List<Flashcard>> grouped = {};
    for (final card in filtered) {
      final dateStr = _formatDateGroup(card.createdAt);
      if (!grouped.containsKey(dateStr)) {
        grouped[dateStr] = [];
      }
      grouped[dateStr]!.add(card);
    }

    setState(() {
      _groupedCards = grouped;
    });
  }

  String _formatDateGroup(DateTime? date) {
    if (date == null) return 'Older Cards';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final cardDay = DateTime(date.year, date.month, date.day);

    if (cardDay == today) {
      return 'Today';
    } else if (cardDay == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat.yMMMMd().format(date); // e.g., "July 15, 2026"
    }
  }

  Future<void> _deleteCard(Flashcard card) async {
    await isarDb.writeTxn(() async {
      await isarDb.flashcards.delete(card.id);
    });
    _allCards.remove(card);
    _applyFilter();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Deleted "${card.word}"'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showFilterSheet(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Filters', style: theme.textTheme.titleLarge),
                        TextButton(
                          onPressed: () {
                            setModalState(() {
                              _activeDateFilter = 'All Time';
                              _activeGenderFilter = 'All';
                            });
                            setState(() {
                              _activeDateFilter = 'All Time';
                              _activeGenderFilter = 'All';
                            });
                            _applyFilter();
                          },
                          child: const Text('Reset'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Date Filter
                    Text('Time Period', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _dateFilters.map((filter) {
                        final isActive = filter == _activeDateFilter;
                        return ChoiceChip(
                          label: Text(filter),
                          selected: isActive,
                          onSelected: (selected) {
                            if (selected) {
                              setModalState(() => _activeDateFilter = filter);
                              setState(() => _activeDateFilter = filter);
                              _applyFilter();
                            }
                          },
                          showCheckmark: false,
                          selectedColor: theme.colorScheme.secondaryContainer,
                          labelStyle: TextStyle(
                            fontSize: 13,
                            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                            color: isActive ? theme.colorScheme.secondary : theme.colorScheme.onSurfaceVariant,
                          ),
                          side: BorderSide(
                            color: isActive ? theme.colorScheme.secondary : theme.colorScheme.outline.withValues(alpha: 0.3),
                            width: isActive ? 1.5 : 1,
                          ),
                          backgroundColor: theme.colorScheme.surface,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 28),

                    // Gender Filter
                    Text('Article (Gender)', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _genderFilters.map((filter) {
                        final isActive = filter == _activeGenderFilter;
                        Color chipColor;
                        if (filter == 'der') {
                          chipColor = AppTheme.getGenderColor('der', isDark);
                        } else if (filter == 'die') {
                          chipColor = AppTheme.getGenderColor('die', isDark);
                        } else if (filter == 'das') {
                          chipColor = AppTheme.getGenderColor('das', isDark);
                        } else {
                          chipColor = theme.colorScheme.primary;
                        }

                        return ChoiceChip(
                          label: Text(filter),
                          selected: isActive,
                          onSelected: (selected) {
                            if (selected) {
                              setModalState(() => _activeGenderFilter = filter);
                              setState(() => _activeGenderFilter = filter);
                              _applyFilter();
                            }
                          },
                          showCheckmark: false,
                          selectedColor: chipColor.withValues(alpha: isDark ? 0.25 : 0.15),
                          labelStyle: TextStyle(
                            fontSize: 13,
                            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                            color: isActive ? chipColor : theme.colorScheme.onSurfaceVariant,
                          ),
                          side: BorderSide(
                            color: isActive ? chipColor : theme.colorScheme.outline.withValues(alpha: 0.3),
                            width: isActive ? 1.5 : 1,
                          ),
                          backgroundColor: theme.colorScheme.surface,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 32),

                    // Done Button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text('Show Results', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    int totalFilteredCount = _groupedCards.values.fold(0, (sum, list) => sum + list.length);
    bool hasActiveFilters = _activeDateFilter != 'All Time' || _activeGenderFilter != 'All';

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ─── Header ───
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Icon(Icons.menu_book_rounded, color: theme.colorScheme.primary, size: 28),
                  const SizedBox(width: 10),
                  Text('Library', style: theme.textTheme.titleLarge),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$totalFilteredCount cards',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ─── Search Bar & Filter Button ───
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: theme.textTheme.bodyLarge,
                        decoration: InputDecoration(
                          hintText: 'Search words or translations…',
                          hintStyle: theme.textTheme.bodyMedium,
                          prefixIcon: Icon(Icons.search_rounded, color: theme.colorScheme.onSurfaceVariant),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Filter Button
                  GestureDetector(
                    onTap: () => _showFilterSheet(context),
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: hasActiveFilters ? theme.colorScheme.primary : theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
                      ),
                      child: Icon(
                        hasActiveFilters ? Icons.filter_list_off_rounded : Icons.tune_rounded,
                        color: hasActiveFilters ? theme.colorScheme.onPrimary : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ─── Active Filter Chips ───
            if (hasActiveFilters) ...[
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  height: 36,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      if (_activeDateFilter != 'All Time')
                        _ActiveFilterChip(
                          label: _activeDateFilter,
                          onClear: () {
                            setState(() => _activeDateFilter = 'All Time');
                            _applyFilter();
                          },
                        ),
                      if (_activeDateFilter != 'All Time' && _activeGenderFilter != 'All')
                        const SizedBox(width: 8),
                      if (_activeGenderFilter != 'All')
                        _ActiveFilterChip(
                          label: _activeGenderFilter,
                          isGender: true,
                          isDark: isDark,
                          onClear: () {
                            setState(() => _activeGenderFilter = 'All');
                            _applyFilter();
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 12),

            // ─── Card List ───
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _groupedCards.isEmpty
                      ? _buildEmptyState(theme, isDark)
                      : ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                          itemCount: _groupedCards.length,
                          itemBuilder: (context, index) {
                            final dateKey = _groupedCards.keys.elementAt(index);
                            final cards = _groupedCards[dateKey]!;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Date Header
                                Padding(
                                  padding: const EdgeInsets.only(top: 16, bottom: 8, left: 4),
                                  child: Text(
                                    dateKey,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                                // Cards for this date
                                ...cards.map((card) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: _WordTile(
                                    card: card,
                                    isDark: isDark,
                                    onDelete: () => _deleteCard(card),
                                  ),
                                )),
                              ],
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, bool isDark) {
    final hasSearch = _searchController.text.isNotEmpty || _activeGenderFilter != 'All' || _activeDateFilter != 'All Time';
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Icon(
              hasSearch ? Icons.search_off_rounded : Icons.menu_book_rounded,
              size: 44,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            hasSearch ? 'No matches found' : 'Library is empty',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            hasSearch
                ? 'Try a different search or filter.'
                : 'Scan a textbook page to add cards!',
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─── Active Filter Chip ───
class _ActiveFilterChip extends StatelessWidget {
  final String label;
  final bool isGender;
  final bool isDark;
  final VoidCallback onClear;

  const _ActiveFilterChip({
    required this.label,
    this.isGender = false,
    this.isDark = false,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Color color = theme.colorScheme.secondary;
    if (isGender) {
      if (label == 'der') color = AppTheme.getGenderColor('der', isDark);
      else if (label == 'die') color = AppTheme.getGenderColor('die', isDark);
      else if (label == 'das') color = AppTheme.getGenderColor('das', isDark);
      else color = theme.colorScheme.primary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onClear,
            child: Icon(Icons.close_rounded, size: 16, color: color),
          ),
        ],
      ),
    );
  }
}


// ─── Individual Word Tile ───
class _WordTile extends StatelessWidget {
  final Flashcard card;
  final bool isDark;
  final VoidCallback onDelete;

  const _WordTile({required this.card, required this.isDark, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final article = card.article ?? '';
    final genderColor = AppTheme.getGenderColor(article, isDark);
    final streakCount = card.consecutiveCorrect;

    return Dismissible(
      key: ValueKey(card.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: theme.colorScheme.error.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Icon(Icons.delete_outline_rounded, color: theme.colorScheme.error),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.15)),
        ),
        child: Row(
          children: [
            // Gender color dot
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: genderColor.withValues(alpha: isDark ? 0.15 : 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  article.isNotEmpty ? article : '—',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: genderColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Word + Translation
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    card.word ?? '',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    card.translation ?? '',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            // Streak indicator
            if (streakCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.tertiary.withValues(alpha: isDark ? 0.15 : 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.local_fire_department_rounded,
                        size: 14, color: theme.colorScheme.tertiary),
                    const SizedBox(width: 3),
                    Text(
                      '$streakCount',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.tertiary,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
