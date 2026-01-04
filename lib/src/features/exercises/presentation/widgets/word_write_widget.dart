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
                // Question Box
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    // Main Content Box
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.funBg,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: AppColors.pandaBlack,
                          width: 3,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.pandaBlack,
                            offset: Offset(4, 4),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Text(
                                  widget.currentWord.translation,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontFamily: 'Fredoka',
                                    fontSize: 32,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.pandaBlack,
                                    height: 1.2,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Styled Audio Button
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.pandaBlack,
                                    width: 2,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black12,
                                      offset: Offset(0, 2),
                                      blurRadius: 0,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: TtsPlayer(
                                    id: widget.currentWord.id,
                                    type: 'dictionary',
                                    size: 24,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          // Optional: Provide context hint text below if needed
                          // const SizedBox(height: 8),
                          // Text("Type the meaning...", style: ...)
                        ],
                      ),
                    ),
                    // Floating Label
                    Positioned(
                      top: -14,
                      child: Transform.rotate(
                        angle: -0.02, // ~1 degree tilt
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.pandaBlack,
                              width: 2,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                offset: Offset(0, 2),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: const Text(
                            "TRANSLATE THIS",
                            style: TextStyle(
                              fontFamily: 'Fredoka', // Or system font
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.pandaBlack,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                // End Question Box
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
