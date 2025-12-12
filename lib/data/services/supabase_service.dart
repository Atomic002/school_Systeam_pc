// lib/data/services/supabase_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  // Bitta umumiy Supabase client
  SupabaseClient get client => Supabase.instance.client;
}
