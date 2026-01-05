// lib/presentation/controllers/rooms_classes_controller.dart

import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/services/supabase_service.dart';
import 'package:get/get.dart';

class RoomsClassesController extends GetxController {
  final SupabaseService _supabaseService = Get.find<SupabaseService>();

  var isLoading = false.obs;
  var currentView = 'rooms'.obs;
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

  List<Map<String, dynamic>> get filteredRooms {
    var list = rooms.toList();
    if (selectedBranchId.value != null) {
      list = list
          .where((r) => r['branch_id'] == selectedBranchId.value)
          .toList();
    }
    if (searchQuery.value.isNotEmpty) {
      list = list
          .where(
            (r) => r['name'].toString().toLowerCase().contains(
              searchQuery.value.toLowerCase(),
            ),
          )
          .toList();
    }
    return list;
  }

  List<Map<String, dynamic>> get filteredClasses {
    var list = classes.toList();
    if (selectedBranchId.value != null) {
      list = list
          .where((c) => c['branch_id'] == selectedBranchId.value)
          .toList();
    }
    if (searchQuery.value.isNotEmpty) {
      list = list
          .where(
            (c) => c['name'].toString().toLowerCase().contains(
              searchQuery.value.toLowerCase(),
            ),
          )
          .toList();
    }
    return list;
  }

  @override
  void onInit() {
    super.onInit();
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    isLoading.value = true;
    try {
      await loadBranches();
      await Future.wait([loadRooms(), loadClasses(), loadStatistics()]);
    } catch (e) {
      Get.snackbar('Xato', 'Ma\'lumotlarni yuklashda xatolik: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadBranches() async {
    try {
      final response = await _supabaseService.client
          .from('branches')
          .select('id, name')
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
          'room_number': room['room_number'],
          'assigned_class': assignedClass,
        };
      }).toList();

      totalRooms.value = rooms.length;
      availableRooms.value = rooms
          .where((r) => r['assigned_class'] == null)
          .length;
    } catch (e) {
      print('Error loading rooms: $e');
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
        final studentCount = (enrollments != null && enrollments.isNotEmpty)
            ? enrollments[0]['count']
            : 0;

        String teacherName = 'Biriktirilmagan';
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
    }
  }

  Future<void> loadStatistics() async {
    try {
      final studentsCount = await _supabaseService.client
          .from('students')
          .count()
          .eq('status', 'active');
      totalStudents.value = studentsCount;

      final teachersCount = await _supabaseService.client
          .from('staff')
          .count()
          .eq('is_teacher', true)
          .eq('status', 'active');
      totalTeachers.value = teachersCount;
    } catch (e) {
      print('Error loading statistics: $e');
    }
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
  }

  // --- QO'SHILGAN FUNKSIYA ---
  void showFilterDialog() {
    Get.defaultDialog(
      title: "Filtrlash",
      content: Column(
        children: [
          const Text("Filial bo'yicha saralash"),
          const SizedBox(height: 10),
          Obx(
            () => DropdownButton<String>(
              value: selectedBranchId.value,
              hint: const Text("Barcha filiallar"),
              isExpanded: true,
              onChanged: (String? newValue) {
                selectedBranchId.value = newValue;
              },
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text("Barcha filiallar"),
                ),
                ...branches.map((branch) {
                  return DropdownMenuItem<String>(
                    value: branch['id'],
                    child: Text(branch['name']),
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
      textConfirm: "OK",
      confirmTextColor: Colors.white,
      onConfirm: () => Get.back(),
    );
  }
}
