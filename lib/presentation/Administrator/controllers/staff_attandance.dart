// lib/presentation/controllers/enhanced_staff_attendance_controller.dart
// MUKAMMAL XODIMLAR DAVOMATI CONTROLLER

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:convert';
import 'dart:io' as io;
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:universal_html/html.dart' as html;
import 'package:excel/excel.dart' as excel;

class EnhancedStaffAttendanceControlleradmin extends GetxController {
  final _supabase = Supabase.instance.client;

  // ==================== STATE ====================
  final isLoading = false.obs;
  final selectedDate = DateTime.now().obs;
  final allStaff = <Map<String, dynamic>>[].obs;
  final filteredStaff = <Map<String, dynamic>>[].obs;
  final attendanceRecords = <Map<String, dynamic>>[].obs;
  final branches = <Map<String, dynamic>>[].obs;
  final attendanceRules = Rxn<Map<String, dynamic>>();

  // ==================== FILTERS ====================
  final selectedBranchId = Rxn<String>();
  final selectedStatus = Rxn<String>();
  final selectedSalaryType = Rxn<String>();
  final showOnlyTeachers = false.obs;
  final searchQuery = ''.obs;

  // ==================== DATE RANGE ====================
  final showDateRange = false.obs;
  final startDate = DateTime.now().subtract(Duration(days: 30)).obs;
  final endDate = DateTime.now().obs;

  // ==================== STATISTICS ====================
  final totalStaff = 0.obs;
  final presentCount = 0.obs;
  final absentCount = 0.obs;
  final lateCount = 0.obs;
  final leaveCount = 0.obs;
  final halfDayCount = 0.obs;
  final attendancePercentage = 0.0.obs;
  final totalHoursWorked = 0.0.obs;
  final averageWorkHours = 0.0.obs;

  // ==================== VIEW MODE ====================
  final viewMode = 'daily'.obs; // 'daily', 'weekly', 'monthly', 'calendar'
  
  // ==================== CALENDAR DATA ====================
  final calendarAttendance = <DateTime, List<Map<String, dynamic>>>{}.obs;
  final selectedMonthYear = DateTime.now().obs;

  @override
  void onInit() {
    super.onInit();
    loadInitialData();
  }

  // ==================== INITIAL LOAD ====================
  Future<void> loadInitialData() async {
    await Future.wait([
      _loadBranches(),
      _loadAttendanceRules(),
      loadAttendanceData(),
    ]);
  }

  // ==================== LOAD BRANCHES ====================
  Future<void> _loadBranches() async {
    try {
      final response = await _supabase
          .from('branches')
          .select('id, name')
          .eq('is_active', true)
          .order('name');

      branches.value = List<Map<String, dynamic>>.from(response);
    } catch (e) {
      _showError('Filiallar yuklanmadi: $e');
    }
  }

  // ==================== LOAD ATTENDANCE RULES ====================
  Future<void> _loadAttendanceRules() async {
    try {
      final response = await _supabase
          .from('attendance_rules')
          .select('*')
          .eq('is_active', true)
          .maybeSingle();

      if (response != null) {
        attendanceRules.value = response;
      }
    } catch (e) {
      print('Attendance rules load error: $e');
    }
  }

