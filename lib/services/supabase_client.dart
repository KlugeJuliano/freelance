// lib/services/supabase_client.dart
//
// Singleton de acesso ao cliente Supabase.
// Substitui qualquer referência à API Laravel.
//
// Setup no main.dart:
//   await Supabase.initialize(
//     url: 'https://SEU_PROJECT.supabase.co',
//     anonKey: 'SUA_ANON_KEY',
//   );

import 'package:supabase_flutter/supabase_flutter.dart';

/// Atalho global para o cliente Supabase.
final supabase = Supabase.instance.client;
