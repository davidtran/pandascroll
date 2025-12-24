import 'package:flutter_riverpod/flutter_riverpod.dart';

class OnboardingState {
  final String? nativeLanguage;
  final String? targetLanguage;
  final List<String> categories;
  final String? level;

  const OnboardingState({
    this.nativeLanguage,
    this.targetLanguage,
    this.categories = const [],
    this.level,
  });

  OnboardingState copyWith({
    String? nativeLanguage,
    String? targetLanguage,
    List<String>? categories,
    String? level,
  }) {
    return OnboardingState(
      nativeLanguage: nativeLanguage ?? this.nativeLanguage,
      targetLanguage: targetLanguage ?? this.targetLanguage,
      categories: categories ?? this.categories,
      level: level ?? this.level,
    );
  }
}

class OnboardingNotifier extends Notifier<OnboardingState> {
  @override
  OnboardingState build() {
    return const OnboardingState();
  }

  void setNativeLanguage(String code) {
    state = state.copyWith(nativeLanguage: code);
  }

  void setTargetLanguage(String code) {
    state = state.copyWith(targetLanguage: code);
  }

  void toggleCategory(String category) {
    final current = List<String>.from(state.categories);
    if (current.contains(category)) {
      current.remove(category);
    } else {
      current.add(category);
    }
    state = state.copyWith(categories: current);
  }

  void setLevel(String level) {
    state = state.copyWith(level: level);
  }
}

final onboardingProvider =
    NotifierProvider<OnboardingNotifier, OnboardingState>(
      OnboardingNotifier.new,
    );
