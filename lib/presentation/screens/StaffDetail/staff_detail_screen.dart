// lib/presentation/screens/StaffDetail/staff_dashboard_screen.dart
// XODIM PROFILI EKRANI - TO'LIQ MA'LUMOTLAR

import 'package:flutter/material.dart';
import 'package:flutter_application_1/presentation/controllers/staff_detail_controller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../config/constants.dart';
import '../../../config/app_routes.dart';
import '../../widgets/sidebar.dart';

class StaffDashboardScreen extends StatelessWidget {
  StaffDashboardScreen({Key? key}) : super(key: key);

  final controller = Get.put(StaffDashboardController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundLight,
      body: Row(
        children: [
          Sidebar(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(child: CircularProgressIndicator());
              }

              if (controller.staff.value == null) {
                return Center(child: Text('Xodim topilmadi'));
              }

              return Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [_buildProfileSection(), _buildTabSection()],
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  // ==================== HEADER ====================
  Widget _buildHeader() {
    final staff = controller.staff.value!;

    return Container(
      padding: EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Get.back(),
            icon: Icon(Icons.arrow_back, color: AppConstants.primaryColor),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${staff['first_name']} ${staff['last_name']}',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(
                  staff['position'] ?? '',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
          ),
          _buildQuickActions(),
        ],
      ),
    );
  }

