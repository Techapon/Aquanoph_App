import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

bool _supabaseReady = false;
bool get isSupabaseReady => _supabaseReady;

Future<void> loadEnv() => dotenv.load(fileName: '.env');

/// Throws StateError when .env still has placeholder values (app shows a setup hint instead of crashing).
Future<void> initSupabase() async {
  final url = dotenv.maybeGet('SUPABASE_URL');
  final anon = dotenv.maybeGet('SUPABASE_ANON_KEY');
  if (url == null || anon == null || url.contains('REPLACE_ME') || anon.contains('REPLACE_ME')) {
    throw StateError('Missing .env values: copy .env.example to .env and set SUPABASE_URL + SUPABASE_ANON_KEY');
  }
  await Supabase.initialize(url: url, publishableKey: anon);
  _supabaseReady = true;
}
