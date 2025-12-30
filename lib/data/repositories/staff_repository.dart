// lib/data/repositories/staff_repository.dart

import 'dart:io';

import 'package:flutter_application_1/data/models/schedule_model.dart';
import 'package:flutter_application_1/data/models/staff.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StaffRepository {
  final _supabase = Supabase.instance.client;

  // ==================== FILIALLARNI OLISH ====================
  Future<List<Map<String, dynamic>>> getBranches() async {
    try {
      final response = await _supabase
          .from('branches')
          .select('id, name, address, is_active')
          .eq('is_active', true)
          .order('is_main', ascending: false)
          .order('name');

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Get branches error: $e');
      rethrow;
    }
  }

  // ==================== FANLARNI OLISH ====================
  Future<List<Map<String, dynamic>>> getSubjects() async {
    try {
      final response = await _supabase
          .from('subjects')
          .select('id, name, code')
          .eq('is_active', true)
          .order('name');

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Get subjects error: $e');
      rethrow;
    }
  }

  // ==================== XONALARNI OLISH ====================
  Future<List<Map<String, dynamic>>> getRooms() async {
    try {
      final response = await _supabase
          .from('rooms')
          .select('id, branch_id, name, capacity, floor, room_type')
          .eq('is_active', true)
          .order('name');

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Get rooms error: $e');
      rethrow;
    }
  }

  Future<StaffEnhanced?> createStaff({
    String? userId,
    required String branchId,
    String? visitorId,
    required String firstName,
    required String lastName,
    required String middleName,
    required String gender,
    required DateTime birthDate,
    required String phone,
    required String phoneSecondary,
    required String region,
    required String district,
    required String address,
    required String position,
    required String department,
    required bool isTeacher,
    required String salaryType,
    double? baseSalary,
    double? hourlyRate,
    double? dailyRate,
    int? expectedHoursPerMonth,
    required DateTime hireDate,
    required String skills,
    required String education,
    required String experience,
    required String notes,
    required String createdBy,
    String? defaultRoomId,
    String? photoUrl, // <--- YANGI PARAMETR
  }) async {
    try {
      final response = await _supabase
          .from('staff')
          .insert({
            'user_id': userId,
            'branch_id': branchId,
            'visitor_id': visitorId,
            'first_name': firstName,
            'last_name': lastName,
            'middle_name': middleName.isNotEmpty ? middleName : null,
            'gender': gender,
            'birth_date': birthDate.toIso8601String().split('T')[0],
            'phone': phone,
            'phone_secondary': phoneSecondary.isNotEmpty ? phoneSecondary : null,
            'region': region.isNotEmpty ? region : null,
            'district': district.isNotEmpty ? district : null,
            'address': address.isNotEmpty ? address : null,
            'position': position,
            'department': department.isNotEmpty ? department : null,
            'is_teacher': isTeacher,
            'salary_type': salaryType,
            'base_salary': baseSalary,
            'hourly_rate': hourlyRate,
            'daily_rate': dailyRate,
            'expected_hours_per_month': expectedHoursPerMonth,
            'hire_date': hireDate.toIso8601String().split('T')[0],
            'skills': skills.isNotEmpty ? skills : null,
            'education': education.isNotEmpty ? education : null,
            'experience': experience.isNotEmpty ? experience : null,
            'notes': notes.isNotEmpty ? notes : null,
            'photo_url': photoUrl, // <--- BAZAGA YOZISH
            'created_by': createdBy,
            'status': 'active',
            'default_room_id': defaultRoomId,
          })
          .select('*, branches:branch_id(name)')
          .single();

      return StaffEnhanced.fromJson({
        ...response,
        'branch_name': response['branches']?['name'] ?? '',
      });
    } catch (e) {
      print('Create staff error: $e');
      rethrow;
    }
  }
  // ==================== O'QITUVCHIGA FAN BIRIKTIRISH ====================
  Future<void> assignSubjectToTeacher({
    required String staffId,
    required String subjectId,
    required bool isPrimary,
  }) async {
    try {
      await _supabase.from('teacher_subjects').insert({
        'staff_id': staffId,
        'subject_id': subjectId,
        'is_primary': isPrimary,
      });
    } catch (e) {
      print('Assign subject error: $e');
      rethrow;
    }
  }

  // ==================== O'QITUVCHINI SINFGA BIRIKTIRISH ====================
  Future<void> assignTeacherToClass({
    required String staffId,
    required String classId,
    required String subjectId,
  }) async {
    try {
      // Academic year ID ni olish
      final academicYearResponse = await _supabase
          .from('academic_years')
          .select('id')
          .eq('is_current', true)
          .single();

      final academicYearId = academicYearResponse['id'];

      await _supabase.from('teacher_classes').insert({
        'staff_id': staffId,
        'class_id': classId,
        'subject_id': subjectId,
        'academic_year_id': academicYearId,
        'is_active': true,
      });
    } catch (e) {
      print('Assign teacher to class error: $e');
      rethrow;
    }
  }

  // ==================== XODIMNI YANGILASH ====================
  Future<StaffModel?> updateStaff({
    required String id,
    String? firstName,
    String? lastName,
    String? middleName,
    String? phone,
    String? phoneSecondary,
    String? position,
    String? department,
    double? baseSalary,
    double? hourlyRate,
    double? dailyRate,
    String? status,
  }) async {
    try {
      final updateData = <String, dynamic>{};

      if (firstName != null) updateData['first_name'] = firstName;
      if (lastName != null) updateData['last_name'] = lastName;
      if (middleName != null) updateData['middle_name'] = middleName;
      if (phone != null) updateData['phone'] = phone;
      if (phoneSecondary != null)
        updateData['phone_secondary'] = phoneSecondary;
      if (position != null) updateData['position'] = position;
      if (department != null) updateData['department'] = department;
      if (baseSalary != null) updateData['base_salary'] = baseSalary;
      if (hourlyRate != null) updateData['hourly_rate'] = hourlyRate;
      if (dailyRate != null) updateData['daily_rate'] = dailyRate;
      if (status != null) updateData['status'] = status;

      updateData['updated_at'] = DateTime.now().toIso8601String();

      final response = await _supabase
          .from('staff')
          .update(updateData)
          .eq('id', id)
          .select()
          .single();

      return StaffModel.fromJson(response);
    } catch (e) {
      print('Update staff error: $e');
      rethrow;
    }
  }
  

  // ==================== XODIMNI O'CHIRISH ====================
  Future<void> deleteStaff(String id) async {
    try {
      await _supabase
          .from('staff')
          .update({
            'status': 'inactive',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id);
    } catch (e) {
      print('Delete staff error: $e');
      rethrow;
    }
  }

  // ==================== XODIMNI OLISH (ID BO'YICHA) ====================
  Future<StaffModel?> getStaffById(String id) async {
    try {
      final response = await _supabase
          .from('staff')
          .select('''
            *,
            branches:branch_id (name, address),
            users:user_id (role)
          ''')
          .eq('id', id)
          .single();

      return StaffModel.fromJson(response);
    } catch (e) {
      print('Get staff by id error: $e');
      rethrow;
    }
  }

  // ==================== BARCHA XODIMLARNI OLISH ====================
  Future<List<StaffModel>> getAllStaff({String? branchId}) async {
    try {
      var query = _supabase
          .from('staff')
          .select('''
            *,
            branches:branch_id (name),
            users:user_id (role)
          ''')
          .order('created_at', ascending: false);

      if (branchId != null) {}

      final response = await query;

      return (response as List)
          .map((json) => StaffModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Get all staff error: $e');
      rethrow;
    }
  }

  // ==================== O'QITUVCHILARNI OLISH ====================
  Future<List<StaffModel>> getTeachers({String? branchId}) async {
    try {
      var query = _supabase
          .from('staff')
          .select('''
            *,
            branches:branch_id (name)
          ''')
          .eq('is_teacher', true)
          .eq('status', 'active')
          .order('last_name');

      if (branchId != null) {}

      final response = await query;

      return (response as List)
          .map((json) => StaffModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Get teachers error: $e');
      rethrow;
    }
  }
  // ✅ YANGI: RASM YUKLASH FUNKSIYASI
  Future<String?> uploadProfileImage(File file) async {
    try {
      final fileExt = file.path.split('.').last;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final filePath = 'staff_avatars/$fileName';

      // 'avatars' bu Supabase Storage dagi bucket nomi.
      // Supabase dashboardingizda 'avatars' nomli public bucket yaratishingiz kerak!
      await _supabase.storage.from('avatars').upload(filePath, file);

      // Public URL ni olish
      final imageUrl = _supabase.storage.from('avatars').getPublicUrl(filePath);
      return imageUrl;
    } catch (e) {
      print('Rasm yuklashda xatolik: $e');
      return null;
    }
  }
   Future<String?> createUser({
    required String branchId,
    required String firstName,
    required String lastName,
    required String middleName,
    required String gender,
    required DateTime birthDate,
    required String phone,
    required String phoneSecondary,
    required String region,
    required String district,
    required String address,
    required String username,
    required String password,
    required String role,
  }) async {
    try {
      // Users jadvaliga ma'lumot qo'shish va ID ni qaytarib olish
      final response = await _supabase
          .from('users')
          .insert({
            'branch_id': branchId,
            'first_name': firstName,
            'last_name': lastName,
            'middle_name': middleName.isNotEmpty ? middleName : null,
            'gender': gender,
            'birth_date': birthDate.toIso8601String().split('T')[0],
            'phone': phone,
            'phone_secondary': phoneSecondary.isNotEmpty ? phoneSecondary : null,
            'region': region,
            'district': district,
            'address': address,
            'role': role,
            'username': username,
            'password_hash': password, // Haqiqiy loyihada buni hash qilish kerak!
            'status': 'active',
          })
          .select('id') // <--- MUHIM: ID ni so'rash
          .single();

      return response['id'] as String;
    } catch (e) {
      print('Create user error: $e');
      // Xatoni aniqroq qaytarish uchun:
      if (e.toString().contains('users_username_key')) {
         throw Exception("Bu username allaqachon mavjud");
      }
      rethrow;
    }
  }

  // Staff ID orqali to'liq ma'lumotlarni olish
    // ==================== USER ID ORQALI STAFFNI OLISH ====================
  Future<List<StaffEnhanced>> getStaffByUserId(String userId) async {
    try {
      final response = await _supabase
          .from('staff')
          .select('''
            *,
            branches!inner(name)
          ''')
          .eq('user_id', userId)
          .eq('status', 'active');

      if (response == null || (response as List).isEmpty) {
        return [];
      }

      return (response as List).map((json) {
        final staffData = Map<String, dynamic>.from(json);
        
        // Branch nomini to'g'irlash
        if (json['branches'] != null) {
          staffData['branch_name'] = json['branches']['name'];
        }
        
        // Rasm URL ni aniq ko'rsatish
        staffData['photo_url'] = json['photo_url'];

        return StaffEnhanced.fromJson(staffData);
      }).toList();
    } catch (e) {
      print('❌ getStaffByUserId xatolik: $e');
      return [];
    }
  }
} // <--- Class mana shu yerda tugaydi



