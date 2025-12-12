// lib/presentation/controllers/subjects_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SubjectsController extends GetxController {
  final supabase = Supabase.instance.client;

  final RxList<Map<String, dynamic>> subjects = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> filteredSubjects =
      <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxString filterStatus = 'all'.obs;
  final RxString searchQuery = ''.obs;

  final RxInt totalSubjects = 0.obs;
  final RxInt activeSubjects = 0.obs;
  final RxInt inactiveSubjects = 0.obs;
  final RxInt totalTeachers = 0.obs;

  final nameController = TextEditingController();
  final codeController = TextEditingController();
  final descriptionController = TextEditingController();
  final RxBool isActive = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadSubjects();

    // Filter va search o'zgarishlarini kuzatish
    ever(filterStatus, (_) => _applyFilters());
    ever(searchQuery, (_) => _applyFilters());
  }

  Future<void> loadSubjects() async {
    try {
      isLoading.value = true;

      // Fanlarni yuklash
      final subjectsData = await supabase
          .from('subjects')
          .select()
          .order('name');

      subjects.value = List<Map<String, dynamic>>.from(subjectsData);

      // Har bir fan uchun o'qituvchilar sonini hisoblash
      for (var subject in subjects) {
        final teacherCount = await supabase
            .from('teacher_subjects')
            .select('id')
            .eq('subject_id', subject['id'])
            .count();

        subject['teacher_count'] = teacherCount.count;
      }

      _calculateStats();
      _applyFilters();
    } catch (e) {
      Get.snackbar(
        'Xato',
        'Fanlarni yuklashda xatolik: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _calculateStats() {
    totalSubjects.value = subjects.length;
    activeSubjects.value = subjects.where((s) => s['is_active'] == true).length;
    inactiveSubjects.value = subjects
        .where((s) => s['is_active'] != true)
        .length;

    // Jami o'qituvchilar sonini hisoblash
    totalTeachers.value = subjects.fold(
      0,
      (sum, subject) => sum + (subject['teacher_count'] as int? ?? 0),
    );
  }

  void _applyFilters() {
    var filtered = subjects.toList();

    // Status bo'yicha filter
    if (filterStatus.value == 'active') {
      filtered = filtered.where((s) => s['is_active'] == true).toList();
    } else if (filterStatus.value == 'inactive') {
      filtered = filtered.where((s) => s['is_active'] != true).toList();
    }

    // Qidiruv bo'yicha filter
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filtered = filtered.where((s) {
        final name = (s['name'] as String? ?? '').toLowerCase();
        final code = (s['code'] as String? ?? '').toLowerCase();
        final description = (s['description'] as String? ?? '').toLowerCase();
        return name.contains(query) ||
            code.contains(query) ||
            description.contains(query);
      }).toList();
    }

    filteredSubjects.value = filtered;
  }

  void searchSubjects(String query) {
    searchQuery.value = query;
  }

  void showAddSubjectDialog() {
    // Formani tozalash
    nameController.clear();
    codeController.clear();
    descriptionController.clear();
    isActive.value = true;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 600,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4CAF50), Color(0xFF388E3C)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.book,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Yangi fan qo\'shish',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Fan nomi *',
                  hintText: 'Masalan: Matematika',
                  prefixIcon: const Icon(Icons.book, color: Color(0xFF4CAF50)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: codeController,
                decoration: InputDecoration(
                  labelText: 'Fan kodi',
                  hintText: 'Masalan: MATH-101',
                  prefixIcon: const Icon(Icons.tag, color: Color(0xFF4CAF50)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Tavsif',
                  hintText: 'Fan haqida qisqacha ma\'lumot...',
                  prefixIcon: const Icon(
                    Icons.description,
                    color: Color(0xFF4CAF50),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Obx(
                () => SwitchListTile(
                  title: const Text('Faol holat'),
                  subtitle: const Text('Fan faol yoki nofaol'),
                  value: isActive.value,
                  onChanged: (value) => isActive.value = value,
                  activeColor: const Color(0xFF4CAF50),
                ),
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
                  ElevatedButton(
                    onPressed: saveSubject,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Saqlash'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void editSubject(Map<String, dynamic> subject) {
    nameController.text = subject['name'];
    codeController.text = subject['code'] ?? '';
    descriptionController.text = subject['description'] ?? '';
    isActive.value = subject['is_active'] ?? true;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 600,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Fanni tahrirlash',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Fan nomi *',
                  prefixIcon: const Icon(Icons.book, color: Color(0xFF2196F3)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: codeController,
                decoration: InputDecoration(
                  labelText: 'Fan kodi',
                  prefixIcon: const Icon(Icons.tag, color: Color(0xFF2196F3)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Tavsif',
                  prefixIcon: const Icon(
                    Icons.description,
                    color: Color(0xFF2196F3),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Obx(
                () => SwitchListTile(
                  title: const Text('Faol holat'),
                  subtitle: const Text('Fan faol yoki nofaol'),
                  value: isActive.value,
                  onChanged: (value) => isActive.value = value,
                  activeColor: const Color(0xFF2196F3),
                ),
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
                  ElevatedButton(
                    onPressed: () => updateSubject(subject['id']),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2196F3),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Yangilash'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> saveSubject() async {
    if (nameController.text.trim().isEmpty) {
      Get.snackbar(
        'Xato',
        'Fan nomini kiriting',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    try {
      await supabase.from('subjects').insert({
        'name': nameController.text.trim(),
        'code': codeController.text.trim().isEmpty
            ? null
            : codeController.text.trim(),
        'description': descriptionController.text.trim().isEmpty
            ? null
            : descriptionController.text.trim(),
        'is_active': isActive.value,
      });

      Get.back();
      Get.snackbar(
        'Muvaffaqiyatli',
        'Fan muvaffaqiyatli qo\'shildi',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      loadSubjects();
    } catch (e) {
      Get.snackbar(
        'Xato',
        'Fanni saqlashda xatolik: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> updateSubject(String id) async {
    if (nameController.text.trim().isEmpty) {
      Get.snackbar(
        'Xato',
        'Fan nomini kiriting',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    try {
      await supabase
          .from('subjects')
          .update({
            'name': nameController.text.trim(),
            'code': codeController.text.trim().isEmpty
                ? null
                : codeController.text.trim(),
            'description': descriptionController.text.trim().isEmpty
                ? null
                : descriptionController.text.trim(),
            'is_active': isActive.value,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id);

      Get.back();
      Get.snackbar(
        'Muvaffaqiyatli',
        'Fan muvaffaqiyatli yangilandi',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      loadSubjects();
    } catch (e) {
      Get.snackbar(
        'Xato',
        'Fanni yangilashda xatolik: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> deleteSubject(String id) async {
    Get.dialog(
      AlertDialog(
        title: const Text('O\'chirish'),
        content: const Text(
          'Ushbu fanni o\'chirmoqchimisiz?\n\nDiqqat: Fan bilan bog\'liq barcha ma\'lumotlar o\'chib ketadi!',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Bekor qilish'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              try {
                await supabase.from('subjects').delete().eq('id', id);

                Get.snackbar(
                  'Muvaffaqiyatli',
                  'Fan muvaffaqiyatli o\'chirildi',
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );

                loadSubjects();
              } catch (e) {
                Get.snackbar(
                  'Xato',
                  'Fanni o\'chirishda xatolik: $e',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('O\'chirish'),
          ),
        ],
      ),
    );
  }

  @override
  void onClose() {
    nameController.dispose();
    codeController.dispose();
    descriptionController.dispose();
    super.onClose();
  }
}
