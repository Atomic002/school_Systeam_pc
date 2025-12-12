// lib/data/models/payment_model.dart
// ================================================================================
// PAYMENT MODEL - To'liq to'lov ma'lumotlari modeli
// ================================================================================

class PaymentModel {
  final String id;
  final String branchId;
  final String studentId;
  final String? classId;
  final String? enrollmentId;

  // To'lov turlari
  final String
  paymentType; // 'tuition', 'registration', 'exam', 'other', 'debt_payment'
  final String paymentMethod; // 'cash', 'click', 'terminal', 'owner_fund'
  final String paymentStatus; // 'paid', 'partial', 'cancelled', 'pending'

  // Summalar
  final double amount;
  final double discountPercent;
  final double discountAmount;
  final String? discountReason;
  final double finalAmount;

  // Qarz ma'lumotlari
  final bool isDebt;
  final double debtAmount;
  final double paidAmount;
  final double remainingDebt;

  // Davr
  final int? periodMonth;
  final int? periodYear;
  final DateTime? periodStart;
  final DateTime? periodEnd;

  // Sana va vaqt
  final DateTime paymentDate;
  final String paymentTime;
  final DateTime? dueDate;

  // Qo'shimcha
  final String? receiptNumber;
  final String? notes;
  final String? receivedBy;
  final String? cashRegisterId;

  // Audit
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Qo'shimcha ma'lumotlar (join qilingan)
  String? studentName;
  String? className;
  String? branchName;
  String? receivedByName;
  String? cashRegisterName;

  PaymentModel({
    required this.id,
    required this.branchId,
    required this.studentId,
    this.classId,
    this.enrollmentId,
    required this.paymentType,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.amount,
    required this.discountPercent,
    required this.discountAmount,
    this.discountReason,
    required this.finalAmount,
    required this.isDebt,
    required this.debtAmount,
    required this.paidAmount,
    required this.remainingDebt,
    this.periodMonth,
    this.periodYear,
    this.periodStart,
    this.periodEnd,
    required this.paymentDate,
    required this.paymentTime,
    this.dueDate,
    this.receiptNumber,
    this.notes,
    this.receivedBy,
    this.cashRegisterId,
    required this.createdAt,
    this.updatedAt,
    this.studentName,
    this.className,
    this.branchName,
    this.receivedByName,
    this.cashRegisterName,
  });

