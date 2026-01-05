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
      ]);
      await loadAssignedStudents();
    } catch (e) {
      print('Detail Load Error: $e');
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
          .select('*, branch:branches(name)')
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
        'room_number': response['room_number'],
        'is_available': true, // Mantiqan hisoblash mumkin
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
            id, name, code, main_teacher_id,
            teacher:staff!classes_main_teacher_id_fkey(first_name, last_name),
            enrollments(count)
          ''')
          .eq('default_room_id', roomId!)
          .eq('is_active', true);

      assignedClasses.value = List<Map<String, dynamic>>.from(response).map((cls) {
        final enrollments = cls['enrollments'] as List?;
        final studentCount = (enrollments != null && enrollments.isNotEmpty)
            ? enrollments[0]['count']
            : 0;

        String teacherName = 'Biriktirilmagan';
        if (cls['teacher'] != null) {
          teacherName = '${cls['teacher']['first_name']} ${cls['teacher']['last_name']}';
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
            id, first_name, last_name, position,
            teacher_subjects(subject:subjects(name))
          ''')
          .eq('default_room_id', roomId!)
          .eq('is_teacher', true)
          .eq('status', 'active');

      assignedTeachers.value = List<Map<String, dynamic>>.from(response).map((teacher) {
        final teacherSubjects = teacher['teacher_subjects'] as List?;
        final subjects = teacherSubjects
                ?.map((ts) => ts['subject']?['name'] as String? ?? '')
                .where((s) => s.isNotEmpty)
                .toList() ?? [];

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
      final classIds = assignedClasses.map((c) => c['id']).toList();
      if (classIds.isEmpty) {
        assignedStudents.value = [];
        return;
      }
      final response = await _supabaseService.client
          .from('students')
          .select('id, first_name, last_name, phone, enrollments!inner(class:classes(id, name))')
          .eq('status', 'active')
          .inFilter('enrollments.class_id', classIds);

      assignedStudents.value = List<Map<String, dynamic>>.from(response).map((student) {
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

  void editRoom() async {
    // Tahrirlash sahifasiga o'tish va natijani kutish
    final result = await Get.toNamed('/edit-room', arguments: {'id': roomId});
    
    // Agar muvaffaqiyatli saqlangan bo'lsa (result == true), ma'lumotlarni yangilaymiz
    if (result == true) {
      loadRoomDetails();
    }
  }

  // --- QO'SHILGAN (YETISHMAYOTGAN) FUNKSIYALAR ---

  // 1. Xonani o'chirish
  Future<void> deleteRoom() async {
    Get.defaultDialog(
      title: "Xonani o'chirish",
      middleText: "Haqiqatan ham bu xonani o'chirmoqchimisiz? Ma'lumotlar arxivlanadi.",
      textCancel: "Yo'q",
      textConfirm: "Ha, o'chirish",
      confirmTextColor: Colors.white,
      onConfirm: () async {
        try {
          // Soft delete (is_active = false)
          await _supabaseService.client
              .from('rooms')
              .update({'is_active': false})
              .eq('id', roomId!);
          
          Get.back(); // Dialogni yopish
          Get.back(); // Screen dan chiqish
          Get.snackbar("Muvaffaqiyatli", "Xona o'chirildi", backgroundColor: Colors.green, colorText: Colors.white);
        } catch (e) {
          Get.back();
          Get.snackbar("Xato", "Xonani o'chirishda xatolik: $e", backgroundColor: Colors.red, colorText: Colors.white);
        }
      },
    );
  }

  // 2. Sinf biriktirish (Ro'yxatdan tanlash)
  void assignClass() {
    Get.bottomSheet(
      Container(
        height: 400,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            const Text("Sinfni tanlang", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: FutureBuilder(
                // Hali xonasi yo'q bo'lgan sinflarni yuklash
                future: _supabaseService.client
                    .from('classes')
                    .select('id, name')
.filter('default_room_id', 'is', null)                     .eq('is_active', true),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  final List<dynamic> availableClasses = snapshot.data as List<dynamic>;
                  
                  if (availableClasses.isEmpty) return const Center(child: Text("Bo'sh sinflar mavjud emas"));

                  return ListView.builder(
                    itemCount: availableClasses.length,
                    itemBuilder: (context, index) {
                      final cls = availableClasses[index];
                      return ListTile(
                        leading: const Icon(Icons.class_, color: Colors.blue),
                        title: Text(cls['name']),
                        trailing: const Icon(Icons.add_circle_outline),
                        onTap: () async {
                          try {
                            await _supabaseService.client
                                .from('classes')
                                .update({'default_room_id': roomId})
                                .eq('id', cls['id']);
                            
                            Get.back(); // Sheetni yopish
                            loadAssignedClasses(); // Ro'yxatni yangilash
                            Get.snackbar("Muvaffaqiyatli", "Sinf biriktirildi", backgroundColor: Colors.green, colorText: Colors.white);
                          } catch (e) {
                            Get.snackbar("Xato", "Biriktirishda xatolik");
                          }
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 3. O'qituvchi biriktirish
  void assignTeacher() {
    Get.bottomSheet(
      Container(
        height: 400,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            const Text("O'qituvchini tanlang", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: FutureBuilder(
                // Xonasi yo'q o'qituvchilarni yuklash
                future: _supabaseService.client
                    .from('staff')
                    .select('id, first_name, last_name')
                    .eq('is_teacher', true)
.filter('default_room_id', 'is', null)                     .eq('status', 'active'),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  final List<dynamic> availableTeachers = snapshot.data as List<dynamic>;

                  if (availableTeachers.isEmpty) return const Center(child: Text("Bo'sh o'qituvchilar mavjud emas"));

                  return ListView.builder(
                    itemCount: availableTeachers.length,
                    itemBuilder: (context, index) {
                      final teacher = availableTeachers[index];
                      return ListTile(
                        leading: const Icon(Icons.person, color: Colors.blue),
                        title: Text("${teacher['first_name']} ${teacher['last_name']}"),
                        trailing: const Icon(Icons.add_circle_outline),
                        onTap: () async {
                          try {
                            await _supabaseService.client
                                .from('staff')
                                .update({'default_room_id': roomId})
                                .eq('id', teacher['id']);
                            
                            Get.back();
                            loadAssignedTeachers();
                            Get.snackbar("Muvaffaqiyatli", "O'qituvchi biriktirildi", backgroundColor: Colors.green, colorText: Colors.white);
                          } catch (e) {
                            Get.snackbar("Xato", "Biriktirishda xatolik");
                          }
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 4. O'qituvchini xonadan ajratish
  Future<void> unassignTeacher(String teacherId) async {
    Get.defaultDialog(
      title: "Ajratish",
      middleText: "Bu o'qituvchini xonadan ajratmoqchimisiz?",
      textConfirm: "Ha",
      textCancel: "Yo'q",
      confirmTextColor: Colors.white,
      onConfirm: () async {
        try {
          await _supabaseService.client
              .from('staff')
              .update({'default_room_id': null})
              .eq('id', teacherId);
          
          Get.back(); // Dialogni yopish
          loadAssignedTeachers(); // Ro'yxatni yangilash
          Get.snackbar("Muvaffaqiyatli", "O'qituvchi ajratildi", backgroundColor: Colors.green, colorText: Colors.white);
        } catch (e) {
          Get.back();
          Get.snackbar("Xato", "Ajratishda xatolik: $e", backgroundColor: Colors.red, colorText: Colors.white);
        }
      }
    );
  }
}