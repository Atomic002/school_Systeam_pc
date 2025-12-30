// lib/presentation/controllers/students_controller.dart
// TO'G'RIDAN-TO'G'RI DATABASE DAN ISHLAYDI (CHEKLOVLARSIZ)

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:excel/excel.dart' as excel_pkg;
import 'dart:io';
import 'package:path_provider/path_provider.dart';


class StudentsControlleradmin extends GetxController {
  final _supabase = Supabase.instance.client;

  // Observable variables
  final RxList<Map<String, dynamic>> students = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> allStudents = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;
  final RxString viewMode = 'grid'.obs;

  // Filters
  final Rx<String?> selectedStatus = Rx<String?>(null);
  final Rx<String?> selectedClassId = Rx<String?>(null);
  final Rx<String?> selectedBranchId = Rx<String?>(null);

  // Pagination
  final RxInt currentPage = 1.obs;
  final RxInt itemsPerPage = 20.obs;
  final RxInt totalCount = 0.obs;

  // Statistics
  final RxInt activeCount = 0.obs;
  final RxInt pausedCount = 0.obs;
  final RxInt graduatedCount = 0.obs;
  final RxDouble averageFee = 0.0.obs;

  // Dropdown data
  final RxList<Map<String, dynamic>> classes = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> branches = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _initializeController();
  }

  Future<void> _initializeController() async {
    // AuthService shart emas, chunki biz userga qaramaymiz
    // Lekin filterlar uchun ma'lumotlarni yuklaymiz
    await loadInitialData();
  }

  // ==================== MA'LUMOTLARNI YUKLASH ====================
  Future<void> loadInitialData() async {
    await Future.wait([
      loadBranches(),
      loadClasses(), // Barcha sinflarni yuklash
      loadStudents(), // Barcha o'quvchilarni yuklash
    ]);
  }

  Future<void> loadBranches() async {
    try {
      final response = await _supabase
          .from('branches')
          .select('id, name')
          .eq('is_active', true)
          .order('name');

      branches.value = (response as List)
          .map((e) => {'id': e['id'] as String, 'name': e['name'] as String})
          .toList();
    } catch (e) {
      print('❌ Load branches error: $e');
    }
  }

  Future<void> loadClasses() async {
    try {
      // Branch ID ga qaramasdan barcha aktiv sinflarni yuklaymiz
      var query = _supabase
          .from('classes')
          .select(
            '''
            id, 
            name,
            class_levels(name),
            branches(name)
          ''',
          ) // Branch nomini ham oldik, qaysi filial sinfi ekanini bilish uchun
          .eq('is_active', true);

      // Agar filterda filial tanlangan bo'lsa, faqat o'sha filial sinflarini yuklaymiz
      if (selectedBranchId.value != null) {
        query = query.eq('branch_id', selectedBranchId.value!);
      }

      final response = await query.order('name');

      classes.value = (response as List)
          .map(
            (e) => {
              'id': e['id'] as String,
              // Sinf nomi yoniga filial nomini ham qo'shib qo'yamiz (masalan: "5-A (Toshkent)")
              'name': '${e['name']} (${e['branches']?['name'] ?? ''})',
              'level_name': e['class_levels']?['name'] as String?,
            },
          )
          .toList();
    } catch (e) {
      print('❌ Load classes error: $e');
    }
  }

  Future<void> loadStudents() async {
    try {
      isLoading.value = true;

      // 1. DINAMIK JOIN MANTIQI
      // Agar sinf filteri tanlangan bo'lsa, '!inner' ishlatamiz.
      // Bu degani: "Faqat shu shartga tushadiganlarni olib kel".
      // Agar tanlanmagan bo'lsa, bo'sh qoladi (Left Join) va hammasini olib keladi.
      String joinType = selectedClassId.value != null ? '!inner' : '';

      var query = _supabase.from('students').select('''
            *,
            branches(id, name),
            enrollments$joinType(
              id,
              class_id,
              is_active,
              classes(
                id,
                name,
                code,
                class_level_id,
                main_teacher_id,
                default_room_id,
                class_levels(id, name),
                staff!classes_main_teacher_id_fkey(
                  id,
                  first_name,
                  last_name
                ),
                rooms!classes_default_room_id_fkey(
                  id,
                  name,
                  room_number
                )
              )
            )
          ''');

      // ==================== FILTERLAR ====================

      // 1. Holat bo'yicha filter
      if (selectedStatus.value != null) {
        query = query.eq('status', selectedStatus.value!);
      }

      // 2. Sinf bo'yicha filter
      // Bu yerda !inner bo'lgani uchun, faqat shu ID ga teng bo'lganlar qaytadi
      if (selectedClassId.value != null) {
        query = query
            .eq('enrollments.class_id', selectedClassId.value!)
            .eq('enrollments.is_active', true);
      }

      // 3. Filial bo'yicha filter
      if (selectedBranchId.value != null) {
        query = query.eq('branch_id', selectedBranchId.value!);
      }

      // 4. Qidiruv
      if (searchQuery.value.isNotEmpty) {
        query = query.or(
          'first_name.ilike.%${searchQuery.value}%,'
          'last_name.ilike.%${searchQuery.value}%,'
          'phone.ilike.%${searchQuery.value}%,'
          'parent_phone.ilike.%${searchQuery.value}%',
        );
      }

      // Pagination
      final response = await query
          .order('created_at', ascending: false)
          .range(
            (currentPage.value - 1) * itemsPerPage.value,
            currentPage.value * itemsPerPage.value - 1,
          );

      // Parse students (Ma'lumotlarni o'qish)
      final parsedStudents = (response as List).map((json) {
        final student = Map<String, dynamic>.from(json);

        Map<String, dynamic>? activeEnrollment;

        if (json['enrollments'] != null &&
            (json['enrollments'] as List).isNotEmpty) {
          final enrollmentsList = json['enrollments'] as List;
          // Agar sinf bo'yicha filter qilayotgan bo'lsak, birinchi chiqqani biz qidirayotgan sinf bo'ladi
          activeEnrollment = enrollmentsList.firstWhere(
            (e) => e['is_active'] == true,
            orElse: () => enrollmentsList.first, // Fallback
          );
        }

        if (activeEnrollment != null) {
          final classData = activeEnrollment['classes'];
          if (classData != null) {
            student['class_id'] = classData['id'];
            student['class_name'] = classData['name'];
            student['class_level_id'] = classData['class_level_id'];
            student['class_level_name'] = classData['class_levels']?['name'];

            if (classData['staff'] != null) {
              student['main_teacher_name'] =
                  '${classData['staff']['first_name']} ${classData['staff']['last_name']}';
            }
          }
        } else {
          student['class_name'] = 'Sinfga biriktirilmagan';
          student['class_full_name'] = 'Sinfga biriktirilmagan';
        }

        student['full_name'] =
            '${student['first_name']} ${student['last_name']}';
        String branchName = json['branches']?['name'] ?? '';
        student['branch_name'] = branchName;

        if (activeEnrollment != null && student['class_name'] != null) {
          if (student['class_level_name'] != null) {
            student['class_full_name'] =
                '${student['class_level_name']} - ${student['class_name']}';
          } else {
            student['class_full_name'] = student['class_name'];
          }
        }

        // To'lovni hisoblash
        final monthlyFee = (student['monthly_fee'] ?? 0).toDouble();
        final discountPercent = (student['discount_percent'] ?? 0).toDouble();
        final discountAmount = (student['discount_amount'] ?? 0).toDouble();
        student['final_monthly_fee'] =
            monthlyFee - (monthlyFee * discountPercent / 100) - discountAmount;

        // Status text
        switch (student['status']) {
          case 'active':
            student['status_text'] = 'Faol';
            break;
          case 'paused':
            student['status_text'] = 'To\'xtatilgan';
            break;
          case 'graduated':
            student['status_text'] = 'Bitirgan';
            break;
          case 'pending':
            student['status_text'] = 'Kutilmoqda';
            break;
          default:
            student['status_text'] = student['status'];
        }

        return student;
      }).toList();

      students.value = parsedStudents;

      // Statistics
      await _calculateStatistics();

      // COUNT SO'ROVI HAM FILTERGA MOSLASHISHI KERAK
      // Agar sinf tanlangan bo'lsa, count so'rovini ham shunga moslaymiz
      if (selectedClassId.value != null) {
        final countResponse = await _supabase
            .from('enrollments')
            .select('student_id')
            .eq('class_id', selectedClassId.value!)
            .eq('is_active', true);
        totalCount.value = countResponse.length;
      } else {
        // Oddiy holat
        var countQuery = _supabase.from('students').select('id');
        if (selectedBranchId.value != null) {
          countQuery = countQuery.eq('branch_id', selectedBranchId.value!);
        }
        if (selectedStatus.value != null) {
          countQuery = countQuery.eq('status', selectedStatus.value!);
        }
        final countResponse = await countQuery;
        totalCount.value = countResponse.length;
      }
    } catch (e, stackTrace) {
      print('❌ Load students error: $e\n$stackTrace');
      Get.snackbar(
        'Xatolik',
        'Ma\'lumotlarni yuklashda xatolik',
        backgroundColor: Colors.red.shade100,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _calculateStatistics() async {
    try {
      activeCount.value = students.where((s) => s['status'] == 'active').length;
      pausedCount.value = students.where((s) => s['status'] == 'paused').length;
      graduatedCount.value = students
          .where((s) => s['status'] == 'graduated')
          .length;

      if (students.isNotEmpty) {
        final totalFee = students.fold<double>(
          0,
          (sum, student) => sum + (student['final_monthly_fee'] ?? 0.0),
        );
        averageFee.value = totalFee / students.length;
      } else {
        averageFee.value = 0;
      }
    } catch (e) {
      print('❌ Calculate statistics error: $e');
    }
  }

  // ==================== QIDIRUV ====================
  void searchStudents(String query) {
    searchQuery.value = query;
    // Serverdan qidirish uchun qayta yuklaymiz
    currentPage.value = 1;
    loadStudents();
  }

  // ==================== FILTERLAR ====================
  void setStatusFilter(String? status) {
    selectedStatus.value = status;
    currentPage.value = 1;
    loadStudents();
  }

  void filterByClass(String? classId) {
    selectedClassId.value = classId;
    currentPage.value = 1;
    loadStudents();
  }

  void filterByBranch(String? branchId) {
    selectedBranchId.value = branchId;
    // Filial o'zgarganda sinflar ro'yxatini ham yangilash kerak
    selectedClassId.value = null; // Sinf filterni tozalash
    loadClasses();
    currentPage.value = 1;
    loadStudents();
  }

  void clearAllFilters() {
    selectedStatus.value = null;
    selectedClassId.value = null;
    selectedBranchId.value = null;
    searchQuery.value = '';
    currentPage.value = 1;
    loadClasses(); // Hamma sinflarni qaytarish
    loadStudents();
  }

  // ==================== PAGINATION ====================
  bool get hasPreviousPage => currentPage.value > 1;
  bool get hasNextPage => students.length >= itemsPerPage.value;

  void previousPage() {
    if (hasPreviousPage) {
      currentPage.value--;
      loadStudents();
    }
  }

  void nextPage() {
    if (hasNextPage) {
      currentPage.value++;
      loadStudents();
    }
  }

  // ==================== O'CHIRISH ====================
  Future<void> deleteStudent(String studentId) async {
    try {
      await _supabase.from('students').delete().eq('id', studentId);

      Get.snackbar(
        'Muvaffaqiyatli',
        'O\'quvchi o\'chirildi',
        backgroundColor: Colors.green.shade100,
        snackPosition: SnackPosition.TOP,
      );

      await loadStudents();
    } catch (e) {
      Get.snackbar(
        'Xatolik',
        'O\'quvchini o\'chirishda xatolik',
        backgroundColor: Colors.red.shade100,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  // ==================== TELEFON ====================
  Future<void> callParent(String phone) async {
    if (phone.isEmpty) return;
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  // ==================== YANGILASH ====================
  Future<void> refreshData() async {
    currentPage.value = 1;
    await loadInitialData();
  }

  // ==================== EXPORT PDF, EXCEL, CSV (O'ZGARMAGAN) ====================
  Future<void> exportToPDF() async {
    // ... Eski kod o'z holida qolaveradi, chunki students ro'yxati endi to'liq
    try {
      final pdf = pw.Document();
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (context) => [
            pw.Header(level: 0, child: pw.Text('O\'QUVCHILAR RO\'YXATI')),
            _buildPdfTable(),
          ],
        ),
      );
      await Printing.layoutPdf(onLayout: (format) async => pdf.save());
    } catch (e) {
      Get.snackbar('Xatolik', 'PDF xatosi: $e');
    }
  }

  pw.Widget _buildPdfTable() {
    return pw.Table(
      border: pw.TableBorder.all(),
      children: [
        pw.TableRow(
          children: [
            _buildPdfCell('F.I.Sh', bold: true),
            _buildPdfCell('Filial', bold: true), // Filialni qo'shdik
            _buildPdfCell('Sinf', bold: true),
            _buildPdfCell('Telefon', bold: true),
          ],
        ),
        ...students.map((student) {
          return pw.TableRow(
            children: [
              _buildPdfCell(student['full_name']),
              _buildPdfCell(student['branch_name'] ?? ''), // Filial nomi
              _buildPdfCell(student['class_full_name']),
              _buildPdfCell(student['parent_phone']),
            ],
          );
        }),
      ],
    );
  }

  pw.Widget _buildPdfCell(String text, {bool bold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontWeight: bold ? pw.FontWeight.bold : null,
          fontSize: 10,
        ),
      ),
    );
  }

  Future<void> exportToExcel() async {
    try {
      final excel = excel_pkg.Excel.createExcel();
      final sheet = excel['O\'quvchilar'];

      sheet.appendRow([
        excel_pkg.TextCellValue('№'),
        excel_pkg.TextCellValue('F.I.Sh'),
        excel_pkg.TextCellValue('Sinf'),
        excel_pkg.TextCellValue('Telefon'),
        excel_pkg.TextCellValue('Ota-ona'),
        excel_pkg.TextCellValue('To\'lov'),
        excel_pkg.TextCellValue('Holat'),
      ]);

      for (var i = 0; i < students.length; i++) {
        final student = students[i];
        sheet.appendRow([
          excel_pkg.IntCellValue(i + 1),
          excel_pkg.TextCellValue(student['full_name']),
          excel_pkg.TextCellValue(student['class_full_name']),
          excel_pkg.TextCellValue(student['phone'] ?? ''),
          excel_pkg.TextCellValue(student['parent_phone']),
          excel_pkg.DoubleCellValue(student['final_monthly_fee']),
          excel_pkg.TextCellValue(student['status_text']),
        ]);
      }

      final directory = await getApplicationDocumentsDirectory();
      final file = File(
        '${directory.path}/students_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.xlsx',
      );
      await file.writeAsBytes(excel.encode()!);

      Get.snackbar('Muvaffaqiyatli', 'Excel fayl saqlandi');
    } catch (e) {
      print('❌ Export Excel error: $e');
      Get.snackbar('Xatolik', 'Excel yaratishda xatolik');
    }
  }

  // ==================== EXPORT CSV ====================
  Future<void> exportToCSV() async {
    try {
      final csv = StringBuffer();
      csv.writeln('№,F.I.Sh,Sinf,Telefon,Ota-ona,To\'lov,Holat');

      students.asMap().forEach((index, student) {
        csv.writeln(
          '${index + 1},"${student['full_name']}","${student['class_full_name']}",'
          '"${student['phone'] ?? ''}","${student['parent_phone']}",'
          '${student['final_monthly_fee']},"${student['status_text']}"',
        );
      });

      final directory = await getApplicationDocumentsDirectory();
      final file = File(
        '${directory.path}/students_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.csv',
      );
      await file.writeAsString(csv.toString());

      Get.snackbar(
        'Muvaffaqiyatli',
        'CSV fayl saqlandi',
        backgroundColor: Color.fromRGBO(76, 175, 80, 0.1),
        colorText: Color(0xFF4CAF50),
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      print('❌ Export CSV error: $e');
      Get.snackbar('Xatolik', 'CSV yaratishda xatolik');
    }
  }

  String _formatCurrency(double amount) {
    return NumberFormat('#,###').format(amount);
  }
}
