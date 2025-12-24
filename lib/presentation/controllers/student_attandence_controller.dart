// lib/presentation/controllers/student_attendance_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:excel/excel.dart' as excel_pkg;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class StudentAttendanceController extends GetxController {
  final _supabase = Supabase.instance.client;

  // Observable variables
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final Rx<DateTime> selectedMonthYear = DateTime.now().obs;
  final RxString viewMode = 'daily'.obs;
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;

  // Filters
  final Rx<String?> selectedBranchId = Rx<String?>(null);
  final Rx<String?> selectedClassId = Rx<String?>(null);
  final Rx<String?> selectedStatus = Rx<String?>(null);
  final RxString searchQuery = ''.obs;

  // Data
  final RxList<Map<String, dynamic>> branches = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> classes = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> students = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> filteredStudents =
      <Map<String, dynamic>>[].obs;

  // Attendance status map
  final RxMap<String, Map<String, dynamic>> attendanceStatus =
      <String, Map<String, dynamic>>{}.obs;

  // Statistics
  final RxInt totalStudents = 0.obs;
  final RxInt presentCount = 0.obs;
  final RxInt absentCount = 0.obs;
  final RxInt lateCount = 0.obs;
  final RxInt excusedCount = 0.obs;
  final RxDouble attendancePercentage = 0.0.obs;

  // Calendar data
  final RxMap<DateTime, List<Map<String, dynamic>>> calendarAttendance =
      <DateTime, List<Map<String, dynamic>>>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _loadInitialData();
  }

  // ==================== INITIAL DATA ====================
  Future<void> _loadInitialData() async {
    await Future.wait([_loadBranches(), _loadClasses()]);
  }

  Future<void> _loadBranches() async {
    try {
      final response = await _supabase
          .from('branches')
          .select('id, name')
          .eq('is_active', true)
          .order('name');

      branches.value = List<Map<String, dynamic>>.from(response);

      print('✅ Loaded ${branches.length} branches');
    } catch (e) {
      print('❌ Load branches error: $e');
    }
  }

  Future<void> _loadClasses() async {
    try {
      final response = await _supabase
          .from('classes')
          .select('''
            id,
            name,
            code,
            max_students,
            class_levels(id, name, order_number),
            branches(id, name),
            staff!classes_main_teacher_id_fkey(id, first_name, last_name),
            rooms!classes_room_id_fkey(id, name)
          ''')
          .eq('is_active', true)
          .order('name');

      classes.value = List<Map<String, dynamic>>.from(
        response.map((item) {
          final classLevel = item['class_levels'] as Map?;
          final branch = item['branches'] as Map?;
          final teacher = item['staff'] as Map?;

          return {
            'id': item['id'],
            'name': item['name'],
            'code': item['code'],
            'max_students': item['max_students'],
            'level_name': classLevel?['name'] ?? '',
            'branch_name': branch?['name'] ?? '',
            'branch_id': branch?['id'],
            'teacher_name': teacher != null
                ? '${teacher['first_name']} ${teacher['last_name']}'
                : '',
          };
        }),
      );

      print('✅ Loaded ${classes.length} classes');
    } catch (e) {
      print('❌ Load classes error: $e');
    }
  }

  // ==================== DATE/CLASS CHANGES ====================
  void changeDate(DateTime date) {
    selectedDate.value = date;
    if (selectedClassId.value != null) {
      loadAttendanceData();
    }
  }

  void changeMonth(DateTime month) {
    selectedMonthYear.value = month;
    loadAttendanceData();
  }

  DateTime getWeekStart(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  void changeClass(String? classId) {
    selectedClassId.value = classId;

    // Sinf tanlanganda branch_id ni ham o'rnatish
    if (classId != null) {
      final selectedClass = classes.firstWhereOrNull((c) => c['id'] == classId);
      if (selectedClass != null) {
        selectedBranchId.value = selectedClass['branch_id'];
      }
      loadAttendanceData();
    } else {
      students.clear();
      filteredStudents.clear();
      attendanceStatus.clear();
      _resetStatistics();
    }
  }

  // ==================== LOAD ATTENDANCE DATA ====================
  Future<void> loadAttendanceData() async {
    final classId = selectedClassId.value;
    if (classId == null) {
      print('⚠️ Class ID null');
      return;
    }

    try {
      isLoading.value = true;
      print('📥 Loading attendance for class: $classId');

      await _loadClassStudents(classId);

      if (viewMode.value == 'daily') {
        await _loadDailyAttendance(classId);
      } else if (viewMode.value == 'weekly') {
        await _loadWeeklyAttendance(classId);
      } else if (viewMode.value == 'monthly' || viewMode.value == 'calendar') {
        await _loadMonthlyAttendance(classId);
      }

      applyFilters();
      calculateStatistics();

      print('✅ Attendance loaded successfully');
    } catch (e) {
      print('❌ Load attendance error: $e');
      Get.snackbar(
        'Xatolik',
        'Davomatni yuklashda xatolik: $e',
        backgroundColor: Colors.red.shade100,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadClassStudents(String classId) async {
    try {
      final response = await _supabase
          .from('students')
          .select('''
            id, first_name, last_name, middle_name, phone, photo_url,
            birth_date, gender, parent_phone, monthly_fee, status,
            branches(id, name),
            class_levels(id, name)
          ''')
          .eq('class_id', classId)
          .eq('status', 'active')
          .order('last_name');

      students.value = List<Map<String, dynamic>>.from(
        response.map((student) {
          final branch = student['branches'] as Map?;
          final classLevel = student['class_levels'] as Map?;

          return {
            'id': student['id'],
            'name': '${student['last_name']} ${student['first_name']}',
            'full_name':
                '${student['last_name']} ${student['first_name']} ${student['middle_name'] ?? ''}',
            'phone': student['phone'] ?? '',
            'parent_phone': student['parent_phone'] ?? '',
            'photo_url': student['photo_url'],
            'birth_date': student['birth_date'],
            'gender': student['gender'],
            'monthly_fee': student['monthly_fee'] ?? 0,
            'status': student['status'],
            'branch_name': branch?['name'] ?? '',
            'class_level': classLevel?['name'] ?? '',
          };
        }),
      );

      totalStudents.value = students.length;
      print('✅ Loaded ${students.length} students');
    } catch (e) {
      print('❌ Load class students error: $e');
      throw e;
    }
  }

  Future<void> _loadDailyAttendance(String classId) async {
    try {
      final dateString = selectedDate.value.toIso8601String().split('T')[0];

      print('📅 Loading attendance for date: $dateString');

      final response = await _supabase
          .from('attendance_students')
          .select('*')
          .eq('class_id', classId)
          .eq('attendance_date', dateString);

      print('📊 Found ${response.length} attendance records');

      attendanceStatus.clear();
      for (final record in response) {
        attendanceStatus[record['student_id']] = {
          'status': record['status'],
          'arrival_time': record['arrival_time'],
          'notes': record['notes'],
          'marked_at': record['marked_at'],
        };
      }

      // Set default status for students without attendance
      for (final student in students) {
        if (!attendanceStatus.containsKey(student['id'])) {
          attendanceStatus[student['id']] = {
            'status': 'not_marked',
            'arrival_time': null,
            'notes': null,
            'marked_at': null,
          };
        }
      }
    } catch (e) {
      print('❌ Load daily attendance error: $e');
    }
  }

  Future<void> _loadWeeklyAttendance(String classId) async {
    try {
      final weekStart = getWeekStart(selectedDate.value);
      final weekEnd = weekStart.add(Duration(days: 6));

      final response = await _supabase
          .from('attendance_students')
          .select('*')
          .eq('class_id', classId)
          .gte('attendance_date', weekStart.toIso8601String().split('T')[0])
          .lte('attendance_date', weekEnd.toIso8601String().split('T')[0]);

      final Map<String, Map<String, dynamic>> weeklyData = {};

      for (final record in response) {
        final studentId = record['student_id'];
        if (!weeklyData.containsKey(studentId)) {
          weeklyData[studentId] = {
            'present': 0,
            'absent': 0,
            'late': 0,
            'excused': 0,
          };
        }

        final status = record['status'];
        if (weeklyData[studentId]!.containsKey(status)) {
          weeklyData[studentId]![status]++;
        }
      }

      attendanceStatus.clear();
      for (final student in students) {
        final studentId = student['id'];
        final data =
            weeklyData[studentId] ??
            {'present': 0, 'absent': 0, 'late': 0, 'excused': 0};

        attendanceStatus[studentId] = {'weekly_data': data, 'total_days': 7};
      }
    } catch (e) {
      print('❌ Load weekly attendance error: $e');
    }
  }

  Future<void> _loadMonthlyAttendance(String classId) async {
    try {
      final monthStart = DateTime(
        selectedMonthYear.value.year,
        selectedMonthYear.value.month,
        1,
      );
      final monthEnd = DateTime(
        selectedMonthYear.value.year,
        selectedMonthYear.value.month + 1,
        0,
      );

      final response = await _supabase
          .from('attendance_students')
          .select('*')
          .eq('class_id', classId)
          .gte('attendance_date', monthStart.toIso8601String().split('T')[0])
          .lte('attendance_date', monthEnd.toIso8601String().split('T')[0]);

      final Map<String, Map<String, dynamic>> monthlyData = {};

      for (final record in response) {
        final studentId = record['student_id'];
        if (!monthlyData.containsKey(studentId)) {
          monthlyData[studentId] = {
            'present': 0,
            'absent': 0,
            'late': 0,
            'excused': 0,
          };
        }

        final status = record['status'];
        if (monthlyData[studentId]!.containsKey(status)) {
          monthlyData[studentId]![status]++;
        }
      }

      attendanceStatus.clear();
      for (final student in students) {
        final studentId = student['id'];
        final data =
            monthlyData[studentId] ??
            {'present': 0, 'absent': 0, 'late': 0, 'excused': 0};

        attendanceStatus[studentId] = {
          'monthly_data': data,
          'total_days': monthEnd.day,
        };
      }

      if (viewMode.value == 'calendar') {
        _processCalendarData(response);
      }
    } catch (e) {
      print('❌ Load monthly attendance error: $e');
    }
  }

  void _processCalendarData(List<dynamic> records) {
    calendarAttendance.clear();

    for (final record in records) {
      final date = DateTime.parse(record['attendance_date']);
      final normalizedDate = DateTime(date.year, date.month, date.day);

      if (!calendarAttendance.containsKey(normalizedDate)) {
        calendarAttendance[normalizedDate] = [];
      }

      calendarAttendance[normalizedDate]!.add({
        'student_id': record['student_id'],
        'status': record['status'],
      });
    }
  }

  // ==================== MARK ATTENDANCE ====================
Future<void> markAttendance(
  String studentId,
  String status, {
  TimeOfDay? arrivalTime,
  String? notes,
}) async {
  try {
    final classId = selectedClassId.value;
    if (classId == null) {
      print('⚠️ Class ID is null');
      return;
    }

    // BU QISMNI OLIB TASHLANG:
    // final userId = _supabase.auth.currentUser?.id;
    // if (userId == null) {
    //   print('⚠️ User not authenticated');
    //   return;
    // }

    final data = {
      'student_id': studentId,
      'class_id': classId,
      'branch_id': selectedBranchId.value,
      'attendance_date': selectedDate.value.toIso8601String().split('T')[0],
      'status': status,
      'session_id': null,
      'arrival_time': arrivalTime != null
          ? '${arrivalTime.hour.toString().padLeft(2, '0')}:${arrivalTime.minute.toString().padLeft(2, '0')}:00'
          : null,
      'notes': notes,
      // 'marked_by': userId, // -> BUNING HAM KERAGI YO'Q, OLING
      'marked_at': DateTime.now().toIso8601String(),
    };

    print('💾 Saving attendance: $data');

    await _supabase
        .from('attendance_students')
        .upsert(
          data,
          onConflict: 'student_id,class_id,attendance_date,session_id',
        );

    // Lokal holatni yangilash
    attendanceStatus[studentId] = {
      'status': status,
      'arrival_time': arrivalTime,
      'notes': notes,
      'marked_at': DateTime.now(),
    };

    calculateStatistics();

    Get.snackbar(
      'Muvaffaqiyatli',
      'Davomat belgilandi',
      backgroundColor: Colors.green.shade100,
      snackPosition: SnackPosition.TOP,
      duration: Duration(seconds: 1),
    );

    print('✅ Attendance saved successfully');
  } catch (e) {
    print('❌ Mark attendance error: $e');
    Get.snackbar(
      'Xatolik',
      'Davomatni belgilashda xatolik: $e',
      backgroundColor: Colors.red.shade100,
      snackPosition: SnackPosition.TOP,
    );
  }
}
  // ==================== FILTERS & STATISTICS ====================
  void applyFilters() {
    var filtered = List<Map<String, dynamic>>.from(students);

    if (selectedBranchId.value != null) {
      filtered = filtered
          .where(
            (s) =>
                s['branch_name'] ==
                branches.firstWhereOrNull(
                  (b) => b['id'] == selectedBranchId.value,
                )?['name'],
          )
          .toList();
    }

    if (selectedStatus.value != null) {
      filtered = filtered.where((s) {
        final status = attendanceStatus[s['id']];
        return status != null && status['status'] == selectedStatus.value;
      }).toList();
    }

    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filtered = filtered.where((s) {
        return s['name'].toString().toLowerCase().contains(query) ||
            s['phone'].toString().toLowerCase().contains(query) ||
            s['parent_phone'].toString().toLowerCase().contains(query);
      }).toList();
    }

    filteredStudents.value = filtered;
  }

  void calculateStatistics() {
    int present = 0, absent = 0, late = 0, excused = 0;

    for (final student in filteredStudents) {
      final status = attendanceStatus[student['id']];
      if (status != null) {
        switch (status['status']) {
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
    }

    presentCount.value = present;
    absentCount.value = absent;
    lateCount.value = late;
    excusedCount.value = excused;

    final total = filteredStudents.length;
    attendancePercentage.value = total > 0
        ? ((present + excused) / total) * 100
        : 0;
  }

  void _resetStatistics() {
    totalStudents.value = 0;
    presentCount.value = 0;
    absentCount.value = 0;
    lateCount.value = 0;
    excusedCount.value = 0;
    attendancePercentage.value = 0;
  }

  Map<String, dynamic>? getAttendanceForStudent(String studentId) {
    return attendanceStatus[studentId];
  }

  // ==================== BULK ACTIONS ====================
  Future<void> markAllPresent() async {
    try {
      for (final student in filteredStudents) {
        await markAttendance(student['id'], 'present');
      }
      Get.snackbar(
        'Muvaffaqiyatli',
        'Barcha o\'quvchilar "Keldi" deb belgilandi',
        backgroundColor: Colors.green.shade100,
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      Get.snackbar(
        'Xatolik',
        'Xatolik yuz berdi',
        backgroundColor: Colors.red.shade100,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  Future<void> autoMarkAbsent() async {
    try {
      int count = 0;
      for (final student in filteredStudents) {
        final status = attendanceStatus[student['id']];
        if (status == null || status['status'] == 'not_marked') {
          await markAttendance(student['id'], 'absent');
          count++;
        }
      }
      Get.snackbar(
        'Muvaffaqiyatli',
        '$count ta o\'quvchi "Kelmadi" deb belgilandi',
        backgroundColor: Colors.green.shade100,
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      Get.snackbar(
        'Xatolik',
        'Xatolik yuz berdi',
        backgroundColor: Colors.red.shade100,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  Future<void> editAttendance(
    String studentId,
    Map<String, dynamic> currentData,
  ) async {
    final result = await Get.dialog<Map<String, dynamic>>(
      AlertDialog(
        title: Text('Davomatni tahrirlash'),
        content: _AttendanceEditDialog(currentData: currentData),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Bekor qilish')),
          ElevatedButton(
            onPressed: () => Get.back(result: currentData),
            child: Text('Saqlash'),
          ),
        ],
      ),
    );

    if (result != null) {
      await markAttendance(
        studentId,
        result['status'],
        arrivalTime: result['arrival_time'],
        notes: result['notes'],
      );
    }
  }

  // ==================== EXPORT ====================
  Future<void> exportToExcel() async {
    Get.snackbar(
      'Ma\'lumot',
      'Excel export tez orada qo\'shiladi',
      backgroundColor: Colors.blue.shade100,
      snackPosition: SnackPosition.TOP,
    );
  }

  Future<void> exportToPDF() async {
    try {
      final pdf = pw.Document();
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (context) => [
            pw.Header(
              level: 0,
              child: pw.Text(
                'O\'QUVCHILAR DAVOMATI',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              'Sana: ${DateFormat('dd.MM.yyyy').format(selectedDate.value)}',
            ),
            pw.Text(
              'Sinf: ${classes.firstWhereOrNull((c) => c['id'] == selectedClassId.value)?['name'] ?? ''}',
            ),
            pw.SizedBox(height: 20),
            pw.Table.fromTextArray(
              headers: ['№', 'F.I.Sh', 'Telefon', 'Holat'],
              data: filteredStudents.asMap().entries.map((entry) {
                final index = entry.key + 1;
                final student = entry.value;
                final status = attendanceStatus[student['id']];
                return [
                  index.toString(),
                  student['name'],
                  student['phone'],
                  _getStatusText(status?['status'] ?? 'not_marked'),
                ];
              }).toList(),
            ),
          ],
        ),
      );
      await Printing.layoutPdf(onLayout: (format) async => pdf.save());
    } catch (e) {
      print('❌ Export to PDF error: $e');
      Get.snackbar(
        'Xatolik',
        'PDF faylni yaratishda xatolik',
        backgroundColor: Colors.red.shade100,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'present':
        return 'Keldi';
      case 'absent':
        return 'Kelmadi';
      case 'late':
        return 'Kechikdi';
      case 'excused':
        return 'Sababli';
      default:
        return 'Belgilanmagan';
    }
  }
}

// Edit dialog widget
class _AttendanceEditDialog extends StatefulWidget {
  final Map<String, dynamic> currentData;

  const _AttendanceEditDialog({required this.currentData});

  @override
  State<_AttendanceEditDialog> createState() => _AttendanceEditDialogState();
}

class _AttendanceEditDialogState extends State<_AttendanceEditDialog> {
  late String selectedStatus;
  late TextEditingController notesController;
  TimeOfDay? arrivalTime;

  @override
  void initState() {
    super.initState();
    selectedStatus = widget.currentData['status'] ?? 'present';
    notesController = TextEditingController(
      text: widget.currentData['notes'] ?? '',
    );
    arrivalTime = widget.currentData['arrival_time'];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DropdownButtonFormField<String>(
          value: selectedStatus,
          decoration: InputDecoration(labelText: 'Holat'),
          items: [
            DropdownMenuItem(value: 'present', child: Text('Keldi')),
            DropdownMenuItem(value: 'absent', child: Text('Kelmadi')),
            DropdownMenuItem(value: 'late', child: Text('Kechikdi')),
            DropdownMenuItem(value: 'excused', child: Text('Sababli')),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() => selectedStatus = value);
              widget.currentData['status'] = value;
            }
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
          onChanged: (value) => widget.currentData['notes'] = value,
        ),
      ],
    );
  }

  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }
}
