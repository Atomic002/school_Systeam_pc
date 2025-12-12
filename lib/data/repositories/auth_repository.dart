// lib/data/repositories/auth_repository.dart
// IZOH: Authentication uchun repository.
// Login, logout, parol yangilash va sessiyani saqlash.

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class AuthRepository {
  final _supabase = Supabase.instance.client;

  // SharedPreferences key lari
  static const String _keyUserId = 'saved_user_id';
  static const String _keyRememberMe = 'remember_me';

  String? get currentUserId => _supabase.auth.currentUser?.id;
  bool get isAuthenticated => _supabase.auth.currentUser != null;

  // ========== LOGIN - Parol tekshirish va saqlash ==========
  Future<UserModel?> login({
    required String username,
    required String password,
    bool rememberMe = false, // ← YANGI: Eslab qolish parametri
  }) async {
    try {
      // 1. Foydalanuvchini topish
      final response = await _supabase
          .from('users')
          .select()
          .eq('username', username)
          .eq('status', 'active')
          .maybeSingle();

      if (response == null) {
        throw Exception('Foydalanuvchi topilmadi');
      }

      final user = UserModel.fromJson(response);

      // 2. Parolni tekshirish
      bool passwordMatches = false;

      if (user.tempPassword != null && user.tempPassword!.isNotEmpty) {
        // Vaqtinchalik parol tekshirish
        passwordMatches = user.tempPassword == password;
      } else if (user.passwordHash != null && user.passwordHash!.isNotEmpty) {
        // Hash qilingan parol tekshirish
        final hashedInput = _hashPassword(password);
        passwordMatches = user.passwordHash == hashedInput;
      }

      if (!passwordMatches) {
        throw Exception('Parol noto\'g\'ri');
      }

      // 3. Last login vaqtini yangilash
      await _supabase
          .from('users')
          .update({'last_login_at': DateTime.now().toIso8601String()})
          .eq('id', user.id);

      // 4. ✅ ESLAB QOLISH - Agar rememberMe true bo'lsa, saqlash
      if (rememberMe) {
        await _saveUserSession(user.id);
      } else {
        await _clearUserSession();
      }

      return user;
    } catch (e) {
      print('Login xatolik: $e');
      rethrow;
    }
  }

  // ========== SAQLANGAN SESSIYANI TEKSHIRISH ==========
  // Ilova ochilganda chaqiriladi
  Future<String?> getSavedUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rememberMe = prefs.getBool(_keyRememberMe) ?? false;

      if (rememberMe) {
        return prefs.getString(_keyUserId);
      }
      return null;
    } catch (e) {
      print('Get saved user ID xatolik: $e');
      return null;
    }
  }

  // ========== SESSIYANI SAQLASH ==========
  Future<void> _saveUserSession(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyUserId, userId);
      await prefs.setBool(_keyRememberMe, true);
      print('✅ Sessiya saqlandi: $userId');
    } catch (e) {
      print('Save session xatolik: $e');
    }
  }

  // ========== SESSIYANI O'CHIRISH ==========
  Future<void> _clearUserSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyUserId);
      await prefs.setBool(_keyRememberMe, false);
      print('🗑️ Sessiya o\'chirildi');
    } catch (e) {
      print('Clear session xatolik: $e');
    }
  }

  // ========== PAROLNI HASH QILISH ==========
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  // ========== FOYDALANUVCHINI ID ORQALI OLISH ==========
  Future<UserModel?> getUserById(String userId) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response == null) return null;

      return UserModel.fromJson(response);
    } catch (e) {
      print('Get user xatolik: $e');
      return null;
    }
  }

  // ========== LOGOUT - Sessiyani o'chirish ==========
  Future<void> logout() async {
    try {
      await _supabase.auth.signOut();
      await _clearUserSession(); // ← Saqlangan sessiyani o'chirish
    } catch (e) {
      print('Logout xatolik: $e');
      rethrow;
    }
  }

  // ========== PAROLNI YANGILASH ==========
  Future<bool> updatePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      if (currentUserId == null) return false;

      final user = await getUserById(currentUserId!);
      if (user == null) return false;

      // Eski parolni tekshirish
      bool oldPasswordMatches = false;
      if (user.tempPassword != null) {
        oldPasswordMatches = user.tempPassword == oldPassword;
      } else if (user.passwordHash != null) {
        oldPasswordMatches = user.passwordHash == _hashPassword(oldPassword);
      }

      if (!oldPasswordMatches) {
        throw Exception('Eski parol noto\'g\'ri');
      }

      // Yangi parolni hash qilib saqlash
      final newHash = _hashPassword(newPassword);

      await _supabase
          .from('users')
          .update({
            'password_hash': newHash,
            'temp_password': null, // Vaqtinchalik parolni o'chirish
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', currentUserId!);

      return true;
    } catch (e) {
      print('Update password xatolik: $e');
      return false;
    }
  }

  // ========== PROFILNI YANGILASH ==========
  Future<bool> updateUserProfile(UserModel user) async {
    try {
      await _supabase.from('users').update(user.toJson()).eq('id', user.id);
      return true;
    } catch (e) {
      print('Update profile xatolik: $e');
      return false;
    }
  }
}

// ==================== QANDAY ISHLAYDI ====================
//
// 1. LOGIN QILGANDA (rememberMe = true):
//    → User ID SharedPreferences ga saqlanadi
//    → remember_me = true flag qo'yiladi
//
// 2. ILOVA QAYTA OCHILGANDA:
//    → AuthController.onInit() da getSavedUserId() chaqiriladi
//    → Agar user ID topilsa → getUserById() orqali ma'lumot olinadi
//    → Dashboard ga avtomatik o'tadi
//
// 3. LOGOUT QILGANDA:
//    → SharedPreferences dan barcha ma'lumotlar o'chiriladi
//    → Keyingi safar login qilish kerak bo'ladi
