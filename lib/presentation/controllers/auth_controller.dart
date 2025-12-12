// lib/presentation/controllers/auth_controller.dart
// IZOH: Authentication controller - login, logout, avtomatik kirish

import 'package:get/get.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';
import '../../config/app_routes.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();

  // Reactive variables
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Getter metodlar
  bool get isAuthenticated => currentUser.value != null;
  String? get userId => currentUser.value?.id;
  String? get userRole => currentUser.value?.role;

  @override
  void onInit() {
    super.onInit();
    // ✅ Ilova ochilganda avtomatik kirish tekshirish
    _checkAuthStatus();
  }

  // ========== AVTOMATIK KIRISH TEKSHIRISH ==========
  // Ilova ochilganda bu metod ishga tushadi
  Future<void> _checkAuthStatus() async {
    try {
      print('🔍 Saqlangan sessiyani tekshirish...');

      // 1. SharedPreferences dan saqlangan user ID ni olish
      final savedUserId = await _authRepository.getSavedUserId();

      if (savedUserId != null) {
        print('✅ Saqlangan user topildi: $savedUserId');

        // 2. User ma'lumotlarini ma'lumotlar bazasidan olish
        final user = await _authRepository.getUserById(savedUserId);

        if (user != null && user.isActive) {
          // 3. Foydalanuvchi aktiv - kirish
          currentUser.value = user;
          print('✅ Avtomatik kirish: ${user.fullName}');

          // 4. Dashboard ga yo'naltirish
          Get.offAllNamed(AppRoutes.dashboard);
        } else {
          print('❌ User aktiv emas yoki topilmadi');
        }
      } else {
        print('ℹ️ Saqlangan sessiya yo\'q - login kerak');
      }
    } catch (e) {
      print('❌ Check auth status xatolik: $e');
    }
  }

  // ========== LOGIN ==========
  Future<void> login({
    required String username,
    required String password,
    bool rememberMe = false, // ← YANGI parametr
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Validatsiya
      if (username.isEmpty) {
        errorMessage.value = 'Foydalanuvchi nomini kiriting';
        return;
      }
      if (password.isEmpty) {
        errorMessage.value = 'Parolni kiriting';
        return;
      }

      // Login qilish (rememberMe parametri bilan)
      final user = await _authRepository.login(
        username: username,
        password: password,
        rememberMe: rememberMe, // ← Bu yerda uzatiladi
      );

      if (user != null) {
        currentUser.value = user;

        // Success xabari
        Get.snackbar(
          'Muvaffaqiyatli',
          'Xush kelibsiz, ${user.fullName}!',
          snackPosition: SnackPosition.TOP,
          duration: Duration(seconds: 2),
        );

        // Dashboard'ga o'tish
        Get.offAllNamed(AppRoutes.dashboard);
      } else {
        errorMessage.value = 'Login yoki parol noto\'g\'ri';
      }
    } catch (e) {
      errorMessage.value = 'Xatolik yuz berdi: ${e.toString()}';
      print('Login xatolik: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ========== LOGOUT ==========
  Future<void> logout() async {
    try {
      isLoading.value = true;

      await _authRepository.logout(); // ← Sessiyani o'chiradi
      currentUser.value = null;

      // Login sahifasiga qaytish
      Get.offAllNamed(AppRoutes.login);

      Get.snackbar(
        'Chiqish',
        'Tizimdan muvaffaqiyatli chiqdingiz',
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      Get.snackbar(
        'Xatolik',
        'Chiqishda xatolik yuz berdi',
        snackPosition: SnackPosition.TOP,
      );
      print('Logout xatolik: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ========== PAROLNI YANGILASH ==========
  Future<bool> updatePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      if (newPassword.length < 6) {
        errorMessage.value =
            'Yangi parol kamida 6 ta belgidan iborat bo\'lishi kerak';
        return false;
      }

      final success = await _authRepository.updatePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );

      if (success) {
        Get.snackbar(
          'Muvaffaqiyatli',
          'Parol yangilandi',
          snackPosition: SnackPosition.TOP,
        );
        return true;
      } else {
        errorMessage.value = 'Parolni yangilashda xatolik';
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Xatolik: ${e.toString()}';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ========== PROFILNI YANGILASH ==========
  Future<bool> updateProfile(UserModel user) async {
    try {
      isLoading.value = true;

      final success = await _authRepository.updateUserProfile(user);

      if (success) {
        currentUser.value = user;
        Get.snackbar(
          'Muvaffaqiyatli',
          'Profil ma\'lumotlari yangilandi',
          snackPosition: SnackPosition.TOP,
        );
        return true;
      } else {
        Get.snackbar(
          'Xatolik',
          'Ma\'lumotlarni yangilashda xatolik',
          snackPosition: SnackPosition.TOP,
        );
        return false;
      }
    } catch (e) {
      print('Update profile xatolik: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Foydalanuvchi rolini tekshirish
  bool hasRole(String role) => currentUser.value?.role == role;
  bool hasAnyRole(List<String> roles) =>
      roles.contains(currentUser.value?.role);
  bool get isAdmin => hasAnyRole(['owner', 'manager', 'admin']);
  bool get isManagerOrOwner => hasAnyRole(['owner', 'manager']);
  bool get isTeacher => hasRole('teacher');
}

// ==================== QANDAY ISHLAYDI ====================
//
// BIRINCHI KIRISH:
// 1. Foydalanuvchi login sahifasiga kiradi
// 2. Username, parol va "Eslab qolish" ni belgilaydi
// 3. Login tugmasi bosiladi
// 4. AuthController.login(rememberMe: true) chaqiriladi
// 5. AuthRepository user ID ni SharedPreferences ga saqlaydi
// 6. Dashboard ga o'tadi
//
// ILOVANI QAYTA OCHISH:
// 1. main.dart da GetMaterialApp ishga tushadi
// 2. AppBindings AuthController ni yaratadi
// 3. AuthController.onInit() ishga tushadi
// 4. _checkAuthStatus() chaqiriladi
// 5. getSavedUserId() orqali saqlangan ID topiladi
// 6. getUserById() orqali user ma'lumotlari olinadi
// 7. Dashboard ga avtomatik o'tadi ✅
//
// LOGOUT:
// 1. Logout tugmasi bosiladi
// 2. AuthController.logout() chaqiriladi
// 3. SharedPreferences tozalanadi
// 4. Login sahifasiga qaytadi
// 5. Keyingi safar qayta login qilish kerak
