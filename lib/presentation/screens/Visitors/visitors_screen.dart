import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/visitors_controller.dart';
import '../../widgets/sidebar.dart';

class VisitorsScreen extends StatelessWidget {
  VisitorsScreen({Key? key}) : super(key: key);

  final VisitorsController controller = Get.put(VisitorsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Row(
        children: [
          Sidebar(),
          Expanded(
            child: Column(
              children: [
                _buildHeader(),
                _buildFilterBar(),
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (controller.filteredVisitors.isEmpty) {
                      return _buildEmptyState();
                    }
                    return _buildVisitorsList();
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddVisitorDialog(),
        backgroundColor: const Color(0xFF2196F3),
        icon: const Icon(Icons.add),
        label: const Text('Yangi tashrif'),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2196F3).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.people_outline,
                  color: Color(0xFF2196F3),
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tashrif buyuruvchilar',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Potentsial o\'quvchilar va xodimlar',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
              const Spacer(),
              Obx(
                () => _buildStatCard(
                  'Jami',
                  controller.visitors.length.toString(),
                  Icons.people,
                  const Color(0xFF2196F3),
                ),
              ),
              const SizedBox(width: 12),
              Obx(
                () => _buildStatCard(
                  'Konvertatsiya qilingan',
                  controller.convertedCount.toString(),
                  Icons.check_circle,
                  const Color(0xFF4CAF50),
                ),
              ),
              const SizedBox(width: 12),
              Obx(
                () => _buildStatCard(
                  'Kutilmoqda',
                  controller.pendingCount.toString(),
                  Icons.pending,
                  const Color(0xFFFF9800),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: TextField(
              onChanged: controller.searchVisitors,
              decoration: InputDecoration(
                hintText: 'Qidirish (ism, familiya, telefon)...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF2196F3)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Obx(
              () => DropdownButtonFormField<String>(
                value: controller.selectedTypeFilter.value,
                decoration: InputDecoration(
                  prefixIcon: const Icon(
                    Icons.filter_list,
                    color: Color(0xFF2196F3),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('Barcha turlar')),
                  DropdownMenuItem(
                    value: 'student',
                    child: Text('O\'quvchilar'),
                  ),
                  DropdownMenuItem(
                    value: 'teacher',
                    child: Text('O\'qituvchilar'),
                  ),
                  DropdownMenuItem(value: 'staff', child: Text('Xodimlar')),
                ],
                onChanged: controller.filterByType,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Obx(
              () => DropdownButtonFormField<String>(
                value: controller.selectedStatusFilter.value,
                decoration: InputDecoration(
                  prefixIcon: const Icon(
                    Icons.check_circle,
                    color: Color(0xFF2196F3),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'all',
                    child: Text('Barcha holatlar'),
                  ),
                  DropdownMenuItem(value: 'pending', child: Text('Kutilmoqda')),
                  DropdownMenuItem(
                    value: 'converted',
                    child: Text('Konvertatsiya qilingan'),
                  ),
                ],
                onChanged: controller.filterByStatus,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisitorsList() {
    return Obx(
      () => ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.filteredVisitors.length,
        itemBuilder: (context, index) {
          final visitor = controller.filteredVisitors[index];
          return _buildVisitorCard(visitor);
        },
      ),
    );
  }

  Widget _buildVisitorCard(Map<String, dynamic> visitor) {
    final isConverted = visitor['is_converted'] ?? false;
    final visitorType = visitor['visitor_type'] ?? 'student';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isConverted
              ? const Color(0xFF4CAF50).withOpacity(0.3)
              : Colors.grey[200]!,
          width: isConverted ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _showVisitorDetails(visitor),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    _buildAvatar(visitor),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${visitor['first_name']} ${visitor['last_name']}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              _buildTypeChip(visitorType),
                              const SizedBox(width: 8),
                              if (isConverted) _buildConvertedBadge(),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.phone,
                                size: 16,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                visitor['phone'] ?? 'N/A',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              if (visitor['phone_secondary'] != null) ...[
                                const SizedBox(width: 16),
                                const Icon(
                                  Icons.phone_android,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  visitor['phone_secondary'],
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.business,
                                size: 16,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                controller.getBranchName(visitor['branch_id']),
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(width: 16),
                              const Icon(
                                Icons.calendar_today,
                                size: 16,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Tashrif: ${_formatDate(visitor['visit_date'])}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (visitor['notes'] != null &&
                    visitor['notes'].toString().isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.note, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            visitor['notes'],
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 13,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (!isConverted) ...[
                      TextButton.icon(
                        onPressed: () => _showConvertDialog(visitor),
                        icon: const Icon(Icons.person_add, size: 18),
                        label: Text(
                          visitorType == 'student'
                              ? 'O\'quvchiga aylantirish'
                              : 'Xodimga aylantirish',
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF4CAF50),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    IconButton(
                      onPressed: () => _showEditDialog(visitor),
                      icon: const Icon(Icons.edit, size: 20),
                      color: const Color(0xFF2196F3),
                      tooltip: 'Tahrirlash',
                    ),
                    IconButton(
                      onPressed: () => _confirmDelete(visitor['id']),
                      icon: const Icon(Icons.delete, size: 20),
                      color: const Color(0xFFF44336),
                      tooltip: 'O\'chirish',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(Map<String, dynamic> visitor) {
    final gender = visitor['gender'] ?? 'male';
    final color = gender == 'female'
        ? const Color(0xFFE91E63)
        : const Color(0xFF2196F3);

    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(color: color.withOpacity(0.3), width: 2),
      ),
      child: Center(
        child: Text(
          visitor['first_name'][0].toUpperCase(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }

  Widget _buildTypeChip(String type) {
    final configs = {
      'student': {
        'label': 'O\'quvchi',
        'color': const Color(0xFF2196F3),
        'icon': Icons.school,
      },
      'teacher': {
        'label': 'O\'qituvchi',
        'color': const Color(0xFF9C27B0),
        'icon': Icons.person,
      },
      'staff': {
        'label': 'Xodim',
        'color': const Color(0xFFFF9800),
        'icon': Icons.badge,
      },
    };

    final config = configs[type] ?? configs['student']!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: (config['color'] as Color).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: (config['color'] as Color).withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            config['icon'] as IconData,
            size: 14,
            color: config['color'] as Color,
          ),
          const SizedBox(width: 4),
          Text(
            config['label'] as String,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: config['color'] as Color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConvertedBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF4CAF50).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF4CAF50).withOpacity(0.3)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, size: 14, color: Color(0xFF4CAF50)),
          SizedBox(width: 4),
          Text(
            'Qo\'shildi',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF4CAF50),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 100, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Tashrif buyuruvchilar yo\'q',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Yangi tashrif buyuruvchi qo\'shish uchun "Yangi tashrif" tugmasini bosing',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  void _showAddVisitorDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 800,
          padding: const EdgeInsets.all(24),
          child: _VisitorForm(controller: controller),
        ),
      ),
    );
  }

  void _showEditDialog(Map<String, dynamic> visitor) {
    controller.prepareEdit(visitor);
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 800,
          padding: const EdgeInsets.all(24),
          child: _VisitorForm(controller: controller, isEdit: true),
        ),
      ),
    );
  }

  void _showVisitorDetails(Map<String, dynamic> visitor) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 700,
          padding: const EdgeInsets.all(24),
          child: _VisitorDetailsView(visitor: visitor, controller: controller),
        ),
      ),
    );
  }

  void _showConvertDialog(Map<String, dynamic> visitor) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.person_add, color: Color(0xFF4CAF50)),
            SizedBox(width: 12),
            Text('Konvertatsiya qilish'),
          ],
        ),
        content: Text(
          visitor['visitor_type'] == 'student'
              ? 'Ushbu tashrif buyuruvchini o\'quvchiga aylantirasizmi?'
              : 'Ushbu tashrif buyuruvchini xodimga aylantirasizmi?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Bekor qilish'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.convertVisitor(visitor);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
            ),
            child: const Text('Konvertatsiya qilish'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(String id) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning, color: Color(0xFFF44336)),
            SizedBox(width: 12),
            Text('O\'chirish'),
          ],
        ),
        content: const Text('Ushbu tashrif buyuruvchini o\'chirmoqchimisiz?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Bekor qilish'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.deleteVisitor(id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF44336),
            ),
            child: const Text('O\'chirish'),
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    try {
      final DateTime dateTime = date is DateTime
          ? date
          : DateTime.parse(date.toString());
      return DateFormat('dd.MM.yyyy').format(dateTime);
    } catch (e) {
      return 'N/A';
    }
  }
}

class _VisitorForm extends StatelessWidget {
  final VisitorsController controller;
  final bool isEdit;

  const _VisitorForm({required this.controller, this.isEdit = false});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                isEdit ? Icons.edit : Icons.add,
                color: const Color(0xFF2196F3),
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                isEdit ? 'Tahrirlash' : 'Yangi tashrif buyuruvchi',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Branch selection
          Obx(() {
            if (controller.branches.isEmpty) {
              return const SizedBox.shrink();
            }
            return Column(
              children: [
                DropdownButtonFormField<String>(
                  value: controller.selectedBranchId.value?.isEmpty ?? true
                      ? null
                      : controller.selectedBranchId.value,
                  decoration: const InputDecoration(
                    labelText: 'Filial *',
                    prefixIcon: Icon(Icons.business, color: Color(0xFF2196F3)),
                    border: OutlineInputBorder(),
                  ),
                  items: controller.branches.map((branch) {
                    return DropdownMenuItem<String>(
                      value: branch['id'],
                      child: Text(branch['name'] ?? 'N/A'),
                    );
                  }).toList(),
                  onChanged: (value) => controller.updateBranch(value),
                ),
                const SizedBox(height: 16),
              ],
            );
          }),

          // Visitor type
          Obx(
            () => DropdownButtonFormField<String>(
              value: controller.visitorType.value,
              decoration: const InputDecoration(
                labelText: 'Tashrif turi *',
                prefixIcon: Icon(Icons.person_pin, color: Color(0xFF2196F3)),
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'student', child: Text('O\'quvchi')),
                DropdownMenuItem(value: 'teacher', child: Text('O\'qituvchi')),
                DropdownMenuItem(value: 'staff', child: Text('Xodim')),
              ],
              onChanged: (v) {
                if (v != null) controller.visitorType.value = v;
              },
            ),
          ),
          const SizedBox(height: 16),

          // Personal info
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller.firstNameController,
                  decoration: const InputDecoration(
                    labelText: 'Ism *',
                    prefixIcon: Icon(Icons.person, color: Color(0xFF2196F3)),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: controller.lastNameController,
                  decoration: const InputDecoration(
                    labelText: 'Familiya *',
                    prefixIcon: Icon(
                      Icons.person_outline,
                      color: Color(0xFF2196F3),
                    ),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller.phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Telefon *',
                    prefixIcon: Icon(Icons.phone, color: Color(0xFF2196F3)),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: controller.phoneSecondaryController,
                  decoration: const InputDecoration(
                    labelText: 'Telefon 2',
                    prefixIcon: Icon(
                      Icons.phone_android,
                      color: Color(0xFF2196F3),
                    ),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: Obx(
                  () => DropdownButtonFormField<String>(
                    value: controller.gender.value,
                    decoration: const InputDecoration(
                      labelText: 'Jinsi',
                      prefixIcon: Icon(Icons.wc, color: Color(0xFF2196F3)),
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'male', child: Text('Erkak')),
                      DropdownMenuItem(value: 'female', child: Text('Ayol')),
                    ],
                    onChanged: (v) {
                      if (v != null) controller.gender.value = v;
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: () => controller.selectBirthDate(context),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Tug\'ilgan sana',
                      prefixIcon: Icon(Icons.cake, color: Color(0xFF2196F3)),
                      border: OutlineInputBorder(),
                    ),
                    child: Obx(() {
                      final date = controller.birthDate.value;
                      return Text(
                        date != null
                            ? DateFormat('dd.MM.yyyy').format(date)
                            : 'Sanani tanlang',
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Address
          TextField(
            controller: controller.addressController,
            decoration: const InputDecoration(
              labelText: 'Manzil',
              prefixIcon: Icon(Icons.home, color: Color(0xFF2196F3)),
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 16),

          // Interested course/position
          Obx(() {
            if (controller.visitorType.value == 'student') {
              return TextField(
                controller: controller.interestedCourseController,
                decoration: const InputDecoration(
                  labelText: 'Qiziqish bildirgan kurs',
                  prefixIcon: Icon(Icons.school, color: Color(0xFF2196F3)),
                  border: OutlineInputBorder(),
                ),
              );
            } else {
              return TextField(
                controller: controller.desiredPositionController,
                decoration: const InputDecoration(
                  labelText: 'Istalgan lavozim',
                  prefixIcon: Icon(Icons.work, color: Color(0xFF2196F3)),
                  border: OutlineInputBorder(),
                ),
              );
            }
          }),
          const SizedBox(height: 16),

          // Notes
          TextField(
            controller: controller.notesController,
            decoration: const InputDecoration(
              labelText: 'Izohlar',
              prefixIcon: Icon(Icons.note, color: Color(0xFF2196F3)),
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('Bekor qilish'),
              ),
              const SizedBox(width: 12),
              Obx(
                () => ElevatedButton(
                  onPressed: controller.isSaving.value
                      ? null
                      : () {
                          if (isEdit) {
                            controller.updateVisitor();
                          } else {
                            controller.addVisitor();
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2196F3),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                  child: controller.isSaving.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(isEdit ? 'Saqlash' : 'Qo\'shish'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _VisitorDetailsView extends StatelessWidget {
  final Map<String, dynamic> visitor;
  final VisitorsController controller;

  const _VisitorDetailsView({required this.visitor, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.info, color: Color(0xFF2196F3), size: 28),
              const SizedBox(width: 12),
              const Text(
                'Tashrif buyuruvchi ma\'lumotlari',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildDetailRow(
            'Ism',
            '${visitor['first_name']} ${visitor['last_name']}',
            Icons.person,
          ),
          _buildDetailRow('Telefon', visitor['phone'] ?? 'N/A', Icons.phone),
          if (visitor['phone_secondary'] != null)
            _buildDetailRow(
              'Telefon 2',
              visitor['phone_secondary'],
              Icons.phone_android,
            ),
          _buildDetailRow(
            'Jinsi',
            visitor['gender'] == 'male' ? 'Erkak' : 'Ayol',
            Icons.wc,
          ),
          if (visitor['birth_date'] != null)
            _buildDetailRow(
              'Tug\'ilgan sana',
              _formatDate(visitor['birth_date']),
              Icons.cake,
            ),
          _buildDetailRow(
            'Filial',
            controller.getBranchName(visitor['branch_id']),
            Icons.business,
          ),
          if (visitor['address'] != null)
            _buildDetailRow('Manzil', visitor['address'], Icons.home),
          if (visitor['interested_course'] != null)
            _buildDetailRow('Kurs', visitor['interested_course'], Icons.school),
          if (visitor['desired_position'] != null)
            _buildDetailRow('Lavozim', visitor['desired_position'], Icons.work),
          if (visitor['notes'] != null &&
              visitor['notes'].toString().isNotEmpty)
            _buildDetailRow('Izohlar', visitor['notes'], Icons.note),
          _buildDetailRow(
            'Tashrif sanasi',
            _formatDate(visitor['visit_date']),
            Icons.calendar_today,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text('Yopish'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF2196F3), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    try {
      final DateTime dateTime = date is DateTime
          ? date
          : DateTime.parse(date.toString());
      return DateFormat('dd.MM.yyyy').format(dateTime);
    } catch (e) {
      return 'N/A';
    }
  }
}
