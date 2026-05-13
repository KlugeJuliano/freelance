import 'package:supabase_flutter/supabase_flutter.dart';

// Acesso global ao cliente — use SupabaseService.client em qualquer lugar
class SupabaseService {
  SupabaseService._();

  static SupabaseClient get client => Supabase.instance.client;

  // Inicializado no main() antes do runApp
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: const String.fromEnvironment('SUPABASE_URL'),
      anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
    );
  }
}
