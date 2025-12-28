import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DailyGoalState {
  final int currentProgress;
  final int target;

  const DailyGoalState({required this.currentProgress, required this.target});

  DailyGoalState copyWith({int? currentProgress, int? target}) {
    return DailyGoalState(
      currentProgress: currentProgress ?? this.currentProgress,
      target: target ?? this.target,
    );
  }
}

class DailyGoalController extends AsyncNotifier<DailyGoalState> {
  static const _kProgressKey = 'daily_goal_progress';
  static const _kTargetKey = 'daily_goal_target';
  static const _kDateKey = 'daily_goal_date';

  @override
  Future<DailyGoalState> build() async {
    final prefs = await SharedPreferences.getInstance();

    final lastDate = prefs.getString(_kDateKey);
    final today = DateTime.now().toIso8601String().split('T').first;

    int progress = prefs.getInt(_kProgressKey) ?? 0;
    int target = prefs.getInt(_kTargetKey) ?? 5; // Default target

    // Reset if it's a new day
    if (lastDate != today) {
      progress = 0;
      await prefs.setString(_kDateKey, today);
      await prefs.setInt(_kProgressKey, 0);
    }

    return DailyGoalState(currentProgress: progress, target: target);
  }

  Future<void> addProgress(int amount) async {
    final currentState = state.value;
    if (currentState == null) return;

    final newProgress = currentState.currentProgress + amount;
    state = AsyncValue.data(
      currentState.copyWith(currentProgress: newProgress),
    );

    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T').first;

    await prefs.setInt(_kProgressKey, newProgress);
    await prefs.setString(_kDateKey, today);
  }

  Future<void> setTarget(int newTarget) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kTargetKey, newTarget);

    // Optimistically update if state is loaded
    if (state.hasValue) {
      state = AsyncValue.data(state.value!.copyWith(target: newTarget));
    } else {
      // If not loaded, we just saved it. Next build() will pick it up.
      // But we can also force refresh.
      ref.invalidateSelf();
    }
  }
}

final dailyGoalProvider =
    AsyncNotifierProvider<DailyGoalController, DailyGoalState>(
      DailyGoalController.new,
    );

// Provides a GlobalKey to locate the Daily Goal Icon for animations
final dailyGoalKeyProvider = Provider((ref) => GlobalKey());
