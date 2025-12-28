import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../home/presentation/views/main_navigation_view.dart';
import '../../../onboarding/presentation/views/landing_view.dart';
import '../../../onboarding/presentation/views/onboarding_view.dart';
import '../controllers/auth_controller.dart';

class RootView extends ConsumerStatefulWidget {
  const RootView({super.key});

  @override
  ConsumerState<RootView> createState() => _RootViewState();
}

class _RootViewState extends ConsumerState<RootView> {
  bool _isLoading = true;
  bool _hasProfile = false;

  @override
  void initState() {
    super.initState();
    _checkAuthAndProfile();
  }

  Future<void> _checkAuthAndProfile() async {
    // AuthController initializes by checking currentSession.
    // However, when we first load, we might need to wait for it.
    // Actually, we can watch authProvider.
    // This methods is mainly for checking profile if auth is true.
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return authState.when(
      loading: () => const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, st) => LandingView(), // Default to landing on error
      data: (isAuthenticated) {
        if (!isAuthenticated) {
          return LandingView();
        }

        // Use a FutureBuilder or separate check for profile
        return const _ProfileCheckView();
      },
    );
  }
}

class _ProfileCheckView extends ConsumerStatefulWidget {
  const _ProfileCheckView();

  @override
  ConsumerState<_ProfileCheckView> createState() => _ProfileCheckViewState();
}

class _ProfileCheckViewState extends ConsumerState<_ProfileCheckView> {
  bool? _hasProfile;

  @override
  void initState() {
    super.initState();
    _checkProfile();
  }

  Future<void> _checkProfile() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        setState(() => _hasProfile = false);
        return;
      }

      final data = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (mounted) {
        setState(() {
          _hasProfile = data != null;
        });
      }
    } catch (e) {
      debugPrint("Error checking profile: $e");
      if (mounted) {
        setState(() => _hasProfile = false); // Default to onboarding?
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasProfile == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_hasProfile!) {
      return const MainNavigationView();
    } else {
      return const OnboardingView();
    }
  }
}
