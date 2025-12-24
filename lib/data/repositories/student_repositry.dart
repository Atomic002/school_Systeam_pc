// lib/data/repositories/student_repository.dart - TO'LIQ TUZATILGAN

import 'package:flutter_application_1/data/models/student_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StudentRepository {
  final _supabase = Supabase.instance.client;

  /// O'quvchi yaratish - BARCHA MAYDONLAR BILAN
  Future<StudentModel?> createStudent({
    required String branchId,
    required String firstName,
    required String lastName,
    required String middleName,
    required String gender,
    required DateTime birthDate,
    required String phone,
    required String address,
    required String region,
    required String district,
    required String parentFirstName,
    required String parentLastName,
    required String parentMiddleName,
    required String parentPhone,
    required String parentPhone2,
    required String parentWorkplace,
    required String parentRelation,
    required double monthlyFee,
    required double discountPercent,
    required double discountAmount,
    required String discountReason,
    required String notes,
    required String medicalNotes,
    String? visitorId,
    required String createdBy,
    
    // ✅ SINF MA'LUMOTLARI
    String? classId,
    String? classLevelId,
    String? classLevelName,
    String? className,
    String? roomId,
    String? roomName,
    String? mainTeacherId,
    String? mainTeacherName,
  }) async {
    try {
      print('💾 ========== STUDENT REPOSITORY - CREATE ==========');
      print('Branch ID: $branchId');
      print('Class ID: $classId');
      print('Class Level ID: $classLevelId');
      print('Class Level Name: $classLevelName');
      print('Room ID: $roomId');
      print('Room Name: $roomName');
      print('Teacher ID: $mainTeacherId');
      print('Teacher Name: $mainTeacherName');

      // ✅ TO'LIQ MA'LUMOTLAR BILAN INSERT
      final data = {
        'branch_id': branchId,
        'first_name': firstName,
        'last_name': lastName,
        'middle_name': middleName.isNotEmpty ? middleName : null,
        'gender': gender,
        'birth_date': birthDate.toIso8601String(),
        'phone': phone.isNotEmpty ? phone : null,
        'address': address.isNotEmpty ? address : null,
        'region': region.isNotEmpty ? region : null,
        'district': district.isNotEmpty ? district : null,
        'parent_first_name': parentFirstName.isNotEmpty ? parentFirstName : null,
        'parent_last_name': parentLastName.isNotEmpty ? parentLastName : null,
        'parent_middle_name': parentMiddleName.isNotEmpty ? parentMiddleName : null,
        'parent_phone': parentPhone.isNotEmpty ? parentPhone : null,
        'parent_phone_secondary': parentPhone2.isNotEmpty ? parentPhone2 : null,
        'parent_workplace': parentWorkplace.isNotEmpty ? parentWorkplace : null,
        'parent_relation': parentRelation,
        'monthly_fee': monthlyFee,
        'discount_percent': discountPercent,
        'discount_amount': discountAmount,
        'discount_reason': discountReason.isNotEmpty ? discountReason : null,
        'notes': notes.isNotEmpty ? notes : null,
        'medical_notes': medicalNotes.isNotEmpty ? medicalNotes : null,
        'visitor_id': visitorId,
        'created_by': createdBy,
        'status': 'active',
        'enrollment_date': DateTime.now().toIso8601String(),
        
        // ✅ SINF MA'LUMOTLARI - ASOSIY!
        'class_id': classId,
        'class_level_id': classLevelId,
        'class_level_name': classLevelName,
        'class_name': className,
        'room_id': roomId,
        'room_name': roomName,
        'main_teacher_id': mainTeacherId,
        'main_teacher_name': mainTeacherName,
      };

      print('📤 Yuboriladigan ma\'lumotlar: $data');

      final response = await _supabase
          .from('students')
          .insert(data)
          .select()
          .single();

      print('✅ O\'quvchi muvaffaqiyatli yaratildi!');
      print('📦 Response: $response');

      return StudentModel.fromJson(response);
    } catch (e) {
      print('❌ createStudent xatosi: $e');
      return null;
    }
  }

  /// O'quvchini yangilash
  Future<bool> updateStudent({
    required String studentId,
    String? photoUrl,
    String? firstName,
    String? lastName,
    String? middleName,
    String? phone,
    String? address,
    String? region,
    String? district,
    String? parentPhone,
    String? parentPhone2,
    String? notes,
    String? medicalNotes,
    String? classId,
    String? classLevelId,
    String? classLevelName,
    String? className,
    String? roomId,
    String? roomName,
    String? mainTeacherId,
    String? mainTeacherName,
  }) async {
    try {
      final Map<String, dynamic> updates = {};

      if (photoUrl != null) updates['photo_url'] = photoUrl;
      if (firstName != null) updates['first_name'] = firstName;
      if (lastName != null) updates['last_name'] = lastName;
      if (middleName != null) updates['middle_name'] = middleName;
      if (phone != null) updates['phone'] = phone;
      if (address != null) updates['address'] = address;
      if (region != null) updates['region'] = region;
      if (district != null) updates['district'] = district;
      if (parentPhone != null) updates['parent_phone'] = parentPhone;
      if (parentPhone2 != null) updates['parent_phone_secondary'] = parentPhone2;
      if (notes != null) updates['notes'] = notes;
      if (medicalNotes != null) updates['medical_notes'] = medicalNotes;
      
      // Sinf ma'lumotlari
      if (classId != null) updates['class_id'] = classId;
      if (classLevelId != null) updates['class_level_id'] = classLevelId;
      if (classLevelName != null) updates['class_level_name'] = classLevelName;
      if (className != null) updates['class_name'] = className;
      if (roomId != null) updates['room_id'] = roomId;
      if (roomName != null) updates['room_name'] = roomName;
      if (mainTeacherId != null) updates['main_teacher_id'] = mainTeacherId;
      if (mainTeacherName != null) updates['main_teacher_name'] = mainTeacherName;

      if (updates.isEmpty) return false;

      await _supabase
          .from('students')
          .update(updates)
          .eq('id', studentId);

      return true;
    } catch (e) {
      print('❌ updateStudent xatosi: $e');
      return false;
    }
  }

  /// Barcha o'quvchilarni olish
  Future<List<StudentModel>> getAllStudents(String branchId) async {
    try {
      final response = await _supabase
          .from('students')
          .select('*')
          .eq('branch_id', branchId)
          .order('last_name');

      return response.map<StudentModel>((json) => StudentModel.fromJson(json)).toList();
    } catch (e) {
      print('❌ getAllStudents xatosi: $e');
      return [];
    }
  }

  /// Bitta o'quvchini olish
  Future<StudentModel?> getStudentById(String studentId) async {
    try {
      final response = await _supabase
          .from('students')
          .select('*')
          .eq('id', studentId)
          .maybeSingle();

      if (response == null) return null;

      return StudentModel.fromJson(response);
    } catch (e) {
      print('❌ getStudentById xatosi: $e');
      return null;
    }
  }

  /// O'quvchini o'chirish (soft delete)
  Future<bool> deleteStudent(String studentId) async {
    try {
      await _supabase
          .from('students')
          .update({'status': 'inactive'})
          .eq('id', studentId);

      return true;
    } catch (e) {
      print('❌ deleteStudent xatosi: $e');
      return false;
    }
  }

  /// Sinfdagi o'quvchilar sonini olish
  Future<int> getClassStudentCount(String classId) async {
    try {
      final response = await _supabase
          .from('students')
          .select('id')
          .eq('class_id', classId)
          .eq('status', 'active');

      return response.length;
    } catch (e) {
      print('❌ getClassStudentCount xatosi: $e');
      return 0;
    }
  }
}