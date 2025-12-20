// lib/presentation/controllers/academic_years_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AcademicYearsController extends GetxController {
  final supabase = Supabase.instance.client;

  var isLoading = false.obs;
  var academicYears = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadAcademicYears();
  }

  Future<void> loadAcademicYears() async {
    isLoading.value = true;
    try {
      final data = await supabase
          .from('academic_years')
          .select()
          .order('start_date', ascending: false);
      
      academicYears.value = List<Map<String, dynamic>>.from(data);
      print('✅ O\'quv yillari yuklandi: ${academicYears.length}');
    } catch (e) {
      print('❌ Load academic years error: $e');
      Get.snackbar('Xato', 'Ma\'lumotlar yuklanmadi');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshData() async {
    await loadAcademicYears();
  }

  void showAddDialog() {
    final nameController = TextEditingController();
    DateTime? startDate;
    DateTime? endDate;

    Get.dialog(
      AlertDialog(
        title: Text('Yangi O\'quv Yili'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Nomi *',
                      hintText: '2024-2025',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                  ListTile(
                    title: Text('Boshlanish sanasi *'),
                    subtitle: Text(
                      startDate != null 
                          ? '${startDate!.day}.${startDate!.month}.${startDate!.year}'
                          : 'Tanlanmagan',
                    ),
                    trailing: Icon(Icons.calendar_today),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() => startDate = picked);
                      }
                    },
                  ),
                  ListTile(
                    title: Text('Tugash sanasi *'),
                    subtitle: Text(
                      endDate != null 
                          ? '${endDate!.day}.${endDate!.month}.${endDate!.year}'
                          : 'Tanlanmagan',
                    ),
                    trailing: Icon(Icons.calendar_today),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: startDate?.add(Duration(days: 300)) ?? DateTime.now(),
                        firstDate: startDate ?? DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() => endDate = picked);
                      }
                    },
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Bekor qilish'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty || startDate == null || endDate == null) {
                Get.snackbar('Xato', 'Barcha maydonlarni to\'ldiring');
                return;
              }
              Get.back();
              await addAcademicYear(nameController.text, startDate!, endDate!);
            },
            child: Text('Qo\'shish'),
          ),
        ],
      ),
    );
  }

  void showEditDialog(Map<String, dynamic> year) {
    final nameController = TextEditingController(text: year['name']);
    DateTime startDate = DateTime.parse(year['start_date']);
    DateTime endDate = DateTime.parse(year['end_date']);

    Get.dialog(
      AlertDialog(
        title: Text('O\'quv Yilini Tahrirlash'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Nomi',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                  ListTile(
                    title: Text('Boshlanish sanasi'),
                    subtitle: Text('${startDate.day}.${startDate.month}.${startDate.year}'),
                    trailing: Icon(Icons.calendar_today),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: startDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() => startDate = picked);
                      }
                    },
                  ),
                  ListTile(
                    title: Text('Tugash sanasi'),
                    subtitle: Text('${endDate.day}.${endDate.month}.${endDate.year}'),
                    trailing: Icon(Icons.calendar_today),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: endDate,
                        firstDate: startDate,
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() => endDate = picked);
                      }
                    },
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Bekor qilish'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await updateAcademicYear(year['id'], nameController.text, startDate, endDate);
            },
            child: Text('Saqlash'),
          ),
        ],
      ),
    );
  }

  Future<void> addAcademicYear(String name, DateTime startDate, DateTime endDate) async {
    try {
      await supabase.from('academic_years').insert({
        'name': name,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
        'is_current': academicYears.isEmpty,
        'is_active': true,
      });
      
      await loadAcademicYears();
      Get.snackbar('Muvaffaqiyatli', 'O\'quv yili qo\'shildi');
    } catch (e) {
      Get.snackbar('Xato', 'Qo\'shishda xatolik');
    }
  }

  Future<void> updateAcademicYear(String id, String name, DateTime startDate, DateTime endDate) async {
    try {
      await supabase.from('academic_years').update({
        'name': name,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', id);
      
      await loadAcademicYears();
      Get.snackbar('Muvaffaqiyatli', 'O\'zgarishlar saqlandi');
    } catch (e) {
      Get.snackbar('Xato', 'Saqlashda xatolik');
    }
  }

  Future<void> setAsCurrent(String id) async {
    try {
      await supabase.from('academic_years').update({'is_current': false}).neq('id', id);
      await supabase.from('academic_years').update({'is_current': true}).eq('id', id);
      await loadAcademicYears();
      Get.snackbar('Muvaffaqiyatli', 'Joriy o\'quv yili o\'zgartirildi');
    } catch (e) {
      Get.snackbar('Xato', 'O\'zgartirishda xatolik');
    }
  }

  Future<void> toggleActive(String id, bool isActive) async {
    try {
      await supabase.from('academic_years').update({'is_active': isActive}).eq('id', id);
      await loadAcademicYears();
      Get.snackbar('Muvaffaqiyatli', isActive ? 'Faollashtirildi' : 'Nofaol qilindi');
    } catch (e) {
      Get.snackbar('Xato', 'O\'zgartirishda xatolik');
    }
  }

  void showDeleteDialog(String id) {
    Get.dialog(
      AlertDialog(
        title: Text('O\'chirish'),
        content: Text('Rostdan ham o\'chirmoqchimisiz?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Yo\'q'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await deleteAcademicYear(id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Ha, o\'chirish'),
          ),
        ],
      ),
    );
  }

  Future<void> deleteAcademicYear(String id) async {
    try {
      await supabase.from('academic_years').delete().eq('id', id);
      await loadAcademicYears();
      Get.snackbar('Muvaffaqiyatli', 'O\'quv yili o\'chirildi');
    } catch (e) {
      Get.snackbar('Xato', 'O\'chirishda xatolik: $e');
    }
  }
}