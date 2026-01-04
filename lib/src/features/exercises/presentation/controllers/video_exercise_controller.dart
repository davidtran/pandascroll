import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/models/exercise_response.dart';
import '../../../feed/domain/models/dictionary_model.dart';

final videoExerciseProvider =
    AsyncNotifierProvider.family<
      VideoExerciseController,
      ExerciseState,
      String
    >(VideoExerciseController.new);

enum ExerciseStage {
  picker,
  loading,
  review,
  quiz,
  listen,
  speak,
  write,
  sentenceReview,
  completed,
}

class ExerciseState {
  final List<DictionaryModel> words;
  final Map<String, List<String>> wordOptions;
  final int currentIndex;
  final ExerciseStage stage;

  ExerciseState({
    this.words = const [],
    this.wordOptions = const {},
    this.currentIndex = 0,
    this.stage = ExerciseStage.picker,
  });

  ExerciseState copyWith({
    List<DictionaryModel>? words,
    Map<String, List<String>>? wordOptions,
    int? currentIndex,
    ExerciseStage? stage,
  }) {
    return ExerciseState(
      words: words ?? this.words,
      wordOptions: wordOptions ?? this.wordOptions,
      currentIndex: currentIndex ?? this.currentIndex,
      stage: stage ?? this.stage,
    );
  }
}

class VideoExerciseController extends AsyncNotifier<ExerciseState> {
  final String videoId;

  VideoExerciseController(this.videoId);

  @override
  Future<ExerciseState> build() async {
    // Start with picker, no data loaded yet
    return ExerciseState(stage: ExerciseStage.picker);
  }

  Future<void> startWordExercise() async {
    state = AsyncValue.data(
      state.value!.copyWith(stage: ExerciseStage.loading),
    );
    try {
      final response = await ApiClient.post(
        '/exercise_prepare_word',
        body: {'video_id': videoId},
      );
      final data = ExerciseResponse.fromJson(response);
      state = AsyncValue.data(
        state.value!.copyWith(
          stage: ExerciseStage.review,
          words: data.words,
          wordOptions: data.wordOptions,
          currentIndex: 0,
        ),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void startSentenceExercise() {
    state = AsyncValue.data(
      state.value!.copyWith(stage: ExerciseStage.sentenceReview),
    );
  }

  void nextWord() {
    final currentState = state.value;
    if (currentState == null) return;

    if (currentState.currentIndex < currentState.words.length - 1) {
      state = AsyncValue.data(
        currentState.copyWith(currentIndex: currentState.currentIndex + 1),
      );
    } else {
      // End of valid words for this stage, move to next stage
      _advanceStage(currentState);
    }
  }

  void _advanceStage(ExerciseState currentState) {
    switch (currentState.stage) {
      case ExerciseStage.review:
        state = AsyncValue.data(
          currentState.copyWith(stage: ExerciseStage.quiz, currentIndex: 0),
        );
        break;
      case ExerciseStage.quiz:
        state = AsyncValue.data(
          currentState.copyWith(stage: ExerciseStage.speak, currentIndex: 0),
        );
        break;
      case ExerciseStage.speak:
        state = AsyncValue.data(
          currentState.copyWith(stage: ExerciseStage.write, currentIndex: 0),
        );
        break;
      case ExerciseStage.write:
        // All word exercises done.
        state = AsyncValue.data(
          currentState.copyWith(
            stage: ExerciseStage.completed,
            currentIndex: 0,
          ),
        );
        break;
      default:
        break;
    }
  }

  void skipReview() {
    // Check current stage and skip to next phase?
    // Or just next word? Assuming next word for now.
    nextWord();
  }
}
