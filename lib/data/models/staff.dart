// lib/data/models/staff_models.dart
// IZOH: Kengaytirilgan hodim modellari

// =====================================================
// 1. ASOSIY STAFF MODEL (Yangilangan)
// =====================================================
class StaffEnhanced {
  final String id;
  final String? userId;
  final String branchId;
  final String branchName;
  final String firstName;
  final String lastName;
  final String? middleName;
  final String gender;
  final DateTime? birthDate;
  final String phone;
  final String? phoneSecondary;
  final String? region;
  final String? district;
  final String? address;
  final String position;
  final String department;
  final bool isTeacher;
  final String salaryType;
  final double? baseSalary;
  final double? hourlyRate;
  final double? dailyRate;
  final int? expectedHoursPerMonth;
  final DateTime? hireDate;
  final String status;
  final DateTime createdAt;

  // Qo'shimcha statistika
  final int certificationsCount;
  final int activeLeavesCount;
  final double? latestRating;
  final int achievementsCount;
  final int activeWarningsCount;

  StaffEnhanced({
    required this.id,
    this.userId,
    required this.branchId,
    required this.branchName,
    required this.firstName,
    required this.lastName,
    this.middleName,
    required this.gender,
    this.birthDate,
    required this.phone,
    this.phoneSecondary,
    this.region,
    this.district,
    this.address,
    required this.position,
    required this.department,
    required this.isTeacher,
    required this.salaryType,
    this.baseSalary,
    this.hourlyRate,
    this.dailyRate,
    this.expectedHoursPerMonth,
    this.hireDate,
    required this.status,
    required this.createdAt,
    this.certificationsCount = 0,
    this.activeLeavesCount = 0,
    this.latestRating,
    this.achievementsCount = 0,
    this.activeWarningsCount = 0,
  });

  factory StaffEnhanced.fromJson(Map<String, dynamic> json) {
    return StaffEnhanced(
      id: json['id'] ?? '',
      userId: json['user_id'],
      branchId: json['branch_id'] ?? '',
      branchName: json['branch_name'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      middleName: json['middle_name'],
      gender: json['gender'] ?? 'male',
      birthDate: json['birth_date'] != null
          ? DateTime.parse(json['birth_date'])
          : null,
      phone: json['phone'] ?? '',
      phoneSecondary: json['phone_secondary'],
      region: json['region'],
      district: json['district'],
      address: json['address'],
      position: json['position'] ?? '',
      department: json['department'] ?? '',
      isTeacher: json['is_teacher'] ?? false,
      salaryType: json['salary_type'] ?? 'monthly',
      baseSalary: json['base_salary']?.toDouble(),
      hourlyRate: json['hourly_rate']?.toDouble(),
      dailyRate: json['daily_rate']?.toDouble(),
      expectedHoursPerMonth: json['expected_hours_per_month'],
      hireDate: json['hire_date'] != null
          ? DateTime.parse(json['hire_date'])
          : null,
      status: json['status'] ?? 'active',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      certificationsCount: json['certifications_count'] ?? 0,
      activeLeavesCount: json['active_leaves_count'] ?? 0,
      latestRating: json['latest_rating']?.toDouble(),
      achievementsCount: json['achievements_count'] ?? 0,
      activeWarningsCount: json['active_warnings_count'] ?? 0,
    );
  }

  String get fullName => middleName != null
      ? '$firstName $lastName $middleName'
      : '$firstName $lastName';

  String get statusText {
    switch (status) {
      case 'active':
        return 'Aktiv';
      case 'inactive':
        return 'Noaktiv';
      case 'on_leave':
        return 'Ta\'tilda';
      default:
        return 'Noma\'lum';
    }
  }

  String get workExperienceText {
    if (hireDate == null) return 'N/A';
    final duration = DateTime.now().difference(hireDate!);
    final years = duration.inDays ~/ 365;
    final months = (duration.inDays % 365) ~/ 30;
    if (years > 0) {
      return '$years yil ${months > 0 ? "$months oy" : ""}';
    }
    return '$months oy';
  }

  int get age {
    if (birthDate == null) return 0;
    final today = DateTime.now();
    int age = today.year - birthDate!.year;
    if (today.month < birthDate!.month ||
        (today.month == birthDate!.month && today.day < birthDate!.day)) {
      age--;
    }
    return age;
  }
}

// =====================================================
// 2. STAFF DOCUMENT MODEL
// =====================================================
class StaffDocument {
  final String id;
  final String staffId;
  final String documentType;
  final String? documentNumber;
  final DateTime? issueDate;
  final DateTime? expiryDate;
  final String? issuingAuthority;
  final String? fileUrl;
  final String? notes;
  final DateTime createdAt;

