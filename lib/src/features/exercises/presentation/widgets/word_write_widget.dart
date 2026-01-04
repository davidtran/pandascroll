import 'package:flutter/material.dart';
import 'package:pandascroll/src/core/theme/app_colors.dart';
import 'package:pandascroll/src/features/feed/domain/models/dictionary_model.dart';
import 'package:pandascroll/src/features/feed/presentation/widgets/quiz/tts_player.dart';
import 'package:pandascroll/src/features/onboarding/presentation/widgets/panda_button.dart';

class WordWriteWidget extends StatefulWidget {
  final DictionaryModel currentWord;
  final VoidCallback onCorrect;

  const WordWriteWidget({
    super.key,
    required this.currentWord,
    required this.onCorrect,
  });

  @override
  State<WordWriteWidget> createState() => _WordWriteWidgetState();
}

class _WordWriteWidgetState extends State<WordWriteWidget> {
  final TextEditingController _controller = TextEditingController();
  bool _showError = false;
  bool _isCorrect = false;

  void _checkAnswer() {
    final input = _controller.text.trim().toLowerCase();
    final target = widget.currentWord.word.trim().toLowerCase();

    if (input == target) {
      setState(() {
        _isCorrect = true;
        _showError = false;
      });
      Future.delayed(const Duration(milliseconds: 1000), widget.onCorrect);
    } else {
      setState(() {
        _showError = true;
      });
    }
  }

  void _giveUp() {
    setState(() {
      _controller.text = widget.currentWord.word;
      _isCorrect = true; // technically gave up but we show answer
    });
    Future.delayed(const Duration(milliseconds: 1500), widget.onCorrect);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 32),
                const Text(
                  "Write this in Target Language",
                  style: TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 24),
                // Hint: Translation
                Text(
                  widget.currentWord.translation,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.pandaBlack,
                  ),
                ),
                const SizedBox(height: 16),
                // Audio Hint
                TtsPlayer(id: widget.currentWord.id, type: 'dictionary'),

                const SizedBox(height: 32),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: TextField(
                    controller: _controller,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.pandaBlack,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: _showError ? Colors.red[50] : Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: _showError ? Colors.red : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: _showError ? Colors.red : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: AppColors.bambooGreen,
                          width: 2,
                        ),
                      ),
                      hintText: "Type answer...",
                    ),
                    onSubmitted: (_) => _checkAnswer(),
                  ),
                ),

                if (_showError)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: const Text(
                      "Try again!",
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              PandaButton(text: "Check", onPressed: _checkAnswer, height: 56),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _giveUp,
                child: const Text(
                  "I don't know",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
