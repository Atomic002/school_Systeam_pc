// lib/presentation/controllers/staff_detail_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';

class StaffDashboardController extends GetxController {
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
      
      // ✅ TO'G'RILANGAN SO'ROV
      final response = await _supabase
          .from('staff')
          .select('''
            *,
            branches:branch_id(name),
            users:user_id(
              username,
              status,
              role
            )
          ''')
          .eq('id', staffId!)
          .single();

      staff.value = response;
      baseSalary.value = (response['base_salary'] ?? 0).toDouble();

      await Future.wait([
        loadAttendance(),
        loadSalaryHistory(),
        // is_teacher null bo'lishi mumkin, shuning uchun == true tekshiramiz
        if (response['is_teacher'] == true) ...[
          loadTeacherSchedule(),
          loadTeacherStudents(),
        ],
        loadDocuments(),
        loadEvaluations(),
      ]);
    } catch (e) {
      print('Load data error: $e'); // Konsolga to'liq xatoni chiqarish
      Get.snackbar(
        'Xatolik',
        'Ma\'lumotlar yuklanmadi: ${e.toString()}', // Xatoni ko'rsatish
        backgroundColor: Colors.red.shade100,
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 5),
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
      
      // SalaryController dagi kabi 'salary_operations' jadvalidan o'qiyapmiz
      final response = await _supabase
          .from('salary_operations')
          .select('*')
          .eq('staff_id', staffId!)
          .eq('is_paid', true) // <--- MUHIM: Faqat to'langanlarini chiqaramiz
          .order('paid_at', ascending: false); // Oxirgi to'lov birinchi chiqadi

      salaryHistory.value = List<Map<String, dynamic>>.from(response);
      
      // Statistika hisoblash
      _calculateSalaryStats();

      // --- AVANSLAR (O'zgarishsiz qoladi) ---
      final advancesResponse = await _supabase
          .from('staff_advances')
          .select('amount')
          .eq('staff_id', staffId!)
          .eq('is_deducted', false); // Hali ish haqidan ushlanmagan avanslar

      totalAdvances.value = advancesResponse.fold(
        0.0,
        (sum, item) => sum + ((item['amount'] as num?)?.toDouble() ?? 0.0),
      );

      // --- QARZLAR (O'zgarishsiz qoladi) ---
      final loansResponse = await _supabase
          .from('staff_loans')
          .select('remaining_amount')
          .eq('staff_id', staffId!)
          .eq('is_settled', false); // Hali yopilmagan qarzlar

      totalLoans.value = loansResponse.fold(
        0.0,
        (sum, item) => sum + ((item['remaining_amount'] as num?)?.toDouble() ?? 0.0),
      );
      
    } catch (e) {
      print('Load salary history error: $e');
    } finally {
      isLoadingSalary.value = false;
    }
  }

    void _calculateSalaryStats() {
    try {
      double total = 0.0;
      
      for (var item in salaryHistory) {
        // MUHIM: 'amount' emas, 'net_amount' ni olamiz
        final amount = (item['net_amount'] as num?)?.toDouble() ?? 0.0;
        total += amount;
      }

      totalPaid.value = total;
    } catch (e) {
      print('Maosh statistikasini hisoblashda xato: $e');
      totalPaid.value = 0.0;
    }
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
      teacherStudents.clear(); // Eski ma'lumotlarni tozalash

      // 1-QADAM: O'qituvchiga tegishli SINF ID larini yig'amiz
      Set<String> classIds = {};

      // A) Sinf rahbari bo'lgan sinflar
      final mainClasses = await _supabase
          .from('classes')
          .select('id')
          .eq('main_teacher_id', staffId!);
      
      for (var item in mainClasses) {
        classIds.add(item['id']);
      }

      // B) Fan o'qituvchisi sifatida dars o'tadigan sinflar
      final subjectClasses = await _supabase
          .from('teacher_classes')
          .select('class_id')
          .eq('staff_id', staffId!)
          .eq('is_active', true);

      for (var item in subjectClasses) {
        if (item['class_id'] != null) {
          classIds.add(item['class_id']);
        }
      }

      // 2-QADAM: O'quvchilarni yuklash
      List<Map<String, dynamic>> loadedStudents = [];

      // Agar sinflar bo'lsa, o'sha sinfdagi o'quvchilarni olamiz
      if (classIds.isNotEmpty) {
        final classStudents = await _supabase
            .from('students')
            .select('*, classes:class_id(name)') // 'payments' ni bu yerdan olib tashladim, alohida yuklaymiz
            .inFilter('class_id', classIds.toList())
            .eq('status', 'active');
        
        loadedStudents.addAll(List<Map<String, dynamic>>.from(classStudents));
      }

      // Qo'shimcha: To'g'ridan-to'g'ri biriktirilgan o'quvchilar (Sinfda bo'lmasa ham)
      final directStudents = await _supabase
          .from('students')
          .select('*, classes:class_id(name)')
          .eq('main_teacher_id', staffId!)
          .eq('status', 'active');

      // Takrorlanishni oldini olish
      for (var ds in directStudents) {
        if (!loadedStudents.any((s) => s['id'] == ds['id'])) {
          loadedStudents.add(ds);
        }
      }

      // 3-QADAM: To'lovlarni hisoblash (Xatolik bermasligi uchun try-catch ichida)
      double totalRev = 0;
      int paidCount = 0;
      int debtCount = 0;

      for (var student in loadedStudents) {
        try {
          final monthlyFee = (student['monthly_fee'] ?? 0).toDouble();
          
          // To'lovlarni alohida so'rov bilan olamiz. 
          // DIQQAT: 'status' ustunini ishlatmaymiz, chunki u yo'q ekan.
          final payments = await _supabase
              .from('payments')
              .select('amount')
              .eq('student_id', student['id']);

          double paidSum = 0;
          for (var p in payments) {
            paidSum += (p['amount'] ?? 0).toDouble();
          }

          // UI uchun ma'lumot qo'shamiz
          student['total_paid'] = paidSum;
          
          totalRev += paidSum;
          if (paidSum >= monthlyFee) {
            paidCount++;
          } else {
            debtCount++;
          }
        } catch (e) {
          print("To'lovni hisoblashda xato (Student ID: ${student['id']}): $e");
          student['total_paid'] = 0.0;
          debtCount++;
        }
      }

      // Natijalarni Controllerga yuklash
      teacherStudents.value = loadedStudents;
      totalStudents.value = loadedStudents.length;
      paidStudents.value = paidCount;
      debtorStudents.value = debtCount;
      totalRevenue.value = totalRev;
      
      // Foizni hisoblash
      double totalExpected = loadedStudents.fold(0, (sum, s) => sum + (s['monthly_fee'] ?? 0));
      if (totalExpected > 0) {
        collectionPercentage.value = (totalRev / totalExpected) * 100;
      } else {
        collectionPercentage.value = 0;
      }

    } catch (e) {
      print('Load students error: $e');
      Get.snackbar('Xatolik', 'O\'quvchilar ro\'yxatini yuklashda muammo: $e');
    } finally {
      isLoadingStudents.value = false;
    }
  }

  // To'lov statistikasini yuklangan ma'lumotlardan hisoblash (Tezroq ishlaydi)


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
      // CSV sarlavhalari
      String csv = 'Davr,To\'langan Sana,Summa (Net),Gross,Izoh\n';
      
      for (var salary in salaryHistory) {
        // Davrni yozish (Masalan: 3-2024)
        String period = '${salary['period_month']}-${salary['period_year']}';
        
        // To'langan sanani formatlash
        String paidDate = salary['paid_at'] != null 
            ? salary['paid_at'].toString().substring(0, 10) 
            : '-';
            
        // Summalar
        final net = salary['net_amount'] ?? 0;
        final gross = salary['gross_amount'] ?? 0;
        final note = (salary['notes'] ?? '').toString().replaceAll(',', ' '); // CSV buzilmasligi uchun vergulni olib tashlaymiz

        csv += '$period,$paidDate,$net,$gross,$note\n';
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
// lib/presentation/controllers/staff_detail_controller.dart

// ... (boshqa kodlar)

// editStaff funksiyasini shunday qoldiring:
  void editStaff() {
    Get.toNamed(
      '/add-staff', // <--- DIQQAT: '/edit-staff' EMAS, '/add-staff' bo'lishi shart
      arguments: {
        'staffId': staffId,
        'isEdit': true
      }
    );
  }
// ... (boshqa kodlar)

  void downloadProfile() =>
      Get.snackbar('Yuklanmoqda', 'Profil tayyorlanmoqda...');
  void printProfile() {} // Desktop uchun print dialog ochish

  Future<void> deleteStaff() async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: Text('Butunlay o\'chirish'),
        content: Text(
            'Diqqat! Bu xodim va uning tizimga kirish ma\'lumotlari butunlay o\'chiriladi.\nTasdiqlaysizmi?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('Bekor qilish'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Ha, o\'chirish'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        isLoading.value = true;
        
        // 1. User ID borligini tekshiramiz
        final userId = staff.value?['user_id'];

        if (userId != null) {
          // AGAR USER BO'LSA: Biz Userni o'chiramiz. 
          // Bazadagi "ON DELETE CASCADE" sababli Staff ham avtomatik o'chadi.
          await _supabase.from('users').delete().eq('id', userId);
        } else {
          // AGAR USER BO'LMASA: Faqat Staffni o'chiramiz
          await _supabase.from('staff').delete().eq('id', staffId!);
        }

        Get.back(); // Sahifani yopish
        Get.snackbar(
          'Muvaffaqiyatli',
          'Xodim va foydalanuvchi ma\'lumotlari o\'chirildi',
          backgroundColor: Colors.green.shade100,
        );
      } catch (e) {
        print('Delete error: $e');
        Get.snackbar(
          'Xatolik',
          'O\'chirish imkonsiz: $e',
          backgroundColor: Colors.red.shade100,
          duration: Duration(seconds: 4),
        );
      } finally {
        isLoading.value = false;
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
