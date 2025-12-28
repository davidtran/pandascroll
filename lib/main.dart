import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'src/core/theme/app_theme.dart';
import 'src/features/onboarding/presentation/views/landing_view.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'src/features/auth/presentation/controllers/auth_controller.dart';
import 'src/features/auth/presentation/views/root_view.dart';
import 'src/features/feed/presentation/views/feed_view.dart';

import 'src/core/utils/navigation.dart';
import 'src/core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://qdtjmwttsqlbstpvmzja.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFkdGptd3R0c3FsYnN0cHZtemphIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjU4ODk2NDgsImV4cCI6MjA4MTQ2NTY0OH0.FDURrsLWDC6zDF8XA4wJNDDs-RjSU3gAmkR4S1N7L1E',
  );

  await NotificationService().init();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'PandaScroll',
      theme: AppTheme.lightTheme,
      home: const RootView(),
      debugShowCheckedModeBanner: false,
    );
  }
}
