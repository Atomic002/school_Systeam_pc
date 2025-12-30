import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/models/student_model.dart';
import 'package:flutter_application_1/data/repositories/payment_repositry.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../controllers/auth_controller.dart';
import '../widgets/payment_history_dialog.dart';
import '../widgets/payment_receipt_dialog.dart';

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
// CONTROLLER
// ============================================================================
class NewPaymentControllerV4admin extends GetxController {
  final PaymentRepository _paymentRepo = PaymentRepository();
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

  // Payment history
  var paymentHistory = <PaymentHistoryModel>[].obs;
  var isLoadingHistory = false.obs;

  // Branch
  var userBranchId = Rxn<String>();
  var availableBranches = <Map<String, dynamic>>[].obs;
  var selectedBranchId = Rxn<String>();
  var canChangeBranch = false.obs;

  // Statistics
  var currentMonthPaymentsCount = 0.obs;
  var currentMonthRevenue = 0.0.obs;
  var currentMonthDebtorsCount = 0.obs;
  var unpaidStudentsCount = 0.obs;

  // Payment data
  var paymentType = 'tuition'.obs;
  var paymentMethod = 'cash'.obs;
  var paymentDate = DateTime.now().obs; // --- O'ZGARTIRILDI: To'lov sanasi

  // Month selection
  var selectedMonth = DateTime.now().month.obs;
  var selectedYear = DateTime.now().year.obs;

  // Discount
  var hasDiscount = false.obs;
  var discountType = 'amount'.obs;

  // Debt
  var isPartialPayment = false.obs;

  // Calculated values
  var finalAmount = 0.0.obs;
  var debtAmount = 0.0.obs;
  var totalSelectedDebts = 0.0.obs;

  // Staff
  var currentStaffName = ''.obs;
  var currentStaffId = ''.obs;
  var currentStaffRole = ''.obs;

  late AuthController _authController;

  @override
  void onInit() {
    super.onInit();
    _initializeController();
  }

