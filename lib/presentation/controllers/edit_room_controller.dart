import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/services/supabase_service.dart';
import 'package:get/get.dart';

class EditRoomController extends GetxController {
  final SupabaseService _supabaseService = Get.find<SupabaseService>();
  final formKey = GlobalKey<FormState>();

  // Text controllers
  final nameController = TextEditingController();
  final capacityController = TextEditingController();
  final floorController = TextEditingController();
  final equipmentController = TextEditingController();

  // Observable variables
  var isLoading = true.obs;
  var isSaving = false.obs;
  
  var selectedBranchId = Rxn<String>();
  var selectedRoomType = 'classroom'.obs;
  var selectedEquipment = <String>[].obs;

  // Data lists
  var branches = <Map<String, dynamic>>[].obs;
  
  String? roomId;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    roomId = args?['id'];
    
    loadInitialData();
  }

  @override
  void onClose() {
    nameController.dispose();
    capacityController.dispose();
    floorController.dispose();
    equipmentController.dispose();
    super.onClose();
  }

  Future<void> loadInitialData() async {
    isLoading.value = true;
    try {
      await loadBranches();
      if (roomId != null) {
        await loadRoomData();
      }
    } catch (e) {
      Get.snackbar('Xato', 'Ma\'lumotlarni yuklashda xatolik: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadBranches() async {
    final response = await _supabaseService.client
        .from('branches')
        .select('id, name')
        .eq('is_active', true);
    branches.value = List<Map<String, dynamic>>.from(response);
  }

  Future<void> loadRoomData() async {
    final data = await _supabaseService.client
        .from('rooms')
        .select()
        .eq('id', roomId!)
        .single();

    // Ma'lumotlarni formaga to'ldirish
    nameController.text = data['name'];
    capacityController.text = data['capacity'].toString();
    floorController.text = data['floor'].toString();
    selectedBranchId.value = data['branch_id'];
    selectedRoomType.value = data['room_type'] ?? 'classroom';
    
    // Jihozlarni parse qilish
    if (data['equipment'] != null) {
      equipmentController.text = data['equipment'];
      // Agar jihozlar vergul bilan yozilgan bo'lsa, ularni ajratib olamiz
      final equipmentList = (data['equipment'] as String).split(',').map((e) => e.trim()).toList();
      selectedEquipment.assignAll(equipmentList);
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
    // Text controllerni yangilash
    equipmentController.text = selectedEquipment.join(', ');
  }

  Future<void> saveRoom() async {
    if (!formKey.currentState!.validate()) return;
    if (selectedBranchId.value == null) {
      Get.snackbar('Xato', 'Filialni tanlang', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    isSaving.value = true;
    try {
      final updates = {
        'name': nameController.text.trim(),
        'capacity': int.parse(capacityController.text),
        'floor': int.parse(floorController.text),
        'branch_id': selectedBranchId.value,
        'room_type': selectedRoomType.value,
        'equipment': equipmentController.text.trim(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _supabaseService.client
          .from('rooms')
          .update(updates)
          .eq('id', roomId!);

      Get.back(result: true); // Muvaffaqiyatli qaytish
      Get.snackbar(
        'Muvaffaqiyatli', 
        'Xona ma\'lumotlari yangilandi', 
        backgroundColor: Colors.green, 
        colorText: Colors.white
      );
    } catch (e) {
      Get.snackbar(
        'Xato', 
        'Saqlashda xatolik: $e', 
        backgroundColor: Colors.red, 
        colorText: Colors.white
      );
    } finally {
      isSaving.value = false;
    }
  }
}