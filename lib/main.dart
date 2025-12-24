// lib/main.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'config/supabase_config.dart';
import 'config/app_routes.dart';
import 'config/app_bindings.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/auth/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Supabase init
  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );

  // Sana formatlari uchun (uz)
  await initializeDateFormatting('uz', null);

  runApp(const SchoolSystemApp());
}

class SchoolSystemApp extends StatelessWidget {
  const SchoolSystemApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'School System',
      debugShowCheckedModeBanner: false,

      // GLOBAL bindlar (SupabaseService, AuthController va h.k.)
      initialBinding: AppBindings(),

      // ========================================================
      // 1. LOCALIZATION SOZLAMALARI (DatePicker xatosini tuzatadi)
      // ========================================================
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('uz', 'UZ'), // O'zbek tili
        Locale('en', 'US'), // Ingliz tili
        Locale('ru', 'RU'), // Rus tili
      ],
      // ========================================================

      // Asosiy til
      locale: const Locale('uz', 'UZ'),

      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,

      initialRoute: AppRoutes.login,
      getPages: AppRoutes.routes,

      unknownRoute: GetPage(name: '/not-found', page: () => LoginScreen()),
    );
  }
}