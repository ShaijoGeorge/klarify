import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:intl/intl.dart';
import '../../core/database/flashcard.dart';
import '../../core/theme/app_theme.dart';
import '../../main.dart';

class LibraryScreen extends StatefulWidget {
  final List<Flashcard>? initialCards;

  const LibraryScreen({super.key, this.initialCards});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  List<Flashcard> _allCards = [];
  Map<String, List<Flashcard>> _groupedCards = {};
  bool _isLoading = true;
  bool _isReverseStudy = false;

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
    if (widget.initialCards != null) {
      setState(() {
        _allCards = widget.initialCards!;
        _isLoading = false;
      });
      _applyFilter();
      return;
    }

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
    final scheme = theme.colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: scheme.surface,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        side: BorderSide(
          color: scheme.outline.withValues(alpha: isDark ? 0.15 : 0.3),
        ),
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
                    // Handle
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: scheme.outline.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Filters', style: theme.textTheme.titleMedium),
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
                          child: Text(
                            'Reset',
                            style: TextStyle(color: scheme.primary),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Date Filter
                    Text('Time Period', style: theme.textTheme.titleSmall),
                    const SizedBox(height: 10),
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
                          selectedColor: scheme.primaryContainer,
                          labelStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                            color: isActive ? scheme.primary : scheme.onSurfaceVariant,
                          ),
                          side: BorderSide(
                            color: isActive ? scheme.primary.withValues(alpha: 0.4) : scheme.outline.withValues(alpha: isDark ? 0.15 : 0.5),
                          ),
                          backgroundColor: scheme.surface,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    // Gender Filter
                    Text('Article (Gender)', style: theme.textTheme.titleSmall),
                    const SizedBox(height: 10),
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
                          chipColor = scheme.primary;
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
                          selectedColor: chipColor.withValues(alpha: isDark ? 0.2 : 0.12),
                          labelStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                            color: isActive ? chipColor : scheme.onSurfaceVariant,
                          ),
                          side: BorderSide(
                            color: isActive ? chipColor.withValues(alpha: 0.4) : scheme.outline.withValues(alpha: isDark ? 0.15 : 0.5),
                          ),
                          backgroundColor: scheme.surface,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // Done Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: FilledButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: FilledButton.styleFrom(
                          backgroundColor: scheme.primary,
                          foregroundColor: scheme.onPrimary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text('Show Results', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
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
    final scheme = theme.colorScheme;

    int totalFilteredCount = _groupedCards.values.fold(0, (sum, list) => sum + list.length);
    bool hasActiveFilters = _activeDateFilter != 'All Time' || _activeGenderFilter != 'All';

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Row(
                children: [
                  Text('Library', style: theme.textTheme.titleLarge),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isReverseStudy = !_isReverseStudy;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: scheme.surface,
                        border: Border.all(color: scheme.outline.withValues(alpha: isDark ? 0.15 : 0.5)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _isReverseStudy ? 'EN' : 'DE',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: scheme.primary,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.swap_horiz_rounded, size: 14, color: scheme.primary),
                          const SizedBox(width: 4),
                          Text(
                            _isReverseStudy ? 'DE' : 'EN',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: scheme.primary,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$totalFilteredCount cards',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: scheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Search Bar & Filter Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: scheme.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: scheme.outline.withValues(alpha: isDark ? 0.15 : 0.5),
                        ),
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: theme.textTheme.bodyLarge,
                        decoration: InputDecoration(
                          hintText: 'Search words…',
                          hintStyle: theme.textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                          prefixIcon: Icon(Icons.search_rounded, color: scheme.onSurfaceVariant, size: 20),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 13),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => _showFilterSheet(context),
                    child: Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: hasActiveFilters ? scheme.primary : scheme.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: hasActiveFilters
                              ? scheme.primary
                              : scheme.outline.withValues(alpha: isDark ? 0.15 : 0.5),
                        ),
                      ),
                      child: Icon(
                        hasActiveFilters ? Icons.filter_list_off_rounded : Icons.tune_rounded,
                        color: hasActiveFilters ? scheme.onPrimary : scheme.onSurfaceVariant,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Active Filter Chips
            if (hasActiveFilters) ...[
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SizedBox(
                  height: 32,
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
                        const SizedBox(width: 6),
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

            const SizedBox(height: 10),

            // Card List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _groupedCards.isEmpty
                      ? _buildEmptyState(theme, isDark)
                      : ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
                          itemCount: _groupedCards.length,
                          itemBuilder: (context, index) {
                            final dateKey = _groupedCards.keys.elementAt(index);
                            final cards = _groupedCards[dateKey]!;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Date Header
                                Padding(
                                  padding: const EdgeInsets.only(top: 14, bottom: 8, left: 4),
                                  child: Text(
                                    dateKey,
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: scheme.onSurfaceVariant,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                                // Cards for this date
                                ...cards.map((card) => Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: _WordTile(
                                    card: card,
                                    isDark: isDark,
                                    isReverseStudy: _isReverseStudy,
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
    final scheme = theme.colorScheme;
    final hasSearch = _searchController.text.isNotEmpty || _activeGenderFilter != 'All' || _activeDateFilter != 'All Time';
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasSearch ? Icons.search_off_rounded : Icons.menu_book_rounded,
              size: 64,
              color: scheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              hasSearch ? 'No matches found' : 'Library is empty',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hasSearch
                  ? 'Try a different search or filter.'
                  : 'Scan a textbook page to add cards!',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// Active Filter Chip
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
    final scheme = Theme.of(context).colorScheme;
    
    Color color = scheme.secondary;
    if (isGender) {
      if (label == 'der') {
        color = AppTheme.getGenderColor('der', isDark);
      } else if (label == 'die') {
        color = AppTheme.getGenderColor('die', isDark);
      } else if (label == 'das') {
        color = AppTheme.getGenderColor('das', isDark);
      } else {
        color = scheme.primary;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onClear,
            child: Icon(Icons.close_rounded, size: 14, color: color),
          ),
        ],
      ),
    );
  }
}


// Individual Word Tile
class _WordTile extends StatelessWidget {
  final Flashcard card;
  final bool isDark;
  final bool isReverseStudy;
  final VoidCallback onDelete;

  const _WordTile({
    required this.card,
    required this.isDark,
    required this.isReverseStudy,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final article = card.article?.trim().toLowerCase() ?? '';
    final isValidArticle = article == 'der' || article == 'die' || article == 'das';
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
          color: scheme.error.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(Icons.delete_outline_rounded, color: scheme.error),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: scheme.outline.withValues(alpha: isDark ? 0.15 : 0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0x08000000),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            // Gender color indicator
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: genderColor.withValues(alpha: isDark ? 0.15 : 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: isValidArticle
                    ? Text(
                        article,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: genderColor,
                        ),
                      )
                    : Icon(
                        Icons.sort_by_alpha_rounded,
                        size: 20,
                        color: genderColor,
                      ),
              ),
            ),
            const SizedBox(width: 12),
            // Word + Translation
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isReverseStudy ? (card.translation ?? '') : (card.word ?? ''),
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isReverseStudy ? (card.word ?? '') : (card.translation ?? ''),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            // Streak indicator
            if (streakCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: scheme.tertiary.withValues(alpha: isDark ? 0.15 : 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.local_fire_department_rounded,
                        size: 12, color: scheme.tertiary),
                    const SizedBox(width: 3),
                    Text(
                      '$streakCount',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: scheme.tertiary,
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
