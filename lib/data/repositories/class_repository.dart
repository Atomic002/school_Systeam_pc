// lib/data/repositories/class_repository.dart - YAKUNIY TUZATILGAN

import 'package:supabase_flutter/supabase_flutter.dart';

class ClassRepository {
  final _supabase = Supabase.instance.client;

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
          .map<Map<String, dynamic>>((item) => {
                'id': item['id'] as String,
                'name': item['name'] as String,
                'order_number': item['order_number'] as int,
              })
          .toList();
    } catch (e) {
      print('❌ getClassLevels error: $e');
      return [];
    }
  }

  /// Sinflarni BATAFSIL olish - HAR BIR SINF UCHUN ALOHIDA SO'ROVLAR
  Future<List<Map<String, dynamic>>> getClassesWithDetails(
    String branchId,
  ) async {
    try {
      print('🔄 ========== LOADING CLASSES ==========');
      print('Branch ID: $branchId');

      // 1. Faqat sinflarni olish
      final classesResponse = await _supabase
          .from('classes')
          .select('id, name, code, class_level_id, main_teacher_id, default_room_id, monthly_fee, max_students')
          .eq('branch_id', branchId)
          .eq('is_active', true)
          .order('name');

      print('📦 Classes raw: ${classesResponse.length}');

      if (classesResponse.isEmpty) {
        print('⚠️ No classes found for this branch');
        return [];
      }

      final List<Map<String, dynamic>> classes = [];

      // 2. Har bir sinf uchun to'liq ma'lumotlarni yig'ish
      for (var classData in classesResponse) {
        final Map<String, dynamic> processedClass = {
          'id': classData['id'],
          'name': classData['name'],
          'code': classData['code'],
          'class_level_id': classData['class_level_id'],
          'main_teacher_id': classData['main_teacher_id'],
          'default_room_id': classData['default_room_id'],
          'monthly_fee': classData['monthly_fee'],
          'max_students': classData['max_students'],
          'teacher': 'Tayinlanmagan',
          'room': 'Tayinlanmagan',
        };

        // Sinf darajasini olish
        if (classData['class_level_id'] != null) {
          try {
            final levelResponse = await _supabase
                .from('class_levels')
                .select('name, order_number')
                .eq('id', classData['class_level_id'])
                .maybeSingle();

            if (levelResponse != null) {
              processedClass['class_level_name'] = levelResponse['name'];
              processedClass['class_level_order'] = levelResponse['order_number'];
            }
          } catch (e) {
            print('⚠️ Level fetch error: $e');
          }
        }

        // O'qituvchini olish (staff jadvalidan)
        if (classData['main_teacher_id'] != null) {
          try {
            final teacherResponse = await _supabase
                .from('staff')
                .select('first_name, last_name, middle_name')
                .eq('id', classData['main_teacher_id'])
                .maybeSingle();

            if (teacherResponse != null) {
              processedClass['teacher'] = '${teacherResponse['last_name']} ${teacherResponse['first_name']} ${teacherResponse['middle_name'] ?? ''}'.trim();
              processedClass['teacher_first_name'] = teacherResponse['first_name'];
              processedClass['teacher_last_name'] = teacherResponse['last_name'];
            }
          } catch (e) {
            print('⚠️ Teacher fetch error: $e');
          }
        }

        // Xonani olish
        if (classData['default_room_id'] != null) {
          try {
            final roomResponse = await _supabase
                .from('rooms')
                .select('name, capacity')
                .eq('id', classData['default_room_id'])
                .maybeSingle();

            if (roomResponse != null) {
              processedClass['room'] = roomResponse['name'];
              processedClass['room_capacity'] = roomResponse['capacity'];
            }
          } catch (e) {
            print('⚠️ Room fetch error: $e');
          }
        }

        classes.add(processedClass);
        print('✅ ${processedClass['name']}: ${processedClass['teacher']} | ${processedClass['room']}');
      }

      print('✅ ========== LOADED ${classes.length} CLASSES ==========\n');
      return classes;
    } catch (e) {
      print('❌ getClassesWithDetails error: $e');
      return [];
    }
  }

  /// O'qituvchilarni BATAFSIL olish
  Future<List<Map<String, dynamic>>> getTeachers(String branchId) async {
    try {
      print('🔄 ========== LOADING TEACHERS ==========');
      print('Branch ID: $branchId');

      // 1. Faol o'qituvchilarni olish
      final staffResponse = await _supabase
          .from('staff')
          .select('id, first_name, last_name, middle_name, phone, position')
          .eq('branch_id', branchId)
          .eq('is_teacher', true)
          .eq('status', 'active')
          .order('last_name');

      print('📦 Teachers raw: ${staffResponse.length}');

      if (staffResponse.isEmpty) {
        print('⚠️ No teachers found');
        return [];
      }

      final List<Map<String, dynamic>> teachers = [];

      for (var staff in staffResponse) {
        final Map<String, dynamic> teacher = {
          'id': staff['id'],
          'first_name': staff['first_name'],
          'last_name': staff['last_name'],
          'middle_name': staff['middle_name'],
          'phone': staff['phone'],
          'position': staff['position'],
          'full_name': '${staff['last_name']} ${staff['first_name']} ${staff['middle_name'] ?? ''}'.trim(),
        };

        // O'qituvchining sinfini topish
        try {
          final classResponse = await _supabase
              .from('classes')
              .select('id, name, default_room_id')
              .eq('main_teacher_id', staff['id'])
              .eq('is_active', true)
              .maybeSingle();

          if (classResponse != null) {
            teacher['class_id'] = classResponse['id'];
            teacher['class_name'] = classResponse['name'];

            // Xonani olish
            if (classResponse['default_room_id'] != null) {
              final roomResponse = await _supabase
                  .from('rooms')
                  .select('name')
                  .eq('id', classResponse['default_room_id'])
                  .maybeSingle();

              if (roomResponse != null) {
                teacher['room_id'] = classResponse['default_room_id'];
                teacher['room_name'] = roomResponse['name'];
              }
            }
          }
        } catch (e) {
          print('⚠️ Class fetch error for ${teacher['full_name']}: $e');
        }

        teachers.add(teacher);
        print('✅ ${teacher['full_name']}: ${teacher['class_name'] ?? 'Yo\'q'}');
      }

      print('✅ ========== LOADED ${teachers.length} TEACHERS ==========\n');
      return teachers;
    } catch (e) {
      print('❌ getTeachers error: $e');
      return [];
    }
  }

  /// Xonalarni BATAFSIL olish
  Future<List<Map<String, dynamic>>> getRooms(String branchId) async {
    try {
      print('🔄 ========== LOADING ROOMS ==========');
      print('Branch ID: $branchId');

      // 1. Xonalarni olish
      final roomsResponse = await _supabase
          .from('rooms')
          .select('id, name, capacity, floor, room_type')
          .eq('branch_id', branchId)
          .eq('is_active', true)
          .order('name');

      print('📦 Rooms raw: ${roomsResponse.length}');

      if (roomsResponse.isEmpty) {
        print('⚠️ No rooms found');
        return [];
      }

      final List<Map<String, dynamic>> rooms = [];

      for (var roomData in roomsResponse) {
        final Map<String, dynamic> room = {
          'id': roomData['id'],
          'name': roomData['name'],
          'capacity': roomData['capacity'],
          'floor': roomData['floor'],
          'room_type': roomData['room_type'],
        };

        // Xonadagi sinfni topish
        try {
          final classResponse = await _supabase
              .from('classes')
              .select('id, name, main_teacher_id')
              .eq('default_room_id', roomData['id'])
              .eq('is_active', true)
              .maybeSingle();

          if (classResponse != null) {
            room['class_id'] = classResponse['id'];
            room['class_name'] = classResponse['name'];

            // O'qituvchini olish
            if (classResponse['main_teacher_id'] != null) {
              final teacherResponse = await _supabase
                  .from('staff')
                  .select('first_name, last_name')
                  .eq('id', classResponse['main_teacher_id'])
                  .maybeSingle();

              if (teacherResponse != null) {
                room['teacher_id'] = classResponse['main_teacher_id'];
                room['teacher_name'] = '${teacherResponse['last_name']} ${teacherResponse['first_name']}';
              }
            }
          }
        } catch (e) {
          print('⚠️ Class fetch error for ${room['name']}: $e');
        }

        rooms.add(room);
        print('✅ ${room['name']}: ${room['class_name'] ?? 'Yo\'q'}');
      }

      print('✅ ========== LOADED ${rooms.length} ROOMS ==========\n');
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
          .select('*')
          .eq('id', classId)
          .maybeSingle();

      return response;
    } catch (e) {
      print('❌ getClassById error: $e');
      return null;
    }
  }
}