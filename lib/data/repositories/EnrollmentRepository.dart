// lib/data/repositories/enrollment_repository.dart

import 'package:supabase_flutter/supabase_flutter.dart';

class EnrollmentRepository {
  final _supabase = Supabase.instance.client;

  Future<Map<String, dynamic>?> getCurrentEnrollment(String studentId) async {
    try {
      // Birinchi navbatda students jadvalidan class_id ni olish
      final student = await _supabase
          .from('students')
          .select('class_id, class_name, main_teacher_name, room_name')
          .eq('id', studentId)
          .maybeSingle();

      if (student == null || student['class_id'] == null) {
        // Enrollments jadvalidan izlash
        final enrollment = await _supabase
            .from('enrollments')
            .select('''
              *,
              classes:class_id(id, name, main_teacher_id, default_room_id)
            ''')
            .eq('student_id', studentId)
            .eq('is_active', true)
            .order('enrolled_at', ascending: false)
            .limit(1)
            .maybeSingle();

        if (enrollment == null) return null;

        String? teacherName;
        String? roomName;

        // O'qituvchi nomini olish
        if (enrollment['classes']?['main_teacher_id'] != null) {
          final teacher = await _supabase
              .from('staff')
              .select('first_name, last_name')
              .eq('id', enrollment['classes']['main_teacher_id'])
              .maybeSingle();
          
          if (teacher != null) {
            teacherName = '${teacher['first_name']} ${teacher['last_name']}';
          }
        }

        // Xona nomini olish
        if (enrollment['classes']?['default_room_id'] != null) {
          final room = await _supabase
              .from('rooms')
              .select('name')
              .eq('id', enrollment['classes']['default_room_id'])
              .maybeSingle();
          
          if (room != null) {
            roomName = room['name'];
          }
        }

        return {
          'id': enrollment['id'],
          'class_id': enrollment['class_id'],
          'class_name': enrollment['classes']?['name'],
          'teacher_name': teacherName,
          'room_name': roomName,
          'enrolled_at': enrollment['enrolled_at'],
          'custom_monthly_fee': enrollment['custom_monthly_fee'],
        };
      }

      // Students jadvalidan ma'lumotlar mavjud
      return {
        'class_id': student['class_id'],
        'class_name': student['class_name'],
        'teacher_name': student['main_teacher_name'],
        'room_name': student['room_name'],
      };
    } catch (e) {
      print('Get current enrollment error: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getStudentEnrollmentHistory(String studentId) async {
    try {
      final response = await _supabase
          .from('enrollments')
          .select('''
            *,
            classes:class_id(name),
            academic_years:academic_year_id(name, start_date, end_date)
          ''')
          .eq('student_id', studentId)
          .order('enrolled_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Get enrollment history error: $e');
      return [];
    }
  }
}