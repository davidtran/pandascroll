import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:pandascroll/src/features/subscription/data/subscription_repository.dart';

final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  return SubscriptionRepository();
});

class SubscriptionState {
  final CustomerInfo? customerInfo;
  final Offerings? offerings;
  final bool isLoading;

  SubscriptionState({
    this.customerInfo,
    this.offerings,
    this.isLoading = false,
  });

  bool get isPro {
    if (customerInfo == null) return false;
    return customerInfo!.entitlements.active.containsKey('lingodrip Pro');
  }

  SubscriptionState copyWith({
    CustomerInfo? customerInfo,
    Offerings? offerings,
    bool? isLoading,
  }) {
    return SubscriptionState(
      customerInfo: customerInfo ?? this.customerInfo,
      offerings: offerings ?? this.offerings,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class SubscriptionNotifier extends AsyncNotifier<SubscriptionState> {
  late final SubscriptionRepository _repository;

  @override
  Future<SubscriptionState> build() async {
    _repository = ref.read(subscriptionRepositoryProvider);
    await _repository.init();

    final offerings = await _repository.getOfferings();
    final customerInfo = await _repository.getCustomerInfo();

    return SubscriptionState(
      customerInfo: customerInfo,
      offerings: offerings,
      isLoading: false,
    );
  }

  Future<void> purchasePackage(Package package) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final customerInfo = await _repository.purchasePackage(package);
      final currentOfferings = state.value?.offerings;
      // if cancelled, customerInfo is null, keep old state but loading false
      return SubscriptionState(
        customerInfo: customerInfo ?? state.value?.customerInfo,
        offerings: currentOfferings,
        isLoading: false,
      );
    });
  }

  Future<void> restorePurchases() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final customerInfo = await _repository.restorePurchases();
      return SubscriptionState(
        customerInfo: customerInfo ?? state.value?.customerInfo,
        offerings: state.value?.offerings,
        isLoading: false,
      );
    });
  }
}

final subscriptionProvider =
    AsyncNotifierProvider<SubscriptionNotifier, SubscriptionState>(() {
      return SubscriptionNotifier();
    });
