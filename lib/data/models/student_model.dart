class StudentModel {
  final String id;
  final String branchId;
  final String firstName;
  final String lastName;
  final String? middleName;
  final String gender;
  final DateTime? birthDate;
  final String? phone;
  final String? phoneSecondary;
  final String? address;
  final String? region;
  final String? district;

  // Ota-ona ma'lumotlari
  final String parentFirstName;
  final String parentLastName;
  final String? parentMiddleName;
  final String parentPhone;
  final String? parentPhoneSecondary;
  final String? parentWorkplace;
  final String? parentRelation;

  // Moliyaviy ma'lumotlar
  final double monthlyFee;
  final double discountPercent;
  final double discountAmount;
  final String? discountReason; // YANGI: Chegirma sababi
  final double? finalMonthlyFee;

  // Qo'shimcha ma'lumotlar
  final String? notes;
  final String? medicalNotes;
  final String? visitorId;
  final String status;
  final DateTime? enrollmentDate;
  final String? createdBy;

  // Sinf ma'lumotlari (YANGILANGAN)
  final String? classId;
  final String? classLevelId; // YANGI: Sinf darajasi ID
  final String? classLevelName; // YANGI: Sinf darajasi nomi (1-sinf, 2-sinf)
  final String? className; // YANGI: Sinf nomi (1-A, 2-B)

  // Xona ma'lumotlari (YANGI)
  final String? roomId;
  final String? roomName; // Xona nomi (Xona 101)

  // O'qituvchi ma'lumotlari (YANGI)
  final String? mainTeacherId; // Sinf kuratori
  final String? mainTeacherName; // Kurator ismi

  final DateTime? createdAt;
  final DateTime? updatedAt;

  StudentModel({
    required this.id,
    required this.branchId,
    required this.firstName,
    required this.lastName,
    this.middleName,
    required this.gender,
    this.birthDate,
    this.phone,
    this.phoneSecondary,
    this.address,
    this.region,
    this.district,
    required this.parentFirstName,
    required this.parentLastName,
    this.parentMiddleName,
    required this.parentPhone,
    this.parentPhoneSecondary,
    this.parentWorkplace,
    this.parentRelation,
    required this.monthlyFee,
    this.discountPercent = 0,
    this.discountAmount = 0,
    this.discountReason,
    this.finalMonthlyFee,
    this.notes,
    this.medicalNotes,
    this.visitorId,
    this.status = 'active',
    this.enrollmentDate,
    this.createdBy,
    this.classId,
    this.classLevelId,
    this.classLevelName,
    this.className,
    this.roomId,
    this.roomName,
    this.mainTeacherId,
    this.mainTeacherName,
    this.createdAt,
    this.updatedAt,
  });

  // To'liq ism
  String get fullName {
    final parts = [
      lastName,
      firstName,
      middleName,
    ].where((p) => p != null && p.isNotEmpty).toList();
    return parts.join(' ');
  }

  // Ota-ona to'liq ismi
  String get parentFullName {
    final parts = [
      parentLastName,
      parentFirstName,
      parentMiddleName,
    ].where((p) => p != null && p.isNotEmpty).toList();
    return parts.join(' ');
  }

  // YANGI: Sinf to'liq nomi
  String get classFullName {
    if (classLevelName != null && className != null) {
      return '$classLevelName - $className';
    }
    if (className != null) return className!;
    if (classLevelName != null) return classLevelName!;
    return 'Sinfga biriktirilmagan';
  }

  // YANGI: O'qituvchi ma'lumoti
  String get teacherInfo {
    return mainTeacherName ?? 'Kurator tayinlanmagan';
  }

  // YANGI: Xona ma'lumoti
  String get roomInfo {
    return roomName ?? 'Xona biriktirilmagan';
  }

  // Yosh hisobi
  int? get age {
    if (birthDate == null) return null;
    final now = DateTime.now();
    int age = now.year - birthDate!.year;
    if (now.month < birthDate!.month ||
        (now.month == birthDate!.month && now.day < birthDate!.day)) {
      age--;
    }
    return age;
  }

  // Status rangi
  String get statusColor {
    switch (status) {
      case 'active':
        return '#4CAF50'; // Yashil
      case 'paused':
        return '#FF9800'; // To'q sariq
      case 'graduated':
        return '#2196F3'; // Ko'k
      case 'expelled':
        return '#F44336'; // Qizil
      default:
        return '#9E9E9E'; // Kulrang
    }
  }

  // Status matni
  String get statusText {
    switch (status) {
      case 'active':
        return 'Faol';
      case 'paused':
        return 'To\'xtatilgan';
      case 'graduated':
        return 'Bitirgan';
      case 'expelled':
        return 'Chiqarilgan';
      default:
        return 'Noma\'lum';
    }
  }

  // YANGI: Chegirma ma'lumoti
  String get discountInfo {
    if (discountPercent > 0) {
      final reason = discountReason?.isNotEmpty == true
          ? ' ($discountReason)'
          : '';
      return '$discountPercent%$reason';
    }
    return 'Yo\'q';
  }

  // JSON'dan model yaratish
  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['id'] as String,
      branchId: json['branch_id'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      middleName: json['middle_name'] as String?,
      gender: json['gender'] as String,
      birthDate: json['birth_date'] != null
          ? DateTime.parse(json['birth_date'] as String)
          : null,
      phone: json['phone'] as String?,
      phoneSecondary: json['phone_secondary'] as String?,
      address: json['address'] as String?,
      region: json['region'] as String?,
      district: json['district'] as String?,
      parentFirstName: json['parent_first_name'] as String,
      parentLastName: json['parent_last_name'] as String,
      parentMiddleName: json['parent_middle_name'] as String?,
      parentPhone: json['parent_phone'] as String,
      parentPhoneSecondary: json['parent_phone_secondary'] as String?,
      parentWorkplace: json['parent_workplace'] as String?,
      parentRelation: json['parent_relation'] as String?,
      monthlyFee: (json['monthly_fee'] as num?)?.toDouble() ?? 0.0,
      discountPercent: (json['discount_percent'] as num?)?.toDouble() ?? 0.0,
      discountAmount: (json['discount_amount'] as num?)?.toDouble() ?? 0.0,
      discountReason: json['discount_reason'] as String?,
      finalMonthlyFee: (json['final_monthly_fee'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
      medicalNotes: json['medical_notes'] as String?,
      visitorId: json['visitor_id'] as String?,
      status: json['status'] as String? ?? 'active',
      enrollmentDate: json['enrollment_date'] != null
          ? DateTime.parse(json['enrollment_date'] as String)
          : null,
      createdBy: json['created_by'] as String?,
      classId: json['class_id'] as String?,
      classLevelId: json['class_level_id'] as String?,
      classLevelName: json['class_level_name'] as String?,
      className: json['class_name'] as String?,
      roomId: json['room_id'] as String?,
      roomName: json['room_name'] as String?,
      mainTeacherId: json['main_teacher_id'] as String?,
      mainTeacherName: json['main_teacher_name'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  // Model'ni JSON'ga aylantirish
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'branch_id': branchId,
      'first_name': firstName,
      'last_name': lastName,
      'middle_name': middleName,
      'gender': gender,
      'birth_date': birthDate?.toIso8601String(),
      'phone': phone,
      'phone_secondary': phoneSecondary,
      'address': address,
      'region': region,
      'district': district,
      'parent_first_name': parentFirstName,
      'parent_last_name': parentLastName,
      'parent_middle_name': parentMiddleName,
      'parent_phone': parentPhone,
      'parent_phone_secondary': parentPhoneSecondary,
      'parent_workplace': parentWorkplace,
      'parent_relation': parentRelation,
      'monthly_fee': monthlyFee,
      'discount_percent': discountPercent,
      'discount_amount': discountAmount,
      'discount_reason': discountReason,
      'final_monthly_fee': finalMonthlyFee,
      'notes': notes,
      'medical_notes': medicalNotes,
      'visitor_id': visitorId,
      'status': status,
      'enrollment_date': enrollmentDate?.toIso8601String(),
      'created_by': createdBy,
      'class_id': classId,
      'class_level_id': classLevelId,
      'class_level_name': classLevelName,
      'class_name': className,
      'room_id': roomId,
      'room_name': roomName,
      'main_teacher_id': mainTeacherId,
      'main_teacher_name': mainTeacherName,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // CopyWith metodi
  StudentModel copyWith({
    String? id,
    String? branchId,
    String? firstName,
    String? lastName,
    String? middleName,
    String? gender,
    DateTime? birthDate,
    String? phone,
    String? phoneSecondary,
    String? address,
    String? region,
    String? district,
    String? parentFirstName,
    String? parentLastName,
    String? parentMiddleName,
    String? parentPhone,
    String? parentPhoneSecondary,
    String? parentWorkplace,
    String? parentRelation,
    double? monthlyFee,
    double? discountPercent,
    double? discountAmount,
    String? discountReason,
    double? finalMonthlyFee,
    String? notes,
    String? medicalNotes,
    String? visitorId,
    String? status,
    DateTime? enrollmentDate,
    String? createdBy,
    String? classId,
    String? classLevelId,
    String? classLevelName,
    String? className,
    String? roomId,
    String? roomName,
    String? mainTeacherId,
    String? mainTeacherName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StudentModel(
      id: id ?? this.id,
      branchId: branchId ?? this.branchId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      middleName: middleName ?? this.middleName,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      phone: phone ?? this.phone,
      phoneSecondary: phoneSecondary ?? this.phoneSecondary,
      address: address ?? this.address,
      region: region ?? this.region,
      district: district ?? this.district,
      parentFirstName: parentFirstName ?? this.parentFirstName,
      parentLastName: parentLastName ?? this.parentLastName,
      parentMiddleName: parentMiddleName ?? this.parentMiddleName,
      parentPhone: parentPhone ?? this.parentPhone,
      parentPhoneSecondary: parentPhoneSecondary ?? this.parentPhoneSecondary,
      parentWorkplace: parentWorkplace ?? this.parentWorkplace,
      parentRelation: parentRelation ?? this.parentRelation,
      monthlyFee: monthlyFee ?? this.monthlyFee,
      discountPercent: discountPercent ?? this.discountPercent,
      discountAmount: discountAmount ?? this.discountAmount,
      discountReason: discountReason ?? this.discountReason,
      finalMonthlyFee: finalMonthlyFee ?? this.finalMonthlyFee,
      notes: notes ?? this.notes,
      medicalNotes: medicalNotes ?? this.medicalNotes,
      visitorId: visitorId ?? this.visitorId,
      status: status ?? this.status,
      enrollmentDate: enrollmentDate ?? this.enrollmentDate,
      createdBy: createdBy ?? this.createdBy,
      classId: classId ?? this.classId,
      classLevelId: classLevelId ?? this.classLevelId,
      classLevelName: classLevelName ?? this.classLevelName,
      className: className ?? this.className,
      roomId: roomId ?? this.roomId,
      roomName: roomName ?? this.roomName,
      mainTeacherId: mainTeacherId ?? this.mainTeacherId,
      mainTeacherName: mainTeacherName ?? this.mainTeacherName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'StudentModel(id: $id, fullName: $fullName, class: $classFullName, '
        'teacher: $teacherInfo, room: $roomInfo, status: $statusText)';
  }
}
