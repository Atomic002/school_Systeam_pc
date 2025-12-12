// lib/data/models/branch_model.dart

class BranchModel {
  final String id;
  final String name;
  final String? address;
  final String? phone;
  final String? phoneSecondary;
  final String? email;
  final bool isMain;
  final bool isActive;
  final String? workingHoursStart;
  final String? workingHoursEnd;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Statistika ma'lumotlari (join orqali)
  int? totalStudents;
  int? activeStudents;
  int? totalStaff;
  int? totalTeachers;
  int? totalClasses;
  int? totalRooms;
  double? monthlyRevenue;
  double? yearlyRevenue;
  double? totalExpenses;
  double? netProfit;
  double? averageMonthlyFee;
  int? totalDebts;
  double? totalDebtAmount;
  int? graduatedStudents;
  int? pausedStudents;

  BranchModel({
    required this.id,
    required this.name,
    this.address,
    this.phone,
    this.phoneSecondary,
    this.email,
    required this.isMain,
    required this.isActive,
    this.workingHoursStart,
    this.workingHoursEnd,
    required this.createdAt,
    this.updatedAt,
    this.totalStudents,
    this.activeStudents,
    this.totalStaff,
    this.totalTeachers,
    this.totalClasses,
    this.totalRooms,
    this.monthlyRevenue,
    this.yearlyRevenue,
    this.totalExpenses,
    this.netProfit,
    this.averageMonthlyFee,
    this.totalDebts,
    this.totalDebtAmount,
    this.graduatedStudents,
    this.pausedStudents,
  });

  factory BranchModel.fromJson(Map<String, dynamic> json) {
    return BranchModel(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String?,
      phone: json['phone'] as String?,
      phoneSecondary: json['phone_secondary'] as String?,
      email: json['email'] as String?,
      isMain: json['is_main'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
      workingHoursStart: json['working_hours_start'] as String?,
      workingHoursEnd: json['working_hours_end'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      totalStudents: json['total_students'] as int?,
      activeStudents: json['active_students'] as int?,
      totalStaff: json['total_staff'] as int?,
      totalTeachers: json['total_teachers'] as int?,
      totalClasses: json['total_classes'] as int?,
      totalRooms: json['total_rooms'] as int?,
      monthlyRevenue: (json['monthly_revenue'] as num?)?.toDouble(),
      yearlyRevenue: (json['yearly_revenue'] as num?)?.toDouble(),
      totalExpenses: (json['total_expenses'] as num?)?.toDouble(),
      netProfit: (json['net_profit'] as num?)?.toDouble(),
      averageMonthlyFee: (json['average_monthly_fee'] as num?)?.toDouble(),
      totalDebts: json['total_debts'] as int?,
      totalDebtAmount: (json['total_debt_amount'] as num?)?.toDouble(),
      graduatedStudents: json['graduated_students'] as int?,
      pausedStudents: json['paused_students'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'phone': phone,
      'phone_secondary': phoneSecondary,
      'email': email,
      'is_main': isMain,
      'is_active': isActive,
      'working_hours_start': workingHoursStart,
      'working_hours_end': workingHoursEnd,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  BranchModel copyWith({
    String? id,
    String? name,
    String? address,
    String? phone,
    String? phoneSecondary,
    String? email,
    bool? isMain,
    bool? isActive,
    String? workingHoursStart,
    String? workingHoursEnd,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BranchModel(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      phoneSecondary: phoneSecondary ?? this.phoneSecondary,
      email: email ?? this.email,
      isMain: isMain ?? this.isMain,
      isActive: isActive ?? this.isActive,
      workingHoursStart: workingHoursStart ?? this.workingHoursStart,
      workingHoursEnd: workingHoursEnd ?? this.workingHoursEnd,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      totalStudents: totalStudents,
      activeStudents: activeStudents,
      totalStaff: totalStaff,
      totalTeachers: totalTeachers,
      totalClasses: totalClasses,
      totalRooms: totalRooms,
      monthlyRevenue: monthlyRevenue,
      yearlyRevenue: yearlyRevenue,
      totalExpenses: totalExpenses,
      netProfit: netProfit,
      averageMonthlyFee: averageMonthlyFee,
      totalDebts: totalDebts,
      totalDebtAmount: totalDebtAmount,
      graduatedStudents: graduatedStudents,
      pausedStudents: pausedStudents,
    );
  }

  // Status matn
  String get statusText => isActive ? 'Faol' : 'Nofaol';

  // Ish vaqti formatlangan
  String get workingHoursFormatted {
    if (workingHoursStart == null || workingHoursEnd == null) {
      return 'Belgilanmagan';
    }
    return '$workingHoursStart - $workingHoursEnd';
  }

  // Foyda foizi
  double get profitMargin {
    if (yearlyRevenue == null || yearlyRevenue == 0) return 0;
    return ((netProfit ?? 0) / yearlyRevenue!) * 100;
  }

  // O'quvchilar to'ldirish foizi
  double get studentOccupancyRate {
    if (totalStudents == null || totalStudents == 0) return 0;
    final capacity = totalRooms != null ? totalRooms! * 30 : 100;
    return (totalStudents! / capacity) * 100;
  }
}
