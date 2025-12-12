// lib/presentation/screens/subjects/subjects_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_application_1/presentation/controllers/subjekcs_controller.dart';
import 'package:flutter_application_1/presentation/widgets/sidebar.dart';
import 'package:get/get.dart';

class SubjectsScreen extends StatelessWidget {
  SubjectsScreen({Key? key}) : super(key: key);

  final SubjectsController controller = Get.put(SubjectsController());

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
                          _buildSubjectsList(),
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
          colors: [Color(0xFF4CAF50), Color(0xFF388E3C)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4CAF50).withOpacity(0.3),
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
                child: const Icon(Icons.book, size: 32, color: Colors.white),
              ),
              const SizedBox(width: 20),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fanlar',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Barcha o\'quv fanlarini boshqaring',
                      style: TextStyle(fontSize: 14, color: Colors.white70),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: controller.showAddSubjectDialog,
                icon: const Icon(Icons.add),
                label: const Text('Yangi fan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF4CAF50),
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
            'Jami fanlar',
            controller.totalSubjects.value.toString(),
            Icons.book,
            const Color(0xFF4CAF50),
          ),
          const SizedBox(width: 16),
          _buildStatCard(
            'Faol fanlar',
            controller.activeSubjects.value.toString(),
            Icons.check_circle,
            const Color(0xFF2196F3),
          ),
          const SizedBox(width: 16),
          _buildStatCard(
            'O\'qituvchilar',
            controller.totalTeachers.value.toString(),
            Icons.person,
            const Color(0xFFFFA726),
          ),
          const SizedBox(width: 16),
          _buildStatCard(
            'Nofaol fanlar',
            controller.inactiveSubjects.value.toString(),
            Icons.cancel,
            const Color(0xFFF44336),
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

  Widget _buildSubjectsList() {
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
                      hintText: 'Fanlarni qidirish...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: controller.searchSubjects,
                  ),
                ),
                const SizedBox(width: 16),
                Obx(
                  () => DropdownButton<String>(
                    value: controller.filterStatus.value,
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('Barchasi')),
                      DropdownMenuItem(value: 'active', child: Text('Faol')),
                      DropdownMenuItem(
                        value: 'inactive',
                        child: Text('Nofaol'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        controller.filterStatus.value = value;
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          Obx(() {
            final subjects = controller.filteredSubjects;
            if (subjects.isEmpty) {
              return _buildEmptyState();
            }
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: subjects.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) =>
                  _buildSubjectItem(subjects[index]),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSubjectItem(Map<String, dynamic> subject) {
    final isActive = subject['is_active'] ?? true;
    final teacherCount = subject['teacher_count'] ?? 0;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      leading: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isActive
                ? [const Color(0xFF4CAF50), const Color(0xFF388E3C)]
                : [Colors.grey.shade400, Colors.grey.shade600],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          _getSubjectIcon(subject['code']),
          color: Colors.white,
          size: 28,
        ),
      ),
      title: Text(
        subject['name'],
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (subject['code'] != null)
            Text(
              'Kod: ${subject['code']}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          if (subject['description'] != null)
            Text(
              subject['description'],
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.person, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                '$teacherCount ta o\'qituvchi',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isActive
                  ? const Color(0xFF4CAF50).withOpacity(0.1)
                  : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isActive
                    ? const Color(0xFF4CAF50).withOpacity(0.3)
                    : Colors.grey.withOpacity(0.3),
              ),
            ),
            child: Text(
              isActive ? 'Faol' : 'Nofaol',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isActive ? const Color(0xFF4CAF50) : Colors.grey,
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.edit, color: Color(0xFF2196F3)),
            onPressed: () => controller.editSubject(subject),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Color(0xFFF44336)),
            onPressed: () => controller.deleteSubject(subject['id']),
          ),
        ],
      ),
    );
  }

  IconData _getSubjectIcon(String? code) {
    if (code == null) return Icons.book;

    final lowerCode = code.toLowerCase();
    if (lowerCode.contains('math')) return Icons.calculate;
    if (lowerCode.contains('phys')) return Icons.science;
    if (lowerCode.contains('chem')) return Icons.biotech;
    if (lowerCode.contains('bio')) return Icons.nature;
    if (lowerCode.contains('eng')) return Icons.language;
    if (lowerCode.contains('lit')) return Icons.menu_book;
    if (lowerCode.contains('hist')) return Icons.history_edu;
    if (lowerCode.contains('geo')) return Icons.public;
    if (lowerCode.contains('pe') || lowerCode.contains('sport'))
      return Icons.sports;
    if (lowerCode.contains('art')) return Icons.palette;
    if (lowerCode.contains('music')) return Icons.music_note;
    if (lowerCode.contains('comp') || lowerCode.contains('it'))
      return Icons.computer;

    return Icons.book;
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.book_outlined, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'Fanlar topilmadi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Yangi fan qo\'shish uchun yuqoridagi tugmani bosing',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
