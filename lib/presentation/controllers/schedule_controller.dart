import 'package:flutter_application_1/data/models/schedule_model.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ScheduleController extends GetxController {
  final supabase = Supabase.instance.client;

  final isLoading = false.obs;
  final scheduleTemplates = <ScheduleTemplate>[].obs;
  final scheduleSessions = <ScheduleSession>[].obs;
  final classes = <ClassModel>[].obs;
  final subjects = <SubjectModel>[].obs;
  final teachers = <StaffModel>[].obs;
  final rooms = <RoomModel>[].obs;

  final selectedClassId = Rxn<String>();
  final selectedTeacherId = Rxn<String>();
  final selectedDate = DateTime.now().obs;

  @override
  void onInit() {
    super.onInit();
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    await Future.wait([
      loadClasses(),
      loadSubjects(),
      loadTeachers(),
      loadRooms(),
    ]);
    await loadScheduleTemplates();
  }

  Future<void> loadClasses() async {
    try {
      final response = await supabase
          .from('classes')
          .select('*, class_levels(name)')
          .eq('is_active', true)
          .order('name');

      classes.value = (response as List)
          .map((json) => ClassModel.fromJson(json))
          .toList();
    } catch (e) {
      Get.snackbar('Xato', 'Sinflar yuklanmadi: $e');
    }
  }

  Future<void> loadSubjects() async {
    try {
      final response = await supabase
          .from('subjects')
          .select('*')
          .eq('is_active', true)
          .order('name');

      subjects.value = (response as List)
          .map((json) => SubjectModel.fromJson(json))
          .toList();
    } catch (e) {
      Get.snackbar('Xato', 'Fanlar yuklanmadi: $e');
    }
  }

  Future<void> loadTeachers() async {
    try {
      final response = await supabase
          .from('staff')
          .select('*')
          .eq('is_teacher', true)
          .eq('status', 'active')
          .order('first_name');

      teachers.value = (response as List)
          .map((json) => StaffModel.fromJson(json))
          .toList();
    } catch (e) {
      Get.snackbar('Xato', 'O\'qituvchilar yuklanmadi: $e');
    }
  }

  Future<void> loadRooms() async {
    try {
      final response = await supabase
          .from('rooms')
          .select('*')
          .eq('is_active', true)
          .order('name');

      rooms.value = (response as List)
          .map((json) => RoomModel.fromJson(json))
          .toList();
    } catch (e) {
      Get.snackbar('Xato', 'Xonalar yuklanmadi: $e');
    }
  }

  Future<void> loadScheduleTemplates() async {
    isLoading.value = true;
    try {
      var query = supabase
          .from('schedule_templates')
          .select('''
        *,
        classes(id, name, code, class_levels(name)),
        subjects(id, name, code),
        staff(id, first_name, last_name, middle_name),
        rooms(id, name, capacity, floor)
      ''')
          .eq('is_active', true);

      if (selectedClassId.value != null) {
        query = query.eq('class_id', selectedClassId.value!);
      }

      if (selectedTeacherId.value != null) {
        query = query.eq('teacher_id', selectedTeacherId.value!);
      }

      final response = await query.order('start_time');

      scheduleTemplates.value = (response as List)
          .map((json) => ScheduleTemplate.fromJson(json))
          .toList();
    } catch (e) {
      Get.snackbar('Xato', 'Jadval yuklanmadi: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadScheduleSessions(DateTime date) async {
    isLoading.value = true;
    try {
      var query = supabase
          .from('schedule_sessions')
          .select('''
        *,
        classes(id, name, code),
        subjects(id, name, code),
        staff(id, first_name, last_name),
        rooms(id, name)
      ''')
          .eq('session_date', date.toIso8601String().split('T')[0]);

      if (selectedClassId.value != null) {
        query = query.eq('class_id', selectedClassId.value!);
      }

      if (selectedTeacherId.value != null) {
        query = query.eq('teacher_id', selectedTeacherId.value!);
      }

      final response = await query.order('start_time');

      scheduleSessions.value = (response as List)
          .map((json) => ScheduleSession.fromJson(json))
          .toList();
    } catch (e) {
      Get.snackbar('Xato', 'Darslar yuklanmadi: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createScheduleTemplate(ScheduleTemplate template) async {
    try {
      await supabase.from('schedule_templates').insert(template.toJson());

      await loadScheduleTemplates();
      Get.snackbar('Muvaffaqiyat', 'Dars jadvali qo\'shildi');
      return true;
    } catch (e) {
      Get.snackbar('Xato', 'Dars qo\'shilmadi: $e');
      return false;
    }
  }

  Future<bool> updateScheduleTemplate(ScheduleTemplate template) async {
    try {
      await supabase
          .from('schedule_templates')
          .update(template.toJson())
          .eq('id', template.id);

      await loadScheduleTemplates();
      Get.snackbar('Muvaffaqiyat', 'Dars yangilandi');
      return true;
    } catch (e) {
      Get.snackbar('Xato', 'Dars yangilanmadi: $e');
      return false;
    }
  }

  Future<bool> deleteScheduleTemplate(String id) async {
    try {
      await supabase.from('schedule_templates').delete().eq('id', id);

      await loadScheduleTemplates();
      Get.snackbar('Muvaffaqiyat', 'Dars o\'chirildi');
      return true;
    } catch (e) {
      Get.snackbar('Xato', 'Dars o\'chirilmadi: $e');
      return false;
    }
  }

  Map<String, List<ScheduleTemplate>> getGroupedByDay() {
    final grouped = <String, List<ScheduleTemplate>>{};

    for (var template in scheduleTemplates) {
      if (!grouped.containsKey(template.dayOfWeek)) {
        grouped[template.dayOfWeek] = [];
      }
      grouped[template.dayOfWeek]!.add(template);
    }

    return grouped;
  }

  List<ScheduleTemplate> getTemplatesForDay(String dayOfWeek) {
    return scheduleTemplates.where((t) => t.dayOfWeek == dayOfWeek).toList();
  }

  void setClassFilter(String? classId) {
    selectedClassId.value = classId;
    loadScheduleTemplates();
  }

  void setTeacherFilter(String? teacherId) {
    selectedTeacherId.value = teacherId;
    loadScheduleTemplates();
  }

  void setDate(DateTime date) {
    selectedDate.value = date;
    loadScheduleSessions(date);
  }
}
