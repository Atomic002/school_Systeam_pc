// lib/presentation/screens/StaffAttendance/enhanced_staff_attendance_screen.dart
// MUKAMMAL XODIMLAR DAVOMATI EKRANI

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../config/constants.dart';
import '../../../config/app_routes.dart';
import '../../controllers/staff_attandance.dart';
import '../../widgets/sidebar.dart';
import 'package:table_calendar/table_calendar.dart';

class EnhancedStaffAttendanceScreen extends StatelessWidget {
  EnhancedStaffAttendanceScreen({Key? key}) : super(key: key);

  final controller = Get.put(EnhancedStaffAttendanceController());

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
          colors: [Colors.white, Colors.blue.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppConstants.primaryColor,
                  AppConstants.primaryColor.withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppConstants.primaryColor.withOpacity(0.3),
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Icon(Icons.how_to_reg, color: Colors.white, size: 36),
          ),
          SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Xodimlar Davomati',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: AppConstants.textPrimaryColor,
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
                      color: AppConstants.textSecondaryColor,
                      fontSize: 15,
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

  // ==================== QUICK ACTIONS ====================
  Widget _buildQuickActions() {
    return Row(
      children: [
        _buildActionButton(
          'Hammasini belgilash',
          Icons.check_circle,
          AppConstants.successColor,
          controller.markAllPresent,
        ),
        SizedBox(width: 12),
        _buildActionButton(
          'Kelmaganlar',
          Icons.cancel,
          AppConstants.errorColor,
          controller.autoMarkAbsent,
        ),
        SizedBox(width: 12),
        PopupMenuButton<String>(
          icon: Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppConstants.infoColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppConstants.infoColor.withOpacity(0.3),
              ),
            ),
            child: Icon(Icons.download, color: AppConstants.infoColor),
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
          icon: Icon(Icons.refresh),
          tooltip: 'Yangilash',
          style: IconButton.styleFrom(
            backgroundColor: Colors.grey.shade100,
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
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        elevation: 4,
        shadowColor: color.withOpacity(0.5),
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
            color: isSelected ? AppConstants.primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected
                    ? Colors.white
                    : AppConstants.textSecondaryColor,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : AppConstants.textSecondaryColor,
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
              _buildBranchFilter(),
              SizedBox(width: 16),
              _buildSalaryTypeFilter(),
              SizedBox(width: 16),
              _buildStatusFilter(),
              SizedBox(width: 16),
              Obx(
                () => FilterChip(
                  label: Text('Faqat o\'qituvchilar'),
                  selected: controller.showOnlyTeachers.value,
                  onSelected: (val) {
                    controller.showOnlyTeachers.value = val;
                    controller.applyFilters();
                    controller.calculateStatistics();
                  },
                  selectedColor: AppConstants.primaryColor.withOpacity(0.2),
                  checkmarkColor: AppConstants.primaryColor,
                ),
              ),
              SizedBox(width: 16),
              Expanded(child: _buildSearchField()),
            ],
          ),
          SizedBox(height: 20),
          // Statistics cards
          _buildStatisticsCards(),
        ],
      ),
    );
  }

  // ==================== DATE SELECTOR ====================
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
                colors: [
                  AppConstants.primaryColor,
                  AppConstants.primaryColor.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppConstants.primaryColor.withOpacity(0.3),
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
            foregroundColor: AppConstants.primaryColor,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
      ],
    );
  }

  // ==================== MONTH SELECTOR ====================
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
        ),
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
              color: AppConstants.primaryColor,
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
        ),
      ],
    );
  }

  // ==================== WEEK SELECTOR ====================
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
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: BoxDecoration(
            color: AppConstants.primaryColor,
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
        IconButton(
          onPressed: () {
            controller.selectedDate.value = controller.selectedDate.value.add(
              Duration(days: 7),
            );
            controller.loadAttendanceData();
          },
          icon: Icon(Icons.chevron_right),
        ),
      ],
    );
  }

  // ==================== FILTERS ====================
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

  Widget _buildSalaryTypeFilter() {
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
            value: controller.selectedSalaryType.value,
            hint: Text('Maosh turi'),
            items: [
              DropdownMenuItem(value: null, child: Text('Barcha turlar')),
              DropdownMenuItem(value: 'monthly', child: Text('Oylik')),
              DropdownMenuItem(value: 'hourly', child: Text('Soatlik')),
              DropdownMenuItem(value: 'daily', child: Text('Kunlik')),
            ],
            onChanged: (val) {
              controller.selectedSalaryType.value = val;
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
            hint: Text('Holat'),
            items: [
              DropdownMenuItem(value: null, child: Text('Barcha holatlar')),
              DropdownMenuItem(
                value: 'present',
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: AppConstants.successColor,
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
                    Icon(
                      Icons.cancel,
                      color: AppConstants.errorColor,
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Text('Kelmagan'),
                  ],
                ),
              ),
              DropdownMenuItem(
                value: 'late',
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      color: AppConstants.warningColor,
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Text('Kechikkan'),
                  ],
                ),
              ),
              DropdownMenuItem(
                value: 'leave',
                child: Row(
                  children: [
                    Icon(
                      Icons.beach_access,
                      color: AppConstants.infoColor,
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Text('Ta\'tilda'),
                  ],
                ),
              ),
              DropdownMenuItem(
                value: 'half_day',
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time_filled,
                      color: Colors.orange,
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Text('Yarim kun'),
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
        hintText: 'Ism, telefon yoki lavozim bo\'yicha qidirish...',
        prefixIcon: Icon(Icons.search, color: AppConstants.primaryColor),
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
          borderSide: BorderSide(color: AppConstants.primaryColor, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  // ==================== STATISTICS CARDS ====================
  Widget _buildStatisticsCards() {
    return Obx(
      () => Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Jami xodimlar',
              controller.totalStaff.toString(),
              Icons.people,
              AppConstants.primaryColor,
              null,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Kelgan',
              controller.presentCount.toString(),
              Icons.check_circle,
              AppConstants.successColor,
              '${controller.presentCount.value > 0 ? ((controller.presentCount.value / controller.totalStaff.value) * 100).toStringAsFixed(1) : 0}%',
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Kelmagan',
              controller.absentCount.toString(),
              Icons.cancel,
              AppConstants.errorColor,
              '${controller.absentCount.value > 0 ? ((controller.absentCount.value / controller.totalStaff.value) * 100).toStringAsFixed(1) : 0}%',
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Kechikkan',
              controller.lateCount.toString(),
              Icons.access_time,
              AppConstants.warningColor,
              null,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Ta\'tilda',
              controller.leaveCount.toString(),
              Icons.beach_access,
              AppConstants.infoColor,
              null,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Davomat %',
              '${controller.attendancePercentage.value.toStringAsFixed(1)}%',
              Icons.analytics,
              AppConstants.successColor,
              controller.totalHoursWorked.value > 0
                  ? '${controller.totalHoursWorked.value.toStringAsFixed(1)} soat'
                  : null,
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

  // ==================== LIST VIEW ====================
  Widget _buildListView() {
    return Obx(() {
      if (controller.isLoading.value) {
        return Center(child: CircularProgressIndicator());
      }

      if (controller.filteredStaff.isEmpty) {
        return _buildEmptyState();
      }

      return ListView.builder(
        padding: EdgeInsets.all(AppConstants.paddingLarge),
        itemCount: controller.filteredStaff.length,
        itemBuilder: (context, index) {
          final staff = controller.filteredStaff[index];
          return _buildStaffCard(staff);
        },
      );
    });
  }

  // ==================== CALENDAR VIEW ====================
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
              return controller.calendarAttendance[day] ?? [];
            },
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: AppConstants.primaryColor.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: AppConstants.primaryColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
        Expanded(child: _buildListView()),
      ],
    );
  }

  // ==================== STAFF CARD ====================
  Widget _buildStaffCard(Map<String, dynamic> staff) {
    final attendance = controller.getAttendanceForStaff(staff['id']);
    final status = attendance?['status'] ?? 'not_marked';
    final statusColor = _getStatusColor(status);
    final salaryType = staff['salary_type'] ?? 'monthly';

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 3,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => Get.toNamed(
          AppRoutes.staffDetail,
          arguments: {'staffId': staff['id']},
        ),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Row(
            children: [
              // Avatar
              Stack(
                children: [
                  Hero(
                    tag: 'staff_${staff['id']}',
                    child: CircleAvatar(
                      radius: 36,
                      backgroundColor: AppConstants.primaryColor.withOpacity(
                        0.1,
                      ),
                      backgroundImage: staff['photo_url'] != null
                          ? NetworkImage(staff['photo_url'])
                          : null,
                      child: staff['photo_url'] == null
                          ? Text(
                              '${staff['first_name'][0]}${staff['last_name'][0]}'
                                  .toUpperCase(),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppConstants.primaryColor,
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

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${staff['first_name']} ${staff['last_name']}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppConstants.textPrimaryColor,
                            ),
                          ),
                        ),
                        if (staff['is_teacher'] == true)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppConstants.successColor.withOpacity(
                                0.15,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.school,
                                  size: 14,
                                  color: AppConstants.successColor,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'O\'qituvchi',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppConstants.successColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.badge,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        SizedBox(width: 6),
                        Text(
                          staff['position'] ?? 'N/A',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(width: 12),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            controller.getSalaryTypeText(salaryType),
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (staff['branches'] != null) ...[
                      SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.business,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                          SizedBox(width: 6),
                          Text(
                            staff['branches']['name'] ?? 'N/A',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (attendance != null) ...[
                      SizedBox(height: 10),
                      Row(
                        children: [
                          if (attendance['check_in_time'] != null) ...[
                            _buildTimeChip(
                              Icons.login,
                              'Kirish: ${attendance['check_in_time']}',
                              AppConstants.successColor,
                            ),
                            SizedBox(width: 8),
                          ],
                          if (attendance['check_out_time'] != null) ...[
                            _buildTimeChip(
                              Icons.logout,
                              'Chiqish: ${attendance['check_out_time']}',
                              AppConstants.errorColor,
                            ),
                            SizedBox(width: 8),
                          ],
                          if (attendance['actual_hours'] != null)
                            _buildTimeChip(
                              Icons.timer,
                              '${attendance['actual_hours']} soat',
                              AppConstants.infoColor,
                            ),
                          if (attendance['late_minutes'] != null &&
                              attendance['late_minutes'] > 0) ...[
                            SizedBox(width: 8),
                            _buildTimeChip(
                              Icons.warning,
                              '${attendance['late_minutes']} daq kechikdi',
                              AppConstants.warningColor,
                            ),
                          ],
                        ],
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
                          'Kelgan',
                          Icons.check,
                          AppConstants.successColor,
                          () =>
                              controller.markAttendance(staff['id'], 'present'),
                        ),
                        _buildQuickActionButton(
                          'Kechikkan',
                          Icons.access_time,
                          AppConstants.warningColor,
                          () => controller.markAttendance(staff['id'], 'late'),
                        ),
                        _buildQuickActionButton(
                          'Kelmagan',
                          Icons.cancel,
                          AppConstants.errorColor,
                          () =>
                              controller.markAttendance(staff['id'], 'absent'),
                        ),
                      ],
                      if (status != 'not_marked')
                        _buildQuickActionButton(
                          'Tahrirlash',
                          Icons.edit,
                          AppConstants.primaryColor,
                          () => controller.editAttendance(
                            staff['id'],
                            attendance!,
                          ),
                        ),
                      IconButton(
                        onPressed: () => Get.toNamed(
                          AppRoutes.staffDetail,
                          arguments: {'staffId': staff['id']},
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

  Widget _buildTimeChip(IconData icon, String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
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

  // ==================== EMPTY STATE ====================
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 100, color: Colors.grey.shade300),
          SizedBox(height: 24),
          Text(
            'Xodimlar topilmadi',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Filtrlarni o\'zgartiring yoki yangi xodim qo\'shing',
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
        return AppConstants.successColor;
      case 'absent':
        return AppConstants.errorColor;
      case 'late':
        return AppConstants.warningColor;
      case 'leave':
      case 'sick':
        return AppConstants.infoColor;
      case 'half_day':
        return Colors.orange;
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
      case 'leave':
        return Icons.beach_access;
      case 'sick':
        return Icons.medical_services;
      case 'half_day':
        return Icons.access_time_filled;
      default:
        return Icons.help_outline;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'present':
        return 'Kelgan';
      case 'absent':
        return 'Kelmagan';
      case 'late':
        return 'Kechikkan';
      case 'leave':
        return 'Ta\'tilda';
      case 'sick':
        return 'Kasal';
      case 'half_day':
        return 'Yarim kun';
      default:
        return 'Belgilanmagan';
    }
  }
}
