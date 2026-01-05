import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/models/exercise_dictionary_model.dart';
import '../../domain/models/exercise_response.dart';
import '../../domain/models/sentence_exercise_model.dart';

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
  sentenceScramble,
  sentenceSpeak,
  sentenceDictation,
  completed,
}

class ExerciseState {
  final List<ExerciseDictionaryModel> words;
  final List<SentenceExerciseModel> sentences;
  final Map<String, List<String>> wordOptions;
  final int currentIndex;
  final int sessionScore;

  final ExerciseStage stage;

  ExerciseState({
    this.words = const [],
    this.sentences = const [],
    this.wordOptions = const {},
    this.currentIndex = 0,
    this.sessionScore = 0,
    this.stage = ExerciseStage.picker,
  });

  ExerciseState copyWith({
    List<ExerciseDictionaryModel>? words,
    List<SentenceExerciseModel>? sentences,
    Map<String, List<String>>? wordOptions,
    int? currentIndex,
    int? sessionScore,
    ExerciseStage? stage,
  }) {
    return ExerciseState(
      words: words ?? this.words,
      sentences: sentences ?? this.sentences,
      wordOptions: wordOptions ?? this.wordOptions,
      currentIndex: currentIndex ?? this.currentIndex,
      sessionScore: sessionScore ?? this.sessionScore,
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
          sentences: const [],
          currentIndex: 0,
          sessionScore: 0,
        ),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> startSentenceExercise() async {
    state = AsyncValue.data(
      state.value!.copyWith(stage: ExerciseStage.loading),
    );
    try {
      final response = await ApiClient.post(
        '/exercise_prepare_sentence',
        body: {'video_id': videoId},
      );

      final data = response['data'] ?? response;
      final sentences = (data['sentences'] as List)
          .map((e) => SentenceExerciseModel.fromJson(e))
          .toList();

      state = AsyncValue.data(
        state.value!.copyWith(
          stage: ExerciseStage.sentenceReview,
          sentences: sentences,
          words: const [],
          wordOptions: const {},
          currentIndex: 0,
          sessionScore: 0,
        ),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void nextWord() {
    final currentState = state.value;
    if (currentState == null) return;

    int totalItems = 0;
    if (currentState.stage == ExerciseStage.sentenceScramble ||
        currentState.stage == ExerciseStage.sentenceReview ||
        currentState.stage == ExerciseStage.sentenceSpeak ||
        currentState.stage == ExerciseStage.sentenceDictation) {
      totalItems = currentState.sentences.length;
    } else {
      totalItems = currentState.words.length;
    }

    if (currentState.currentIndex < totalItems - 1) {
      state = AsyncValue.data(
        currentState.copyWith(currentIndex: currentState.currentIndex + 1),
      );
    } else {
      // End of valid items for this stage, move to next stage
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
          currentState.copyWith(stage: ExerciseStage.listen, currentIndex: 0),
        );
        break;
      case ExerciseStage.listen:
        state = AsyncValue.data(
          currentState.copyWith(
            stage: ExerciseStage.completed,
            currentIndex: 0,
          ),
        );
        break;

      case ExerciseStage.sentenceReview:
        state = AsyncValue.data(
          currentState.copyWith(
            stage: ExerciseStage.sentenceScramble,
            currentIndex: 0,
          ),
        );
        break;

      case ExerciseStage.sentenceScramble:
        state = AsyncValue.data(
          currentState.copyWith(
            stage: ExerciseStage.sentenceSpeak,
            currentIndex: 0,
          ),
        );
        break;

      case ExerciseStage.sentenceSpeak:
        state = AsyncValue.data(
          currentState.copyWith(
            stage: ExerciseStage.sentenceDictation,
            currentIndex: 0,
          ),
        );
        break;

      case ExerciseStage.sentenceDictation:
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

  Future<void> markWordAsKnown(String word, String language) async {
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
        'language': language,
      }, onConflict: 'user_id,word,language');

      nextWord();
    } catch (e) {
      debugPrint("Error marking word as known: $e");
    }
  }

  void skipReview() {
    final currentState = state.value;
    if (currentState == null) return;
    _advanceStage(currentState);
  }

  void incrementScore() {
    final currentState = state.value;
    if (currentState == null) return;
    state = AsyncValue.data(
      currentState.copyWith(sessionScore: currentState.sessionScore + 1),
    );
  }

  Future<void> saveExerciseResult() async {
    final currentState = state.value;
    if (currentState == null) return;

    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    String type = 'word';
    int total = currentState.words.length;

    if (currentState.sentences.isNotEmpty) {
      type = 'sentence';
      total = currentState.sentences.length;
    }

    try {
      await Supabase.instance.client.from('video_exercise_results').upsert({
        'user_id': userId,
        'video_id': videoId,
        'score': currentState.sessionScore,
        'total_questions': total,
        'type': type,
      }, onConflict: 'user_id,video_id');
    } catch (e) {
      debugPrint("Error saving exercise result: $e");
    }
  }

  void resetToPicker() {
    state = AsyncValue.data(ExerciseState(stage: ExerciseStage.picker));
  }
}
