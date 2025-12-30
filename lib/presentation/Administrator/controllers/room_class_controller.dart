// lib/presentation/controllers/rooms_classes_controller.dart

import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/services/supabase_service.dart';
import 'package:get/get.dart';

class RoomsClassesControlleradmin extends GetxController {
  final SupabaseService _supabaseService = Get.find<SupabaseService>();

  // Observable variables
  var isLoading = false.obs;
  var currentView = 'rooms'.obs; // 'rooms' yoki 'classes'
  var searchQuery = ''.obs;
  var selectedBranchId = Rxn<String>();

  // Statistics
  var totalRooms = 0.obs;
  var availableRooms = 0.obs;
  var totalClasses = 0.obs;
  var activeClasses = 0.obs;
  var totalStudents = 0.obs;
  var totalTeachers = 0.obs;

  // Data lists
  var rooms = <Map<String, dynamic>>[].obs;
  var classes = <Map<String, dynamic>>[].obs;
  var branches = <Map<String, dynamic>>[].obs;

  // Filtered lists
  List<Map<String, dynamic>> get filteredRooms {
    if (searchQuery.value.isEmpty) return rooms;
    return rooms.where((room) {
      final name = room['name'].toString().toLowerCase();
      final query = searchQuery.value.toLowerCase();
      return name.contains(query);
    }).toList();
  }

  List<Map<String, dynamic>> get filteredClasses {
    if (searchQuery.value.isEmpty) return classes;
    return classes.where((cls) {
      final name = cls['name'].toString().toLowerCase();
      final query = searchQuery.value.toLowerCase();
      return name.contains(query);
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    isLoading.value = true;
    try {
      await Future.wait([
        loadBranches(),
        loadRooms(),
        loadClasses(),
        loadStatistics(),
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

  Future<void> loadRooms() async {
    try {
      final response = await _supabaseService.client
          .from('rooms')
          .select('''
          *,
          branch:branches(name),
          classes:classes!classes_default_room_id_fkey(
            id,
            name,
            enrollments(count)
          )
        ''')
          .eq('is_active', true)
          .order('name');

      rooms.value = List<Map<String, dynamic>>.from(response).map((room) {
        // Biriktirilgan sinfni aniqlash
        String? assignedClass;

        final roomClasses = room['classes'] as List?;
        if (roomClasses != null && roomClasses.isNotEmpty) {
          assignedClass = roomClasses[0]['name'];
        }

        return {
          'id': room['id'],
          'name': room['name'],
          'capacity': room['capacity'],
          'floor': room['floor'],
          'room_type': room['room_type'],
          'equipment': room['equipment'],
          'branch_name': room['branch']?['name'],
          'branch_id': room['branch_id'],
          'assigned_class': assignedClass,
        };
      }).toList();

      totalRooms.value = rooms.length;
      availableRooms.value = rooms
          .where((r) => r['assigned_class'] == null)
          .length;
    } catch (e) {
      print('Error loading rooms: $e');
      Get.snackbar('Xato', 'Xonalarni yuklashda xatolik: $e');
    }
  }

  Future<void> loadClasses() async {
    try {
      final response = await _supabaseService.client
          .from('classes')
          .select('''
          *,
          branch:branches(name),
          room:rooms!classes_default_room_id_fkey(name),
          teacher:staff!classes_main_teacher_id_fkey(first_name, last_name),
          class_level:class_levels(name),
          enrollments(count)
        ''')
          .eq('is_active', true)
          .order('name');

      classes.value = List<Map<String, dynamic>>.from(response).map((cls) {
        final enrollments = cls['enrollments'] as List?;
        final studentCount = enrollments?.isNotEmpty == true
            ? enrollments![0]['count']
            : 0;

        String? teacherName;
        if (cls['teacher'] != null) {
          teacherName =
              '${cls['teacher']['first_name']} ${cls['teacher']['last_name']}';
        }

        return {
          'id': cls['id'],
          'name': cls['name'],
          'code': cls['code'],
          'branch_name': cls['branch']?['name'],
          'branch_id': cls['branch_id'],
          'room_name': cls['room']?['name'],
          'room_id': cls['default_room_id'],
          'teacher_name': teacherName,
          'teacher_id': cls['main_teacher_id'],
          'class_level': cls['class_level']?['name'],
          'student_count': studentCount,
          'max_students': cls['max_students'],
          'monthly_fee': cls['monthly_fee'],
          'specialization': cls['specialization'],
        };
      }).toList();

      totalClasses.value = classes.length;
      activeClasses.value = classes.length;
    } catch (e) {
      print('Error loading classes: $e');
      Get.snackbar('Xato', 'Sinflarni yuklashda xatolik: $e');
    }
  }

  Future<void> loadStatistics() async {
    try {
      // O'quvchilar soni
      final studentsResponse = await _supabaseService.client
          .from('students')
          .select('id')
          .eq('status', 'active');
      totalStudents.value = studentsResponse.length;

      // O'qituvchilar soni
      final teachersResponse = await _supabaseService.client
          .from('staff')
          .select('id')
          .eq('is_teacher', true)
          .eq('status', 'active');
      totalTeachers.value = teachersResponse.length;
    } catch (e) {
      print('Error loading statistics: $e');
    }
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
  }

  void showFilterDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Filtrlash'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Filial bo\'yicha filtrlash'),
            const SizedBox(height: 16),
            Obx(
              () => DropdownButtonFormField<String?>(
                value: selectedBranchId.value,
                decoration: const InputDecoration(
                  labelText: 'Filial',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('Barcha filiallar'),
                  ),
                  ...branches.map((branch) {
                    return DropdownMenuItem<String?>(
                      value: branch['id'],
                      child: Text(branch['name']),
                    );
                  }).toList(),
                ],
                onChanged: (value) {
                  selectedBranchId.value = value;
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              selectedBranchId.value = null;
              Get.back();
            },
            child: const Text('Tozalash'),
          ),
          ElevatedButton(
            onPressed: () {
              applyFilter();
              Get.back();
            },
            child: const Text('Qo\'llash'),
          ),
        ],
      ),
    );
  }

  void applyFilter() {
    if (selectedBranchId.value != null) {
      if (currentView.value == 'rooms') {
        rooms.value = rooms
            .where((r) => r['branch_id'] == selectedBranchId.value)
            .toList();
      } else {
        classes.value = classes
            .where((c) => c['branch_id'] == selectedBranchId.value)
            .toList();
      }
    } else {
      loadRooms();
      loadClasses();
    }
  }

  Future<void> deleteRoom(String roomId) async {
    try {
      await _supabaseService.client
          .from('rooms')
          .update({'is_active': false})
          .eq('id', roomId);

      Get.snackbar(
        'Muvaffaqiyatli',
        'Xona o\'chirildi',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      loadRooms();
    } catch (e) {
      Get.snackbar(
        'Xato',
        'Xonani o\'chirishda xatolik: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> deleteClass(String classId) async {
    try {
      await _supabaseService.client
          .from('classes')
          .update({'is_active': false})
          .eq('id', classId);

      Get.snackbar(
        'Muvaffaqiyatli',
        'Sinf o\'chirildi',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      loadClasses();
    } catch (e) {
      Get.snackbar(
        'Xato',
        'Sinfni o\'chirishda xatolik: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
