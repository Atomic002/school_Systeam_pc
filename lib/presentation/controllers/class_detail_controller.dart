// lib/presentation/controllers/class_detail_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/services/supabase_service.dart';

class ClassDetailController extends GetxController {
  final SupabaseService _supabaseService = Get.find<SupabaseService>();

  var isLoading = false.obs;
  var classData = Rxn<Map<String, dynamic>>();
  var students = <Map<String, dynamic>>[].obs;
  var teachers = <Map<String, dynamic>>[].obs;
  var paymentHistory = <Map<String, dynamic>>[].obs;

  var totalStudents = 0.obs;
  var totalPaid = 0.0.obs;
  var totalDebt = 0.0.obs;
  var averageAttendance = 0.0.obs;
  var debtorCount = 0.obs;
  var paymentPercentage = 0.0.obs;

  var searchQuery = ''.obs;
  var selectedFilter = 'all'.obs;

  String? classId;

  // Filtered students
  List<Map<String, dynamic>> get filteredStudents {
    var result = students.toList();

    // Search filter
    if (searchQuery.value.isNotEmpty) {
      result = result.where((student) {
        final name = '${student['first_name']} ${student['last_name']}'
            .toLowerCase();
        return name.contains(searchQuery.value.toLowerCase());
      }).toList();
    }

    // Status filter
    if (selectedFilter.value == 'paid') {
      result = result
          .where((s) => s['debt'] == null || s['debt'] == 0)
          .toList();
    } else if (selectedFilter.value == 'debt') {
      result = result.where((s) => s['debt'] != null && s['debt'] > 0).toList();
    }

    return result;
  }

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    classId = args?['id'];
    if (classId != null) {
      loadClassDetails();
    }
  }

  Future<void> loadClassDetails() async {
    isLoading.value = true;
    try {
      await Future.wait([
        loadClass(),
        loadStudents(),
        loadTeachers(),
        loadPaymentHistory(),
        loadStatistics(),
      ]);
    } catch (e) {
      Get.snackbar(
        'Xato',
        'Ma\'lumotlarni yuklashda xatolik: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadClass() async {
    try {
      final response = await _supabaseService.client
          .from('classes')
          .select('''
            *,
            branch:branches(name),
            room:rooms!classes_default_room_id_fkey(name),
            teacher:users!classes_main_teacher_id_fkey(first_name, last_name),
            class_level:class_levels(name)
          ''')
          .eq('id', classId!)
          .single();

      String? teacherName;
      if (response['teacher'] != null) {
        teacherName =
            '${response['teacher']['first_name']} ${response['teacher']['last_name']}';
      }

      classData.value = {
        'id': response['id'],
        'name': response['name'],
        'code': response['code'],
        'branch_name': response['branch']?['name'],
        'room_name': response['room']?['name'],
        'room_id': response['default_room_id'],
        'teacher_name': teacherName,
        'teacher_id': response['main_teacher_id'],
        'class_level': response['class_level']?['name'],
        'max_students': response['max_students'],
        'monthly_fee': response['monthly_fee'],
        'specialization': response['specialization'],
        'student_count': 0, // Will be updated
      };
    } catch (e) {
      print('Error loading class: $e');
    }
  }

  Future<void> loadStudents() async {
    try {
      final response = await _supabaseService.client
          .from('students')
          .select('''
            id,
            first_name,
            last_name,
            phone,
            enrollments!inner(class_id),
            student_debts(remaining_amount)
          ''')
          .eq('enrollments.class_id', classId!)
          .eq('status', 'active');

      students.value = List<Map<String, dynamic>>.from(response).map((student) {
        final debts = student['student_debts'] as List?;
        double totalDebt = 0;
        if (debts != null && debts.isNotEmpty) {
          for (var debt in debts) {
            totalDebt += (debt['remaining_amount'] as num?)?.toDouble() ?? 0;
          }
        }

        return {
          'id': student['id'],
          'first_name': student['first_name'],
          'last_name': student['last_name'],
          'phone': student['phone'],
          'debt': totalDebt,
        };
      }).toList();

      totalStudents.value = students.length;

      // Update class data
      if (classData.value != null) {
        classData.value!['student_count'] = students.length;
        classData.refresh();
      }
    } catch (e) {
      print('Error loading students: $e');
    }
  }

  Future<void> loadTeachers() async {
    try {
      final response = await _supabaseService.client
          .from('teacher_classes')
          .select('''
            staff_id,
            subject:subjects(name),
            staff:staff(
              id,
              first_name,
              last_name,
              position
            )
          ''')
          .eq('class_id', classId!)
          .eq('is_active', true);

      teachers.value = List<Map<String, dynamic>>.from(response).map((tc) {
        return {
          'id': tc['staff']['id'],
          'first_name': tc['staff']['first_name'],
          'last_name': tc['staff']['last_name'],
          'position': tc['staff']['position'],
          'subject_name': tc['subject']?['name'],
        };
      }).toList();
    } catch (e) {
      print('Error loading teachers: $e');
    }
  }

  Future<void> loadPaymentHistory() async {
    try {
      final response = await _supabaseService.client
          .from('payments')
          .select('''
            id,
            final_amount,
            payment_date,
            student:students(first_name, last_name)
          ''')
          .eq('class_id', classId!)
          .eq('payment_status', 'paid')
          .order('payment_date', ascending: false)
          .limit(20);

      paymentHistory.value = List<Map<String, dynamic>>.from(response).map((
        payment,
      ) {
        return {
          'id': payment['id'],
          'amount': payment['final_amount'],
          'payment_date': DateTime.parse(payment['payment_date']),
          'student_name':
              '${payment['student']['first_name']} ${payment['student']['last_name']}',
        };
      }).toList();
    } catch (e) {
      print('Error loading payment history: $e');
    }
  }

  Future<void> loadStatistics() async {
    try {
      // Total paid this month
      final currentMonth = DateTime.now().month;
      final currentYear = DateTime.now().year;

      final paymentsResponse = await _supabaseService.client
          .from('payments')
          .select('final_amount')
          .eq('class_id', classId!)
          .eq('payment_status', 'paid')
          .eq('period_month', currentMonth)
          .eq('period_year', currentYear);

      double paid = 0;
      for (var payment in paymentsResponse) {
        paid += (payment['final_amount'] as num?)?.toDouble() ?? 0;
      }
      totalPaid.value = paid;

      // Total debt
      final debtsResponse = await _supabaseService.client
          .from('student_debts')
          .select('remaining_amount')
          .eq('class_id', classId!)
          .eq('is_settled', false);

      double debt = 0;
      for (var d in debtsResponse) {
        debt += (d['remaining_amount'] as num?)?.toDouble() ?? 0;
      }
      totalDebt.value = debt;

      // Debtor count
      debtorCount.value = students
          .where((s) => s['debt'] != null && s['debt'] > 0)
          .length;

      // Payment percentage
      final monthlyFee = classData.value?['monthly_fee'] ?? 0;
      final expectedTotal = monthlyFee * totalStudents.value;
      if (expectedTotal > 0) {
        paymentPercentage.value = (paid / expectedTotal) * 100;
      }

      // Average attendance
      final attendanceResponse = await _supabaseService.client
          .from('attendance_students')
          .select('status')
          .eq('class_id', classId!)
          .gte(
            'attendance_date',
            DateTime(currentYear, currentMonth, 1).toIso8601String(),
          )
          .lte(
            'attendance_date',
            DateTime(currentYear, currentMonth + 1, 0).toIso8601String(),
          );

      if (attendanceResponse.isNotEmpty) {
        final presentCount = attendanceResponse
            .where((a) => a['status'] == 'present')
            .length;
        averageAttendance.value =
            (presentCount / attendanceResponse.length) * 100;
      }
    } catch (e) {
      print('Error loading statistics: $e');
    }
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
  }

  void filterStudents(String filter) {
    selectedFilter.value = filter;
  }

  void editClass() {
    Get.toNamed('/edit-class', arguments: {'id': classId});
  }

  void addStudent() {
    Get.toNamed('/add-student', arguments: {'class_id': classId});
  }

  void addTeacher() {
    // O'qituvchi qo'shish dialog
    Get.dialog(
      AlertDialog(
        title: const Text('O\'qituvchi biriktirish'),
        content: const Text('Bu funksiya hozircha ishlab chiqilmoqda...'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Yopish')),
        ],
      ),
    );
  }

  Future<void> removeTeacher(String teacherId) async {
    try {
      await _supabaseService.client
          .from('teacher_classes')
          .delete()
          .eq('staff_id', teacherId)
          .eq('class_id', classId!);

      Get.snackbar(
        'Muvaffaqiyatli',
        'O\'qituvchi sinfdan ajratildi',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      loadTeachers();
    } catch (e) {
      Get.snackbar(
        'Xato',
        'O\'qituvchini ajratishda xatolik: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
