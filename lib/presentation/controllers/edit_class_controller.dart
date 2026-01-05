// lib/presentation/controllers/edit_class_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/services/supabase_service.dart';

class EditClassController extends GetxController {
  final SupabaseService _supabaseService = Get.find<SupabaseService>();
  final formKey = GlobalKey<FormState>();

  // Text controllers
  final nameController = TextEditingController();
  final codeController = TextEditingController();
  final maxStudentsController = TextEditingController();
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
  var selectedStatus = 'active'.obs;

  // Data lists
  var branches = <Map<String, dynamic>>[].obs;
  var academicYears = <Map<String, dynamic>>[].obs;
  var classLevels = <Map<String, dynamic>>[].obs;
  var availableRooms = <Map<String, dynamic>>[].obs;
  var availableTeachers = <Map<String, dynamic>>[].obs;

  String? classId;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    classId = args?['id'];
    
    if (classId != null) {
      loadInitialData();
    }

    // Branch o'zgarganda xonalar va o'qituvchilarni yangilash
    ever(selectedBranchId, (_) {
      if (selectedBranchId.value != null) {
        loadRoomsForBranch();
        loadTeachersForBranch();
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
      
      // Sinf ma'lumotlarini yuklash
      await loadClassData();
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

  Future<void> loadClassData() async {
    try {
      final response = await _supabaseService.client
          .from('classes')
          .select('''
            *,
            branch:branches(id, name),
            room:rooms!classes_default_room_id_fkey(id, name),
            main_teacher:staff!classes_main_teacher_id_fkey(id, first_name, last_name),
            class_level:class_levels(id, name),
            academic_year:academic_years(id, name)
          ''')
          .eq('id', classId!)
          .single();

      // Ma'lumotlarni controller ga yuklash
      nameController.text = response['name'] ?? '';
      codeController.text = response['code'] ?? '';
      maxStudentsController.text = response['max_students']?.toString() ?? '30';
      monthlyFeeController.text = response['monthly_fee']?.toString() ?? '';
      specializationController.text = response['specialization'] ?? '';

      selectedBranchId.value = response['branch_id'];
      selectedAcademicYearId.value = response['academic_year_id'];
      selectedClassLevelId.value = response['class_level_id'];
      selectedRoomId.value = response['default_room_id'];
      selectedMainTeacherId.value = response['main_teacher_id'];
      selectedStatus.value = response['is_active'] == true ? 'active' : 'inactive';

      // Branch tanlangandan keyin xonalar va o'qituvchilarni yuklash
      if (selectedBranchId.value != null) {
        await loadRoomsForBranch();
        await loadTeachersForBranch();
      }
    } catch (e) {
      print('Error loading class data: $e');
      Get.snackbar('Xato', 'Sinf ma\'lumotlarini yuklashda xatolik');
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

  Future<void> updateClass() async {
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
        'is_active': selectedStatus.value == 'active',
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _supabaseService.client
          .from('classes')
          .update(classData)
          .eq('id', classId!);

      Get.back(result: true);
      Get.snackbar(
        'Muvaffaqiyatli',
        'Sinf muvaffaqiyatli yangilandi',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Xato',
        'Sinfni yangilashda xatolik: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isSaving.value = false;
    }
  }
}