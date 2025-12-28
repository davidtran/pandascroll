import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/widgets.dart';
import '../../../profile/data/profile_repository.dart';

class PawState {
  final int count;
  final int maxCount;
  final DateTime? nextRegenTime;
  final int regenMinutes;

  const PawState({
    required this.count,
    required this.maxCount,
    this.nextRegenTime,
    this.regenMinutes = 30,
  });

  PawState copyWith({
    int? count,
    int? maxCount,
    DateTime? nextRegenTime,
    bool clearRegenTime = false,
    int? regenMinutes,
  }) {
    return PawState(
      count: count ?? this.count,
      maxCount: maxCount ?? this.maxCount,
      nextRegenTime: clearRegenTime
          ? null
          : (nextRegenTime ?? this.nextRegenTime),
      regenMinutes: regenMinutes ?? this.regenMinutes,
    );
  }
}

class PawNotifier extends AsyncNotifier<PawState> {
  Timer? _timer;

  @override
  FutureOr<PawState> build() async {
    final repo = ref.read(profileRepositoryProvider);
    final data = await repo.syncEnergy();

    // Parse data
    int energy = 5;
    int refillMinutes = 30;
    DateTime? lastUpdated;

    if (data != null) {
      if (data['energy'] != null) energy = data['energy'] as int;
      if (data['refill_minutes'] != null) {
        refillMinutes = data['refill_minutes'] as int;
      }
      if (data['last_energy_updated_at'] != null) {
        lastUpdated = DateTime.tryParse(
          data['last_energy_updated_at'].toString(),
        )?.toLocal();
      }
    }

    _startTimer(lastUpdated, energy, refillMinutes);

    return PawState(
      count: energy,
      maxCount: 5,
      regenMinutes: refillMinutes,
      nextRegenTime: _calculateNextRegen(lastUpdated, energy, refillMinutes),
    );
  }

  DateTime? _calculateNextRegen(DateTime? lastUpdated, int count, int minutes) {
    if (count >= 5 || lastUpdated == null) return null;
    return lastUpdated.add(Duration(minutes: minutes));
  }

  /// Tries to consume 1 paw. Returns true if successful.
  /// Tries to consume 1 paw. Returns true if successful.
  Future<bool> consume() async {
    final stateData = state.value;
    if (stateData == null || stateData.count <= 0) return false;

    // Optimistic Update
    final previousState = stateData;
    state = AsyncData(stateData.copyWith(count: stateData.count - 1));

    try {
      final repo = ref.read(profileRepositoryProvider);
      final result = await repo.spendEnergy();

      if (result != null) {
        // Update with real server state
        final newEnergy = result['energy'] as int;
        // Check if refill_minutes changed dynamically
        final newRefillMinutes =
            result['refill_minutes'] as int? ?? stateData.regenMinutes;

        final lastUpdated = DateTime.tryParse(
          result['last_energy_updated_at'].toString(),
        )?.toLocal();

        state = AsyncData(
          stateData.copyWith(
            count: newEnergy,
            regenMinutes: newRefillMinutes,
            nextRegenTime: _calculateNextRegen(
              lastUpdated,
              newEnergy,
              newRefillMinutes,
            ),
          ),
        );
        _startTimer(lastUpdated, newEnergy, newRefillMinutes);
        return true;
      } else {
        // Revert on failure
        state = AsyncData(previousState);
        return false;
      }
    } catch (e) {
      state = AsyncData(previousState);
      return false;
    }
  }

  /// Refunds a paw (e.g. game win).
  Future<void> refund() async {
    final stateData = state.value;
    if (stateData != null && stateData.count < stateData.maxCount) {
      // Optimistic update
      final newCount = stateData.count + 1;
      final previousState = stateData;

      state = AsyncData(
        stateData.copyWith(
          count: newCount,
          nextRegenTime: newCount >= stateData.maxCount
              ? null
              : stateData.nextRegenTime,
          clearRegenTime: newCount >= stateData.maxCount,
        ),
      );

      try {
        final repo = ref.read(profileRepositoryProvider);
        final result = await repo.refundEnergy();

        if (result != null) {
          final newEnergy = result['energy'] as int;
          // Check if refill_minutes changed dynamically
          final newRefillMinutes =
              result['refill_minutes'] as int? ?? stateData.regenMinutes;

          final lastUpdated = DateTime.tryParse(
            result['last_energy_updated_at'].toString(),
          )?.toLocal();

          state = AsyncData(
            stateData.copyWith(
              count: newEnergy,
              regenMinutes: newRefillMinutes,
              nextRegenTime: _calculateNextRegen(
                lastUpdated,
                newEnergy,
                newRefillMinutes,
              ),
            ),
          );
          _startTimer(lastUpdated, newEnergy, newRefillMinutes);
        } else {
          // Revert on failure?
          state = AsyncData(previousState);
        }
      } catch (e) {
        state = AsyncData(previousState);
      }
    }
  }

  void _startTimer(DateTime? lastUpdated, int count, int minutes) {
    _timer?.cancel();
    if (count < 5 && lastUpdated != null) {
      final next = lastUpdated.add(Duration(minutes: minutes));
      final now = DateTime.now();
      final diff = next.difference(now);

      if (!diff.isNegative) {
        _timer = Timer(diff, () {
          // Time reached!
          ref.invalidateSelf();
        });
      }
    }
  }
}

final pawProvider = AsyncNotifierProvider<PawNotifier, PawState>(
  PawNotifier.new,
);

final pawIconKeyProvider = Provider<GlobalKey>((ref) => GlobalKey());
final pandaIconKeyProvider = Provider<GlobalKey>((ref) => GlobalKey());
