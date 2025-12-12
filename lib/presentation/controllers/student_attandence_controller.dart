// lib/presentation/controllers/student_attendance_controller.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/repositories/visitior_repitory.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/repositories/attendance_repository.dart';
import '../../data/repositories/student_repositry.dart';
import 'auth_controller.dart';

class StudentAttendanceController extends GetxController {
  final AttendanceRepository _attendanceRepo = AttendanceRepository();
  final ClassRepository _classRepo = ClassRepository();
  final StudentRepository _studentRepo = StudentRepository();
  final AuthController _authController = Get.find<AuthController>();

  // Observable variables
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final Rx<String?> selectedClassId = Rx<String?>(null);

  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;

  // Sinflar ro'yxati
  final RxList<Map<String, String>> classes = <Map<String, String>>[].obs;

  // O'quvchilar ro'yxati
  final RxList<Map<String, dynamic>> students = <Map<String, dynamic>>[].obs;

  // Davomat statuslari: studentId -> status
  final RxMap<String, String> attendanceStatus = <String, String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _loadClasses();
  }

  // ==================== SINFLARNI YUKLASH ====================
  Future<void> _loadClasses() async {
    try {
      final branchId = _authController.currentUser.value?.branchId;
      if (branchId == null) return;

      final result = await _classRepo.getClassesWithDetails(branchId);
      classes.value = result;
    } catch (e) {
      print('Load classes error: $e');
    }
  }

  // ==================== SANA O'ZGARTIRISH ====================
  void changeDate(DateTime date) {
    selectedDate.value = date;
    if (selectedClassId.value != null) {
      loadAttendanceForClass();
    }
  }

  // ==================== SINF TANLASH ====================
  void changeClass(String? classId) {
    selectedClassId.value = classId;
    if (classId != null) {
      loadAttendanceForClass();
    } else {
      students.clear();
      attendanceStatus.clear();
    }
  }

  // ==================== DAVOMATNI YUKLASH ====================
  Future<void> loadAttendanceForClass() async {
    final classId = selectedClassId.value;
    if (classId == null) return;

    try {
      isLoading.value = true;

      final branchId = _authController.currentUser.value?.branchId;
      if (branchId == null) return;

      // 1. Sinf o'quvchilarini olish
      final studentsList = await _getClassStudents(classId);
      students.value = studentsList;

      // 2. Tanlangan sana uchun davomat ma'lumotlarini olish
      final existingAttendance = await _attendanceRepo.getClassAttendance(
        classId,
        selectedDate.value,
      );

      // 3. Status'larni to'ldirish
      attendanceStatus.clear();
      for (final student in studentsList) {
        final studentId = student['id'] as String;

        // Mavjud davomatni topish
        final existing = existingAttendance.firstWhereOrNull(
          (a) => a.studentId == studentId,
        );

        // Agar mavjud bo'lsa, uni olish, aks holda 'present'
        attendanceStatus[studentId] = existing?.status ?? 'present';
      }
    } catch (e) {
      print('Load attendance error: $e');
      Get.snackbar(
        'Xatolik',
        'Davomatni yuklashda xatolik',
        backgroundColor: const Color(0xFFF44336).withOpacity(0.1),
        colorText: const Color(0xFFF44336),
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Sinf o'quvchilarini olish
  Future<List<Map<String, dynamic>>> _getClassStudents(String classId) async {
    try {
      final branchId = _authController.currentUser.value?.branchId;
      if (branchId == null) return [];

      // enrollments orqali sinfning o'quvchilarini olish
      final response = await _studentRepo.getClassStudents(classId);
      return response;
    } catch (e) {
      print('Get class students error: $e');
      return [];
    }
  }

  // ==================== STATUS O'ZGARTIRISH ====================
  void setStatus(String studentId, String status) {
    attendanceStatus[studentId] = status;
  }

  // ==================== SAQLASH ====================
  Future<void> saveAttendance() async {
    final classId = selectedClassId.value;
    if (classId == null) return;

    try {
      isSaving.value = true;

      final branchId = _authController.currentUser.value?.branchId;
      final userId = _authController.currentUser.value?.id;
      if (branchId == null || userId == null) return;

      // Har bir o'quvchi uchun davomatni saqlash
      for (final student in students) {
        final studentId = student['id'] as String;
        final status = attendanceStatus[studentId] ?? 'present';

        await _attendanceRepo.markAttendance(
          studentId: studentId,
          classId: classId,
          branchId: branchId,
          date: selectedDate.value,
          status: status,
          markedBy: userId,
        );
      }

      Get.snackbar(
        'Muvaffaqiyatli',
        'Davomat saqlandi',
        backgroundColor: const Color(0xFF4CAF50).withOpacity(0.1),
        colorText: const Color(0xFF4CAF50),
        icon: const Icon(Icons.check_circle, color: Color(0xFF4CAF50)),
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      print('Save attendance error: $e');
      Get.snackbar(
        'Xatolik',
        'Davomatni saqlashda xatolik',
        backgroundColor: const Color(0xFFF44336).withOpacity(0.1),
        colorText: const Color(0xFFF44336),
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isSaving.value = false;
    }
  }

  // ==================== BARCHASINI "KELDI" QILISH ====================
  void markAllPresent() {
    for (final student in students) {
      final studentId = student['id'] as String;
      attendanceStatus[studentId] = 'present';
    }
  }

  // ==================== BARCHASINI "KELMADI" QILISH ====================
  void markAllAbsent() {
    for (final student in students) {
      final studentId = student['id'] as String;
      attendanceStatus[studentId] = 'absent';
    }
  }
}

// StudentRepository'ga qo'shimcha metod
// lib/data/repositories/student_repository.dart ga qo'shing:

extension StudentRepositoryAttendance on StudentRepository {
  // Sinf o'quvchilarini olish
  Future<List<Map<String, dynamic>>> getClassStudents(String classId) async {
    try {
      final response = await Supabase.instance.client
          .from('enrollments')
          .select('''
            student_id,
            students!inner(
              id,
              first_name,
              last_name,
              middle_name,
              phone,
              status
            )
          ''')
          .eq('class_id', classId)
          .eq('is_active', true)
          .eq('students.status', 'active');

      return (response as List).map((item) {
        final student = item['students'] as Map<String, dynamic>;
        return {
          'id': student['id'],
          'name': '${student['last_name']} ${student['first_name']}',
          'phone': student['phone'] ?? '',
          'status': student['status'],
        };
      }).toList();
    } catch (e) {
      print('Get class students error: $e');
      return [];
    }
  }
}