  // ==================== LOAD ATTENDANCE DATA ====================
  Future<void> loadAttendanceData() async {
    try {
      isLoading.value = true;

      // Load staff with their branch info
      var staffQuery = _supabase.from('staff').select('''
        *,
        branches:branch_id(id, name),
        users:user_id(username, role)
      ''').eq('is_active', true).order('last_name');

      final staffResponse = await staffQuery;
      allStaff.value = List<Map<String, dynamic>>.from(staffResponse);

      // Load attendance based on view mode
      if (viewMode.value == 'daily') {
        await _loadDailyAttendance();
      } else if (viewMode.value == 'monthly' || viewMode.value == 'calendar') {
        await _loadMonthlyAttendance();
      } else if (viewMode.value == 'weekly') {
        await _loadWeeklyAttendance();
      }

      applyFilters();
      calculateStatistics();
    } catch (e) {
      _showError('Ma\'lumotlar yuklanmadi: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ==================== LOAD DAILY ATTENDANCE ====================
  Future<void> _loadDailyAttendance() async {
    final dateStr = selectedDate.value.toIso8601String().split('T')[0];

    final response = await _supabase
        .from('attendance_staff')
        .select('''
          *,
          marked_by_user:marked_by(username),
          approved_by_user:approved_by(username)
        ''')
        .eq('attendance_date', dateStr)
        .order('created_at', ascending: false);

    attendanceRecords.value = List<Map<String, dynamic>>.from(response);
  }

  // ==================== LOAD WEEKLY ATTENDANCE ====================
  Future<void> _loadWeeklyAttendance() async {
    final weekStart = getWeekStart(selectedDate.value);
    final weekEnd = weekStart.add(Duration(days: 6));

    final response = await _supabase
        .from('attendance_staff')
        .select('*')
        .gte('attendance_date', weekStart.toIso8601String().split('T')[0])
        .lte('attendance_date', weekEnd.toIso8601String().split('T')[0])
        .order('attendance_date', ascending: false);

    attendanceRecords.value = List<Map<String, dynamic>>.from(response);
  }

  // ==================== LOAD MONTHLY ATTENDANCE ====================
  Future<void> _loadMonthlyAttendance() async {
    final year = selectedMonthYear.value.year;
    final month = selectedMonthYear.value.month;
    final monthStart = DateTime(year, month, 1);
    final monthEnd = DateTime(year, month + 1, 0);

    final response = await _supabase
        .from('attendance_staff')
        .select('*')
        .gte('attendance_date', monthStart.toIso8601String().split('T')[0])
        .lte('attendance_date', monthEnd.toIso8601String().split('T')[0])
        .order('attendance_date', ascending: false);

    final records = List<Map<String, dynamic>>.from(response);
    attendanceRecords.value = records;

    // Group by date for calendar view
    if (viewMode.value == 'calendar') {
      calendarAttendance.clear();
      for (var record in records) {
        final date = DateTime.parse(record['attendance_date']);
        if (!calendarAttendance.containsKey(date)) {
          calendarAttendance[date] = [];
        }
        calendarAttendance[date]!.add(record);
      }
    }
  }

  // ==================== MARK ATTENDANCE ====================
  Future<void> markAttendance(
    String staffId,
    String status, {
    TimeOfDay? checkInTime,
    TimeOfDay? checkOutTime,
    String? notes,
  }) async {
    try {
      final staff = allStaff.firstWhere((s) => s['id'] == staffId);
      final dateStr = selectedDate.value.toIso8601String().split('T')[0];
      final currentUser = _supabase.auth.currentUser;

      // Check if it's a teacher and validate against schedule
      if (staff['is_teacher'] == true && staff['salary_type'] == 'hourly') {
        final hasSchedule = await _checkTeacherSchedule(staffId, selectedDate.value);
        if (!hasSchedule) {
          Get.dialog(
            AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange),
                  SizedBox(width: 8),
                  Text('Ogohlantirish'),
                ],
              ),
              content: Text(
                'Bu o\'qituvchining bugungi kunda dars jadvali yo\'q. '
                'Davomatni belgilashni davom ettirmoqchimisiz?'
              ),
              actions: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: Text('Bekor qilish'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Get.back();
                    _saveAttendance(staffId, status, dateStr, currentUser?.id,
                        checkInTime, checkOutTime, notes);
                  },
                  child: Text('Davom ettirish'),
                ),
              ],
            ),
          );
          return;
        }
      }

      await _saveAttendance(staffId, status, dateStr, currentUser?.id,
          checkInTime, checkOutTime, notes);
    } catch (e) {
      _showError('Davomat belgilanmadi: $e');
    }
  }

  // ==================== SAVE ATTENDANCE ====================
  Future<void> _saveAttendance(
    String staffId,
    String status,
    String dateStr,
    String? userId,
    TimeOfDay? checkInTime,
    TimeOfDay? checkOutTime,
    String? notes,
  ) async {
    final currentTime = TimeOfDay.now();
    final timeStr = checkInTime != null
        ? '${checkInTime.hour.toString().padLeft(2, '0')}:${checkInTime.minute.toString().padLeft(2, '0')}:00'
        : '${currentTime.hour.toString().padLeft(2, '0')}:${currentTime.minute.toString().padLeft(2, '0')}:00';

    final checkOutStr = checkOutTime != null
        ? '${checkOutTime.hour.toString().padLeft(2, '0')}:${checkOutTime.minute.toString().padLeft(2, '0')}:00'
        : null;

    // Calculate late minutes
    int lateMinutes = 0;
    if (status == 'late' && attendanceRules.value != null) {
      final workStart = TimeOfDay(
        hour: int.parse(attendanceRules.value!['work_start_time'].split(':')[0]),
        minute: int.parse(attendanceRules.value!['work_start_time'].split(':')[1]),
      );
      final checkIn = checkInTime ?? currentTime;
      lateMinutes = (checkIn.hour * 60 + checkIn.minute) - 
                    (workStart.hour * 60 + workStart.minute);
    }

    final existingAttendance = getAttendanceForStaff(staffId);

    Map<String, dynamic> data = {
      'status': status,
      'notes': notes,
      'late_minutes': lateMinutes,
      'marked_by': userId,
      'marked_at': DateTime.now().toIso8601String(),
    };

    if (status == 'present' || status == 'late' || status == 'half_day') {
      data['check_in_time'] = timeStr;
    }

    if (checkOutStr != null) {
      data['check_out_time'] = checkOutStr;
    }

    if (existingAttendance != null) {
      await _supabase
          .from('attendance_staff')
          .update(data)
          .eq('id', existingAttendance['id']);
    } else {
      data['staff_id'] = staffId;
      data['attendance_date'] = dateStr;
      data['branch_id'] = selectedBranchId.value;
      
      await _supabase.from('attendance_staff').insert(data);
    }

    await loadAttendanceData();
    _showSuccess('Davomat muvaffaqiyatli belgilandi');
  }

  // ==================== CHECK TEACHER SCHEDULE ====================
  Future<bool> _checkTeacherSchedule(String teacherId, DateTime date) async {
    try {
      final dayOfWeek = _getDayOfWeekName(date.weekday);
      final dateStr = date.toIso8601String().split('T')[0];

      // Check schedule sessions for the date
      final sessions = await _supabase
          .from('schedule_sessions')
          .select('id')
          .eq('teacher_id', teacherId)
          .eq('session_date', dateStr)
          .eq('is_cancelled', false);

      if (sessions.isNotEmpty) return true;

      // Check template schedule
      final templates = await _supabase
          .from('schedule_templates')
          .select('id')
          .eq('teacher_id', teacherId)
          .eq('day_of_week', dayOfWeek)
          .eq('is_active', true);

      return templates.isNotEmpty;
    } catch (e) {
      print('Schedule check error: $e');
      return false;
    }
  }

  // ==================== MARK ALL PRESENT ====================
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
            child: Text('Ha'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      isLoading.value = true;
      final dateStr = selectedDate.value.toIso8601String().split('T')[0];
      final currentTime = TimeOfDay.now();
      final timeStr = '${currentTime.hour.toString().padLeft(2, '0')}:${currentTime.minute.toString().padLeft(2, '0')}:00';
      final currentUser = _supabase.auth.currentUser;

      for (var staff in filteredStaff) {
        final existingAttendance = getAttendanceForStaff(staff['id']);
        if (existingAttendance == null) {
          await _supabase.from('attendance_staff').insert({
            'staff_id': staff['id'],
            'attendance_date': dateStr,
            'status': 'present',
            'check_in_time': timeStr,
            'branch_id': staff['branch_id'],
            'marked_by': currentUser?.id,
          });
        }
      }

      await loadAttendanceData();
      _showSuccess('Barcha xodimlar belgilandi');
    } catch (e) {
      _showError('Xatolik yuz berdi: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ==================== AUTO MARK ABSENT ====================
  Future<void> autoMarkAbsent() async {
    try {
      final dateStr = selectedDate.value.toIso8601String().split('T')[0];
      final currentUser = _supabase.auth.currentUser;

      for (var staff in filteredStaff) {
        final existingAttendance = getAttendanceForStaff(staff['id']);
        if (existingAttendance == null) {
          await _supabase.from('attendance_staff').insert({
            'staff_id': staff['id'],
            'attendance_date': dateStr,
            'status': 'absent',
            'branch_id': staff['branch_id'],
            'marked_by': currentUser?.id,
            'notes': 'Avtomatik belgilangan',
          });
        }
      }

      await loadAttendanceData();
      _showSuccess('Kelmaganlar avtomatik belgilandi');
    } catch (e) {
      _showError('Xatolik: $e');
    }
  }

  // ==================== EDIT ATTENDANCE ====================
  Future<void> editAttendance(String staffId, Map<String, dynamic> attendance) async {
    final statusController = TextEditingController(text: attendance['status']);
    final checkInController = TextEditingController(
      text: attendance['check_in_time'] ?? '',
    );
    final checkOutController = TextEditingController(
      text: attendance['check_out_time'] ?? '',
    );
    final notesController = TextEditingController(text: attendance['notes'] ?? '');

    final result = await Get.dialog<Map<String, dynamic>>(
      AlertDialog(
        title: Text('Davomatni tahrirlash'),
        content: Container(
          width: 500,
          child: SingleChildScrollView(
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
                    DropdownMenuItem(value: 'half_day', child: Text('Yarim kun')),
                    DropdownMenuItem(value: 'sick', child: Text('Kasal')),
                  ],
                  onChanged: (value) {
                    if (value != null) statusController.text = value;
                  },
                ),
                SizedBox(height: 16),
                TextField(
                  controller: checkInController,
                  decoration: InputDecoration(
                    labelText: 'Kirish vaqti (HH:MM)',
                    border: OutlineInputBorder(),
                    hintText: '09:00',
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: checkOutController,
                  decoration: InputDecoration(
                    labelText: 'Chiqish vaqti (HH:MM)',
                    border: OutlineInputBorder(),
                    hintText: '18:00',
                  ),
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
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Bekor qilish'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: {
              'status': statusController.text,
            'check_in_time': checkInController.text.isNotEmpty 
    ? (checkInController.text.split(':').length == 2 
        ? '${checkInController.text}:00' // Agar 22:33 bo'lsa -> 22:33:00 qilamiz
        : checkInController.text)        // Agar 22:33:00 bo'lsa -> o'zini qoldiramiz
    : null,

'check_out_time': checkOutController.text.isNotEmpty 
    ? (checkOutController.text.split(':').length == 2 
        ? '${checkOutController.text}:00' 
        : checkOutController.text)
    : null,
              'notes': notesController.text,
            }),
            child: Text('Saqlash'),
          ),
        ],
      ),
    );

    if (result != null) {
      try {
        await _supabase
            .from('attendance_staff')
            .update(result)
            .eq('id', attendance['id']);

        await loadAttendanceData();
        _showSuccess('Davomat yangilandi');
      } catch (e) {
        _showError('Yangilanmadi: $e');
      }
    }
  }

  // ==================== APPLY FILTERS ====================
  void applyFilters() {
    var result = List<Map<String, dynamic>>.from(allStaff);

    if (selectedBranchId.value != null) {
      result = result.where((s) => s['branch_id'] == selectedBranchId.value).toList();
    }

    if (selectedSalaryType.value != null) {
      result = result.where((s) => s['salary_type'] == selectedSalaryType.value).toList();
    }

    if (showOnlyTeachers.value) {
      result = result.where((s) => s['is_teacher'] == true).toList();
    }

    if (selectedStatus.value != null) {
      result = result.where((staff) {
        final attendance = getAttendanceForStaff(staff['id']);
        final status = attendance?['status'] ?? 'not_marked';
        return status == selectedStatus.value;
      }).toList();
    }

    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      result = result.where((staff) {
        final firstName = (staff['first_name'] as String?)?.toLowerCase() ?? '';
        final lastName = (staff['last_name'] as String?)?.toLowerCase() ?? '';
        final position = (staff['position'] as String?)?.toLowerCase() ?? '';
        final phone = (staff['phone'] as String?)?.toLowerCase() ?? '';
        
        return firstName.contains(query) ||
            lastName.contains(query) ||
            position.contains(query) ||
            phone.contains(query);
      }).toList();
    }

    filteredStaff.value = result;
    totalStaff.value = result.length;
  }

  // ==================== CALCULATE STATISTICS ====================
  void calculateStatistics() {
    presentCount.value = 0;
    absentCount.value = 0;
    lateCount.value = 0;
    leaveCount.value = 0;
    halfDayCount.value = 0;
    double totalHours = 0;
    int staffWithAttendance = 0;

    for (var staff in filteredStaff) {
      final attendance = getAttendanceForStaff(staff['id']);
      if (attendance != null) {
        final status = attendance['status'];
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
          case 'sick':
            leaveCount.value++;
            break;
          case 'half_day':
            halfDayCount.value++;
            break;
        }

        if (attendance['actual_hours'] != null) {
          totalHours += (attendance['actual_hours'] as num).toDouble();
          staffWithAttendance++;
        }
      }
    }

    totalHoursWorked.value = totalHours;
    averageWorkHours.value = staffWithAttendance > 0 
        ? totalHours / staffWithAttendance 
        : 0;

    if (totalStaff.value > 0) {
      attendancePercentage.value = 
          ((presentCount.value + lateCount.value + halfDayCount.value) / 
           totalStaff.value) * 100;
    }
  }

  // ==================== EXPORT TO EXCEL ====================
     Future<void> exportToExcel() async {
    try {
      final excelFile = excel.Excel.createExcel();
      final sheet = excelFile['Davomat'];

      // Headers
      final headers = [
        'ISM',
        'LAVOZIM',
        'FILIAL',
        'MAOSH TURI',
        'STATUS',
        'KIRISH',
        'CHIQISH',
        'SOATLAR',
        'KECHIKISH (daq)',
        'IZOH',
      ];

      for (var i = 0; i < headers.length; i++) {
        var cell = sheet.cell(excel.CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
        
        // O'ZGARISH 1: Stringni TextCellValue ga o'rash kerak
        cell.value = excel.TextCellValue(headers[i]); 
        
        cell.cellStyle = excel.CellStyle(
          bold: true,
          backgroundColorHex: excel.ExcelColor.fromHexString('#1976D2'),
          fontColorHex: excel.ExcelColor.fromHexString('#FFFFFF'),
        );
      }

      // Data rows
      int row = 1;
      for (var staff in filteredStaff) {
        final attendance = getAttendanceForStaff(staff['id']);
        final status = attendance?['status'] ?? 'not_marked';

        final rowData = [
          '${staff['first_name']} ${staff['last_name']}',
          staff['position'] ?? '',
          staff['branches']?['name'] ?? '',
          getSalaryTypeText(staff['salary_type']),
          _getStatusTextForExport(status),
          attendance?['check_in_time'] ?? '-',
          attendance?['check_out_time'] ?? '-',
          attendance?['actual_hours']?.toString() ?? '-',
          attendance?['late_minutes']?.toString() ?? '0',
          attendance?['notes'] ?? '',
        ];

        for (var i = 0; i < rowData.length; i++) {
          // O'ZGARISH 2: Bu yerda ham TextCellValue ishlatish shart
          sheet.cell(excel.CellIndex.indexByColumnRow(columnIndex: i, rowIndex: row))
            .value = excel.TextCellValue(rowData[i]);
        }
        row++;
      }

      final bytes = excelFile.encode();
      if (bytes == null) throw Exception('Excel yaratishda xatolik');

      final dateStr = DateFormat('dd_MM_yyyy').format(selectedDate.value);
      final fileName = 'xodimlar_davomati_$dateStr.xlsx';

      if (kIsWeb) {
        _downloadFileWeb(bytes, fileName);
      } else {
        await _saveFileDesktop(bytes, fileName);
      }

      _showSuccess('Excel fayli yuklandi');
    } catch (e) {
      _showError('Excel yaratilmadi: $e');
    }
  }
  // ==================== EXPORT TO PDF ====================
  Future<void> exportToPDF() async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4.landscape,
          build: (context) => [
            pw.Header(
              level: 0,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'XODIMLAR DAVOMATI',
                    style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    DateFormat('dd MMMM yyyy, EEEE', 'uz').format(selectedDate.value),
                    style: pw.TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            
            // Statistics
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
              children: [
                _buildPdfStatCard('Jami', totalStaff.value.toString()),
                _buildPdfStatCard('Kelgan', presentCount.value.toString()),
                _buildPdfStatCard('Kelmagan', absentCount.value.toString()),
                _buildPdfStatCard('Kechikkan', lateCount.value.toString()),
                _buildPdfStatCard('Davomat %', '${attendancePercentage.value.toStringAsFixed(1)}%'),
              ],
            ),
            
            pw.SizedBox(height: 20),
            
            // Table
            pw.Table.fromTextArray(
              headers: ['ISM', 'LAVOZIM', 'FILIAL', 'STATUS', 'KIRISH', 'CHIQISH', 'SOAT'],
              data: filteredStaff.map((staff) {
                final attendance = getAttendanceForStaff(staff['id']);
                final status = attendance?['status'] ?? 'not_marked';
                return [
                  '${staff['first_name']} ${staff['last_name']}',
                  staff['position'] ?? '',
                  staff['branches']?['name'] ?? '',
                  _getStatusTextForExport(status),
                  attendance?['check_in_time'] ?? '-',
                  attendance?['check_out_time'] ?? '-',
                  attendance?['actual_hours']?.toString() ?? '-',
                ];
              }).toList(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              cellAlignment: pw.Alignment.centerLeft,
              headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
            ),
          ],
        ),
      );

      final bytes = await pdf.save();
      final dateStr = DateFormat('dd_MM_yyyy').format(selectedDate.value);
      final fileName = 'davomat_$dateStr.pdf';

      if (kIsWeb) {
        _downloadFileWeb(bytes, fileName);
      } else {
        await _saveFilePDFDesktop(bytes, fileName);
      }

      _showSuccess('PDF yuklandi');
    } catch (e) {
      _showError('PDF yaratilmadi: $e');
    }
  }

  pw.Widget _buildPdfStatCard(String label, String value) {
    return pw.Container(
      padding: pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Column(
        children: [
          pw.Text(value, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 4),
          pw.Text(label, style: pw.TextStyle(fontSize: 10)),
        ],
      ),
    );
  }

  // ==================== HELPER METHODS ====================

  Map<String, dynamic>? getAttendanceForStaff(String staffId) {
    try {
      return attendanceRecords.firstWhere((r) => r['staff_id'] == staffId);
    } catch (e) {
      return null;
    }
  }

