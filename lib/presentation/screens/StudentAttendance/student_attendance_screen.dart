// lib/presentation/screens/attendance/perfect_student_attendance_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_1/presentation/controllers/student_attandence_controller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../config/constants.dart';
import '../../../config/app_routes.dart';
import '../../widgets/sidebar.dart';

class PerfectStudentAttendanceScreen extends StatelessWidget {
  PerfectStudentAttendanceScreen({Key? key}) : super(key: key);

  final controller = Get.put(StudentAttendanceController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundLight,
      body: Row(
        children: [
          Sidebar(),
          Expanded(
            child: Column(
              children: [
                _buildHeader(),
                _buildViewModeSelector(),
                _buildFiltersAndStats(),
                Expanded(child: _buildContent()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== HEADER ====================
  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF667eea).withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.checklist_rounded, color: Colors.white, size: 36),
          ),
          SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'O\'quvchilar Davomati',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 4),
                Obx(
                  () => Text(
                    DateFormat(
                      'dd MMMM yyyy, EEEE',
                      'uz',
                    ).format(controller.selectedDate.value),
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          _buildQuickActions(),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        _buildActionButton(
          'Hammasini belgilash',
          Icons.check_circle,
          Color(0xFF06D6A0),
          controller.markAllPresent,
        ),
        SizedBox(width: 12),
        _buildActionButton(
          'Kelmaganlar',
          Icons.cancel,
          Color(0xFFFF6B6B),
          controller.autoMarkAbsent,
        ),
        SizedBox(width: 12),
        PopupMenuButton<String>(
          icon: Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.download, color: Colors.white),
          ),
          onSelected: (value) {
            if (value == 'excel')
              controller.exportToExcel();
            else if (value == 'pdf')
              controller.exportToPDF();
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'excel',
              child: Row(
                children: [
                  Icon(Icons.table_chart, color: Colors.green, size: 20),
                  SizedBox(width: 12),
                  Text('Excel yuklab olish'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'pdf',
              child: Row(
                children: [
                  Icon(Icons.picture_as_pdf, color: Colors.red, size: 20),
                  SizedBox(width: 12),
                  Text('PDF yuklab olish'),
                ],
              ),
            ),
          ],
        ),
        SizedBox(width: 12),
        IconButton(
          onPressed: controller.loadAttendanceData,
          icon: Icon(Icons.refresh, color: Colors.white),
          tooltip: 'Yangilash',
          style: IconButton.styleFrom(
            backgroundColor: Colors.white.withOpacity(0.2),
            padding: EdgeInsets.all(12),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 20),
      label: Text(label, style: TextStyle(fontWeight: FontWeight.w600)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: color,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ==================== VIEW MODE SELECTOR ====================
  Widget _buildViewModeSelector() {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppConstants.paddingLarge,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Obx(
        () => Row(
          children: [
            _buildViewModeTab('Kunlik', 'daily', Icons.today),
            _buildViewModeTab('Haftalik', 'weekly', Icons.calendar_view_week),
            _buildViewModeTab('Oylik', 'monthly', Icons.calendar_month),
            _buildViewModeTab('Kalendar', 'calendar', Icons.calendar_today),
          ],
        ),
      ),
    );
  }

  Widget _buildViewModeTab(String label, String mode, IconData icon) {
    final isSelected = controller.viewMode.value == mode;
    return Expanded(
      child: InkWell(
        onTap: () {
          controller.viewMode.value = mode;
          controller.loadAttendanceData();
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(colors: [Color(0xFF667eea), Color(0xFF764ba2)])
                : null,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey[600],
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[600],
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== FILTERS AND STATS ====================
  Widget _buildFiltersAndStats() {
    return Container(
      padding: EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        children: [
          // Date selector and filters
          Row(
            children: [
              Obx(
                () => controller.viewMode.value == 'daily'
                    ? _buildDateSelector()
                    : controller.viewMode.value == 'calendar' ||
                          controller.viewMode.value == 'monthly'
                    ? _buildMonthSelector()
                    : _buildWeekSelector(),
              ),
              SizedBox(width: 16),
              _buildClassDropdown(),
              SizedBox(width: 16),
              _buildBranchFilter(),
              SizedBox(width: 16),
              _buildStatusFilter(),
              SizedBox(width: 16),
              Expanded(child: _buildSearchField()),
            ],
          ),
          SizedBox(height: 20),
          _buildStatisticsCards(),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return Row(
      children: [
        IconButton(
          onPressed: () {
            controller.selectedDate.value = controller.selectedDate.value
                .subtract(Duration(days: 1));
            controller.loadAttendanceData();
          },
          icon: Icon(Icons.chevron_left, size: 28),
          tooltip: 'Oldingi kun',
          style: IconButton.styleFrom(
            backgroundColor: Colors.grey.shade100,
            padding: EdgeInsets.all(12),
          ),
        ),
        SizedBox(width: 12),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: Get.context!,
              initialDate: controller.selectedDate.value,
              firstDate: DateTime(2020),
              lastDate: DateTime.now().add(Duration(days: 1)),
            );
            if (date != null) {
              controller.selectedDate.value = date;
              controller.loadAttendanceData();
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF667eea).withOpacity(0.3),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.white, size: 22),
                SizedBox(width: 12),
                Obx(
                  () => Text(
                    DateFormat(
                      'dd.MM.yyyy',
                    ).format(controller.selectedDate.value),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 12),
        IconButton(
          onPressed: () {
            if (controller.selectedDate.value.isBefore(DateTime.now())) {
              controller.selectedDate.value = controller.selectedDate.value.add(
                Duration(days: 1),
              );
              controller.loadAttendanceData();
            }
          },
          icon: Icon(Icons.chevron_right, size: 28),
          tooltip: 'Keyingi kun',
          style: IconButton.styleFrom(
            backgroundColor: Colors.grey.shade100,
            padding: EdgeInsets.all(12),
          ),
        ),
        SizedBox(width: 16),
        TextButton.icon(
          onPressed: () {
            controller.selectedDate.value = DateTime.now();
            controller.loadAttendanceData();
          },
          icon: Icon(Icons.today, size: 20),
          label: Text('Bugun', style: TextStyle(fontWeight: FontWeight.w600)),
          style: TextButton.styleFrom(
            foregroundColor: Color(0xFF667eea),
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildMonthSelector() {
    return Row(
      children: [
        IconButton(
          onPressed: () {
            controller.selectedMonthYear.value = DateTime(
              controller.selectedMonthYear.value.year,
              controller.selectedMonthYear.value.month - 1,
            );
            controller.loadAttendanceData();
          },
          icon: Icon(Icons.chevron_left),
          style: IconButton.styleFrom(
            backgroundColor: Colors.grey.shade100,
            padding: EdgeInsets.all(12),
          ),
        ),
        SizedBox(width: 12),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: Get.context!,
              initialDate: controller.selectedMonthYear.value,
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
              initialDatePickerMode: DatePickerMode.year,
            );
            if (date != null) {
              controller.selectedMonthYear.value = date;
              controller.loadAttendanceData();
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_month, color: Colors.white, size: 22),
                SizedBox(width: 12),
                Obx(
                  () => Text(
                    DateFormat(
                      'MMMM yyyy',
                      'uz',
                    ).format(controller.selectedMonthYear.value),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 12),
        IconButton(
          onPressed: () {
            final next = DateTime(
              controller.selectedMonthYear.value.year,
              controller.selectedMonthYear.value.month + 1,
            );
            if (next.isBefore(DateTime.now()) ||
                next.month == DateTime.now().month) {
              controller.selectedMonthYear.value = next;
              controller.loadAttendanceData();
            }
          },
          icon: Icon(Icons.chevron_right),
          style: IconButton.styleFrom(
            backgroundColor: Colors.grey.shade100,
            padding: EdgeInsets.all(12),
          ),
        ),
      ],
    );
  }

  Widget _buildWeekSelector() {
    return Row(
      children: [
        IconButton(
          onPressed: () {
            controller.selectedDate.value = controller.selectedDate.value
                .subtract(Duration(days: 7));
            controller.loadAttendanceData();
          },
          icon: Icon(Icons.chevron_left),
          style: IconButton.styleFrom(
            backgroundColor: Colors.grey.shade100,
            padding: EdgeInsets.all(12),
          ),
        ),
        SizedBox(width: 12),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.calendar_view_week, color: Colors.white, size: 22),
              SizedBox(width: 12),
              Obx(() {
                final weekStart = controller.getWeekStart(
                  controller.selectedDate.value,
                );
                final weekEnd = weekStart.add(Duration(days: 6));
                return Text(
                  '${DateFormat('dd.MM').format(weekStart)} - ${DateFormat('dd.MM.yyyy').format(weekEnd)}',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                );
              }),
            ],
          ),
        ),
        SizedBox(width: 12),
        IconButton(
          onPressed: () {
            controller.selectedDate.value = controller.selectedDate.value.add(
              Duration(days: 7),
            );
            controller.loadAttendanceData();
          },
          icon: Icon(Icons.chevron_right),
          style: IconButton.styleFrom(
            backgroundColor: Colors.grey.shade100,
            padding: EdgeInsets.all(12),
          ),
        ),
      ],
    );
  }

  Widget _buildClassDropdown() {
    return Obx(
      () => Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey.shade50,
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String?>(
            value: controller.selectedClassId.value,
            hint: Text('Sinf tanlang'),
            items: controller.classes.map((classItem) {
              return DropdownMenuItem<String?>(
                value: classItem['id'],
                child: Row(
                  children: [
                    Icon(Icons.class_, size: 18),
                    SizedBox(width: 8),
                    Text('${classItem['name']} - ${classItem['level_name']}'),
                  ],
                ),
              );
            }).toList(),
            onChanged: controller.changeClass,
          ),
        ),
      ),
    );
  }

  Widget _buildBranchFilter() {
    return Obx(
      () => Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey.shade50,
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String?>(
            value: controller.selectedBranchId.value,
            hint: Text('Barcha filiallar'),
            items: [
              DropdownMenuItem(value: null, child: Text('Barcha filiallar')),
              ...controller.branches.map(
                (b) => DropdownMenuItem(value: b['id'], child: Text(b['name'])),
              ),
            ],
            onChanged: (val) {
              controller.selectedBranchId.value = val;
              controller.applyFilters();
              controller.calculateStatistics();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStatusFilter() {
    return Obx(
      () => Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey.shade50,
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String?>(
            value: controller.selectedStatus.value,
            hint: Text('Barcha holatlar'),
            items: [
              DropdownMenuItem(value: null, child: Text('Barcha holatlar')),
              DropdownMenuItem(
                value: 'present',
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Color(0xFF06D6A0),
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Text('Kelgan'),
                  ],
                ),
              ),
              DropdownMenuItem(
                value: 'absent',
                child: Row(
                  children: [
                    Icon(Icons.cancel, color: Color(0xFFFF6B6B), size: 18),
                    SizedBox(width: 8),
                    Text('Kelmagan'),
                  ],
                ),
              ),
              DropdownMenuItem(
                value: 'late',
                child: Row(
                  children: [
                    Icon(Icons.access_time, color: Color(0xFFFFC857), size: 18),
                    SizedBox(width: 8),
                    Text('Kechikkan'),
                  ],
                ),
              ),
              DropdownMenuItem(
                value: 'excused',
                child: Row(
                  children: [
                    Icon(Icons.event_note, color: Colors.blue, size: 18),
                    SizedBox(width: 8),
                    Text('Sababli'),
                  ],
                ),
              ),
            ],
            onChanged: (val) {
              controller.selectedStatus.value = val;
              controller.applyFilters();
              controller.calculateStatistics();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      onChanged: (val) {
        controller.searchQuery.value = val;
        controller.applyFilters();
        controller.calculateStatistics();
      },
      decoration: InputDecoration(
        hintText: 'Ism, telefon yoki ota-ona telefoni bo\'yicha qidirish...',
        prefixIcon: Icon(Icons.search, color: Color(0xFF667eea)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFF667eea), width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildStatisticsCards() {
    return Obx(
      () => Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Jami o\'quvchilar',
              controller.totalStudents.toString(),
              Icons.people,
              Color(0xFF667eea),
              null,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Kelgan',
              controller.presentCount.toString(),
              Icons.check_circle,
              Color(0xFF06D6A0),
              '${controller.presentCount.value > 0 ? ((controller.presentCount.value / controller.totalStudents.value) * 100).toStringAsFixed(1) : 0}%',
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Kelmagan',
              controller.absentCount.toString(),
              Icons.cancel,
              Color(0xFFFF6B6B),
              '${controller.absentCount.value > 0 ? ((controller.absentCount.value / controller.totalStudents.value) * 100).toStringAsFixed(1) : 0}%',
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Kechikkan',
              controller.lateCount.toString(),
              Icons.access_time,
              Color(0xFFFFC857),
              null,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Sababli',
              controller.excusedCount.toString(),
              Icons.event_note,
              Colors.blue,
              null,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Davomat %',
              '${controller.attendancePercentage.value.toStringAsFixed(1)}%',
              Icons.analytics,
              Color(0xFF06D6A0),
              null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String? subtitle,
  ) {
    return Container(
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              Spacer(),
              Text(
                value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: color,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (subtitle != null) ...[
            SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ],
        ],
      ),
    );
  }

  // ==================== CONTENT ====================
  Widget _buildContent() {
    return Obx(() {
      if (controller.viewMode.value == 'calendar') {
        return _buildCalendarView();
      }
      return _buildListView();
    });
  }

  Widget _buildListView() {
    return Obx(() {
      if (controller.isLoading.value) {
        return Center(child: CircularProgressIndicator());
      }

      if (controller.selectedClassId.value == null) {
        return _buildEmptyState('Iltimos, avval sinf tanlang', Icons.class_);
      }

      if (controller.filteredStudents.isEmpty) {
        return _buildEmptyState('O\'quvchilar topilmadi', Icons.people_outline);
      }

      return ListView.builder(
        padding: EdgeInsets.all(AppConstants.paddingLarge),
        itemCount: controller.filteredStudents.length,
        itemBuilder: (context, index) {
          final student = controller.filteredStudents[index];
          return _buildStudentCard(student);
        },
      );
    });
  }

  Widget _buildCalendarView() {
    return Column(
      children: [
        Obx(
          () => TableCalendar(
            firstDay: DateTime(2020),
            lastDay: DateTime.now().add(Duration(days: 365)),
            focusedDay: controller.selectedMonthYear.value,
            calendarFormat: CalendarFormat.month,
            selectedDayPredicate: (day) =>
                isSameDay(day, controller.selectedDate.value),
            onDaySelected: (selected, focused) {
              controller.selectedDate.value = selected;
              controller.loadAttendanceData();
            },
            eventLoader: (day) {
              final normalized = DateTime(day.year, day.month, day.day);
              return controller.calendarAttendance[normalized] ?? [];
            },
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Color(0xFF667eea).withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Color(0xFF667eea),
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(
                color: Color(0xFF06D6A0),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
        Expanded(child: _buildListView()),
      ],
    );
  }

  Widget _buildStudentCard(Map<String, dynamic> student) {
    final attendance = controller.getAttendanceForStudent(student['id']);
    final status = attendance?['status'] ?? 'not_marked';
    final statusColor = _getStatusColor(status);

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 3,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => Get.toNamed(
          AppRoutes.studentDetail,
          arguments: {'studentId': student['id']},
        ),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Row(
            children: [
              // Avatar with status indicator
              Stack(
                children: [
                  Hero(
                    tag: 'student_${student['id']}',
                    child: CircleAvatar(
                      radius: 36,
                      backgroundColor: Color(0xFF667eea).withOpacity(0.1),
                      backgroundImage: student['photo_url'] != null
                          ? NetworkImage(student['photo_url'])
                          : null,
                      child: student['photo_url'] == null
                          ? Text(
                              student['name']
                                  .toString()
                                  .split(' ')
                                  .map((e) => e[0])
                                  .take(2)
                                  .join()
                                  .toUpperCase(),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF667eea),
                              ),
                            )
                          : null,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: statusColor.withOpacity(0.5),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Icon(
                        _getStatusIcon(status),
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(width: 20),

              // Student Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            student['name'],
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.phone, size: 14, color: Colors.grey[600]),
                        SizedBox(width: 6),
                        Text(
                          student['phone'].isNotEmpty
                              ? student['phone']
                              : 'Telefon yo\'q',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                        if (student['parent_phone'].isNotEmpty) ...[
                          SizedBox(width: 12),
                          Icon(
                            Icons.family_restroom,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          SizedBox(width: 6),
                          Text(
                            student['parent_phone'],
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 6),
                    Row(
                      children: [
                        if (student['class_level'].isNotEmpty) ...[
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              student['class_level'],
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                        ],
                        if (student['branch_name'].isNotEmpty) ...[
                          Icon(
                            Icons.business,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          SizedBox(width: 4),
                          Text(
                            student['branch_name'],
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (attendance != null &&
                        attendance['arrival_time'] != null) ...[
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Kelish: ${attendance['arrival_time']}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (attendance != null &&
                        attendance['notes'] != null &&
                        attendance['notes'].isNotEmpty) ...[
                      SizedBox(height: 6),
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.note, size: 14, color: Colors.grey[700]),
                            SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                attendance['notes'],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Status and Actions
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: statusColor.withOpacity(0.4),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getStatusIcon(status),
                          size: 18,
                          color: statusColor,
                        ),
                        SizedBox(width: 8),
                        Text(
                          _getStatusText(status),
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      if (status == 'not_marked') ...[
                        _buildQuickActionButton(
                          'Keldi',
                          Icons.check,
                          Color(0xFF06D6A0),
                          () => controller.markAttendance(
                            student['id'],
                            'present',
                          ),
                        ),
                        _buildQuickActionButton(
                          'Kechikdi',
                          Icons.access_time,
                          Color(0xFFFFC857),
                          () =>
                              controller.markAttendance(student['id'], 'late'),
                        ),
                        _buildQuickActionButton(
                          'Kelmadi',
                          Icons.cancel,
                          Color(0xFFFF6B6B),
                          () => controller.markAttendance(
                            student['id'],
                            'absent',
                          ),
                        ),
                      ],
                      if (status != 'not_marked')
                        _buildQuickActionButton(
                          'Tahrirlash',
                          Icons.edit,
                          Color(0xFF667eea),
                          () => controller.editAttendance(
                            student['id'],
                            attendance!,
                          ),
                        ),
                      IconButton(
                        onPressed: () => Get.toNamed(
                          AppRoutes.studentDetail,
                          arguments: {'studentId': student['id']},
                        ),
                        icon: Icon(Icons.open_in_new, size: 18),
                        tooltip: 'Profilni ko\'rish',
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.grey.shade100,
                          padding: EdgeInsets.all(10),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 100, color: Colors.grey.shade300),
          SizedBox(height: 24),
          Text(
            message,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Ma\'lumotlar yuklanishi uchun filtrlarni tanlang',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 15),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ==================== HELPER FUNCTIONS ====================

  Color _getStatusColor(String status) {
    switch (status) {
      case 'present':
        return Color(0xFF06D6A0);
      case 'absent':
        return Color(0xFFFF6B6B);
      case 'late':
        return Color(0xFFFFC857);
      case 'excused':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'present':
        return Icons.check_circle;
      case 'absent':
        return Icons.cancel;
      case 'late':
        return Icons.access_time;
      case 'excused':
        return Icons.event_note;
      default:
        return Icons.help_outline;
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
