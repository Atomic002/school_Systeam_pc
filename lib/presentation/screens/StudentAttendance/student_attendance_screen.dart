// lib/presentation/screens/attendance/student_attendance_screen.dart
// IZOH: O'quvchilar davomadi - zamonaviy dizayn bilan

import 'package:flutter/material.dart';
import 'package:flutter_application_1/presentation/controllers/student_attandence_controller.dart';
import 'package:get/get.dart';

import '../../widgets/sidebar.dart';

class StudentAttendanceScreen extends StatelessWidget {
  StudentAttendanceScreen({Key? key}) : super(key: key);

  final StudentAttendanceController controller = Get.put(
    StudentAttendanceController(),
  );

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
                    if (controller.isLoading.value &&
                        controller.students.isEmpty) {
                      return _buildLoadingState();
                    }

                    if (controller.selectedClassId.value == null) {
                      return _buildEmptyState();
                    }

                    if (controller.students.isEmpty) {
                      return _buildNoStudentsState();
                    }

                    return Column(
                      children: [
                        _buildQuickStats(),
                        Expanded(child: _buildStudentsList()),
                        _buildBottomBar(),
                      ],
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

  // ---------------- HEADER ----------------

  Widget _buildHeader() {
    return Obx(() {
      final date = controller.selectedDate.value;
      final classId = controller.selectedClassId.value;
      final classes = controller.classes;

      classes.firstWhereOrNull((c) => c['id'] == classId);

      return Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF667eea).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.checklist_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'O\'quvchilar davomadi',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatHeaderDate(date),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildSaveButton(),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    // Sana tanlash
                    Expanded(child: _buildDatePickerField(date)),
                    const SizedBox(width: 16),
                    // Sinf tanlash
                    Expanded(
                      child: _buildClassDropdown(
                        classes: classes,
                        selectedId: classId,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildSaveButton() {
    return Obx(() {
      final isSaving = controller.isSaving.value;

      return ElevatedButton.icon(
        onPressed: isSaving
            ? null
            : () async {
                final classId = controller.selectedClassId.value;
                if (classId == null) {
                  Get.snackbar(
                    'Xatolik',
                    'Iltimos, avval sinf tanlang',
                    snackPosition: SnackPosition.TOP,
                    backgroundColor: Colors.red.shade100,
                  );
                  return;
                }

                final confirmed = await _showConfirmDialog();
                if (!confirmed) return;

                try {
                  await controller.saveAttendance();
                  Get.snackbar(
                    'Muvaffaqiyat',
                    'Davomad saqlandi',
                    snackPosition: SnackPosition.TOP,
                    backgroundColor: Colors.green.shade100,
                  );
                } catch (_) {
                  Get.snackbar(
                    'Xatolik',
                    'Davomadni saqlashda xatolik yuz berdi',
                    snackPosition: SnackPosition.TOP,
                    backgroundColor: Colors.red.shade100,
                  );
                }
              },
        icon: isSaving
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.save),
        label: Text(isSaving ? 'Saqlanmoqda...' : 'Saqlash'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF667eea),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    });
  }

  Widget _buildDatePickerField(DateTime date) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: Get.context!,
          initialDate: date,
          firstDate: DateTime(2024),
          lastDate: DateTime(2026),
        );
        if (picked != null && picked != date) {
          controller.changeDate(picked);
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: Color(0xFF667eea)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sana',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatDate(date),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_drop_down, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildClassDropdown({
    required List<Map<String, String>> classes,
    required String? selectedId,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          hint: const Text('Sinf tanlang'),
          value: selectedId,
          items: classes.map((classItem) {
            return DropdownMenuItem<String>(
              value: classItem['id'],
              child: Row(
                children: [
                  const Icon(Icons.class_, size: 20),
                  const SizedBox(width: 8),
                  Text(classItem['name']!),
                ],
              ),
            );
          }).toList(),
          onChanged: controller.changeClass,
        ),
      ),
    );
  }

  // ---------------- STATISTIKA ----------------

  Widget _buildQuickStats() {
    return Obx(() {
      final statuses = controller.attendanceStatus.values;

      final present = statuses.where((s) => s == 'present').length;
      final absent = statuses.where((s) => s == 'absent').length;
      final late = statuses.where((s) => s == 'late').length;
      final excused = statuses.where((s) => s == 'excused').length;
      final total = statuses.length;

      String percent(int count) {
        if (total == 0) return '0%';
        final p = (count / total * 100).toStringAsFixed(0);
        return '$p%';
      }

      return Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            _buildStatCard(
              icon: Icons.check_circle,
              title: 'Keldi',
              value: '$present / $total',
              subtitle: percent(present),
              color: const Color(0xFF06D6A0),
            ),
            const SizedBox(width: 16),
            _buildStatCard(
              icon: Icons.cancel,
              title: 'Kelmadi',
              value: '$absent / $total',
              subtitle: percent(absent),
              color: const Color(0xFFFF6B6B),
            ),
            const SizedBox(width: 16),
            _buildStatCard(
              icon: Icons.access_time,
              title: 'Kechikdi',
              value: '$late / $total',
              subtitle: percent(late),
              color: const Color(0xFFFFC857),
            ),
            const SizedBox(width: 16),
            _buildStatCard(
              icon: Icons.event_note,
              title: 'Sababli',
              value: '$excused / $total',
              subtitle: percent(excused),
              color: const Color(0xFF667eea),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),
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
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- O'QUVCHILAR RO'YXATI ----------------

  Widget _buildStudentsList() {
    return Obx(() {
      final students = controller.students;
      final statuses = controller.attendanceStatus;

      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        itemCount: students.length,
        itemBuilder: (context, index) {
          final student = students[index];
          final studentId = student['id'] as String;
          final status = statuses[studentId] ?? 'present';

          return _buildStudentCard(
            student: student,
            status: status,
            onStatusChanged: (newStatus) {
              controller.setStatus(studentId, newStatus);
            },
          );
        },
      );
    });
  }

  Widget _buildStudentCard({
    required Map<String, dynamic> student,
    required String status,
    required Function(String) onStatusChanged,
  }) {
    final name = student['name'] as String;
    final initials = _getInitials(name);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: _getStatusColor(status).withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: _getStatusColor(status).withOpacity(0.15),
                  child: Text(
                    initials,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(status),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'ID: ${student['id']}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                _buildStatusPill(status),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildStatusChip(
                  label: 'Keldi',
                  icon: Icons.check_circle,
                  isSelected: status == 'present',
                  color: Colors.green,
                  onTap: () => onStatusChanged('present'),
                ),
                _buildStatusChip(
                  label: 'Kelmadi',
                  icon: Icons.cancel,
                  isSelected: status == 'absent',
                  color: Colors.red,
                  onTap: () => onStatusChanged('absent'),
                ),
                _buildStatusChip(
                  label: 'Kechikdi',
                  icon: Icons.access_time,
                  isSelected: status == 'late',
                  color: Colors.orange,
                  onTap: () => onStatusChanged('late'),
                ),
                _buildStatusChip(
                  label: 'Sababli',
                  icon: Icons.event_note,
                  isSelected: status == 'excused',
                  color: Colors.blue,
                  onTap: () => onStatusChanged('excused'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? color : Colors.grey.shade600,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? color : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusPill(String status) {
    Color color;
    String text;

    switch (status) {
      case 'present':
        color = Colors.green;
        text = 'Keldi';
        break;
      case 'absent':
        color = Colors.red;
        text = 'Kelmadi';
        break;
      case 'late':
        color = Colors.orange;
        text = 'Kechikdi';
        break;
      case 'excused':
        color = Colors.blue;
        text = 'Sababli';
        break;
      default:
        color = Colors.grey;
        text = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  // ---------------- BOTTOM BAR ----------------

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Obx(() {
        final total = controller.students.length;
        final statuses = controller.attendanceStatus.values;
        final present = statuses.where((s) => s == 'present').length;

        return Row(
          children: [
            Text(
              'Jami: $total o\'quvchi, keldi: $present',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: () {
                // Barchasini "keldi" qilib qo'yish
                for (final s in controller.students) {
                  controller.setStatus(s['id'] as String, 'present');
                }
              },
              icon: const Icon(Icons.done_all),
              label: const Text('Barchasini "keldi"'),
            ),
          ],
        );
      }),
    );
  }

  // ---------------- HOLATLAR ----------------

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667eea)),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.class_, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'Avval sinfni tanlang',
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildNoStudentsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.group_off, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'Bu sinfda o\'quvchilar yo\'q',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  // ---------------- HELPERLAR ----------------

  String _formatHeaderDate(DateTime date) {
    const months = [
      'Yanvar',
      'Fevral',
      'Mart',
      'Aprel',
      'May',
      'Iyun',
      'Iyul',
      'Avgust',
      'Sentabr',
      'Oktabr',
      'Noyabr',
      'Dekabr',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatDate(DateTime date) {
    const weekdays = [
      'Dushanba',
      'Seshanba',
      'Chorshanba',
      'Payshanba',
      'Juma',
      'Shanba',
      'Yakshanba',
    ];
    final weekday = weekdays[date.weekday - 1];
    return '$weekday, ${date.day}.${date.month}.${date.year}';
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'present':
        return Colors.green;
      case 'absent':
        return Colors.red;
      case 'late':
        return Colors.orange;
      case 'excused':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return parts[0][0] + parts[1][0];
    }
    return parts[0][0];
  }

  Future<bool> _showConfirmDialog() async {
    final result = await showDialog<bool>(
      context: Get.context!,
      builder: (context) => AlertDialog(
        title: const Text('Tasdiqlash'),
        content: const Text('Davomadni saqlashni xohlaysizmi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Bekor qilish'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Saqlash'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
