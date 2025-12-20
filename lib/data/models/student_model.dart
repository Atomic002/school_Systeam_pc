class StudentModel {
  final String id;
  final String? userId; // YANGI: Login uchun (nullable)
  final String branchId; // UI buzilmasligi uchun String qoldirdik
  final String firstName;
  final String lastName;
  final String? middleName;
  final String gender; // UI da xato bermasligi uchun String qoldirdik
  final DateTime? birthDate;
  final String? phone;
  final String? phoneSecondary;
  final String? address;
  final String? region;
  final String? district;
  final String? photoUrl; // YANGI: Rasm uchun

  // Ota-ona 1 ma'lumotlari
  final String parentFirstName; // UI xatosi oldini olish uchun String (default "" beramiz)
  final String parentLastName;
  final String? parentMiddleName;
  final String parentPhone;
  final String? parentPhoneSecondary;
  final String? parentWorkplace;
  final String? parentRelation;

  // Ota-ona 2 ma'lumotlari (YANGI - Bazada bor)
  final String? parent2FirstName;
  final String? parent2LastName;
  final String? parent2Phone;
  final String? parent2Relation;

  // Moliyaviy ma'lumotlar
  final double monthlyFee;
  final double discountPercent;
  final double discountAmount;
  final String? discountReason;
  // finalMonthlyFee maydoni o'chirildi va pastda getter qilib yozildi

  // Qo'shimcha ma'lumotlar
  final String? notes;
  final String? medicalNotes;
  final String? visitorId;
  final String status;
  final DateTime? enrollmentDate;
  final DateTime? graduationDate; // YANGI
  final String? createdBy;

  // Sinf ma'lumotlari
  final String? classId;
  final String? classLevelId;
  final String? classLevelName;
  final String? className;

  // Xona ma'lumotlari
  final String? roomId;
  final String? roomName;

  // O'qituvchi ma'lumotlari
  final String? mainTeacherId;
  final String? mainTeacherName;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  StudentModel({
    required this.id,
    this.userId,
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
    this.photoUrl,
    required this.parentFirstName,
    required this.parentLastName,
    this.parentMiddleName,
    required this.parentPhone,
    this.parentPhoneSecondary,
    this.parentWorkplace,
    this.parentRelation,
    this.parent2FirstName,
    this.parent2LastName,
    this.parent2Phone,
    this.parent2Relation,
    required this.monthlyFee,
    this.discountPercent = 0,
    this.discountAmount = 0,
    this.discountReason,
    this.notes,
    this.medicalNotes,
    this.visitorId,
    this.status = 'active',
    this.enrollmentDate,
    this.graduationDate,
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

  // --- UI UCHUN KERAKLI GETTERLAR (MUHIM) ---

  // 1. Final summa hisobi (Bazada yo'q, lekin UI da kerak)
  // Oldingi kodingizda bu maydon edi, endi u avtomatik hisoblanadi.
  double get finalMonthlyFee {
    if (monthlyFee == 0) return 0;
    // Agar aniq summa chegirmasi bo'lsa
    if (discountAmount > 0) {
      return monthlyFee - discountAmount;
    }
    // Agar foiz chegirmasi bo'lsa (va summa 0 bo'lsa)
    if (discountPercent > 0) {
      return monthlyFee - (monthlyFee * (discountPercent / 100));
    }
    return monthlyFee;
  }

  // To'liq ism
  String get fullName {
    final parts = [lastName, firstName, middleName].where((p) => p != null && p.isNotEmpty).toList();
    return parts.join(' ');
  }

  // Ota-ona to'liq ismi
  String get parentFullName {
    final parts = [parentLastName, parentFirstName, parentMiddleName].where((p) => p != null && p.isNotEmpty).toList();
    if (parts.isEmpty) return "Ma'lumot yo'q";
    return parts.join(' ');
  }

  // Sinf to'liq nomi
  String get classFullName {
    if (classLevelName != null && className != null) {
      return '$classLevelName - $className';
    }
    if (className != null) return className!;
    if (classLevelName != null) return classLevelName!;
    return 'Sinfga biriktirilmagan';
  }

  // O'qituvchi ma'lumoti
  String get teacherInfo => mainTeacherName ?? 'Kurator tayinlanmagan';

  // Xona ma'lumoti
  String get roomInfo => roomName ?? 'Xona biriktirilmagan';

  // Chegirma ma'lumoti
  String get discountInfo {
    if (discountPercent > 0) return '${discountPercent.toStringAsFixed(0)}%';
    if (discountAmount > 0) return '${discountAmount.toStringAsFixed(0)} so\'m';
    return 'Yo\'q';
  }

  // Yosh hisobi
  int? get age {
    if (birthDate == null) return null;
    final now = DateTime.now();
    int age = now.year - birthDate!.year;
    if (now.month < birthDate!.month || (now.month == birthDate!.month && now.day < birthDate!.day)) {
      age--;
    }
    return age;
  }

  // Status rangi (UI da ishlatilgan bo'lsa)
  String get statusColor {
    switch (status) {
      case 'active': return '#4CAF50';
      case 'paused': return '#FF9800';
      case 'graduated': return '#2196F3';
      case 'expelled': return '#F44336';
      default: return '#9E9E9E';
    }
  }

  // Status matni
  String get statusText {
    switch (status) {
      case 'active': return 'Faol';
      case 'paused': return 'To\'xtatilgan';
      case 'graduated': return 'Bitirgan';
      case 'expelled': return 'Chiqarilgan';
      default: return 'Noma\'lum';
    }
  }

  // JSON'dan model yaratish (Xavfsiz qilingan)
  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['id'] as String,
      userId: json['user_id'] as String?,
      // Bazadan null kelsa, bo'sh string qaytaramiz (UI sinmasligi uchun)
      branchId: json['branch_id'] as String? ?? '', 
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      middleName: json['middle_name'] as String?,
      // Gender null kelsa, default qiymat
      gender: json['gender'] as String? ?? 'male', 
      birthDate: json['birth_date'] != null ? DateTime.parse(json['birth_date'] as String) : null,
      phone: json['phone'] as String?,
      phoneSecondary: json['phone_secondary'] as String?,
      address: json['address'] as String?,
      region: json['region'] as String?,
      district: json['district'] as String?,
      photoUrl: json['photo_url'] as String?,
      
      // Ota-ona ma'lumotlari (Bazada null bo'lishi mumkin, lekin Modelda required turibdi)
      // Shuning uchun null kelsa "" (bo'sh) beramiz.
      parentFirstName: json['parent_first_name'] as String? ?? '',
      parentLastName: json['parent_last_name'] as String? ?? '',
      parentMiddleName: json['parent_middle_name'] as String?,
      parentPhone: json['parent_phone'] as String? ?? '',
      parentPhoneSecondary: json['parent_phone_secondary'] as String?,
      parentWorkplace: json['parent_workplace'] as String?,
      parentRelation: json['parent_relation'] as String?,
      
      // 2-Ota-ona
      parent2FirstName: json['parent2_first_name'] as String?,
      parent2LastName: json['parent2_last_name'] as String?,
      parent2Phone: json['parent2_phone'] as String?,
      parent2Relation: json['parent2_relation'] as String?,

      // Moliya (Raqamlarni xavfsiz o'girish)
      monthlyFee: (json['monthly_fee'] as num?)?.toDouble() ?? 0.0,
      discountPercent: (json['discount_percent'] as num?)?.toDouble() ?? 0.0,
      discountAmount: (json['discount_amount'] as num?)?.toDouble() ?? 0.0,
      discountReason: json['discount_reason'] as String?,
      // finalMonthlyFee bu yerdan o'qilmaydi, u getter.

      notes: json['notes'] as String?,
      medicalNotes: json['medical_notes'] as String?,
      visitorId: json['visitor_id'] as String?,
      status: json['status'] as String? ?? 'active',
      enrollmentDate: json['enrollment_date'] != null ? DateTime.parse(json['enrollment_date'] as String) : null,
      graduationDate: json['graduation_date'] != null ? DateTime.parse(json['graduation_date'] as String) : null,
      createdBy: json['created_by'] as String?,
      
      classId: json['class_id'] as String?,
      classLevelId: json['class_level_id'] as String?,
      classLevelName: json['class_level_name'] as String?,
      className: json['class_name'] as String?,
      roomId: json['room_id'] as String?,
      roomName: json['room_name'] as String?,
      mainTeacherId: json['main_teacher_id'] as String?,
      mainTeacherName: json['main_teacher_name'] as String?,
      
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
    );
  }

  // Model'ni JSON'ga aylantirish
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
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
      'photo_url': photoUrl,
      
      'parent_first_name': parentFirstName,
      'parent_last_name': parentLastName,
      'parent_middle_name': parentMiddleName,
      'parent_phone': parentPhone,
      'parent_phone_secondary': parentPhoneSecondary,
      'parent_workplace': parentWorkplace,
      'parent_relation': parentRelation,
      
      'parent2_first_name': parent2FirstName,
      'parent2_last_name': parent2LastName,
      'parent2_phone': parent2Phone,
      'parent2_relation': parent2Relation,

      'monthly_fee': monthlyFee,
      'discount_percent': discountPercent,
      'discount_amount': discountAmount,
      'discount_reason': discountReason,
      // final_monthly_fee yozilmaydi (u faqat o'qish uchun hisoblanadi)

      'notes': notes,
      'medical_notes': medicalNotes,
      'visitor_id': visitorId,
      'status': status,
      'enrollment_date': enrollmentDate?.toIso8601String(),
      'graduation_date': graduationDate?.toIso8601String(),
      'created_by': createdBy,
      
      'class_id': classId,
      // 'class_level_name', 'class_name' va boshqa join qilingan maydonlar 
      // odatda update paytida backendga yuborilmaydi, lekin saqlab tursangiz zarari yo'q.
    };
  }

  // CopyWith
  StudentModel copyWith({
    String? id,
    String? userId,
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
    String? photoUrl,
    String? parentFirstName,
    String? parentLastName,
    String? parentMiddleName,
    String? parentPhone,
    String? parentPhoneSecondary,
    String? parentWorkplace,
    String? parentRelation,
    String? parent2FirstName,
    String? parent2LastName,
    String? parent2Phone,
    String? parent2Relation,
    double? monthlyFee,
    double? discountPercent,
    double? discountAmount,
    String? discountReason,
    String? notes,
    String? medicalNotes,
    String? visitorId,
    String? status,
    DateTime? enrollmentDate,
    DateTime? graduationDate,
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
      userId: userId ?? this.userId,
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
      photoUrl: photoUrl ?? this.photoUrl,
      parentFirstName: parentFirstName ?? this.parentFirstName,
      parentLastName: parentLastName ?? this.parentLastName,
      parentMiddleName: parentMiddleName ?? this.parentMiddleName,
      parentPhone: parentPhone ?? this.parentPhone,
      parentPhoneSecondary: parentPhoneSecondary ?? this.parentPhoneSecondary,
      parentWorkplace: parentWorkplace ?? this.parentWorkplace,
      parentRelation: parentRelation ?? this.parentRelation,
      parent2FirstName: parent2FirstName ?? this.parent2FirstName,
      parent2LastName: parent2LastName ?? this.parent2LastName,
      parent2Phone: parent2Phone ?? this.parent2Phone,
      parent2Relation: parent2Relation ?? this.parent2Relation,
      monthlyFee: monthlyFee ?? this.monthlyFee,
      discountPercent: discountPercent ?? this.discountPercent,
      discountAmount: discountAmount ?? this.discountAmount,
      discountReason: discountReason ?? this.discountReason,
      notes: notes ?? this.notes,
      medicalNotes: medicalNotes ?? this.medicalNotes,
      visitorId: visitorId ?? this.visitorId,
      status: status ?? this.status,
      enrollmentDate: enrollmentDate ?? this.enrollmentDate,
      graduationDate: graduationDate ?? this.graduationDate,
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
    return 'StudentModel(id: $id, fullName: $fullName, class: $classFullName, status: $statusText)';
  }
}