// lib/data/repositories/student_repository.dart
// TO'LIQ TUZATILGAN VA OPTIMALLASHTIRILGAN VERSIYA

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/student_model.dart';

class StudentRepository {
  final _supabase = Supabase.instance.client;

  // =====================================================
  // O'QUVCHILARNI OLISH (PAGINATION + FILTER)
  // =====================================================
  Future<List<StudentModel>> getStudents({
    required String branchId,
    String? status,
    String? searchQuery,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      var query = _supabase
          .from('students')
          .select()
          .eq('branch_id', branchId)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      // Status filter
      if (status != null && status.isNotEmpty) {
        ('status', status);
      }

      // Search filter (ism, familiya, telefon)
      if (searchQuery != null && searchQuery.isNotEmpty) {
        (
          'first_name.ilike.%$searchQuery%,'
              'last_name.ilike.%$searchQuery%,'
              'phone.ilike.%$searchQuery%,'
              'parent_phone.ilike.%$searchQuery%',
        );
      }

      final response = await query;

      return (response as List)
          .map((json) => StudentModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('❌ getStudents xatolik: $e');
      rethrow;
    }
  }

  // =====================================================
  // O'QUVCHILAR SONINI OLISH
  // =====================================================
  Future<int> getStudentsCount({
    required String branchId,
    String? status,
  }) async {
    try {
      var query = _supabase
          .from('students')
          .select('id')
          .eq('branch_id', branchId);

      if (status != null && status.isNotEmpty) {
        query = query.eq('status', status);
      }

      final response = await query.count();
      return response.count;
    } catch (e) {
      print('❌ getStudentsCount xatolik: $e');
      return 0;
    }
  }

  // =====================================================
  // BITTA O'QUVCHINI ID ORQALI OLISH
  // =====================================================
  Future<StudentModel?> getStudentById(String studentId) async {
    try {
      final response = await _supabase
          .from('students')
          .select()
          .eq('id', studentId)
          .maybeSingle();

      if (response == null) return null;

      return StudentModel.fromJson(response);
    } catch (e) {
      print('❌ getStudentById xatolik: $e');
      return null;
    }
  }

  // =====================================================
  // YANGI O'QUVCHI QO'SHISH
  // =====================================================
  Future<StudentModel?> createStudent({
    required String branchId,
    required String firstName,
    required String lastName,
    String? middleName,
    required String gender,
    required DateTime birthDate,
    String? phone,
    String? address,
    String? region,
    String? district,
    required String parentFirstName,
    required String parentLastName,
    String? parentMiddleName,
    required String parentPhone,
    String? parentPhoneSecondary,
    String? parentWorkplace,
    String? parentRelation,
    required double monthlyFee,
    double discountPercent = 0,
    double discountAmount = 0,
    String? discountReason,
    String? notes,
    String? medicalNotes,
    String? visitorId,
    String? createdBy,
    String? classId,
  }) async {
    try {
      final data = {
        'branch_id': branchId,
        'first_name': firstName,
        'last_name': lastName,
        'middle_name': middleName,
        'gender': gender,
        'birth_date': birthDate.toIso8601String(),
        'phone': phone,
        'address': address,
        'region': region,
        'district': district,
        'parent_first_name': parentFirstName,
        'parent_last_name': parentLastName,
        'parent_middle_name': parentMiddleName,
        'parent_phone': parentPhone,
        'parent_phone_secondary': parentPhoneSecondary,
        'parent_workplace': parentWorkplace,
        'parent_relation': parentRelation ?? 'Otasi',
        'monthly_fee': monthlyFee,
        'discount_percent': discountPercent,
        'discount_amount': discountAmount,
        'discount_reason': discountReason,
        'notes': notes,
        'medical_notes': medicalNotes,
        'visitor_id': visitorId,
        'status': 'active',
        'enrollment_date': DateTime.now().toIso8601String(),
        'created_by': createdBy,
      };

      final response = await _supabase
          .from('students')
          .insert(data)
          .select()
          .single();

      // Agar visitor'dan yaratilgan bo'lsa, visitor'ni converted qilish
      if (visitorId != null) {
        await _supabase
            .from('visitors')
            .update({
              'is_converted': true,
              'converted_at': DateTime.now().toIso8601String(),
              'converted_to_student_id': response['id'],
            })
            .eq('id', visitorId);
      }

      return StudentModel.fromJson(response);
    } catch (e) {
      print('❌ createStudent xatolik: $e');
      return null;
    }
  }

  // =====================================================
  // O'QUVCHINI YANGILASH
  // =====================================================
  // lib/data/repositories/student_repository.dart (update metodini qo'shish)

  // StudentRepository klassiga quyidagi metodlarni qo'shing:

  /// O'quvchi ma'lumotlarini yangilash
  Future<bool> updateStudent({
    required String studentId,
    String? firstName,
    String? lastName,
    String? middleName,
    String? phone,
    String? phoneSecondary,
    String? address,
    String? region,
    String? district,
    String? parentPhone,
    String? parentPhoneSecondary,
    String? parentWorkplace,
    double? monthlyFee,
    double? discountPercent,
    String? discountReason,
    String? medicalNotes,
    String? notes,
    String? status,
    String? photoUrl, // Bu qatorni qo'shing
  }) async {
    try {
      final Map<String, dynamic> updates = {};

      if (firstName != null) updates['first_name'] = firstName;
      if (lastName != null) updates['last_name'] = lastName;
      if (middleName != null) updates['middle_name'] = middleName;
      if (phone != null) updates['phone'] = phone;
      if (phoneSecondary != null) updates['phone_secondary'] = phoneSecondary;
      if (address != null) updates['address'] = address;
      if (region != null) updates['region'] = region;
      if (district != null) updates['district'] = district;
      if (parentPhone != null) updates['parent_phone'] = parentPhone;
      if (parentPhoneSecondary != null)
        updates['parent_phone_secondary'] = parentPhoneSecondary;
      if (parentWorkplace != null)
        updates['parent_workplace'] = parentWorkplace;
      if (monthlyFee != null) {
        updates['monthly_fee'] = monthlyFee;
        final percent = discountPercent ?? 0.0;
        final discountAmount = monthlyFee * (percent / 100);
        updates['discount_percent'] = percent;
        updates['discount_amount'] = discountAmount;
        updates['final_monthly_fee'] = monthlyFee - discountAmount;
      }
      if (discountReason != null) updates['discount_reason'] = discountReason;
      if (medicalNotes != null) updates['medical_notes'] = medicalNotes;
      if (notes != null) updates['notes'] = notes;
      if (status != null) updates['status'] = status;
      if (photoUrl != null)
        updates['photo_url'] = photoUrl; // Bu qatorni qo'shing

      updates['updated_at'] = DateTime.now().toIso8601String();

      await Supabase.instance.client
          .from('students')
          .update(updates)
          .eq('id', studentId);

      return true;
    } catch (e) {
      print('Update student error: $e');
      throw Exception('O\'quvchi ma\'lumotlarini yangilashda xatolik: $e');
    }
  }

  /// O'quvchini o'chirish (soft delete)
  Future<bool> deleteStudent(String studentId) async {
    try {
      await Supabase.instance.client
          .from('students')
          .update({
            'status': 'deleted',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', studentId);

      return true;
    } catch (e) {
      print('Delete student error: $e');
      throw Exception('O\'quvchini o\'chirishda xatolik: $e');
    }
  }

  /// O'quvchi statusini o'zgartirish
  Future<bool> updateStudentStatus(String studentId, String status) async {
    try {
      await Supabase.instance.client
          .from('students')
          .update({
            'status': status,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', studentId);

      return true;
    } catch (e) {
      print('Update student status error: $e');
      throw Exception('Status o\'zgartirishda xatolik: $e');
    }
  }

  /// O'quvchini sinfdan chiqarish
  Future<bool> removeStudentFromClass(String studentId, String classId) async {
    try {
      await Supabase.instance.client
          .from('enrollments')
          .update({
            'is_active': false,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('student_id', studentId)
          .eq('class_id', classId);

      return true;
    } catch (e) {
      print('Remove student from class error: $e');
      throw Exception('Sinfdan chiqarishda xatolik: $e');
    }
  }

  /// O'quvchini boshqa sinfga ko'chirish
  Future<bool> transferStudent({
    required String studentId,
    required String oldClassId,
    required String newClassId,
    required String branchId,
  }) async {
    try {
      // Eski sinfdan chiqarish
      await removeStudentFromClass(studentId, oldClassId);

      // Yangi sinfga qo'shish
      await enrollStudentToClass(
        studentId: studentId,
        classId: newClassId,
        branchId: branchId,
      );

      return true;
    } catch (e) {
      print('Transfer student error: $e');
      throw Exception('O\'quvchini ko\'chirishda xatolik: $e');
    }
  }

  // =====================================================
  // O'QUVCHINI O'CHIRISH
  // =====================================================

  // =====================================================
  // VISITOR'DAN O'QUVCHI YARATISH
  // =====================================================
  Future<StudentModel?> createStudentFromVisitor({
    required String visitorId,
    required String branchId,
    required double monthlyFee,
    String? classId,
    String? notes,
    String? createdBy,
  }) async {
    try {
      // 1. Visitor ma'lumotlarini olish
      final visitorResponse = await _supabase
          .from('visitors')
          .select()
          .eq('id', visitorId)
          .single();

      final visitor = visitorResponse;

      // 2. O'quvchi yaratish
      final student = await createStudent(
        branchId: branchId,
        firstName: visitor['first_name'] as String,
        lastName: visitor['last_name'] as String,
        middleName: visitor['middle_name'] as String?,
        gender: visitor['gender'] as String? ?? 'male',
        birthDate: visitor['birth_date'] != null
            ? DateTime.parse(visitor['birth_date'] as String)
            : DateTime.now().subtract(const Duration(days: 365 * 7)),
        phone: visitor['phone'] as String?,
        address: visitor['address'] as String?,
        region: visitor['region'] as String?,
        district: visitor['district'] as String?,
        parentFirstName: 'Ota-ona',
        parentLastName: 'ismi',
        parentPhone: visitor['phone'] as String,
        monthlyFee: monthlyFee,
        notes: notes ?? visitor['notes'] as String?,
        visitorId: visitorId,
        createdBy: createdBy,
      );

      // 3. Agar sinf berilgan bo'lsa, enrollment yaratish
      if (student != null && classId != null) {
        await _createEnrollment(
          studentId: student.id,
          classId: classId,
          branchId: branchId,
        );
      }

      return student;
    } catch (e) {
      print('❌ createStudentFromVisitor xatolik: $e');
      return null;
    }
  }

  // =====================================================
  // ENROLLMENT YARATISH (ICHKI FUNKSIYA)
  // =====================================================
  Future<void> _createEnrollment({
    required String studentId,
    required String classId,
    required String branchId,
  }) async {
    try {
      // Academic year'ni olish
      final academicYearResponse = await _supabase
          .from('academic_years')
          .select('id')
          .eq('is_current', true)
          .maybeSingle();

      if (academicYearResponse == null) return;

      final academicYearId = academicYearResponse['id'] as String;

      await _supabase.from('enrollments').insert({
        'student_id': studentId,
        'class_id': classId,
        'academic_year_id': academicYearId,
        'enrolled_at': DateTime.now().toIso8601String(),
        'is_active': true,
      });
    } catch (e) {
      print('❌ _createEnrollment xatolik: $e');
    }
  }

  // =====================================================
  // O'QUVCHINI SINFGA BIRIKTIRISH
  // =====================================================
  Future<bool> enrollStudentToClass({
    required String studentId,
    required String classId,
    required String branchId,
  }) async {
    try {
      await _createEnrollment(
        studentId: studentId,
        classId: classId,
        branchId: branchId,
      );
      return true;
    } catch (e) {
      print('❌ enrollStudentToClass xatolik: $e');
      return false;
    }
  }

  // =====================================================
  // O'QUVCHI STATISTIKASI
  // =====================================================
  Future<Map<String, dynamic>> getStudentStatistics(String branchId) async {
    try {
      // Jami o'quvchilar
      final total = await getStudentsCount(branchId: branchId);

      // Faol o'quvchilar
      final active = await getStudentsCount(
        branchId: branchId,
        status: 'active',
      );

      // To'xtatilgan
      final paused = await getStudentsCount(
        branchId: branchId,
        status: 'paused',
      );

      // Bitirganlar
      final graduated = await getStudentsCount(
        branchId: branchId,
        status: 'graduated',
      );

      return {
        'total': total,
        'active': active,
        'paused': paused,
        'graduated': graduated,
      };
    } catch (e) {
      print('❌ getStudentStatistics xatolik: $e');
      return {'total': 0, 'active': 0, 'paused': 0, 'graduated': 0};
    }
  }

  Future<List<Map<String, dynamic>>> getTeachers(String branchId) async {
    try {
      print('🔄 Fetching teachers for branch: $branchId');

      final response = await _supabase
          .from('staff')
          .select('''
            id,
            first_name,
            last_name,
            middle_name,
            phone,
            position,
            default_room_id
          ''')
          .eq('branch_id', branchId)
          .eq('is_teacher', true)
          .eq('status', 'active')
          .order('last_name');

      print('✅ Teachers fetched: ${response.length}');

      // Har bir o'qituvchi uchun sinf va xona ma'lumotlarini olish
      List<Map<String, dynamic>> teachers = [];

      for (var teacher in response) {
        // O'qituvchining sinfini topish
        final classResponse = await _supabase
            .from('classes')
            .select('id, name, default_room_id')
            .eq('main_teacher_id', teacher['id'])
            .eq('is_active', true)
            .maybeSingle();

        // Xona ma'lumotini olish
        String? roomName;
        if (teacher['default_room_id'] != null) {
          final roomResponse = await _supabase
              .from('rooms')
              .select('name')
              .eq('id', teacher['default_room_id'])
              .maybeSingle();

          roomName = roomResponse?['name'];
        }

        teachers.add({
          'id': teacher['id'],
          'full_name': '${teacher['first_name']} ${teacher['last_name']}',
          'first_name': teacher['first_name'],
          'last_name': teacher['last_name'],
          'middle_name': teacher['middle_name'],
          'phone': teacher['phone'],
          'position': teacher['position'],
          'class_id': classResponse?['id'],
          'class_name': classResponse?['name'],
          'room_id':
              teacher['default_room_id'] ?? classResponse?['default_room_id'],
          'room_name': roomName,
        });
      }

      print('📊 Teachers processed: ${teachers.length}');
      return teachers;
    } catch (e) {
      print('❌ getTeachers error: $e');
      return [];
    }
  }

  /// Xonalar ro'yxatini olish
  Future<List<Map<String, dynamic>>> getRooms(String branchId) async {
    try {
      print('🔄 Fetching rooms for branch: $branchId');

      final response = await _supabase
          .from('rooms')
          .select('id, name, capacity, floor, room_type')
          .eq('branch_id', branchId)
          .eq('is_active', true)
          .order('name');

      print('✅ Rooms fetched: ${response.length}');

      // Har bir xona uchun sinf va o'qituvchi ma'lumotlarini olish
      List<Map<String, dynamic>> rooms = [];

      for (var room in response) {
        // Xonadagi sinfni topish
        final classResponse = await _supabase
            .from('classes')
            .select('''
              id,
              name,
              main_teacher_id
            ''')
            .eq('default_room_id', room['id'])
            .eq('is_active', true)
            .maybeSingle();

        // O'qituvchi ma'lumotini olish
        String? teacherName;
        if (classResponse?['main_teacher_id'] != null) {
          final teacherResponse = await _supabase
              .from('staff')
              .select('first_name, last_name')
              .eq('id', classResponse?['main_teacher_id'])
              .maybeSingle();

          if (teacherResponse != null) {
            teacherName =
                '${teacherResponse['first_name']} ${teacherResponse['last_name']}';
          }
        }

        rooms.add({
          'id': room['id'],
          'name': room['name'],
          'capacity': room['capacity'],
          'floor': room['floor'],
          'room_type': room['room_type'],
          'class_id': classResponse?['id'],
          'class_name': classResponse?['name'],
          'teacher_id': classResponse?['main_teacher_id'],
          'teacher_name': teacherName,
        });
      }

      print('📊 Rooms processed: ${rooms.length}');
      return rooms;
    } catch (e) {
      print('❌ getRooms error: $e');
      return [];
    }
  }

  /// Sinf darajalarini olish
  Future<List<Map<String, dynamic>>> getClassLevels() async {
    try {
      print('🔄 Fetching class levels...');

      final response = await _supabase
          .from('class_levels')
          .select('id, name, order_number')
          .eq('is_active', true)
          .order('order_number');

      print('✅ Class levels fetched: ${response.length}');

      return response
          .map(
            (item) => {
              'id': item['id'] as String,
              'name': item['name'] as String,
              'order_number': item['order_number'] as int,
            },
          )
          .toList();
    } catch (e) {
      print('❌ getClassLevels error: $e');
      return [];
    }
  }

  /// Sinflarni batafsil ma'lumot bilan olish
  Future<List<Map<String, dynamic>>> getClassesWithDetails(
    String branchId,
  ) async {
    try {
      print('🔄 Fetching classes for branch: $branchId');

      final response = await _supabase
          .from('classes')
          .select('''
            id,
            name,
            code,
            class_level_id,
            main_teacher_id,
            default_room_id,
            monthly_fee,
            max_students,
            class_levels!inner(name),
            staff(first_name, last_name),
            rooms(name)
          ''')
          .eq('branch_id', branchId)
          .eq('is_active', true)
          .order('name');

      print('✅ Classes fetched: ${response.length}');

      return response.map((item) {
        final teacher = item['staff'];
        final room = item['rooms'];
        final classLevel = item['class_levels'];

        return {
          'id': item['id'],
          'name': item['name'],
          'code': item['code'],
          'class_level_id': item['class_level_id'],
          'class_level_name': classLevel?['name'],
          'main_teacher_id': item['main_teacher_id'],
          'teacher': teacher != null
              ? '${teacher['first_name']} ${teacher['last_name']}'
              : 'Tayinlanmagan',
          'default_room_id': item['default_room_id'],
          'room': room?['name'] ?? 'Tayinlanmagan',
          'monthly_fee': item['monthly_fee'],
          'max_students': item['max_students'],
        };
      }).toList();
    } catch (e) {
      print('❌ getClassesWithDetails error: $e');
      return [];
    }
  }
}
