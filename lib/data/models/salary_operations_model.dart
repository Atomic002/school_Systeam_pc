// lib/data/models/salary_operation.dart
// IZOH: Maosh operatsiyalari uchun model - Supabase "salary_operations" jadvalidagi ma'lumotlarni ifodalaydi

class SalaryOperation {
  final String id;
  final String branchId;
  final String staffId;
  final String operationType; // 'salary', 'advance', 'loan'
  final int periodMonth;
  final int periodYear;
  final double baseAmount;
  final int? workedDays;
  final int? workedHours;
  final double bonusPercent;
  final double bonusAmount;
  final double penaltyPercent;
  final double penaltyAmount;
  final double advanceDeduction;
  final double loanDeduction;
  final double grossAmount;
  final double netAmount;
  final bool isPaid;
  final DateTime? paidAt;
  final String? notes;
  final String calculatedBy;
  final String? paidBy;
  final DateTime createdAt;

  // Staff ma'lumotlari (JOIN qilinganda)
  final String? staffFirstName;
  final String? staffLastName;
  final String? staffPosition;
  final String? staffSalaryType;

  SalaryOperation({
    required this.id,
    required this.branchId,
    required this.staffId,
    required this.operationType,
    required this.periodMonth,
    required this.periodYear,
    required this.baseAmount,
    this.workedDays,
    this.workedHours,
    required this.bonusPercent,
    required this.bonusAmount,
    required this.penaltyPercent,
    required this.penaltyAmount,
    required this.advanceDeduction,
    required this.loanDeduction,
    required this.grossAmount,
    required this.netAmount,
    required this.isPaid,
    this.paidAt,
    this.notes,
    required this.calculatedBy,
    this.paidBy,
    required this.createdAt,
    this.staffFirstName,
    this.staffLastName,
    this.staffPosition,
    this.staffSalaryType,
  });

  // Supabase JSON dan model yaratish
  factory SalaryOperation.fromJson(Map<String, dynamic> json) {
    return SalaryOperation(
      id: json['id'] ?? '',
      branchId: json['branch_id'] ?? '',
      staffId: json['staff_id'] ?? '',
      operationType: json['operation_type'] ?? 'salary',
      periodMonth: json['period_month'] ?? 0,
      periodYear: json['period_year'] ?? 0,
      baseAmount: (json['base_amount'] ?? 0).toDouble(),
      workedDays: json['worked_days'],
      workedHours: json['worked_hours'],
      bonusPercent: (json['bonus_percent'] ?? 0).toDouble(),
      bonusAmount: (json['bonus_amount'] ?? 0).toDouble(),
      penaltyPercent: (json['penalty_percent'] ?? 0).toDouble(),
      penaltyAmount: (json['penalty_amount'] ?? 0).toDouble(),
      advanceDeduction: (json['advance_deduction'] ?? 0).toDouble(),
      loanDeduction: (json['loan_deduction'] ?? 0).toDouble(),
      grossAmount: (json['gross_amount'] ?? 0).toDouble(),
      netAmount: (json['net_amount'] ?? 0).toDouble(),
      isPaid: json['is_paid'] ?? false,
      paidAt: json['paid_at'] != null ? DateTime.parse(json['paid_at']) : null,
      notes: json['notes'],
      calculatedBy: json['calculated_by'] ?? '',
      paidBy: json['paid_by'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      // Staff ma'lumotlari (agar JOIN bo'lsa)
      staffFirstName: json['staff']?['first_name'],
      staffLastName: json['staff']?['last_name'],
      staffPosition: json['staff']?['position'],
      staffSalaryType: json['staff']?['salary_type'],
    );
  }

  // Model ni JSON ga aylantirish (Supabase ga yuborish uchun)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'branch_id': branchId,
      'staff_id': staffId,
      'operation_type': operationType,
      'period_month': periodMonth,
      'period_year': periodYear,
      'base_amount': baseAmount,
      'worked_days': workedDays,
      'worked_hours': workedHours,
      'bonus_percent': bonusPercent,
      'bonus_amount': bonusAmount,
      'penalty_percent': penaltyPercent,
      'penalty_amount': penaltyAmount,
      'advance_deduction': advanceDeduction,
      'loan_deduction': loanDeduction,
      'gross_amount': grossAmount,
      'net_amount': netAmount,
      'is_paid': isPaid,
      'paid_at': paidAt?.toIso8601String(),
      'notes': notes,
      'calculated_by': calculatedBy,
      'paid_by': paidBy,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Staff to'liq ismi
  String get staffFullName {
    if (staffFirstName != null && staffLastName != null) {
      return '$staffFirstName $staffLastName';
    }
    return 'Noma\'lum hodim';
  }

  // Oy nomi olish
  String get monthName {
    const months = [
      'Yanvar',
      'Fevral',
      'Mart',
      'Aprel',
      'May',
      'Iyun',
      'Iyul',
      'Avgust',
      'Sentabr',
      'Oktabr',
      'Noyabr',
      'Dekabr',
    ];
    return months[periodMonth - 1];
  }

  // Davr (oy va yil) string ko'rinishda
  String get periodString => '$monthName $periodYear';

  // Operatsiya turi nomi
  String get operationTypeName {
    switch (operationType) {
      case 'salary':
        return 'Oylik maosh';
      case 'advance':
        return 'Avans';
      case 'loan':
        return 'Qarz';
      default:
        return 'Noma\'lum';
    }
  }

  // Status rangi
  String get statusColor {
    return isPaid ? 'green' : 'orange';
  }

  // Status matni
  String get statusText {
    return isPaid ? 'To\'langan' : 'Kutilmoqda';
  }
}
