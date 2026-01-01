import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:pandascroll/src/core/theme/app_colors.dart';
import 'package:pandascroll/src/features/subscription/presentation/widgets/upgrade_header.dart';
import 'package:pandascroll/src/features/subscription/presentation/widgets/selectable_plan_card.dart';
import 'package:pandascroll/src/features/subscription/presentation/widgets/upgrade_faq.dart';
import 'package:pandascroll/src/features/subscription/presentation/widgets/upgrade_stats_summary.dart';
import 'package:pandascroll/src/features/subscription/presentation/widgets/upgrade_bottom_bar.dart';
import 'package:pandascroll/src/features/onboarding/presentation/widgets/panda_button.dart';

class UpgradeView extends StatefulWidget {
  const UpgradeView({super.key});

  @override
  State<UpgradeView> createState() => _UpgradeViewState();
}

class _UpgradeViewState extends State<UpgradeView> {
  String _selectedPlan = 'yearly';

  @override
  Widget build(BuildContext context) {
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
                        onPressed: () {
                          // Restore purchase logic
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

                          Row(
                            children: [
                              Expanded(
                                child: SelectablePlanCard(
                                  title: "Monthly",
                                  price: "\$9",
                                  period: "mo",
                                  isSelected: _selectedPlan == 'monthly',
                                  onTap: () =>
                                      setState(() => _selectedPlan = 'monthly'),
                                ),
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                child: SelectablePlanCard(
                                  title: "Yearly",
                                  price: "\$59",
                                  period: "yr",

                                  isBestValue: true,
                                  isSelected: _selectedPlan == 'yearly',
                                  onTap: () =>
                                      setState(() => _selectedPlan = 'yearly'),
                                ),
                              ),
                            ],
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
              selectedPlan: _selectedPlan,
              onTap: () {
                // TODO: Implement purchase logic
                debugPrint("Upgrading to $_selectedPlan");
              },
            ),
          ),
        ],
      ),
    );
  }
}
