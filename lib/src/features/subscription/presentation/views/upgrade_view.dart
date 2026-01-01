import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:pandascroll/src/features/subscription/presentation/providers/subscription_provider.dart';

import 'package:pandascroll/src/core/theme/app_colors.dart';
import 'package:pandascroll/src/features/subscription/presentation/widgets/upgrade_header.dart';
import 'package:pandascroll/src/features/subscription/presentation/widgets/selectable_plan_card.dart';
import 'package:pandascroll/src/features/subscription/presentation/widgets/upgrade_faq.dart';
import 'package:pandascroll/src/features/subscription/presentation/widgets/upgrade_stats_summary.dart';
import 'package:pandascroll/src/features/subscription/presentation/widgets/upgrade_bottom_bar.dart';
import 'package:pandascroll/src/features/onboarding/presentation/widgets/panda_button.dart';

class UpgradeView extends ConsumerStatefulWidget {
  const UpgradeView({super.key});

  @override
  ConsumerState<UpgradeView> createState() => _UpgradeViewState();
}

class _UpgradeViewState extends ConsumerState<UpgradeView> {
  Package? _selectedPackage;

  @override
  void initState() {
    super.initState();
    // Fetch offerings is handled by the provider's build method
  }

  String _formatTrial(IntroductoryPrice? price) {
    if (price == null) return '';
    final unit = price.periodUnit;
    final count = price.periodNumberOfUnits;
    String unitStr = '';
    switch (unit) {
      case PeriodUnit.day:
        unitStr = 'd';
        break;
      case PeriodUnit.week:
        unitStr = 'w';
        break;
      case PeriodUnit.month:
        unitStr = 'm';
        break;
      case PeriodUnit.year:
        unitStr = 'y';
        break;
      case PeriodUnit.unknown:
        unitStr = '';
        break;
    }
    return '$count$unitStr';
  }

  @override
  Widget build(BuildContext context) {
    final subscriptionState = ref.watch(subscriptionProvider);

    // Select default package if not set
    if (_selectedPackage == null &&
        subscriptionState.value?.offerings?.current != null) {
      final currentOffering = subscriptionState.value!.offerings!.current!;
      if (currentOffering.annual != null) {
        _selectedPackage = currentOffering.annual;
      } else if (currentOffering.monthly != null) {
        _selectedPackage = currentOffering.monthly;
      }
    }

    final currentOffering = subscriptionState.value?.offerings?.current;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background Elements
          Positioned(
            top: 40,
            right: 0,
            child: Container(
              width: 256,
              height: 256,
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
                  child: Container(color: Colors.transparent),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 0,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                color: AppColors.primaryBrand.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
                  child: Container(color: Colors.transparent),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top Bar (Close Button)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded, size: 28),
                        color: AppColors.pandaBlack,
                      ),
                      TextButton(
                        onPressed: () async {
                          await ref
                              .read(subscriptionProvider.notifier)
                              .restorePurchases();
                        },
                        child: const Text(
                          "Restore",
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 14, // Slightly larger for tap target
                            fontWeight: FontWeight.bold,
                            color: AppColors.textLight,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                      ), // Reduced from max-w-1000 logic, just good padding
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 16),
                          // Stats Summary (Motivation)
                          const UpgradeHeader(),
                          const SizedBox(height: 32),
                          const UpgradeStatsSummary(),

                          const SizedBox(height: 48),

                          // Plan Selection
                          const Center(
                            child: Text(
                              "Choose your plan",
                              style: TextStyle(
                                fontFamily: 'Fredoka',
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: AppColors.pandaBlack,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          if (subscriptionState.isLoading)
                            const Center(child: CircularProgressIndicator())
                          else if (currentOffering != null)
                            Row(
                              children: [
                                if (currentOffering.monthly != null)
                                  Expanded(
                                    child: SelectablePlanCard(
                                      title: "Monthly",
                                      price: currentOffering
                                          .monthly!
                                          .storeProduct
                                          .priceString,
                                      period: "mo",
                                      trial: _formatTrial(
                                        currentOffering
                                            .monthly!
                                            .storeProduct
                                            .introductoryPrice,
                                      ),
                                      isSelected:
                                          _selectedPackage ==
                                          currentOffering.monthly,
                                      onTap: () => setState(
                                        () => _selectedPackage =
                                            currentOffering.monthly,
                                      ),
                                    ),
                                  ),
                                const SizedBox(width: 24),
                                if (currentOffering.annual != null)
                                  Expanded(
                                    child: SelectablePlanCard(
                                      title: "Yearly",
                                      price: currentOffering
                                          .annual!
                                          .storeProduct
                                          .priceString,
                                      period: "yr",
                                      trial: _formatTrial(
                                        currentOffering
                                            .annual!
                                            .storeProduct
                                            .introductoryPrice,
                                      ),
                                      isBestValue: true,
                                      isSelected:
                                          _selectedPackage ==
                                          currentOffering.annual,
                                      onTap: () => setState(
                                        () => _selectedPackage =
                                            currentOffering.annual,
                                      ),
                                    ),
                                  ),
                              ],
                            )
                          else
                            const Center(
                              child: Text('Unable to fetch offerings'),
                            ),

                          const SizedBox(height: 32),

                          // FAQ
                          const UpgradeFAQ(),

                          // Spacer for fixed bottom CTA
                          const SizedBox(height: 140),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Fixed Bottom Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: UpgradeBottomBar(
              selectedPackage: _selectedPackage,
              onTap: () async {
                if (_selectedPackage != null) {
                  await ref
                      .read(subscriptionProvider.notifier)
                      .purchasePackage(_selectedPackage!);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
