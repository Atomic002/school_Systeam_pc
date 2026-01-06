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
    // SINF MA'LUMOTLARI
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
        'parent_first_name': parentFirstName.isNotEmpty
            ? parentFirstName
            : null,
        'parent_last_name': parentLastName.isNotEmpty ? parentLastName : null,
        'parent_middle_name': parentMiddleName.isNotEmpty
            ? parentMiddleName
            : null,
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

        // SINF MA'LUMOTLARI
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
      return StudentModel.fromJson(response);
    } catch (e) {
      print('❌ createStudent xatosi: $e');
      return null;
    }
  }

  /// ✅ O'quvchini yangilash - TO'LIQ TUZATILGAN
  Future<bool> updateStudent({
    required String studentId,
    // ASOSIY MA'LUMOTLAR
    String? firstName,
    String? lastName,
    String? middleName,
    String? gender,
    DateTime? birthDate,
    String? phone,
    String? address,
    String? region,
    String? district,
    // OTA-ONA
    String? parentFirstName,
    String? parentLastName,
    String? parentMiddleName,
    String? parentPhone,
    String? parentPhone2,
    String? parentWorkplace,
    String? parentRelation,
    // MOLIYAVIY
    double? monthlyFee,
    double? discountPercent,
    double? discountAmount,
    String? discountReason,
    // QO'SHIMCHA
    String? notes,
    String? medicalNotes,
    String? photoUrl,
    // SINF
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
      print('🔄 ========== STUDENT REPOSITORY - UPDATE ==========');
      print('Student ID: $studentId');
      final Map<String, dynamic> updates = {};

      // ASOSIY MA'LUMOTLAR
      if (firstName != null) updates['first_name'] = firstName;
      if (lastName != null) updates['last_name'] = lastName;
      if (middleName != null)
        updates['middle_name'] = middleName.isNotEmpty ? middleName : null;
      if (gender != null) updates['gender'] = gender;
      if (birthDate != null)
        updates['birth_date'] = birthDate.toIso8601String();
      if (phone != null) updates['phone'] = phone.isNotEmpty ? phone : null;
      if (address != null)
        updates['address'] = address.isNotEmpty ? address : null;
      if (region != null) updates['region'] = region.isNotEmpty ? region : null;
      if (district != null)
        updates['district'] = district.isNotEmpty ? district : null;

      // OTA-ONA MA'LUMOTLARI
      if (parentFirstName != null)
        updates['parent_first_name'] = parentFirstName.isNotEmpty
            ? parentFirstName
            : null;
      if (parentLastName != null)
        updates['parent_last_name'] = parentLastName.isNotEmpty
            ? parentLastName
            : null;
      if (parentMiddleName != null)
        updates['parent_middle_name'] = parentMiddleName.isNotEmpty
            ? parentMiddleName
            : null;
      if (parentPhone != null)
        updates['parent_phone'] = parentPhone.isNotEmpty ? parentPhone : null;
      if (parentPhone2 != null)
        updates['parent_phone_secondary'] = parentPhone2.isNotEmpty
            ? parentPhone2
            : null;
      if (parentWorkplace != null)
        updates['parent_workplace'] = parentWorkplace.isNotEmpty
            ? parentWorkplace
            : null;
      if (parentRelation != null) updates['parent_relation'] = parentRelation;

      // MOLIYAVIY
      if (monthlyFee != null) updates['monthly_fee'] = monthlyFee;
      if (discountPercent != null)
        updates['discount_percent'] = discountPercent;
      if (discountAmount != null) updates['discount_amount'] = discountAmount;
      if (discountReason != null)
        updates['discount_reason'] = discountReason.isNotEmpty
            ? discountReason
            : null;

      // QO'SHIMCHA
      if (notes != null) updates['notes'] = notes.isNotEmpty ? notes : null;
      if (medicalNotes != null)
        updates['medical_notes'] = medicalNotes.isNotEmpty
            ? medicalNotes
            : null;
      if (photoUrl != null) updates['photo_url'] = photoUrl;

      // SINF MA'LUMOTLARI
      if (classId != null) updates['class_id'] = classId;
      if (classLevelId != null) updates['class_level_id'] = classLevelId;
      if (classLevelName != null) updates['class_level_name'] = classLevelName;
      if (className != null) updates['class_name'] = className;
      if (roomId != null) updates['room_id'] = roomId;
      if (roomName != null) updates['room_name'] = roomName;
      if (mainTeacherId != null) updates['main_teacher_id'] = mainTeacherId;
      if (mainTeacherName != null)
        updates['main_teacher_name'] = mainTeacherName;

      // Updated_at maydonini avtomatik qo'shish
      updates['updated_at'] = DateTime.now().toIso8601String();

      if (updates.isEmpty) {
        print('⚠️ Yangilanadigan ma\'lumotlar yo\'q');
        return false;
      }

      print('📤 Yangilanadigan maydonlar: ${updates.keys.join(', ')}');
      print('📦 To\'liq ma\'lumotlar: $updates');

      await _supabase.from('students').update(updates).eq('id', studentId);

      print('✅ O\'quvchi muvaffaqiyatli yangilandi!');
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
      return response
          .map<StudentModel>((json) => StudentModel.fromJson(json))
          .toList();
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
          .update({
            'status': 'inactive',
            'updated_at': DateTime.now().toIso8601String(),
          })
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
      final count = await _supabase
          .from('students')
          .count()
          .eq('class_id', classId)
          .eq('status', 'active');
      return count;
    } catch (e) {
      print('❌ getClassStudentCount xatosi: $e');
      return 0;
    }
  }

  /// Filialdagi o'quvchilar sonini olish
  Future<int> getBranchStudentCount(String branchId) async {
    try {
      final count = await _supabase
          .from('students')
          .count()
          .eq('branch_id', branchId)
          .eq('status', 'active');
      return count;
    } catch (e) {
      print('❌ getBranchStudentCount xatosi: $e');
      return 0;
    }
  }

  /// O'quvchini qidirish
  Future<List<StudentModel>> searchStudents({
    required String branchId,
    String? searchQuery,
    String? classId,
    String? status,
  }) async {
    try {
      var query = _supabase
          .from('students')
          .select('*')
          .eq('branch_id', branchId);
      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or(
          'first_name.ilike.%$searchQuery%,last_name.ilike.%$searchQuery%,phone.ilike.%$searchQuery%',
        );
      }

      if (classId != null) {
        query = query.eq('class_id', classId);
      }

      if (status != null) {
        query = query.eq('status', status);
      }

      final response = await query.order('last_name');

      return response
          .map<StudentModel>((json) => StudentModel.fromJson(json))
          .toList();
    } catch (e) {
      print('❌ searchStudents xatosi: $e');
      return [];
    }
  }
}
