import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../flashcards/data/flashcards_repository.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_dimens.dart';
import '../../../../onboarding/presentation/widgets/panda_button.dart';
import '../../../domain/models/word_preparation_model.dart';
import 'word_audio_player.dart';

class WordPreparationScreen extends ConsumerStatefulWidget {
  final WordPreparationModel data;
  final VoidCallback onComplete;
  final String videoId;
  final String language;

  const WordPreparationScreen({
    super.key,
    required this.data,
    required this.onComplete,
    required this.videoId,
    required this.language,
  });

  @override
  ConsumerState<WordPreparationScreen> createState() =>
      _WordPreparationScreenState();
}

class _WordPreparationScreenState extends ConsumerState<WordPreparationScreen> {
  late PageController _pageController;
  int _currentIndex = 0;
  late List<dynamic> _items; // Contains both Words and Sentences
  Map<String, String> _audioMap = {};

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _items = [...widget.data.words, ...widget.data.sentences];
    _fetchAudio();
  }

  Future<void> _fetchAudio() async {
    try {
      final response = await ApiClient.get(
        '/audio?id=${widget.videoId}&type=video',
      );
      if (response['data'] != null) {
        final List<dynamic> list = response['data'];
        final map = <String, String>{};
        for (var item in list) {
          final text = item['text'] as String?;
          final url = item['url'] as String?;
          if (text != null && url != null) {
            map[text] = url;
          }
        }
        if (mounted) {
          setState(() {
            _audioMap = map;
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching audio: $e");
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentIndex < _items.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      widget.onComplete();
    }
  }

  void _previous() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_items.isEmpty) {
      // Should not happen if API returns data, but safety check
      WidgetsBinding.instance.addPostFrameCallback((_) => widget.onComplete());
      return const SizedBox();
    }

    final total = _items.length;
    final progress = (_currentIndex + 1) / total;

    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              Image.asset(
                'assets/images/panda_study.png',
                width: 20,
                height: 20,
              ),
              const SizedBox(width: 8),
              Text(
                "Preparation",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const Spacer(),
              Text(
                "${_currentIndex + 1}/$total",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[200],
          valueColor: const AlwaysStoppedAnimation(AppColors.primaryBrand),
        ),

        Expanded(
          child: PageView.builder(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(), // Force use buttons
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemCount: _items.length,
            itemBuilder: (context, index) {
              final item = _items[index];
              final bool isCurrent = index == _currentIndex;

              if (item is WordItem) {
                return _buildWordCard(item, isCurrent);
              } else if (item is SentenceItem) {
                return _buildSentenceCard(item, isCurrent);
              }
              return const SizedBox();
            },
          ),
        ),

        // Bottom Actions
        Padding(
          padding: const EdgeInsets.only(
            left: AppSpacing.md,
            right: AppSpacing.md,
            top: AppSpacing.md,
          ),
          child: Row(
            children: [
              SizedBox(
                width: 60,
                child: PandaButton(
                  onPressed: _previous,
                  text: "",
                  icon: Icons.arrow_back,
                  backgroundColor: AppColors.primaryBrand,
                  height: 50,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 1,
                child: PandaButton(
                  onPressed: _next,
                  height: 50,
                  text: _currentIndex == _items.length - 1
                      ? "Start Exercise"
                      : "Next",
                  icon: Icons.arrow_forward,
                  backgroundColor: AppColors.primaryBrand,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _markWordAsKnown(String word) async {
    final cleanWord = word
        .trim()
        .replaceAll(RegExp(r'^[^\w]+|[^\w]+$'), '')
        .toLowerCase();
    if (cleanWord.isEmpty) return;

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      await Supabase.instance.client.from('user_known_words').upsert({
        'user_id': userId,
        'word': cleanWord,
        'language': widget.language,
      }, onConflict: 'user_id,word,language');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Word marked as known. It won't appear in future exercises.",
              style: TextStyle(color: Colors.black),
            ),
            backgroundColor: Colors.amberAccent,

            duration: Duration(seconds: 2),
          ),
        );
        if (_currentIndex < _items.length - 1) {
          _next();
        } else {
          widget.onComplete();
        }
      }
    } catch (e) {
      debugPrint("Error marking word as known: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  Widget _buildWordCard(WordItem word, bool autoPlay) {
    final audioUrl = _audioMap[word.word];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Word Header
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(color: Colors.black),
              boxShadow: [
                BoxShadow(
                  color: Colors.black,
                  blurRadius: 0,
                  offset: const Offset(4, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.5),
                            blurRadius: 0,
                            offset: const Offset(4, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        word.type.toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.accent,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () async {
                            try {
                              await ref
                                  .read(flashcardsRepositoryProvider)
                                  .addFlashcard(
                                    front: word.word,
                                    back: [
                                      word.pronunciation,
                                      word.translation,
                                      if (word.examples.isNotEmpty)
                                        word.examples.first.text,
                                    ],
                                    videoId: widget.videoId,
                                    language: widget.language,
                                  );

                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Added to Flashcards"),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                                // Configure automatic reload
                                ref
                                    .read(
                                      flashcardsUpdateTriggerProvider.notifier,
                                    )
                                    .trigger();
                                // Also refresh badge count
                                ref.refresh(flashcardsDueCountProvider);
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Error: $e"),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                          icon: const Icon(
                            Icons.bookmark_add_outlined,
                            color: AppColors.pandaBlack,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      word.word,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.pandaBlack,
                      ),
                    ),
                    if (audioUrl != null) ...[
                      const SizedBox(width: 8),
                      WordAudioPlayer(url: audioUrl, autoPlay: autoPlay),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  word.pronunciation,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  word.translation,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          GestureDetector(
            onTap: () => _markWordAsKnown(word.word),
            child: Text(
              "mark as known",
              textAlign: .center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSentenceCard(SentenceItem sentence, bool autoPlay) {
    final audioUrl = _audioMap[sentence.text];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(color: Colors.black),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black,
                  blurRadius: 0,
                  offset: Offset(4, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Header: Key Sentence Badge + Save Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        "KEY SENTENCE",
                        style: TextStyle(
                          color: Colors.orange[800],
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        try {
                          await ref
                              .read(flashcardsRepositoryProvider)
                              .addFlashcard(
                                front: sentence.text,
                                back: [sentence.translation],
                                videoId: widget.videoId,
                                language: widget.language,
                              );

                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Added to Flashcards",
                                  style: TextStyle(color: AppColors.pandaBlack),
                                ),
                                duration: Duration(seconds: 1),
                                backgroundColor: Colors.amberAccent,
                              ),
                            );
                            ref
                                .read(flashcardsUpdateTriggerProvider.notifier)
                                .trigger();
                            ref.refresh(flashcardsDueCountProvider);
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Error: $e"),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      icon: const Icon(
                        Icons.bookmark_add_outlined,
                        color: AppColors.pandaBlack,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Sentence Text + Audio Icon
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        sentence.text,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    if (audioUrl != null) ...[
                      const SizedBox(width: 8),
                      WordAudioPlayer(url: audioUrl, autoPlay: autoPlay),
                    ],
                  ],
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 24),
                Text(
                  sentence.translation,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textLight,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
