// lib/presentation/controllers/add_class_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/services/supabase_service.dart';

class AddClassController extends GetxController {
  final SupabaseService _supabaseService = Get.find<SupabaseService>();
  final formKey = GlobalKey<FormState>();

  // Text controllers
  final nameController = TextEditingController();
  final codeController = TextEditingController();
  final maxStudentsController = TextEditingController(text: '30');
  final monthlyFeeController = TextEditingController();
  final specializationController = TextEditingController();

  // Observable variables
  var isLoading = false.obs;
  var isSaving = false.obs;
  var selectedBranchId = Rxn<String>();
  var selectedAcademicYearId = Rxn<String>();
  var selectedClassLevelId = Rxn<String>();
  var selectedRoomId = Rxn<String>();
  var selectedMainTeacherId = Rxn<String>();
  var selectedTeachers = <String>[].obs;
  var selectedStudents = <String>[].obs;
  var selectedStudentsData = <Map<String, dynamic>>[].obs;

  // Data lists
  var branches = <Map<String, dynamic>>[].obs;
  var academicYears = <Map<String, dynamic>>[].obs;
  var classLevels = <Map<String, dynamic>>[].obs;
  var availableRooms = <Map<String, dynamic>>[].obs;
  var availableTeachers = <Map<String, dynamic>>[].obs;
  var availableStudents = <Map<String, dynamic>>[].obs;
  var monthlyFee = 0.0.obs;
  var maxStudents = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadInitialData();