DateTime getWeekStart(DateTime date) {
   return date.subtract(Duration(days: date.weekday - 1));
}

  String _getDayOfWeekName(int weekday) {
    const days = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
    return days[weekday - 1];
  }

  String getSalaryTypeText(String? type) {
    switch (type) {
      case 'monthly': return 'Oylik';
      case 'hourly': return 'Soatlik';
      case 'daily': return 'Kunlik';
      default: return type ?? 'N/A';
    }
  }

  String _getStatusTextForExport(String status) {
    switch (status) {
      case 'present': return 'Kelgan';
      case 'absent': return 'Kelmagan';
      case 'late': return 'Kechikkan';
      case 'leave': return 'Ta\'tilda';
      case 'half_day': return 'Yarim kun';
      case 'sick': return 'Kasal';
      default: return 'Belgilanmagan';
    }
  }

  void _downloadFileWeb(List<int> bytes, String fileName) {
    if (kIsWeb) {
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', fileName)
        ..click();
      html.Url.revokeObjectUrl(url);
    }
  }

  Future<void> _saveFileDesktop(List<int> bytes, String fileName) async {
    if (!kIsWeb) {
      if (io.Platform.isAndroid || io.Platform.isIOS) {
        final directory = await getApplicationDocumentsDirectory();
        final file = io.File('${directory.path}/$fileName');
        await file.writeAsBytes(bytes);
        _showSuccess('Fayl saqlandi: ${file.path}');
      } else {
        String? outputPath = await FilePicker.platform.saveFile(
          dialogTitle: 'Faylni saqlash',
          fileName: fileName,
        );
        if (outputPath != null) {
          final file = io.File(outputPath);
          await file.writeAsBytes(bytes);
          _showSuccess('Fayl saqlandi');
        }
      }
    }
  }

  Future<void> _saveFilePDFDesktop(List<int> bytes, String fileName) async {
    await _saveFileDesktop(bytes, fileName);
  }

  void _showSuccess(String message) {
    Get.snackbar(
      'Muvaffaqiyatli',
      message,
      backgroundColor: Colors.green.shade100,
      snackPosition: SnackPosition.TOP,
      duration: Duration(seconds: 3),
      icon: Icon(Icons.check_circle, color: Colors.green),
    );
  }

  void _showError(String message) {
    Get.snackbar(
      'Xatolik',
      message,
      backgroundColor: Colors.red.shade100,
      snackPosition: SnackPosition.TOP,
      duration: Duration(seconds: 4),
      icon: Icon(Icons.error, color: Colors.red),
    );
  }

  // ==================== DATE NAVIGATION ====================
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

  Future<void> previousDay() async {
    selectedDate.value = selectedDate.value.subtract(Duration(days: 1));
    await loadAttendanceData();
  }

  Future<void> nextDay() async {
    if (selectedDate.value.isBefore(DateTime.now())) {
      selectedDate.value = selectedDate.value.add(Duration(days: 1));
      await loadAttendanceData();
    }
  }

  Future<void> goToToday() async {
    selectedDate.value = DateTime.now();
    await loadAttendanceData();
  }

  // ==================== FILTER METHODS ====================
  void filterByBranch(String? branchId) {
    selectedBranchId.value = branchId;
    applyFilters();
    calculateStatistics();
  }

  void filterByStatus(String? status) {
    selectedStatus.value = status;
    applyFilters();
    calculateStatistics();
  }

  void filterBySalaryType(String? type) {
    selectedSalaryType.value = type;
    applyFilters();
    calculateStatistics();
  }

  void searchStaff(String query) {
    searchQuery.value = query;
    applyFilters();
    calculateStatistics();
  }

  void toggleTeacherFilter(bool value) {
    showOnlyTeachers.value = value;
    applyFilters();
    calculateStatistics();
  }
}