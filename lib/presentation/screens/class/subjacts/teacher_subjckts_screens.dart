// lib/presentation/screens/teacher_subjects/teacher_subjects_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_application_1/presentation/controllers/teacher_subjeckts_controller.dart';
import 'package:flutter_application_1/presentation/widgets/sidebar.dart';
import 'package:get/get.dart';

class TeacherSubjectsScreen extends StatelessWidget {
  TeacherSubjectsScreen({Key? key}) : super(key: key);

  final TeacherSubjectsController controller = Get.put(
    TeacherSubjectsController(),
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
                    if (controller.isLoading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          _buildStats(),
                          const SizedBox(height: 24),
                          _buildTeachersList(),
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
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF9800), Color(0xFFF57C00)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF9800).withOpacity(0.3),
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
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.school, size: 32, color: Colors.white),
              ),
              const SizedBox(width: 20),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'O\'qituvchi fanlari',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'O\'qituvchilarni fanlar bilan bog\'lang',
                      style: TextStyle(fontSize: 14, color: Colors.white70),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: controller.showAssignSubjectDialog,
                icon: const Icon(Icons.add),
                label: const Text('Fan biriktirish'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFFFF9800),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStats() {
    return Obx(
      () => Row(
        children: [
          _buildStatCard(
            'Jami o\'qituvchilar',
            controller.totalTeachers.value.toString(),
            Icons.person,
            const Color(0xFFFF9800),
          ),
          const SizedBox(width: 16),
          _buildStatCard(
            'Jami fanlar',
            controller.totalSubjects.value.toString(),
            Icons.book,
            const Color(0xFF4CAF50),
          ),
          const SizedBox(width: 16),
          _buildStatCard(
            'Bog\'lanishlar',
            controller.totalAssignments.value.toString(),
            Icons.link,
            const Color(0xFF2196F3),
          ),
          const SizedBox(width: 16),
          _buildStatCard(
            'Asosiy fanlar',
            controller.primarySubjects.value.toString(),
            Icons.star,
            const Color(0xFFFFC107),
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
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [color, color.withOpacity(0.8)]),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 14, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeachersList() {
    return Container(
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
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'O\'qituvchi qidirish...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: controller.searchTeachers,
                  ),
                ),
              ],
            ),
          ),
          Obx(() {
            final teachers = controller.filteredTeachers;
            if (teachers.isEmpty) {
              return _buildEmptyState();
            }
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: teachers.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) =>
                  _buildTeacherItem(teachers[index]),
            );
          }),
        ],
      ),
    );
  }

Widget _buildTeacherItem(Map<String, dynamic> teacher) {
  final subjects = teacher['subjects'] as List? ?? [];
  
  // O'zgartirilgan joy:
final primarySubject = subjects
    .cast<Map<String, dynamic>?>() 
    .firstWhere(
      (s) => s?['is_primary'] == true,
      orElse: () => null,
    );

    return ExpansionTile(
      leading: CircleAvatar(
        backgroundColor: const Color(0xFFFF9800),
        child: Text(
          (teacher['first_name'] as String? ?? '?')[0].toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        '${teacher['first_name']} ${teacher['last_name']}',
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      subtitle: primarySubject != null
          ? Row(
              children: [
                const Icon(Icons.star, size: 14, color: Colors.amber),
                const SizedBox(width: 4),
                Text(
                  primarySubject['subject_name'],
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            )
          : Text(
              '${subjects.length} ta fan',
              style: const TextStyle(fontSize: 12),
            ),
      children: [
        if (subjects.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Hali fanlar biriktirilmagan',
              style: TextStyle(color: Colors.grey[600]),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: subjects.map<Widget>((subject) {
                final isPrimary = subject['is_primary'] == true;
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isPrimary
                          ? [Colors.amber, Colors.amber.shade700]
                          : [
                              const Color(0xFFFF9800).withOpacity(0.1),
                              const Color(0xFFF57C00).withOpacity(0.05),
                            ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isPrimary
                          ? Colors.amber
                          : const Color(0xFFFF9800).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isPrimary)
                        const Icon(Icons.star, size: 16, color: Colors.white)
                      else
                        const Icon(
                          Icons.book,
                          size: 16,
                          color: Color(0xFFFF9800),
                        ),
                      const SizedBox(width: 6),
                      Text(
                        subject['subject_name'],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isPrimary
                              ? Colors.white
                              : const Color(0xFFFF9800),
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () => controller.removeSubject(
                          teacher['id'],
                          subject['subject_id'],
                        ),
                        child: Icon(
                          Icons.close,
                          size: 16,
                          color: isPrimary ? Colors.white : Colors.red,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () => controller.showAssignSubjectDialog(
                  teacherId: teacher['id'],
                ),
                icon: const Icon(Icons.add),
                label: const Text('Fan qo\'shish'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFFF9800),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.school_outlined, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'O\'qituvchilar topilmadi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Avval o\'qituvchilarni kiriting',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
