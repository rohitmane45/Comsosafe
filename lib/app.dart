import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/providers/profile_provider.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/onboarding_screen.dart';

class CosmosafeApp extends StatelessWidget {
  const CosmosafeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileProvider()..load(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'CosmoSafe',
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.system,
        home: const _AppGate(),
      ),
    );
  }
}

/// Routes to onboarding or home depending on profile state.
class _AppGate extends StatelessWidget {
  const _AppGate();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProfileProvider>();

    // Still loading from SharedPreferences
    if (!provider.loaded) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // First launch — show onboarding
    if (!provider.onboardingComplete) {
      return const OnboardingScreen();
    }

    // Returning user — go home
    return const HomeScreen();
  }
}
