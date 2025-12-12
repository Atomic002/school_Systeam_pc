// lib/data/repositories/visitor_repository.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class VisitorRepository {
  final _supabase = Supabase.instance.client;

  // Potensial o'quvchilar (o'quvchiga aylanmagan visitor'lar)
  Future<List<VisitorModel>> getPotentialStudents(String branchId) async {
    try {
      final response = await _supabase
          .from('visitors')
          .select()
          .eq('branch_id', branchId)
          .eq('visitor_type', 'potential_student')
          .eq('is_converted', false)
          .order('visit_date', ascending: false)
          .limit(50);

      return (response as List)
          .map((json) => VisitorModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Get potential students error: $e');
      return [];
    }
  }

  Future<void> convertVisitorToStaff({
    required String visitorId,
    required String staffId,
  }) async {}

  Future<dynamic> getUnconvertedVisitors() async {}
}

Future<List<Map<String, dynamic>>> getUnconvertedVisitors() async {
  try {
    var _supabase;
    final response = await _supabase
        .from('visitors')
        .select('*')
        .eq('is_converted', false)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  } catch (e) {
    print('Get unconverted visitors error: $e');
    return [];
  }
}

// Tashrif buyuruvchini staff ga konvert qilish
Future<void> convertVisitorToStaff({
  required String visitorId,
  required String staffId,
}) async {
  try {
    var _supabase;
    await _supabase
        .from('visitors')
        .update({
          'is_converted': true,
          'converted_at': DateTime.now().toIso8601String(),
          'converted_to_staff_id': staffId,
        })
        .eq('id', visitorId);
  } catch (e) {
    print('Convert visitor error: $e');
    rethrow;
  }
}

// lib/data/repositories/class_repository.dart
Future<List<Map<String, dynamic>>> getAllVisitors({
  String? branchId,
  String? visitorType,
  bool? isConverted,
}) async {
  try {
    var _supabase;
    var query = _supabase.from('visitors').select('*');

    if (branchId != null) {
      query = query.eq('branch_id', branchId);
    }

    if (visitorType != null) {
      query = query.eq('visitor_type', visitorType);
    }

    if (isConverted != null) {
      query = query.eq('is_converted', isConverted);
    }

    final response = await query.order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  } catch (e) {
    print('Get all visitors error: $e');
    return [];
  }
}

class ClassRepository {
  final _supabase = Supabase.instance.client;

  // Sinf darajalarini olish
  Future<List<Map<String, String>>> getClassLevels() async {
    try {
      final response = await _supabase
          .from('class_levels')
          .select('id, name, order_number')
          .eq('is_active', true)
          .order('order_number');

      return (response as List).map((item) {
        return {'id': item['id'] as String, 'name': item['name'] as String};
      }).toList();
    } catch (e) {
      print('Get class levels error: $e');
      return [];
    }
  }

  // Sinflarni o'qituvchi va xona bilan olish
  Future<List<Map<String, String>>> getClassesWithDetails(
    String branchId,
  ) async {
    try {
      final response = await _supabase
          .from('classes')
          .select('''
            id,
            name,
            code,
            class_level_id,
            default_room_id,
            monthly_fee,
            max_students,
            main_teacher_id,
            rooms!default_room_id(name),
            users!main_teacher_id(first_name, last_name)
          ''')
          .eq('branch_id', branchId)
          .eq('is_active', true);

      return (response as List).map((item) {
        final room = item['rooms'] as Map<String, dynamic>?;
        final teacher = item['users'] as Map<String, dynamic>?;

        return {
          'id': item['id'] as String,
          'name': item['name'] as String,
          'code': item['code'] as String,
          'class_level_id': item['class_level_id'] as String,
          'room': room?['name'] as String? ?? 'Xona yo\'q',
          'teacher': teacher != null
              ? '${teacher['first_name']} ${teacher['last_name']}'
              : 'O\'qituvchi yo\'q',
          'monthly_fee': (item['monthly_fee'] as num).toString(),
        };
      }).toList();
    } catch (e) {
      print('Get classes with details error: $e');
      return [];
    }
  }

  // Sinf ma'lumotlarini olish
  Future<Map<String, dynamic>?> getClassDetails(String classId) async {
    try {
      final response = await _supabase
          .from('classes')
          .select('''
            *,
            class_levels(name, order_number),
            rooms!default_room_id(name, capacity, room_type),
            users!main_teacher_id(first_name, last_name, middle_name)
          ''')
          .eq('id', classId)
          .single();

      return response;
    } catch (e) {
      print('Get class details error: $e');
      return null;
    }
  }

  Future<dynamic> getTeachers(String branchId) async {}

  Future<dynamic> getRooms(String branchId) async {}
}

// lib/data/models/visitor_model.dart
class VisitorModel {
  final String id;
  final String? firstName;
  final String? lastName;
  final String? middleName;
  final String? gender;
  final DateTime? birthDate;
  final String? phone;
  final String? address;
  final String? region;
  final String? district;
  final String? notes;
  final DateTime? visitDate;
  final bool isConverted;

  VisitorModel({
    required this.id,
    this.firstName,
    this.lastName,
    this.middleName,
    this.gender,
    this.birthDate,
    this.phone,
    this.address,
    this.region,
    this.district,
    this.notes,
    this.visitDate,
    this.isConverted = false,
  });

  factory VisitorModel.fromJson(Map<String, dynamic> json) {
    return VisitorModel(
      id: json['id'] as String,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      middleName: json['middle_name'] as String?,
      gender: json['gender'] as String?,
      birthDate: json['birth_date'] != null
          ? DateTime.parse(json['birth_date'] as String)
          : null,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      region: json['region'] as String?,
      district: json['district'] as String?,
      notes: json['notes'] as String?,
      visitDate: json['visit_date'] != null
          ? DateTime.parse(json['visit_date'] as String)
          : null,
      isConverted: json['is_converted'] as bool? ?? false,
    );
  }

  String get fullName {
    final parts = <String>[];
    if (lastName != null) parts.add(lastName!);
    if (firstName != null) parts.add(firstName!);
    if (middleName != null) parts.add(middleName!);
    return parts.join(' ');
  }
}
