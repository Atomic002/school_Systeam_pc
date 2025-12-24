// lib/presentation/controllers/auth_controller.dart
// TUZATILGAN - Navigatsiya muammolari hal qilindi

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

  // ========== AVTOMATIK KIRISH TEKSHIRISH ==========
  Future<void> _checkAuthStatus() async {
    try {
      print('🔍 Saqlangan sessiyani tekshirish...');

      // Navigatsiya tayyor bo'lishini kutish
      await Future.delayed(Duration(milliseconds: 100));

      final savedUserId = await _authRepository.getSavedUserId();

      if (savedUserId != null) {
        print('✅ Saqlangan user topildi: $savedUserId');

        final user = await _authRepository.getUserById(savedUserId);

        if (user != null && user.isActive) {
          currentUser.value = user;
          print('✅ Avtomatik kirish: ${user.fullName}');
          print('👤 User roli: ${user.role}');

          // Navigatsiya uchun qo'shimcha kutish
          await Future.delayed(Duration(milliseconds: 200));
          
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

  // ========== LOGIN ==========
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
          duration: Duration(seconds: 2),
        );

        // Navigatsiya uchun qisqa kutish
        await Future.delayed(Duration(milliseconds: 300));

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

  // ========== ROLGA QARAB YO'NALTIRISH ==========
  void _navigateByRole(String role) {
    final roleKey = role.toLowerCase().trim();
    
    print('🚀 Navigatsiya boshlandi');
    print('🎭 Rol: $roleKey');
    
    try {
      switch (roleKey) {
        case 'owner':
          // Ega - Dashboard
          print('📊 Owner → Dashboard');
          Get.offAllNamed(AppRoutes.dashboard);
          break;

        case 'admin':
          // Qabulxona - Tashrif buyuruvchilar
          print('👥 Admin → Visitors');
          Get.offAllNamed(AppRoutes.visitors);
          break;

        case 'staff':
        case 'teacher':
          // Xodim/O'qituvchi - Mening jadvalim
          print('📅 Staff/Teacher → My Schedule');
          Get.offAllNamed(AppRoutes.mySchedule);
          break;

        case 'director':
          // Direktor - Hisobotlar
          print('📈 Director → Reports');
          Get.offAllNamed(AppRoutes.reports);
          break;

        default:
          // Noma'lum rol - Dashboard
          print('❓ Unknown role ($roleKey) → Dashboard');
          Get.offAllNamed(AppRoutes.dashboard);
      }
      
      print('✅ Navigatsiya muvaffaqiyatli');
    } catch (e) {
      print('❌ Navigatsiya xatoligi: $e');
      // Xatolik bo'lsa Dashboard ga yo'naltirish
      Get.offAllNamed(AppRoutes.dashboard);
    }
  }

  // ========== LOGOUT ==========
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
      print('❌ Update profile xatolik: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ========== ROL TEKSHIRISH METODLARI ==========
  // Bitta rolni tekshirish
  bool hasRole(String role) => 
      currentUser.value?.role.toLowerCase().trim() == role.toLowerCase().trim();

  // Bir nechta rollarni tekshirish
  bool hasAnyRole(List<String> roles) {
    final userRole = currentUser.value?.role.toLowerCase().trim();
    return roles.any((role) => role.toLowerCase().trim() == userRole);
  }

  // Aniq rollar uchun getter'lar
  bool get isOwner => hasRole('owner');
  bool get isAdmin => hasRole('admin');
  bool get isStaff => hasAnyRole(['staff', 'teacher']);
  bool get isTeacher => hasRole('teacher');
  bool get isDirector => hasRole('director');

  // Bir nechta rollar uchun
  bool get isManagerOrOwner => hasAnyRole(['owner', 'manager']);
  bool get canManageFinance => hasAnyRole(['owner', 'director']);
  bool get canViewReports => hasAnyRole(['owner', 'director', 'manager']);
  
  // Manual navigatsiya metodi (debug uchun)
  void navigateToHome() {
    if (currentUser.value != null) {
      _navigateByRole(currentUser.value!.role);
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  }
}