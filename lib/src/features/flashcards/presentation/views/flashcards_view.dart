import 'dart:math';
import 'dart:ui' as android;

import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/flashcards_repository.dart';
import '../../domain/models/flashcard_model.dart';
// Removed google_fonts import

enum CardRating { hard, good, easy }

class FlashcardsView extends ConsumerStatefulWidget {
  const FlashcardsView({super.key});

  @override
  ConsumerState<FlashcardsView> createState() => _FlashcardsViewState();
}

class _FlashcardsViewState extends ConsumerState<FlashcardsView> {
  // Using a local list to manage the review session locally
  // This prevents jitter from stream updates during a session
  List<FlashcardModel> _reviewQueue = [];
  int _totalCards = 0;
  bool _isLoading = true;
  // Track flipped state per card index
  final Set<int> _flippedIndices = {};
  int _currentIndex = 0;
  final CardSwiperController _swiperController = CardSwiperController();

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  @override
  void dispose() {
    _swiperController.dispose();
    super.dispose();
  }

  Future<void> _loadCards() async {
    // For now, reloading calls repository directly or we can use ref.read
    final repository = ref.read(flashcardsRepositoryProvider);
    final results = await Future.wait([
      repository.getDueFlashcards(),
      repository.getTotalFlashcardsCount(),
    ]);

    if (mounted) {
      final cards = results[0] as List<FlashcardModel>;
      final total = results[1] as int;

      setState(() {
        _reviewQueue = cards;
        _totalCards = total;
        _isLoading = false;
      });
    }
  }

  void _processReview(int index, CardRating rating) async {
    if (index >= _reviewQueue.length) return;
    final card = _reviewQueue[index];

    // SRS Logic
    double newInterval = card.interval;
    double newEase = card.easeFactor;
    DateTime nextDueDate;

    switch (rating) {
      case CardRating.hard:
        newInterval = newInterval * 1.2;
        newEase = max(1.3, newEase - 0.15);
        nextDueDate = DateTime.now().add(
          Duration(days: max(1, newInterval.toInt())),
        );
        break;

      case CardRating.good:
        newInterval = (newInterval == 0) ? 1 : newInterval * newEase;
        nextDueDate = DateTime.now().add(
          Duration(days: max(1, newInterval.toInt())),
        );
        break;

      case CardRating.easy:
        newInterval = (newInterval == 0) ? 4 : newInterval * newEase * 1.3;
        newEase += 0.15;
        nextDueDate = DateTime.now().add(
          Duration(days: max(1, newInterval.toInt())),
        );
        break;
    }

    if (mounted) {
      final days = max(1, newInterval.toInt());
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Marked as ${rating.name.toUpperCase()}. Review in $days day${days > 1 ? 's' : ''}.",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          backgroundColor: Colors.white,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        ),
      );
    }

