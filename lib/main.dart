import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:aquanoph/core/supabase/supabase_init.dart';
import 'package:aquanoph/core/theme/app_colors.dart';
import 'package:aquanoph/core/theme/app_fonts.dart';
import 'package:aquanoph/features/auth/presentation/controller/auth_provider.dart';
import 'package:aquanoph/features/auth/presentation/pages/sign_in_page.dart';
import 'package:aquanoph/features/pond/presentation/controller/pond_provider.dart';
import 'package:aquanoph/features/pond/presentation/pages/ponds_page.dart';

// ponytail: AuthGate lives in main as the app shell; feature pages live in their feature folder.
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
    if (!supabaseReady) return MaterialApp(title: 'Aquanoph', home: const _SetupHintPage());
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PondProvider()),
      ],
      child: MaterialApp(
        title: 'Aquanoph',
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
    return PondsPage(userId: auth.user!.id);
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
