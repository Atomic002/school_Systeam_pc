// lib/presentation/screens/rooms_classes/room_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_application_1/presentation/controllers/room_detail_controller.dart';
import 'package:flutter_application_1/presentation/widgets/sidebar.dart';
import 'package:get/get.dart';

class RoomDetailScreen extends StatelessWidget {
  RoomDetailScreen({Key? key}) : super(key: key);

  final RoomDetailController controller = Get.put(RoomDetailController());

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
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (controller.room.value == null) {
                      return _buildErrorState();
                    }
                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 2,
                                child: Column(
                                  children: [
                                    _buildRoomInfo(),
                                    const SizedBox(height: 20),
                                    _buildEquipment(),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                flex: 3,
                                child: Column(
                                  children: [
                                    _buildAssignedClasses(),
                                    const SizedBox(height: 20),
                                    _buildAssignedTeachers(),
                                    const SizedBox(height: 20),
                                    _buildAssignedStudents(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Obx(() {
      final room = controller.room.value;
      if (room == null) return const SizedBox();

      return Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2196F3).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Get.back(),
                ),
                const SizedBox(width: 16),
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.meeting_room,
                    size: 40,
                    color: Color(0xFF2196F3),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        room['name'],
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildBadge(
                            Icons.people,
                            'Sig\'im: ${room['capacity']}',
                          ),
                          const SizedBox(width: 12),
                          _buildBadge(Icons.layers, '${room['floor']}-qavat'),
                          const SizedBox(width: 12),
                          _buildBadge(
                            Icons.category,
                            room['room_type'] ?? 'Oddiy',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        _buildHeaderButton(
          icon: Icons.edit,
          label: 'Tahrirlash',
          onTap: controller.editRoom,
        ),
        const SizedBox(width: 12),
        _buildHeaderButton(
          icon: Icons.delete,
          label: 'O\'chirish',
          onTap: controller.deleteRoom,
          isDestructive: true,
        ),
      ],
    );
  }

  Widget _buildHeaderButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDestructive
            ? Colors.red.withOpacity(0.2)
            : Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDestructive
              ? Colors.red.withOpacity(0.3)
              : Colors.white.withOpacity(0.3),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Icon(icon, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoomInfo() {
    return Obx(() {
      final room = controller.room.value!;
      return _buildCard(
        title: 'Xona ma\'lumotlari',
        icon: Icons.info,
        child: Column(
          children: [
            _buildInfoRow('Xona nomi', room['name']),
            _buildInfoRow('Filial', room['branch_name'] ?? '—'),
            _buildInfoRow('Sig\'im', '${room['capacity']} kishi'),
            _buildInfoRow('Qavat', '${room['floor']}-qavat'),
            _buildInfoRow('Xona turi', room['room_type'] ?? '—'),
            _buildInfoRow(
              'Holati',
              room['is_available'] ? 'Bo\'sh' : 'Band',
              isHighlighted: true,
            ),
          ],
        ),
      );
    });
  }

  Widget _buildEquipment() {
    return Obx(() {
      final equipment = controller.room.value?['equipment'];
      return _buildCard(
        title: 'Jihozlar',
        icon: Icons.devices,
        child: equipment != null && equipment.toString().isNotEmpty
            ? Text(
                equipment,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              )
            : const Text(
                'Jihozlar kiritilmagan',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
      );
    });
  }

  Widget _buildAssignedClasses() {
    return Obx(() {
      final classes = controller.assignedClasses;
      return _buildCard(
        title: 'Biriktirilgan sinflar',
        icon: Icons.school,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFF2196F3)),
            onPressed: controller.assignClass,
          ),
        ],
        child: classes.isEmpty
            ? _buildEmptySection('Sinflar biriktirilmagan')
            : ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: classes.length,
                separatorBuilder: (_, __) => const Divider(height: 16),
                itemBuilder: (context, index) =>
                    _buildClassItem(classes[index]),
              ),
      );
    });
  }

  Widget _buildClassItem(Map<String, dynamic> cls) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF4CAF50).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF4CAF50).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.school, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cls['name'],
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (cls['teacher_name'] != null)
                  Text(
                    cls['teacher_name'],
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
              ],
            ),
          ),
          Text(
            '${cls['student_count']} o\'quvchi',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildAssignedTeachers() {
    return Obx(() {
      final teachers = controller.assignedTeachers;
      return _buildCard(
        title: 'Biriktirilgan o\'qituvchilar',
        icon: Icons.person,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFF2196F3)),
            onPressed: controller.assignTeacher,
          ),
        ],
        child: teachers.isEmpty
            ? _buildEmptySection('O\'qituvchilar biriktirilmagan')
            : ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: teachers.length,
                separatorBuilder: (_, __) => const Divider(height: 16),
                itemBuilder: (context, index) =>
                    _buildTeacherItem(teachers[index]),
              ),
      );
    });
  }

  Widget _buildTeacherItem(Map<String, dynamic> teacher) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2196F3).withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF2196F3).withOpacity(0.2)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFF2196F3),
            child: Text(
              teacher['first_name'][0] + teacher['last_name'][0],
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${teacher['first_name']} ${teacher['last_name']}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (teacher['subjects'] != null)
                  Text(
                    teacher['subjects'].join(', '),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.red, size: 20),
            onPressed: () => controller.unassignTeacher(teacher['id']),
          ),
        ],
      ),
    );
  }

  Widget _buildAssignedStudents() {
    return Obx(() {
      final students = controller.assignedStudents;
      return _buildCard(
        title: 'O\'quvchilar (${students.length})',
        icon: Icons.people,
        child: students.isEmpty
            ? _buildEmptySection('O\'quvchilar yo\'q')
            : ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: students.take(10).length,
                separatorBuilder: (_, __) => const Divider(height: 12),
                itemBuilder: (context, index) =>
                    _buildStudentItem(students[index]),
              ),
      );
    });
  }

  Widget _buildStudentItem(Map<String, dynamic> student) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: Colors.orange,
        child: Text(
          student['first_name'][0],
          style: const TextStyle(color: Colors.white),
        ),
      ),
      title: Text(
        '${student['first_name']} ${student['last_name']}',
        style: const TextStyle(fontSize: 14),
      ),
      subtitle: Text(
        student['class_name'] ?? '',
        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
      ),
      trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
      onTap: () {
        // O'quvchi detayliga o'tish
      },
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required Widget child,
    List<Widget>? actions,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              if (actions != null) ...actions,
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    bool isHighlighted = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: isHighlighted ? const Color(0xFF2196F3) : Colors.black87,
                fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySection(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(Icons.inbox, size: 60, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: Colors.red.shade300),
          const SizedBox(height: 16),
          Text(
            'Xona topilmadi',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Orqaga'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