    // Branch o'zgarganda xonalar va o'qituvchilarni yangilash
    ever(selectedBranchId, (_) {
      if (selectedBranchId.value != null) {
        loadRoomsForBranch();
        loadTeachersForBranch();
        loadStudentsForBranch();
      }
    });
  }

  @override
  void onClose() {
    nameController.dispose();
    codeController.dispose();
    maxStudentsController.dispose();
    monthlyFeeController.dispose();
    specializationController.dispose();
    super.onClose();
  }

  Future<void> loadInitialData() async {
    isLoading.value = true;
    try {
      await Future.wait([
        loadBranches(),
        loadAcademicYears(),
        loadClassLevels(),
      ]);
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

  Future<void> loadBranches() async {
    try {
      final response = await _supabaseService.client
          .from('branches')
          .select()
          .eq('is_active', true)
          .order('name');

      branches.value = List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error loading branches: $e');
    }
  }

  Future<void> loadAcademicYears() async {
    try {
      final response = await _supabaseService.client
          .from('academic_years')
          .select()
          .eq('is_active', true)
          .order('start_date', ascending: false);

      academicYears.value = List<Map<String, dynamic>>.from(response);

      // Joriy yilni avtomatik tanlash
      final currentYear = academicYears.firstWhereOrNull(
        (year) => year['is_current'] == true,
      );
      if (currentYear != null) {
        selectedAcademicYearId.value = currentYear['id'];
      }
    } catch (e) {
      print('Error loading academic years: $e');
    }
  }

  Future<void> loadClassLevels() async {
    try {
      final response = await _supabaseService.client
          .from('class_levels')
          .select()
          .eq('is_active', true)
          .order('order_number');

      classLevels.value = List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error loading class levels: $e');
    }
  }

  Future<void> loadRoomsForBranch() async {
    try {
      final response = await _supabaseService.client
          .from('rooms')
          .select('id, name, capacity, floor')
          .eq('branch_id', selectedBranchId.value!)
          .eq('is_active', true)
          .order('name');

      availableRooms.value = List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error loading rooms: $e');
    }
  }

  Future<void> loadTeachersForBranch() async {
    try {
      final response = await _supabaseService.client
          .from('staff')
          .select('id, first_name, last_name, position')
          .eq('branch_id', selectedBranchId.value!)
          .eq('is_teacher', true)
          .eq('status', 'active')
          .order('last_name');

      availableTeachers.value = List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error loading teachers: $e');
    }
  }

  Future<void> loadStudentsForBranch() async {
    try {
      final response = await _supabaseService.client
          .from('students')
          .select('id, first_name, last_name, phone, birth_date')
          .eq('branch_id', selectedBranchId.value!)
          .eq('status', 'active')
          .order('last_name');

      availableStudents.value = List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error loading students: $e');
    }
  }

  void toggleTeacher(String teacherId) {
    if (selectedTeachers.contains(teacherId)) {
      selectedTeachers.remove(teacherId);
    } else {
      selectedTeachers.add(teacherId);
    }
  }

  void showStudentSelectionDialog() {
    if (availableStudents.isEmpty) {
      Get.snackbar(
        'Ogohlantirish',
        'Avval filialni tanlang',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    final searchController = TextEditingController();
    final filteredStudents = <Map<String, dynamic>>[].obs;
    filteredStudents.value = availableStudents;

    Get.dialog(
      Dialog(
        child: Container(
          width: 600,
          height: 700,
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Row(
                children: [
                  const Text(
                    'O\'quvchilarni tanlang',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: searchController,
                decoration: const InputDecoration(
                  labelText: 'Qidirish',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (query) {
                  if (query.isEmpty) {
                    filteredStudents.value = availableStudents;
                  } else {
                    filteredStudents.value = availableStudents.where((s) {
                      final name = '${s['first_name']} ${s['last_name']}'
                          .toLowerCase();
                      return name.contains(query.toLowerCase());
                    }).toList();
                  }
                },
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Obx(() {
                  if (filteredStudents.isEmpty) {
                    return const Center(child: Text('O\'quvchilar topilmadi'));
                  }
                  return ListView.builder(
                    itemCount: filteredStudents.length,
                    itemBuilder: (context, index) {
                      final student = filteredStudents[index];
                      final isSelected = selectedStudents.contains(
                        student['id'],
                      );
                      return CheckboxListTile(
                        value: isSelected,
                        onChanged: (value) {
                          if (value == true) {
                            selectedStudents.add(student['id']);
                            selectedStudentsData.add(student);
                          } else {
                            selectedStudents.remove(student['id']);
                            selectedStudentsData.removeWhere(
                              (s) => s['id'] == student['id'],
                            );
                          }
                        },
                        title: Text(
                          '${student['first_name']} ${student['last_name']}',
                        ),
                        subtitle: Text(student['phone'] ?? ''),
                        secondary: CircleAvatar(
                          backgroundColor: const Color(0xFF4CAF50),
                          child: Text(
                            student['first_name'][0],
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('Bekor qilish'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                    ),
                    child: Obx(
                      () => Text('Tanlash (${selectedStudents.length})'),
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

  void removeStudent(String studentId) {
    selectedStudents.remove(studentId);
    selectedStudentsData.removeWhere((s) => s['id'] == studentId);
  }

  Future<void> saveClass() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    if (selectedBranchId.value == null) {
      Get.snackbar(
        'Xato',
        'Filialni tanlang',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (selectedAcademicYearId.value == null) {
      Get.snackbar(
        'Xato',
        'O\'quv yilini tanlang',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (selectedClassLevelId.value == null) {
      Get.snackbar(
        'Xato',
        'Sinf darajasini tanlang',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isSaving.value = true;

    try {
      // Sinfni saqlash
      final classData = {
        'branch_id': selectedBranchId.value,
        'academic_year_id': selectedAcademicYearId.value,
        'class_level_id': selectedClassLevelId.value,
        'name': nameController.text.trim(),
        'code': codeController.text.trim().isEmpty
            ? null
            : codeController.text.trim(),
        'main_teacher_id': selectedMainTeacherId.value,
        'default_room_id': selectedRoomId.value,
        'monthly_fee': double.parse(monthlyFeeController.text),
        'specialization': specializationController.text.trim().isEmpty
            ? null
            : specializationController.text.trim(),
        'max_students': int.parse(maxStudentsController.text),
        'is_active': true,
      };

      final classResponse = await _supabaseService.client
          .from('classes')
          .insert(classData)
          .select()
          .single();

      final classId = classResponse['id'];

      // O'qituvchilarni biriktirish
      if (selectedTeachers.isNotEmpty) {
        final teacherClasses = selectedTeachers.map((teacherId) {
          return {
            'staff_id': teacherId,
            'class_id': classId,
            'academic_year_id': selectedAcademicYearId.value,
            'is_active': true,
          };
        }).toList();

        await _supabaseService.client
            .from('teacher_classes')
            .insert(teacherClasses);
      }

      // O'quvchilarni biriktirish
      if (selectedStudents.isNotEmpty) {
        final enrollments = selectedStudents.map((studentId) {
          return {
            'student_id': studentId,
            'class_id': classId,
            'academic_year_id': selectedAcademicYearId.value,
            'enrolled_at': DateTime.now().toIso8601String(),
            'is_active': true,
          };
        }).toList();

        await _supabaseService.client.from('enrollments').insert(enrollments);

        // O'quvchilarning class_id ni yangilash
        for (final studentId in selectedStudents) {
          await _supabaseService.client
              .from('students')
              .update({'class_id': classId})
              .eq('id', studentId);
        }
      }

      Get.back();
      Get.snackbar(
        'Muvaffaqiyatli',
        'Sinf muvaffaqiyatli qo\'shildi',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Xato',
        'Sinfni saqlashda xatolik: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isSaving.value = false;
    }
  }
}
