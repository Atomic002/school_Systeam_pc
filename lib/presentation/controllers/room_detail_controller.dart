// lib/presentation/controllers/room_detail_controller.dart

import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/services/supabase_service.dart';
import 'package:get/get.dart';

class RoomDetailController extends GetxController {
  final SupabaseService _supabaseService = Get.find<SupabaseService>();

  var isLoading = false.obs;
  var room = Rxn<Map<String, dynamic>>();
  var assignedClasses = <Map<String, dynamic>>[].obs;
  var assignedTeachers = <Map<String, dynamic>>[].obs;
  var assignedStudents = <Map<String, dynamic>>[].obs;

  String? roomId;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    roomId = args?['id'];
    if (roomId != null) {
      loadRoomDetails();
    }
  }

  Future<void> loadRoomDetails() async {
    isLoading.value = true;
    try {
      await Future.wait([
        loadRoom(),
        loadAssignedClasses(),
        loadAssignedTeachers(),
        loadAssignedStudents(),
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

  Future<void> loadRoom() async {
    try {
      final response = await _supabaseService.client
          .from('rooms')
          .select('''
            *,
            branch:branches(name)
          ''')
          .eq('id', roomId!)
          .single();

      room.value = {
        'id': response['id'],
        'name': response['name'],
        'capacity': response['capacity'],
        'floor': response['floor'],
        'room_type': response['room_type'],
        'equipment': response['equipment'],
        'is_active': response['is_active'],
        'branch_name': response['branch']?['name'],
        'branch_id': response['branch_id'],
        'is_available': true, // Bu yerda band/bo'sh logikasini qo'shish mumkin
      };
    } catch (e) {
      print('Error loading room: $e');
    }
  }

  Future<void> loadAssignedClasses() async {
    try {
      final response = await _supabaseService.client
          .from('classes')
          .select('''
            id,
            name,
            code,
            main_teacher_id,
            teacher:users!classes_main_teacher_id_fkey(first_name, last_name),
            enrollments(count)
          ''')
          .eq('default_room_id', roomId!)
          .eq('is_active', true);

      assignedClasses.value = List<Map<String, dynamic>>.from(response).map((
        cls,
      ) {
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
          'teacher_name': teacherName,
          'student_count': studentCount,
        };
      }).toList();
    } catch (e) {
      print('Error loading assigned classes: $e');
    }
  }

  Future<void> loadAssignedTeachers() async {
    try {
      final response = await _supabaseService.client
          .from('staff')
          .select('''
            id,
            first_name,
            last_name,
            position,
            teacher_subjects(
              subject:subjects(name)
            )
          ''')
          .eq('default_room_id', roomId!)
          .eq('is_teacher', true)
          .eq('status', 'active');

      assignedTeachers.value = List<Map<String, dynamic>>.from(response).map((
        teacher,
      ) {
        final teacherSubjects = teacher['teacher_subjects'] as List?;
        final subjects =
            teacherSubjects
                ?.map((ts) => ts['subject']['name'] as String)
                .toList() ??
            [];

        return {
          'id': teacher['id'],
          'first_name': teacher['first_name'],
          'last_name': teacher['last_name'],
          'position': teacher['position'],
          'subjects': subjects,
        };
      }).toList();
    } catch (e) {
      print('Error loading assigned teachers: $e');
    }
  }

  Future<void> loadAssignedStudents() async {
    try {
      // Avval shu xonaga biriktirilgan sinflarni topamiz
      final classIds = assignedClasses.map((c) => c['id']).toList();

      if (classIds.isEmpty) {
        assignedStudents.value = [];
        return;
      }

      final response = await _supabaseService.client
          .from('students')
          .select('''
            id,
            first_name,
            last_name,
            phone,
            enrollments(
              class:classes(id, name)
            )
          ''')
          .eq('status', 'active')
          .inFilter('enrollments.class.id', classIds);

      assignedStudents.value = List<Map<String, dynamic>>.from(response).map((
        student,
      ) {
        final enrollments = student['enrollments'] as List?;
        String? className;
        if (enrollments != null && enrollments.isNotEmpty) {
          className = enrollments[0]['class']?['name'];
        }

        return {
          'id': student['id'],
          'first_name': student['first_name'],
          'last_name': student['last_name'],
          'phone': student['phone'],
          'class_name': className,
        };
      }).toList();
    } catch (e) {
      print('Error loading assigned students: $e');
    }
  }

  void editRoom() {
    // Tahrirlash sahifasiga o'tish
    Get.toNamed('/edit-room', arguments: {'id': roomId});
  }

  void deleteRoom() {
    Get.dialog(
      AlertDialog(
        title: const Text('Xonani o\'chirish'),
        content: const Text('Haqiqatan ham bu xonani o\'chirmoqchimisiz?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Yo\'q')),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              try {
                await _supabaseService.client
                    .from('rooms')
                    .update({'is_active': false})
                    .eq('id', roomId!);

                Get.back(); // Detail screendan chiqish
                Get.snackbar(
                  'Muvaffaqiyatli',
                  'Xona o\'chirildi',
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
              } catch (e) {
                Get.snackbar(
                  'Xato',
                  'Xonani o\'chirishda xatolik: $e',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Ha, o\'chirish'),
          ),
        ],
      ),
    );
  }

  void assignClass() {
    // Sinf biriktirish dialog
    Get.dialog(
      AlertDialog(
        title: const Text('Sinf biriktirish'),
        content: const Text('Bu funksiya hozircha ishlab chiqilmoqda...'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Yopish')),
        ],
      ),
    );
  }

  void assignTeacher() {
    // O'qituvchi biriktirish dialog
    Get.dialog(
      AlertDialog(
        title: const Text('O\'qituvchi biriktirish'),
        content: const Text('Bu funksiya hozircha ishlab chiqilmoqda...'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Yopish')),
        ],
      ),
    );
  }

  Future<void> unassignTeacher(String teacherId) async {
    try {
      await _supabaseService.client
          .from('staff')
          .update({'default_room_id': null})
          .eq('id', teacherId);

      Get.snackbar(
        'Muvaffaqiyatli',
        'O\'qituvchi xonadan ajratildi',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      loadAssignedTeachers();
    } catch (e) {
      Get.snackbar(
        'Xato',
        'O\'qituvchini ajratishda xatolik: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
