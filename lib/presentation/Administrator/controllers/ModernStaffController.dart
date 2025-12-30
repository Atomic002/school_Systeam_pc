// lib/presentation/controllers/modern_staff_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';

class ModernStaffControlleradmin extends GetxController {
  final _supabase = Supabase.instance.client;

  final isLoading = false.obs;
  final allStaff = <Map<String, dynamic>>[].obs;
  final filteredStaff = <Map<String, dynamic>>[].obs;
  final branches = <Map<String, dynamic>>[].obs;
  final positions = <String>[].obs;

  final searchQuery = ''.obs;
  final selectedBranchId = Rxn<String>();
  final selectedPosition = Rxn<String>();
  final selectedStatus = Rxn<String>();
  final showOnlyTeachers = false.obs;

  final totalStaff = 0.obs;
  final totalTeachers = 0.obs;
  final activeStaff = 0.obs;
  final onLeaveStaff = 0.obs;
  final averageSalary = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    loadStaffData();
  }

  Future<void> loadStaffData() async {
    try {
      isLoading.value = true;
      await _loadBranches();

      final response = await _supabase
          .from('staff')
          .select('''
            *,
            branches:branch_id(name),
            users:user_id(role, username)
          ''')
          .order('created_at', ascending: false);

      allStaff.value = List<Map<String, dynamic>>.from(response);
      _extractPositions();
      applyFilters();
      _calculateStatistics();
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

  Future<void> _loadBranches() async {
    try {
      final response = await _supabase
          .from('branches')
          .select('id, name')
          .eq('is_active', true)
          .order('name');
      branches.value = List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Load branches error: $e');
    }
  }

  void _extractPositions() {
    final posSet = <String>{};
    for (var staff in allStaff) {
      final position = staff['position'] as String?;
      if (position != null && position.isNotEmpty) {
        posSet.add(position);
      }
    }
    positions.value = posSet.toList()..sort();
  }

  void searchStaff(String query) {
    searchQuery.value = query.toLowerCase();
    applyFilters();
  }

  void filterByBranch(String? branchId) {
    selectedBranchId.value = branchId;
    applyFilters();
  }

  void filterByPosition(String? position) {
    selectedPosition.value = position;
    applyFilters();
  }

  void filterByStatus(String? status) {
    selectedStatus.value = status;
    applyFilters();
  }

  void toggleTeacherFilter(bool value) {
    showOnlyTeachers.value = value;
    applyFilters();
  }

  void applyFilters() {
    var result = List<Map<String, dynamic>>.from(allStaff);

    if (searchQuery.value.isNotEmpty) {
      result = result.where((staff) {
        final firstName = (staff['first_name'] as String?)?.toLowerCase() ?? '';
        final lastName = (staff['last_name'] as String?)?.toLowerCase() ?? '';
        final phone = (staff['phone'] as String?)?.toLowerCase() ?? '';
        final position = (staff['position'] as String?)?.toLowerCase() ?? '';
        return firstName.contains(searchQuery.value) ||
            lastName.contains(searchQuery.value) ||
            phone.contains(searchQuery.value) ||
            position.contains(searchQuery.value);
      }).toList();
    }

    if (selectedBranchId.value != null) {
      result = result
          .where((staff) => staff['branch_id'] == selectedBranchId.value)
          .toList();
    }

    if (selectedPosition.value != null) {
      result = result
          .where((staff) => staff['position'] == selectedPosition.value)
          .toList();
    }

    if (selectedStatus.value != null) {
      result = result
          .where((staff) => staff['status'] == selectedStatus.value)
          .toList();
    }

    if (showOnlyTeachers.value) {
      result = result.where((staff) => staff['is_teacher'] == true).toList();
    }

    filteredStaff.value = result;
  }

  void _calculateStatistics() {
    totalStaff.value = allStaff.length;
    totalTeachers.value = allStaff.where((s) => s['is_teacher'] == true).length;
    activeStaff.value = allStaff.where((s) => s['status'] == 'active').length;
    onLeaveStaff.value = allStaff
        .where((s) => s['status'] == 'on_leave')
        .length;

    double totalSalary = 0;
    int count = 0;
    for (var staff in allStaff) {
      final salary = staff['base_salary'] as num?;
      if (salary != null && salary > 0) {
        totalSalary += salary.toDouble();
        count++;
      }
    }
    averageSalary.value = count > 0 ? totalSalary / count : 0;
  }

  Future<void> deleteStaff(String staffId) async {
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
            .eq('id', staffId);
        Get.snackbar(
          'Muvaffaqiyatli',
          'Xodim o\'chirildi',
          backgroundColor: Colors.green.shade100,
          snackPosition: SnackPosition.TOP,
        );
        await loadStaffData();
      } catch (e) {
        Get.snackbar(
          'Xatolik',
          'Xodim o\'chirilmadi: $e',
          backgroundColor: Colors.red.shade100,
          snackPosition: SnackPosition.TOP,
        );
      }
    }
  }

  // ==================== PDF EXPORT (DESKTOP/MOBILE) ====================
  Future<void> exportToPDF() async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4.landscape,
          build: (context) => [
            pw.Header(
              level: 0,
              child: pw.Text(
                'Xodimlar ro\'yxati',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Table.fromTextArray(
              headers: [
                'ISM',
                'LAVOZIM',
                'TELEFON',
                'FILIAL',
                'MAOSH',
                'STATUS',
              ],
              data: filteredStaff.map((staff) {
                return [
                  '${staff['first_name']} ${staff['last_name']}',
                  staff['position'] ?? '',
                  staff['phone'] ?? '',
                  staff['branches']?['name'] ?? '',
                  '${staff['base_salary'] ?? 0} so\'m',
                  staff['status'] == 'active' ? 'Aktiv' : 'Noaktiv',
                ];
              }).toList(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              cellAlignment: pw.Alignment.centerLeft,
            ),
          ],
        ),
      );

      final bytes = await pdf.save();
      await _saveFile(bytes, 'xodimlar_royxati.pdf', 'application/pdf');

      Get.snackbar(
        'Muvaffaqiyatli',
        'PDF yuklab olindi',
        backgroundColor: Colors.green.shade100,
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      Get.snackbar(
        'Xatolik',
        'PDF yaratilmadi: $e',
        backgroundColor: Colors.red.shade100,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  // ==================== CSV EXPORT ====================
  Future<void> exportToExcel() async {
    try {
      String csv = 'ISM,LAVOZIM,TELEFON,FILIAL,MAOSH,STATUS\n';

      for (var staff in filteredStaff) {
        csv += '"${staff['first_name']} ${staff['last_name']}",';
        csv += '"${staff['position'] ?? ''}",';
        csv += '"${staff['phone'] ?? ''}",';
        csv += '"${staff['branches']?['name'] ?? ''}",';
        csv += '"${staff['base_salary'] ?? 0}",';
        csv += '"${staff['status'] == 'active' ? 'Aktiv' : 'Noaktiv'}"\n';
      }

      final bytes = utf8.encode(csv);
      await _saveFile(bytes, 'xodimlar_royxati.csv', 'text/csv');

      Get.snackbar(
        'Muvaffaqiyatli',
        'CSV yuklab olindi',
        backgroundColor: Colors.green.shade100,
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      Get.snackbar(
        'Xatolik',
        'CSV yaratilmadi: $e',
        backgroundColor: Colors.red.shade100,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  // ==================== UNIVERSAL FAYL SAQLASH ====================
  Future<void> _saveFile(
    List<int> bytes,
    String fileName,
    String mimeType,
  ) async {
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        // Mobile uchun
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/$fileName');
        await file.writeAsBytes(bytes);
        Get.snackbar(
          'Saqlandi',
          'Fayl: ${file.path}',
          backgroundColor: Colors.green.shade100,
          duration: Duration(seconds: 5),
        );
      } else {
        // Desktop uchun - foydalanuvchi o'zi joyni tanlaydi
        String? outputPath = await FilePicker.platform.saveFile(
          dialogTitle: 'Faylni saqlash',
          fileName: fileName,
          type: mimeType == 'application/pdf' ? FileType.custom : FileType.any,
          allowedExtensions: mimeType == 'application/pdf' ? ['pdf'] : ['csv'],
        );

        if (outputPath != null) {
          final file = File(outputPath);
          await file.writeAsBytes(bytes);
          Get.snackbar(
            'Saqlandi',
            'Fayl: $outputPath',
            backgroundColor: Colors.green.shade100,
            duration: Duration(seconds: 5),
          );
        }
      }
    } catch (e) {
      print('Save file error: $e');
      rethrow;
    }
  }
}
