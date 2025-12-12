// lib/presentation/controllers/teacher_subjects_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TeacherSubjectsController extends GetxController {
  final supabase = Supabase.instance.client;

  final RxList<Map<String, dynamic>> teachers = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> filteredTeachers =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> subjects = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;

  final RxInt totalTeachers = 0.obs;
  final RxInt totalSubjects = 0.obs;
  final RxInt totalAssignments = 0.obs;
  final RxInt primarySubjects = 0.obs;

  final Rx<String?> selectedTeacherId = Rx<String?>(null);
  final Rx<String?> selectedSubjectId = Rx<String?>(null);
  final RxBool isPrimary = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadData();

    ever(searchQuery, (_) => _applyFilters());
  }

  Future<void> loadData() async {
    try {
      isLoading.value = true;

      // O'qituvchilarni yuklash
      final teachersData = await supabase
          .from('staff')
          .select('id, first_name, last_name')
          .eq('role', 'teacher')
          .order('first_name');

      teachers.value = List<Map<String, dynamic>>.from(teachersData);

      // Har bir o'qituvchi uchun fanlarini yuklash
      for (var teacher in teachers) {
        final teacherSubjects = await supabase
            .from('teacher_subjects')
            .select('''
              id,
              subject_id,
              is_primary,
              subjects (
                id,
                name
              )
            ''')
            .eq('staff_id', teacher['id']);

        teacher['subjects'] = teacherSubjects.map((ts) {
          return {
            'id': ts['id'],
            'subject_id': ts['subject_id'],
            'subject_name': ts['subjects']['name'],
            'is_primary': ts['is_primary'],
          };
        }).toList();
      }

      // Barcha fanlarni yuklash
      final subjectsData = await supabase
          .from('subjects')
          .select()
          .eq('is_active', true)
          .order('name');

      subjects.value = List<Map<String, dynamic>>.from(subjectsData);

      _calculateStats();
      _applyFilters();
    } catch (e) {
      Get.snackbar(
        'Xato',
        'Ma\'lumotlarni yuklashda xatolik: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _calculateStats() {
    totalTeachers.value = teachers.length;
    totalSubjects.value = subjects.length;

    int assignments = 0;
    int primaryCount = 0;

    for (var teacher in teachers) {
      final teacherSubjects = teacher['subjects'] as List? ?? [];
      assignments += teacherSubjects.length;
      primaryCount += teacherSubjects
          .where((s) => s['is_primary'] == true)
          .length;
    }

    totalAssignments.value = assignments;
    primarySubjects.value = primaryCount;
  }

  void _applyFilters() {
    var filtered = teachers.toList();

    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filtered = filtered.where((t) {
        final firstName = (t['first_name'] as String? ?? '').toLowerCase();
        final lastName = (t['last_name'] as String? ?? '').toLowerCase();
        return firstName.contains(query) || lastName.contains(query);
      }).toList();
    }

    filteredTeachers.value = filtered;
  }

  void searchTeachers(String query) {
    searchQuery.value = query;
  }

  void showAssignSubjectDialog({String? teacherId}) {
    selectedTeacherId.value = teacherId;
    selectedSubjectId.value = null;
    isPrimary.value = false;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 500,
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
                        colors: [Color(0xFFFF9800), Color(0xFFF57C00)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.link,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Fan biriktirish',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Obx(
                () => DropdownButtonFormField<String>(
                  value: selectedTeacherId.value,
                  decoration: InputDecoration(
                    labelText: 'O\'qituvchi *',
                    prefixIcon: const Icon(
                      Icons.person,
                      color: Color(0xFFFF9800),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: teachers.map((teacher) {
                    return DropdownMenuItem<String>(
                      value: teacher['id'],
                      child: Text(
                        '${teacher['first_name']} ${teacher['last_name']}',
                      ),
                    );
                  }).toList(),
                  onChanged: (value) => selectedTeacherId.value = value,
                ),
              ),
              const SizedBox(height: 16),
              Obx(
                () => DropdownButtonFormField<String>(
                  value: selectedSubjectId.value,
                  decoration: InputDecoration(
                    labelText: 'Fan *',
                    prefixIcon: const Icon(
                      Icons.book,
                      color: Color(0xFFFF9800),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: subjects.map((subject) {
                    return DropdownMenuItem<String>(
                      value: subject['id'],
                      child: Text(subject['name']),
                    );
                  }).toList(),
                  onChanged: (value) => selectedSubjectId.value = value,
                ),
              ),
              const SizedBox(height: 16),
              Obx(
                () => SwitchListTile(
                  title: const Text('Asosiy fan'),
                  subtitle: const Text('Bu o\'qituvchining asosiy fani'),
                  value: isPrimary.value,
                  onChanged: (value) => isPrimary.value = value,
                  activeColor: Colors.amber,
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
                    onPressed: assignSubject,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF9800),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Biriktirish'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> assignSubject() async {
    if (selectedTeacherId.value == null) {
      Get.snackbar(
        'Xato',
        'O\'qituvchini tanlang',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    if (selectedSubjectId.value == null) {
      Get.snackbar(
        'Xato',
        'Fanni tanlang',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    try {
      // Avval bu o'qituvchida bu fan bor-yo'qligini tekshirish
      final existing = await supabase
          .from('teacher_subjects')
          .select()
          .eq('staff_id', selectedTeacherId.value!)
          .eq('subject_id', selectedSubjectId.value!);

      if (existing.isNotEmpty) {
        Get.snackbar(
          'Diqqat',
          'Bu fan allaqachon biriktirilgan',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }

      // Agar asosiy fan bo'lsa, boshqa asosiy fanlarni nofaol qilish
      if (isPrimary.value) {
        await supabase
            .from('teacher_subjects')
            .update({'is_primary': false})
            .eq('staff_id', selectedTeacherId.value!)
            .neq('subject_id', selectedSubjectId.value!);
      }

      // Yangi fanni biriktirish
      await supabase.from('teacher_subjects').insert({
        'staff_id': selectedTeacherId.value,
        'subject_id': selectedSubjectId.value,
        'is_primary': isPrimary.value,
      });

      Get.back();
      Get.snackbar(
        'Muvaffaqiyatli',
        'Fan muvaffaqiyatli biriktirildi',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      loadData();
    } catch (e) {
      Get.snackbar(
        'Xato',
        'Fanni biriktirishda xatolik: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> removeSubject(String teacherId, String subjectId) async {
    Get.dialog(
      AlertDialog(
        title: const Text('O\'chirish'),
        content: const Text('Ushbu fanni o\'qituvchidan ajratmoqchimisiz?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Bekor qilish'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              try {
                await supabase
                    .from('teacher_subjects')
                    .delete()
                    .eq('staff_id', teacherId)
                    .eq('subject_id', subjectId);

                Get.snackbar(
                  'Muvaffaqiyatli',
                  'Fan muvaffaqiyatli ajratildi',
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );

                loadData();
              } catch (e) {
                Get.snackbar(
                  'Xato',
                  'Fanni ajratishda xatolik: $e',
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
}
