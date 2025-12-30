import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:just_audio/just_audio.dart';
import 'package:pandascroll/src/core/theme/app_colors.dart';
import 'package:pandascroll/src/core/theme/app_dimens.dart';

import '../../../../core/network/api_client.dart';
import '../../domain/models/exercise_model.dart';
import '../providers/stats_provider.dart';
import '../providers/paw_provider.dart';
import 'quiz/word_quiz_widget.dart';
import 'quiz/scramble_widget.dart';
import 'quiz/video_understanding_widget.dart';
import 'quiz/cloze_widget.dart';
import 'quiz/parrot_widget.dart';
import 'quiz/quiz_feedback_sheet.dart';
import 'quiz/quiz_completion_screen.dart';
import 'quiz/quiz_failed_screen.dart';
import 'quiz/word_preparation_screen.dart';
import '../../domain/models/word_preparation_model.dart';

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
      height: 8,
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
              color = AppColors.textLight.withOpacity(0.5);
            }
          } else {
            color = AppColors.textLight.withOpacity(0.5);
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
  final String language;

  const QuizPanel({
    super.key,
    required this.videoId,
    required this.audioUrl,
    this.onTitleChanged,
    required this.onClose,
    this.onNextVideo,
    required this.language,
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
  final Set<String> _correctExerciseIds = {};

  // Preparation State
  WordPreparationModel? _preparationData;
  bool _isPreparationCompleted = false;

  // Bamboo State
  List<AnswerStatus> _answerStatus = [];
  int _lives = 3; // Changed from 5 to 3
  DateTime? _startTime;

  late AudioPlayer _audioPlayer;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 1),
    );
    _startTime = DateTime.now();
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
        _correctExerciseIds.clear();
        _answerStatus = [];
        _lives = 3;
        _startTime = DateTime.now();
        _preparationData = null;
        _isPreparationCompleted = false;
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

  void _showNoEnergyDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Out of Energy! 🐾"),
        content: const Text(
          "You need more paws to play. Wait for them to regenerate.",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              widget.onClose(); // Close panel
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  Future<void> _fetchExercises() async {
    // 1. Check if user has enough paws (READ-ONLY)
    if (_exercises.isEmpty && _isLoading) {
      final pawState = ref.read(pawProvider).value;
      if (pawState == null || pawState.count <= 0) {
        if (mounted) _showNoEnergyDialog();
        return;
      }
    }

    try {
      final response = await ApiClient.get(
        '/exercises?video_id=${widget.videoId}&translate_language=Vietnamese',
      );

      // Fetch Preparation Data concurrently or sequentially
      // We do it sequentially here for simplicity and error handling
      WordPreparationModel? prepData;
      try {
        final prepResponse = await ApiClient.post(
          '/exercise_prepare?',
          body: {'video_id': widget.videoId},
        );
        if (prepResponse['data'] != null) {
          prepData = WordPreparationModel.fromJson(prepResponse['data']);
        }
      } catch (e) {
        debugPrint("Failed to fetch preparation data: $e");
        // We can continue without preparation data if it fails
      }

      if (!mounted) return;

      final List<dynamic> responseData = response['data'];
      final exercises = responseData.map((json) {
        return ExerciseModel.fromJson(json);
      }).toList();

      if (exercises.isNotEmpty) {
        // 2. Consume Paw (WRITE) - Only after successful load
        final pawNotifier = ref.read(pawProvider.notifier);
        final success = await pawNotifier.consume();

        if (!success) {
          if (mounted) _showNoEnergyDialog();
          return;
        }
      }

      if (mounted) {
        setState(() {
          _exercises = exercises;
          _preparationData = prepData;
          _isLoading = false;
          // If no prep data, mark as completed immediately
          if (prepData == null ||
              (prepData.words.isEmpty && prepData.sentences.isEmpty)) {
            _isPreparationCompleted = true;
          }
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

      final duration = _startTime != null
          ? DateTime.now().difference(_startTime!).inSeconds.toDouble()
          : 0.0;

      // Save Quiz Stats
      ref
          .read(statsRepositoryProvider)
          .insertExerciseResult(
            score: _correctCount.toDouble(),
            totalQuestions: _exercises.length.toDouble(),
            durationSeconds: duration,
            videoId: widget.videoId,
          );

      widget.onTitleChanged?.call("Level Complete! 🎉");

      // Check for success condition
      final success =
          _exercises.isNotEmpty && (_correctCount / _exercises.length) > 0.5;
      if (success) {
        // Refund Paw
        ref.read(pawProvider.notifier).refund();
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
          } else {
            if (_lives <= 0) {
              setState(() {}); // Trigger rebuild to show fail screen
            } else {
              _nextExercise();
            }
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
    });

    if (isCorrect) {
      final currentExercise = _exercises[_currentIndex];
      // Only increment score if this exercise hasn't been answered correctly before
      if (!_correctExerciseIds.contains(currentExercise.id)) {
        _correctExerciseIds.add(currentExercise.id);
        _correctCount++;
      }

      final correctAnswer = _getExerciseCorrectAnswer(currentExercise);
      _showFeedback(true, correctAnswer: correctAnswer);
    }
  }

  void _handleNextVideoOrReset() {
    if (widget.onNextVideo != null) {
      widget.onNextVideo!();
      _resetState();
    } else {
      _resetState();
    }
  }

  void _handleClose() {
    // Show confirm dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text("quit?"),
        content: const Text(
          "are you sure you want to quit? you will lose progress.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("cancel", style: TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              _resetState();
              widget.onClose();
            },
            child: const Text("quit", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _resetState() {
    setState(() {
      _currentIndex = 0;
      _isCompleted = false;
      _correctCount = 0;
      _correctExerciseIds.clear();
      _answerStatus = [];
      _lives = 3;
      _startTime = DateTime.now();
      _isPreparationCompleted = false;
    });
    if (firstTitle.isNotEmpty) {
      widget.onTitleChanged?.call(firstTitle);
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
                  Expanded(
                    child: BambooProgressBar(
                      totalSteps: _exercises.length,
                      statusList: _answerStatus,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Hearts Logic
                  Row(
                    children: List.generate(3, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Icon(
                          index < _lives
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: index < _lives ? Colors.red : Colors.grey[300],
                          size: 20,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _handleClose,
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

            if (!_isCompleted && _lives > 0 && !_isLoading)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        if (_preparationData != null &&
                            !_isPreparationCompleted) {
                          setState(() {
                            _isPreparationCompleted = true;
                          });
                        } else {
                          setState(() {
                            if (_answerStatus.length <= _currentIndex) {
                              _answerStatus.add(AnswerStatus.unanswer);
                            }
                            if (_lives > 0) _lives--;
                          });
                          _nextExercise();
                        }
                      },
                      style: TextButton.styleFrom(foregroundColor: Colors.grey),
                      child: Row(
                        mainAxisAlignment: .center,
                        children: [
                          Text(
                            (_preparationData != null &&
                                    !_isPreparationCompleted)
                                ? "Skip Preparation"
                                : "Skip Question",
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(width: 4),
                          if (_isPreparationCompleted)
                            FaIcon(FontAwesomeIcons.heartCrack, size: 14),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
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
    if (_lives <= 0) {
      return QuizFailedScreen(
        onRetry: () {
          // Retry logic if needed, currently just closes to retry externally
          _handleClose();
        },
        onClose: _handleClose,
      );
    }

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

    if (_preparationData != null && !_isPreparationCompleted) {
      return WordPreparationScreen(
        data: _preparationData!,
        onComplete: () {
          setState(() {
            _isPreparationCompleted = true;
          });
        },
        videoId: widget.videoId,
        language: widget.language,
      );
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
    return QuizCompletionScreen(
      exercises: _exercises,
      correctCount: _correctCount,
      onContinue: _handleNextVideoOrReset,
      onClaim: _handleNextVideoOrReset,
      videoId: widget.videoId,
    );
  }

  void _handleWrongAnswer(ExerciseModel exercise) {
    setState(() {
      if (_answerStatus.length <= _currentIndex) {
        _answerStatus.add(AnswerStatus.wrong);
      } else {
        _answerStatus[_currentIndex] = AnswerStatus.wrong;
      }
      if (_lives > 0) _lives--;
    });

    final correctAnswer = _getExerciseCorrectAnswer(exercise);

    // If lost last life, wait a bit then show fail screen?
    // Or show feedback first?
    // Let's show feedback, then on "Next" check lives.

    _showFeedback(false, correctAnswer: correctAnswer);
  }

  Widget _buildExerciseContent(ExerciseModel exercise) {
    final Key exerciseKey = ValueKey("exercise_${exercise.id}");
    switch (exercise.type) {
      case 'word_quiz':
        return WordQuizWidget(
          key: exerciseKey,
          data: WordQuizData.fromJson(exercise.data),
          onCorrect: () => _handleAnswer(true),
          onWrong: () => _handleWrongAnswer(exercise),
        );
      case 'scramble':
        return ScrambleWidget(
          key: exerciseKey,
          data: ScrambleData.fromJson(exercise.data),
          onCorrect: () => _handleAnswer(true),
          onWrong: () => _handleWrongAnswer(exercise),
          audioUrl: widget.audioUrl,
          onPlayAudio: _playAudio,
          onPauseAudio: _pauseAudio,
          audioStateStream: _audioPlayer.playerStateStream,
        );
      case 'video_understanding':
        return VideoUnderstandingWidget(
          key: exerciseKey,
          data: VideoUnderstandingData.fromJson(exercise.data),
          onCorrect: () => _handleAnswer(true),
        );
      case 'cloze':
        return ClozeWidget(
          key: exerciseKey,
          data: ClozeData.fromJson(exercise.data),
          onCorrect: () => _handleAnswer(true),
          onWrong: () => _handleWrongAnswer(exercise),
          audioUrl: widget.audioUrl,
          onPlayAudio: _playAudio,
          onPauseAudio: _pauseAudio,
          audioStateStream: _audioPlayer.playerStateStream,
        );
      case 'parrot':
        return ParrotWidget(
          key: exerciseKey,
          data: ParrotData.fromJson(exercise.data),
          onCorrect: () => _handleAnswer(true),
          onWrong: () => _handleWrongAnswer(exercise),
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
