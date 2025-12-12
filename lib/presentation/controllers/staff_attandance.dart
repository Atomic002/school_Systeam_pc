// lib/presentation/controllers/staff_attendance_controller.dart
// XODIMLAR DAVOMATI CONTROLLER - TO'LIQ FUNKSIONAL

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'dart:html' as html;
import 'dart:convert';

class StaffAttendanceController extends GetxController {
  final _supabase = Supabase.instance.client;

  // ==================== ASOSIY MA'LUMOTLAR ====================
  final isLoading = false.obs;
  final selectedDate = DateTime.now().obs;
  final allStaff = <Map<String, dynamic>>[].obs;
  final filteredStaff = <Map<String, dynamic>>[].obs;
  final attendanceRecords = <Map<String, dynamic>>[].obs;
  final branches = <Map<String, dynamic>>[].obs;

  // ==================== FILTERLAR ====================
  final selectedBranchId = Rxn<String>();
  final selectedStatus = Rxn<String>();
  final searchQuery = ''.obs;

  // ==================== STATISTIKA ====================
  final totalStaff = 0.obs;
  final presentCount = 0.obs;
  final absentCount = 0.obs;
  final lateCount = 0.obs;
  final leaveCount = 0.obs;
  final attendancePercentage = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    loadInitialData();
  }

  // ==================== BOSHLANG'ICH MA'LUMOTLARNI YUKLASH ====================
  Future<void> loadInitialData() async {
    await _loadBranches();
    await loadAttendanceData();
  }

  // ==================== FILIALLARNI YUKLASH ====================
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

  // ==================== DAVOMAT MA'LUMOTLARINI YUKLASH ====================
  Future<void> loadAttendanceData() async {
    try {
      isLoading.value = true;

      // Xodimlarni yuklash
      var staffQuery = _supabase
          .from('staff')
          .select('''
            *,
            branches:branch_id(name)
          ''')
          .eq('status', 'active')
          .order('last_name');

      final staffResponse = await staffQuery;
      allStaff.value = List<Map<String, dynamic>>.from(staffResponse);

      // Tanlangan sana uchun davomat ma'lumotlarini yuklash
      final dateStr = selectedDate.value.toIso8601String().split('T')[0];

      final attendanceResponse = await _supabase
          .from('attendance_staff')
          .select('*')
          .eq('attendance_date', dateStr);

      attendanceRecords.value = List<Map<String, dynamic>>.from(
        attendanceResponse,
      );

      // Filterlarni qo'llash
      applyFilters();

      // Statistikani hisoblash
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

  // ==================== FILTERLARNI QO'LLASH ====================
  void applyFilters() {
    var result = List<Map<String, dynamic>>.from(allStaff);

    // Filial filtri
    if (selectedBranchId.value != null) {
      result = result
          .where((staff) => staff['branch_id'] == selectedBranchId.value)
          .toList();
    }

    // Status filtri
    if (selectedStatus.value != null) {
      result = result.where((staff) {
        final attendance = getAttendanceForStaff(staff['id']);
        final status = attendance?['status'] ?? 'not_marked';
        return status == selectedStatus.value;
      }).toList();
    }

    // Qidiruv
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      result = result.where((staff) {
        final firstName = (staff['first_name'] as String?)?.toLowerCase() ?? '';
        final lastName = (staff['last_name'] as String?)?.toLowerCase() ?? '';
        final position = (staff['position'] as String?)?.toLowerCase() ?? '';

        return firstName.contains(query) ||
            lastName.contains(query) ||
            position.contains(query);
      }).toList();
    }

    filteredStaff.value = result;
    totalStaff.value = result.length;
  }

  // ==================== STATISTIKANI HISOBLASH ====================
  void _calculateStatistics() {
    presentCount.value = 0;
    absentCount.value = 0;
    lateCount.value = 0;
    leaveCount.value = 0;

    for (var staff in filteredStaff) {
      final attendance = getAttendanceForStaff(staff['id']);
      final status = attendance?['status'] ?? 'not_marked';

      switch (status) {
        case 'present':
          presentCount.value++;
          break;
        case 'absent':
          absentCount.value++;
          break;
        case 'late':
          lateCount.value++;
          break;
        case 'leave':
          leaveCount.value++;
          break;
      }
    }

    // Davomat foizini hisoblash
    final markedCount =
        presentCount.value +
        lateCount.value +
        absentCount.value +
        leaveCount.value;
    if (totalStaff.value > 0) {
      attendancePercentage.value =
          ((presentCount.value + lateCount.value) / totalStaff.value) * 100;
    }
  }

  // ==================== XODIM UCHUN DAVOMATNI OLISH ====================
  Map<String, dynamic>? getAttendanceForStaff(String staffId) {
    try {
      return attendanceRecords.firstWhere(
        (record) => record['staff_id'] == staffId,
      );
    } catch (e) {
      return null;
    }
  }

  // ==================== DAVOMATNI BELGILASH ====================
  Future<void> markAttendance(String staffId, String status) async {
    try {
      final dateStr = selectedDate.value.toIso8601String().split('T')[0];
      final currentTime = TimeOfDay.now();
      final timeStr =
          '${currentTime.hour.toString().padLeft(2, '0')}:${currentTime.minute.toString().padLeft(2, '0')}:00';

      final existingAttendance = getAttendanceForStaff(staffId);

      if (existingAttendance != null) {
        // Yangilash
        await _supabase
            .from('attendance_staff')
            .update({
              'status': status,
              if (status == 'present' || status == 'late')
                'check_in_time': timeStr,
            })
            .eq('id', existingAttendance['id']);
      } else {
        // Yangi qo'shish
        await _supabase.from('attendance_staff').insert({
          'staff_id': staffId,
          'attendance_date': dateStr,
          'status': status,
          if (status == 'present' || status == 'late') 'check_in_time': timeStr,
        });
      }

      await loadAttendanceData();

      Get.snackbar(
        'Muvaffaqiyatli',
        'Davomat belgilandi',
        backgroundColor: Colors.green.shade100,
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Xatolik',
        'Davomat belgilanmadi: $e',
        backgroundColor: Colors.red.shade100,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  // ==================== DAVOMATNI TAHRIRLASH ====================
  Future<void> editAttendance(
    String staffId,
    Map<String, dynamic> attendance,
  ) async {
    final statusController = TextEditingController(text: attendance['status']);
    final notesController = TextEditingController(
      text: attendance['notes'] ?? '',
    );

    final result = await Get.dialog<Map<String, dynamic>>(
      AlertDialog(
        title: Text('Davomatni tahrirlash'),
        content: Container(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: attendance['status'],
                decoration: InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(value: 'present', child: Text('Kelgan')),
                  DropdownMenuItem(value: 'absent', child: Text('Kelmagan')),
                  DropdownMenuItem(value: 'late', child: Text('Kechikkan')),
                  DropdownMenuItem(value: 'leave', child: Text('Ta\'tilda')),
                ],
                onChanged: (value) {
                  if (value != null) statusController.text = value;
                },
              ),
              SizedBox(height: 16),
              TextField(
                controller: notesController,
                decoration: InputDecoration(
                  labelText: 'Izoh',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Bekor qilish')),
          ElevatedButton(
            onPressed: () => Get.back(
              result: {
                'status': statusController.text,
                'notes': notesController.text,
              },
            ),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: Text('Saqlash'),
          ),
        ],
      ),
    );

    if (result != null) {
      try {
        await _supabase
            .from('attendance_staff')
            .update({'status': result['status'], 'notes': result['notes']})
            .eq('id', attendance['id']);

        await loadAttendanceData();

        Get.snackbar(
          'Muvaffaqiyatli',
          'Davomat yangilandi',
          backgroundColor: Colors.green.shade100,
          snackPosition: SnackPosition.TOP,
        );
      } catch (e) {
        Get.snackbar(
          'Xatolik',
          'Davomat yangilanmadi: $e',
          backgroundColor: Colors.red.shade100,
          snackPosition: SnackPosition.TOP,
        );
      }
    }
  }

  // ==================== BARCHASINI BELGILASH ====================
  Future<void> markAllPresent() async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: Text('Tasdiqlash'),
        content: Text('Barcha xodimlarni "Kelgan" deb belgilaysizmi?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('Yo\'q'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: Text('Ha'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final dateStr = selectedDate.value.toIso8601String().split('T')[0];
        final currentTime = TimeOfDay.now();
        final timeStr =
            '${currentTime.hour.toString().padLeft(2, '0')}:${currentTime.minute.toString().padLeft(2, '0')}:00';

        for (var staff in filteredStaff) {
          final existingAttendance = getAttendanceForStaff(staff['id']);

          if (existingAttendance == null) {
            await _supabase.from('attendance_staff').insert({
              'staff_id': staff['id'],
              'attendance_date': dateStr,
              'status': 'present',
              'check_in_time': timeStr,
            });
          }
        }

        await loadAttendanceData();

        Get.snackbar(
          'Muvaffaqiyatli',
          'Barcha xodimlar belgilandi',
          backgroundColor: Colors.green.shade100,
          snackPosition: SnackPosition.TOP,
        );
      } catch (e) {
        Get.snackbar(
          'Xatolik',
          'Xatolik yuz berdi: $e',
          backgroundColor: Colors.red.shade100,
          snackPosition: SnackPosition.TOP,
        );
      }
    }
  }

  // ==================== SANA TANLASH ====================
  Future<void> selectDate() async {
    final date = await showDatePicker(
      context: Get.context!,
      initialDate: selectedDate.value,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(Duration(days: 1)),
    );

    if (date != null) {
      selectedDate.value = date;
      await loadAttendanceData();
    }
  }

  // ==================== OLDINGI KUN ====================
  Future<void> previousDay() async {
    selectedDate.value = selectedDate.value.subtract(Duration(days: 1));
    await loadAttendanceData();
  }

  // ==================== KEYINGI KUN ====================
  Future<void> nextDay() async {
    if (selectedDate.value.isBefore(DateTime.now())) {
      selectedDate.value = selectedDate.value.add(Duration(days: 1));
      await loadAttendanceData();
    }
  }

  // ==================== BUGUNGGA O'TISH ====================
  Future<void> goToToday() async {
    selectedDate.value = DateTime.now();
    await loadAttendanceData();
  }

  // ==================== FILIAL BO'YICHA FILTERLASH ====================
  void filterByBranch(String? branchId) {
    selectedBranchId.value = branchId;
    applyFilters();
    _calculateStatistics();
  }

  // ==================== STATUS BO'YICHA FILTERLASH ====================
  void filterByStatus(String? status) {
    selectedStatus.value = status;
    applyFilters();
    _calculateStatistics();
  }

  // ==================== QIDIRUV ====================
  void searchStaff(String query) {
    searchQuery.value = query;
    applyFilters();
    _calculateStatistics();
  }

  // ==================== DAVOMATNI EKSPORT QILISH ====================
  Future<void> exportAttendance() async {
    try {
      final dateStr = DateFormat('dd.MM.yyyy').format(selectedDate.value);

      // CSV yaratish
      String csv =
          'ISM,LAVOZIM,FILIAL,STATUS,KIRISH VAQTI,CHIQISH VAQTI,IZOH\n';

      for (var staff in filteredStaff) {
        final attendance = getAttendanceForStaff(staff['id']);
        final status = attendance?['status'] ?? 'not_marked';

        csv += '"${staff['first_name']} ${staff['last_name']}",';
        csv += '"${staff['position'] ?? ''}",';
        csv += '"${staff['branches']?['name'] ?? ''}",';
        csv += '"${_getStatusTextForExport(status)}",';
        csv += '"${attendance?['check_in_time'] ?? '-'}",';
        csv += '"${attendance?['check_out_time'] ?? '-'}",';
        csv += '"${attendance?['notes'] ?? ''}"\n';
      }

      // Faylni yuklab olish
      final bytes = utf8.encode(csv);
      final blob = html.Blob([bytes], 'text/csv;charset=utf-8');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', 'davomat_${dateStr}.csv')
        ..click();
      html.Url.revokeObjectUrl(url);

      Get.snackbar(
        'Muvaffaqiyatli',
        'Davomat yuklab olindi',
        backgroundColor: Colors.green.shade100,
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      Get.snackbar(
        'Xatolik',
        'Yuklab olinmadi: $e',
        backgroundColor: Colors.red.shade100,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  // ==================== STATUS MATNI (EKSPORT UCHUN) ====================
  String _getStatusTextForExport(String status) {
    switch (status) {
      case 'present':
        return 'Kelgan';
      case 'absent':
        return 'Kelmagan';
      case 'late':
        return 'Kechikkan';
      case 'leave':
        return 'Ta\'tilda';
      default:
        return 'Belgilanmagan';
    }
  }
}
