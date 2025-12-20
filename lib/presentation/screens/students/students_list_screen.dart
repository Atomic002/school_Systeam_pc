// lib/presentation/screens/students/students_list_screen.dart
// ZAMONAVIY VA MUKAMMAL DIZAYN - O'QUVCHILAR RO'YXATI

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/students_controller.dart';
import '../../widgets/sidebar.dart';
import '../../../config/app_routes.dart';

class StudentsListScreen extends StatelessWidget {
  StudentsListScreen({Key? key}) : super(key: key);

  final StudentsController controller = Get.put(StudentsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Row(
        children: [
          // Sidebar
          Sidebar(),

          // Main Content
          Expanded(
            child: Column(
              children: [
                // Modern AppBar
                _buildModernAppBar(),

                // Content Area
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value &&
                        controller.students.isEmpty) {
                      return _buildLoadingState();
                    }
                    return _buildMainContent();
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Modern AppBar with gradient
  Widget _buildModernAppBar() {
    return Container(
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
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Title Section
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
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(height: 8),
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

                  // Action Buttons
                  _buildActionButtons(),
                ],
              ),

              SizedBox(height: 20),

              // Search and Filter Row
              _buildSearchAndFilter(),
            ],
          ),
        ),
      ),
    );
  }

  // Action Buttons
  Widget _buildActionButtons() {
    return Row(
      children: [
        // Export Button
        _buildHeaderButton(
          icon: Icons.file_download_outlined,
          label: 'Export',
          onTap: () => _exportStudents(),
        ),
        SizedBox(width: 12),

        // Import Button
        _buildHeaderButton(
          icon: Icons.file_upload_outlined,
          label: 'Import',
          onTap: () => _importStudents(),
        ),
        SizedBox(width: 12),

        // Add Student Button
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
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                child: Row(
                  children: [
                    Icon(Icons.add_circle_outline, color: Color(0xFF667eea)),
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
      ],
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

  // Search and Filter
  Widget _buildSearchAndFilter() {
    return Row(
      children: [
        // Search Box
        Expanded(
          flex: 3,
          child: Container(
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
              onChanged: (value) => controller.searchStudents(value),
              decoration: InputDecoration(
                hintText:
                    'Ism, familiya yoki telefon raqam bo\'yicha qidirish...',
                prefixIcon: Icon(Icons.search, color: Color(0xFF667eea)),
                suffixIcon: Obx(
                  () => controller.searchQuery.value.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, color: Colors.grey),
                          onPressed: () => controller.searchStudents(''),
                        )
                      : SizedBox(),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
            ),
          ),
        ),

        SizedBox(width: 16),

        // Filter Chips
        _buildFilterChip(
          label: 'Faol',
          isSelected: controller.selectedStatus.value == 'active',
          onTap: () => controller.setStatusFilter(
            controller.selectedStatus.value == 'active' ? null : 'active',
          ),
        ),

        SizedBox(width: 12),

        _buildFilterChip(
          label: 'To\'xtatilgan',
          isSelected: controller.selectedStatus.value == 'paused',
          onTap: () => controller.setStatusFilter(
            controller.selectedStatus.value == 'paused' ? null : 'paused',
          ),
        ),

        SizedBox(width: 12),

        // Advanced Filters Button
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: Icon(Icons.tune, color: Color(0xFF667eea)),
            onPressed: () => _showAdvancedFilters(),
            tooltip: 'Qo\'shimcha filtrlar',
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.3),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSelected)
                  Icon(Icons.check_circle, color: Color(0xFF667eea), size: 18),
                if (isSelected) SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Color(0xFF667eea) : Colors.white,
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

  // Main Content
  Widget _buildMainContent() {
    return Obx(() {
      if (controller.students.isEmpty) {
        return _buildEmptyState();
      }

      return Column(
        children: [
          // Quick Stats
          _buildQuickStats(),

          // Students Grid
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => controller.refreshData(),
              child: _buildStudentsGrid(),
            ),
          ),

          // Pagination
          _buildModernPagination(),
        ],
      );
    });
  }

  // Quick Stats
  Widget _buildQuickStats() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        children: [
          _buildStatCard(
            icon: Icons.school,
            title: 'Jami o\'quvchilar',
            value: '${controller.totalCount.value}',
            color: Color(0xFF667eea),
          ),
          SizedBox(width: 16),
          _buildStatCard(
            icon: Icons.people,
            title: 'Faol o\'quvchilar',
            value:
                '${controller.students.where((s) => s.status == 'active').length}',
            color: Color(0xFF06D6A0),
          ),
          SizedBox(width: 16),
          _buildStatCard(
            icon: Icons.pause_circle,
            title: 'To\'xtatilgan',
            value:
                '${controller.students.where((s) => s.status == 'paused').length}',
            color: Color(0xFFFFC857),
          ),
          SizedBox(width: 16),
          _buildStatCard(
            icon: Icons.star,
            title: 'Bitirganlar',
            value:
                '${controller.students.where((s) => s.status == 'graduated').length}',
            color: Color(0xFFFF6B6B),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
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

  // Students Grid
  Widget _buildStudentsGrid() {
    return GridView.builder(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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

  // Modern Student Card
  Widget _buildStudentCard(student, int index) {
    final colors = [
      Color(0xFF667eea),
      Color(0xFF06D6A0),
      Color(0xFFFFC857),
      Color(0xFFFF6B6B),
    ];
    final cardColor = colors[index % colors.length];

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
          onTap: () =>
              Get.toNamed(AppRoutes.studentDetail, arguments: student.id),
          borderRadius: BorderRadius.circular(20),
          child: Column(
            children: [
              // Header with gradient
              Container(
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [cardColor, cardColor.withOpacity(0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Stack(
                  children: [
                    // Avatar
                    Center(
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: Center(
                          child: Text(
                            student.firstName[0] + student.lastName[0],
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: cardColor,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Status Badge
                    Positioned(
                      top: 12,
                      right: 12,
                      child: _buildStatusBadge(student.status),
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
                      // Name
                      Text(
                        student.fullName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      SizedBox(height: 8),

                      // Info Rows
                      _buildInfoRow(
                        Icons.phone,
                        student.parentPhone,
                        cardColor,
                      ),
                      SizedBox(height: 6),
                      _buildInfoRow(
                        Icons.calendar_today,
                        '${student.age} yosh',
                        cardColor,
                      ),
                      SizedBox(height: 6),
                      _buildInfoRow(
                        Icons.attach_money,
                        '${_formatCurrency((student.finalMonthlyFee ?? 0).toDouble())} so\'m',
                        cardColor,
                      ),

                      Spacer(),

                      // Actions
                      Row(
                        children: [
                          Expanded(
                            child: _buildCardActionButton(
                              Icons.visibility_outlined,
                              'Ko\'rish',
                              cardColor,
                              () => Get.toNamed(
                                AppRoutes.studentDetail,
                                arguments: student.id,
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          _buildCardIconButton(
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
    Color color;
    String text;
    IconData icon;

    switch (status) {
      case 'active':
        color = Color(0xFF06D6A0);
        text = 'Faol';
        icon = Icons.check_circle;
        break;
      case 'paused':
        color = Color(0xFFFFC857);
        text = 'To\'xtatilgan';
        icon = Icons.pause_circle;
        break;
      case 'graduated':
        color = Color(0xFF667eea);
        text = 'Bitirgan';
        icon = Icons.school;
        break;
      case 'expelled':
        color = Color(0xFFFF6B6B);
        text = 'Chiqarilgan';
        icon = Icons.cancel;
        break;
      default:
        color = Colors.grey;
        text = status;
        icon = Icons.help;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
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

  Widget _buildCardActionButton(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 16, color: color),
                SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardIconButton(IconData icon, Color color, VoidCallback onTap) {
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

  // Modern Pagination
  Widget _buildModernPagination() {
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
          Text(
            'Ko\'rsatilmoqda: ${controller.students.length} ta yozuv',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),

          Spacer(),

          // Previous Button
          _buildPaginationButton(
            Icons.chevron_left,
            controller.hasPreviousPage,
            () => controller.previousPage(),
          ),

          SizedBox(width: 12),

          // Page Info
          Container(
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

          SizedBox(width: 12),

          // Next Button
          _buildPaginationButton(
            Icons.chevron_right,
            controller.hasNextPage,
            () => controller.nextPage(),
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

  // Empty State
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
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
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

  // Loading State
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

  // Helper Methods
  String _formatCurrency(double amount) {
    return amount
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  void _showStudentOptions(student) {
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
              leading: Icon(Icons.edit, color: Color(0xFF667eea)),
              title: Text('Tahrirlash'),
              onTap: () {
                Get.back();
                _editStudent(student.id);
              },
            ),
            ListTile(
              leading: Icon(Icons.payment, color: Color(0xFF06D6A0)),
              title: Text('To\'lov qabul qilish'),
              onTap: () {
                Get.back();
                _makePayment(student.id);
              },
            ),
            ListTile(
              leading: Icon(Icons.history, color: Color(0xFFFFC857)),
              title: Text('To\'lovlar tarixi'),
              onTap: () {
                Get.back();
                _showPaymentHistory(student.id);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: Color(0xFFFF6B6B)),
              title: Text('O\'chirish'),
              onTap: () {
                Get.back();
                _deleteStudent(student.id);
              },
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showAdvancedFilters() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Qo\'shimcha filtrlar'),
        content: Container(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Status filter
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: [
                  DropdownMenuItem(value: null, child: Text('Barchasi')),
                  DropdownMenuItem(value: 'active', child: Text('Faol')),
                  DropdownMenuItem(
                    value: 'paused',
                    child: Text('To\'xtatilgan'),
                  ),
                  DropdownMenuItem(value: 'graduated', child: Text('Bitirgan')),
                  DropdownMenuItem(
                    value: 'expelled',
                    child: Text('Chiqarilgan'),
                  ),
                ],
                onChanged: (value) => controller.setStatusFilter(value),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              controller.clearAllFilters();
              Get.back();
            },
            child: Text('Tozalash'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(),
            child: Text('Qo\'llash'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF667eea),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _editStudent(String studentId) {
    Get.snackbar(
      'Ma\'lumot',
      'Tahrirlash funksiyasi tez orada qo\'shiladi',
      backgroundColor: Color(0xFF667eea).withOpacity(0.1),
      colorText: Color(0xFF667eea),
      icon: Icon(Icons.edit, color: Color(0xFF667eea)),
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

  void _showPaymentHistory(String studentId) {
    Get.snackbar(
      'Ma\'lumot',
      'To\'lovlar tarixi tez orada qo\'shiladi',
      backgroundColor: Color(0xFFFFC857).withOpacity(0.1),
      colorText: Color(0xFFFFC857),
      icon: Icon(Icons.history, color: Color(0xFFFFC857)),
      snackPosition: SnackPosition.TOP,
      margin: EdgeInsets.all(16),
      borderRadius: 12,
    );
  }

  void _deleteStudent(String studentId) {
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
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Haqiqatan ham bu o\'quvchini o\'chirmoqchimisiz? Bu amal qaytarilmaydi.',
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
                        controller.deleteStudent(studentId);
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

  void _exportStudents() {
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
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Qaysi formatda export qilmoqchisiz?',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              _buildExportButton('Excel (.xlsx)', Icons.table_chart, () {
                Get.back();
                Get.snackbar(
                  'Ma\'lumot',
                  'Excel export tez orada qo\'shiladi',
                  backgroundColor: Color(0xFF06D6A0).withOpacity(0.1),
                  colorText: Color(0xFF06D6A0),
                );
              }),
              SizedBox(height: 12),
              _buildExportButton('PDF', Icons.picture_as_pdf, () {
                Get.back();
                Get.snackbar(
                  'Ma\'lumot',
                  'PDF export tez orada qo\'shiladi',
                  backgroundColor: Color(0xFF06D6A0).withOpacity(0.1),
                  colorText: Color(0xFF06D6A0),
                );
              }),
              SizedBox(height: 12),
              _buildExportButton('CSV', Icons.description, () {
                Get.back();
                Get.snackbar(
                  'Ma\'lumot',
                  'CSV export tez orada qo\'shiladi',
                  backgroundColor: Color(0xFF06D6A0).withOpacity(0.1),
                  colorText: Color(0xFF06D6A0),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExportButton(String label, IconData icon, VoidCallback onTap) {
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

  void _importStudents() {
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
}
