// lib/presentation/controllers/add_branch_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/services/supabase_service.dart';
import '../../data/models/branch_model.dart';

class AddBranchController extends GetxController {
  final SupabaseService _supabaseService = Get.find<SupabaseService>();
  final formKey = GlobalKey<FormState>();

  // Text controllers
  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final phoneController = TextEditingController();
  final phoneSecondaryController = TextEditingController();
  final emailController = TextEditingController();

  // Observable variables
  var isSaving = false.obs;
  var isMain = false.obs;
  var isActive = true.obs;
  var workingHoursStart = '08:00'.obs;
  var workingHoursEnd = '18:00'.obs;

  // Edit mode
  BranchModel? editingBranch;

  @override
  void onInit() {
    super.onInit();
    // Agar edit mode bo'lsa
    if (Get.arguments != null && Get.arguments is BranchModel) {
      editingBranch = Get.arguments as BranchModel;
      loadBranchData();
    }
  }

  void loadBranchData() {
    if (editingBranch == null) return;

    nameController.text = editingBranch!.name;
    addressController.text = editingBranch!.address ?? '';
    phoneController.text = editingBranch!.phone ?? '';
    phoneSecondaryController.text = editingBranch!.phoneSecondary ?? '';
    emailController.text = editingBranch!.email ?? '';
    isMain.value = editingBranch!.isMain;
    isActive.value = editingBranch!.isActive;

    if (editingBranch!.workingHoursStart != null) {
      workingHoursStart.value = editingBranch!.workingHoursStart!.substring(
        0,
        5,
      );
    }
    if (editingBranch!.workingHoursEnd != null) {
      workingHoursEnd.value = editingBranch!.workingHoursEnd!.substring(0, 5);
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    addressController.dispose();
    phoneController.dispose();
    phoneSecondaryController.dispose();
    emailController.dispose();
    super.onClose();
  }

  Future<void> selectTime(bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: Get.context!,
      initialTime: TimeOfDay(
        hour: int.parse(
          (isStartTime ? workingHoursStart.value : workingHoursEnd.value).split(
            ':',
          )[0],
        ),
        minute: int.parse(
          (isStartTime ? workingHoursStart.value : workingHoursEnd.value).split(
            ':',
          )[1],
        ),
      ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: Color(0xFF2196F3)),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final formatted =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      if (isStartTime) {
        workingHoursStart.value = formatted;
      } else {
        workingHoursEnd.value = formatted;
      }
    }
  }

  Future<void> saveBranch() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    isSaving.value = true;

    try {
      final branchData = {
        'name': nameController.text.trim(),
        'address': addressController.text.trim().isEmpty
            ? null
            : addressController.text.trim(),
        'phone': phoneController.text.trim().isEmpty
            ? null
            : phoneController.text.trim(),
        'phone_secondary': phoneSecondaryController.text.trim().isEmpty
            ? null
            : phoneSecondaryController.text.trim(),
        'email': emailController.text.trim().isEmpty
            ? null
            : emailController.text.trim(),
        'is_main': isMain.value,
        'is_active': isActive.value,
        'working_hours_start': '${workingHoursStart.value}:00',
        'working_hours_end': '${workingHoursEnd.value}:00',
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (editingBranch != null) {
        // Yangilash
        await _supabaseService.client
            .from('branches')
            .update(branchData)
            .eq('id', editingBranch!.id);

        Get.back();
        Get.snackbar(
          'Muvaffaqiyatli',
          'Filial muvaffaqiyatli yangilandi',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        // Yangi qo'shish
        await _supabaseService.client.from('branches').insert(branchData);

        Get.back();
        Get.snackbar(
          'Muvaffaqiyatli',
          'Filial muvaffaqiyatli qo\'shildi',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Xato',
        'Filialni saqlashda xatolik: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isSaving.value = false;
    }
  }
}
