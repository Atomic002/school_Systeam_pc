// lib/config/app_bindings.dart
// GLOBAL bindlar: ilova ochilganda bir marta yaratiladi va
// Get.find() orqali hamma joyda ishlatiladi.

import 'package:get/get.dart';

import '../data/services/supabase_service.dart';
import '../presentation/controllers/auth_controller.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    // ====== GLOBAL SERVISLAR ======
    // Supabase bilan ishlash uchun bitta umumiy servis
    Get.put<SupabaseService>(
      SupabaseService(),
      permanent: true, // ilova yopilguncha xotirada turadi
    );

    // ====== GLOBAL CONTROLLERLAR ======
    // AuthController – foydalanuvchi ma'lumotlari, login/logout va hokazo
    Get.put<AuthController>(AuthController(), permanent: true);

    // Agar keyinchalik boshqa global controllerlar bo'lsa shu yerga qo'shasiz:
    // Get.put<ThemeController>(ThemeController(), permanent: true);
    // Get.put<LanguageController>(LanguageController(), permanent: true);
  }
}
