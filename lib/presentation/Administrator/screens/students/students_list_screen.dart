// lib/presentation/screens/students/students_screen.dart
// TO'G'IRLANGAN VERSIYA (MAP bilan ishlash uchun)

import 'package:flutter/material.dart';
import 'package:flutter_application_1/config/app_routes.dart';
import 'package:flutter_application_1/config/constants.dart';
import 'package:flutter_application_1/presentation/Administrator/controllers/students_controller.dart';
import 'package:flutter_application_1/presentation/widgets/sidebar.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';


class StudentsScreenadmin extends StatelessWidget {
  StudentsScreenadmin({Key? key}) : super(key: key);

  final controller = Get.put(StudentsControlleradmin());

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
                _buildModernHeader(),
                _buildFiltersSection(),
                Expanded(child: _buildMainContent()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== ZAMONAVIY HEADER ====================
  Widget _buildModernHeader() {
    return Container(
      padding: EdgeInsets.all(24),
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
      child: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(Icons.school, color: Colors.white, size: 32),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'O\'quvchilar',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Obx(
                        () => Text(
                          'Jami: ${controller.totalCount.value} ta o\'quvchi',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                _buildHeaderButton(
                  icon: Icons.file_download,
                  label: 'Export',
                  onTap: () => _showExportDialog(),
                ),
                SizedBox(width: 12),
                _buildHeaderButton(
                  icon: Icons.file_upload,
                  label: 'Import',
                  onTap: () => _showImportDialog(),
                ),
                SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => Get.toNamed(AppRoutes.addStudent),
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.add_circle, color: Color(0xFF667eea)),
                            SizedBox(width: 8),
                            Text(
                              'Yangi o\'quvchi',
                              style: TextStyle(
                                color: Color(0xFF667eea),
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                IconButton(
                  onPressed: controller.refreshData,
                  icon: Icon(Icons.refresh, color: Colors.white),
                  tooltip: 'Yangilash',
                ),
              ],
            ),
            SizedBox(height: 20),
            _buildSearchBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                Icon(icon, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        onChanged: controller.searchStudents,
        decoration: InputDecoration(
          hintText: 'Ism, familiya yoki telefon raqam bo\'yicha qidirish...',
          prefixIcon: Icon(Icons.search, color: Color(0xFF667eea)),
          suffixIcon: Obx(
            () => controller.searchQuery.value.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () => controller.searchStudents(''),
                  )
                : SizedBox(),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  // ==================== FILTERLAR VA STATISTIKA ====================
  Widget _buildFiltersSection() {
    return Container(
      padding: EdgeInsets.all(24),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            children: [
              _buildStatusFilter(),
              SizedBox(width: 12),
              _buildClassFilter(),
              SizedBox(width: 12),
              _buildBranchFilter(),
              Spacer(),
              _buildViewToggle(),
            ],
          ),
          SizedBox(height: 16),
          _buildStatsCards(),
        ],
      ),
    );
  }

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
              DropdownMenuItem(value: 'active', child: Text('Faol')),
              DropdownMenuItem(value: 'paused', child: Text('To\'xtatilgan')),
              DropdownMenuItem(value: 'graduated', child: Text('Bitirgan')),
            ],
            onChanged: controller.setStatusFilter,
          ),
        ),
      ),
    );
  }

  Widget _buildClassFilter() {
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
            value: controller.selectedClassId.value,
            hint: Text('Sinf'),
            items: [
              DropdownMenuItem(value: null, child: Text('Barcha sinflar')),
              ...controller.classes.map(
                (cls) => DropdownMenuItem(
                  value: cls['id'],
                  child: Text(cls['name']),
                ),
              ),
            ],
            onChanged: controller.filterByClass,
          ),
        ),
      ),
    );
  }

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
            hint: Text('Filial'),
            items: [
              DropdownMenuItem(value: null, child: Text('Barcha filiallar')),
              ...controller.branches.map(
                (branch) => DropdownMenuItem(
                  value: branch['id'],
                  child: Text(branch['name']),
                ),
              ),
            ],
            onChanged: controller.filterByBranch,
          ),
        ),
      ),
    );
  }

  Widget _buildViewToggle() {
    return Obx(
      () => Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            _buildViewButton(
              Icons.grid_view,
              'grid',
              controller.viewMode.value == 'grid',
            ),
            _buildViewButton(
              Icons.list,
              'list',
              controller.viewMode.value == 'list',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewButton(IconData icon, String mode, bool selected) {
    return InkWell(
      onTap: () => controller.viewMode.value = mode,
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: selected ? Color(0xFF667eea) : Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildStatsCards() {
    return Obx(
      () => Row(
        children: [
          _buildStatCard(
            'Jami',
            controller.totalCount.toString(),
            Icons.people,
            Color(0xFF667eea),
          ),
          SizedBox(width: 12),
          _buildStatCard(
            'Faol',
            controller.activeCount.toString(),
            Icons.check_circle,
            Color(0xFF06D6A0),
          ),
          SizedBox(width: 12),
          _buildStatCard(
            'To\'xtatilgan',
            controller.pausedCount.toString(),
            Icons.pause_circle,
            Color(0xFFFFC857),
          ),
          SizedBox(width: 12),
          _buildStatCard(
            'Bitirganlar',
            controller.graduatedCount.toString(),
            Icons.school,
            Color(0xFF667eea),
          ),
          SizedBox(width: 12),
          _buildStatCard(
            'O\'rtacha to\'lov',
            '${_formatCurrency(controller.averageFee.value)}',
            Icons.payments,
            Color(0xFF06D6A0),
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

  // ==================== ASOSIY KONTENT ====================
  Widget _buildMainContent() {
    return Obx(() {
      if (controller.isLoading.value && controller.students.isEmpty) {
        return _buildLoadingState();
      }

      if (controller.students.isEmpty) {
        return _buildEmptyState();
      }

      return Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: controller.refreshData,
              child: Obx(
                () => controller.viewMode.value == 'grid'
                    ? _buildGridView()
                    : _buildListView(),
              ),
            ),
          ),
          _buildPagination(),
        ],
      );
    });
  }

  // ==================== GRID VIEW ====================
  Widget _buildGridView() {
    return GridView.builder(
      padding: EdgeInsets.all(24),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.85,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
      ),
      itemCount: controller.students.length,
      itemBuilder: (context, index) {
        final student = controller.students[index];
        return _buildStudentCard(student, index);
      },
    );
  }

  Widget _buildStudentCard(Map<String, dynamic> student, int index) {
    final colors = [
      Color(0xFF667eea),
      Color(0xFF06D6A0),
      Color(0xFFFFC857),
      Color(0xFFFF6B6B),
    ];
    final cardColor = colors[index % colors.length];

    // Mapdan ma'lumotlarni o'qish (null checklar bilan)
    final String id = student['id'] ?? '';
    final String photoUrl = student['photo_url'] ?? '';
    final String firstName = student['first_name'] ?? '';
    final String lastName = student['last_name'] ?? '';
    final String fullName = student['full_name'] ?? '$firstName $lastName';
    final String status = student['status'] ?? '';
    final String classFullName = student['class_full_name'] ?? 'Sinf yo\'q';
    final String parentPhone = student['parent_phone'] ?? '';
    final double finalMonthlyFee = (student['final_monthly_fee'] ?? 0)
        .toDouble();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: cardColor.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Get.toNamed(
            AppRoutes.studentDetail,
            arguments: {'studentId': id},
          ),
          borderRadius: BorderRadius.circular(20),
          child: Column(
            children: [
              // Header
              Container(
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [cardColor, cardColor.withOpacity(0.7)],
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: photoUrl.isNotEmpty
                            ? ClipOval(
                                child: Image.network(
                                  photoUrl,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Center(
                                child: Text(
                                  firstName.isNotEmpty
                                      ? '${firstName[0]}${lastName.isNotEmpty ? lastName[0] : ''}'
                                            .toUpperCase()
                                      : '?',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: cardColor,
                                  ),
                                ),
                              ),
                      ),
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: _buildStatusBadge(status),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fullName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 8),
                      _buildInfoRow(Icons.class_, classFullName, cardColor),
                      SizedBox(height: 6),
                      _buildInfoRow(Icons.phone, parentPhone, cardColor),
                      SizedBox(height: 6),
                      _buildInfoRow(
                        Icons.payments,
                        '${_formatCurrency(finalMonthlyFee)} so\'m',
                        cardColor,
                      ),
                      Spacer(),
                      Row(
                        children: [
                          Expanded(
                            child: _buildCardButton(
                              'Ko\'rish',
                              cardColor,
                              () => Get.toNamed(
                                AppRoutes.studentDetail,
                                arguments: {'studentId': id},
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          _buildIconButton(
                            Icons.more_vert,
                            cardColor,
                            () => _showStudentOptions(student),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final config = _getStatusConfig(status);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(config['icon'], size: 14, color: config['color']),
          SizedBox(width: 4),
          Text(
            config['text'],
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: config['color'],
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getStatusConfig(String status) {
    switch (status) {
      case 'active':
        return {
          'color': Color(0xFF06D6A0),
          'text': 'Faol',
          'icon': Icons.check_circle,
        };
      case 'paused':
        return {
          'color': Color(0xFFFFC857),
          'text': 'To\'xtatilgan',
          'icon': Icons.pause_circle,
        };
      case 'graduated':
        return {
          'color': Color(0xFF667eea),
          'text': 'Bitirgan',
          'icon': Icons.school,
        };
      default:
        return {'color': Colors.grey, 'text': status, 'icon': Icons.help};
    }
  }

  Widget _buildInfoRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color.withOpacity(0.7)),
        SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildCardButton(String label, Color color, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon, Color color, VoidCallback onTap) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Icon(icon, size: 16, color: color),
        ),
      ),
    );
  }

  // ==================== LIST VIEW ====================
  Widget _buildListView() {
    return ListView.builder(
      padding: EdgeInsets.all(24),
      itemCount: controller.students.length,
      itemBuilder: (context, index) {
        final student = controller.students[index];
        return _buildStudentListItem(student);
      },
    );
  }

  Widget _buildStudentListItem(Map<String, dynamic> student) {
    // Mapdan ma'lumotlarni o'qish
    final String id = student['id'] ?? '';
    final String photoUrl = student['photo_url'] ?? '';
    final String firstName = student['first_name'] ?? '';
    final String lastName = student['last_name'] ?? '';
    final String fullName = student['full_name'] ?? '$firstName $lastName';
    final String status = student['status'] ?? '';
    final String classFullName = student['class_full_name'] ?? 'Sinf yo\'q';
    final String parentPhone = student['parent_phone'] ?? '';
    final double finalMonthlyFee = (student['final_monthly_fee'] ?? 0)
        .toDouble();

    final statusConfig = _getStatusConfig(status);

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () =>
            Get.toNamed(AppRoutes.studentDetail, arguments: {'studentId': id}),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Color(0xFF667eea).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: photoUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(photoUrl, fit: BoxFit.cover),
                      )
                    : Center(
                        child: Text(
                          firstName.isNotEmpty
                              ? '${firstName[0]}${lastName.isNotEmpty ? lastName[0] : ''}'
                                    .toUpperCase()
                              : '?',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF667eea),
                          ),
                        ),
                      ),
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
                            fullName,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: statusConfig['color'].withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                statusConfig['icon'],
                                size: 14,
                                color: statusConfig['color'],
                              ),
                              SizedBox(width: 4),
                              Text(
                                statusConfig['text'],
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: statusConfig['color'],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.class_, size: 16, color: Colors.grey[600]),
                        SizedBox(width: 4),
                        Text(
                          classFullName,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                        SizedBox(width: 16),
                        Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                        SizedBox(width: 4),
                        Text(
                          parentPhone,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                        SizedBox(width: 16),
                        Icon(Icons.payments, size: 16, color: Colors.grey[600]),
                        SizedBox(width: 4),
                        Text(
                          '${_formatCurrency(finalMonthlyFee)} so\'m',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF06D6A0),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Harakatlar
              Row(
                children: [
                  IconButton(
                    onPressed: () => Get.toNamed(
                      AppRoutes.studentDetail,
                      arguments: {'studentId': id},
                    ),
                    icon: Icon(Icons.visibility, color: Color(0xFF667eea)),
                    tooltip: 'Ko\'rish',
                  ),
                  IconButton(
                    onPressed: () => _showStudentOptions(student),
                    icon: Icon(Icons.more_vert, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== PAGINATION ====================
  Widget _buildPagination() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Obx(
            () => Text(
              'Ko\'rsatilmoqda: ${controller.students.length} ta yozuv',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ),
          Spacer(),
          _buildPaginationButton(
            Icons.chevron_left,
            controller.hasPreviousPage,
            controller.previousPage,
          ),
          SizedBox(width: 12),
          Obx(
            () => Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Color(0xFF667eea).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Sahifa ${controller.currentPage.value}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF667eea),
                ),
              ),
            ),
          ),
          SizedBox(width: 12),
          _buildPaginationButton(
            Icons.chevron_right,
            controller.hasNextPage,
            controller.nextPage,
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationButton(
    IconData icon,
    bool enabled,
    VoidCallback onTap,
  ) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: enabled ? Color(0xFF667eea) : Colors.grey[300],
        borderRadius: BorderRadius.circular(10),
        boxShadow: enabled
            ? [
                BoxShadow(
                  color: Color(0xFF667eea).withOpacity(0.3),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(10),
          child: Icon(icon, color: enabled ? Colors.white : Colors.grey[500]),
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
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: Color(0xFF667eea).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.school_outlined,
              size: 100,
              color: Color(0xFF667eea),
            ),
          ),
          SizedBox(height: 32),
          Text(
            'O\'quvchilar topilmadi',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          Text(
            'Birinchi o\'quvchini qo\'shib boshlang',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => Get.toNamed(AppRoutes.addStudent),
            icon: Icon(Icons.add),
            label: Text('Yangi o\'quvchi qo\'shish'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF667eea),
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== LOADING HOLAT ====================
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667eea)),
          ),
          SizedBox(height: 16),
          Text(
            'Ma\'lumotlar yuklanmoqda...',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  // ==================== DIALOGLAR ====================
  void _showStudentOptions(Map<String, dynamic> student) {
    // Mapdan ma'lumotlarni o'qish
    final String id = student['id'] ?? '';
    final String parentPhone = student['parent_phone'] ?? '';

    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.visibility, color: Color(0xFF667eea)),
              title: Text('Ko\'rish'),
              onTap: () {
                Get.back();
                Get.toNamed(
                  AppRoutes.studentDetail,
                  arguments: {'studentId': id},
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.edit, color: Color(0xFF06D6A0)),
              title: Text('Tahrirlash'),
              onTap: () {
                Get.back();
                Get.toNamed(
                  AppRoutes.editStudent,
                  arguments: {'studentId': id},
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.payment, color: Color(0xFFFFC857)),
              title: Text('To\'lov qabul qilish'),
              onTap: () {
                Get.back();
                _makePayment(id);
              },
            ),
            ListTile(
              leading: Icon(Icons.phone, color: Color(0xFF667eea)),
              title: Text('Qo\'ng\'iroq qilish'),
              onTap: () {
                Get.back();
                controller.callParent(parentPhone);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: Color(0xFFFF6B6B)),
              title: Text('O\'chirish'),
              onTap: () {
                Get.back();
                _confirmDelete(student);
              },
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(Map<String, dynamic> student) {
    final String id = student['id'] ?? '';
    final String fullName = student['full_name'] ?? 'O\'quvchi';

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: 400,
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFFFF6B6B).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  size: 48,
                  color: Color(0xFFFF6B6B),
                ),
              ),
              SizedBox(height: 24),
              Text(
                'O\'quvchini o\'chirish',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                'Haqiqatan ham $fullName ni o\'chirmoqchimisiz? Bu amal qaytarilmaydi.',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      child: Text('Bekor qilish'),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        controller.deleteStudent(id);
                      },
                      child: Text('O\'chirish'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFFF6B6B),
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showExportDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: 400,
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFF06D6A0).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.file_download,
                  size: 48,
                  color: Color(0xFF06D6A0),
                ),
              ),
              SizedBox(height: 24),
              Text(
                'Export qilish',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                'Qaysi formatda export qilmoqchisiz?',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              _buildExportOption('Excel (.xlsx)', Icons.table_chart, () {
                Get.back();
                controller.exportToExcel();
              }),
              SizedBox(height: 12),
              _buildExportOption('PDF', Icons.picture_as_pdf, () {
                Get.back();
                controller.exportToPDF();
              }),
              SizedBox(height: 12),
              _buildExportOption('CSV', Icons.description, () {
                Get.back();
                controller.exportToCSV();
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExportOption(String label, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: Color(0xFF667eea)),
            SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            Spacer(),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _showImportDialog() {
    Get.snackbar(
      'Ma\'lumot',
      'Import funksiyasi tez orada qo\'shiladi',
      backgroundColor: Color(0xFF667eea).withOpacity(0.1),
      colorText: Color(0xFF667eea),
      icon: Icon(Icons.file_upload, color: Color(0xFF667eea)),
      snackPosition: SnackPosition.TOP,
      margin: EdgeInsets.all(16),
      borderRadius: 12,
    );
  }

  void _makePayment(String studentId) {
    Get.snackbar(
      'Ma\'lumot',
      'To\'lov qabul qilish funksiyasi tez orada qo\'shiladi',
      backgroundColor: Color(0xFF06D6A0).withOpacity(0.1),
      colorText: Color(0xFF06D6A0),
      icon: Icon(Icons.payment, color: Color(0xFF06D6A0)),
      snackPosition: SnackPosition.TOP,
      margin: EdgeInsets.all(16),
      borderRadius: 12,
    );
  }

  // ==================== HELPER ====================
  String _formatCurrency(double amount) {
    return NumberFormat('#,###').format(amount);
  }
}
