// lib/presentation/controllers/payment_controller_v5.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/models/student_model.dart';
import '../widgets/payment_history_dialog.dart';
import '../widgets/payment_receipt_dialog.dart';
import 'auth_controller.dart';

// ============================================================================
// MODELS
// ============================================================================
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
  final DateTime? createdAt;
  final String? studentName;
  final String? className;
  final String? studentPhone;

  StudentDebtModel({
    required this.id,
    required this.studentId,
    this.classId,
    this.branchId,
    required this.debtAmount,
    this.paidAmount = 0,
    required this.remainingAmount,
    this.periodMonth,
    this.periodYear,
    this.isSettled = false,
    this.settledAt,
    this.dueDate,
    this.createdAt,
    this.studentName,
    this.className,
    this.studentPhone,
  });

  factory StudentDebtModel.fromJson(Map<String, dynamic> json) {
    return StudentDebtModel(
      id: json['id'],
      studentId: json['student_id'],
      classId: json['class_id'],
      branchId: json['branch_id'],
      debtAmount: (json['debt_amount'] as num).toDouble(),
      paidAmount: (json['paid_amount'] as num?)?.toDouble() ?? 0,
      remainingAmount: (json['remaining_amount'] as num).toDouble(),
      periodMonth: json['period_month'],
      periodYear: json['period_year'],
      isSettled: json['is_settled'] ?? false,
      settledAt: json['settled_at'] != null
          ? DateTime.parse(json['settled_at'])
          : null,
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      studentName: json['student_name'],
      className: json['class_name'],
      studentPhone: json['student_phone'],
    );
  }

  String get periodText {
    if (periodMonth != null && periodYear != null) {
      final months = [
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
    return 'Aniqlanmagan';
  }

  bool get isOverdue {
    if (dueDate == null || isSettled) return false;
    return DateTime.now().isAfter(dueDate!);
  }

  int get daysOverdue =>
      !isOverdue ? 0 : DateTime.now().difference(dueDate!).inDays;
}

class PaymentHistoryModel {
  final String id;
  final DateTime paymentDate;
  final double amount;
  final String paymentType;
  final String paymentMethod;
  final int? periodMonth;
  final int? periodYear;
  final String receiptNumber;
  final String status;
  final double finalAmount;
  final double discountAmount;
  final double? paidAmount;
  final double? remainingDebt;
  final String? debtReason;
  final String? notes;
  final String? receivedByName;

  PaymentHistoryModel({
    required this.id,
    required this.paymentDate,
    required this.amount,
    required this.paymentType,
    required this.paymentMethod,
    this.periodMonth,
    this.periodYear,
    required this.receiptNumber,
    required this.status,
    required this.finalAmount,
    this.discountAmount = 0,
    this.paidAmount,
    this.remainingDebt,
    this.debtReason,
    this.notes,
    this.receivedByName,
  });

  factory PaymentHistoryModel.fromJson(Map<String, dynamic> json) {
    return PaymentHistoryModel(
      id: json['id'],
      paymentDate: DateTime.parse(json['payment_date']),
      amount: (json['amount'] as num).toDouble(),
      paymentType: json['payment_type'],
      paymentMethod: json['payment_method'],
      periodMonth: json['period_month'],
      periodYear: json['period_year'],
      receiptNumber: json['receipt_number'] ?? '',
      status: json['payment_status'] ?? 'paid',
      finalAmount: (json['final_amount'] as num).toDouble(),
      discountAmount: (json['discount_amount'] as num?)?.toDouble() ?? 0,
      paidAmount: (json['paid_amount'] as num?)?.toDouble(),
      remainingDebt: (json['remaining_debt'] as num?)?.toDouble(),
      debtReason: json['debt_reason'],
      notes: json['notes'],
      receivedByName: json['received_by_name'],
    );
  }

  String get periodText {
    if (periodMonth == null || periodYear == null) return '-';
    final months = [
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
}

// ============================================================================
// PAYMENT SPLIT MODEL
// ============================================================================
class PaymentSplit {
  String method;
  double amount;

  PaymentSplit({required this.method, this.amount = 0});
}

// ============================================================================
// CONTROLLER (MUKAMMAL VERSIYA)
// ============================================================================
class NewPaymentControllerV5 extends GetxController {
  final _supabase = Supabase.instance.client;
  final formKey = GlobalKey<FormState>();

  // Controllers
  final searchController = TextEditingController();
  final amountController = TextEditingController();
  final discountController = TextEditingController();
  final discountReasonController = TextEditingController();
  final paidAmountController = TextEditingController();
  final notesController = TextEditingController();
  final debtReasonController = TextEditingController();

  // Observable state
  var isLoading = false.obs;
  var isSearching = false.obs;
  var searchResults = <StudentModel>[].obs;
  var selectedStudent = Rxn<StudentModel>();
  var selectedStudentId = Rxn<String>();

  // Debts
  var studentDebts = <StudentDebtModel>[].obs;
  var selectedDebts = <String>[].obs;
  var isLoadingDebts = false.obs;
  var totalAllDebts = 0.0.obs; // O'quvchining jami barcha qarzlari

  // Payment history
  var paymentHistory = <PaymentHistoryModel>[].obs;
  var isLoadingHistory = false.obs;

  // Branch
  var userBranchId = Rxn<String>();
  var availableBranches = <Map<String, dynamic>>[].obs;
  var selectedBranchId = Rxn<String>();
  var canChangeBranch = false.obs;
  var showBranchSelector = false.obs;

  // Statistics
  var currentMonthPaymentsCount = 0.obs;
  var currentMonthRevenue = 0.0.obs;
  var currentMonthDebtorsCount = 0.obs;
  var unpaidStudentsCount = 0.obs;

  // Payment data
  var paymentType = 'tuition'.obs;
  var paymentDate = DateTime.now().obs;

  // Month selection
  var selectedMonth = DateTime.now().month.obs;
  var selectedYear = DateTime.now().year.obs;

  // Discount
  var hasDiscount = false.obs;
  var discountType = 'amount'.obs;

  // Debt & Calculation
  var isPartialPayment = false.obs;
  var useMultiPayment = false.obs;
  var paymentSplits = <PaymentSplit>[].obs;

  var finalAmount =
      0.0.obs; // To'lanishi kerak bo'lgan summa (Asosiy - Chegirma)
  var totalPaidAmount = 0.0.obs; // Kassaga kirayotgan real summa
  var debtAmount = 0.0.obs; // Qarz summasi
  var isOverPayment = false.obs; // Oshiqcha to'lov bormi?
  var totalSelectedDebts = 0.0.obs;

  // Staff
  var currentStaffName = ''.obs;
  var currentStaffId = ''.obs;
  var currentStaffRole = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeController();
  }

  // ============================================================================
  // INITIALIZATION
  // ============================================================================
  Future<void> _initializeController() async {
    await Future.delayed(Duration.zero);

    try {
      isLoading.value = true;

      // AuthController dan ma'lumot olish
      if (!Get.isRegistered<AuthController>()) {
        Get.offAllNamed('/login');
        throw Exception('Avtorizatsiya topilmadi');
      }

      final authController = Get.find<AuthController>();

      if (!authController.isAuthenticated || authController.userId == null) {
        Get.offAllNamed('/login');
        throw Exception('Iltimos, tizimga kiring');
      }

      final String userId = authController.userId!;

      // User ma'lumotlarini olish
      final userData = await _supabase
          .from('users')
          .select('id, first_name, last_name, username, role, branch_id')
          .eq('id', userId)
          .single();

      currentStaffId.value = userId;
      currentStaffName.value =
          '${userData['first_name']} ${userData['last_name']}';
      currentStaffRole.value = _getRoleNameInUzbek(userData['role']);

      // Branch tekshirish
      if (userData['branch_id'] != null) {
        selectedBranchId.value = userData['branch_id'];
        userBranchId.value = userData['branch_id'];
        canChangeBranch.value = false;
        showBranchSelector.value = false;

        await loadInitialStudents();
        await loadCurrentMonthStatistics();
      } else {
        // Branch yo'q - tanlash kerak
        showBranchSelector.value = true;
        await loadAvailableBranches();
      }

      print('✅ Controller initialized successfully');
    } catch (e) {
      print('❌ Initialization error: $e');
      Get.snackbar(
        'Xato',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadAvailableBranches() async {
    try {
      final branches = await _supabase
          .from('branches')
          .select('id, name, address')
          .eq('is_active', true)
          .order('name');

      availableBranches.value = List<Map<String, dynamic>>.from(branches);
    } catch (e) {
      print('❌ Load branches error: $e');
    }
  }

  Future<void> selectBranch(String branchId) async {
    selectedBranchId.value = branchId;
    showBranchSelector.value = false;
    await loadInitialStudents();
    await loadCurrentMonthStatistics();
  }

  String _getRoleNameInUzbek(String role) {
    switch (role) {
      case 'owner':
        return 'Direktor';
      case 'manager':
        return 'Menejer';
      case 'teacher':
        return 'Oqituvchi';
      case 'accountant':
        return 'Buxgalter';
      case 'receptionist':
        return 'Qabulxona';
      default:
        return 'Xodim';
    }
  }

  // ============================================================================
  // LOAD STUDENTS & STATUSES
  // ============================================================================
  // Bu funksiya o'quvchilarning shu oy uchun statusini qaytaradi
  Future<Map<String, String>> _getStudentPaymentStatuses() async {
    if (selectedBranchId.value == null) return {};

    final paymentsData = await _supabase
        .from('payments')
        .select('student_id, payment_status')
        .eq('branch_id', selectedBranchId.value!)
        .eq('period_month', selectedMonth.value)
        .eq('period_year', selectedYear.value)
        .neq('payment_status', 'cancelled'); // Faqat aktiv to'lovlar

    Map<String, String> statusMap = {};
    for (var p in paymentsData) {
      // Agar o'quvchi bir necha marta to'lagan bo'lsa (qisman bo'lsa ham), statusni olamiz
      // Lekin 'partial' dan 'paid' ga o'tgan bo'lsa, 'paid' ni saqlab qolish kerak
      String current = statusMap[p['student_id']] ?? '';
      String newStatus = p['payment_status'] ?? 'paid';

      if (current != 'paid') {
        // Agar hali paid bo'lmasa, yangisini olamiz
        statusMap[p['student_id']] = newStatus;
      }
    }
    return statusMap;
  }

  Future<void> loadInitialStudents() async {
    if (selectedBranchId.value == null) return;

    try {
      isSearching.value = true;

      final studentsData = await _supabase
          .from('students')
          .select('''
            *,
            enrollments!inner(
              id, class_id, classes!inner(id, name, class_level_id, main_teacher_id, default_room_id, class_levels(id, name), rooms:rooms!classes_default_room_id_fkey(id, name))
            )
          ''')
          .eq('branch_id', selectedBranchId.value!)
          .eq('status', 'active')
          .order('first_name')
          .limit(500);

      final teacherIds = <String>{};
      for (var json in studentsData) {
        if (json['enrollments'] != null &&
            (json['enrollments'] as List).isNotEmpty) {
          final enrollment = (json['enrollments'] as List).first;
          final classData = enrollment['classes'];
          if (classData != null && classData['main_teacher_id'] != null) {
            teacherIds.add(classData['main_teacher_id']);
          }
        }
      }

      Map<String, Map<String, dynamic>> teachersMap = {};
      if (teacherIds.isNotEmpty) {
        final teachersData = await _supabase
            .from('users')
            .select('id, first_name, last_name')
            .filter('id', 'in', teacherIds.toList());
        for (var teacher in teachersData) {
          teachersMap[teacher['id']] = teacher;
        }
      }

      // To'lov statuslarini olamiz
      final statusMap = await _getStudentPaymentStatuses();

      final students = <StudentModel>[];
      for (var json in studentsData) {
        // Statusni mapdan olamiz, bo'lmasa 'unpaid'
        json['payment_status'] = statusMap[json['id']] ?? 'unpaid';

        _parseStudentData(json, teachersMap, students);
      }

      searchResults.value = students;
    } catch (e) {
      print('❌ Load students error: $e');
      searchResults.clear();
    } finally {
      isSearching.value = false;
    }
  }

  void _parseStudentData(
    Map<String, dynamic> json,
    Map<String, dynamic> teachersMap,
    List<StudentModel> students,
  ) {
    try {
      if (json['enrollments'] != null &&
          (json['enrollments'] as List).isNotEmpty) {
        final enrollment = (json['enrollments'] as List).first;
        final classData = enrollment['classes'];
        if (classData != null) {
          json['class_id'] = classData['id'];
          json['class_name'] = classData['name'];
          json['room_id'] = classData['default_room_id'];
          json['main_teacher_id'] = classData['main_teacher_id'];
          if (classData['class_levels'] != null) {
            json['class_level_id'] = classData['class_levels']['id'];
            json['class_level_name'] = classData['class_levels']['name'];
          }
          if (classData['rooms'] != null) {
            json['room_name'] = classData['rooms']['name'];
          }
          if (classData['main_teacher_id'] != null) {
            final teacher = teachersMap[classData['main_teacher_id']];
            if (teacher != null) {
              json['main_teacher_name'] =
                  '${teacher['first_name']} ${teacher['last_name']}';
            }
          }
        }
      }
      final student = StudentModel.fromJson(json);
      students.add(student);
    } catch (e) {
      print('⚠️ Parse error: $e');
    }
  }

  // ============================================================================
  // SEARCH
  // ============================================================================
  Future<void> searchStudents() async {
    if (selectedBranchId.value == null) {
      Get.snackbar('Xato', 'Filialni tanlang');
      return;
    }

    final searchText = searchController.text.trim().toLowerCase();
    if (searchText.isEmpty) {
      await loadInitialStudents();
      return;
    }

    try {
      isSearching.value = true;
      final allStudents = searchResults.toList();
      final filtered = allStudents.where((s) {
        final name = s.fullName.toLowerCase();
        final phone = (s.phone! + s.parentPhone).replaceAll(RegExp(r'\D'), '');
        final className = (s.className ?? '').toLowerCase();

        return name.contains(searchText) ||
            phone.contains(searchText) ||
            className.contains(searchText);
      }).toList();

      searchResults.value = filtered;

      if (filtered.isEmpty) {
        Get.snackbar(
          'Ma\'lumot',
          'Hech qanday o\'quvchi topilmadi',
          duration: Duration(seconds: 1),
        );
      }
    } catch (e) {
      print('❌ Search error: $e');
    } finally {
      isSearching.value = false;
    }
  }

  void clearSearch() {
    searchController.clear();
    loadInitialStudents();
  }

  // ============================================================================
  // LOAD DEBTS & HISTORY
  // ============================================================================
  Future<void> loadStudentDebts(String studentId) async {
    if (selectedBranchId.value == null) return;

    try {
      isLoadingDebts.value = true;

      // 1. Student ma'lumotlarini olish (enrollment date uchun)
      final studentData = await _supabase
          .from('students')
          .select('enrollment_date, class_id, monthly_fee')
          .eq('id', studentId)
          .maybeSingle();

      if (studentData == null) return;

      final enrollmentDate = studentData['enrollment_date'] != null
          ? DateTime.parse(studentData['enrollment_date'])
          : DateTime.now();

      // 2. Yetishmayotgan oylar uchun qarz yaratish
      if ((studentData['monthly_fee'] as num?) != null &&
          (studentData['monthly_fee'] as num) > 0) {
        await _createMissingDebts(
          studentId,
          enrollmentDate,
          studentData['class_id'],
        );
      }

      // 3. Qarzlarni yuklash
      final debtsData = await _supabase
          .from('student_debts')
          .select('''
            *,
            students(first_name, last_name, parent_phone),
            classes(name)
          ''')
          .eq('student_id', studentId)
          .eq('is_settled', false)
          .gt('remaining_amount', 0)
          .order('period_year', ascending: false)
          .order('period_month', ascending: false);

      final debts = <StudentDebtModel>[];
      double allDebtsSum = 0;

      for (var json in debtsData) {
        final debt = StudentDebtModel.fromJson(json);
        debts.add(debt);
        allDebtsSum += debt.remainingAmount;
      }

      studentDebts.value = debts;
      totalAllDebts.value = allDebtsSum;
    } catch (e) {
      print('❌ Load debts error: $e');
    } finally {
      isLoadingDebts.value = false;
    }
  }

   Future<void> _createMissingDebts(
    String studentId,
    DateTime enrollmentDate,
    String? classId,
  ) async {
    try {
      // 1. O'quvchini olish (limit(1) bilan)
      final studentResponse = await _supabase
          .from('students')
          .select('monthly_fee')
          .eq('id', studentId)
          .limit(1); // Xato bermaydi, ro'yxat qaytaradi

      if (studentResponse.isEmpty) return;

      final student = studentResponse.first;
      final monthlyFee = (student['monthly_fee'] as num?)?.toDouble() ?? 0;
      if (monthlyFee <= 0) return;

      final now = DateTime.now();
      var checkDate = DateTime(enrollmentDate.year, enrollmentDate.month, 1);

      while (checkDate.isBefore(now) ||
          (checkDate.month == now.month && checkDate.year == now.year)) {
        
        // 2. To'lovlarni tekshirish (limit(1) bilan)
        final existingPayments = await _supabase
            .from('payments')
            .select('id')
            .eq('student_id', studentId)
            .eq('period_month', checkDate.month)
            .eq('period_year', checkDate.year)
            .eq('payment_status', 'paid')
            .limit(1); // 2 ta to'lov bo'lsa ham xato bermaydi

        if (existingPayments.isEmpty) {
          // 3. Qarzlarni tekshirish (limit(1) bilan)
          final existingDebts = await _supabase
              .from('student_debts')
              .select('id')
              .eq('student_id', studentId)
              .eq('period_month', checkDate.month)
              .eq('period_year', checkDate.year)
              .limit(1); // Dublikat qarz bo'lsa ham xato bermaydi

          // Agar ro'yxat bo'sh bo'lsa, demak qarz yo'q -> Yaratamiz
          if (existingDebts.isEmpty) {
            final dueDate = DateTime(checkDate.year, checkDate.month, 10);
            await _supabase.from('student_debts').insert({
              'student_id': studentId,
              'class_id': classId,
              'branch_id': selectedBranchId.value,
              'debt_amount': monthlyFee,
              'remaining_amount': monthlyFee,
              'period_month': checkDate.month,
              'period_year': checkDate.year,
              'due_date': dueDate.toIso8601String(),
              'is_settled': false,
            });
          }
        }
        checkDate = DateTime(checkDate.year, checkDate.month + 1, 1);
      }
    } catch (e) {
      print('⚠️ Create missing debts error: $e');
    }
  }
  Future<void> loadPaymentHistory(String studentId) async {
    try {
      isLoadingHistory.value = true;
      final historyData = await _supabase
          .from('payments')
          .select('*, users:received_by(first_name, last_name)')
          .eq('student_id', studentId)
          .order('payment_date', ascending: false)
          .limit(50);

      final history = <PaymentHistoryModel>[];
      for (var json in historyData) {
        if (json['users'] != null) {
          json['received_by_name'] =
              '${json['users']['first_name']} ${json['users']['last_name']}';
        }
        history.add(PaymentHistoryModel.fromJson(json));
      }
      paymentHistory.value = history;
    } catch (e) {
      print('❌ Load history error: $e');
    } finally {
      isLoadingHistory.value = false;
    }
  }

  void showPaymentHistory() {
    if (selectedStudent.value == null) return;
    Get.dialog(
      PaymentHistoryDialog(controller: this),
      barrierDismissible: true,
    );
  }

  // ============================================================================
  // STATISTICS
  // ============================================================================
  Future<void> loadCurrentMonthStatistics() async {
    if (selectedBranchId.value == null) return;
    try {
      final currentMonth = selectedMonth.value;
      final currentYear = selectedYear.value;

      final totalStudentsResponse = await _supabase
          .from('students')
          .select('id')
          .eq('branch_id', selectedBranchId.value!)
          .eq('status', 'active');
      int totalActiveStudents = (totalStudentsResponse as List).length;

      // Bekor qilinmagan to'lovlarni olamiz
      final paidStudentsResponse = await _supabase
          .from('payments')
          .select('student_id, final_amount, paid_amount, payment_status')
          .eq('branch_id', selectedBranchId.value!)
          .eq('period_month', currentMonth)
          .eq('period_year', currentYear)
          .neq('payment_status', 'cancelled');

      final uniquePaidStudentIds = <String>{};
      double totalRevenue = 0;

      for (var payment in paidStudentsResponse) {
        uniquePaidStudentIds.add(payment['student_id'] as String);

        if (payment['payment_status'] == 'partial') {
          totalRevenue += (payment['paid_amount'] as num?)?.toDouble() ?? 0;
        } else {
          totalRevenue += (payment['final_amount'] as num?)?.toDouble() ?? 0;
        }
      }

      currentMonthPaymentsCount.value = uniquePaidStudentIds.length;
      currentMonthRevenue.value = totalRevenue;

      unpaidStudentsCount.value =
          totalActiveStudents - uniquePaidStudentIds.length;
      if (unpaidStudentsCount.value < 0) unpaidStudentsCount.value = 0;

      final debtsResponse = await _supabase
          .from('student_debts')
          .select('student_id')
          .eq('branch_id', selectedBranchId.value!)
          .eq('is_settled', false)
          .gt('remaining_amount', 0);

      final uniqueDebtors = (debtsResponse as List)
          .map((e) => e['student_id'])
          .toSet();
      currentMonthDebtorsCount.value = uniqueDebtors.length;
    } catch (e) {
      print('❌ Statistics error: $e');
    }
  }

  // ============================================================================
  // MULTI-PAYMENT & CALCULATION LOGIC
  // ============================================================================
  void toggleMultiPayment(bool value) {
    useMultiPayment.value = value;
    if (value) {
      // Masalan, hammasini Naqdga yozib qo'yamiz, Click 0 bo'lib turadi
      paymentSplits.value = [
        PaymentSplit(method: 'cash', amount: finalAmount.value), // To'liq summa
        PaymentSplit(method: 'click', amount: 0),
      ];
    } else {
      paymentSplits.clear();
    }
    calculateFinalAmount();
  }

  void addPaymentSplit() {
    paymentSplits.add(PaymentSplit(method: 'cash', amount: 0));
    calculateFinalAmount();
  }

  void removePaymentSplit(int index) {
    if (paymentSplits.length > 1) {
      paymentSplits.removeAt(index);
      calculateFinalAmount();
    }
  }

  // Bu funksiya aynan shunday bo'lishi shart:
  void updateSplitAmount(int index, String val) {
    // Probelni olib tashlab parse qilamiz
    double amount = double.tryParse(val.replaceAll(' ', '')) ?? 0;

    // Splitni yangilaymiz
    paymentSplits[index].amount = amount;

    // UI yangilanishi uchun majburiy signal beramiz
    paymentSplits.refresh();

    // Umumiy summani qayta hisoblaymiz (Juda muhim!)
    calculateFinalAmount();
  }

  // ============================================================================
  // MAIN CALCULATION FUNCTION (MANTIQ MARKAZI)
  // ============================================================================
    void calculateFinalAmount() {
    // 1. Asosiy narxni olish (probellarni tozalab)
    double baseAmount =
        double.tryParse(amountController.text.replaceAll(' ', '')) ?? 0;

    // 2. Chegirmani hisoblash
    double discount = 0;
    if (hasDiscount.value) {
      double val = double.tryParse(discountController.text.replaceAll(' ', '')) ?? 0;
      if (discountType.value == 'percent') {
        discount = baseAmount * (val / 100);
      } else {
        discount = val;
      }
    }
    
    // Chegirma summadan oshib ketmasligi kerak
    if (discount > baseAmount) discount = baseAmount;
    
    // Yakuniy talab qilinadigan summa (Chegirmadan keyingi narx)
    finalAmount.value = baseAmount - discount; 

    // 3. To'lanayotgan summani (Kassaga kirim) hisoblash
    if (useMultiPayment.value) {
      // Multi to'lov
      double splitsTotal = paymentSplits.fold(
        0.0,
        (sum, split) => sum + split.amount,
      );
      totalPaidAmount.value = splitsTotal;
      isPartialPayment.value = splitsTotal < finalAmount.value;
    } else {
      // Oddiy to'lov
      if (isPartialPayment.value) {
        // Agar qisman to'lov yoqilgan bo'lsa, inputdan olamiz
        double inputPaid = double.tryParse(paidAmountController.text.replaceAll(' ', '')) ?? 0;
        
        // Agar kiritilgan summa Yakuniy summadan ko'p bo'lsa, uni tenglashtiramiz (Xatolik oldini olish uchun)
        if (inputPaid > finalAmount.value) {
             // Bu yerda qiymatni o'zgartirmaymiz, faqat hisob-kitob uchun
             // UI da validator xato ko'rsatadi
        }
        totalPaidAmount.value = inputPaid;
      } else {
        // To'liq to'lov
        totalPaidAmount.value = finalAmount.value;
      }
    }

    // 4. Qarz va Oshiqcha to'lovni hisoblash
    if (totalPaidAmount.value > finalAmount.value) {
      isOverPayment.value = true;
      debtAmount.value = 0; // Qarz manfiy bo'lmasligi kerak
    } else {
      isOverPayment.value = false;
      debtAmount.value = finalAmount.value - totalPaidAmount.value;
      
      // Kichik tiyin farqlarini yo'qotish uchun
      if (debtAmount.value < 0) debtAmount.value = 0;
    }
  }

  // ============================================================================
  // SELECTION
  // ============================================================================
  void toggleDebtSelection(String debtId) {
    if (selectedDebts.contains(debtId)) {
      selectedDebts.remove(debtId);
    } else {
      selectedDebts.add(debtId);
    }
    calculateTotalSelectedDebts();
  }

  void calculateTotalSelectedDebts() {
    double total = 0;
    for (var debtId in selectedDebts) {
      final debt = studentDebts.firstWhere((d) => d.id == debtId);
      total += debt.remainingAmount;
    }
    totalSelectedDebts.value = total;

    if (selectedDebts.isNotEmpty) {
      amountController.text = total.toStringAsFixed(0);
      useMultiPayment.value = false; // Qarz tanlanganda multi o'chiriladi
      paymentSplits.clear();
    }
    calculateFinalAmount();
  }

  void selectStudent(StudentModel student) {
    selectedStudent.value = student;
    selectedStudentId.value = student.id;
    loadStudentDebts(student.id);
    loadPaymentHistory(student.id);

    _resetForm(keepStudent: true);
    amountController.text = student.monthlyFee.toStringAsFixed(0);

    if (student.discountAmount > 0) {
      hasDiscount.value = true;
      if (student.discountPercent > 0) {
        discountType.value = 'percent';
        discountController.text = student.discountPercent.toStringAsFixed(0);
      } else {
        discountType.value = 'amount';
        discountController.text = student.discountAmount.toStringAsFixed(0);
      }
      if (student.discountReason?.isNotEmpty ?? false) {
        discountReasonController.text = student.discountReason!;
      }
    }
    calculateFinalAmount();
  }

  void clearSelection() {
    selectedStudent.value = null;
    selectedStudentId.value = null;
    studentDebts.clear();
    paymentHistory.clear();
    _resetForm();
  }

  void _resetForm({bool keepStudent = false}) {
    amountController.clear();
    discountController.clear();
    discountReasonController.clear();
    paidAmountController.clear();
    notesController.clear();
    debtReasonController.clear();
    if (!keepStudent) selectedDebts.clear();

    hasDiscount.value = false;
    discountType.value = 'amount';
    isPartialPayment.value = false;
    useMultiPayment.value = false;
    paymentSplits.clear();

    finalAmount.value = 0;
    debtAmount.value = 0;
    totalPaidAmount.value = 0;
    isOverPayment.value = false;
    paymentDate.value = DateTime.now();
  }

  // ============================================================================
  // CONFIRMATION & SAVING
  // ============================================================================

  // Kassa borligini tekshirish va yo'q bo'lsa ochish (MUHIM!)
    Future<void> _ensureCashRegisterExists(String method) async {
    try {
      final existing = await _supabase
          .from('cash_register')
          .select('id')
          .eq('branch_id', selectedBranchId.value!)
          .eq('payment_method', method)
          .limit(1); // Dublikat kassa bo'lsa ham birinchisini oladi

      if (existing.isEmpty) {
        // Agar umuman yo'q bo'lsa, yaratadi
        try {
          await _supabase.from('cash_register').insert({
            'branch_id': selectedBranchId.value,
            'payment_method': method,
            'current_balance': 0,
          });
        } catch (e) {
          // Agar biz tekshirib yaratgunimizcha kassa paydo bo'lib qolsa,
          // insert xato beradi, lekin buni yutib yuboramiz (ignore).
        }
      }
    } catch (e) {
      print('Kassa tekshirishda xato: $e');
    }
  }
    Future<void> confirmPayment() async {
    if (!formKey.currentState!.validate()) return;
    if (selectedStudent.value == null) return;

    if (isOverPayment.value) {
      Get.snackbar('Xatolik', 'To\'lov summasi oshib ketdi!',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    if (totalPaidAmount.value <= 0) {
      Get.snackbar('Diqqat', 'To\'lov summasi 0 bo\'lishi mumkin emas',
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    // Qayta to'lov tekshiruvi
    if (selectedDebts.isEmpty) {
      // TUZATILDI: maybeSingle() o'rniga limit(1) ishlatamiz
      final existsList = await _supabase
          .from('payments')
          .select('id')
          .eq('student_id', selectedStudentId.value!)
          .eq('period_month', selectedMonth.value)
          .eq('period_year', selectedYear.value)
          .eq('payment_status', 'paid')
          .limit(1); // <--- XATONI OLDINI OLADI

      if (existsList.isNotEmpty) {
        Get.defaultDialog(
          title: 'Diqqat!',
          middleText:
              'Bu oy uchun allaqachon to\'liq to\'lov qilingan. Baribir davom etasizmi?',
          textConfirm: 'Ha',
          textCancel: 'Yo\'q',
          confirmTextColor: Colors.white,
          onConfirm: () {
            Get.back();
            _showConfirmationDialog();
          },
        );
        return;
      }
    }

    _showConfirmationDialog();
  }

  void _showConfirmationDialog() {
    Get.defaultDialog(
      title: 'To\'lovni Tasdiqlash',
      content: Column(
        children: [
          Text(
            'Kassaga kirim: ${formatCurrency(totalPaidAmount.value)} so\'m',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.green[800],
            ),
          ),
          SizedBox(height: 10),
          if (debtAmount.value > 0)
            Container(
              padding: EdgeInsets.all(8),
              color: Colors.red[50],
              child: Text(
                'Qarzga qoladi: ${formatCurrency(debtAmount.value)} so\'m',
                style: TextStyle(color: Colors.red),
              ),
            ),
          SizedBox(height: 10),
          _buildConfirmRow('O\'quvchi:', selectedStudent.value!.fullName),
          _buildConfirmRow(
            'Sana:',
            DateFormat('dd.MM.yyyy').format(paymentDate.value),
          ),

          if (selectedDebts.isNotEmpty)
            _buildConfirmRow('Qarzlar:', '${selectedDebts.length} ta oy uchun'),

          if (useMultiPayment.value) ...[
            SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "To'lov turlari:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            ...paymentSplits.map(
              (split) => Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text(
                  '• ${_getMethodName(split.method)}: ${formatCurrency(split.amount)} so\'m',
                ),
              ),
            ),
          ],
        ],
      ),
      textConfirm: 'TASDIQLASH',
      textCancel: 'Bekor qilish',
      confirmTextColor: Colors.white,
      buttonColor: Colors.green,
      onConfirm: () {
        Get.back();
        savePayment();
      },
    );
  }

  Widget _buildConfirmRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Flexible(
            child: Text(
              value,
              style: TextStyle(fontWeight: FontWeight.w600),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  String _getMethodName(String method) {
    switch (method) {
      case 'cash':
        return 'Naqd';
      case 'click':
        return 'Click';
      case 'terminal':
        return 'Terminal';
      case 'owner_fund':
        return 'Ega kassasi';
      default:
        return method;
    }
  }

  Future<void> savePayment() async {
    try {
      isLoading.value = true;

      if (selectedDebts.isNotEmpty) {
        await _processMultipleDebtsPayment();
      } else {
        await _processSinglePayment();
      }

      await loadCurrentMonthStatistics();
      if (selectedStudentId.value != null) {
        await loadStudentDebts(selectedStudentId.value!);
        await loadPaymentHistory(selectedStudentId.value!);
        // O'quvchilar ro'yxatini yangilash (rangi o'zgarishi uchun)
        await loadInitialStudents();
      }

      clearSelection();
      Get.snackbar(
        'Muvaffaqiyatli',
        'To\'lov qabul qilindi',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Payment error: $e');
      Get.snackbar(
        'Xato',
        'To\'lovda xatolik: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _processMultipleDebtsPayment() async {
    double remainingPayment = totalPaidAmount.value;
    final paymentIds = <String>[];

    for (var debtId in selectedDebts) {
      if (remainingPayment <= 0) break;

      final debt = studentDebts.firstWhere((d) => d.id == debtId);
      final amountToPay = remainingPayment >= debt.remainingAmount
          ? debt.remainingAmount
          : remainingPayment;

      final newPaidAmount = debt.paidAmount + amountToPay;
      final newRemainingAmount = debt.debtAmount - newPaidAmount;
      final isFullyPaid = newRemainingAmount <= 0;

      await _supabase
          .from('student_debts')
          .update({
            'paid_amount': newPaidAmount,
            'remaining_amount': isFullyPaid ? 0 : newRemainingAmount,
            'is_settled': isFullyPaid,
            'settled_at': isFullyPaid ? DateTime.now().toIso8601String() : null,
          })
          .eq('id', debtId);

      String id = await _insertPaymentRecord(
        amount: amountToPay,
        discount: 0,
        finalAmt: amountToPay,
        debtId: debtId,
        month: debt.periodMonth,
        year: debt.periodYear,
        notes: 'Qarz to\'lovi: ${debt.periodText}',
        status:
            'paid', paidAmount: amountToPay, // Qarz to'layotganda har doim 'paid' deb ketsin, chunki qarzni qisman to'lasa ham baribir to'lov bo'ladi
      );
      paymentIds.add(id);

   
      remainingPayment -= amountToPay;
    }

    if (paymentIds.isNotEmpty) {
      _showPaymentReceipt(paymentIds.last);
    }
  }

   Future<void> _processSinglePayment() async {
    // Status aniqlash (Agar qarz 0 dan katta bo'lsa 'partial', bo'lmasa 'paid')
    String status = debtAmount.value > 0 ? 'partial' : 'paid';

    // Asosiy summa
    double baseAmount = double.tryParse(amountController.text.replaceAll(' ', '')) ?? 0;
    
    // Aniq chegirma summasi
    double discountVal = baseAmount - finalAmount.value;
    if (discountVal < 0) discountVal = 0;

    // MUHIM: Bu yerda Ma'lumotlar bazasiga to'g'ri ajratib yuborish kerak
    String id = await _insertPaymentRecord(
      amount: baseAmount,           // Asl narx (masalan 1 mln)
      discount: discountVal,        // Chegirma (masalan 100 ming)
      finalAmt: finalAmount.value,  // Kelishilgan narx (900 ming) - BU YER XATO EDI
      paidAmount: totalPaidAmount.value, // Kassaga kirgan pul (500 ming) - YANGI PARAMETR
      debtId: null,
      month: selectedMonth.value,
      year: selectedYear.value,
      notes: notesController.text,
      status: status,
    );

    // Qarz yozish (Faqat qarz mavjud bo'lsa)
    if (debtAmount.value > 0) {
      await _supabase.from('student_debts').insert({
        'student_id': selectedStudentId.value,
        'branch_id': selectedBranchId.value,
        'class_id': selectedStudent.value!.classId,
        'debt_amount': debtAmount.value,
        'remaining_amount': debtAmount.value,
        'paid_amount': 0,
        'period_month': selectedMonth.value,
        'period_year': selectedYear.value,
        'is_settled': false,
        'due_date': DateTime.now().add(Duration(days: 10)).toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
      });
    }

    _showPaymentReceipt(id);
  }

   Future<String> _insertPaymentRecord({
    required double amount,
    required double discount,
    required double finalAmt,     // Kelishilgan summa (Discount chiqarilgan)
    required double paidAmount,   // Real to'langan summa
    required String? debtId,
    required int? month,
    required int? year,
    required String? notes,
    String status = 'paid',
  }) async {
    final receipt = 'P-${DateTime.now().millisecondsSinceEpoch}';

    String method = 'cash';
    if (useMultiPayment.value) {
      method = 'multi';
    } else if (paymentSplits.isNotEmpty) {
      method = paymentSplits.first.method;
    }

    await _ensureCashRegisterExists(method);
    if (useMultiPayment.value) {
      for (var split in paymentSplits) {
        if (split.amount > 0) await _ensureCashRegisterExists(split.method);
      }
    }

    final res = await _supabase
        .from('payments')
        .insert({
          'branch_id': selectedBranchId.value,
          'student_id': selectedStudentId.value,
          'class_id': selectedStudent.value?.classId,
          'amount': amount,
          'discount_amount': discount,
          'final_amount': finalAmt,   // Kelishilgan narx
          'paid_amount': paidAmount,  // Kassaga kirgan pul
          'payment_method': method,
          'payment_type': paymentType.value,
          'payment_status': status,
          'period_month': month,
          'period_year': year,
          'receipt_number': receipt,
          'received_by': currentStaffId.value,
          'notes': notes,
          'debt_id': debtId,
          'payment_date': paymentDate.value.toIso8601String(),
        })
        .select('id')
        .single();

    if (useMultiPayment.value) {
      final validSplits = paymentSplits
          .where((split) => split.amount > 0)
          .toList();
      for (var split in validSplits) {
        await _supabase.from('payment_splits').insert({
          'payment_id': res['id'],
          'method': split.method,
          'amount': split.amount,
        });
        // Kassa balansini shu yerda yangilash tavsiya etiladi
        await _updateCashRegister(split.amount, split.method);
      }
    } else {
        // Oddiy to'lov bo'lsa kassa yangilash
        await _updateCashRegister(paidAmount, method);
    }
    
    return res['id'];
  }
    Future<void> _updateCashRegister(double amount, String method) async {
    if (amount == 0) return;
    try {
      // TUZATILDI: limit(1) ishlatamiz
      final rows = await _supabase
          .from('cash_register')
          .select('id, current_balance')
          .eq('branch_id', selectedBranchId.value!)
          .eq('payment_method', method)
          .limit(1); // <--- XATONI OLDINI OLADI

      if (rows.isNotEmpty) {
        final row = rows.first;
        final current = (row['current_balance'] as num).toDouble();
        
        await _supabase
            .from('cash_register')
            .update({'current_balance': current + amount})
            .eq('id', row['id']);
      }
    } catch (e) {
      print('Kassa yangilashda xato: $e');
    }
  }
  Future<void> _updateMultipleRegisters(double totalAmount) async {
    for (var split in paymentSplits) {
      await _updateCashRegister(split.amount, split.method);
    }
  }

  Future<void> _showPaymentReceipt(String paymentId) async {
    final payment = await _supabase
        .from('payments')
        .select('*, users:received_by(first_name, last_name)')
        .eq('id', paymentId)
        .single();

    final branch = await _supabase
        .from('branches')
        .select('*')
        .eq('id', selectedBranchId.value!)
        .single();

    if (payment['users'] != null) {
      payment['received_by_name'] =
          '${payment['users']['first_name']} ${payment['users']['last_name']}';
    }
    payment['branch_name'] = branch['name'];
    payment['branch_address'] = branch['address'];
    payment['branch_phone'] = branch['phone'];

    if (payment['payment_method'] == 'multi') {
      final splits = await _supabase
          .from('payment_splits')
          .select()
          .eq('payment_id', paymentId);
      payment['payment_splits'] = splits;
    }

    final studentData = {
      'full_name': selectedStudent.value!.fullName,
      'class_name': selectedStudent.value!.className,
      'student_phone': selectedStudent.value!.phone,
    };

    Get.dialog(
      PaymentReceiptDialog(paymentData: payment, studentData: studentData),
      barrierDismissible: false,
    );
  }

  Future<void> voidPayment(String paymentId) async {
    try {
      isLoading.value = true;

      final payment = await _supabase
          .from('payments')
          .select('*, payment_splits(*)')
          .eq('id', paymentId)
          .single();

      await _supabase
          .from('payments')
          .update({
            'payment_status': 'cancelled',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', paymentId);

      if (payment['payment_method'] == 'multi' &&
          payment['payment_splits'] != null) {
        for (var split in payment['payment_splits']) {
          await _updateCashRegister(-split['amount'], split['method']);
        }
      } else {
        await _updateCashRegister(
          -(payment['paid_amount'] as num).toDouble(),
          payment['payment_method'],
        );
      }

      await loadPaymentHistory(selectedStudentId.value!);
      await loadCurrentMonthStatistics();
      await loadInitialStudents(); // Ro'yxatni yangilash

      Get.back();
      Get.snackbar(
        'Muvaffaqiyatli',
        'To\'lov bekor qilindi',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Void payment error: $e');
      Get.snackbar(
        'Xato',
        'Bekor qilishda xatolik',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshData() async {
    await loadInitialStudents();
    await loadCurrentMonthStatistics();
    if (selectedStudentId.value != null) {
      await loadStudentDebts(selectedStudentId.value!);
      await loadPaymentHistory(selectedStudentId.value!);
    }
    Get.snackbar(
      'Yangilandi',
      'Ma\'lumotlar yangilandi',
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: Duration(seconds: 2),
    );
  }

  Future<void> selectMonth(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(selectedYear.value, selectedMonth.value),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      selectedMonth.value = picked.month;
      selectedYear.value = picked.year;
      loadInitialStudents();
      loadCurrentMonthStatistics();
    }
  }

  Future<void> selectPaymentDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: paymentDate.value,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      final now = DateTime.now();
      paymentDate.value = DateTime(
        picked.year,
        picked.month,
        picked.day,
        now.hour,
        now.minute,
      );
    }
  }

  String get currentMonthYear => '${selectedMonth.value}-${selectedYear.value}';
  String formatCurrency(double amount) =>
      NumberFormat('#,###', 'uz_UZ').format(amount);
}