    // Update DB
    try {
      await ref
          .read(flashcardsRepositoryProvider)
          .updateFlashcardReview(
            card.id,
            interval: newInterval,
            easeFactor: newEase,
            nextReviewAt: nextDueDate,
            status: 'review',
          );
    } catch (e) {
      debugPrint("Error updating flashcard: $e");
    } finally {
      if (mounted) {
        setState(() {
          _reviewQueue.removeWhere((c) => c.id == card.id);
        });
      }
    }
  }

  void _flipCard(int index) {
    setState(() {
      if (_flippedIndices.contains(index)) {
        _flippedIndices.remove(index);
      } else {
        _flippedIndices.add(index);
      }
    });
  }

  void _rateAndSwipe(CardRating rating) {
    // 1. Process the review (DB update + Snackbar)
    _processReview(_currentIndex, rating);

    // 2. Trigger the visual swipe
    // Map rating to direction
    CardSwiperDirection direction;
    switch (rating) {
      case CardRating.hard:
        direction = CardSwiperDirection.left;
        break;
      case CardRating.good:
        direction = CardSwiperDirection.right;
        break;
      case CardRating.easy:
        direction = CardSwiperDirection.top;
        break;
    }
    _swiperController.swipe(direction);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF102219), // panda-black
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primaryBrand),
        ),
      );
    }

    const pandaBlack = Color(0xFF102219);
    const primaryGreen = Color(0xFF13ec80);
    const accentOrange = Color(0xFFFF9F1C);
    const pandaWhite = Color(0xFFF6F8F7);
    const softGreen = Color(0xFFE0FBE6);

    if (_reviewQueue.isEmpty) {
      if (_totalCards == 0) {
        return const Scaffold(
          backgroundColor: Color(0xFF102219),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.save_alt_rounded, color: Colors.white54, size: 64),
                SizedBox(height: 16),
                Text(
                  "No cards yet!",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Nunito',
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Save words to start memorizing.",
                  style: TextStyle(color: Colors.white54, fontSize: 16),
                ),
              ],
            ),
          ),
        );
      }

      return const Scaffold(
        backgroundColor: pandaBlack,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle_outline_rounded,
                color: Color(0xFF13ec80),
                size: 80,
              ),
              SizedBox(height: 24),
              Text(
                "All caught up!",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Nunito',
                ),
              ),
              SizedBox(height: 8),
              Text(
                "Great job! Come back later.",
                style: TextStyle(color: Colors.white54, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    // Design Colors

    return Scaffold(
      backgroundColor: pandaBlack,
      body: Stack(
        children: [
          // Background Effects
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: primaryGreen.withOpacity(0.1),
                shape: BoxShape.circle,
                backgroundBlendMode: BlendMode.screen,
              ),
              child: BackdropFilter(
                filter: android.ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: accentOrange.withOpacity(0.1),
                shape: BoxShape.circle,
                backgroundBlendMode: BlendMode.screen,
              ),
              child: BackdropFilter(
                filter: android.ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Minimal Header (removed buttons as requested)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        Text(
                          "REVIEWING",
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                            color: Colors.white60,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Tap to Flip • Buttons to Rate",
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white38,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Expanded(
                  child: CardSwiper(
                    controller: _swiperController,
                    cardsCount: _reviewQueue.length,

                    numberOfCardsDisplayed: min(3, _reviewQueue.length),
                    padding: const EdgeInsets.all(24.0),

                    cardBuilder:
                        (context, index, percentThresholdX, percentThresholdY) {
                          final card = _reviewQueue[index];
                          final isCardFlipped = _flippedIndices.contains(index);

                          return GestureDetector(
                            onTap: () => _flipCard(index),
                            key: ValueKey(card.id),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 400),
                              transitionBuilder: (child, animation) {
                                final rotateAnim = Tween(
                                  begin: pi,
                                  end: 0.0,
                                ).animate(animation);
                                return AnimatedBuilder(
                                  animation: rotateAnim,
                                  builder: (context, child) {
                                    return Transform(
                                      transform: Matrix4.identity()
                                        ..setEntry(3, 2, 0.001)
                                        ..rotateY(
                                          (1 - animation.value) *
                                              pi /
                                              (child!.key ==
                                                      const ValueKey(true)
                                                  ? 1
                                                  : -1) *
                                              0,
                                        ),
                                      alignment: Alignment.center,
                                      child: FadeTransition(
                                        opacity: animation,
                                        child: ScaleTransition(
                                          scale: animation,
                                          child: child,
                                        ),
                                      ),
                                    );
                                  },
                                  child: child,
                                );
                              },
                              child: isCardFlipped
                                  ? _buildBackCard(
                                      card,
                                      pandaWhite,
                                      pandaBlack,
                                      primaryGreen,
                                      softGreen,
                                    )
                                  : _buildFrontCard(
                                      card,
                                      pandaWhite,
                                      pandaBlack,
                                      primaryGreen,
                                      softGreen,
                                    ),
                            ),
                          );
                        },
                  ),
                ),

                // Footer Controls (Ratings trigger Swipes)
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Hard (Left)
                      _buildRatingFab(
                        "Hard",
                        FaIcon(FontAwesomeIcons.faceFrown, color: Colors.black),
                        Colors.redAccent,
                        () => _rateAndSwipe(CardRating.hard),
                      ),
                      // Good (Right)
                      _buildRatingFab(
                        "Good",
                        FaIcon(FontAwesomeIcons.faceMeh, color: Colors.black),
                        primaryGreen,
                        () => _rateAndSwipe(CardRating.good),
                      ),
                      // Easy (Top)
                      _buildRatingFab(
                        "Easy",
                        FaIcon(
                          FontAwesomeIcons.faceGrinBeam,
                          color: Colors.black,
                        ),
                        accentOrange,
                        () => _rateAndSwipe(CardRating.easy),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingFab(
    String label,
    FaIcon icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          heroTag: label,
          onPressed: onTap,
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 4,
          child: icon,
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildFrontCard(
    FlashcardModel card,
    Color bg,
    Color text,
    Color primary,
    Color soft,
  ) {
    return Container(
      key: const ValueKey(false),
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 400),
      // height: 400,
      decoration: ShapeDecoration(
        color: Colors.white,
        shadows: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, 4),
            blurRadius: 8,
          ),
        ],
        shape: ContinuousRectangleBorder(
          borderRadius: BorderRadius.circular(64),
        ),
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: soft, shape: BoxShape.circle),
                child: const Icon(Icons.volume_up, color: Color(0xFF13ec80)),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  card.front,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 64,
                    fontWeight: FontWeight.w900,
                    color: text,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackCard(
    FlashcardModel card,
    Color bg,
    Color text,
    Color primary,
    Color soft,
  ) {
    final pronunciation = card.back.isNotEmpty ? card.back[0] : "";
    final definition = card.back.length > 1 ? card.back[1] : "";

    return Container(
      key: const ValueKey(true),
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 400),
      decoration: ShapeDecoration(
        color: bg,
        shadows: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, 4),
            blurRadius: 8,
          ),
        ],
        shape: ContinuousRectangleBorder(
          borderRadius: BorderRadius.circular(64),
        ),
      ),
      child: Column(
        mainAxisAlignment: .center,
        children: [
          const SizedBox(height: 48),
          Text(
            pronunciation,
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              definition,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: text,
                height: 1.4,
              ),
            ),
          ),

          // Example area (mocked or if data structure updated to support it fully later)
          if (card.back.length > 2) ...[
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: soft.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: primary.withOpacity(0.1)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 3,
                      height: 40,
                      color: primary.withOpacity(0.5),
                      margin: const EdgeInsets.only(right: 12),
                    ),
                    Expanded(
                      child: Text(
                        card.back[2], // Assuming 3rd element is example if exists
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 16,
                          color: text,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
