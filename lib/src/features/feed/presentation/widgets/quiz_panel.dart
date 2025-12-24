import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:pandascroll/src/core/theme/app_colors.dart';
import 'package:pandascroll/src/core/theme/app_dimens.dart';
import 'package:pandascroll/src/features/onboarding/presentation/widgets/panda_button.dart';

import '../../../../core/network/api_client.dart';
import '../../domain/models/exercise_model.dart';
import '../controllers/daily_goal_controller.dart';
import 'quiz/word_quiz_widget.dart';
import 'quiz/scramble_widget.dart';
import 'quiz/video_understanding_widget.dart';
import 'quiz/cloze_widget.dart';
import 'quiz/parrot_widget.dart';
import 'quiz/quiz_feedback_sheet.dart';

// --- Bamboo Progress Components ---

enum AnswerStatus { unanswer, correct, wrong }

class BambooSegmentPainter extends CustomPainter {
  final Color color;
  final bool isFirst;
  final bool isLast;

  BambooSegmentPainter({
    required this.color,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final Path path = Path();

    double slant = size.width * 0.1;
    if (slant > 6) slant = 6;

    double leftTopX = slant;
    double rightTopX = size.width;
    double rightBottomX = size.width - slant;
    double leftBottomX = 0;

    if (isFirst) {
      path.moveTo(size.height / 2, 0);
      path.lineTo(rightTopX, 0);
      path.lineTo(rightBottomX, size.height);
      path.lineTo(size.height / 2, size.height);

      path.arcToPoint(
        Offset(size.height / 2, 0),
        radius: Radius.circular(size.height / 2),
        clockwise: true,
      );
    } else if (isLast) {
      path.moveTo(leftTopX, 0);
      path.lineTo(size.width - size.height / 2, 0);
      path.arcToPoint(
        Offset(size.width - size.height / 2, size.height),
        radius: Radius.circular(size.height / 2),
        clockwise: true,
      );
      path.lineTo(leftBottomX, size.height);
      path.lineTo(leftTopX, 0);
    } else {
      path.moveTo(leftTopX, 0);
      path.lineTo(rightTopX, 0);
      path.lineTo(rightBottomX, size.height);
      path.lineTo(leftBottomX, size.height);
      path.close();
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class BambooProgressBar extends StatelessWidget {
  final int totalSteps;
  final List<AnswerStatus> statusList;

  const BambooProgressBar({
    super.key,
    required this.totalSteps,
    required this.statusList,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 12,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: List.generate(totalSteps, (index) {
          final isFirst = index == 0;
          final isLast = index == totalSteps - 1;

          Color color;

          if (index < statusList.length) {
            final status = statusList[index];
            if (status == AnswerStatus.correct) {
              color = const Color(0xFF2B7FFF);
            } else if (status == AnswerStatus.wrong) {
              color = const Color(0xFFFF4B4B);
            } else {
              color = AppColors.primaryBrand.withOpacity(0.3);
            }
          } else {
            color = AppColors.primaryBrand.withOpacity(0.3);
          }

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1),
              child: CustomPaint(
                painter: BambooSegmentPainter(
                  color: color,
                  isFirst: isFirst,
                  isLast: isLast,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class QuizPanel extends ConsumerStatefulWidget {
  final String videoId;
  final String audioUrl;
  final Function(String title)? onTitleChanged;
  final VoidCallback onClose;
  final VoidCallback? onNextVideo;

  const QuizPanel({
    super.key,
    required this.videoId,
    required this.audioUrl,
    this.onTitleChanged,
    required this.onClose,
    this.onNextVideo,
  });

  @override
  ConsumerState<QuizPanel> createState() => _QuizPanelState();
}

class _QuizPanelState extends ConsumerState<QuizPanel> {
  bool _isLoading = true;
  String? _error;
  List<ExerciseModel> _exercises = [];
  int _currentIndex = 0;
  bool _isCompleted = false;
  String firstTitle = "";
  int _correctCount = 0;

  // Bamboo State
  List<AnswerStatus> _answerStatus = [];
  int _lives = 5;

  late AudioPlayer _audioPlayer;
  late ConfettiController _confettiController;
  final GlobalKey _pawIconKey = GlobalKey();

  // Animation State
  OverlayEntry? _flyingEntry;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
    _fetchExercises();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _playAudio({required double start, required double end}) async {
    try {
      if (start < end) {
        await _audioPlayer.setAudioSource(
          ClippingAudioSource(
            start: Duration(milliseconds: (start * 1000).toInt()),
            end: Duration(milliseconds: (end * 1000).toInt()),
            child: AudioSource.uri(Uri.parse(widget.audioUrl)),
          ),
        );
        await _audioPlayer.play();
      }
    } catch (e) {
      debugPrint("Error playing audio: $e");
    }
  }

  Future<void> _pauseAudio() async {
    await _audioPlayer.pause();
  }

  @override
  void didUpdateWidget(QuizPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoId != widget.videoId) {
      setState(() {
        _currentIndex = 0;
        _isCompleted = false;
        _exercises = [];
        _isLoading = true;
        _error = null;
        _correctCount = 0;
        _answerStatus = [];
        _lives = 5;
      });
      _fetchExercises();
    } else {
      if (!_isLoading && _exercises.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (firstTitle != "") {
            widget.onTitleChanged?.call(firstTitle);
          }
        });
      }
    }
  }

  Future<void> _fetchExercises() async {
    try {
      final response = await ApiClient.get(
        '/exercises?video_id=${widget.videoId}&translate_language=Vietnamese',
      );
      final List<dynamic> data = response['data'];

      if (mounted) {
        setState(() {
          _exercises = data.map((e) => ExerciseModel.fromJson(e)).toList();
          _isLoading = false;
        });
        if (_exercises.isNotEmpty) {
          firstTitle = _getExerciseTitle(_exercises[0]) ?? "";
          if (firstTitle != "") {
            widget.onTitleChanged?.call(firstTitle);
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _nextExercise() {
    if (_currentIndex < _exercises.length - 1) {
      setState(() {
        _currentIndex++;
      });
      final title = _getExerciseTitle(_exercises[_currentIndex]);
      if (title != null) {
        widget.onTitleChanged?.call(title);
      }
    } else {
      setState(() {
        _isCompleted = true;
      });
      widget.onTitleChanged?.call("Level Complete! 🎉");

      // Check for success condition
      final success =
          _exercises.isNotEmpty && (_correctCount / _exercises.length) > 0.5;
      if (success) {
        _confettiController.play();
      }
    }
  }

  void _previousExercise() {
    if (_isCompleted) {
      setState(() {
        _isCompleted = false;
      });
      final title = _getExerciseTitle(_exercises[_currentIndex]);
      if (title != null) {
        widget.onTitleChanged?.call(title);
      }
    } else if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
      final title = _getExerciseTitle(_exercises[_currentIndex]);
      if (title != null) {
        widget.onTitleChanged?.call(title);
      }
    }
  }

  void _showFeedback(bool isCorrect, {String? correctAnswer}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => QuizFeedbackSheet(
        isCorrect: isCorrect,
        correctAnswer: correctAnswer,
        audioUrl: widget.audioUrl,
        onNext: () {
          Navigator.pop(context);
          if (isCorrect) {
            _nextExercise();
          }
        },
        onRetry: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  String? _getExerciseCorrectAnswer(ExerciseModel exercise) {
    if (exercise.type == 'scramble') {
      final data = ScrambleData.fromJson(exercise.data);
      return data.sentenceText;
    } else if (exercise.type == 'video_understanding') {
      final data = VideoUnderstandingData.fromJson(exercise.data);
      return data.correctAnswer;
    } else if (exercise.type == 'cloze') {
      final data = ClozeData.fromJson(exercise.data);
      return data.correctAnswer;
    } else if (exercise.type == 'parrot') {
      final data = ParrotData.fromJson(exercise.data);
      return data.sentenceText;
    } else if (exercise.type == 'word_quiz') {
      final data = WordQuizData.fromJson(exercise.data);
      return "${data.word}: ${data.correctMeaning}";
    }
    return null;
  }

  void _handleAnswer(bool isCorrect) {
    setState(() {
      if (_answerStatus.length <= _currentIndex) {
        _answerStatus.add(
          isCorrect ? AnswerStatus.correct : AnswerStatus.wrong,
        );
      } else {
        _answerStatus[_currentIndex] = isCorrect
            ? AnswerStatus.correct
            : AnswerStatus.wrong;
      }

      if (!isCorrect) {
        if (_lives > 0) _lives--;
      }
    });

    if (isCorrect) {
      _correctCount++;
      final correctAnswer = _getExerciseCorrectAnswer(
        _exercises[_currentIndex],
      );
      _showFeedback(true, correctAnswer: correctAnswer);
    }
  }

  void _claimRewardAndFly() {
    // Get target position
    final targetGlobalKey = ref.read(dailyGoalKeyProvider);
    final RenderBox? targetBox =
        targetGlobalKey.currentContext?.findRenderObject() as RenderBox?;
    final RenderBox? startBox =
        _pawIconKey.currentContext?.findRenderObject() as RenderBox?;

    if (targetBox != null && startBox != null) {
      final startPos = startBox.localToGlobal(Offset.zero);
      final targetPos = targetBox.localToGlobal(Offset.zero);

      _flyingEntry = OverlayEntry(
        builder: (context) => _FlyingPawAnimation(
          startPos: startPos,
          targetPos: targetPos,
          onComplete: () {
            _flyingEntry?.remove();
            _flyingEntry = null;

            // Add Rewards
            ref.read(dailyGoalProvider.notifier).addProgress(_exercises.length);

            // Proceed to next video or reset
            _handleNextVideoOrReset();
          },
        ),
      );

      Overlay.of(context).insert(_flyingEntry!);
    } else {
      // Fallback if positions not found
      ref.read(dailyGoalProvider.notifier).addProgress(_exercises.length);
      _handleNextVideoOrReset();
    }
  }

  void _handleNextVideoOrReset() {
    if (widget.onNextVideo != null) {
      widget.onNextVideo!();
    } else {
      setState(() {
        _currentIndex = 0;
        _isCompleted = false;
        _correctCount = 0;
        _answerStatus = [];
        _lives = 5;
      });
      if (firstTitle.isNotEmpty) {
        widget.onTitleChanged?.call(firstTitle);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            // BAMBOO HEADER
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.favorite, color: Colors.red, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        "$_lives",
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          fontFamily: 'Fredoka',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(width: 12),
                  Expanded(
                    child: BambooProgressBar(
                      totalSteps: _exercises.length,
                      statusList: _answerStatus,
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => widget.onClose(),
                    child: const Icon(
                      Icons.close,
                      color: Colors.grey,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),

            // 2. Content Area
            Expanded(child: _buildBodyContent()),

            if (!_isCompleted)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => setState(() {
                        _currentIndex--;
                      }),
                      child: const Icon(
                        Icons.chevron_left,
                        color: Colors.grey,
                        size: 20,
                      ),
                    ),
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          // SKIP
                          setState(() {
                            if (_answerStatus.length <= _currentIndex) {
                              _answerStatus.add(AnswerStatus.unanswer);
                            }
                          });
                          _nextExercise();
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.grey,
                        ),
                        child: const Text(
                          "Skip Question",
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() {
                        _currentIndex++;
                      }),
                      child: const Icon(
                        Icons.chevron_right,
                        color: Colors.grey,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),

        // Confetti
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [
              Colors.green,
              Colors.blue,
              Colors.pink,
              Colors.orange,
              Colors.purple,
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBodyContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryBrand),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            Text(
              "Failed to load quiz",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _error = null;
                });
                _fetchExercises();
              },
              child: const Text("Retry"),
            ),
          ],
        ),
      );
    }

    if (_exercises.isEmpty) {
      return const Center(child: Text("No exercises found"));
    }

    if (_isCompleted) {
      return _buildCompletionScreen();
    }

    final currentExercise = _exercises[_currentIndex];

    return CustomScrollView(
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                Expanded(child: _buildExerciseContent(currentExercise)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompletionScreen() {
    final percentage = _exercises.isNotEmpty
        ? (_correctCount / _exercises.length * 100).round()
        : 0;

    final bool isSuccess =
        _exercises.isNotEmpty && (_correctCount / _exercises.length) > 0.5;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: AppSpacing.xl),
          Text(
            isSuccess ? "Awesome! 🎉" : "Good Try!",
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textMain,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            "You answered $_correctCount/${_exercises.length} correctly ($percentage%).",
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),

          if (isSuccess) ...[
            const SizedBox(height: AppSpacing.xl),
            const Text(
              "Total Reward",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.pandaBlack,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/paw.png',
                  width: 40,
                  height: 40,
                  key: _pawIconKey, // Start position for animation
                ),
                const SizedBox(width: 8),
                Text(
                  "x ${_exercises.length}", // Just using total exercises as reward count?
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.accent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            PandaButton(
              width: 200,
              onPressed: _claimRewardAndFly, // Claims and Shows animation
              text: "Claim",
            ),
          ] else ...[
            const SizedBox(height: AppSpacing.xl),
            PandaButton(
              width: 200,
              onPressed: _handleNextVideoOrReset,
              text: "Continue", // Or "Try Again"?
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildExerciseContent(ExerciseModel exercise) {
    switch (exercise.type) {
      case 'word_quiz':
        return WordQuizWidget(
          data: WordQuizData.fromJson(exercise.data),
          onCorrect: () => _handleAnswer(true),
        );
      case 'scramble':
        return ScrambleWidget(
          data: ScrambleData.fromJson(exercise.data),
          onCorrect: () => _handleAnswer(true),
          onWrong: () {
            setState(() {
              if (_answerStatus.length <= _currentIndex) {
                _answerStatus.add(AnswerStatus.wrong);
              } else {
                _answerStatus[_currentIndex] = AnswerStatus.wrong;
              }
              if (_lives > 0) _lives--;
            });
            final correctAnswer = _getExerciseCorrectAnswer(exercise);
            _showFeedback(false, correctAnswer: correctAnswer);
          },
          audioUrl: widget.audioUrl,
          onPlayAudio: _playAudio,
          onPauseAudio: _pauseAudio,
          audioStateStream: _audioPlayer.playerStateStream,
        );
      case 'video_understanding':
        return VideoUnderstandingWidget(
          data: VideoUnderstandingData.fromJson(exercise.data),
          onCorrect: () => _handleAnswer(true),
        );
      case 'cloze':
        return ClozeWidget(
          data: ClozeData.fromJson(exercise.data),
          onCorrect: () => _handleAnswer(true),
          onWrong: () {
            setState(() {
              if (_answerStatus.length <= _currentIndex) {
                _answerStatus.add(AnswerStatus.wrong);
              } else {
                _answerStatus[_currentIndex] = AnswerStatus.wrong;
              }
              if (_lives > 0) _lives--;
            });
            final correctAnswer = _getExerciseCorrectAnswer(exercise);
            _showFeedback(false, correctAnswer: correctAnswer);
          },
          audioUrl: widget.audioUrl,
          onPlayAudio: _playAudio,
          onPauseAudio: _pauseAudio,
          audioStateStream: _audioPlayer.playerStateStream,
        );
      case 'parrot':
        return ParrotWidget(
          data: ParrotData.fromJson(exercise.data),
          onCorrect: () => _handleAnswer(true),
          onWrong: () {
            setState(() {
              if (_answerStatus.length <= _currentIndex) {
                _answerStatus.add(AnswerStatus.wrong);
              } else {
                _answerStatus[_currentIndex] = AnswerStatus.wrong;
              }
              if (_lives > 0) _lives--;
            });
            _showFeedback(false);
          },
          audioUrl: widget.audioUrl,
          onPlayAudio: _playAudio,
          onPauseAudio: _pauseAudio,
          audioStateStream: _audioPlayer.playerStateStream,
        );
      default:
        return Center(child: Text("Unknown exercise type: ${exercise.type}"));
    }
  }

  String? _getExerciseTitle(ExerciseModel exercise) {
    if (exercise.data is Map<String, dynamic>) {
      final data = exercise.data as Map<String, dynamic>;
      if (data.containsKey('title')) {
        return data['title'] as String;
      }
    }

    switch (exercise.type) {
      case 'word_quiz':
        return 'Word Quiz';
      case 'scramble':
        return 'Order the Sentence';
      case 'video_understanding':
        return 'Video Understanding';
      case 'cloze':
        return 'Fill in the Blank';
      case 'parrot':
        return 'Repeat the Sentence';
      default:
        return null;
    }
  }
}

class _FlyingPawAnimation extends StatefulWidget {
  final Offset startPos;
  final Offset targetPos;
  final VoidCallback onComplete;

  const _FlyingPawAnimation({
    required this.startPos,
    required this.targetPos,
    required this.onComplete,
  });

  @override
  State<_FlyingPawAnimation> createState() => _FlyingPawAnimationState();
}

class _FlyingPawAnimationState extends State<_FlyingPawAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    // Scale down as it flies away
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.5).animate(_controller);

    _controller.forward().then((_) => widget.onComplete());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final currentX =
            widget.startPos.dx +
            (widget.targetPos.dx - widget.startPos.dx) * _animation.value;
        final currentY =
            widget.startPos.dy +
            (widget.targetPos.dy - widget.startPos.dy) * _animation.value;

        return Positioned(
          left: currentX,
          top: currentY,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Image.asset('assets/images/paw.png', width: 40, height: 40),
          ),
        );
      },
    );
  }
}