  // JSON dan model yaratish
  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] as String,
      branchId: json['branch_id'] as String,
      studentId: json['student_id'] as String,
      classId: json['class_id'] as String?,
      enrollmentId: json['enrollment_id'] as String?,
      paymentType: json['payment_type'] as String,
      paymentMethod: json['payment_method'] as String,
      paymentStatus: json['payment_status'] as String,
      amount: (json['amount'] as num).toDouble(),
      discountPercent: (json['discount_percent'] as num?)?.toDouble() ?? 0,
      discountAmount: (json['discount_amount'] as num?)?.toDouble() ?? 0,
      discountReason: json['discount_reason'] as String?,
      finalAmount: (json['final_amount'] as num).toDouble(),
      isDebt: json['is_debt'] as bool? ?? false,
      debtAmount: (json['debt_amount'] as num?)?.toDouble() ?? 0,
      paidAmount: (json['paid_amount'] as num?)?.toDouble() ?? 0,
      remainingDebt: (json['remaining_debt'] as num?)?.toDouble() ?? 0,
      periodMonth: json['period_month'] as int?,
      periodYear: json['period_year'] as int?,
      periodStart: json['period_start'] != null
          ? DateTime.parse(json['period_start'] as String)
          : null,
      periodEnd: json['period_end'] != null
          ? DateTime.parse(json['period_end'] as String)
          : null,
      paymentDate: DateTime.parse(json['payment_date'] as String),
      paymentTime: json['payment_time'] as String,
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'] as String)
          : null,
      receiptNumber: json['receipt_number'] as String?,
      notes: json['notes'] as String?,
      receivedBy: json['received_by'] as String?,
      cashRegisterId: json['cash_register_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      studentName: json['student_full_name'] as String?,
      className: json['class_name'] as String?,
      branchName: json['branch_name'] as String?,
      receivedByName: json['received_by_name'] as String?,
      cashRegisterName: json['register_name'] as String?,
    );
  }

  // Model dan JSON yaratish
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'branch_id': branchId,
      'student_id': studentId,
      'class_id': classId,
      'enrollment_id': enrollmentId,
      'payment_type': paymentType,
      'payment_method': paymentMethod,
      'payment_status': paymentStatus,
      'amount': amount,
      'discount_percent': discountPercent,
      'discount_amount': discountAmount,
      'discount_reason': discountReason,
      'final_amount': finalAmount,
      'is_debt': isDebt,
      'debt_amount': debtAmount,
      'paid_amount': paidAmount,
      'remaining_debt': remainingDebt,
      'period_month': periodMonth,
      'period_year': periodYear,
      'period_start': periodStart?.toIso8601String(),
      'period_end': periodEnd?.toIso8601String(),
      'payment_date': paymentDate.toIso8601String().split('T')[0],
      'payment_time': paymentTime,
      'due_date': dueDate?.toIso8601String().split('T')[0],
      'receipt_number': receiptNumber,
      'notes': notes,
      'received_by': receivedBy,
      'cash_register_id': cashRegisterId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Davr nomini olish
  String get periodName {
    if (periodMonth == null || periodYear == null) return '-';
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
    return '${months[periodMonth! - 1]} $periodYear';
  }

  // To'lov turi nomini olish
  String get paymentTypeName {
    switch (paymentType) {
      case 'tuition':
        return 'Oylik to\'lov';
      case 'registration':
        return 'Ro\'yxatga olish';
      case 'exam':
        return 'Imtihon';
      case 'debt_payment':
        return 'Qarz to\'lovi';
      case 'other':
        return 'Boshqa';
      default:
        return paymentType;
    }
  }

  // To'lov usuli nomini olish
  String get paymentMethodName {
    switch (paymentMethod) {
      case 'cash':
        return 'Naqd';
      case 'click':
        return 'Click';
      case 'terminal':
        return 'Terminal';
      case 'owner_fund':
        return 'Ega kassasi';
      default:
        return paymentMethod;
    }
  }

  // To'lov holati nomini olish
  String get paymentStatusName {
    switch (paymentStatus) {
      case 'paid':
        return 'To\'langan';
      case 'partial':
        return 'Qisman to\'langan';
      case 'cancelled':
        return 'Bekor qilingan';
      case 'pending':
        return 'Kutilmoqda';
      default:
        return paymentStatus;
    }
  }

  // Nusxa yaratish
  PaymentModel copyWith({
    String? id,
    String? branchId,
    String? studentId,
    String? classId,
    String? enrollmentId,
    String? paymentType,
    String? paymentMethod,
    String? paymentStatus,
    double? amount,
    double? discountPercent,
    double? discountAmount,
    String? discountReason,
    double? finalAmount,
    bool? isDebt,
    double? debtAmount,
    double? paidAmount,
    double? remainingDebt,
    int? periodMonth,
    int? periodYear,
    DateTime? periodStart,
    DateTime? periodEnd,
    DateTime? paymentDate,
    String? paymentTime,
    DateTime? dueDate,
    String? receiptNumber,
    String? notes,
    String? receivedBy,
    String? cashRegisterId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PaymentModel(
      id: id ?? this.id,
      branchId: branchId ?? this.branchId,
      studentId: studentId ?? this.studentId,
      classId: classId ?? this.classId,
      enrollmentId: enrollmentId ?? this.enrollmentId,
      paymentType: paymentType ?? this.paymentType,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      amount: amount ?? this.amount,
      discountPercent: discountPercent ?? this.discountPercent,
      discountAmount: discountAmount ?? this.discountAmount,
      discountReason: discountReason ?? this.discountReason,
      finalAmount: finalAmount ?? this.finalAmount,
      isDebt: isDebt ?? this.isDebt,
      debtAmount: debtAmount ?? this.debtAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      remainingDebt: remainingDebt ?? this.remainingDebt,
      periodMonth: periodMonth ?? this.periodMonth,
      periodYear: periodYear ?? this.periodYear,
      periodStart: periodStart ?? this.periodStart,
      periodEnd: periodEnd ?? this.periodEnd,
      paymentDate: paymentDate ?? this.paymentDate,
      paymentTime: paymentTime ?? this.paymentTime,
      dueDate: dueDate ?? this.dueDate,
      receiptNumber: receiptNumber ?? this.receiptNumber,
      notes: notes ?? this.notes,
      receivedBy: receivedBy ?? this.receivedBy,
      cashRegisterId: cashRegisterId ?? this.cashRegisterId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// ================================================================================
// CASH REGISTER MODEL - Kassa modeli
// ================================================================================

class CashRegisterModel {
  final String id;
  final String branchId;
  final String registerType; // 'cash', 'click', 'terminal', 'owner'
  final String registerName;
  final double currentBalance;
  final double initialBalance;
  final bool isActive;
  final DateTime lastUpdatedAt;
  final String? lastUpdatedBy;
  final DateTime createdAt;

  CashRegisterModel({
    required this.id,
    required this.branchId,
    required this.registerType,
    required this.registerName,
    required this.currentBalance,
    required this.initialBalance,
    required this.isActive,
    required this.lastUpdatedAt,
    this.lastUpdatedBy,
    required this.createdAt,
  });

  factory CashRegisterModel.fromJson(Map<String, dynamic> json) {
    return CashRegisterModel(
      id: json['id'] as String,
      branchId: json['branch_id'] as String,
      registerType: json['register_type'] as String,
      registerName: json['register_name'] as String,
      currentBalance: (json['current_balance'] as num).toDouble(),
      initialBalance: (json['initial_balance'] as num?)?.toDouble() ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      lastUpdatedAt: DateTime.parse(json['last_updated_at'] as String),
      lastUpdatedBy: json['last_updated_by'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'branch_id': branchId,
      'register_type': registerType,
      'register_name': registerName,
      'current_balance': currentBalance,
      'initial_balance': initialBalance,
      'is_active': isActive,
      'last_updated_at': lastUpdatedAt.toIso8601String(),
      'last_updated_by': lastUpdatedBy,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

// ================================================================================
// STUDENT DEBT MODEL - O'quvchi qarz modeli
// ================================================================================

class StudentDebtModel {
  final String id;
  final String studentId;
  final String? classId;
  final String? branchId;
  final double debtAmount;
  final double paidAmount;
  final double remainingAmount;
  final int? periodMonth;
  final int? periodYear;
  final bool isSettled;
  final DateTime? settledAt;
  final DateTime? dueDate;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Qo'shimcha
  String? studentName;
  String? className;

  StudentDebtModel({
    required this.id,
    required this.studentId,
    this.classId,
    this.branchId,
    required this.debtAmount,
    required this.paidAmount,
    required this.remainingAmount,
    this.periodMonth,
    this.periodYear,
    required this.isSettled,
    this.settledAt,
    this.dueDate,
    required this.createdAt,
    this.updatedAt,
    this.studentName,
    this.className,
  });

  factory StudentDebtModel.fromJson(Map<String, dynamic> json) {
    return StudentDebtModel(
      id: json['id'] as String,
      studentId: json['student_id'] as String,
      classId: json['class_id'] as String?,
      branchId: json['branch_id'] as String?,
      debtAmount: (json['debt_amount'] as num).toDouble(),
      paidAmount: (json['paid_amount'] as num?)?.toDouble() ?? 0,
      remainingAmount: (json['remaining_amount'] as num).toDouble(),
      periodMonth: json['period_month'] as int?,
      periodYear: json['period_year'] as int?,
      isSettled: json['is_settled'] as bool? ?? false,
      settledAt: json['settled_at'] != null
          ? DateTime.parse(json['settled_at'] as String)
          : null,
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      studentName: json['student_name'] as String?,
      className: json['class_name'] as String?,
    );
  }

  String get periodName {
    if (periodMonth == null || periodYear == null) return '-';
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
    return '${months[periodMonth! - 1]} $periodYear';
  }

  void operator [](String other) {}
}
