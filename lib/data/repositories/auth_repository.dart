// lib/data/repositories/auth_repository.dart
// YANGILANGAN - Filial nomini olish va parol tekshirish yaxshilangan

import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class AuthRepository {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  // SharedPreferences kalit
  static const String _userIdKey = 'saved_user_id';

  // ========== LOGIN ==========
  Future<UserModel?> login({
    required String username,
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      print('🔐 Login attempt: $username');

      // 1. Foydalanuvchini topish (Filial nomi bilan)
      final response = await _supabase
          .from('users')
          .select('''
            *,
            branches:branch_id (
              name
            )
          ''')
          .eq('username', username)
          .maybeSingle();

      if (response == null) {
        print('❌ User topilmadi: $username');
        return null;
      }

      print('✅ User topildi: ${response['username']}');
      print('👤 Full name: ${response['first_name']} ${response['last_name']}');
      print('🎭 Role: ${response['role']}');
      print('📍 Branch ID: ${response['branch_id']}');

      // 2. Parolni tekshirish (YAXSHILANGAN!)
      final storedPassword = response['password_hash'] ?? response['temp_password'];
      
      print('🔐 Kiritilgan parol: $password');
      print('🔐 DB dagi parol: $storedPassword');
      
      if (storedPassword == null) {
        print('❌ DB da parol topilmadi');
        return null;
      }

      // Parolni trim qilib taqqoslash (bo'sh joylarni olib tashlash)
      final isPasswordValid = password.trim() == storedPassword.toString().trim();
      
      if (!isPasswordValid) {
        print('❌ Parol noto\'g\'ri');
        print('   Kiritilgan: "$password" (length: ${password.length})');
        print('   Kutilgan: "$storedPassword" (length: ${storedPassword.toString().length})');
        return null;
      }

      print('✅ Parol to\'g\'ri');

      // 3. User aktiv emasligini tekshirish
      final userStatus = response['status'] ?? 'active';
      final isActive = response['is_active'] ?? (userStatus == 'active');
      
      if (!isActive && userStatus != 'active') {
        print('❌ User aktiv emas (status: $userStatus)');
        return null;
      }

      print('✅ User aktiv');

      // 4. UserModel yaratish (branch_name bilan)
      final Map<String, dynamic> userData = Map<String, dynamic>.from(response);
      
      // Filial nomini qo'shish
      if (userData['branches'] != null) {
        userData['branch_name'] = userData['branches']['name'];
        print('🏢 Branch name: ${userData['branch_name']}');
      }
      
      final user = UserModel.fromJson(userData);

      // 5. Agar "Meni eslab qol" belgilangan bo'lsa - ID ni saqlash
      if (rememberMe) {
        await _saveUserId(user.id!);
        print('💾 User ID saqlandi: ${user.id}');
      } else {
        await _clearUserId();
        print('ℹ️ User ID saqlanmadi (Remember me = false)');
      }

      // 6. Last login vaqtini yangilash
      await _updateLastLogin(user.id!);

      print('✅ Login muvaffaqiyatli: ${user.fullName}');
      print('🎭 Rol: ${user.role}');
      return user;

    } catch (e, stackTrace) {
      print('❌ Login xatolik: $e');
      print('📍 Stack trace: $stackTrace');
      return null;
    }
  }

  // ========== LOGOUT ==========
  Future<void> logout() async {
    try {
      await _clearUserId();
      print('✅ Logout muvaffaqiyatli');
    } catch (e) {
      print('❌ Logout xatolik: $e');
    }
  }

  // ========== USER ID NI SAQLASH ==========
  Future<void> _saveUserId(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userIdKey, userId);
      print('💾 SharedPreferences ga saqlandi: $userId');
    } catch (e) {
      print('❌ User ID saqlashda xatolik: $e');
    }
  }

  // ========== SAQLANGAN USER ID NI OLISH ==========
  Future<String?> getSavedUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedId = prefs.getString(_userIdKey);
      if (savedId != null) {
        print('📂 Saqlangan User ID topildi: $savedId');
      } else {
        print('📂 Saqlangan User ID yo\'q');
      }
      return savedId;
    } catch (e) {
      print('❌ User ID olishda xatolik: $e');
      return null;
    }
  }

  // ========== USER ID NI O'CHIRISH ==========
  Future<void> _clearUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userIdKey);
      print('🗑️ User ID o\'chirildi');
    } catch (e) {
      print('❌ User ID o\'chirishda xatolik: $e');
    }
  }

  // ========== USER NI ID BO'YICHA OLISH ==========
  Future<UserModel?> getUserById(String userId) async {
    try {
      print('🔍 User ni ID bo\'yicha qidirish: $userId');

      final response = await _supabase
          .from('users')
          .select('''
            *,
            branches:branch_id (
              name
            )
          ''')
          .eq('id', userId)
          .maybeSingle();

      if (response == null) {
        print('❌ User topilmadi (ID: $userId)');
        return null;
      }

      // Branch name ni qo'shish
      final Map<String, dynamic> userData = Map<String, dynamic>.from(response);
      if (userData['branches'] != null) {
        userData['branch_name'] = userData['branches']['name'];
      }

      final user = UserModel.fromJson(userData);
      print('✅ User topildi: ${user.fullName} (${user.role})');
      return user;

    } catch (e) {
      print('❌ User olishda xatolik: $e');
      return null;
    }
  }

  // ========== LAST LOGIN VAQTINI YANGILASH ==========
  Future<void> _updateLastLogin(String userId) async {
    try {
      await _supabase.from('users').update({
        'last_login_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);
      print('⏰ Last login yangilandi');
    } catch (e) {
      print('❌ Last login yangilashda xatolik: $e');
    }
  }

  // ========== PAROLNI YANGILASH ==========
  Future<bool> updatePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final savedUserId = await getSavedUserId();
      if (savedUserId == null) {
        print('❌ User ID topilmadi');
        return false;
      }

      // Eski parolni tekshirish
      final response = await _supabase
          .from('users')
          .select('password_hash')
          .eq('id', savedUserId)
          .single();

      final storedPassword = response['password_hash'];
      
      if (storedPassword != oldPassword) {
        print('❌ Eski parol noto\'g\'ri');
        return false;
      }

      // Yangi parolni yangilash
      await _supabase.from('users').update({
        'password_hash': newPassword,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', savedUserId);

      print('✅ Parol yangilandi');
      return true;
    } catch (e) {
      print('❌ Parol yangilashda xatolik: $e');
      return false;
    }
  }

  // ========== PROFILNI YANGILASH ==========
  Future<bool> updateUserProfile(UserModel user) async {
    try {

      await _supabase.from('users').update({
        'first_name': user.firstName,
        'last_name': user.lastName,
        'middle_name': user.middleName,
        'phone': user.phone,
        'phone_secondary': user.phoneSecondary,
        'region': user.region,
        'district': user.district,
        'address': user.address,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', user.id!);

      print('✅ Profil yangilandi');
      return true;
    } catch (e) {
      print('❌ Profil yangilashda xatolik: $e');
      return false;
    }
  }

  // ========== DEBUG: USERS JADVALINI TEKSHIRISH ==========
  Future<void> debugCheckUser(String username) async {
    try {
      print('\n========== DEBUG INFO ==========');
      final response = await _supabase
          .from('users')
          .select()
          .eq('username', username)
          .maybeSingle();

      if (response == null) {
        print('❌ User topilmadi: $username');
      } else {
        print('✅ User ma\'lumotlari:');
        print('   Username: ${response['username']}');
        print('   Password Hash: ${response['password_hash']}');
        print('   Temp Password: ${response['temp_password']}');
        print('   Role: ${response['role']}');
        print('   Status: ${response['status']}');
        print('   Is Active: ${response['is_active']}');
        print('   Branch ID: ${response['branch_id']}');
      }
      print('================================\n');
    } catch (e) {
      print('❌ Debug error: $e');
    }
  }
}