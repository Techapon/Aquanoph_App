import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:aquanoph/core/supabase/supabase_init.dart';
import 'package:aquanoph/core/theme/app_colors.dart';
import 'package:aquanoph/core/theme/app_fonts.dart';
import 'package:aquanoph/features/auth/presentation/controller/auth_provider.dart';
import 'package:aquanoph/features/auth/presentation/pages/sign_in_page.dart';

// ponytail: AuthGate + placeholder live in main as the app shell.
// Phase 2 replaces the placeholder with features/pond pages (then move gate if needed).
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await loadEnv();
  try {
    await initSupabase();
  } catch (_) {
    // keep running; app shows a setup-hint screen (isSupabaseReady == false)
  }
  runApp(AquanophApp(supabaseReady: isSupabaseReady));
}

class AquanophApp extends StatelessWidget {
  final bool supabaseReady;
  const AquanophApp({super.key, required this.supabaseReady});

  @override
  Widget build(BuildContext context) {
    if (!supabaseReady) return MaterialApp(title: 'NamDee', home: const _SetupHintPage());
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AuthProvider())],
      child: MaterialApp(
        title: 'NamDee',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(fontFamily: AppFonts.body, scaffoldBackgroundColor: Colors.white),
        home: const _AuthGate(),
      ),
    );
  }
}

class _AuthGate extends StatefulWidget {
  const _AuthGate();

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<AuthProvider>().loadSession());
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (!auth.bootstrapped) return const Scaffold(backgroundColor: Colors.white, body: Center(child: CircularProgressIndicator()));
    if (auth.user == null) return const SignInPage();
    return const _PondPlaceholderPage();
  }
}

class _PondPlaceholderPage extends StatelessWidget {
  const _PondPlaceholderPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('NamDee', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: AppFonts.heading, color: AppColors.textPrimary)),
        actions: [
          TextButton(
            onPressed: () => context.read<AuthProvider>().doSignOut(),
            child: const Text('Sign out', style: TextStyle(color: AppColors.textSecondary)),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: const Center(
        child: Text(
          'Pond list — Phase 2',
          style: TextStyle(fontSize: 18, fontFamily: AppFonts.heading, color: AppColors.textSecondary),
        ),
      ),
    );
  }
}

class _SetupHintPage extends StatelessWidget {
  const _SetupHintPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            'Copy .env.example to .env and set SUPABASE_URL + SUPABASE_ANON_KEY, then restart the app.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, fontFamily: AppFonts.body, color: AppColors.textPrimary),
          ),
        ),
      ),
    );
  }
}
