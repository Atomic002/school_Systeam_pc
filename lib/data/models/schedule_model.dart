// lib/data/models/schedule_template.dart
class ScheduleTemplate {
  final String id;
  final String branchId;
  final String academicYearId;
  final String classId;
  final String dayOfWeek;
  final String startTime;
  final String endTime;
  final String subjectId;
  final String? teacherId;
  final String? roomId;
  final bool isActive;
  final DateTime createdAt;

  // Relations
  final ClassModel? classData;
  final SubjectModel? subject;
  final StaffModel? teacher;
  final RoomModel? room;

  ScheduleTemplate({
    required this.id,
    required this.branchId,
    required this.academicYearId,
    required this.classId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.subjectId,
    this.teacherId,
    this.roomId,
    required this.isActive,
    required this.createdAt,
    this.classData,
    this.subject,
    this.teacher,
    this.room,
  });

  factory ScheduleTemplate.fromJson(Map<String, dynamic> json) {
    return ScheduleTemplate(
      id: json['id'],
      branchId: json['branch_id'],
      academicYearId: json['academic_year_id'],
      classId: json['class_id'],
      dayOfWeek: json['day_of_week'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      subjectId: json['subject_id'],
      teacherId: json['teacher_id'],
      roomId: json['room_id'],
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
      classData: json['classes'] != null
          ? ClassModel.fromJson(json['classes'])
          : null,
      subject: json['subjects'] != null
          ? SubjectModel.fromJson(json['subjects'])
          : null,
      teacher: json['staff'] != null
          ? StaffModel.fromJson(json['staff'])
          : null,
      room: json['rooms'] != null ? RoomModel.fromJson(json['rooms']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'branch_id': branchId,
      'academic_year_id': academicYearId,
      'class_id': classId,
      'day_of_week': dayOfWeek,
      'start_time': startTime,
      'end_time': endTime,
      'subject_id': subjectId,
      'teacher_id': teacherId,
      'room_id': roomId,
      'is_active': isActive,
    };
  }
}

// lib/data/models/schedule_session.dart
class ScheduleSession {
  final String id;
  final String? templateId;
  final String branchId;
  final String academicYearId;
  final String classId;
  final String subjectId;
  final String? teacherId;
  final String? roomId;
  final DateTime sessionDate;
  final String startTime;
  final String endTime;
  final String status; // scheduled, in_progress, completed, cancelled
  final String? notes;
  final String? homework;
  final String? materials;
  final int? lessonNumber;

  // Relations
  final ClassModel? classData;
  final SubjectModel? subject;
  final StaffModel? teacher;
  final RoomModel? room;

  ScheduleSession({
    required this.id,
    this.templateId,
    required this.branchId,
    required this.academicYearId,
    required this.classId,
    required this.subjectId,
    this.teacherId,
    this.roomId,
    required this.sessionDate,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.notes,
    this.homework,
    this.materials,
    this.lessonNumber,
    this.classData,
    this.subject,
    this.teacher,
    this.room,
  });

  factory ScheduleSession.fromJson(Map<String, dynamic> json) {
    return ScheduleSession(
      id: json['id'],
      templateId: json['template_id'],
      branchId: json['branch_id'],
      academicYearId: json['academic_year_id'],
      classId: json['class_id'],
      subjectId: json['subject_id'],
      teacherId: json['teacher_id'],
      roomId: json['room_id'],
      sessionDate: DateTime.parse(json['session_date']),
      startTime: json['start_time'],
      endTime: json['end_time'],
      status: json['status'] ?? 'scheduled',
      notes: json['notes'],
      homework: json['homework'],
      materials: json['materials'],
      lessonNumber: json['lesson_number'],
      classData: json['classes'] != null
          ? ClassModel.fromJson(json['classes'])
          : null,
      subject: json['subjects'] != null
          ? SubjectModel.fromJson(json['subjects'])
          : null,
      teacher: json['staff'] != null
          ? StaffModel.fromJson(json['staff'])
          : null,
      room: json['rooms'] != null ? RoomModel.fromJson(json['rooms']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'template_id': templateId,
      'branch_id': branchId,
      'academic_year_id': academicYearId,
      'class_id': classId,
      'subject_id': subjectId,
      'teacher_id': teacherId,
      'room_id': roomId,
      'session_date': sessionDate.toIso8601String().split('T')[0],
      'start_time': startTime,
      'end_time': endTime,
      'status': status,
      'notes': notes,
      'homework': homework,
      'materials': materials,
      'lesson_number': lessonNumber,
    };
  }
}

// lib/data/models/class_model.dart
class ClassModel {
  final String id;
  final String name;
  final String code;
  final String? classLevelName;

  ClassModel({
    required this.id,
    required this.name,
    required this.code,
    this.classLevelName,
  });

  factory ClassModel.fromJson(Map<String, dynamic> json) {
    return ClassModel(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      classLevelName: json['class_levels']?['name'],
    );
  }
}

// lib/data/models/subject_model.dart
class SubjectModel {
  final String id;
  final String name;
  final String code;

  SubjectModel({required this.id, required this.name, required this.code});

  factory SubjectModel.fromJson(Map<String, dynamic> json) {
    return SubjectModel(id: json['id'], name: json['name'], code: json['code']);
  }
}

// lib/data/models/room_model.dart
class RoomModel {
  final String id;
  final String name;
  final int? capacity;
  final int? floor;

  RoomModel({required this.id, required this.name, this.capacity, this.floor});

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: json['id'],
      name: json['name'],
      capacity: json['capacity'],
      floor: json['floor'],
    );
  }
}

// lib/data/models/staff_model.dart
class StaffModel {
  final String id;
  final String firstName;
  final String lastName;
  final String? middleName;

  StaffModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.middleName,
  });

  factory StaffModel.fromJson(Map<String, dynamic> json) {
    return StaffModel(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      middleName: json['middle_name'],
    );
  }

  String get fullName {
    final parts = [
      firstName,
      middleName,
      lastName,
    ].where((p) => p != null && p.isNotEmpty).toList();
    return parts.join(' ');
  }
}