  StaffDocument({
    required this.id,
    required this.staffId,
    required this.documentType,
    this.documentNumber,
    this.issueDate,
    this.expiryDate,
    this.issuingAuthority,
    this.fileUrl,
    this.notes,
    required this.createdAt,
  });

  factory StaffDocument.fromJson(Map<String, dynamic> json) {
    return StaffDocument(
      id: json['id'],
      staffId: json['staff_id'],
      documentType: json['document_type'],
      documentNumber: json['document_number'],
      issueDate: json['issue_date'] != null
          ? DateTime.parse(json['issue_date'])
          : null,
      expiryDate: json['expiry_date'] != null
          ? DateTime.parse(json['expiry_date'])
          : null,
      issuingAuthority: json['issuing_authority'],
      fileUrl: json['file_url'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  String get documentTypeText {
    switch (documentType) {
      case 'passport':
        return 'Passport';
      case 'diploma':
        return 'Diplom';
      case 'certificate':
        return 'Sertifikat';
      case 'contract':
        return 'Shartnoma';
      default:
        return documentType;
    }
  }
}

// =====================================================
// 3. STAFF CERTIFICATION MODEL
// =====================================================
class StaffCertification {
  final String id;
  final String staffId;
  final String certificationName;
  final String? issuingOrganization;
  final DateTime? issueDate;
  final DateTime? expiryDate;
  final String? certificateUrl;
  final double? score;
  final bool isActive;
  final DateTime createdAt;

  StaffCertification({
    required this.id,
    required this.staffId,
    required this.certificationName,
    this.issuingOrganization,
    this.issueDate,
    this.expiryDate,
    this.certificateUrl,
    this.score,
    required this.isActive,
    required this.createdAt,
  });

  factory StaffCertification.fromJson(Map<String, dynamic> json) {
    return StaffCertification(
      id: json['id'],
      staffId: json['staff_id'],
      certificationName: json['certification_name'],
      issuingOrganization: json['issuing_organization'],
      issueDate: json['issue_date'] != null
          ? DateTime.parse(json['issue_date'])
          : null,
      expiryDate: json['expiry_date'] != null
          ? DateTime.parse(json['expiry_date'])
          : null,
      certificateUrl: json['certificate_url'],
      score: json['score']?.toDouble(),
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  bool get isExpired {
    if (expiryDate == null) return false;
    return expiryDate!.isBefore(DateTime.now());
  }
}

// =====================================================
// 4. STAFF EVALUATION MODEL
// =====================================================
class StaffEvaluation {
  final String id;
  final String staffId;
  final String? evaluatorId;
  final String? evaluatorName;
  final DateTime evaluationDate;
  final DateTime periodStart;
  final DateTime periodEnd;
  final double? teachingQuality;
  final double? punctuality;
  final double? communication;
  final double? professionalism;
  final double? studentFeedback;
  final double? overallRating;
  final String? strengths;
  final String? areasForImprovement;
  final String? goals;
  final String? notes;
  final DateTime createdAt;

  StaffEvaluation({
    required this.id,
    required this.staffId,
    this.evaluatorId,
    this.evaluatorName,
    required this.evaluationDate,
    required this.periodStart,
    required this.periodEnd,
    this.teachingQuality,
    this.punctuality,
    this.communication,
    this.professionalism,
    this.studentFeedback,
    this.overallRating,
    this.strengths,
    this.areasForImprovement,
    this.goals,
    this.notes,
    required this.createdAt,
  });

  factory StaffEvaluation.fromJson(Map<String, dynamic> json) {
    return StaffEvaluation(
      id: json['id'],
      staffId: json['staff_id'],
      evaluatorId: json['evaluator_id'],
      evaluatorName: json['evaluator_name'],
      evaluationDate: DateTime.parse(json['evaluation_date']),
      periodStart: DateTime.parse(json['period_start']),
      periodEnd: DateTime.parse(json['period_end']),
      teachingQuality: json['teaching_quality']?.toDouble(),
      punctuality: json['punctuality']?.toDouble(),
      communication: json['communication']?.toDouble(),
      professionalism: json['professionalism']?.toDouble(),
      studentFeedback: json['student_feedback']?.toDouble(),
      overallRating: json['overall_rating']?.toDouble(),
      strengths: json['strengths'],
      areasForImprovement: json['areas_for_improvement'],
      goals: json['goals'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

// =====================================================
// 5. STAFF LEAVE MODEL
// =====================================================
class StaffLeave {
  final String id;
  final String staffId;
  final String leaveType;
  final DateTime startDate;
  final DateTime endDate;
  final int totalDays;
  final String? reason;
  final String status;
  final String? approvedBy;
  final DateTime? approvedAt;
  final String? notes;
  final DateTime createdAt;

  StaffLeave({
    required this.id,
    required this.staffId,
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    required this.totalDays,
    this.reason,
    required this.status,
    this.approvedBy,
    this.approvedAt,
    this.notes,
    required this.createdAt,
  });

  factory StaffLeave.fromJson(Map<String, dynamic> json) {
    return StaffLeave(
      id: json['id'],
      staffId: json['staff_id'],
      leaveType: json['leave_type'],
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      totalDays: json['total_days'],
      reason: json['reason'],
      status: json['status'],
      approvedBy: json['approved_by'],
      approvedAt: json['approved_at'] != null
          ? DateTime.parse(json['approved_at'])
          : null,
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  String get leaveTypeText {
    switch (leaveType) {
      case 'vacation':
        return 'Ta\'til';
      case 'sick':
        return 'Kasallik';
      case 'personal':
        return 'Shaxsiy';
      case 'maternity':
        return 'Tug\'ruq';
      default:
        return leaveType;
    }
  }

  String get statusText {
    switch (status) {
      case 'pending':
        return 'Kutilmoqda';
      case 'approved':
        return 'Tasdiqlangan';
      case 'rejected':
        return 'Rad etilgan';
      default:
        return status;
    }
  }
}

// =====================================================
// 6. STAFF ACHIEVEMENT MODEL
// =====================================================
class StaffAchievement {
  final String id;
  final String staffId;
  final String achievementType;
  final String title;
  final String? description;
  final DateTime? dateAchieved;
  final String? issuedBy;
  final String? certificateUrl;
  final DateTime createdAt;

  StaffAchievement({
    required this.id,
    required this.staffId,
    required this.achievementType,
    required this.title,
    this.description,
    this.dateAchieved,
    this.issuedBy,
    this.certificateUrl,
    required this.createdAt,
  });

  factory StaffAchievement.fromJson(Map<String, dynamic> json) {
    return StaffAchievement(
      id: json['id'],
      staffId: json['staff_id'],
      achievementType: json['achievement_type'],
      title: json['title'],
      description: json['description'],
      dateAchieved: json['date_achieved'] != null
          ? DateTime.parse(json['date_achieved'])
          : null,
      issuedBy: json['issued_by'],
      certificateUrl: json['certificate_url'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
