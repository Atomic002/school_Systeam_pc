// lib/presentation/controllers/staff_detail_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';

class StaffDashboardControlleradmin extends GetxController {
  final _supabase = Supabase.instance.client;

  final staff = Rxn<Map<String, dynamic>>();
  final isLoading = false.obs;
  final selectedTab = 0.obs;

  // Davomat
  final isLoadingAttendance = false.obs;
  final attendanceList = <Map<String, dynamic>>[].obs;
  final attendanceStartDate = DateTime.now().subtract(Duration(days: 30)).obs;
  final attendanceEndDate = DateTime.now().obs;
  final totalAttendanceDays = 0.obs;
  final presentDays = 0.obs;
  final absentDays = 0.obs;
  final lateDays = 0.obs;
  final attendancePercentage = 0.0.obs;

  // Maosh
  final isLoadingSalary = false.obs;
  final salaryHistory = <Map<String, dynamic>>[].obs;
  final baseSalary = 0.0.obs;
  final totalPaid = 0.0.obs;
  final totalAdvances = 0.0.obs;
  final totalLoans = 0.0.obs;

  // Darslar
  final isLoadingSchedule = false.obs;
  final teacherSchedule = <Map<String, dynamic>>[].obs;
  final weeklyLessons = 0.obs;
  final assignedClasses = <Map<String, dynamic>>[].obs;
  final teachingSubjects = <Map<String, dynamic>>[].obs;

  // O'quvchilar
  final isLoadingStudents = false.obs;
  final teacherStudents = <Map<String, dynamic>>[].obs;
  final totalStudents = 0.obs;
  final paidStudents = 0.obs;
  final debtorStudents = 0.obs;
  final totalRevenue = 0.0.obs;
  final collectionPercentage = 0.0.obs;

  // Hujjatlar
  final isLoadingDocuments = false.obs;
  final documents = <Map<String, dynamic>>[].obs;

  // Baholash
  final isLoadingEvaluations = false.obs;
  final evaluations = <Map<String, dynamic>>[].obs;
  final achievements = <Map<String, dynamic>>[].obs;
  final averageRating = 0.0.obs;
  final totalEvaluations = 0.obs;
  
  

  String? staffId;

  @override
  void onInit() {
    super.onInit();
    staffId = Get.arguments?['staffId'];
    if (staffId != null) {
      loadStaffData();
    }
  }

