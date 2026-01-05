import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pandascroll/src/features/exercises/presentation/controllers/video_exercise_controller.dart';
import 'package:pandascroll/src/features/exercises/presentation/widgets/exercise_progress_bar.dart';
import 'package:pandascroll/src/features/exercises/presentation/widgets/word_listen_widget.dart';
import 'package:pandascroll/src/features/exercises/presentation/widgets/word_quiz_widget.dart';
import 'package:pandascroll/src/features/exercises/presentation/widgets/word_speak_widget.dart';
import 'package:pandascroll/src/features/exercises/presentation/widgets/word_write_widget.dart';
import 'package:pandascroll/src/features/exercises/presentation/widgets/sentence_scramble_widget.dart';
import 'package:pandascroll/src/features/exercises/presentation/widgets/sentence_speak_widget.dart';
import 'package:pandascroll/src/features/exercises/presentation/widgets/sentence_dictation_widget.dart';

class WordGameWidget extends ConsumerWidget {
  final String videoId;
  final ExerciseState state;
  final VoidCallback onClose;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const WordGameWidget({
    super.key,
    required this.videoId,
    required this.state,
    required this.onClose,
    required this.onNext,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Widget gameContent;

    switch (state.stage) {
      case ExerciseStage.listen:
        print('start listen game');
        gameContent = WordListenWidget(
          videoId: videoId,
          currentWord: state.words[state.currentIndex],
          allWords: state.words,
          onCorrect: onNext,
        );
        break;
      case ExerciseStage.quiz:
        gameContent = WordQuizWidget(
          currentWord: state.words[state.currentIndex],
          allWords: state.words,
          onCorrect: onNext,
        );
        break;
      case ExerciseStage.speak:
        gameContent = WordSpeakWidget(
          currentWord: state.words[state.currentIndex],
          onCorrect: onNext,
        );
        break;
      case ExerciseStage.write:
        gameContent = WordWriteWidget(
          currentWord: state.words[state.currentIndex],
          onCorrect: onNext,
        );
        break;
      case ExerciseStage.sentenceScramble:
        gameContent = SentenceScrambleWidget(
          videoId: videoId,
          sentence: state.sentences[state.currentIndex],
          onCorrect: onNext,
        );
        break;
      case ExerciseStage.sentenceSpeak:
        gameContent = SentenceSpeakWidget(
          videoId: videoId,
          sentence: state.sentences[state.currentIndex],
          onCorrect: onNext,
        );
        break;
      case ExerciseStage.sentenceDictation:
        gameContent = SentenceDictationWidget(
          videoId: videoId,
          sentence: state.sentences[state.currentIndex],
          onCorrect: onNext,
        );
        break;
      default:
        return const SizedBox();
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.close, color: Colors.grey, size: 28),
                onPressed: onClose,
              ),
              Expanded(
                child: Center(
                  child: ExerciseProgressBar(
                    currentIndex: state.currentIndex,
                    total:
                        (state.stage == ExerciseStage.sentenceScramble ||
                            state.stage == ExerciseStage.sentenceSpeak)
                        ? state.sentences.length
                        : state.words.length,
                  ),
                ),
              ),
              // Balance out the close button
              const SizedBox(width: 48),
            ],
          ),
        ),
        Expanded(child: gameContent),
        Padding(
          padding: const EdgeInsets.only(bottom: 24, top: 8),
          child: TextButton(
            onPressed: onSkip,
            child: const Text(
              "Skip",
              style: TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
