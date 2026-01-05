// lib/presentation/controllers/class_detail_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../data/services/supabase_service.dart';

class ClassDetailController extends GetxController {
  final SupabaseService _supabaseService = Get.find<SupabaseService>();
  final currencyFormat = NumberFormat('#,###', 'uz');

  // Loading states
  var isLoading = false.obs;
  var isExporting = false.obs;

  // Asosiy ma'lumotlar
  var classData = Rxn<Map<String, dynamic>>();
  var students = <Map<String, dynamic>>[].obs;
  var teachers = <Map<String, dynamic>>[].obs;
  var recentPayments = <Map<String, dynamic>>[].obs;
  var availableTeachers = <Map<String, dynamic>>[].obs;
  var availableSubjects = <Map<String, dynamic>>[].obs;

  // Statistika
  var totalStudents = 0.obs;
  var totalExpectedRevenue = 0.0.obs;
  var totalCollectedRevenue = 0.0.obs;
  var totalDebt = 0.0.obs;
  var collectionRate = 0.0.obs;
  var averageAttendance = 0.0.obs;
  var debtorsCount = 0.obs;

  // Filter va Qidiruv
  var searchQuery = ''.obs;
  var filterType = 'all'.obs;

  String? classId;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    classId = args?['id'];
    if (classId != null) {
      refreshData();
    }
  }

  Future<void> refreshData() async {
    isLoading.value = true;
    try {
      await Future.wait([
        loadClassInfo(),
        loadStudentsWithDetailedFinance(),
        loadTeachers(),
        loadRecentPayments(),
        loadAttendanceStats(),
      ]);
      _calculateAggregatedStats();
    } catch (e) {
      print('Xatolik: $e');
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

  Future<void> loadClassInfo() async {
    final response = await _supabaseService.client
        .from('classes')
        .select('''
          *,
          branch:branches(id, name),
          room:rooms!classes_default_room_id_fkey(name),
          main_teacher:staff!classes_main_teacher_id_fkey(first_name, last_name, phone),
          class_level:class_levels(name)
        ''')
        .eq('id', classId!)
        .single();
    classData.value = response;
  }

  Future<void> loadStudentsWithDetailedFinance() async {
    final studentsList = await _supabaseService.client
        .from('students')
        .select(
          'id, first_name, last_name, phone, monthly_fee, discount_percent, enrollment_date',
        )
        .eq('class_id', classId!)
        .eq('status', 'active');

    final allClassPayments = await _supabaseService.client
        .from('payments')
        .select('student_id, final_amount')
        .eq('class_id', classId!)
        .eq('payment_status', 'paid');

    List<Map<String, dynamic>> processedList = [];

    for (var student in studentsList) {
      final studentId = student['id'];
      final monthlyFee = (student['monthly_fee'] as num?)?.toDouble() ?? 0.0;
      final discountPercent =
          (student['discount_percent'] as num?)?.toDouble() ?? 0.0;
      final enrollmentDate = DateTime.parse(student['enrollment_date']);

      final netMonthlyFee = monthlyFee * (1 - discountPercent / 100);

      final now = DateTime.now();
      int monthsStudied =
          (now.year - enrollmentDate.year) * 12 +
          (now.month - enrollmentDate.month);
      if (now.day >= enrollmentDate.day) {
        monthsStudied += 1;
      }
      if (monthsStudied < 1) monthsStudied = 1;

      final expectedTotal = netMonthlyFee * monthsStudied;

      double totalPaid = 0.0;
      for (var payment in allClassPayments) {
        if (payment['student_id'] == studentId) {
          totalPaid += (payment['final_amount'] as num).toDouble();
        }
      }

      double debt = expectedTotal - totalPaid;
      if (debt < 0) debt = 0;

      double paidPercent = expectedTotal > 0
          ? (totalPaid / expectedTotal * 100)
          : 100.0;
      if (paidPercent > 100) paidPercent = 100.0;

      processedList.add({
        ...student,
        'net_monthly_fee': netMonthlyFee,
        'total_expected': expectedTotal,
        'total_paid': totalPaid,
        'debt': debt,
        'paid_percent': paidPercent,
        'months_studied': monthsStudied,
      });
    }

    processedList.sort((a, b) => a['first_name'].compareTo(b['first_name']));
    students.value = processedList;
    totalStudents.value = students.length;
  }

  Future<void> loadTeachers() async {
    final response = await _supabaseService.client
        .from('teacher_classes')
        .select(
          '*, staff:staff_id(id, first_name, last_name, phone, position), subject:subjects(name)',
        )
        .eq('class_id', classId!)
        .eq('is_active', true);

    teachers.value = List<Map<String, dynamic>>.from(response);
  }

  Future<void> loadRecentPayments() async {
    final response = await _supabaseService.client
        .from('payments')
        .select('*, student:students(first_name, last_name)')
        .eq('class_id', classId!)
        .eq('payment_status', 'paid')
        .order('payment_date', ascending: false)
        .limit(10);

    recentPayments.value = List<Map<String, dynamic>>.from(response);
  }

  Future<void> loadAttendanceStats() async {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1).toIso8601String();

      final attendanceData = await _supabaseService.client
          .from('attendance_students')
          .select('status')
          .eq('class_id', classId!)
          .gte('attendance_date', startOfMonth);

      if (attendanceData.isNotEmpty) {
        final presentCount = attendanceData
            .where((a) => a['status'] == 'present')
            .length;
        averageAttendance.value = (presentCount / attendanceData.length) * 100;
      } else {
        averageAttendance.value = 0.0;
      }
    } catch (e) {
      print('Davomat xatosi: $e');
    }
  }

  void _calculateAggregatedStats() {
    double expected = 0;
    double collected = 0;
    double debt = 0;
    int debtors = 0;

    for (var s in students) {
      expected += s['total_expected'];
      collected += s['total_paid'];
      debt += s['debt'];
      if (s['debt'] > 0) debtors++;
    }

    totalExpectedRevenue.value = expected;
    totalCollectedRevenue.value = collected;
    totalDebt.value = debt;
    debtorsCount.value = debtors;

    if (expected > 0) {
      collectionRate.value = (collected / expected) * 100;
    } else {
      collectionRate.value = 100.0;
    }
  }

  List<Map<String, dynamic>> get filteredStudents {
    return students.where((s) {
      final name = '${s['first_name']} ${s['last_name']}'.toLowerCase();
      final query = searchQuery.value.toLowerCase();
      if (!name.contains(query)) return false;

      if (filterType.value == 'debt') return s['debt'] > 0;
      if (filterType.value == 'paid') return s['debt'] <= 0;

      return true;
    }).toList();
  }

  // === AMALLAR ===

  void editClass() async {
    final result = await Get.toNamed('/edit-class', arguments: {'id': classId});
    if (result == true) {
      refreshData(); // Ma'lumotlarni qayta yuklash
    }
  }

  void addStudent() {
    Get.toNamed('/add-student', arguments: {'class_id': classId});
  }

  // O'QITUVCHI BIRIKTIRISH (YANGI FUNKSIYA)
  Future<void> addTeacher() async {
    try {
      // Mavjud o'qituvchilar va fanlarni yuklash
      await _loadAvailableTeachersAndSubjects();

      if (availableTeachers.isEmpty) {
        Get.snackbar(
          'Ogohlantirish',
          'Filialda faol o\'qituvchilar topilmadi',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }

      // Dialog ochish
      _showAddTeacherDialog();
    } catch (e) {
      Get.snackbar('Xato', 'Ma\'lumotlarni yuklashda xatolik: $e');
    }
  }

  Future<void> _loadAvailableTeachersAndSubjects() async {
    if (classData.value == null) return;

    final branchId = classData.value!['branch_id'];

    // Filialdagi barcha faol o'qituvchilarni yuklash
    final teachersResponse = await _supabaseService.client
        .from('staff')
        .select('id, first_name, last_name, position, phone')
        .eq('branch_id', branchId)
        .eq('is_teacher', true)
        .eq('status', 'active');

    availableTeachers.value = List<Map<String, dynamic>>.from(teachersResponse);

    // Barcha fanlarni yuklash
    final subjectsResponse = await _supabaseService.client
        .from('subjects')
        .select('id, name')
        .eq('is_active', true)
        .order('name');

    availableSubjects.value = List<Map<String, dynamic>>.from(subjectsResponse);
  }

  void _showAddTeacherDialog() {
    final selectedTeacherId = Rxn<String>();
    final selectedSubjectId = Rxn<String>();
    final isSaving = false.obs;

    Get.dialog(
      Dialog(
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.person_add, color: Colors.blue),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'O\'qituvchi Biriktirish',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2B3674),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'O\'qituvchini tanlang',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Obx(
                () => DropdownButtonFormField<String>(
                  value: selectedTeacherId.value,
                  decoration: const InputDecoration(
                    labelText: 'O\'qituvchi',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  items: availableTeachers.map<DropdownMenuItem<String>>((
                    teacher,
                  ) {
                    return DropdownMenuItem<String>(
                      value: teacher['id'].toString(),
                      child: Text(
                        '${teacher['first_name']} ${teacher['last_name']} - ${teacher['position'] ?? 'O\'qituvchi'}',
                        overflow: TextOverflow
                            .ellipsis, // Agar ism uzun bo'lsa sig'dirish uchun
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    selectedTeacherId.value = value;
                  },
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Fanni tanlang',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Obx(
                () => DropdownButtonFormField<String>(
                  value: selectedSubjectId.value,
                  decoration: const InputDecoration(
                    labelText: 'Fan',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.book),
                  ),
                  items: availableSubjects.map<DropdownMenuItem<String>>((
                    subject,
                  ) {
                    return DropdownMenuItem<String>(
                      value: subject['id'].toString(),
                      child: Text(subject['name'] ?? ''),
                    );
                  }).toList(),
                  onChanged: (value) {
                    selectedSubjectId.value = value;
                  },
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('Bekor qilish'),
                  ),
                  const SizedBox(width: 12),
                  Obx(
                    () => ElevatedButton(
                      onPressed: isSaving.value
                          ? null
                          : () async {
                              if (selectedTeacherId.value == null) {
                                Get.snackbar(
                                  'Xato',
                                  'O\'qituvchini tanlang',
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                );
                                return;
                              }

                              if (selectedSubjectId.value == null) {
                                Get.snackbar(
                                  'Xato',
                                  'Fanni tanlang',
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                );
                                return;
                              }

                              isSaving.value = true;

                              try {
                                await _supabaseService.client
                                    .from('teacher_classes')
                                    .insert({
                                      'staff_id': selectedTeacherId.value,
                                      'class_id': classId,
                                      'subject_id': selectedSubjectId.value,
                                      'academic_year_id':
                                          classData.value!['academic_year_id'],
                                      'is_active': true,
                                    });

                                Get.back();
                                await loadTeachers();
                                Get.snackbar(
                                  'Muvaffaqiyatli',
                                  'O\'qituvchi muvaffaqiyatli biriktirildi',
                                  backgroundColor: Colors.green,
                                  colorText: Colors.white,
                                );
                              } catch (e) {
                                Get.snackbar(
                                  'Xato',
                                  'O\'qituvchini biriktirishda xatolik: $e',
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                );
                              } finally {
                                isSaving.value = false;
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                      ),
                      child: isSaving.value
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Biriktirish'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> removeTeacher(String teacherClassId) async {
    try {
      // Tasdiqlash dialogi
      final confirm = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Tasdiqlash'),
          content: const Text(
            'Haqiqatan ham bu o\'qituvchini sinfdan o\'chirmoqchimisiz?',
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Yo\'q'),
            ),
            ElevatedButton(
              onPressed: () => Get.back(result: true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Ha, o\'chirish'),
            ),
          ],
        ),
      );

      if (confirm == true) {
        await _supabaseService.client
            .from('teacher_classes')
            .delete()
            .eq('id', teacherClassId);

        await loadTeachers();
        Get.snackbar(
          'Muvaffaqiyatli',
          'O\'qituvchi sinfdan o\'chirildi',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Xato',
        'O\'qituvchini o\'chirishda xatolik: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // PDF Export
  Future<void> exportToPdf() async {
    if (isExporting.value) return;
    isExporting.value = true;

    try {
      final pdf = pw.Document();
      final cData = classData.value!;

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (context) {
            return [
              pw.Header(
                level: 0,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      '${cData['name']} Sinfi Hisoboti',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(DateFormat('dd.MM.yyyy').format(DateTime.now())),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                  children: [
                    _pdfInfoColumn('O\'quvchilar', '${students.length} ta'),
                    _pdfInfoColumn(
                      'Jami Qarz',
                      currencyFormat.format(totalDebt.value),
                      color: PdfColors.red,
                    ),
                    _pdfInfoColumn(
                      'Yig\'ilgan',
                      currencyFormat.format(totalCollectedRevenue.value),
                      color: PdfColors.green,
                    ),
                    _pdfInfoColumn(
                      'To\'lov foizi',
                      '${collectionRate.value.toStringAsFixed(1)}%',
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                "O'quvchilar ro'yxati va moliyaviy holat",
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Table.fromTextArray(
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.blueGrey,
                ),
                headerStyle: pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                ),
                rowDecoration: const pw.BoxDecoration(
                  border: pw.Border(
                    bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
                  ),
                ),
                cellAlignments: {
                  0: pw.Alignment.centerLeft,
                  1: pw.Alignment.centerLeft,
                  2: pw.Alignment.centerRight,
                  3: pw.Alignment.centerRight,
                  4: pw.Alignment.centerRight,
                  5: pw.Alignment.center,
                },
                headers: [
                  '#',
                  'F.I.SH',
                  'Oylik To\'lov',
                  'To\'langan',
                  'Qarz',
                  'Holat',
                ],
                data: List.generate(students.length, (index) {
                  final s = students[index];
                  final hasDebt = s['debt'] > 0;
                  return [
                    (index + 1).toString(),
                    "${s['first_name']} ${s['last_name']}",
                    currencyFormat.format(s['net_monthly_fee']),
                    currencyFormat.format(s['total_paid']),
                    currencyFormat.format(s['debt']),
                    hasDebt ? 'Qarzdor' : 'To\'lagan',
                  ];
                }),
              ),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Text(
                    'Jami qarzdorlik: ',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(
                    currencyFormat.format(totalDebt.value),
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.red,
                    ),
                  ),
                ],
              ),
            ];
          },
        ),
      );

      final output = await pdf.save();
      final fileName =
          '${cData['name']}_hisobot_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf';
      await Printing.sharePdf(bytes: output, filename: fileName);
    } catch (e) {
      Get.snackbar('Xato', 'PDF yaratishda xatolik: $e');
    } finally {
      isExporting.value = false;
    }
  }

  pw.Widget _pdfInfoColumn(
    String title,
    String value, {
    PdfColor color = PdfColors.black,
  }) {
    return pw.Column(
      children: [
        pw.Text(
          title,
          style: const pw.TextStyle(color: PdfColors.grey600, fontSize: 10),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(
            color: color,
            fontWeight: pw.FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
  // lib/presentation/controllers/class_detail_controller.dart ichiga oxirrog'iga qo'shing:

  Future<void> deleteClass() async {
    try {
      // Tasdiqlash dialogi
      final confirm = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Sinfni o\'chirish'),
          content: const Text(
            'Haqiqatan ham bu sinfni o\'chirmoqchimisiz? Barcha ma\'lumotlar arxivlanadi.',
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Yo\'q'),
            ),
            ElevatedButton(
              onPressed: () => Get.back(result: true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Ha, o\'chirish'),
            ),
          ],
        ),
      );

      if (confirm == true) {
        isLoading.value = true;
        
        // Soft delete (is_active = false)
        await _supabaseService.client
            .from('classes')
            .update({'is_active': false})
            .eq('id', classId!);

        Get.back(); // Ekranni yopish va orqaga qaytish
        Get.snackbar(
          'Muvaffaqiyatli',
          'Sinf o\'chirildi',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Xato',
        'Sinfni o\'chirishda xatolik: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
