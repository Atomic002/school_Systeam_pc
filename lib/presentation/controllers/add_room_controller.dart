// lib/presentation/controllers/add_room_controller.dart

import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/services/supabase_service.dart';
import 'package:get/get.dart';

class AddRoomController extends GetxController {
  final SupabaseService _supabaseService = Get.find<SupabaseService>();
  final formKey = GlobalKey<FormState>();

  // Text controllers
  final nameController = TextEditingController();
  final capacityController = TextEditingController();
  final floorController = TextEditingController();
  final equipmentController = TextEditingController();

  // Observable variables
  var isSaving = false.obs;
  var selectedBranchId = Rxn<String>();
  var selectedRoomType = 'classroom'.obs;
  var selectedEquipment = <String>[].obs;
  var selectedClasses = <String>[].obs;
  var selectedTeachers = <String>[].obs;

  // Data lists
  var branches = <Map<String, dynamic>>[].obs;
  var availableClasses = <Map<String, dynamic>>[].obs;
  var availableTeachers = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadBranches();

    // Branch o'zgarganda sinflar va o'qituvchilarni yangilash
    ever(selectedBranchId, (_) {
      if (selectedBranchId.value != null) {
        loadClassesForBranch();
        loadTeachersForBranch();
      }
    });
  }

  @override
  void onClose() {
    nameController.dispose();
    capacityController.dispose();
    floorController.dispose();
    equipmentController.dispose();
    super.onClose();
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

  Future<void> loadClassesForBranch() async {
    try {
      final response = await _supabaseService.client
          .from('classes')
          .select('id, name, code')
          .eq('branch_id', selectedBranchId.value!)
          .eq('is_active', true)
          .order('name');

      availableClasses.value = List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error loading classes: $e');
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

  void toggleEquipment(String equipment) {
    if (selectedEquipment.contains(equipment)) {
      selectedEquipment.remove(equipment);
    } else {
      selectedEquipment.add(equipment);
    }
    updateEquipmentText();
  }

  void updateEquipmentText() {
    final currentText = equipmentController.text;
    final equipment = selectedEquipment.join(', ');

    if (currentText.isEmpty) {
      equipmentController.text = equipment;
    } else if (!currentText.contains(equipment)) {
      equipmentController.text = '$currentText, $equipment';
    }
  }

  void toggleClass(String classId) {
    if (selectedClasses.contains(classId)) {
      selectedClasses.remove(classId);
    } else {
      selectedClasses.add(classId);
    }
  }

  void toggleTeacher(String teacherId) {
    if (selectedTeachers.contains(teacherId)) {
      selectedTeachers.remove(teacherId);
    } else {
      selectedTeachers.add(teacherId);
    }
  }

  Future<void> saveRoom() async {
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

    isSaving.value = true;

    try {
      // Xonani saqlash
      final roomData = {
        'branch_id': selectedBranchId.value,
        'name': nameController.text.trim(),
        'capacity': int.parse(capacityController.text),
        'floor': int.parse(floorController.text),
        'room_type': selectedRoomType.value,
        'equipment': equipmentController.text.trim(),
        'is_active': true,
      };

      final roomResponse = await _supabaseService.client
          .from('rooms')
          .insert(roomData)
          .select()
          .single();

      final roomId = roomResponse['id'];

      // Sinflarni biriktirish
      if (selectedClasses.isNotEmpty) {
        for (final classId in selectedClasses) {
          await _supabaseService.client
              .from('classes')
              .update({'default_room_id': roomId})
              .eq('id', classId);
        }
      }

      // O'qituvchilarni biriktirish
      if (selectedTeachers.isNotEmpty) {
        for (final teacherId in selectedTeachers) {
          await _supabaseService.client
              .from('staff')
              .update({'default_room_id': roomId})
              .eq('id', teacherId);
        }
      }

      Get.back();
      Get.snackbar(
        'Muvaffaqiyatli',
        'Xona muvaffaqiyatli qo\'shildi',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Xato',
        'Xonani saqlashda xatolik: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isSaving.value = false;
    }
  }
}
