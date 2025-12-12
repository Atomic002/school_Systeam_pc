// lib/config/supabase_config.dart
// IZOH: Bu fayl Supabase ma'lumotlar bazasi sozlamalarini saqlaydi.
// URL va API key ni bu yerda kiritish kerak.

class SupabaseConfig {
  // Supabase loyihangizning URL manzili
  static const String supabaseUrl = 'https://bekibkfswdljsxwvcldg.supabase.co';

  // Supabase anon (public) API key
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJla2lia2Zzd2RsanN4d3ZjbGRnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQxMzM0MjksImV4cCI6MjA3OTcwOTQyOX0.LY4Yq5109c1eWSGIuKOafgljR5aDlpQ7Ac1zI0Q4n04';

  // Timeout vaqti (sekundlarda)
  static const int timeoutSeconds = 30;

  get client => null;

  // DIQQAT: Service role key ni frontend'da HECH QACHON ishlatmang!
  // Faqat backend/server-side operatsiyalar uchun.
}
