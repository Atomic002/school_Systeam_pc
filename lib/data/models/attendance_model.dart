// lib/data/models/attendance_model.dart
// IZOH: O'quvchi va hodimlar davomadini boshqaruvchi model.
// Har bir davomat yozuvi bu model orqali saqlanadi.

class AttendanceModel {
  final String id;
  final String branchId;
  final String? studentId; // Agar o'quvchi davomadi bo'lsa
  final String? staffId; // Agar hodim davomadi bo'lsa
  final String? classId;
  final DateTime attendanceDate;
  final String status; // present, absent, late, excused
  final String? arrivalTime;
  final String? checkInTime;
  final String? checkOutTime;
  final String? notes;
  final String markedBy;
  final DateTime markedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  AttendanceModel({
    required this.id,
    required this.branchId,
    this.studentId,
    this.staffId,
    this.classId,
    required this.attendanceDate,
    required this.status,
    this.arrivalTime,
    this.checkInTime,
    this.checkOutTime,
    this.notes,
    required this.markedBy,
    required this.markedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  // JSON'dan parse qilish
  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id'] as String,
      branchId: json['branch_id'] as String,
      studentId: json['student_id'] as String?,
      staffId: json['staff_id'] as String?,
      classId: json['class_id'] as String?,
      attendanceDate: DateTime.parse(json['attendance_date']),
      status: json['status'] as String,
      arrivalTime: json['arrival_time'] as String?,
      checkInTime: json['check_in_time'] as String?,
      checkOutTime: json['check_out_time'] as String?,
      notes: json['notes'] as String?,
      markedBy: json['marked_by'] as String,
      markedAt: DateTime.parse(json['marked_at']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  // JSON'ga konvertatsiya
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'branch_id': branchId,
      'student_id': studentId,
      'staff_id': staffId,
      'class_id': classId,
      'attendance_date': attendanceDate.toIso8601String(),
      'status': status,
      'arrival_time': arrivalTime,
      'check_in_time': checkInTime,
      'check_out_time': checkOutTime,
      'notes': notes,
      'marked_by': markedBy,
      'marked_at': markedAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Davomat statusi o'zbekcha
  String get statusInUzbek {
    switch (status) {
      case 'present':
        return 'Keldi';
      case 'absent':
        return 'Kelmadi';
      case 'late':
        return 'Kechikdi';
      case 'excused':
        return 'Sababli';
      default:
        return status;
    }
  }

  // Davomat turi (o'quvchi yoki hodim)
  bool get isStudentAttendance => studentId != null;
  bool get isStaffAttendance => staffId != null;

  // Status rangi
  String get statusColor {
    switch (status) {
      case 'present':
        return '#10B981'; // Yashil
      case 'absent':
        return '#EF4444'; // Qizil
      case 'late':
        return '#F59E0B'; // Sariq
      case 'excused':
        return '#3B82F6'; // Moviy
      default:
        return '#6B7280'; // Kulrang
    }
  }

  // copyWith metodi
  AttendanceModel copyWith({
    String? id,
    String? branchId,
    String? studentId,
    String? staffId,
    String? classId,
    DateTime? attendanceDate,
    String? status,
    String? arrivalTime,
    String? checkInTime,
    String? checkOutTime,
    String? notes,
    String? markedBy,
    DateTime? markedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AttendanceModel(
      id: id ?? this.id,
      branchId: branchId ?? this.branchId,
      studentId: studentId ?? this.studentId,
      staffId: staffId ?? this.staffId,
      classId: classId ?? this.classId,
      attendanceDate: attendanceDate ?? this.attendanceDate,
      status: status ?? this.status,
      arrivalTime: arrivalTime ?? this.arrivalTime,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      notes: notes ?? this.notes,
      markedBy: markedBy ?? this.markedBy,
      markedAt: markedAt ?? this.markedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
