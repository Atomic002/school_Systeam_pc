// lib/data/models/auth_service.dart
// TO'G'RILANGAN VERSIYA

import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'user_model.dart';

class AuthService extends GetxService {
  final _supabase = Supabase.instance.client;
  
  // Current user - nullable
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  
  // Loading state
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadCurrentUser();
  }

  /// Joriy foydalanuvchini yuklash
  Future<void> loadCurrentUser() async {
    try {
      isLoading.value = true;
      print('🔄 Loading current user...');

      final session = _supabase.auth.currentSession;
      if (session == null) {
        print('⚠️ No active session');
        currentUser.value = null;
        return;
      }

      final userId = session.user.id;
      print('👤 User ID: $userId');

      // Users jadvalidan ma'lumot olish
      final response = await _supabase
          .from('users')
          .select('*')
          .eq('id', userId)
          .maybeSingle();

      if (response != null) {
        currentUser.value = UserModel.fromJson(response);
        print('✅ User loaded: ${currentUser.value?.fullName}');
        print('🏢 Branch ID: ${currentUser.value?.branchId}');
      } else {
        print('❌ User not found in database');
        currentUser.value = null;
      }
    } catch (e) {
      print('❌ Load current user error: $e');
      currentUser.value = null;
    } finally {
      isLoading.value = false;
    }
  }

  /// Login
  Future<bool> login(String username, String password) async {
    try {
      isLoading.value = true;
      print('🔐 Attempting login for: $username');

      // Supabase Auth orqali login
      final response = await _supabase.auth.signInWithPassword(
        email: '$username@school.local', // Email format kerak
        password: password,
      );

      if (response.session != null) {
        await loadCurrentUser();
        print('✅ Login successful');
        return true;
      }

      return false;
    } catch (e) {
      print('❌ Login error: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      await _supabase.auth.signOut();
      currentUser.value = null;
      print('👋 User logged out');
    } catch (e) {
      print('❌ Logout error: $e');
    }
  }

  /// Foydalanuvchi tizimga kirganmi?
  bool get isAuthenticated => currentUser.value != null;

  /// Foydalanuvchi roli
  String? get userRole => currentUser.value?.role;

  /// Foydalanuvchi filiali
  String? get userBranchId => currentUser.value?.branchId;
}