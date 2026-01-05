import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/dictionary_repository.dart';
import '../../domain/models/user_dictionary_model.dart';
import '../widgets/dictionary_entry_card.dart';
import '../../../feed/presentation/widgets/dictionary_panel.dart';

enum DictionaryFilter { recent, az, nouns, verbs, adverbs, favorites }

class MyDictionaryView extends ConsumerStatefulWidget {
  const MyDictionaryView({super.key});

  @override
  ConsumerState<MyDictionaryView> createState() => _MyDictionaryViewState();
}

class _MyDictionaryViewState extends ConsumerState<MyDictionaryView> {
  DictionaryFilter _selectedFilter = DictionaryFilter.recent;

  @override
  Widget build(BuildContext context) {
    final dictionaryAsync = ref.watch(userDictionaryProvider);

    return Scaffold(
      backgroundColor: AppColors.funBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(
              context,
              totalCount: dictionaryAsync.maybeWhen(
                data: (e) => e.length,
                orElse: () => 0,
              ),
            ),
            Expanded(
              child: dictionaryAsync.when(
                data: (entries) {
                  if (entries.isEmpty) {
                    return _buildEmptyState();
                  }

                  final filteredEntries = _filterEntries(entries);

                  if (filteredEntries.isEmpty) {
                    return _buildEmptyState(
                      message: "No words found for this category.",
                    );
                  }

                  // OPTIMIZATION: Choose how to build the list based on filter
                  if (_selectedFilter == DictionaryFilter.recent) {
                    return _buildOptimizedGroupedList(filteredEntries);
                  } else {
                    return _buildStandardList(filteredEntries);
                  }
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) {
                  debugPrint(err.toString());
                  return Center(child: Text('Error: $err'));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 1. Standard List for A-Z, Nouns, etc. (No headers needed)
  Widget _buildStandardList(List<UserDictionaryEntry> entries) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildEntryItem(context, entries[index]),
        );
      },
    );
  }

  /// 2. Optimized Grouped List (Flattens Headers + Items into one list)
  Widget _buildOptimizedGroupedList(List<UserDictionaryEntry> entries) {
    // Flatten the data into a list of specific items (Headers or Entries)
    final List<DictionaryListItem> flatList = [];

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final weekAgo = today.subtract(const Duration(days: 7));

    String? lastHeaderKey;

    for (var entry in entries) {
      final entryDate = entry.createdAt;
      final dateOnly = DateTime(entryDate.year, entryDate.month, entryDate.day);

      // Determine the group key
      String key;
      if (dateOnly == today) {
        key = 'Today';
      } else if (dateOnly == yesterday) {
        key = 'Yesterday';
      } else if (dateOnly.isAfter(weekAgo)) {
        key = 'This Week';
      } else {
        key = 'Older';
      }

      // If key changes, insert a HeaderItem first
      if (key != lastHeaderKey) {
        flatList.add(HeaderItem(key));
        lastHeaderKey = key;
      }

      // Then insert the EntryItem
      flatList.add(EntryItem(entry));
    }

    // Render using a single ListView.builder
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: flatList.length,
      itemBuilder: (context, index) {
        final item = flatList[index];

        if (item is HeaderItem) {
          return Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 12),
            child: _buildSectionHeader(item.title),
          );
        } else if (item is EntryItem) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildEntryItem(context, item.entry),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  List<UserDictionaryEntry> _filterEntries(List<UserDictionaryEntry> entries) {
    switch (_selectedFilter) {
      case DictionaryFilter.recent:
        // Assuming repo returns sorted by date DESC. If not, sort here.
        return entries;
      case DictionaryFilter.az:
        final sorted = List<UserDictionaryEntry>.from(entries);
        sorted.sort((a, b) => a.dictionary.word.compareTo(b.dictionary.word));
        return sorted;
      case DictionaryFilter.nouns:
        return entries
            .where((e) => e.dictionary.type.toLowerCase().contains('noun'))
            .toList();
      case DictionaryFilter.verbs:
        return entries
            .where((e) => e.dictionary.type.toLowerCase().contains('verb'))
            .toList();
      case DictionaryFilter.adverbs:
        return entries
            .where((e) => e.dictionary.type.toLowerCase().contains('adverb'))
            .toList();
      case DictionaryFilter.favorites:
        return [];
    }
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Expanded(child: Container(height: 2, color: Colors.grey[300])),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: Colors.grey[500],
              letterSpacing: 1.0,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Container(height: 2, color: Colors.grey[300])),
      ],
    );
  }

  Widget _buildEntryItem(BuildContext context, UserDictionaryEntry entry) {
    return DictionaryEntryCard(
      entry: entry,
      onTap: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.white,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          builder: (context) => DraggableScrollableSheet(
            initialChildSize: 0.85,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            expand: false,
            builder: (context, scrollController) => ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              child: DictionaryPanel(
                dictionaryId: entry.dictionaryId.toString(),
                data: entry.dictionary,
                language: entry.language,
                onClose: () => Navigator.pop(context),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterTabs() {
    final tabs = [
      {'label': 'Recent', 'filter': DictionaryFilter.recent},
      {'label': 'A-Z', 'filter': DictionaryFilter.az},
      {'label': 'Nouns', 'filter': DictionaryFilter.nouns},
      {'label': 'Verbs', 'filter': DictionaryFilter.verbs},
      {'label': 'Adverbs', 'filter': DictionaryFilter.adverbs},
    ];

    return Container(
      height: 40,
      margin: const EdgeInsets.only(top: 24, bottom: 10),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 0),
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        separatorBuilder: (c, i) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final tab = tabs[index];
          final filter = tab['filter'] as DictionaryFilter;
          final isSelected = _selectedFilter == filter;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedFilter = filter;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.pandaBlack : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.pandaBlack, width: 2),
              ),
              child: Text(
                tab['label'] as String,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.pandaBlack,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState({String? message}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/panda_treasure.png',
              width: 180,
              height: 180,
            ),
            const SizedBox(height: 24),
            Text(
              message ??
                  "New dictionary words will be collected when you do exercises and look up new words.",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontFamily: 'Fredoka',
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, {required int totalCount}) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      decoration: const BoxDecoration(
        color: AppColors.bambooLight,
        border: Border(
          bottom: BorderSide(color: AppColors.pandaBlack, width: 3),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.accentOrange,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.pandaBlack, width: 2),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.pandaBlack,
                          offset: Offset(2, 3),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.menu_book,
                      color: Colors.black,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "My Dictionary",
                    style: TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: AppColors.pandaBlack,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.funBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.cardSecondaryShadow,
                    width: 2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "TOTAL",
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: AppColors.pandaBlack,
                        height: 0.9,
                      ),
                    ),
                    Text(
                      "$totalCount ${totalCount == 1 ? "word" : "words"}",
                      style: const TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                        color: AppColors.pandaBlack,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          _buildFilterTabs(),
        ],
      ),
    );
  }
}

// ==========================================
// HELPER CLASSES FOR OPTIMIZED LIST RENDER
// ==========================================

abstract class DictionaryListItem {}

class HeaderItem implements DictionaryListItem {
  final String title;
  HeaderItem(this.title);
}

class EntryItem implements DictionaryListItem {
  final UserDictionaryEntry entry;
  EntryItem(this.entry);
}
