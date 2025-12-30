import 'dart:math';
import 'dart:ui' as android;

import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pandascroll/src/features/onboarding/presentation/widgets/panda_button.dart';
import 'package:pandascroll/src/features/feed/presentation/widgets/quiz/tts_player.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/flashcards_repository.dart';
import '../../domain/models/flashcard_model.dart';
import 'package:pandascroll/src/features/profile/presentation/providers/profile_providers.dart';
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
  bool _isEnded = false;
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

  void onReset() {
    setState(() {
      _isEnded = false;
    });
    _loadCards();
  }

  Future<void> _loadCards() async {
    // For now, reloading calls repository directly or we can use ref.read
    final repository = ref.read(flashcardsRepositoryProvider);
    final profile = ref.read(userProfileProvider).value;
    final language = profile?['target_language'] ?? '';

    final results = await Future.wait([
      repository.getDueFlashcards(language),
      repository.getTotalFlashcardsCount(language),
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

    double newInterval = card.interval;
    double newEase = card.easeFactor;
    DateTime nextDueDate;

    // --- CONFIGURATION ---
    // If interval is less than this, we consider it "New/Learning"
    const double graduationThreshold = 1.0;

    switch (rating) {
      case CardRating.hard:
        // FIX 1: Hard should PUNISH the interval (shrink it), not grow it.
        // If it's a mature card, cut time in half. If new, set to 10 minutes (0.007 days).
        newInterval = (newInterval > 1.0) ? newInterval * 0.5 : 0.007;

        // Decrease ease (make it harder to grow in future)
        newEase = max(1.3, newEase - 0.20);
        break;

      case CardRating.good:
        if (newInterval < graduationThreshold) {
          // FIX 2: Learning Step. If new, jump to 1 day.
          newInterval = 1.0;
        } else {
          // Standard review: Grow by Ease Factor
          newInterval = newInterval * newEase;
        }
        break;

      case CardRating.easy:
        if (newInterval < graduationThreshold) {
          // If new but easy, jump straight to 3 days
          newInterval = 3.0;
        } else {
          // Grow fast + Bonus
          newInterval = newInterval * newEase * 1.3;
        }
        // Reward ease (make it grow faster in future)
        newEase += 0.15;
        break;
    }

    // Calculate strict date based on fractional days (e.g. 0.5 days = 12 hours)
    final durationInMinutes = (newInterval * 24 * 60).toInt();
    nextDueDate = DateTime.now().add(Duration(minutes: durationInMinutes));

    // --- UI FEEDBACK ---
    if (mounted) {
      String timeDisplay;
      if (newInterval < 1.0) {
        // Show Minutes/Hours if less than a day
        final minutes = (newInterval * 24 * 60).toInt();
        if (minutes < 60) {
          timeDisplay = "$minutes mins";
        } else {
          timeDisplay = "${(minutes / 60).toStringAsFixed(1)} hours";
        }
      } else {
        // Show Days
        timeDisplay = "${newInterval.toStringAsFixed(1)} days";
      }

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Review in $timeDisplay",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          backgroundColor: Colors.white,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(milliseconds: 1500),
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
    // Listen for external updates (e.g. adding a new card)
    ref.listen(flashcardsUpdateTriggerProvider, (_, __) {
      _loadCards();
    });

    // Reload when target language changes
    ref.listen(userProfileProvider.select((v) => v.value?['target_language']), (
      previous,
      next,
    ) {
      if (previous != next) {
        _loadCards();
      }
    });

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
        return Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/panda_study.png', height: 128),
                const SizedBox(height: 16),
                Text(
                  "no cards yet!",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Fredoka',
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "save words to start memorizing.",
                  style: TextStyle(color: Colors.white54, fontSize: 16),
                ),
              ],
            ),
          ),
        );
      }

      return const Scaffold(
        backgroundColor: Colors.black,
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
                "all caught up!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 31,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Fredoka',
                ),
              ),
              SizedBox(height: 8),
              Text(
                "the words in this stack will reappear later.",
                textAlign: .center,
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 21,
                  fontFamily: 'Nunito',
                ),
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
                          "reviewing",
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
                          "tap to flip",
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

                if (_isEnded) ...[
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "you finished this stack.",
                            style: const TextStyle(
                              fontFamily: 'Fredoka',
                              fontSize: 31,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          PandaButton(
                            text: 'start again',
                            onPressed: onReset,
                            backgroundColor: pandaWhite,
                            shadowColor: pandaWhite.withOpacity(0.2),
                            width: 200,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                if (!_isEnded) ...[
                  Expanded(
                    child: CardSwiper(
                      controller: _swiperController,
                      cardsCount: _reviewQueue.length,
                      isLoop: false,
                      onSwipe: (previousIndex, currentIndex, direction) {
                        if (currentIndex != null) {
                          _currentIndex = currentIndex;
                        }

                        // Map direction to rating
                        CardRating? rating;
                        if (direction == CardSwiperDirection.left) {
                          rating = CardRating.hard;
                        } else if (direction == CardSwiperDirection.right) {
                          rating = CardRating.easy;
                        } else if (direction == CardSwiperDirection.top ||
                            direction == CardSwiperDirection.bottom) {
                          rating = CardRating.good;
                        }

                        if (rating != null) {
                          _processReview(previousIndex, rating);
                        }
                        return true;
                      },
                      onEnd: () => {
                        setState(() {
                          _isEnded = true;
                        }),
                      },
                      threshold: 100,

                      numberOfCardsDisplayed: min(3, _reviewQueue.length),
                      padding: const EdgeInsets.all(24.0),

                      cardBuilder:
                          (
                            context,
                            index,
                            percentThresholdX,
                            percentThresholdY,
                          ) {
                            final card = _reviewQueue[index];
                            final isCardFlipped = _flippedIndices.contains(
                              index,
                            );

                            final opacityX = percentThresholdX / 300;
                            final opacityY = percentThresholdY / 300;

                            // Threshold for visibility
                            final showHard =
                                opacityX < -0.25; // Left swipe (negative X)
                            final showEasy =
                                opacityX > 0.25; // Right swipe (positive X)
                            final showGood =
                                opacityY.abs() >
                                0.25; // Top/Bottom swipe (Y axis)

                            return GestureDetector(
                              onTap: () => _flipCard(index),
                              key: ValueKey(card.id),
                              child: Stack(
                                children: [
                                  AnimatedSwitcher(
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

                                  // Overlays
                                  if (showHard)
                                    _buildSwipeOverlay(
                                      "HARD",
                                      Colors.redAccent,
                                      Alignment.topRight,
                                      opacity: (-opacityX).clamp(0.0, 1.0),
                                    ),
                                  if (showEasy)
                                    _buildSwipeOverlay(
                                      "EASY",
                                      Colors.orangeAccent,
                                      Alignment.topLeft,
                                      opacity: (opacityX).clamp(0.0, 1.0),
                                    ),
                                  if (showGood)
                                    _buildSwipeOverlay(
                                      "GOOD",
                                      const Color(0xFF13ec80),
                                      Alignment.center,
                                      opacity: (opacityY.abs()).clamp(0.0, 1.0),
                                    ),
                                ],
                              ),
                            );
                          },
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                // Footer Controls (Ratings trigger Swipes)
                if (!_isEnded)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Hard (Left)
                        _buildRatingFab(
                          "hard",
                          FaIcon(
                            FontAwesomeIcons.faceFrown,
                            color: Colors.black,
                            size: 16,
                          ),
                          Colors.redAccent,
                          () => _rateAndSwipe(CardRating.hard),
                        ),
                        // Good (Right)
                        _buildRatingFab(
                          "good",
                          FaIcon(
                            FontAwesomeIcons.faceMeh,
                            color: Colors.black,
                            size: 16,
                          ),
                          primaryGreen,
                          () => _rateAndSwipe(CardRating.good),
                        ),
                        // Easy (Top)
                        _buildRatingFab(
                          "easy",
                          FaIcon(
                            FontAwesomeIcons.faceGrinBeam,
                            color: Colors.black,
                            size: 16,
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
          mini: true,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w400,
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
              child: TtsPlayer(id: card.id, type: 'flashcard', autoPlay: true),
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

  Widget _buildSwipeOverlay(
    String text,
    Color color,
    Alignment alignment, {
    double opacity = 1.0,
  }) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Container(
          decoration: BoxDecoration(
            color: color.withOpacity(0.1 * opacity),
            borderRadius: BorderRadius.circular(64),
          ),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: color,
                  border: Border.all(
                    color: color.withOpacity(opacity),
                    width: 4,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'mark as',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                        color: Colors.white,
                        fontFamily: 'Fredoka',
                        letterSpacing: 2,
                      ),
                    ),
                    Text(
                      text,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Fredoka',
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
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
