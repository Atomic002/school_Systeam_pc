// lib/presentation/screens/StaffList/modern_staff_screen.dart
// MUKAMMAL XODIMLAR RO'YXATI EKRANI

import 'package:flutter/material.dart';
import 'package:flutter_application_1/presentation/controllers/ModernStaffController.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../config/constants.dart';
import '../../../config/app_routes.dart';
import '../../widgets/sidebar.dart';

class ModernStaffScreen extends StatelessWidget {
  ModernStaffScreen({Key? key}) : super(key: key);

  final controller = Get.put(ModernStaffController());

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
                Expanded(child: _buildStaffList()),
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
              Icons.people,
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
                  'Xodimlar',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.textPrimaryColor,
                  ),
                ),
                Obx(
                  () => Text(
                    'Jami: ${controller.filteredStaff.length} xodim',
                    style: TextStyle(
                      color: AppConstants.textSecondaryColor,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          _buildExportButton(),
          SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: () => Get.toNamed(AppRoutes.addStaff),
            icon: Icon(Icons.add),
            label: Text('Yangi xodim'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
          ),
          SizedBox(width: 12),
          IconButton(
            onPressed: controller.loadStaffData,
            icon: Icon(Icons.refresh),
            tooltip: 'Yangilash',
          ),
        ],
      ),
    );
  }

  // ==================== EXPORT BUTTON ====================
  Widget _buildExportButton() {
    return PopupMenuButton<String>(
      icon: Icon(Icons.download),
      tooltip: 'Yuklab olish',
      onSelected: (value) {
        if (value == 'pdf') {
          controller.exportToPDF();
        } else if (value == 'excel') {
          controller.exportToExcel();
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'pdf',
          child: Row(
            children: [
              Icon(Icons.picture_as_pdf, color: Colors.red, size: 20),
              SizedBox(width: 12),
              Text('PDF'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'excel',
          child: Row(
            children: [
              Icon(Icons.table_chart, color: Colors.green, size: 20),
              SizedBox(width: 12),
              Text('Excel'),
            ],
          ),
        ),
      ],
    );
  }

  // ==================== FILTERS VA STATISTIKA ====================
  Widget _buildFiltersAndStats() {
    return Container(
      padding: EdgeInsets.all(AppConstants.paddingLarge),
      color: Colors.white,
      child: Column(
        children: [
          // Qidiruv va filterlar
          Row(
            children: [
              Expanded(child: _buildSearchField()),
              SizedBox(width: 12),
              _buildBranchFilter(),
              SizedBox(width: 12),
              _buildPositionFilter(),
              SizedBox(width: 12),
              _buildStatusFilter(),
              SizedBox(width: 12),
              _buildTeacherFilter(),
            ],
          ),
          SizedBox(height: 16),
          // Statistika kartochkalari
          _buildStatsCards(),
        ],
      ),
    );
  }

  // ==================== QIDIRUV MAYDONI ====================
  Widget _buildSearchField() {
    return TextField(
      onChanged: controller.searchStaff,
      decoration: InputDecoration(
        hintText: 'Ism, telefon yoki lavozim bo\'yicha qidirish...',
        prefixIcon: Icon(Icons.search, color: AppConstants.primaryColor),
        suffixIcon: Obx(
          () => controller.searchQuery.value.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () => controller.searchStaff(''),
                )
              : SizedBox(),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppConstants.primaryColor, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  // ==================== FILIAL FILTER ====================
  Widget _buildBranchFilter() {
    return Obx(
      () => Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
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

  // ==================== LAVOZIM FILTER ====================
  Widget _buildPositionFilter() {
    return Obx(
      () => Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey[50],
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String?>(
            value: controller.selectedPosition.value,
            hint: Text('Lavozim'),
            items: [
              DropdownMenuItem(value: null, child: Text('Barcha lavozimlar')),
              ...controller.positions.map((pos) {
                return DropdownMenuItem(value: pos, child: Text(pos));
              }).toList(),
            ],
            onChanged: controller.filterByPosition,
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
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey[50],
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String?>(
            value: controller.selectedStatus.value,
            hint: Text('Holat'),
            items: [
              DropdownMenuItem(value: null, child: Text('Barcha holatlar')),
              DropdownMenuItem(value: 'active', child: Text('Aktiv')),
              DropdownMenuItem(value: 'inactive', child: Text('Noaktiv')),
              DropdownMenuItem(value: 'on_leave', child: Text('Ta\'tilda')),
            ],
            onChanged: controller.filterByStatus,
          ),
        ),
      ),
    );
  }

  // ==================== O'QITUVCHI FILTER ====================
  Widget _buildTeacherFilter() {
    return Obx(
      () => FilterChip(
        label: Text('Faqat o\'qituvchilar'),
        selected: controller.showOnlyTeachers.value,
        onSelected: controller.toggleTeacherFilter,
        selectedColor: AppConstants.primaryColor.withOpacity(0.2),
        checkmarkColor: AppConstants.primaryColor,
      ),
    );
  }

  // ==================== STATISTIKA KARTOCHKALARI ====================
  Widget _buildStatsCards() {
    return Obx(
      () => Row(
        children: [
          _buildStatCard(
            'Jami xodimlar',
            controller.totalStaff.toString(),
            Icons.people,
            AppConstants.primaryColor,
          ),
          SizedBox(width: 12),
          _buildStatCard(
            'O\'qituvchilar',
            controller.totalTeachers.toString(),
            Icons.school,
            AppConstants.successColor,
          ),
          SizedBox(width: 12),
          _buildStatCard(
            'Aktiv',
            controller.activeStaff.toString(),
            Icons.check_circle,
            Colors.green,
          ),
          SizedBox(width: 12),
          _buildStatCard(
            'Ta\'tilda',
            controller.onLeaveStaff.toString(),
            Icons.beach_access,
            AppConstants.warningColor,
          ),
          SizedBox(width: 12),
          _buildStatCard(
            'O\'rtacha maosh',
            NumberFormat('#,###').format(controller.averageSalary.value),
            Icons.payments,
            AppConstants.infoColor,
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
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== XODIMLAR RO'YXATI ====================
  Widget _buildStaffList() {
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

  // ==================== XODIM KARTOCHKASI ====================
  Widget _buildStaffCard(dynamic staff) {
    final status = staff['status'] ?? 'active';
    final statusColor = status == 'active'
        ? AppConstants.successColor
        : status == 'on_leave'
        ? AppConstants.warningColor
        : Colors.grey;

    final isTeacher = staff['is_teacher'] ?? false;

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => Get.toNamed(
          AppRoutes.staffDetail,
          arguments: {'staffId': staff['id']},
        ),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              Stack(
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: AppConstants.primaryColor.withOpacity(0.1),
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
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Icon(
                        status == 'active'
                            ? Icons.check
                            : status == 'on_leave'
                            ? Icons.beach_access
                            : Icons.close,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(width: 16),

              // Ma'lumotlar
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
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (isTeacher)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppConstants.successColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
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
                                    fontWeight: FontWeight.w600,
                                    color: AppConstants.successColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.badge, size: 16, color: Colors.grey[600]),
                        SizedBox(width: 4),
                        Text(
                          staff['position'],
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 14,
                          ),
                        ),
                        if (staff['department'] != null) ...[
                          SizedBox(width: 8),
                          Text('•', style: TextStyle(color: Colors.grey)),
                          SizedBox(width: 8),
                          Text(
                            staff['department'],
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        _buildInfoChip(
                          Icons.phone,
                          staff['phone'],
                          AppConstants.primaryColor,
                        ),
                        SizedBox(width: 8),
                        _buildInfoChip(
                          Icons.business,
                          staff['branches']?['name'] ?? 'N/A',
                          AppConstants.infoColor,
                        ),
                        SizedBox(width: 8),
                        _buildInfoChip(
                          Icons.payments,
                          '${NumberFormat('#,###').format(staff['base_salary'] ?? 0)} so\'m',
                          AppConstants.successColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Harakatlar
              Column(
                children: [
                  IconButton(
                    onPressed: () => Get.toNamed(
                      AppRoutes.staffDetail,
                      arguments: {'staffId': staff['id']},
                    ),
                    icon: Icon(
                      Icons.visibility,
                      color: AppConstants.primaryColor,
                    ),
                    tooltip: 'Ko\'rish',
                  ),
                  IconButton(
                    onPressed: () => controller.deleteStaff(staff['id']),
                    icon: Icon(Icons.delete, color: AppConstants.errorColor),
                    tooltip: 'O\'chirish',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== INFO CHIP ====================
  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
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
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== BO'SH HOLAT ====================
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 80, color: Colors.grey[300]),
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
            'Filtrlarni o\'zgartiring yoki yangi xodim qo\'shing',
            style: TextStyle(color: Colors.grey[500]),
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Get.toNamed(AppRoutes.addStaff),
            icon: Icon(Icons.add),
            label: Text('Yangi xodim qo\'shish'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }
}