  Future<void> loadStaffData() async {
    try {
      isLoading.value = true;
      final response = await _supabase
          .from('staff')
          .select('''
            *,
            branches:branch_id(name),
            users:user_id(role, username, status)
          ''')
          .eq('id', staffId!)
          .single();

      staff.value = response;
      baseSalary.value = (response['base_salary'] ?? 0).toDouble();

      await Future.wait([
        loadAttendance(),
        loadSalaryHistory(),
        if (response['is_teacher'] == true) ...[
          loadTeacherSchedule(),
          loadTeacherStudents(),
        ],
        loadDocuments(),
        loadEvaluations(),
      ]);
    } catch (e) {
      Get.snackbar(
        'Xatolik',
        'Ma\'lumotlar yuklanmadi: $e',
        backgroundColor: Colors.red.shade100,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadAttendance() async {
    try {
      isLoadingAttendance.value = true;
      final response = await _supabase
          .from('attendance_staff')
          .select('*')
          .eq('staff_id', staffId!)
          .gte(
            'attendance_date',
            attendanceStartDate.value.toIso8601String().split('T')[0],
          )
          .lte(
            'attendance_date',
            attendanceEndDate.value.toIso8601String().split('T')[0],
          )
          .order('attendance_date', ascending: false);

      attendanceList.value = List<Map<String, dynamic>>.from(response);
      _calculateAttendanceStats();
    } catch (e) {
      print('Load attendance error: $e');
    } finally {
      isLoadingAttendance.value = false;
    }
  }

  void _calculateAttendanceStats() {
    totalAttendanceDays.value = attendanceList.length;
    presentDays.value = attendanceList
        .where((a) => a['status'] == 'present')
        .length;
    absentDays.value = attendanceList
        .where((a) => a['status'] == 'absent')
        .length;
    lateDays.value = attendanceList.where((a) => a['status'] == 'late').length;
    if (totalAttendanceDays.value > 0) {
      attendancePercentage.value =
          (presentDays.value / totalAttendanceDays.value) * 100;
    }
  }

  Future<void> loadSalaryHistory() async {
    try {
      isLoadingSalary.value = true;
      final response = await _supabase
          .from('salary_operations')
          .select('*')
          .eq('staff_id', staffId!)
          .order('year', ascending: false)
          .order('month', ascending: false);

      salaryHistory.value = List<Map<String, dynamic>>.from(response);
      _calculateSalaryStats();

      final advancesResponse = await _supabase
          .from('staff_advances')
          .select('amount')
          .eq('staff_id', staffId!)
          .eq('is_deducted', false);

      totalAdvances.value = advancesResponse.fold(
        0.0,
        (sum, item) => sum + (item['amount'] ?? 0),
      );

      final loansResponse = await _supabase
          .from('staff_loans')
          .select('remaining_amount')
          .eq('staff_id', staffId!)
          .eq('is_settled', false);

      totalLoans.value = loansResponse.fold(
        0.0,
        (sum, item) => sum + (item['remaining_amount'] ?? 0),
      );
    } catch (e) {
      print('Load salary error: $e');
    } finally {
      isLoadingSalary.value = false;
    }
  }

  void _calculateSalaryStats() {
    totalPaid.value = salaryHistory.fold(
      0.0,
      (sum, item) => sum + (item['amount'] ?? 0),
    );
  }

  Future<void> loadTeacherSchedule() async {
    try {
      isLoadingSchedule.value = true;
      final response = await _supabase
          .from('schedule_templates')
          .select('''
            *,
            subjects(name),
            classes(name),
            rooms(name)
          ''')
          .eq('teacher_id', staffId!)
          .eq('is_active', true)
          .order('day_of_week')
          .order('start_time');

      teacherSchedule.value = List<Map<String, dynamic>>.from(response);
      weeklyLessons.value = teacherSchedule.length;

      final classSet = <String, Map<String, dynamic>>{};
      final subjectSet = <String, Map<String, dynamic>>{};

      for (var lesson in teacherSchedule) {
        if (lesson['classes'] != null) {
          classSet[lesson['class_id']] = lesson['classes'];
        }
        if (lesson['subjects'] != null) {
          subjectSet[lesson['subject_id']] = lesson['subjects'];
        }
      }

      assignedClasses.value = classSet.values.toList();
      teachingSubjects.value = subjectSet.values.toList();
    } catch (e) {
      print('Load schedule error: $e');
    } finally {
      isLoadingSchedule.value = false;
    }
  }

  Future<void> loadTeacherStudents() async {
    try {
      isLoadingStudents.value = true;
      final classIds = assignedClasses.map((c) => c['id']).toList();

      if (classIds.isEmpty) {
        teacherStudents.value = [];
        return;
      }

      final enrollments = await _supabase
          .from('class_enrollments')
          .select('student_id')
          .inFilter('class_id', classIds)
          .eq('is_active', true);

      final studentIds = enrollments.map((e) => e['student_id']).toList();

      if (studentIds.isEmpty) {
        teacherStudents.value = [];
        return;
      }

      final students = await _supabase
          .from('students')
          .select('*')
          .inFilter('id', studentIds)
          .eq('status', 'active');

      teacherStudents.value = List<Map<String, dynamic>>.from(students);
      totalStudents.value = students.length;
      await _calculateStudentsPaymentStats();
    } catch (e) {
      print('Load students error: $e');
    } finally {
      isLoadingStudents.value = false;
    }
  }

  Future<void> _calculateStudentsPaymentStats() async {
    try {
      double totalExpected = 0;
      double totalPaidAmount = 0;
      int paid = 0;
      int debtors = 0;

      for (var student in teacherStudents) {
        final monthlyFee = (student['monthly_fee'] ?? 0).toDouble();
        totalExpected += monthlyFee;

        final payments = await _supabase
            .from('payments')
            .select('amount')
            .eq('student_id', student['id'])
            .eq('status', 'completed');

        final totalPaidByStudent = payments.fold(
          0.0,
          (sum, p) => sum + (p['amount'] ?? 0),
        );
        totalPaidAmount += totalPaidByStudent;

        if (totalPaidByStudent >= monthlyFee) {
          paid++;
        } else {
          debtors++;
        }
      }

      paidStudents.value = paid;
      debtorStudents.value = debtors;
      totalRevenue.value = totalPaidAmount;
      if (totalExpected > 0) {
        collectionPercentage.value = (totalPaidAmount / totalExpected) * 100;
      }
    } catch (e) {
      print('Calculate payment stats error: $e');
    }
  }

  Future<void> loadDocuments() async {
    try {
      isLoadingDocuments.value = true;
      final response = await _supabase
          .from('staff_documents')
          .select('*')
          .eq('staff_id', staffId!)
          .order('created_at', ascending: false);
      documents.value = List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Load documents error: $e');
    } finally {
      isLoadingDocuments.value = false;
    }
  }

  Future<void> loadEvaluations() async {
    try {
      isLoadingEvaluations.value = true;
      final response = await _supabase
          .from('staff_evaluations')
          .select('*')
          .eq('staff_id', staffId!)
          .order('evaluation_date', ascending: false);

      evaluations.value = List<Map<String, dynamic>>.from(response);
      totalEvaluations.value = evaluations.length;

      if (evaluations.isNotEmpty) {
        final sum = evaluations.fold(
          0.0,
          (sum, e) => sum + (e['overall_rating'] ?? 0),
        );
        averageRating.value = sum / evaluations.length;
      }

      final achievementsResponse = await _supabase
          .from('staff_achievements')
          .select('*')
          .eq('staff_id', staffId!)
          .order('date_achieved', ascending: false);

      achievements.value = List<Map<String, dynamic>>.from(
        achievementsResponse,
      );
    } catch (e) {
      print('Load evaluations error: $e');
    } finally {
      isLoadingEvaluations.value = false;
    }
  }

  // TELEFON/SMS - URL LAUNCHER
  Future<void> callStaff() async {
    final phone = staff.value?['phone'];
    if (phone != null) {
      final uri = Uri.parse('tel:$phone');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    }
  }

  Future<void> sendMessage() async {
    final phone = staff.value?['phone'];
    if (phone != null) {
      final uri = Uri.parse('sms:$phone');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    }
  }

  // RASM YUKLASH
  Future<void> uploadPhoto() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.single.bytes != null) {
        final bytes = result.files.single.bytes!;
        final fileName =
            '${staffId}_${DateTime.now().millisecondsSinceEpoch}.${result.files.single.extension}';

        await _supabase.storage
            .from('staff-photos')
            .uploadBinary(fileName, bytes);
        final photoUrl = _supabase.storage
            .from('staff-photos')
            .getPublicUrl(fileName);
        await _supabase
            .from('staff')
            .update({'photo_url': photoUrl})
            .eq('id', staffId!);
        await loadStaffData();

        Get.snackbar(
          'Muvaffaqiyatli',
          'Rasm yuklandi',
          backgroundColor: Colors.green.shade100,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Xatolik',
        'Rasm yuklanmadi: $e',
        backgroundColor: Colors.red.shade100,
      );
    }
  }

  // HUJJAT YUKLASH
  Future<void> uploadDocument() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'png'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.bytes != null) {
        final bytes = result.files.single.bytes!;
        final fileName =
            '${staffId}_${DateTime.now().millisecondsSinceEpoch}_${result.files.single.name}';

        await _supabase.storage
            .from('staff-documents')
            .uploadBinary(fileName, bytes);
        final fileUrl = _supabase.storage
            .from('staff-documents')
            .getPublicUrl(fileName);

        await _supabase.from('staff_documents').insert({
          'staff_id': staffId,
          'document_type': 'other',
          'file_url': fileUrl,
        });

        await loadDocuments();
        Get.snackbar(
          'Muvaffaqiyatli',
          'Hujjat yuklandi',
          backgroundColor: Colors.green.shade100,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Xatolik',
        'Hujjat yuklanmadi: $e',
        backgroundColor: Colors.red.shade100,
      );
    }
  }

  // HUJJATNI YUKLAB OLISH
  Future<void> downloadDocument(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  // EXPORT FUNKSIYALAR
  Future<void> exportAttendance() async {
    try {
      String csv = 'Sana,Status,Kirish,Chiqish,Izoh\n';
      for (var att in attendanceList) {
        csv += '${att['attendance_date']},';
        csv += '${att['status']},';
        csv += '${att['check_in_time'] ?? '-'},';
        csv += '${att['check_out_time'] ?? '-'},';
        csv += '"${att['notes'] ?? ''}"\n';
      }

      final bytes = utf8.encode(csv);
      await _saveFile(bytes, 'davomat_${staffId}.csv');
      Get.snackbar('Muvaffaqiyatli', 'Davomat yuklab olindi');
    } catch (e) {
      Get.snackbar('Xatolik', 'Yuklab olinmadi: $e');
    }
  }

  Future<void> exportSalaryHistory() async {
    try {
      String csv = 'Oy,Yil,Summa\n';
      for (var salary in salaryHistory) {
        csv += '${salary['month']},${salary['year']},${salary['amount']}\n';
      }

      final bytes = utf8.encode(csv);
      await _saveFile(bytes, 'maosh_tarixi_${staffId}.csv');
      Get.snackbar('Muvaffaqiyatli', 'Maosh tarixi yuklab olindi');
    } catch (e) {
      Get.snackbar('Xatolik', 'Yuklab olinmadi: $e');
    }
  }

  Future<void> exportStudentsList() async {
    try {
      String csv = 'Ism,Telefon,Oylik,Tulangan,Status\n';
      for (var student in teacherStudents) {
        csv += '"${student['first_name']} ${student['last_name']}",';
        csv += '${student['phone']},';
        csv += '${student['monthly_fee']},';
        csv += '${student['total_paid'] ?? 0},';
        csv +=
            '${(student['total_paid'] ?? 0) >= (student['monthly_fee'] ?? 0) ? 'Tulangan' : 'Qarzdor'}\n';
      }

      final bytes = utf8.encode(csv);
      await _saveFile(bytes, 'oquvchilar_${staffId}.csv');
      Get.snackbar('Muvaffaqiyatli', 'O\'quvchilar ro\'yxati yuklab olindi');
    } catch (e) {
      Get.snackbar('Xatolik', 'Yuklab olinmadi: $e');
    }
  }

  Future<void> _saveFile(List<int> bytes, String fileName) async {
    if (Platform.isAndroid || Platform.isIOS) {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(bytes);
      Get.snackbar(
        'Saqlandi',
        'Fayl: ${file.path}',
        duration: Duration(seconds: 5),
      );
    } else {
      String? outputPath = await FilePicker.platform.saveFile(
        dialogTitle: 'Faylni saqlash',
        fileName: fileName,
      );
      if (outputPath != null) {
        final file = File(outputPath);
        await file.writeAsBytes(bytes);
        Get.snackbar(
          'Saqlandi',
          'Fayl: $outputPath',
          duration: Duration(seconds: 5),
        );
      }
    }
  }

  void editStaff() =>
      Get.toNamed('/edit-staff', arguments: {'staffId': staffId});
  void downloadProfile() =>
      Get.snackbar('Yuklanmoqda', 'Profil tayyorlanmoqda...');
  void printProfile() {} // Desktop uchun print dialog ochish

  Future<void> deleteStaff() async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: Text('O\'chirish'),
        content: Text('Xodimni o\'chirishni tasdiqlaysizmi?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('Bekor qilish'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('O\'chirish'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _supabase
            .from('staff')
            .update({'status': 'inactive'})
            .eq('id', staffId!);
        Get.back();
        Get.snackbar(
          'Muvaffaqiyatli',
          'Xodim o\'chirildi',
          backgroundColor: Colors.green.shade100,
        );
      } catch (e) {
        Get.snackbar(
          'Xatolik',
          'Xodim o\'chirilmadi: $e',
          backgroundColor: Colors.red.shade100,
        );
      }
    }
  }

  Future<void> deleteDocument(String docId) async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: Text('O\'chirish'),
        content: Text('Hujjatni o\'chirishni tasdiqlaysizmi?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('Bekor qilish'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('O\'chirish'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _supabase.from('staff_documents').delete().eq('id', docId);
        await loadDocuments();
        Get.snackbar(
          'Muvaffaqiyatli',
          'Hujjat o\'chirildi',
          backgroundColor: Colors.green.shade100,
        );
      } catch (e) {
        Get.snackbar(
          'Xatolik',
          'Hujjat o\'chirilmadi: $e',
          backgroundColor: Colors.red.shade100,
        );
      }
    }
  }

  String getWorkExperience() {
    final hireDate = staff.value?['hire_date'];
    if (hireDate == null) return 'N/A';
    final hire = DateTime.parse(hireDate);
    final now = DateTime.now();
    final diff = now.difference(hire);
    final years = diff.inDays ~/ 365;
    final months = (diff.inDays % 365) ~/ 30;
    if (years > 0) {
      return '$years yil ${months > 0 ? "$months oy" : ""}';
    }
    return '$months oy';
  }

  int getAge() {
    final birthDate = staff.value?['birth_date'];
    if (birthDate == null) return 0;
    final birth = DateTime.parse(birthDate);
    final now = DateTime.now();
    int age = now.year - birth.year;
    if (now.month < birth.month ||
        (now.month == birth.month && now.day < birth.day)) {
      age--;
    }
    return age;
  }

  String getRating() {
    if (averageRating.value > 0) {
      return '${averageRating.value.toStringAsFixed(1)}/5.0';
    }
    return 'Baholanmagan';
  }

  Future<void> selectAttendanceStartDate() async {
    final date = await Get.dialog<DateTime>(
      DatePickerDialog(
        initialDate: attendanceStartDate.value,
        firstDate: DateTime(2020),
        lastDate: DateTime.now(),
      ),
    );
    if (date != null) {
      attendanceStartDate.value = date;
      await loadAttendance();
    }
  }

  Future<void> selectAttendanceEndDate() async {
    final date = await Get.dialog<DateTime>(
      DatePickerDialog(
        initialDate: attendanceEndDate.value,
        firstDate: attendanceStartDate.value,
        lastDate: DateTime.now(),
      ),
    );
    if (date != null) {
      attendanceEndDate.value = date;
      await loadAttendance();
    }
  }
}
