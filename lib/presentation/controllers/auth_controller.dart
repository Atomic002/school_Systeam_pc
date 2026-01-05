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
    // Ilova ochilganda avtomatik kirish tekshirish
    _checkAuthStatus();
  }

  // ==================== 1. AVTOMATIK KIRISH TEKSHIRISH ====================
  Future<void> _checkAuthStatus() async {
    try {
      print('🔍 Saqlangan sessiyani tekshirish...');

      // Navigatsiya tayyor bo'lishini kutish
      await Future.delayed(const Duration(milliseconds: 100));

      final savedUserId = await _authRepository.getSavedUserId();

      if (savedUserId != null) {
        print('✅ Saqlangan user topildi: $savedUserId');

        final user = await _authRepository.getUserById(savedUserId);

        if (user != null && user.isActive) {
          currentUser.value = user;
          print('✅ Avtomatik kirish: ${user.fullName}');
          print('👤 User roli: ${user.role}');

          // Navigatsiya uchun qo'shimcha kutish
          await Future.delayed(const Duration(milliseconds: 200));

          // ✅ Rolga qarab yo'naltirish
          _navigateByRole(user.role);
        } else {
          print('❌ User aktiv emas yoki topilmadi');
          // Login sahifasiga yo'naltirish
          Get.offAllNamed(AppRoutes.login);
        }
      } else {
        print('ℹ️ Saqlangan sessiya yo\'q - login kerak');
        // Login sahifasiga yo'naltirish
        Get.offAllNamed(AppRoutes.login);
      }
    } catch (e) {
      print('❌ Check auth status xatolik: $e');
      // Xatolik bo'lsa ham login sahifasiga yo'naltirish
      Get.offAllNamed(AppRoutes.login);
    }
  }

  // ==================== 2. LOGIN ====================
  Future<void> login({
    required String username,
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Validatsiya
      if (username.isEmpty) {
        errorMessage.value = 'Foydalanuvchi nomini kiriting';
        isLoading.value = false;
        return;
      }
      if (password.isEmpty) {
        errorMessage.value = 'Parolni kiriting';
        isLoading.value = false;
        return;
      }

      print('🔐 Login urinishi: $username');

      // Login qilish (rememberMe parametri bilan)
      final user = await _authRepository.login(
        username: username,
        password: password,
        rememberMe: rememberMe,
      );

      if (user != null) {
        currentUser.value = user;

        print('✅ Login muvaffaqiyatli');
        print('👤 User: ${user.fullName}');
        print('🎭 Rol: ${user.role}');
        print('📍 Branch ID: ${user.branchId}');

        // Success xabari
        Get.snackbar(
          'Muvaffaqiyatli',
          'Xush kelibsiz, ${user.fullName}!',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
        );

        // Navigatsiya uchun qisqa kutish
        await Future.delayed(const Duration(milliseconds: 300));

        // ✅ Rolga qarab yo'naltirish
        _navigateByRole(user.role);
      } else {
        errorMessage.value = 'Login yoki parol noto\'g\'ri';
        print('❌ Login muvaffaqiyatsiz');
      }
    } catch (e) {
      errorMessage.value = 'Xatolik yuz berdi: ${e.toString()}';
      print('❌ Login xatolik: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ==================== 3. ROLGA QARAB YO'NALTIRISH (ASOSIY O'ZGARISH) ====================
  void _navigateByRole(String role) {
    // Kichik harflarga o'tkazish va bo'sh joylarni tozalash
    final roleKey = role.toLowerCase().trim();

    print('🚀 Navigatsiya boshlandi');
    print('🎭 Rol (Key): $roleKey');

    try {
      switch (roleKey) {
        // 1. TA'SISCHI va DIREKTOR -> Dashboard
        case 'owner':
        case 'director':
          print('📊 Rahbariyat → Dashboard');
          Get.offAllNamed(AppRoutes.dashboard);
          break;

        // 2. KASSIR (DB: manager) -> Moliya
        case 'manager':
          print('💰 Kassir → Finance');
          Get.offAllNamed(AppRoutes.finance);
          break;

        // 3. QABULXONA (DB: admin) -> Tashriflar
        case 'admin':
          print('👥 Qabulxona → Visitors');
          Get.offAllNamed(AppRoutes.visitors);
          break;

        // 4. O'QITUVCHI -> Dars jadvali
        case 'teacher':
          print('📅 O\'qituvchi → My Schedule');
          Get.offAllNamed(AppRoutes.mySchedule);
          break;

        // Noma'lum rol
        default:
          print('❓ Noma\'lum rol ($roleKey) → Login');
          Get.snackbar('Xatolik', 'Sizga ruxsat etilgan rol topilmadi');
          Get.offAllNamed(AppRoutes.login);
      }

      print('✅ Navigatsiya muvaffaqiyatli');
    } catch (e) {
      print('❌ Navigatsiya xatoligi: $e');
      // Xatolik bo'lsa login sahifasiga yo'naltirish
      Get.offAllNamed(AppRoutes.login);
    }
  }

  // ==================== 4. LOGOUT ====================
  Future<void> logout() async {
    try {
      isLoading.value = true;

      print('🚪 Logout jarayoni boshlandi');

      await _authRepository.logout();
      currentUser.value = null;

      // Login sahifasiga qaytish
      Get.offAllNamed(AppRoutes.login);

      Get.snackbar(
        'Chiqish',
        'Tizimdan muvaffaqiyatli chiqdingiz',
        snackPosition: SnackPosition.TOP,
      );

      print('✅ Logout muvaffaqiyatli');
    } catch (e) {
      Get.snackbar(
        'Xatolik',
        'Chiqishda xatolik yuz berdi',
        snackPosition: SnackPosition.TOP,
      );
      print('❌ Logout xatolik: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ==================== 5. PAROLNI YANGILASH ====================
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

  // ==================== 6. PROFILNI YANGILASH ====================
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
      print('❌ Update profile xatolik: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ==================== 7. ROL TEKSHIRISH (GETTERS) ====================

  // Yordamchi metod: Rolni tekshirish
  bool hasRole(String role) =>
      currentUser.value?.role.toLowerCase().trim() == role.toLowerCase().trim();

  // Yordamchi metod: Bir nechta rollardan birini tekshirish
  bool hasAnyRole(List<String> roles) {
    final userRole = currentUser.value?.role.toLowerCase().trim();
    return roles.any((role) => role.toLowerCase().trim() == userRole);
  }

  // --- Aniq rollar uchun ---

  // Ta'sischi
  bool get isOwner => hasRole('owner');

  // Direktor
  bool get isDirector => hasRole('director');

  // Kassir (Database: manager)
  bool get isCashier => hasRole('manager');

  // Qabulxona (Database: admin)
  bool get isReception => hasRole('admin');

  // O'qituvchi
  bool get isTeacher => hasRole('teacher');

  // --- Ruxsatlar (Permissions) ---

  // Moliyani boshqarish (Owner, Director, Kassir)
  bool get canManageFinance => hasAnyRole(['owner', 'director', 'manager']);

  // Hisobotlarni ko'rish (Owner, Director)
  bool get canViewReports => hasAnyRole(['owner', 'director']);

  // Xodimlarni boshqarish (Owner, Director, Qabulxona)
  bool get canManageStaff => hasAnyRole(['owner', 'director', 'admin']);

  // Manual navigatsiya metodi (debug uchun)
  void navigateToHome() {
    if (currentUser.value != null) {
      _navigateByRole(currentUser.value!.role);
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  }
}
