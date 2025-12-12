// lib/data/repositories/attendance_repository.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/models/payment_model.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AttendanceRepository {
  final _supabase = Supabase.instance.client;

  // O'quvchi davomat tarixini olish
  Future<List<AttendanceModel>> getStudentAttendance(String studentId) async {
    try {
      final response = await _supabase
          .from('attendance_students')
          .select()
          .eq('student_id', studentId)
          .order('attendance_date', ascending: false)
          .limit(100);

      return (response as List)
          .map((json) => AttendanceModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Get student attendance error: $e');
      return [];
    }
  }

  // Sinf davomatini olish
  Future<List<AttendanceModel>> getClassAttendance(
    String classId,
    DateTime date,
  ) async {
    try {
      final response = await _supabase
          .from('attendance_students')
          .select()
          .eq('class_id', classId)
          .eq('attendance_date', date.toIso8601String().split('T')[0])
          .order('student_id');

      return (response as List)
          .map((json) => AttendanceModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Get class attendance error: $e');
      return [];
    }
  }

  // Davomatni saqlash
  Future<bool> markAttendance({
    required String studentId,
    required String classId,
    required String branchId,
    required DateTime date,
    required String status,
    String? notes,
    String? markedBy,
  }) async {
    try {
      await _supabase.from('attendance_students').upsert({
        'student_id': studentId,
        'class_id': classId,
        'branch_id': branchId,
        'attendance_date': date.toIso8601String().split('T')[0],
        'status': status,
        'notes': notes,
        'marked_by': markedBy,
        'marked_at': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      print('Mark attendance error: $e');
      return false;
    }
  }
}

class AttendanceModel {
  final String id;
  final String studentId;
  final String classId;
  final DateTime attendanceDate;
  final String status;
  final DateTime? arrivalTime;
  final String? notes;

  AttendanceModel({
    required this.id,
    required this.studentId,
    required this.classId,
    required this.attendanceDate,
    required this.status,
    this.arrivalTime,
    this.notes,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id'] as String,
      studentId: json['student_id'] as String,
      classId: json['class_id'] as String,
      attendanceDate: DateTime.parse(json['attendance_date'] as String),
      status: json['status'] as String,
      arrivalTime: json['arrival_time'] != null
          ? DateTime.parse(json['arrival_time'] as String)
          : null,
      notes: json['notes'] as String?,
    );
  }
}

// lib/data/repositories/enrollment_repository.dart

class EnrollmentRepository {
  final _supabase = Supabase.instance.client;

  // O'quvchining hozirgi enrollment'ini olish
  Future<Map<String, dynamic>?> getCurrentEnrollment(String studentId) async {
    try {
      final response = await _supabase
          .from('enrollments')
          .select('''
            *,
            classes!inner(
              id,
              name,
              code,
              main_teacher_id,
              default_room_id,
              users!main_teacher_id(first_name, last_name),
              rooms!default_room_id(name)
            )
          ''')
          .eq('student_id', studentId)
          .eq('is_active', true)
          .maybeSingle();

      if (response == null) return null;

      final classData = response['classes'] as Map<String, dynamic>;
      final teacher = classData['users'] as Map<String, dynamic>?;
      final room = classData['rooms'] as Map<String, dynamic>?;

      return {
        'id': response['id'],
        'class_id': classData['id'],
        'class_name': classData['name'],
        'class_code': classData['code'],
        'teacher_name': teacher != null
            ? '${teacher['first_name']} ${teacher['last_name']}'
            : null,
        'room_name': room?['name'],
        'enrolled_at': response['enrolled_at'],
      };
    } catch (e) {
      print('Get current enrollment error: $e');
      return null;
    }
  }

  // O'quvchini sinfga biriktirish
  Future<bool> enrollStudent({
    required String studentId,
    required String classId,
    required String academicYearId,
  }) async {
    try {
      // Avvalgi enrollment'larni deactivate qilish
      await _supabase
          .from('enrollments')
          .update({'is_active': false})
          .eq('student_id', studentId);

      // Yangi enrollment yaratish
      await _supabase.from('enrollments').insert({
        'student_id': studentId,
        'class_id': classId,
        'academic_year_id': academicYearId,
        'enrolled_at': DateTime.now().toIso8601String(),
        'is_active': true,
      });

      return true;
    } catch (e) {
      print('Enroll student error: $e');
      return false;
    }
  }
}

// lib/data/repositories/schedule_repository.dart

class ScheduleRepository {
  final _supabase = Supabase.instance.client;

  // Sinf dars jadvalini olish
  Future<List<Map<String, dynamic>>> getClassSchedule(String classId) async {
    try {
      final response = await _supabase
          .from('schedule_templates')
          .select('''
            *,
            subjects(name),
            staff!teacher_id(
              users!user_id(first_name, last_name)
            )
          ''')
          .eq('class_id', classId)
          .eq('is_active', true)
          .order('day_of_week')
          .order('start_time');

      // Hafta kunlari bo'yicha guruhlash
      final weekDays = {
        'monday': 'Dushanba',
        'tuesday': 'Seshanba',
        'wednesday': 'Chorshanba',
        'thursday': 'Payshanba',
        'friday': 'Juma',
        'saturday': 'Shanba',
      };

      final groupedSchedule = <String, List<Map<String, String>>>{};

      for (final item in response as List) {
        final day = item['day_of_week'] as String;
        final subject = item['subjects'] as Map<String, dynamic>;
        final staff = item['staff'] as Map<String, dynamic>?;
        final user = staff?['users'] as Map<String, dynamic>?;

        final lesson = {
          'time': '${item['start_time']} - ${item['end_time']}',
          'subject': subject['name'] as String,
          'teacher': user != null
              ? '${user['first_name']} ${user['last_name']}'
              : 'O\'qituvchi yo\'q',
        };

        if (!groupedSchedule.containsKey(day)) {
          groupedSchedule[day] = [];
        }
        groupedSchedule[day]!.add(lesson);
      }

      // List'ga aylantirish
      final result = <Map<String, dynamic>>[];
      for (final entry in weekDays.entries) {
        if (groupedSchedule.containsKey(entry.key)) {
          result.add({
            'day': entry.value,
            'lessons': groupedSchedule[entry.key]!,
          });
        }
      }

      return result;
    } catch (e) {
      print('Get class schedule error: $e');
      return [];
    }
  }

  // Darsni qo'shish/yangilash
  Future<bool> upsertLesson({
    required String classId,
    required String subjectId,
    required String teacherId,
    required String dayOfWeek,
    required String startTime,
    required String endTime,
    String? roomId,
  }) async {
    try {
      await _supabase.from('schedule_templates').upsert({
        'class_id': classId,
        'subject_id': subjectId,
        'teacher_id': teacherId,
        'day_of_week': dayOfWeek,
        'start_time': startTime,
        'end_time': endTime,
        'room_id': roomId,
        'is_active': true,
      });

      return true;
    } catch (e) {
      print('Upsert lesson error: $e');
      return false;
    }
  }
}

class PaymentRepository {
  final _supabase = Supabase.instance.client;

  Future<List<PaymentModel>> getStudentPaymentHistory(String studentId) async {
    try {
      final response = await _supabase
          .from('payments')
          .select()
          .eq('student_id', studentId)
          .order('payment_date', ascending: false);

      return (response as List)
          .map((json) => PaymentModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Get student payment history error: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getStudentDebts(String studentId) async {
    try {
      final response = await _supabase
          .from('student_debts')
          .select()
          .eq('student_id', studentId)
          .eq('is_settled', false);

      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      print('Get student debts error: $e');
      return [];
    }
  }

  Future<bool> createPayment({
    required String studentId,
    required String branchId,
    required String classId,
    required double amount,
    required int periodMonth,
    required int periodYear,
    double discountPercent = 0,
    double discountAmount = 0,
    String? notes,
    String? receivedBy,
  }) async {
    try {
      final finalAmount = amount - discountAmount;

      await _supabase.from('payments').insert({
        'student_id': studentId,
        'branch_id': branchId,
        'class_id': classId,
        'payment_type': 'monthly',
        'payment_status': 'paid',
        'amount': amount,
        'discount_percent': discountPercent,
        'discount_amount': discountAmount,
        'final_amount': finalAmount,
        'period_month': periodMonth,
        'period_year': periodYear,
        'payment_date': DateTime.now().toIso8601String().split('T')[0],
        'payment_time': TimeOfDay.now().format(Get.context!),
        'notes': notes,
        'received_by': receivedBy,
      });

      // Agar qarzdorlik bo'lsa, uni yopish
      await _supabase
          .from('student_debts')
          .update({
            'paid_amount': finalAmount,
            'remaining_amount': 0,
            'is_settled': true,
          })
          .eq('student_id', studentId)
          .eq('period_month', periodMonth)
          .eq('period_year', periodYear);

      return true;
    } catch (e) {
      print('Create payment error: $e');
      return false;
    }
  }
}
