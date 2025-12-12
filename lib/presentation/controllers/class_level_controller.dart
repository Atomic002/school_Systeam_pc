// lib/presentation/controllers/class_levels_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ClassLevelsController extends GetxController {
  final supabase = Supabase.instance.client;

  final RxList<Map<String, dynamic>> classLevels = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;

  final RxInt totalLevels = 0.obs;
  final RxInt activeLevels = 0.obs;
  final RxInt inactiveLevels = 0.obs;
  final RxInt totalClasses = 0.obs;

  final nameController = TextEditingController();
  final orderController = TextEditingController();
  final RxBool isActive = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadClassLevels();
  }

  Future<void> loadClassLevels() async {
    try {
      isLoading.value = true;

      // Sinf darajalarini yuklash
      final levelsData = await supabase
          .from('class_levels')
          .select()
          .order('order_number');

      classLevels.value = List<Map<String, dynamic>>.from(levelsData);

      // Har bir daraja uchun sinflar sonini hisoblash
      for (var level in classLevels) {
        final classCount = await supabase
            .from('classes')
            .select('id')
            .eq('class_level_id', level['id'])
            .count();

        level['class_count'] = classCount.count;
      }

      _calculateStats();
    } catch (e) {
      Get.snackbar(
        'Xato',
        'Sinf darajalarini yuklashda xatolik: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _calculateStats() {
    totalLevels.value = classLevels.length;
    activeLevels.value = classLevels
        .where((l) => l['is_active'] == true)
        .length;
    inactiveLevels.value = classLevels
        .where((l) => l['is_active'] != true)
        .length;
    totalClasses.value = classLevels.fold(
      0,
      (sum, level) => sum + (level['class_count'] as int? ?? 0),
    );
  }

  void showAddLevelDialog() {
    nameController.clear();
    orderController.text = '${classLevels.length + 1}';
    isActive.value = true;

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
                        colors: [Color(0xFF9C27B0), Color(0xFF7B1FA2)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.stairs,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Yangi daraja qo\'shish',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Daraja nomi *',
                  hintText: 'Masalan: 1-sinf',
                  prefixIcon: const Icon(
                    Icons.stairs,
                    color: Color(0xFF9C27B0),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  helperText: 'Misol: 1-sinf, 2-sinf, 3-sinf...',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: orderController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Tartib raqami *',
                  hintText: '1',
                  prefixIcon: const Icon(
                    Icons.format_list_numbered,
                    color: Color(0xFF9C27B0),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  helperText: 'Kichik raqam birinchi ko\'rinadi',
                ),
              ),
              const SizedBox(height: 16),
              Obx(
                () => SwitchListTile(
                  title: const Text('Faol holat'),
                  subtitle: const Text('Daraja faol yoki nofaol'),
                  value: isActive.value,
                  onChanged: (value) => isActive.value = value,
                  activeColor: const Color(0xFF9C27B0),
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
                    onPressed: saveLevel,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9C27B0),
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

  void editLevel(Map<String, dynamic> level) {
    nameController.text = level['name'];
    orderController.text = level['order_number'].toString();
    isActive.value = level['is_active'] ?? true;

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
                    'Darajani tahrirlash',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Daraja nomi *',
                  prefixIcon: const Icon(
                    Icons.stairs,
                    color: Color(0xFF2196F3),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: orderController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Tartib raqami *',
                  prefixIcon: const Icon(
                    Icons.format_list_numbered,
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
                  subtitle: const Text('Daraja faol yoki nofaol'),
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
                    onPressed: () => updateLevel(level['id']),
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

  Future<void> saveLevel() async {
    if (nameController.text.trim().isEmpty) {
      Get.snackbar(
        'Xato',
        'Daraja nomini kiriting',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    if (orderController.text.trim().isEmpty) {
      Get.snackbar(
        'Xato',
        'Tartib raqamini kiriting',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    try {
      final orderNumber = int.parse(orderController.text.trim());

      await supabase.from('class_levels').insert({
        'name': nameController.text.trim(),
        'order_number': orderNumber,
        'is_active': isActive.value,
      });

      Get.back();
      Get.snackbar(
        'Muvaffaqiyatli',
        'Daraja muvaffaqiyatli qo\'shildi',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      loadClassLevels();
    } catch (e) {
      Get.snackbar(
        'Xato',
        'Darajani saqlashda xatolik: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> updateLevel(String id) async {
    if (nameController.text.trim().isEmpty) {
      Get.snackbar(
        'Xato',
        'Daraja nomini kiriting',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    if (orderController.text.trim().isEmpty) {
      Get.snackbar(
        'Xato',
        'Tartib raqamini kiriting',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    try {
      final orderNumber = int.parse(orderController.text.trim());

      await supabase
          .from('class_levels')
          .update({
            'name': nameController.text.trim(),
            'order_number': orderNumber,
            'is_active': isActive.value,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id);

      Get.back();
      Get.snackbar(
        'Muvaffaqiyatli',
        'Daraja muvaffaqiyatli yangilandi',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      loadClassLevels();
    } catch (e) {
      Get.snackbar(
        'Xato',
        'Darajani yangilashda xatolik: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> deleteLevel(String id) async {
    Get.dialog(
      AlertDialog(
        title: const Text('O\'chirish'),
        content: const Text(
          'Ushbu darajani o\'chirmoqchimisiz?\n\nDiqqat: Daraja bilan bog\'liq barcha sinflar ham o\'chib ketadi!',
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
                await supabase.from('class_levels').delete().eq('id', id);

                Get.snackbar(
                  'Muvaffaqiyatli',
                  'Daraja muvaffaqiyatli o\'chirildi',
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );

                loadClassLevels();
              } catch (e) {
                Get.snackbar(
                  'Xato',
                  'Darajani o\'chirishda xatolik: $e',
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

  Future<void> reorderLevels(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final item = classLevels.removeAt(oldIndex);
    classLevels.insert(newIndex, item);

    // Tartib raqamlarini yangilash
    try {
      for (int i = 0; i < classLevels.length; i++) {
        await supabase
            .from('class_levels')
            .update({'order_number': i + 1})
            .eq('id', classLevels[i]['id']);
      }

      loadClassLevels();
    } catch (e) {
      Get.snackbar(
        'Xato',
        'Tartibni o\'zgartirishda xatolik: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    orderController.dispose();
    super.onClose();
  }
}
