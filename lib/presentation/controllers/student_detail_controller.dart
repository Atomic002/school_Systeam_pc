// lib/presentation/controllers/student_detail_controller.dart
// TO'LIQ TUZATILGAN - BARCHA MA'LUMOTLAR BILAN

import 'package:flutter/material.dart';
import 'package:flutter_application_1/presentation/screens/payment/Payments_screen.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StudentDetailController extends GetxController {
  final _supabase = Supabase.instance.client;

  // Observable variables
  final Rx<Map<String, dynamic>?> studentData = Rx<Map<String, dynamic>?>(null);
  final RxBool isLoading = true.obs;
  final RxBool isEditing = false.obs;
  
  // Current tab
  final RxInt selectedTab = 0.obs;

  // To'lovlar
  final RxList<dynamic> paymentHistory = <dynamic>[].obs;
  final RxList<Map<String, dynamic>> monthlyPayments = <Map<String, dynamic>>[].obs;
  final RxBool isLoadingPayments = false.obs;
  final RxDouble totalPaid = 0.0.obs;
  final RxDouble totalDebt = 0.0.obs;
  final RxDouble monthlyFee = 0.0.obs;
  final RxString selectedPaymentPeriod = 'all'.obs;

  // Davomat
  final RxList<dynamic> attendanceRecords = <dynamic>[].obs;
  final RxBool isLoadingAttendance = false.obs;
  final RxInt presentCount = 0.obs;
  final RxInt absentCount = 0.obs;
  final RxInt lateCount = 0.obs;
  final RxInt excusedCount = 0.obs;
  final RxDouble attendancePercentage = 0.0.obs;
  final Rx<DateTime> attendanceStartDate = DateTime.now().subtract(const Duration(days: 30)).obs;
  final Rx<DateTime> attendanceEndDate = DateTime.now().obs;

  // O'quv ma'lumotlari
  final Rx<dynamic> currentEnrollment = Rx<dynamic>(null);
  final Rx<String?> currentClassName = Rx<String?>(null);
  final Rx<String?> currentClassCode = Rx<String?>(null);
  final Rx<String?> classLevelName = Rx<String?>(null);
  final Rx<String?> classTeacherName = Rx<String?>(null);
  final Rx<String?> classTeacherId = Rx<String?>(null);
  final Rx<String?> classRoomName = Rx<String?>(null);
  final Rx<String?> classRoomId = Rx<String?>(null);
  final Rx<String?> branchName = Rx<String?>(null);
  final Rx<String?> branchId = Rx<String?>(null);
  final RxInt studyDuration = 0.obs;
  final RxInt classCapacity = 0.obs;
  final RxInt currentClassSize = 0.obs;

  // Dars jadvali
  final RxList<Map<String, dynamic>> weeklySchedule = <Map<String, dynamic>>[].obs;
  final RxBool isLoadingSchedule = false.obs;

  // Sinfdoshlar
  final RxList<Map<String, dynamic>> classmates = <Map<String, dynamic>>[].obs;
  final RxBool isLoadingClassmates = false.obs;

  String? studentId;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is Map) {
      studentId = Get.arguments['studentId'] as String?;
    } else {
      studentId = Get.arguments as String?;
    }
    if (studentId != null) {
      loadAllData();
    } else {
      isLoading.value = false;
    }
  }

  // ==================== BARCHA MA'LUMOTLARNI YUKLASH ====================
  Future<void> loadAllData() async {
    try {
      isLoading.value = true;

      // O'quvchi asosiy ma'lumotlarini yuklash
      final response = await _supabase
          .from('students')
          .select('''
            *,
            branches(id, name, address, phone)
          ''')
          .eq('id', studentId!)
          .maybeSingle();

      if (response == null) {
        studentData.value = null;
        Get.snackbar(
          'Xatolik',
          'O\'quvchi topilmadi',
          backgroundColor: Colors.red.shade100,
          snackPosition: SnackPosition.TOP,
        );
        return;
      }

      studentData.value = response;
      
      // Filial ma'lumotlari
      final branch = response['branches'] as Map<String, dynamic>?;
      if (branch != null) {
        branchName.value = branch['name'] as String?;
        branchId.value = branch['id'] as String?;
      }

      // Oylik to'lovni olish
      final finalFee = _calculateFinalFee(
        response['monthly_fee'] ?? 0.0,
        response['discount_percent'] ?? 0.0,
        response['discount_amount'] ?? 0.0,
      );
      monthlyFee.value = finalFee;

      // O'qish muddatini hisoblash
      if (response['enrollment_date'] != null) {
        final enrollmentDate = DateTime.parse(response['enrollment_date']);
        final duration = DateTime.now().difference(enrollmentDate);
        studyDuration.value = (duration.inDays / 365).floor();
      }

      // Parallel ravishda boshqa ma'lumotlarni yuklash
      await Future.wait([
        loadEnrollmentInfo(),
        loadPaymentHistory(),
        loadAttendanceHistory(),
        loadSchedule(),
        loadClassmates(),
      ]);
    } catch (e) {
      print('❌ Load all data error: $e');
      Get.snackbar(
        'Xatolik',
        'Ma\'lumotlarni yuklashda xatolik: ${e.toString()}',
        backgroundColor: Colors.red.shade100,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  double _calculateFinalFee(dynamic baseFee, dynamic discountPercent, dynamic discountAmount) {
    final fee = (baseFee is num) ? baseFee.toDouble() : 0.0;
    final percent = (discountPercent is num) ? discountPercent.toDouble() : 0.0;
    final amount = (discountAmount is num) ? discountAmount.toDouble() : 0.0;
    
    return fee - (fee * percent / 100) - amount;
  }

  // ==================== ENROLLMENT MA'LUMOTLARI ====================
    // ==================== ENROLLMENT MA'LUMOTLARI ====================
    // ==================== ENROLLMENT MA'LUMOTLARI ====================
    // ==================== ENROLLMENT MA'LUMOTLARI (TUZATILGAN) ====================
    Future<void> loadEnrollmentInfo() async {
    try {
      print('🔄 Enrollment (Tarix) orqali yuklanmoqda...');
      
      // ENROLLMENTS jadvalidan "is_active = true" bo'lganini qidiramiz
      // Va unga bog'langan CLASSES, STAFF, ROOMS jadvallarini tortib kelamiz
      final response = await _supabase
          .from('enrollments')
          .select('''
            *,
            classes (
              id, name, code, max_students,
              class_levels (id, name),
              staff!main_teacher_id (id, first_name, last_name, phone),
              rooms!default_room_id (id, name, room_number, capacity)
            )
          ''')
          .eq('student_id', studentId!)
          .eq('is_active', true) // Faqat hozirgi sinfini olamiz
          .maybeSingle();

      if (response != null && response['classes'] != null) {
        currentEnrollment.value = response;
        
        final classData = response['classes'];
        
        // 1. Sinf nomi
        currentClassName.value = classData['name'];
        currentClassCode.value = classData['code'];
        classCapacity.value = (classData['max_students'] as num?)?.toInt() ?? 0;

        // 2. Sinf Darajasi
        if (classData['class_levels'] != null) {
          classLevelName.value = classData['class_levels']['name'];
        }

        // 3. O'qituvchi
        if (classData['staff'] != null) {
          final teacher = classData['staff'];
          classTeacherId.value = teacher['id'];
          classTeacherName.value = '${teacher['first_name']} ${teacher['last_name']}';
        } else {
          classTeacherName.value = "Tayinlanmagan";
        }

        // 4. Xona
        if (classData['rooms'] != null) {
          final room = classData['rooms'];
          classRoomId.value = room['id'];
          final rName = room['name'] ?? '';
          final rNum = room['room_number'] ?? '';
          classRoomName.value = rNum.isNotEmpty ? '$rName ($rNum)' : rName;
        } else {
          classRoomName.value = "Xona yo'q";
        }

        // Sinfdagi o'quvchilar sonini hisoblash
        await _loadClassSize(classData['id']);
        
        print('✅ Enrollment ma\'lumotlari yuklandi');
      } else {
        currentClassName.value = 'Sinfga biriktirilmagan';
        classTeacherName.value = '-';
        classRoomName.value = '-';
      }
    } catch (e) {
      print('❌ Enrollment yuklashda xato: $e');
      currentClassName.value = 'Xatolik yuz berdi';
    }
  }

  // Sinfdagi o'quvchilar sonini hisoblash (Students jadvalidan)
  Future<void> _loadClassSize(String classId) async {
    try {
      final response = await _supabase
          .from('students')
          .count() // count() funksiyasi sonini qaytaradi
          .eq('class_id', classId)
          .eq('status', 'active'); // Faqat aktiv o'quvchilarni sanash
      
      currentClassSize.value = response;
    } catch (e) {
      print('❌ Load class size error: $e');
      // Agar count() ishlamasa eski usul:
      try {
        final list = await _supabase.from('students').select('id').eq('class_id', classId);
        currentClassSize.value = list.length;
      } catch (_) {}
    }
  }


  // ==================== TO'LOVLAR TARIXI ====================
  Future<void> loadPaymentHistory() async {
    if (studentId == null) return;

    try {
      isLoadingPayments.value = true;

      // Barcha to'lovlar
      final payments = await _supabase
          .from('payments')
          .select('*')
          .eq('student_id', studentId!)
          .order('payment_date', ascending: false);

      paymentHistory.value = payments;

      // Umumiy to'langan summa
      double paid = 0;
      for (final payment in payments) {
        if (payment['payment_status'] == 'paid') {
          paid += ((payment['final_amount'] ?? 0) as num).toDouble();
        }
      }
      totalPaid.value = paid;

      // Oylik to'lovlar
      await _calculateMonthlyPayments();

      // Qarzdorlikni hisoblash (barcha yillar uchun)
      try {
        final debts = await _supabase
            .from('student_debts')
            .select('*')
            .eq('student_id', studentId!)
            .eq('is_settled', false)
            .order('period_year', ascending: false)
            .order('period_month', ascending: false);

        double debt = 0;
        for (final d in debts) {
          debt += ((d['remaining_amount'] ?? 0) as num).toDouble();
        }
        totalDebt.value = debt;
      } catch (e) {
        print('❌ Load debts error: $e');
        totalDebt.value = 0;
      }
    } catch (e) {
      print('❌ Load payment history error: $e');
    } finally {
      isLoadingPayments.value = false;
    }
  }

  Future<void> _calculateMonthlyPayments() async {
    try {
      final now = DateTime.now();
      final List<Map<String, dynamic>> monthly = [];

      // So'nggi 12 oyni ko'rsatish
      for (int i = 11; i >= 0; i--) {
        final date = DateTime(now.year, now.month - i, 1);
        final month = date.month;
        final year = date.year;

        final payments = paymentHistory.where((p) {
          return p['period_month'] == month && p['period_year'] == year;
        }).toList();

        double paid = 0;
        for (final p in payments) {
          if (p['payment_status'] == 'paid') {
            paid += ((p['final_amount'] ?? 0) as num).toDouble();
          }
        }

        monthly.add({
          'month': month,
          'year': year,
          'paid': paid,
          'expected': monthlyFee.value,
          'isPaid': paid >= monthlyFee.value,
        });
      }

      monthlyPayments.value = monthly;
    } catch (e) {
      print('❌ Calculate monthly payments error: $e');
    }
  }

  void filterPayments(String period) {
    selectedPaymentPeriod.value = period;
  }

  List<dynamic> get filteredPayments {
    if (selectedPaymentPeriod.value == 'all') {
      return paymentHistory;
    } else if (selectedPaymentPeriod.value == 'month') {
      final now = DateTime.now();
      return paymentHistory.where((p) {
        final date = DateTime.parse(p['payment_date']);
        return date.month == now.month && date.year == now.year;
      }).toList();
    } else {
      final now = DateTime.now();
      return paymentHistory.where((p) {
        final date = DateTime.parse(p['payment_date']);
        return date.year == now.year;
      }).toList();
    }
  }

  // ==================== DAVOMAT TARIXI ====================
  Future<void> loadAttendanceHistory() async {
    if (studentId == null) return;

    try {
      isLoadingAttendance.value = true;

      final records = await _supabase
          .from('attendance_students')
          .select('''
            *,
            schedule_sessions(
              *,
              subjects(id, name, code),
              staff(id, first_name, last_name)
            )
          ''')
          .eq('student_id', studentId!)
          .gte('attendance_date', attendanceStartDate.value.toIso8601String())
          .lte('attendance_date', attendanceEndDate.value.toIso8601String())
          .order('attendance_date', ascending: false);

      attendanceRecords.value = records;
      _calculateAttendanceStats(records);
    } catch (e) {
      print('❌ Load attendance history error: $e');
    } finally {
      isLoadingAttendance.value = false;
    }
  }

  void _calculateAttendanceStats(List<dynamic> records) {
    int present = 0, absent = 0, late = 0, excused = 0;

    for (final record in records) {
      switch (record['status']) {
        case 'present':
          present++;
          break;
        case 'absent':
          absent++;
          break;
        case 'late':
          late++;
          break;
        case 'excused':
          excused++;
          break;
      }
    }

    presentCount.value = present;
    absentCount.value = absent;
    lateCount.value = late;
    excusedCount.value = excused;

    final total = present + absent + late + excused;
    attendancePercentage.value = total > 0 ? ((present + excused) / total) * 100 : 0;
  }

  Future<void> selectAttendanceStartDate() async {
    final picked = await showDatePicker(
      context: Get.context!,
      initialDate: attendanceStartDate.value,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      attendanceStartDate.value = picked;
      loadAttendanceHistory();
    }
  }

  Future<void> selectAttendanceEndDate() async {
    final picked = await showDatePicker(
      context: Get.context!,
      initialDate: attendanceEndDate.value,
      firstDate: attendanceStartDate.value,
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      attendanceEndDate.value = picked;
      loadAttendanceHistory();
    }
  }

  // ==================== DARS JADVALI ====================
  Future<void> loadSchedule() async {
    if (currentEnrollment.value == null) return;

    try {
      isLoadingSchedule.value = true;
      
      final classId = currentEnrollment.value['class_id'] as String?;
      if (classId == null) return;

      final response = await _supabase
          .from('schedule_templates')
          .select('''
            *,
            subjects(id, name, code),
            staff(id, first_name, last_name, phone),
            rooms(id, name, room_number)
          ''')
          .eq('class_id', classId)
          .eq('is_active', true)
          .order('day_of_week')
          .order('start_time');

      // Kunlar bo'yicha guruhlash
      final Map<String, List<dynamic>> grouped = {};
      
      for (final item in response) {
        final day = item['day_of_week'] as String;
        if (!grouped.containsKey(day)) {
          grouped[day] = [];
        }
        grouped[day]!.add(item);
      }

      // Kunlarni tartibda saralash
      const dayOrder = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
      
      weeklySchedule.value = dayOrder
          .where((day) => grouped.containsKey(day))
          .map((day) => {
                'day': _getDayName(day),
                'dayEng': day,
                'lessons': grouped[day]!,
              })
          .toList();
    } catch (e) {
      print('❌ Load schedule error: $e');
    } finally {
      isLoadingSchedule.value = false;
    }
  }

  String _getDayName(String day) {
    const days = {
      'monday': 'Dushanba',
      'tuesday': 'Seshanba',
      'wednesday': 'Chorshanba',
      'thursday': 'Payshanba',
      'friday': 'Juma',
      'saturday': 'Shanba',
      'sunday': 'Yakshanba',
    };
    return days[day] ?? day;
  }

  // ==================== SINFDOSHLAR ====================
   // ==================== SINFDOSHLAR ====================
  Future<void> loadClassmates() async {
    // 1-QADAM: Class ID ni olish
    // Biz avval studentData ni yuklaganmiz, class_id o'sha yerda bo'lishi kerak.
    // Agar u yerda bo'lmasa, enrollment dan qaraymiz.
    String? targetClassId = studentData.value?['class_id'];
    
    if (targetClassId == null && currentEnrollment.value != null) {
      targetClassId = currentEnrollment.value['class_id'];
    }

    if (targetClassId == null) {
      print('⚠️ Sinfdoshlarni yuklash uchun Class ID topilmadi');
      return;
    }

    try {
      isLoadingClassmates.value = true;
      print('👥 Sinfdoshlar yuklanmoqda. Class ID: $targetClassId');

      // 2-QADAM: To'g'ridan-to'g'ri students jadvalidan qidirish
      // Bu usul enrollment ga bog'lanishdan ko'ra ancha ishonchli va tez.
      final response = await _supabase
          .from('students')
          .select('id, first_name, last_name, parent_phone, photo_url, monthly_fee, status')
          .eq('class_id', targetClassId)
          .eq('status', 'active') // Faqat aktiv o'quvchilarni ko'rsatish
          .neq('id', studentId!); // O'zini ro'yxatdan chiqarib tashlash

      print('✅ Topilgan sinfdoshlar soni: ${response.length}');

      classmates.value = List<Map<String, dynamic>>.from(response.map((student) {
        return {
          'id': student['id'],
          'name': '${student['first_name']} ${student['last_name']}',
          'phone': student['parent_phone'] ?? '',
          'photo_url': student['photo_url'],
          'monthly_fee': student['monthly_fee'] ?? 0,
          'status': student['status'] ?? 'active',
        };
      }));
      
    } catch (e) {
      print('❌ Load classmates error: $e');
      Get.snackbar('Xatolik', 'Sinfdoshlarni yuklashda xatolik yuz berdi');
    } finally {
      isLoadingClassmates.value = false;
    }
  }
  // ==================== SINFDOSHNING PROFILINI KO'RISH ====================
  void viewClassmateProfile(String classmateId) {
    Get.toNamed('/student-detail', arguments: {'studentId': classmateId});
  }

  // ==================== O'QITUVCHI PROFILINI KO'RISH ====================
  void viewTeacherProfile() {
    if (classTeacherId.value != null) {
      Get.toNamed('/staff-detail', arguments: {'staffId': classTeacherId.value});
    }
  }

  // ==================== HELPER FUNKSIYALAR ====================
  String get fullName {
    if (studentData.value == null) return '';
    return '${studentData.value!['first_name']} ${studentData.value!['last_name']}';
  }

  int? get age {
    if (studentData.value?['birth_date'] == null) return null;
    final birthDate = DateTime.parse(studentData.value!['birth_date']);
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month || (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  String get genderText {
    if (studentData.value == null) return '—';
    return studentData.value!['gender'] == 'male' ? 'Erkak' : 'Ayol';
  }

  String get phone => studentData.value?['phone'] ?? '—';

  String get address {
    if (studentData.value == null) return '—';
    final parts = <String>[];
    if (studentData.value!['region'] != null) parts.add(studentData.value!['region']);
    if (studentData.value!['district'] != null) parts.add(studentData.value!['district']);
    if (studentData.value!['address'] != null) parts.add(studentData.value!['address']);
    return parts.isEmpty ? '—' : parts.join(', ');
  }

  String get parentFullName {
    if (studentData.value == null) return '—';
    return '${studentData.value!['parent_first_name'] ?? ''} ${studentData.value!['parent_last_name'] ?? ''}'.trim();
  }

  String get parentPhone => studentData.value?['parent_phone'] ?? '—';
  String? get parentPhoneSecondary => studentData.value?['parent_phone_secondary'];
  String get parentWorkplace => studentData.value?['parent_workplace'] ?? 'Ko\'rsatilmagan';
  String get parentRelation => studentData.value?['parent_relation'] ?? 'Ota-ona';

  String get status => studentData.value?['status'] ?? 'active';
  String? get photoUrl => studentData.value?['photo_url'];

  String get medicalNotes => studentData.value?['medical_notes'] ?? '';
  bool get hasMedicalNotes => medicalNotes.isNotEmpty;

  String get notes => studentData.value?['notes'] ?? '';
  bool get hasNotes => notes.isNotEmpty;

  String getStudyDuration() {
    if (studentData.value?['enrollment_date'] == null) return '0 kun';
    final enrollmentDate = DateTime.parse(studentData.value!['enrollment_date']);
    final duration = DateTime.now().difference(enrollmentDate);
    final years = (duration.inDays / 365).floor();
    final months = ((duration.inDays % 365) / 30).floor();
    
    if (years > 0 && months > 0) return '$years yil $months oy';
    if (years > 0) return '$years yil';
    if (months > 0) return '$months oy';
    return '${duration.inDays} kun';
  }

  // ==================== TELEFON VA SMS ====================
  Future<void> callParent() async {
    final phone = studentData.value?['parent_phone'];
    if (phone == null || phone.isEmpty) {
      Get.snackbar('Xatolik', 'Telefon raqami mavjud emas');
      return;
    }
    
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> sendMessage() async {
    final phone = studentData.value?['parent_phone'];
    if (phone == null || phone.isEmpty) {
      Get.snackbar('Xatolik', 'Telefon raqami mavjud emas');
      return;
    }
    
    final uri = Uri.parse('sms:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  // ==================== TO'LOV ====================
  // ==================== TO'LOV ====================
  // ==================== TO'LOV ====================
  void makePayment() {
    if (studentId == null) {
      Get.snackbar('Xatolik', 'O\'quvchi ID si topilmadi');
      return;
    }

    // NewPaymentScreenV4 ga o'tish va studentId ni yuborish
    Get.to(
      () => NewPaymentScreenV4(),
      arguments: {'studentId': studentId},
    );
  }

  // ==================== PDF EXPORT ====================
  Future<void> exportToPDF() async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (context) => [
            pw.Text('O\'QUVCHI PROFILI', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 20),
            pw.Text('F.I.Sh: $fullName'),
            pw.Text('Yoshi: ${age ?? '—'} yosh'),
            pw.Text('Telefon: $phone'),
            pw.Text('Sinf: ${currentClassName.value ?? '—'}'),
            pw.Text('Sinf rahbari: ${classTeacherName.value ?? '—'}'),
            pw.Text('Filial: ${branchName.value ?? '—'}'),
            pw.Text('Oylik to\'lov: ${_formatCurrency(monthlyFee.value)} so\'m'),
            pw.Text('Qarzdorlik: ${_formatCurrency(totalDebt.value)} so\'m'),
          ],
        ),
      );

      await Printing.layoutPdf(onLayout: (format) async => pdf.save());
      Get.snackbar('Muvaffaqiyatli', 'PDF yaratildi');
    } catch (e) {
      Get.snackbar('Xatolik', 'PDF yaratishda xatolik');
    }
  }

  void toggleEditMode() {
    isEditing.value = !isEditing.value;
  }

  Future<void> refreshData() async {
    await loadAllData();
  }

  String _formatCurrency(double amount) {
    return NumberFormat('#,###').format(amount);
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '—';
    return DateFormat('dd.MM.yyyy').format(date);
  }
}