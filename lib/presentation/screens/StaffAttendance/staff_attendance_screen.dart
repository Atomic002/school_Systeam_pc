// lib/presentation/screens/StaffAttendance/staff_attendance_screen.dart
// XODIMLAR DAVOMATI EKRANI - TO'LIQ FUNKSIONAL

import 'package:flutter/material.dart';
import 'package:flutter_application_1/presentation/controllers/staff_attandance.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../config/constants.dart';
import '../../widgets/sidebar.dart';

class StaffAttendanceScreen extends StatelessWidget {
  StaffAttendanceScreen({Key? key}) : super(key: key);

  final controller = Get.put(StaffAttendanceController());

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
                _buildFiltersAndStats(),
                Expanded(child: _buildAttendanceContent()),
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
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppConstants.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.how_to_reg,
              color: AppConstants.primaryColor,
              size: 32,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Xodimlar davomati',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.textPrimaryColor,
                  ),
                ),
                Obx(
                  () => Text(
                    'Bugun: ${DateFormat('dd MMMM yyyy, EEEE', 'uz').format(controller.selectedDate.value)}',
                    style: TextStyle(
                      color: AppConstants.textSecondaryColor,
                      fontSize: 14,
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

  // ==================== TEZKOR HARAKATLAR ====================
  Widget _buildQuickActions() {
    return Row(
      children: [
        ElevatedButton.icon(
          onPressed: controller.markAllPresent,
          icon: Icon(Icons.check_circle, size: 20),
          label: Text('Hammasini belgilash'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppConstants.successColor,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          ),
        ),
        SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: controller.exportAttendance,
          icon: Icon(Icons.download, size: 20),
          label: Text('Yuklab olish'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppConstants.infoColor,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          ),
        ),
        SizedBox(width: 12),
        IconButton(
          onPressed: controller.loadAttendanceData,
          icon: Icon(Icons.refresh),
          tooltip: 'Yangilash',
        ),
      ],
    );
  }

  // ==================== FILTERLAR VA STATISTIKA ====================
  Widget _buildFiltersAndStats() {
    return Container(
      padding: EdgeInsets.all(AppConstants.paddingLarge),
      color: Colors.white,
      child: Column(
        children: [
          // Sana va filterlar
          Row(
            children: [
              _buildDateSelector(),
              SizedBox(width: 16),
              _buildBranchFilter(),
              SizedBox(width: 16),
              _buildStatusFilter(),
              SizedBox(width: 16),
              _buildSearchField(),
            ],
          ),
          SizedBox(height: 16),
          // Statistika
          _buildStatisticsCards(),
        ],
      ),
    );
  }

  // ==================== SANA TANLAGICH ====================
  Widget _buildDateSelector() {
    return Row(
      children: [
        IconButton(
          onPressed: controller.previousDay,
          icon: Icon(Icons.chevron_left),
          tooltip: 'Oldingi kun',
        ),
        Obx(
          () => InkWell(
            onTap: controller.selectDate,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: AppConstants.primaryColor,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: AppConstants.primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text(
                    DateFormat(
                      'dd.MM.yyyy',
                    ).format(controller.selectedDate.value),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        IconButton(
          onPressed: controller.nextDay,
          icon: Icon(Icons.chevron_right),
          tooltip: 'Keyingi kun',
        ),
        SizedBox(width: 12),
        TextButton.icon(
          onPressed: controller.goToToday,
          icon: Icon(Icons.today, size: 18),
          label: Text('Bugun'),
          style: TextButton.styleFrom(
            foregroundColor: AppConstants.primaryColor,
          ),
        ),
      ],
    );
  }

  // ==================== FILIAL FILTER ====================
  Widget _buildBranchFilter() {
    return Obx(
      () => Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(10),
          color: Colors.grey[50],
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String?>(
            value: controller.selectedBranchId.value,
            hint: Text('Barcha filiallar'),
            items: [
              DropdownMenuItem(value: null, child: Text('Barcha filiallar')),
              ...controller.branches.map((branch) {
                return DropdownMenuItem(
                  value: branch['id'],
                  child: Text(branch['name']),
                );
              }),
            ],
            onChanged: controller.filterByBranch,
          ),
        ),
      ),
    );
  }

  // ==================== STATUS FILTER ====================
  Widget _buildStatusFilter() {
    return Obx(
      () => Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(10),
          color: Colors.grey[50],
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
            ],
            onChanged: controller.filterByStatus,
          ),
        ),
      ),
    );
  }

  // ==================== QIDIRUV ====================
  Widget _buildSearchField() {
    return Expanded(
      child: TextField(
        onChanged: controller.searchStaff,
        decoration: InputDecoration(
          hintText: 'Xodim qidirish...',
          prefixIcon: Icon(Icons.search, color: AppConstants.primaryColor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppConstants.primaryColor, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  // ==================== STATISTIKA KARTOCHKALARI ====================
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
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Kelgan',
              controller.presentCount.toString(),
              Icons.check_circle,
              AppConstants.successColor,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Kelmagan',
              controller.absentCount.toString(),
              Icons.cancel,
              AppConstants.errorColor,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Kechikkan',
              controller.lateCount.toString(),
              Icons.access_time,
              AppConstants.warningColor,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Ta\'tilda',
              controller.leaveCount.toString(),
              Icons.beach_access,
              AppConstants.infoColor,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Davomat %',
              '${controller.attendancePercentage.toStringAsFixed(1)}%',
              Icons.analytics,
              AppConstants.successColor,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== STATISTIKA KARTOCHKA ====================
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
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
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

  // ==================== DAVOMAT CONTENT ====================
  Widget _buildAttendanceContent() {
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
          return _buildStaffAttendanceCard(staff);
        },
      );
    });
  }

  // ==================== XODIM DAVOMAT KARTOCHKASI ====================
  Widget _buildStaffAttendanceCard(Map<String, dynamic> staff) {
    final attendance = controller.getAttendanceForStaff(staff['id']);
    final status = attendance?['status'] ?? 'not_marked';
    final statusColor = _getStatusColor(status);

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 30,
              backgroundColor: AppConstants.primaryColor.withOpacity(0.1),
              backgroundImage: staff['photo_url'] != null
                  ? NetworkImage(staff['photo_url'])
                  : null,
              child: staff['photo_url'] == null
                  ? Text(
                      '${staff['first_name'][0]}${staff['last_name'][0]}'
                          .toUpperCase(),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.primaryColor,
                      ),
                    )
                  : null,
            ),
            SizedBox(width: 16),

            // Ma'lumotlar
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${staff['first_name']} ${staff['last_name']}',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.badge, size: 14, color: Colors.grey[600]),
                      SizedBox(width: 4),
                      Text(
                        staff['position'] ?? '',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                      SizedBox(width: 12),
                      Icon(Icons.business, size: 14, color: Colors.grey[600]),
                      SizedBox(width: 4),
                      Text(
                        staff['branches']?['name'] ?? '',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                    ],
                  ),
                  if (attendance != null) ...[
                    SizedBox(height: 8),
                    Row(
                      children: [
                        if (attendance['check_in_time'] != null) ...[
                          Icon(
                            Icons.login,
                            size: 14,
                            color: AppConstants.successColor,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Kirish: ${attendance['check_in_time']}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                          ),
                          SizedBox(width: 12),
                        ],
                        if (attendance['check_out_time'] != null) ...[
                          Icon(
                            Icons.logout,
                            size: 14,
                            color: AppConstants.errorColor,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Chiqish: ${attendance['check_out_time']}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Status va harakatlar
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getStatusIcon(status),
                        size: 16,
                        color: statusColor,
                      ),
                      SizedBox(width: 6),
                      Text(
                        _getStatusText(status),
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (status == 'not_marked' || status == 'absent')
                      _buildActionButton(
                        'Kelgan',
                        Icons.check,
                        AppConstants.successColor,
                        () => controller.markAttendance(staff['id'], 'present'),
                      ),
                    if (status == 'not_marked')
                      _buildActionButton(
                        'Kechikkan',
                        Icons.access_time,
                        AppConstants.warningColor,
                        () => controller.markAttendance(staff['id'], 'late'),
                      ),
                    if (status == 'not_marked')
                      _buildActionButton(
                        'Kelmagan',
                        Icons.cancel,
                        AppConstants.errorColor,
                        () => controller.markAttendance(staff['id'], 'absent'),
                      ),
                    if (status != 'not_marked')
                      _buildActionButton(
                        'Tahrirlash',
                        Icons.edit,
                        AppConstants.primaryColor,
                        () =>
                            controller.editAttendance(staff['id'], attendance!),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==================== HARAKAT TUGMASI ====================
  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: EdgeInsets.only(left: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== BO'SH HOLAT ====================
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 80, color: Colors.grey[300]),
          SizedBox(height: 16),
          Text(
            'Xodimlar topilmadi',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Filtrlarni o\'zgartiring',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  // ==================== YORDAMCHI FUNKSIYALAR ====================

  Color _getStatusColor(String status) {
    switch (status) {
      case 'present':
        return AppConstants.successColor;
      case 'absent':
        return AppConstants.errorColor;
      case 'late':
        return AppConstants.warningColor;
      case 'leave':
        return AppConstants.infoColor;
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
      default:
        return 'Belgilanmagan';
    }
  }
}