  // ==================== TEZKOR HARAKATLAR ====================
  Widget _buildQuickActions() {
    return Row(
      children: [
        IconButton(
          onPressed: controller.callStaff,
          icon: Icon(Icons.phone, color: AppConstants.successColor),
          tooltip: 'Qo\'ng\'iroq qilish',
        ),
        IconButton(
          onPressed: controller.sendMessage,
          icon: Icon(Icons.message, color: AppConstants.infoColor),
          tooltip: 'Xabar yuborish',
        ),
        IconButton(
          onPressed: controller.editStaff,
          icon: Icon(Icons.edit, color: AppConstants.primaryColor),
          tooltip: 'Tahrirlash',
        ),
        PopupMenuButton(
          icon: Icon(Icons.more_vert),
          itemBuilder: (context) => [
            PopupMenuItem(
              child: ListTile(
                leading: Icon(Icons.download),
                title: Text('Profilni yuklab olish'),
                onTap: controller.downloadProfile,
              ),
            ),
            PopupMenuItem(
              child: ListTile(
                leading: Icon(Icons.print),
                title: Text('Chop etish'),
                onTap: controller.printProfile,
              ),
            ),
            PopupMenuItem(
              child: ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('O\'chirish', style: TextStyle(color: Colors.red)),
                onTap: controller.deleteStaff,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ==================== PROFIL BO'LIMI ====================
  Widget _buildProfileSection() {
    final staff = controller.staff.value!;
    final status = staff['status'] ?? 'active';
    final statusColor = status == 'active'
        ? AppConstants.successColor
        : status == 'on_leave'
        ? AppConstants.warningColor
        : Colors.grey;

    return Container(
      margin: EdgeInsets.all(AppConstants.paddingLarge),
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppConstants.primaryColor,
            AppConstants.primaryColor.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppConstants.primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Stack(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  image: staff['photo_url'] != null
                      ? DecorationImage(
                          image: NetworkImage(staff['photo_url']),
                          fit: BoxFit.cover,
                        )
                      : null,
                  color: Colors.white.withOpacity(0.2),
                ),
                child: staff['photo_url'] == null
                    ? Center(
                        child: Text(
                          '${staff['first_name'][0]}${staff['last_name'][0]}'
                              .toUpperCase(),
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : null,
              ),
              Positioned(
                bottom: 5,
                right: 5,
                child: InkWell(
                  onTap: controller.uploadPhoto,
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      size: 20,
                      color: AppConstants.primaryColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(width: 24),

          // Ma'lumotlar
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '${staff['first_name']} ${staff['last_name']}',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 12),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        status == 'active'
                            ? 'Aktiv'
                            : status == 'on_leave'
                            ? 'Ta\'tilda'
                            : 'Noaktiv',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  staff['position'] ?? '',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                if (staff['department'] != null) ...[
                  SizedBox(height: 4),
                  Text(
                    staff['department'],
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
                SizedBox(height: 16),
                Row(
                  children: [
                    _buildProfileStat(
                      Icons.calendar_today,
                      'Ish tajribasi',
                      controller.getWorkExperience(),
                    ),
                    SizedBox(width: 24),
                    _buildProfileStat(
                      Icons.star,
                      'Reyting',
                      controller.getRating(),
                    ),
                    SizedBox(width: 24),
                    _buildProfileStat(
                      Icons.payments,
                      'Oylik maosh',
                      '${NumberFormat('#,###').format(staff['base_salary'] ?? 0)} so\'m',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== PROFIL STATISTIKA ====================
  Widget _buildProfileStat(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ==================== TAB BO'LIMI ====================
  Widget _buildTabSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge),
      child: Column(
        children: [
          _buildTabBar(),
          SizedBox(height: 16),
          Obx(() => _buildTabContent()),
        ],
      ),
    );
  }

  // ==================== TAB BAR ====================
  Widget _buildTabBar() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Row(
        children: [
          _buildTab('Umumiy', 0, Icons.info),
          _buildTab('Davomat', 1, Icons.calendar_today),
          _buildTab('Maosh', 2, Icons.payments),
          _buildTab('Darslar', 3, Icons.school),
          _buildTab('O\'quvchilar', 4, Icons.people),
          _buildTab('Hujjatlar', 5, Icons.folder),
          _buildTab('Baholash', 6, Icons.star),
        ],
      ),
    );
  }

  // ==================== TAB ====================
  Widget _buildTab(String label, int index, IconData icon) {
    return Obx(() {
      final isSelected = controller.selectedTab.value == index;
      return Expanded(
        child: InkWell(
          onTap: () => controller.selectedTab.value = index,
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? AppConstants.primaryColor
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 18,
                    color: isSelected
                        ? Colors.white
                        : AppConstants.textSecondaryColor,
                  ),
                  SizedBox(width: 6),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: isSelected
                          ? Colors.white
                          : AppConstants.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  // ==================== TAB CONTENT ====================
  Widget _buildTabContent() {
    switch (controller.selectedTab.value) {
      case 0:
        return _buildGeneralTab();
      case 1:
        return _buildAttendanceTab();
      case 2:
        return _buildSalaryTab();
      case 3:
        return _buildClassesTab();
      case 4:
        return _buildStudentsTab();
      case 5:
        return _buildDocumentsTab();
      case 6:
        return _buildEvaluationTab();
      default:
        return _buildGeneralTab();
    }
  }

  // ==================== UMUMIY MA'LUMOTLAR TAB ====================
  Widget _buildGeneralTab() {
    final staff = controller.staff.value!;

    return Column(
      children: [
        _buildInfoCard(
          title: 'Shaxsiy ma\'lumotlar',
          icon: Icons.person,
          children: [
            _buildInfoRow(
              'To\'liq ism',
              '${staff['first_name']} ${staff['middle_name'] ?? ''} ${staff['last_name']}',
            ),
            _buildInfoRow(
              'Jinsi',
              staff['gender'] == 'male' ? 'Erkak' : 'Ayol',
            ),
            _buildInfoRow('Tug\'ilgan sana', _formatDate(staff['birth_date'])),
            _buildInfoRow('Yoshi', '${controller.getAge()} yosh'),
            _buildInfoRow('Telefon', staff['phone'] ?? 'Kiritilmagan'),
            if (staff['phone_secondary'] != null)
              _buildInfoRow('Qo\'shimcha telefon', staff['phone_secondary']),
          ],
        ),
        SizedBox(height: 16),
        _buildInfoCard(
          title: 'Manzil',
          icon: Icons.location_on,
          children: [
            _buildInfoRow('Viloyat/Shahar', staff['region'] ?? 'Kiritilmagan'),
            _buildInfoRow('Tuman', staff['district'] ?? 'Kiritilmagan'),
            _buildInfoRow('To\'liq manzil', staff['address'] ?? 'Kiritilmagan'),
          ],
        ),
        SizedBox(height: 16),
        _buildInfoCard(
          title: 'Ish ma\'lumotlari',
          icon: Icons.work,
          children: [
            _buildInfoRow(
              'Filial',
              staff['branches']?['name'] ?? 'Kiritilmagan',
            ),
            _buildInfoRow('Lavozim', staff['position'] ?? 'Kiritilmagan'),
            _buildInfoRow('Bo\'lim', staff['department'] ?? 'Kiritilmagan'),
            _buildInfoRow(
              'Ishga qabul qilingan',
              _formatDate(staff['hire_date']),
            ),
            _buildInfoRow('Ish tajribasi', controller.getWorkExperience()),
            _buildInfoRow(
              'O\'qituvchimi',
              staff['is_teacher'] == true ? 'Ha' : 'Yo\'q',
            ),
          ],
        ),
        SizedBox(height: 16),
        _buildInfoCard(
          title: 'Malaka va tajriba',
          icon: Icons.school,
          children: [
            _buildInfoRow('Ma\'lumoti', staff['education'] ?? 'Kiritilmagan'),
            _buildInfoRow('Ko\'nikmalar', staff['skills'] ?? 'Kiritilmagan'),
            _buildInfoRow('Tajriba', staff['experience'] ?? 'Kiritilmagan'),
          ],
        ),
        if (staff['users'] != null) ...[
          SizedBox(height: 16),
          _buildInfoCard(
            title: 'Tizimga kirish ma\'lumotlari',
            icon: Icons.account_circle,
            children: [
              _buildInfoRow('Username', staff['users']['username'] ?? 'N/A'),
              _buildInfoRow('Rol', _getRoleText(staff['users']['role'])),
              _buildInfoRow(
                'Status',
                staff['users']['status'] == 'active' ? 'Aktiv' : 'Noaktiv',
              ),
            ],
          ),
        ],
        if (staff['notes'] != null && staff['notes'].toString().isNotEmpty) ...[
          SizedBox(height: 16),
          _buildInfoCard(
            title: 'Izohlar',
            icon: Icons.note,
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  staff['notes'],
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  // ==================== DAVOMAT TAB ====================
  Widget _buildAttendanceTab() {
    return Obx(() {
      if (controller.isLoadingAttendance.value) {
        return Center(child: CircularProgressIndicator());
      }

      return Column(
        children: [
          // Davomat statistikasi
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Jami kunlar',
                  controller.totalAttendanceDays.toString(),
                  Icons.calendar_today,
                  AppConstants.primaryColor,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Kelgan',
                  controller.presentDays.toString(),
                  Icons.check_circle,
                  AppConstants.successColor,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Kelmagan',
                  controller.absentDays.toString(),
                  Icons.cancel,
                  AppConstants.errorColor,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Kechikkan',
                  controller.lateDays.toString(),
                  Icons.access_time,
                  AppConstants.warningColor,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Davomat %',
                  '${controller.attendancePercentage.toStringAsFixed(1)}%',
                  Icons.analytics,
                  AppConstants.infoColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          // Sana filtri
          Row(
            children: [
              Text(
                'Sana oralig\'i:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              SizedBox(width: 12),
              Obx(
                () => _buildDateButton(
                  controller.attendanceStartDate.value,
                  () => controller.selectAttendanceStartDate(),
                ),
              ),
              SizedBox(width: 12),
              Text('dan'),
              SizedBox(width: 12),
              Obx(
                () => _buildDateButton(
                  controller.attendanceEndDate.value,
                  () => controller.selectAttendanceEndDate(),
                ),
              ),
              SizedBox(width: 12),
              Text('gacha'),
              Spacer(),
              ElevatedButton.icon(
                onPressed: controller.exportAttendance,
                icon: Icon(Icons.download, size: 18),
                label: Text('Yuklab olish'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          // Davomat ro'yxati
          _buildAttendanceList(),
        ],
      );
    });
  }

  // ==================== DAVOMAT RO'YXATI ====================
  Widget _buildAttendanceList() {
    if (controller.attendanceList.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Column(
            children: [
              Icon(Icons.event_busy, size: 64, color: Colors.grey[300]),
              SizedBox(height: 16),
              Text(
                'Davomat ma\'lumotlari topilmadi',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Column(
        children: [
          // Jadval sarlavhasi
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'SANA',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'KUN',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'KIRISH',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'CHIQISH',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'STATUS',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'IZOH',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          // Jadval qatorlari
          ...controller.attendanceList
              .map((attendance) => _buildAttendanceRow(attendance))
              .toList(),
        ],
      ),
    );
  }

  // ==================== DAVOMAT QATORI ====================
  Widget _buildAttendanceRow(Map<String, dynamic> attendance) {
    final date = DateTime.parse(attendance['attendance_date']);
    final status = attendance['status'];
    final statusColor = status == 'present'
        ? AppConstants.successColor
        : status == 'late'
        ? AppConstants.warningColor
        : AppConstants.errorColor;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(DateFormat('dd.MM.yyyy').format(date))),
          Expanded(flex: 1, child: Text(DateFormat('EEEE', 'uz').format(date))),
          Expanded(flex: 1, child: Text(attendance['check_in_time'] ?? '-')),
          Expanded(flex: 1, child: Text(attendance['check_out_time'] ?? '-')),
          Expanded(
            flex: 1,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                status == 'present'
                    ? 'Keldi'
                    : status == 'late'
                    ? 'Kechikdi'
                    : 'Kelmadi',
                style: TextStyle(
                  color: statusColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              attendance['notes'] ?? '',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== MAOSH TAB ====================
  Widget _buildSalaryTab() {
    return Obx(() {
      if (controller.isLoadingSalary.value) {
        return Center(child: CircularProgressIndicator());
      }

      return Column(
        children: [
          // Maosh statistikasi
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Asosiy maosh',
                  '${NumberFormat('#,###').format(controller.baseSalary.value)} so\'m',
                  Icons.payments,
                  AppConstants.primaryColor,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Jami to\'langan',
                  '${NumberFormat('#,###').format(controller.totalPaid.value)} so\'m',
                  Icons.check_circle,
                  AppConstants.successColor,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Avanslar',
                  '${NumberFormat('#,###').format(controller.totalAdvances.value)} so\'m',
                  Icons.money_off,
                  AppConstants.warningColor,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Qarzlar',
                  '${NumberFormat('#,###').format(controller.totalLoans.value)} so\'m',
                  Icons.account_balance,
                  AppConstants.errorColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          // Maosh tarixi
          _buildSalaryHistory(),
        ],
      );
    });
  }

  // ==================== MAOSH TARIXI ====================
  Widget _buildSalaryHistory() {
    if (controller.salaryHistory.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Column(
            children: [
              Icon(Icons.payments, size: 64, color: Colors.grey[300]),
              SizedBox(height: 16),
              Text(
                'Maosh to\'lovlari topilmadi',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  'Maosh to\'lovlari tarixi',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Spacer(),
                ElevatedButton.icon(
                  onPressed: controller.exportSalaryHistory,
                  icon: Icon(Icons.download, size: 18),
                  label: Text('Yuklab olish'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1),
          ...controller.salaryHistory
              .map((salary) => _buildSalaryHistoryRow(salary))
              .toList(),
        ],
      ),
    );
  }

  // ==================== MAOSH TARIXI QATORI ====================
  Widget _buildSalaryHistoryRow(Map<String, dynamic> salary) {
    final month = salary['month'];
    final year = salary['year'];
    final amount = salary['amount'] ?? 0;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppConstants.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Icon(
                Icons.calendar_today,
                color: AppConstants.primaryColor,
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$month-oy, $year',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                Text(
                  'Oylik to\'lov',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            '${NumberFormat('#,###').format(amount)} so\'m',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppConstants.successColor,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== DARSLAR TAB (O'QITUVCHILAR UCHUN) ====================
  Widget _buildClassesTab() {
    final staff = controller.staff.value!;

    if (staff['is_teacher'] != true) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Column(
            children: [
              Icon(Icons.school, size: 64, color: Colors.grey[300]),
              SizedBox(height: 16),
              Text(
                'Bu xodim o\'qituvchi emas',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return Obx(() {
      if (controller.isLoadingSchedule.value) {
        return Center(child: CircularProgressIndicator());
      }

      return Column(
        children: [
          // Darslar statistikasi
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Haftalik darslar',
                  controller.weeklyLessons.toString(),
                  Icons.calendar_view_week,
                  AppConstants.primaryColor,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Biriktirilgan sinflar',
                  controller.assignedClasses.length.toString(),
                  Icons.class_,
                  AppConstants.successColor,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'O\'qitiladigan fanlar',
                  controller.teachingSubjects.length.toString(),
                  Icons.book,
                  AppConstants.infoColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          // Dars jadvali
          Row(
            children: [
              Text(
                'Dars jadvali',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Spacer(),
              ElevatedButton.icon(
                onPressed: () => Get.toNamed(
                  AppRoutes.schedule,
                  arguments: {'teacherId': staff['id']},
                ),
                icon: Icon(Icons.open_in_new, size: 18),
                label: Text('To\'liq jadval'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          _buildScheduleTable(),
        ],
      );
    });
  }

  // ==================== DARS JADVALI JADVALI ====================
  Widget _buildScheduleTable() {
    if (controller.teacherSchedule.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Text(
            'Dars jadvali topilmadi',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Table(
          border: TableBorder.all(color: Colors.grey[300]!),
          children: [
            TableRow(
              decoration: BoxDecoration(color: Colors.grey[100]),
              children: [
                _buildTableCell('Kun', isHeader: true),
                _buildTableCell('Vaqt', isHeader: true),
                _buildTableCell('Fan', isHeader: true),
                _buildTableCell('Sinf', isHeader: true),
                _buildTableCell('Xona', isHeader: true),
              ],
            ),
            ...controller.teacherSchedule.map((lesson) {
              return TableRow(
                children: [
                  _buildTableCell(_getDayName(lesson['day_of_week'])),
                  _buildTableCell(
                    '${lesson['start_time']} - ${lesson['end_time']}',
                  ),
                  _buildTableCell(lesson['subjects']?['name'] ?? 'N/A'),
                  _buildTableCell(lesson['classes']?['name'] ?? 'N/A'),
                  _buildTableCell(lesson['rooms']?['name'] ?? 'N/A'),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  // ==================== O'QUVCHILAR TAB ====================
  Widget _buildStudentsTab() {
    final staff = controller.staff.value!;

    if (staff['is_teacher'] != true) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Column(
            children: [
              Icon(Icons.people, size: 64, color: Colors.grey[300]),
              SizedBox(height: 16),
              Text(
                'Bu xodim o\'qituvchi emas',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return Obx(() {
      if (controller.isLoadingStudents.value) {
        return Center(child: CircularProgressIndicator());
      }

      return Column(
        children: [
          // O'quvchilar statistikasi
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Jami o\'quvchilar',
                  controller.totalStudents.toString(),
                  Icons.people,
                  AppConstants.primaryColor,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'To\'lov qilganlar',
                  controller.paidStudents.toString(),
                  Icons.check_circle,
                  AppConstants.successColor,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Qarzdorlar',
                  controller.debtorStudents.toString(),
                  Icons.warning,
                  AppConstants.errorColor,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Jami tushum',
                  '${NumberFormat('#,###').format(controller.totalRevenue.value)} so\'m',
                  Icons.payments,
                  AppConstants.successColor,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Yig\'ilish %',
                  '${controller.collectionPercentage.toStringAsFixed(1)}%',
                  Icons.analytics,
                  AppConstants.infoColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          // O'quvchilar ro'yxati
          _buildStudentsList(),
        ],
      );
    });
  }

  // ==================== O'QUVCHILAR RO'YXATI ====================
  Widget _buildStudentsList() {
    if (controller.teacherStudents.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Text(
            'O\'quvchilar topilmadi',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      );
    }

    return Card(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  'O\'quvchilar ro\'yxati',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Spacer(),
                ElevatedButton.icon(
                  onPressed: controller.exportStudentsList,
                  icon: Icon(Icons.download, size: 18),
                  label: Text('Yuklab olish'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1),
          ...controller.teacherStudents
              .map((student) => _buildStudentRow(student))
              .toList(),
        ],
      ),
    );
  }

  // ==================== O'QUVCHI QATORI ====================
  Widget _buildStudentRow(Map<String, dynamic> student) {
    final monthlyFee = student['monthly_fee'] ?? 0;
    final totalPaid = student['total_paid'] ?? 0;
    final isPaid = totalPaid >= monthlyFee;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: AppConstants.primaryColor.withOpacity(0.1),
            child: Text(
              '${student['first_name'][0]}${student['last_name'][0]}'
                  .toUpperCase(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppConstants.primaryColor,
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${student['first_name']} ${student['last_name']}',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                Text(
                  student['phone'] ?? '',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Oylik to\'lov',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                Text(
                  '${NumberFormat('#,###').format(monthlyFee)} so\'m',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'To\'langan',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                Text(
                  '${NumberFormat('#,###').format(totalPaid)} so\'m',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isPaid
                        ? AppConstants.successColor
                        : AppConstants.errorColor,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color:
                  (isPaid ? AppConstants.successColor : AppConstants.errorColor)
                      .withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              isPaid ? 'To\'langan' : 'Qarzdor',
              style: TextStyle(
                color: isPaid
                    ? AppConstants.successColor
                    : AppConstants.errorColor,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== HUJJATLAR TAB ====================
  Widget _buildDocumentsTab() {
    return Obx(() {
      if (controller.isLoadingDocuments.value) {
        return Center(child: CircularProgressIndicator());
      }

      return Column(
        children: [
          // Hujjat yuklash tugmasi
          Row(
            children: [
              Text(
                'Hujjatlar',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Spacer(),
              ElevatedButton.icon(
                onPressed: controller.uploadDocument,
                icon: Icon(Icons.upload_file),
                label: Text('Hujjat yuklash'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          // Hujjatlar ro'yxati
          if (controller.documents.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: Column(
                  children: [
                    Icon(Icons.folder_open, size: 64, color: Colors.grey[300]),
                    SizedBox(height: 16),
                    Text(
                      'Hujjatlar topilmadi',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            )
          else
            ...controller.documents
                .map((doc) => _buildDocumentCard(doc))
                .toList(),
        ],
      );
    });
  }

  // ==================== HUJJAT KARTOCHKASI ====================
  Widget _buildDocumentCard(Map<String, dynamic> doc) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppConstants.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getDocumentIcon(doc['document_type']),
            color: AppConstants.primaryColor,
          ),
        ),
        title: Text(
          doc['document_type'] ?? 'Hujjat',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          doc['document_number'] != null
              ? 'Raqam: ${doc['document_number']}'
              : 'Yuklangan: ${_formatDate(doc['created_at'])}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (doc['file_url'] != null)
              IconButton(
                icon: Icon(Icons.download, color: AppConstants.infoColor),
                onPressed: () => controller.downloadDocument(doc['file_url']),
                tooltip: 'Yuklab olish',
              ),
            IconButton(
              icon: Icon(Icons.delete, color: AppConstants.errorColor),
              onPressed: () => controller.deleteDocument(doc['id']),
              tooltip: 'O\'chirish',
            ),
          ],
        ),
      ),
    );
  }

  // ==================== BAHOLASH TAB ====================
  Widget _buildEvaluationTab() {
    return Obx(() {
      if (controller.isLoadingEvaluations.value) {
        return Center(child: CircularProgressIndicator());
      }

      return Column(
        children: [
          // Baholash statistikasi
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'O\'rtacha baho',
                  controller.averageRating.toStringAsFixed(1),
                  Icons.star,
                  AppConstants.warningColor,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Baholashlar soni',
                  controller.totalEvaluations.toString(),
                  Icons.assessment,
                  AppConstants.infoColor,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Yutuqlar',
                  controller.achievements.length.toString(),
                  Icons.emoji_events,
                  AppConstants.successColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          // Baholash tarixi
          _buildEvaluationHistory(),

          SizedBox(height: 16),

          // Yutuqlar
          _buildAchievements(),
        ],
      );
    });
  }

  // ==================== BAHOLASH TARIXI ====================
  Widget _buildEvaluationHistory() {
    if (controller.evaluations.isEmpty) {
      return Card(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.star_border, size: 64, color: Colors.grey[300]),
                SizedBox(height: 16),
                Text(
                  'Baholashlar topilmadi',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Baholash tarixi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Divider(height: 1),
          ...controller.evaluations
              .map((eval) => _buildEvaluationRow(eval))
              .toList(),
        ],
      ),
    );
  }

  // ==================== BAHOLASH QATORI ====================
  Widget _buildEvaluationRow(Map<String, dynamic> eval) {
    final rating = eval['overall_rating'] ?? 0.0;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppConstants.warningColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.star, color: AppConstants.warningColor, size: 24),
                Text(
                  rating.toStringAsFixed(1),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppConstants.warningColor,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDate(eval['evaluation_date']),
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                SizedBox(height: 4),
                if (eval['strengths'] != null)
                  Text(
                    'Kuchli tomonlar: ${eval['strengths']}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (eval['areas_for_improvement'] != null)
                  Text(
                    'Yaxshilanishi kerak: ${eval['areas_for_improvement']}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== YUTUQLAR ====================
  Widget _buildAchievements() {
    if (controller.achievements.isEmpty) {
      return SizedBox();
    }

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Yutuqlar',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Divider(height: 1),
          Padding(
            padding: EdgeInsets.all(16),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: controller.achievements
                  .map((ach) => _buildAchievementChip(ach))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== YUTUQ CHIP ====================
  Widget _buildAchievementChip(Map<String, dynamic> achievement) {
    return Chip(
      avatar: CircleAvatar(
        backgroundColor: AppConstants.successColor,
        child: Icon(Icons.emoji_events, size: 16, color: Colors.white),
      ),
      label: Text(achievement['title'] ?? ''),
      backgroundColor: AppConstants.successColor.withOpacity(0.1),
    );
  }

  // ==================== YORDAMCHI WIDGETLAR ====================

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppConstants.primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Icon(icon, color: AppConstants.primaryColor, size: 24),
                SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.primaryColor,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
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
  ) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              Spacer(),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildDateButton(DateTime date, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: AppConstants.primaryColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_today,
              size: 16,
              color: AppConstants.primaryColor,
            ),
            SizedBox(width: 8),
            Text(
              DateFormat('dd.MM.yyyy').format(date),
              style: TextStyle(color: AppConstants.primaryColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableCell(String text, {bool isHeader = false}) {
    return Padding(
      padding: EdgeInsets.all(12),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          fontSize: 13,
        ),
      ),
    );
  }

  // ==================== YORDAMCHI FUNKSIYALAR ====================

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'Kiritilmagan';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd.MM.yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  String _getDayName(String dayOfWeek) {
    const days = {
      'monday': 'Dushanba',
      'tuesday': 'Seshanba',
      'wednesday': 'Chorshanba',
      'thursday': 'Payshanba',
      'friday': 'Juma',
      'saturday': 'Shanba',
      'sunday': 'Yakshanba',
    };
    return days[dayOfWeek] ?? dayOfWeek;
  }

  String _getRoleText(String? role) {
    const roles = {
      'owner': 'Ega',
      'manager': 'Menejer',
      'director': 'Direktor',
      'admin': 'Administrator',
      'teacher': 'O\'qituvchi',
      'staff': 'Xodim',
      'cashier': 'Kassir',
      'reception': 'Qabul',
    };
    return roles[role] ?? role ?? 'N/A';
  }

  IconData _getDocumentIcon(String? type) {
    const icons = {
      'passport': Icons.badge,
      'diploma': Icons.school,
      'certificate': Icons.workspace_premium,
      'contract': Icons.description,
    };
    return icons[type] ?? Icons.insert_drive_file;
  }
}
