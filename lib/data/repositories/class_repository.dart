// lib/data/repositories/class_repository.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class ClassRepository {
  final _supabase = Supabase.instance.client;

  // ==================== SINF DARAJALARI ====================

  /// Barcha sinf daraja larini olish (1-sinf, 2-sinf, ...)
  Future<List<Map<String, dynamic>>> getClassLevels() async {
    try {
      final response = await _supabase
          .from('class_levels')
          .select('id, level_name, level_number, description')
          .order('level_number');

      print('✅ Class Levels: ${response.length}');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ getClassLevels error: $e');
      return [];
    }
  }

  // ==================== SINFLAR ====================

  /// Filialning barcha sinflarini olish
  Future<List<Map<String, dynamic>>> getClasses(String branchId) async {
    try {
      final response = await _supabase
          .from('classes')
          .select('id, name, class_level_id, capacity, is_active')
          .eq('branch_id', branchId)
          .eq('is_active', true)
          .order('name');

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('getClasses error: $e');
      return [];
    }
  }

  /// Sinflarni to'liq ma'lumotlar bilan olish (o'qituvchi, xona, va h.k.)
  Future<List<Map<String, dynamic>>> getClassesWithDetails(
    String branchId,
  ) async {
    try {
      print('🔍 Loading classes for branch: $branchId');

      final response = await _supabase
          .from('classes')
          .select('''
          id,
          name,
          class_level_id,
          capacity,
          monthly_fee,
          is_active,
          default_room_id,
          main_teacher_id,
          class_levels:class_level_id (
            level_name,
            level_number
          ),
          rooms:default_room_id (
            name,
            room_number
          ),
          users:main_teacher_id (
            first_name,
            last_name
          )
        ''')
          .eq('branch_id', branchId)
          .eq('is_active', true)
          .order('name');

      print('📦 Classes raw response: $response');

      // Ma'lumotlarni flatten qilish
      final classes = <Map<String, dynamic>>[];

      for (var classData in response) {
        final classLevel = classData['class_levels'] as Map<String, dynamic>?;
        final room = classData['rooms'] as Map<String, dynamic>?;
        final teacher = classData['users'] as Map<String, dynamic>?;

        final processedClass = {
          'id': classData['id'],
          'name': classData['name'],
          'class_level_id': classData['class_level_id'],
          'capacity': classData['capacity'],
          'monthly_fee': classData['monthly_fee'],
          'is_active': classData['is_active'],
          'default_room_id': classData['default_room_id'],
          'main_teacher_id': classData['main_teacher_id'],
          // Flatten qilingan ma'lumotlar
          'level_name': classLevel?['level_name'],
          'level_number': classLevel?['level_number'],
          'room': room?['name'] ?? room?['room_number'] ?? '',
          'teacher': teacher != null
              ? '${teacher['last_name']} ${teacher['first_name']}'
              : '',
        };

        classes.add(processedClass);

        print('  📌 Class: ${processedClass['name']}');
        print('     - Teacher: ${processedClass['teacher']}');
        print('     - Room: ${processedClass['room']}');
      }

      print('✅ Loaded ${classes.length} classes');
      return classes;
    } catch (e) {
      print('❌ getClassesWithDetails error: $e');
      return [];
    }
  }

  // ==================== O'QITUVCHILAR ====================

  /// Filialning barcha o'qituvchilarini olish
  Future<List<Map<String, dynamic>>> getTeachers(String branchId) async {
    try {
      print('🔍 Loading teachers for branch: $branchId');

      // 1. Barcha faol xodimlarni olish
      final staffResponse = await _supabase
          .from('staff')
          .select('id, first_name, last_name, middle_name, phone')
          .eq('branch_id', branchId)
          .eq('is_active', true)
          .eq('status', 'active')
          .order('last_name');

      print('📦 Staff response: ${staffResponse.length}');

      final List<Map<String, dynamic>> teachers = [];

      for (var staff in staffResponse) {
        final teacherMap = Map<String, dynamic>.from(staff);

        teacherMap['full_name'] =
            '${teacherMap['last_name']} ${teacherMap['first_name']} ${teacherMap['middle_name'] ?? ''}'
                .trim();

        // Bu o'qituvchining sinfini topish
        try {
          final classResponse = await _supabase
              .from('classes')
              .select('id, name, default_room_id')
              .eq('main_teacher_id', teacherMap['id'])
              .eq('is_active', true)
              .maybeSingle();

          if (classResponse != null) {
            teacherMap['class_id'] = classResponse['id'];
            teacherMap['class_name'] = classResponse['name'];

            // Sinf xonasini olish
            if (classResponse['default_room_id'] != null) {
              final roomResponse = await _supabase
                  .from('rooms')
                  .select('id, name, room_number')
                  .eq('id', classResponse['default_room_id'])
                  .maybeSingle();

              if (roomResponse != null) {
                teacherMap['room_id'] = roomResponse['id'];
                teacherMap['room_name'] =
                    roomResponse['name'] ?? roomResponse['room_number'];
              }
            }
          }
        } catch (e) {
          print('⚠️ No class found for teacher: ${teacherMap['full_name']}');
        }

        teachers.add(teacherMap);

        print('  📌 Teacher: ${teacherMap['full_name']}');
        print('     - Class: ${teacherMap['class_name'] ?? 'Yo\'q'}');
        print('     - Room: ${teacherMap['room_name'] ?? 'Yo\'q'}');
      }

      print('✅ Loaded ${teachers.length} teachers');
      return teachers;
    } catch (e) {
      print('❌ getTeachers error: $e');
      return [];
    }
  }

  // ==================== XONALAR ====================

  /// Filialning barcha xonalarini olish
  Future<List<Map<String, dynamic>>> getRooms(String branchId) async {
    try {
      print('🔍 Loading rooms for branch: $branchId');

      final roomsResponse = await _supabase
          .from('rooms')
          .select('id, name, room_number, capacity, floor, room_type')
          .eq('branch_id', branchId)
          .eq('is_active', true)
          .order('name');

      print('📦 Rooms response: ${roomsResponse.length}');

      final List<Map<String, dynamic>> rooms = [];

      for (var room in roomsResponse) {
        final roomMap = Map<String, dynamic>.from(room);

        // Bu xonada qaysi sinf ekanligini topish
        try {
          final classResponse = await _supabase
              .from('classes')
              .select('id, name, main_teacher_id')
              .eq('default_room_id', roomMap['id'])
              .eq('is_active', true)
              .maybeSingle();

          if (classResponse != null) {
            roomMap['class_id'] = classResponse['id'];
            roomMap['class_name'] = classResponse['name'];

            // Sinf o'qituvchisini olish
            if (classResponse['main_teacher_id'] != null) {
              final teacherResponse = await _supabase
                  .from('staff')
                  .select('id, first_name, last_name')
                  .eq('id', classResponse['main_teacher_id'])
                  .maybeSingle();

              if (teacherResponse != null) {
                roomMap['teacher_id'] = teacherResponse['id'];
                roomMap['teacher_name'] =
                    '${teacherResponse['last_name']} ${teacherResponse['first_name']}';
              }
            }
          }
        } catch (e) {
          print('⚠️ No class found for room: ${roomMap['name']}');
        }

        rooms.add(roomMap);

        print('  📌 Room: ${roomMap['name']}');
        print('     - Class: ${roomMap['class_name'] ?? 'Yo\'q'}');
        print('     - Teacher: ${roomMap['teacher_name'] ?? 'Yo\'q'}');
      }

      print('✅ Loaded ${rooms.length} rooms');
      return rooms;
    } catch (e) {
      print('❌ getRooms error: $e');
      return [];
    }
  }

  /// Bitta sinf ma'lumotlarini olish
  Future<Map<String, dynamic>?> getClassById(String classId) async {
    try {
      final response = await _supabase
          .from('classes')
          .select('''
          id,
          name,
          branch_id,
          class_level_id,
          capacity,
          monthly_fee,
          is_active,
          default_room_id,
          main_teacher_id,
          description,
          created_at,
          class_levels:class_level_id (
            level_name,
            level_number
          ),
          rooms:default_room_id (
            name,
            room_number,
            capacity
          ),
          users:main_teacher_id (
            id,
            first_name,
            last_name,
            phone
          )
        ''')
          .eq('id', classId)
          .maybeSingle();

      if (response == null) return null;

      // Ma'lumotlarni flatten qilish
      final classLevel = response['class_levels'] as Map<String, dynamic>?;
      final room = response['rooms'] as Map<String, dynamic>?;
      final teacher = response['users'] as Map<String, dynamic>?;

      return {
        ...response,
        'level_name': classLevel?['level_name'],
        'level_number': classLevel?['level_number'],
        'room_name': room?['name'],
        'room_number': room?['room_number'],
        'room_capacity': room?['capacity'],
        'teacher_name': teacher != null
            ? '${teacher['last_name']} ${teacher['first_name']}'
            : null,
        'teacher_phone': teacher?['phone'],
      };
    } catch (e) {
      print('getClassById error: $e');
      return null;
    }
  }

  // ==================== SINF YARATISH VA YANGILASH ====================

  /// Yangi sinf yaratish
  Future<Map<String, dynamic>?> createClass({
    required String branchId,
    required String name,
    required String classLevelId,
    int? capacity,
    double? monthlyFee,
    String? defaultRoomId,
    String? mainTeacherId,
    String? description,
  }) async {
    try {
      final data = {
        'branch_id': branchId,
        'name': name,
        'class_level_id': classLevelId,
        'capacity': capacity ?? 30,
        'monthly_fee': monthlyFee ?? 900000,
        'default_room_id': defaultRoomId,
        'main_teacher_id': mainTeacherId,
        'description': description,
        'is_active': true,
      };

      final response = await _supabase
          .from('classes')
          .insert(data)
          .select()
          .single();

      return response;
    } catch (e) {
      print('createClass error: $e');
      throw Exception('Sinf yaratishda xatolik: $e');
    }
  }

  /// Sinfni yangilash
  Future<bool> updateClass({
    required String classId,
    String? name,
    String? classLevelId,
    int? capacity,
    double? monthlyFee,
    String? defaultRoomId,
    String? mainTeacherId,
    String? description,
    bool? isActive,
  }) async {
    try {
      final Map<String, dynamic> updates = {};

      if (name != null) updates['name'] = name;
      if (classLevelId != null) updates['class_level_id'] = classLevelId;
      if (capacity != null) updates['capacity'] = capacity;
      if (monthlyFee != null) updates['monthly_fee'] = monthlyFee;
      if (defaultRoomId != null) updates['default_room_id'] = defaultRoomId;
      if (mainTeacherId != null) updates['main_teacher_id'] = mainTeacherId;
      if (description != null) updates['description'] = description;
      if (isActive != null) updates['is_active'] = isActive;

      updates['updated_at'] = DateTime.now().toIso8601String();

      await _supabase.from('classes').update(updates).eq('id', classId);

      return true;
    } catch (e) {
      print('updateClass error: $e');
      throw Exception('Sinfni yangilashda xatolik: $e');
    }
  }

  /// Sinfni o'chirish (soft delete)
  Future<bool> deleteClass(String classId) async {
    try {
      await _supabase
          .from('classes')
          .update({
            'is_active': false,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', classId);

      return true;
    } catch (e) {
      print('deleteClass error: $e');
      throw Exception('Sinfni o\'chirishda xatolik: $e');
    }
  }

  // ==================== SINF O'QUVCHILARI ====================

  /// Sinf o'quvchilarini olish
  Future<List<Map<String, dynamic>>> getClassStudents(String classId) async {
    try {
      final response = await _supabase
          .from('enrollments')
          .select('''
          id,
          enrolled_at,
          is_active,
          students:student_id (
            id,
            first_name,
            last_name,
            middle_name,
            phone,
            status,
            monthly_fee
          )
        ''')
          .eq('class_id', classId)
          .eq('is_active', true)
          .order('enrolled_at');

      final students = <Map<String, dynamic>>[];

      for (var enrollment in response) {
        final student = enrollment['students'] as Map<String, dynamic>?;
        if (student != null) {
          students.add({
            'enrollment_id': enrollment['id'],
            'enrolled_at': enrollment['enrolled_at'],
            'student_id': student['id'],
            'first_name': student['first_name'],
            'last_name': student['last_name'],
            'middle_name': student['middle_name'],
            'phone': student['phone'],
            'status': student['status'],
            'monthly_fee': student['monthly_fee'],
            'full_name':
                '${student['last_name']} ${student['first_name']} ${student['middle_name'] ?? ''}',
          });
        }
      }

      return students;
    } catch (e) {
      print('getClassStudents error: $e');
      return [];
    }
  }

  /// Sinf o'quvchilari sonini olish
  Future<int> getClassStudentsCount(String classId) async {
    try {
      final response = await _supabase
          .from('enrollments')
          .select('id')
          .eq('class_id', classId)
          .eq('is_active', true);

      return (response as List).length;
    } catch (e) {
      print('getClassStudentsCount error: $e');
      return 0;
    }
  }

  // ==================== SINF STATISTIKASI ====================

  /// Sinf statistikasi
  Future<Map<String, dynamic>> getClassStatistics(String classId) async {
    try {
      // O'quvchilar soni
      final studentsCount = await getClassStudentsCount(classId);

      // Sinf ma'lumotlari
      final classData = await getClassById(classId);
      final capacity = classData?['capacity'] ?? 30;

      // To'lovlar statistikasi (joriy oy)
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);

      final paymentsResponse = await _supabase
          .from('payments')
          .select('amount, status')
          .eq('class_id', classId)
          .gte('payment_date', startOfMonth.toIso8601String());

      double totalPaid = 0;
      double totalPending = 0;

      for (var payment in paymentsResponse) {
        final amount = (payment['amount'] as num?)?.toDouble() ?? 0;
        if (payment['status'] == 'paid') {
          totalPaid += amount;
        } else {
          totalPending += amount;
        }
      }

      return {
        'students_count': studentsCount,
        'capacity': capacity,
        'available_seats': capacity - studentsCount,
        'occupancy_rate': capacity > 0 ? (studentsCount / capacity * 100) : 0,
        'monthly_paid': totalPaid,
        'monthly_pending': totalPending,
      };
    } catch (e) {
      print('getClassStatistics error: $e');
      return {
        'students_count': 0,
        'capacity': 0,
        'available_seats': 0,
        'occupancy_rate': 0,
        'monthly_paid': 0,
        'monthly_pending': 0,
      };
    }
  }

  // ==================== SINF DARAJALARI BILAN ISHLASH ====================

  /// Sinf darajasini yaratish
  Future<Map<String, dynamic>?> createClassLevel({
    required String levelName,
    required int levelNumber,
    String? description,
  }) async {
    try {
      final data = {
        'level_name': levelName,
        'level_number': levelNumber,
        'description': description,
      };

      final response = await _supabase
          .from('class_levels')
          .insert(data)
          .select()
          .single();

      return response;
    } catch (e) {
      print('createClassLevel error: $e');
      throw Exception('Sinf darajasini yaratishda xatolik: $e');
    }
  }

  /// Sinf darajasini yangilash
  Future<bool> updateClassLevel({
    required String levelId,
    String? levelName,
    int? levelNumber,
    String? description,
  }) async {
    try {
      final Map<String, dynamic> updates = {};

      if (levelName != null) updates['level_name'] = levelName;
      if (levelNumber != null) updates['level_number'] = levelNumber;
      if (description != null) updates['description'] = description;

      await _supabase.from('class_levels').update(updates).eq('id', levelId);

      return true;
    } catch (e) {
      print('updateClassLevel error: $e');
      throw Exception('Sinf darajasini yangilashda xatolik: $e');
    }
  }

  /// Sinf darajasini o'chirish
  Future<bool> deleteClassLevel(String levelId) async {
    try {
      // Tekshirish: bu darajada sinflar bor-yo'qligini
      final classesResponse = await _supabase
          .from('classes')
          .select('id')
          .eq('class_level_id', levelId)
          .limit(1);

      if (classesResponse.isNotEmpty) {
        throw Exception(
          'Bu sinf darajasida sinflar mavjud. Avval sinflarni o\'chiring.',
        );
      }

      await _supabase.from('class_levels').delete().eq('id', levelId);

      return true;
    } catch (e) {
      print('deleteClassLevel error: $e');
      throw Exception('Sinf darajasini o\'chirishda xatolik: $e');
    }
  }
}
