import 'package:flutter/material.dart';
import 'package:pandascroll/src/core/theme/app_colors.dart';

import '../../domain/models/language_option.dart';
import 'selectable_option_card.dart';

class LanguageSelectorWidget extends StatefulWidget {
  final List<LanguageOption> languages;
  final String? selectedLanguageCode;
  final ValueChanged<String> onSelected;
  final bool showSearch;

  const LanguageSelectorWidget({
    super.key,
    required this.languages,
    required this.selectedLanguageCode,
    required this.onSelected,
    this.showSearch = true,
  });

  @override
  State<LanguageSelectorWidget> createState() => _LanguageSelectorWidgetState();
}

class _LanguageSelectorWidgetState extends State<LanguageSelectorWidget> {
  late TextEditingController _searchController;
  late List<LanguageOption> _filteredLanguages;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filteredLanguages = widget.languages;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void didUpdateWidget(LanguageSelectorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.languages != oldWidget.languages) {
      _filterLanguages(_searchController.text);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _filterLanguages(_searchController.text);
  }

  void _filterLanguages(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredLanguages = widget.languages;
      } else {
        _filteredLanguages = widget.languages
            .where(
              (lang) =>
                  lang.name.toLowerCase().contains(query.toLowerCase()) ||
                  lang.subtitle.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Search Bar
        if (widget.showSearch) ...[
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: "search languages...",
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // List
        ListView.builder(
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: _filteredLanguages.length,
          itemBuilder: (context, index) {
            final lang = _filteredLanguages[index];
            final isSelected = widget.selectedLanguageCode == lang.code;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Opacity(
                    opacity: lang.available ? 1.0 : 0.5,
                    child: SelectableOptionCard(
                      title: lang.name,
                      subtitle: lang.subtitle,
                      imageUrl: lang.flagUrl,
                      isSelected: isSelected,
                      onTap: () {
                        if (lang.available) {
                          widget.onSelected(lang.code);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("${lang.name} is coming soon!"),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  if (!lang.available)
                    Positioned(
                      right: -8,
                      top: -8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orangeAccent,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              offset: Offset(0, 2),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                        child: const Text(
                          "SOON",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
