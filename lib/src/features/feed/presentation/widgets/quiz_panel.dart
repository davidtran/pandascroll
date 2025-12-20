import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/models/exercise_model.dart';
import 'quiz/word_quiz_widget.dart';
import 'quiz/scramble_widget.dart';
import 'quiz/video_understanding_widget.dart';
import 'quiz/cloze_widget.dart';

import 'quiz/parrot_widget.dart';

class QuizPanel extends StatefulWidget {
  final String videoId;
  final String audioUrl;
  final Function(String title)? onTitleChanged;

  const QuizPanel({
    super.key,
    required this.videoId,
    required this.audioUrl,
    this.onTitleChanged,
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

  @override
  void initState() {
    super.initState();
    _fetchExercises();
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
      });
      _fetchExercises();
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
          final firstTitle = _getExerciseTitle(_exercises[0]);
          if (firstTitle != null) {
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

  @override
  Widget build(BuildContext context) {
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
            const SizedBox(height: AppSpacing.md),
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

    return Column(
      children: [
        // Progress Bar
        LinearProgressIndicator(
          value: (_currentIndex + 1) / _exercises.length,
          backgroundColor: Colors.grey.shade200,
          valueColor: const AlwaysStoppedAnimation<Color>(
            AppColors.primaryBrand,
          ),
          minHeight: 6,
        ),

        // Header with Navigation
        Padding(
          padding: const EdgeInsets.only(top: AppSpacing.md),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: _currentIndex > 0 ? _previousExercise : null,
                icon: const Icon(Icons.arrow_back_ios_rounded),
                color: AppColors.textMain,
                iconSize: 16,
              ),
              Text(
                "Question ${_currentIndex + 1}/${_exercises.length}",
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMain,
                ),
              ),
              IconButton(
                onPressed: _nextExercise,
                icon: const Icon(Icons.arrow_forward_ios_rounded),
                color: AppColors.textMain,
                iconSize: 16,
              ),
            ],
          ),
        ),

        // REMOVED Redundant Exercise Title (now in Panel Header)

        // Exercise Content
        Expanded(
          child: CustomScrollView(
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: _buildExerciseContent(currentExercise),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompletionScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.check_circle_outline_rounded,
            color: Colors.green,
            size: 80,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            "Congratulations!",
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textMain,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            "You have completed 100% of the exercises.",
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _currentIndex = 0;
                _isCompleted = false;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBrand,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.md,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.button),
              ),
            ),
            child: const Text(
              "Review Exercises",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
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
          onCorrect: _nextExercise,
        );
      case 'scramble':
        return ScrambleWidget(
          data: ScrambleData.fromJson(exercise.data),
          onCorrect: _nextExercise,
          audioUrl: widget.audioUrl,
        );
      case 'video_understanding':
        return VideoUnderstandingWidget(
          data: VideoUnderstandingData.fromJson(exercise.data),
          onCorrect: _nextExercise,
        );
      case 'cloze':
        return ClozeWidget(
          data: ClozeData.fromJson(exercise.data),
          onCorrect: _nextExercise,
          audioUrl: widget.audioUrl,
        );
      case 'parrot':
        return ParrotWidget(
          data: ParrotData.fromJson(exercise.data),
          onCorrect: _nextExercise,
          audioUrl: widget.audioUrl,
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
