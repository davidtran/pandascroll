import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:pandascroll/src/core/theme/app_colors.dart';
import 'package:pandascroll/src/core/theme/app_dimens.dart';
import 'package:pandascroll/src/core/theme/app_theme.dart';
import 'package:pandascroll/src/features/onboarding/presentation/widgets/panda_button.dart';

import '../../../../core/network/api_client.dart';
import '../../domain/models/exercise_model.dart';
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

    // clip-path: polygon(5% 0%, 100% 0%, 95% 100%, 0% 100%);
    // Adapt for rounded ends on first/last

    double slant = size.width * 0.1; // 10% slant or fixed
    if (slant > 6) slant = 6;

    // Moves: TL -> TR -> BR -> BL
    // Normal: (slant, 0) -> (w, 0) -> (w-slant, h) -> (0, h)

    double leftTopX = slant;
    double rightTopX = size.width;
    double rightBottomX = size.width - slant;
    double leftBottomX = 0;

    if (isFirst) {
      // First: Rounded Left.
      // Rect from 0 to W.
      // Let's use RRect for the left side?
      // Or just a path that rounds.
      // Simple approximation: (0,0) with radius...

      // Let's stick to the polygon logic but 'unslant' the left for first?
      // User Pill design: <div class="rounded-l-full ...">

      path.moveTo(size.height / 2, 0); // Start after arc top
      path.lineTo(rightTopX, 0);
      path.lineTo(rightBottomX, size.height);
      path.lineTo(size.height / 2, size.height);

      // add arc left
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
      height: 12, // h-3
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: List.generate(totalSteps, (index) {
          final isFirst = index == 0;
          final isLast = index == totalSteps - 1;

          Color color;
          // Logic: "passed" ones are correct/wrong. Future ones are light.
          // Is current index passed?
          // If index < statusList.length, use status.
          // Else unanswer.

          if (index < statusList.length) {
            final status = statusList[index];
            if (status == AnswerStatus.correct) {
              color = const Color(0xFF2B7FFF); // Blue ish
            } else if (status == AnswerStatus.wrong) {
              color = const Color(0xFFFF4B4B); // Red
            } else {
              color = AppColors.primaryBrand.withOpacity(0.3);
            }
          } else {
            color = AppColors.primaryBrand.withOpacity(0.3); // Inactive
          }

          // Special case for 'Current' active segment? User didn't specify.
          // Just "no answer yet = gray" (or light primary).

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1), // gap-1
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

class QuizPanel extends StatefulWidget {
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
  State<QuizPanel> createState() => _QuizPanelState();
}

class _QuizPanelState extends State<QuizPanel> {
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

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _fetchExercises();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playAudio({required double start, required double end}) async {
    print('play ${start} - ${end}');
    print(widget.audioUrl);
    try {
      if (start < end) {
        await _audioPlayer.setAudioSource(
          ClippingAudioSource(
            start: Duration(milliseconds: (start * 1000).toInt()),
            end: Duration(milliseconds: ((end + 5) * 1000).toInt()),
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
        _lives = 5; // Reset lives? assumption
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
          // Initialize answer status as unanswer? or leave empty and append?
          // List must match index? The progress bar is fixed size.
          // we track history.
        });
        print(_exercises);
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
      // Update logic: ensure we don't duplicate on retry?
      // If _currentIndex is already in _answerStatus (retry), update it?
      // Or just append.
      // Current Index: _currentIndex.
      if (_answerStatus.length <= _currentIndex) {
        _answerStatus.add(
          isCorrect ? AnswerStatus.correct : AnswerStatus.wrong,
        );
      } else {
        // Update existing (retry case)
        _answerStatus[_currentIndex] = isCorrect
            ? AnswerStatus.correct
            : AnswerStatus.wrong;
      }

      if (!isCorrect) {
        // Only decrement lives on first failure? Or every failure?
        // Simple logic: every failure.
        if (_lives > 0) _lives--;
      }
    });

    if (isCorrect) {
      _correctCount++;
      final correctAnswer = _getExerciseCorrectAnswer(
        _exercises[_currentIndex],
      );
      _showFeedback(true, correctAnswer: correctAnswer);
    } else {
      // Just update state, don't move next.
      // (Scramble/Cloze handles their own Retry/Feedback triggering).
      // But wait...
      // IF Scramble calls onWrong, it calls _handleAnswer(false).
      // My code in Scramble/Cloze: onWrong: () => _showFeedback(false).
      // They DO NOT call _handleAnswer(false) in my previous edit!
      // They call `_showFeedback` directly!
      // I need to update `_buildExerciseContent` to update status also.
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Always show the layout with Header
    return Column(
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
                child: const Icon(Icons.close, color: Colors.grey, size: 20),
              ),
            ],
          ),
        ),

        // 2. Content Area (Switch based on state)
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
                    style: TextButton.styleFrom(foregroundColor: Colors.grey),
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

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Congratulations!",
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textMain,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            "You answered $_correctCount/${_exercises.length} correctly ($percentage%).",
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          PandaButton(
            width: 200,
            onPressed: () {
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
            },
            text: "Next Video",
          ),
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
            // Handle Wrong: Update status + Show Feedback
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

    // Fallback titles if 'title' field is missing
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