  // ============================================================================
  // INITIALIZATION (O'ZGARTIRILDI: User va Branch tekshiruvi)
  // ============================================================================
   // ============================================================================
  // INITIALIZATION (TUZATILGAN: AuthController orqali tekshirish)
  // ============================================================================
  Future<void> _initializeController() async {
    // 1. UI chizilishini kutish (setState xatosini oldini olish uchun)
    await Future.delayed(Duration.zero);

    try {
      isLoading.value = true;

      // --- O'ZGARTIRILDI: Supabase o'rniga AuthController dan so'raymiz ---
      
      // AuthController ni topamiz (bu vaqtda u xotirada bo'lishi aniq)
      if (!Get.isRegistered<AuthController>()) {
         // Agar tasodifan yo'q bo'lsa, xato bermaslik uchun Login ga otamiz
         Get.offAllNamed('/login'); 
         throw Exception('Avtorizatsiya topilmadi');
      }

      final authController = Get.find<AuthController>();

      // Agar user tizimdan chiqqan bo'lsa
      if (!authController.isAuthenticated || authController.userId == null) {
        Get.offAllNamed('/login'); // Login sahifasiga yo'naltirish
        throw Exception('Iltimos, tizimga kiring');
      }

      final String userId = authController.userId!;
      // -------------------------------------------------------------------

      // 2. User ma'lumotlarini olish (Supabase dan yangilash)
      final userData = await _supabase
          .from('users')
          .select('id, first_name, last_name, username, role, branch_id')
          .eq('id', userId) // <-- Endi ID AuthController dan olinadi
          .single();

      // 3. Controllerga saqlash
      currentStaffId.value = userId;
      currentStaffName.value =
          '${userData['first_name']} ${userData['last_name']}';
      currentStaffRole.value = _getRoleNameInUzbek(userData['role']);

      // 4. Filialni biriktirish
      if (userData['branch_id'] != null) {
        selectedBranchId.value = userData['branch_id'];
        userBranchId.value = userData['branch_id'];
        // Faqat owner o'zgartira oladi
        canChangeBranch.value = (userData['role'] == 'owner');
      } else {
        throw Exception('Sizga filial biriktirilmagan');
      }

      await loadInitialStudents();
      await loadCurrentMonthStatistics();

      print('✅ Controller initialized successfully via AuthController');
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
  String _getRoleNameInUzbek(String role) {
    switch (role) {
      case 'owner':
        return 'Direktor';
      case 'manager':
        return 'Menejer';
      case 'teacher':
        return 'O\'qituvchi';
      case 'accountant':
        return 'Buxgalter';
      case 'receptionist':
        return 'Qabulxona';
      default:
        return 'Xodim';
    }
  }

  // ============================================================================
  // LOAD STUDENTS (O'ZGARTIRILDI: Sinf bo'yicha filter)
  // ============================================================================
  Future<void> loadInitialStudents() async {
    if (selectedBranchId.value == null) return;

    try {
      isSearching.value = true;

      final studentsData = await _supabase
          .from('students')
          .select('''
            *,
            enrollments!inner(
              id,
              class_id,
              classes!inner(
                id,
                name,
                class_level_id,
                main_teacher_id,
                default_room_id,
                class_levels(id, name),
                rooms:rooms!classes_default_room_id_fkey(id, name)
              )
            )
          ''')
          .eq('branch_id', selectedBranchId.value!)
          .eq('status', 'active')
          .order('first_name')
          .limit(500);

      // Teacherlarni yuklash
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

      // To'langanlikni tekshirish
      final paidStudentIds = await _getPaidStudentIds();

      final students = <StudentModel>[];
      for (var json in studentsData) {
        _parseStudentData(json, teachersMap, paidStudentIds, students);
      }

      searchResults.value = students;
    } catch (e) {
      print('❌ Load students error: $e');
      searchResults.clear();
    } finally {
      isSearching.value = false;
    }
  }

  Future<Set<String>> _getPaidStudentIds() async {
    final paymentsData = await _supabase
        .from('payments')
        .select('student_id')
        .eq('branch_id', selectedBranchId.value!)
        .eq('period_month', selectedMonth.value)
        .eq('period_year', selectedYear.value)
        .eq('payment_status', 'paid');

    return (paymentsData as List).map((p) => p['student_id'] as String).toSet();
  }

  void _parseStudentData(
    Map<String, dynamic> json,
    Map<String, dynamic> teachersMap,
    Set<String> paidIds,
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
      json['has_paid_current_month'] = paidIds.contains(student.id);
      students.add(student);
    } catch (e) {
      print('⚠️ Parse error: $e');
    }
  }

  // ============================================================================
  // SEARCH STUDENTS (O'ZGARTIRILDI: Sinf nomi bilan)
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
      // Lokal filter qilish (Supabase or check qiyin)
      final allStudents = searchResults.toList();
      final filtered = allStudents.where((s) {
        final name = s.fullName.toLowerCase();
        final phone = (s.phone! + s.parentPhone).replaceAll(RegExp(r'\D'), '');
        final className = (s.className ?? '').toLowerCase();

        return name.contains(searchText) ||
            phone.contains(searchText) ||
            className.contains(searchText);
      }).toList();

      // Agar localda kam bo'lsa, bazadan ham qidirish mumkin (lekin hozircha local yetadi)
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
  // LOAD DEBTS (O'ZGARTIRILDI: 0 so'mlik qarz yozilmaydi)
  // ============================================================================
  Future<void> loadStudentDebts(String studentId) async {
    if (selectedBranchId.value == null) return;

    try {
      isLoadingDebts.value = true;

      final studentData = await _supabase
          .from('students')
          .select('enrollment_date, class_id')
          .eq('id', studentId)
          .single();

      final enrollmentDate = studentData['enrollment_date'] != null
          ? DateTime.parse(studentData['enrollment_date'])
          : DateTime.now();

      // Qarz generatsiyasi
      await _createMissingDebts(
        studentId,
        enrollmentDate,
        studentData['class_id'],
      );

      final debtsData = await _supabase
          .from('student_debts')
          .select('''
            *,
            students(first_name, last_name, parent_phone),
            classes(name)
          ''')
          .eq('student_id', studentId)
          .eq('is_settled', false)
          .gt('remaining_amount', 0) // <--- MUHIM: 0 lik qarzlar ko'rsatilmaydi
          .order('period_year', ascending: false)
          .order('period_month', ascending: false);

      final debts = <StudentDebtModel>[];
      for (var json in debtsData) {
        debts.add(StudentDebtModel.fromJson(json));
      }

      studentDebts.value = debts;
    } catch (e) {
      print('❌ Load debts error: $e');
    } finally {
      isLoadingDebts.value = false;
    }
  }

  // O'ZGARTIRILDI: Agar monthly_fee <= 0 bo'lsa, qarz yozmaydi
  Future<void> _createMissingDebts(
    String studentId,
    DateTime enrollmentDate,
    String? classId,
  ) async {
    try {
      final student = await _supabase
          .from('students')
          .select('monthly_fee')
          .eq('id', studentId)
          .single();

      final monthlyFee = (student['monthly_fee'] as num?)?.toDouble() ?? 0;

      // MUHIM: 0 BO'LSA QAYTADI
      if (monthlyFee <= 0) return;

      final now = DateTime.now();
      var checkDate = DateTime(enrollmentDate.year, enrollmentDate.month, 1);

      while (checkDate.isBefore(now) ||
          (checkDate.month == now.month && checkDate.year == now.year)) {
        // To'lov bormi?
        final existingPayment = await _supabase
            .from('payments')
            .select('id')
            .eq('student_id', studentId)
            .eq('period_month', checkDate.month)
            .eq('period_year', checkDate.year)
            .eq('payment_status', 'paid') // Faqat to'liq to'langanlar
            .maybeSingle();

        if (existingPayment == null) {
          // Qarz bormi?
          final existingDebt = await _supabase
              .from('student_debts')
              .select('id')
              .eq('student_id', studentId)
              .eq('period_month', checkDate.month)
              .eq('period_year', checkDate.year)
              .maybeSingle();

          if (existingDebt == null) {
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

  Future<void> loadCurrentMonthStatistics() async {
    if (selectedBranchId.value == null) return;
    try {
      final currentMonth = selectedMonth.value;
      final currentYear = selectedYear.value;

      final paymentsResponse = await _supabase
          .from('payments')
          .select('id, final_amount, paid_amount, payment_status')
          .eq('branch_id', selectedBranchId.value!)
          .eq('period_month', currentMonth)
          .eq('period_year', currentYear);

      currentMonthPaymentsCount.value = (paymentsResponse as List).length;

      double totalRevenue = 0;
      for (var payment in paymentsResponse) {
        if (payment['payment_status'] == 'paid') {
          totalRevenue += (payment['final_amount'] as num).toDouble();
        } else if (payment['payment_status'] == 'partial') {
          totalRevenue += (payment['paid_amount'] as num?)?.toDouble() ?? 0;
        }
      }
      currentMonthRevenue.value = totalRevenue;

      final debtsResponse = await _supabase
          .from('student_debts')
          .select('id')
          .eq('branch_id', selectedBranchId.value!)
          .eq('is_settled', false)
          .eq('period_month', currentMonth)
          .eq('period_year', currentYear);

      currentMonthDebtorsCount.value = (debtsResponse as List).length;

      final totalStudents = await _supabase
          .from('students')
          .select('id')
          .eq('branch_id', selectedBranchId.value!)
          .eq('status', 'active');

      unpaidStudentsCount.value =
          (totalStudents as List).length - currentMonthPaymentsCount.value;
    } catch (e) {
      print('❌ Statistics error: $e');
    }
  }

  // ============================================================================
  // SELECTION & CALCULATION
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
    amountController.text = total.toStringAsFixed(0);
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
    if (!keepStudent) {
      selectedDebts.clear();
      
    }
    hasDiscount.value = false;
    discountType.value = 'amount';
    isPartialPayment.value = false;
    finalAmount.value = 0;
    debtAmount.value = 0;
    paymentDate.value = DateTime.now();
  }

  void calculateFinalAmount() {
    double amount =
        double.tryParse(amountController.text.replaceAll(' ', '')) ?? 0;
    double discount = 0;

    if (hasDiscount.value) {
      double val = double.tryParse(discountController.text) ?? 0;
      if (discountType.value == 'percent') {
        discount = amount * (val / 100);
      } else {
        discount = val;
      }
    }
    if (discount > amount) discount = amount;
    finalAmount.value = amount - discount;

    if (isPartialPayment.value) {
      double paid =
          double.tryParse(paidAmountController.text.replaceAll(' ', '')) ?? 0;
      debtAmount.value = (finalAmount.value - paid).clamp(0, double.infinity);
    }
  }

  // ============================================================================
  // CONFIRMATION & SAVING (YANGI)
  // ============================================================================
  Future<void> confirmPayment() async {
    if (!formKey.currentState!.validate()) return;
    if (selectedStudent.value == null) {
      Get.snackbar('Xato', 'O\'quvchi tanlanmagan');
      return;
    }

    // 1. Qayta to'lov tekshiruvi (Agar oddiy to'lov bo'lsa)
    if (selectedDebts.isEmpty) {
      final exists = await _supabase
          .from('payments')
          .select('id')
          .eq('student_id', selectedStudentId.value!)
          .eq('period_month', selectedMonth.value)
          .eq('period_year', selectedYear.value)
          .eq('payment_status', 'paid')
          .maybeSingle();

      if (exists != null) {
        Get.defaultDialog(
          title: 'Diqqat!',
          middleText:
              'Bu oy (${selectedMonth.value}-${selectedYear.value}) uchun allaqachon to\'lov qilingan. Baribir davom etasizmi?',
          textConfirm: 'Ha',
          textCancel: 'Yo\'q',
          confirmTextColor: Colors.white,
          onConfirm: () {
            Get.back(); // Dialog yopish
            _showConfirmationDialog(); // Tasdiqlash
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
            'Summa: ${formatCurrency(finalAmount.value)} so\'m',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          SizedBox(height: 10),
          Text('O\'quvchi: ${selectedStudent.value!.fullName}'),
          Text('Sana: ${DateFormat('dd.MM.yyyy').format(paymentDate.value)}'),
          Text('Qabul qiluvchi: ${currentStaffName.value}'),
          if (selectedDebts.isNotEmpty)
            Text(
              'Tanlangan qarzlar: ${selectedDebts.length} ta',
              style: TextStyle(color: Colors.orange),
            ),
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

  Future<void> savePayment() async {
    try {
      isLoading.value = true;

      // 1. Qarz to'lovi (Multi)
      if (selectedDebts.isNotEmpty) {
        await _processMultipleDebtsPayment();
      }
      // 2. Oddiy to'lov
      else {
        await _processSinglePayment();
      }

      await loadCurrentMonthStatistics();
      if (selectedStudentId.value != null) {
        await loadStudentDebts(selectedStudentId.value!);
        await loadPaymentHistory(selectedStudentId.value!);
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
  Future<void> _processMultipleDebtsPayment() async {
    double inputAmount =
        double.tryParse(amountController.text.replaceAll(' ', '')) ?? 0;
    double discount = 0;
    if (hasDiscount.value) {
      // Chegirma hisoblash
      // ... (agar butun summaga chegirma bo'lsa)
    }
    // Oddiylik uchun har bir qarz to'liq yopiladi deb faraz qilamiz yoki proporsional
    // Bu yerda sizning oldingi logikangizni ishlataman:

    double remainingPayment = inputAmount;
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

      // Debt update
      await _supabase
          .from('student_debts')
          .update({
            'paid_amount': newPaidAmount,
            'remaining_amount': isFullyPaid ? 0 : newRemainingAmount,
            'is_settled': isFullyPaid,
            'settled_at': isFullyPaid ? DateTime.now().toIso8601String() : null,
          })
          .eq('id', debtId);

      // Payment insert
      String id = await _insertPaymentRecord(
        amount: amountToPay,
        discount: 0, // Hozircha qarz to'lovida chegirma yo'q deb turamiz
        finalAmt: amountToPay,
        debtId: debtId,
        month: debt.periodMonth,
        year: debt.periodYear,
        notes: 'Qarz to\'lovi: ${debt.periodText}',
      );
      paymentIds.add(id);

      await _updateCashRegister(amountToPay);
      remainingPayment -= amountToPay;
    }

    if (paymentIds.isNotEmpty) {
      _showPaymentReceipt(paymentIds.last);
    }
  }

  Future<void> _processSinglePayment() async {
    double amount =
        double.tryParse(amountController.text.replaceAll(' ', '')) ?? 0;
    double discount = 0;
    // Chegirma hisoblash
    if (hasDiscount.value) {
      double val = double.tryParse(discountController.text) ?? 0;
      if (discountType.value == 'percent')
        discount = amount * (val / 100);
      else
        discount = val;
    }
    double finalAmt = amount - discount;
    double paidAmt = finalAmt;

    if (isPartialPayment.value) {
      paidAmt =
          double.tryParse(paidAmountController.text.replaceAll(' ', '')) ?? 0;
    }

    String id = await _insertPaymentRecord(
      amount: amount,
      discount: discount,
      finalAmt: paidAmt, // Kassaga kirgan
      debtId: null,
      month: selectedMonth.value,
      year: selectedYear.value,
      notes: notesController.text,
    );

    // Agar qisman bo'lsa, qarz yaratish
    double debt = finalAmt - paidAmt;
    if (debt > 0) {
      await _supabase.from('student_debts').insert({
        'student_id': selectedStudentId.value,
        'branch_id': selectedBranchId.value,
        'class_id': selectedStudent.value!.classId,
        'debt_amount': debt,
        'remaining_amount': debt,
        'period_month': selectedMonth.value,
        'period_year': selectedYear.value,
        'is_settled': false,
        'due_date': DateTime.now().add(Duration(days: 10)).toIso8601String(),
      });
    }

    await _updateCashRegister(paidAmt);
    _showPaymentReceipt(id);
  }

  Future<String> _insertPaymentRecord({
    required double amount,
    required double discount,
    required double finalAmt,
    required String? debtId,
    required int? month,
    required int? year,
    required String? notes,
  }) async {
    final receipt = 'P-${DateTime.now().millisecondsSinceEpoch}';
    // To'lov sanasi paymentDate dan olinadi

    final res = await _supabase
        .from('payments')
        .insert({
          'branch_id': selectedBranchId.value,
          'student_id': selectedStudentId.value,
          'class_id': selectedStudent.value?.classId,
          'amount': amount,
          'discount_amount': discount,
          'final_amount': finalAmt, // Chegirmadan keyingi summa
          'paid_amount': finalAmt, // Kassaga tushgan
          'payment_method': paymentMethod.value,
          'payment_type': paymentType.value,
          'payment_status':
              'paid', // Asosiy payment record "paid" bo'ladi, qarz alohida yoziladi
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

    return res['id'];
  }

  Future<void> _updateCashRegister(double amount) async {
    if (amount <= 0) return;
    final row = await _supabase
        .from('cash_register')
        .select()
        .eq('branch_id', selectedBranchId.value!)
        .eq('payment_method', paymentMethod.value)
        .maybeSingle();

    if (row != null) {
      double current = (row['current_balance'] as num).toDouble();
      await _supabase
          .from('cash_register')
          .update({'current_balance': current + amount})
          .eq('id', row['id']);
    } else {
      await _supabase.from('cash_register').insert({
        'branch_id': selectedBranchId.value,
        'payment_method': paymentMethod.value,
        'current_balance': amount,
      });
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
    // Bekor qilish logikasi (Oldingi javobdagi kabi)
    // ...
  }

  // ============================================================================
  // HELPERS
  // ============================================================================
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
