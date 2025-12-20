// lib/presentation/controllers/payment_controller_v4.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/models/student_model.dart';
import '../../data/repositories/payment_repositry.dart';
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
      settledAt: json['settled_at'] != null ? DateTime.parse(json['settled_at']) : null,
      dueDate: json['due_date'] != null ? DateTime.parse(json['due_date']) : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      studentName: json['student_name'],
      className: json['class_name'],
      studentPhone: json['student_phone'],
    );
  }

  String get periodText {
    if (periodMonth != null && periodYear != null) {
      final months = ['Yanvar', 'Fevral', 'Mart', 'Aprel', 'May', 'Iyun',
                     'Iyul', 'Avgust', 'Sentabr', 'Oktabr', 'Noyabr', 'Dekabr'];
      return '${months[periodMonth! - 1]} $periodYear';
    }
    return 'Aniqlanmagan';
  }

  bool get isOverdue {
    if (dueDate == null || isSettled) return false;
    return DateTime.now().isAfter(dueDate!);
  }

  int get daysOverdue {
    if (!isOverdue) return 0;
    return DateTime.now().difference(dueDate!).inDays;
  }
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
    final months = ['Yanvar', 'Fevral', 'Mart', 'Aprel', 'May', 'Iyun',
                   'Iyul', 'Avgust', 'Sentabr', 'Oktabr', 'Noyabr', 'Dekabr'];
    return '${months[periodMonth! - 1]} $periodYear';
  }
}

// ============================================================================
// CONTROLLER
// ============================================================================
class NewPaymentControllerV4 extends GetxController {
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
  var paymentDateTime = DateTime.now().obs;

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
  // INITIALIZATION
  // ============================================================================
  Future<void> _initializeController() async {
    try {
      isLoading.value = true;

      try {
        _authController = Get.find<AuthController>();
      } catch (e) {
        Get.put(AuthController());
        _authController = Get.find<AuthController>();
      }

      if (!_authController.isAuthenticated) {
        throw Exception('Iltimos, tizimga kiring');
      }

      final user = _authController.currentUser.value;
      if (user == null) {
        throw Exception('Foydalanuvchi ma\'lumotlari topilmadi');
      }

      await _loadCompleteStaffInfo(user.id);
      await _setupBranchAccess(user);
      await loadInitialStudents();
      await loadCurrentMonthStatistics();

      print('✅ Controller initialized successfully');
      
    } catch (e) {
      print('❌ Initialization error: $e');
      Get.snackbar(
        'Xato',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 5),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadCompleteStaffInfo(String userId) async {
    try {
      final userData = await _supabase
          .from('users')
          .select('id, first_name, last_name, username, role, branch_id')
          .eq('id', userId)
          .single();

      currentStaffId.value = userData['id'];
      currentStaffName.value = '${userData['first_name']} ${userData['last_name']}';
      currentStaffRole.value = _getRoleNameInUzbek(userData['role']);
      
    } catch (e) {
      rethrow;
    }
  }

  String _getRoleNameInUzbek(String role) {
    switch (role) {
      case 'owner': return 'Direktor';
      case 'manager': return 'Menejer';
      case 'teacher': return 'O\'qituvchi';
      case 'accountant': return 'Buxgalter';
      case 'receptionist': return 'Qabulxona';
      default: return 'Xodim';
    }
  }

  Future<void> _setupBranchAccess(dynamic user) async {
    try {
      userBranchId.value = user.branchId;

      if (user.role == 'owner' || user.role == 'manager') {
        canChangeBranch.value = true;
        
        final branchesData = await _supabase
            .from('branches')
            .select('id, name')
            .eq('is_active', true)
            .order('name');
        
        availableBranches.value = List<Map<String, dynamic>>.from(branchesData);
        
        if (user.branchId != null && user.branchId!.isNotEmpty) {
          selectedBranchId.value = user.branchId;
        } else if (availableBranches.isNotEmpty) {
          selectedBranchId.value = availableBranches.first['id'];
        }
      } else {
        canChangeBranch.value = false;
        
        if (user.branchId == null || user.branchId!.isEmpty) {
          throw Exception('Sizga filial biriktirilmagan');
        }
        
        selectedBranchId.value = user.branchId;
        
        final branchData = await _supabase
            .from('branches')
            .select('id, name')
            .eq('id', user.branchId!)
            .single();
        
        availableBranches.value = [branchData];
      }
      
    } catch (e) {
      rethrow;
    }
  }

  // ============================================================================
  // LOAD STUDENTS
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

      final teacherIds = <String>{};
      for (var json in studentsData) {
        if (json['enrollments'] != null && (json['enrollments'] as List).isNotEmpty) {
          final enrollment = (json['enrollments'] as List).first;
          final classData = enrollment['classes'];
          if (classData != null && classData['main_teacher_id'] != null) {
            teacherIds.add(classData['main_teacher_id']);
          }
        }
      }

      Map<String, Map<String, dynamic>> teachersMap = {};
      if (teacherIds.isNotEmpty) {
        try {
          final teachersData = await _supabase
              .from('users')
              .select('id, first_name, last_name')
              .filter('id', 'in', teacherIds.toList());
          
          for (var teacher in teachersData) {
            teachersMap[teacher['id']] = teacher;
          }
        } catch (e) {
          print('⚠️ Teacher fetch error: $e');
        }
      }

      // Check payment status for current month
      final currentMonth = selectedMonth.value;
      final currentYear = selectedYear.value;
      
      final paymentsData = await _supabase
          .from('payments')
          .select('student_id')
          .eq('branch_id', selectedBranchId.value!)
          .eq('period_month', currentMonth)
          .eq('period_year', currentYear)
          .eq('payment_status', 'paid');

      final paidStudentIds = (paymentsData as List)
          .map((p) => p['student_id'] as String)
          .toSet();

      final students = <StudentModel>[];
      for (var json in studentsData) {
        try {
          if (json['enrollments'] != null && (json['enrollments'] as List).isNotEmpty) {
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
          json['has_paid_current_month'] = paidStudentIds.contains(student.id);
          students.add(student);
        } catch (e) {
          print('⚠️ Student parse error: $e');
        }
      }

      searchResults.value = students;
      print('✅ ${students.length} o\'quvchi yuklandi');
      
    } catch (e) {
      print('❌ Load students error: $e');
      searchResults.clear();
      Get.snackbar('Xato', 'O\'quvchilarni yuklashda xatolik');
    } finally {
      isSearching.value = false;
    }
  }

  // ============================================================================
  // SEARCH STUDENTS
  // ============================================================================
  Future<void> searchStudents() async {
    if (selectedBranchId.value == null) {
      Get.snackbar('Xato', 'Filialni tanlang');
      return;
    }

    final searchText = searchController.text.trim();
    
    if (searchText.isEmpty) {
      await loadInitialStudents();
      return;
    }

    try {
      isSearching.value = true;

      final isPhone = RegExp(r'^\d+$').hasMatch(searchText);
      
      var query = _supabase
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
          .eq('status', 'active');

      if (isPhone) {
        query = query.or('phone.ilike.%$searchText%,parent_phone.ilike.%$searchText%');
      } else {
        query = query.or(
          'first_name.ilike.%$searchText%,'
          'last_name.ilike.%$searchText%'
        );
      }

      final studentsData = await query.order('first_name').limit(200);

      // Process students similar to loadInitialStudents...
      final teacherIds = <String>{};
      for (var json in studentsData) {
        if (json['enrollments'] != null && (json['enrollments'] as List).isNotEmpty) {
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

      final currentMonth = selectedMonth.value;
      final currentYear = selectedYear.value;
      
      final paymentsData = await _supabase
          .from('payments')
          .select('student_id')
          .eq('branch_id', selectedBranchId.value!)
          .eq('period_month', currentMonth)
          .eq('period_year', currentYear)
          .eq('payment_status', 'paid');

      final paidStudentIds = (paymentsData as List)
          .map((p) => p['student_id'] as String)
          .toSet();

      final students = <StudentModel>[];
      for (var json in studentsData) {
        try {
          if (json['enrollments'] != null && (json['enrollments'] as List).isNotEmpty) {
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
          json['has_paid_current_month'] = paidStudentIds.contains(student.id);
          students.add(student);
        } catch (e) {
          print('⚠️ Parse error: $e');
        }
      }

      searchResults.value = students;

      if (students.isEmpty) {
        Get.snackbar(
          'Ma\'lumot',
          'Hech qanday o\'quvchi topilmadi',
          duration: Duration(seconds: 2),
        );
      }
    } catch (e) {
      print('❌ Search error: $e');
      Get.snackbar('Xato', 'Qidirishda xatolik');
    } finally {
      isSearching.value = false;
    }
  }

  void clearSearch() {
    searchController.clear();
    loadInitialStudents();
  }

  // ============================================================================
  // LOAD DEBTS - Automatically create missing monthly debts
  // ============================================================================
  Future<void> loadStudentDebts(String studentId) async {
    if (selectedBranchId.value == null) return;

    try {
      isLoadingDebts.value = true;

      // Get student enrollment date
      final studentData = await _supabase
          .from('students')
          .select('enrollment_date, class_id')
          .eq('id', studentId)
          .single();

      final enrollmentDate = studentData['enrollment_date'] != null
          ? DateTime.parse(studentData['enrollment_date'])
          : DateTime.now();

      // Create missing debts for unpaid months
      await _createMissingDebts(studentId, enrollmentDate, studentData['class_id']);

      // Load all debts
      final debtsData = await _supabase
          .from('student_debts')
          .select('''
            *,
            students(first_name, last_name, parent_phone),
            classes(name)
          ''')
          .eq('student_id', studentId)
          .eq('is_settled', false)
          .order('period_year', ascending: false)
          .order('period_month', ascending: false);

      final debts = <StudentDebtModel>[];
      for (var json in debtsData) {
        try {
          if (json['students'] != null) {
            json['student_name'] = 
                '${json['students']['first_name']} ${json['students']['last_name']}';
            json['student_phone'] = json['students']['parent_phone'];
          }
          
          if (json['classes'] != null) {
            json['class_name'] = json['classes']['name'];
          }
          
          debts.add(StudentDebtModel.fromJson(json));
        } catch (e) {
          print('⚠️ Debt parse error: $e');
        }
      }

      studentDebts.value = debts;
      print('✅ ${debts.length} ta qarz topildi');
      
    } catch (e) {
      print('❌ Load debts error: $e');
    } finally {
      isLoadingDebts.value = false;
    }
  }

  // Create missing monthly debts automatically
  Future<void> _createMissingDebts(String studentId, DateTime enrollmentDate, String? classId) async {
    try {
      final student = await _supabase
          .from('students')
          .select('monthly_fee')
          .eq('id', studentId)
          .single();

      final monthlyFee = (student['monthly_fee'] as num?)?.toDouble() ?? 0;
      if (monthlyFee <= 0) return;

      // Get academic year holidays
      final holidays = await _supabase
          .from('school_holidays')
          .select('start_date, end_date')
          .eq('branch_id', selectedBranchId.value!)
          .eq('is_active', true);

      final now = DateTime.now();
      var checkDate = DateTime(enrollmentDate.year, enrollmentDate.month, 1);

      while (checkDate.isBefore(now) || checkDate.month == now.month) {
        // Check if month is in holiday
        bool isHoliday = false;
        for (var holiday in holidays) {
          final start = DateTime.parse(holiday['start_date']);
          final end = DateTime.parse(holiday['end_date']);
          
          if ((checkDate.isAfter(start) || checkDate.isAtSameMomentAs(start)) &&
              (checkDate.isBefore(end) || checkDate.isAtSameMomentAs(end))) {
            isHoliday = true;
            break;
          }
        }

        if (!isHoliday) {
          // Check if payment exists
          final existingPayment = await _supabase
              .from('payments')
              .select('id')
              .eq('student_id', studentId)
              .eq('period_month', checkDate.month)
              .eq('period_year', checkDate.year)
              .maybeSingle();

          if (existingPayment == null) {
            // Check if debt already exists
            final existingDebt = await _supabase
                .from('student_debts')
                .select('id')
                .eq('student_id', studentId)
                .eq('period_month', checkDate.month)
                .eq('period_year', checkDate.year)
                .maybeSingle();

            if (existingDebt == null) {
              // Create debt
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
        }

        // Move to next month
        checkDate = DateTime(checkDate.year, checkDate.month + 1, 1);
      }
    } catch (e) {
      print('⚠️ Create missing debts error: $e');
    }
  }

  // ============================================================================
  // LOAD PAYMENT HISTORY
  // ============================================================================
  Future<void> loadPaymentHistory(String studentId) async {
    try {
      isLoadingHistory.value = true;

      final historyData = await _supabase
          .from('payments')
          .select('''
            *,
            users:received_by(first_name, last_name)
          ''')
          .eq('student_id', studentId)
          .order('payment_date', ascending: false)
          .limit(50);

      final history = <PaymentHistoryModel>[];
      for (var json in historyData) {
        try {
          if (json['users'] != null) {
            json['received_by_name'] = 
                '${json['users']['first_name']} ${json['users']['last_name']}';
          }
          history.add(PaymentHistoryModel.fromJson(json));
        } catch (e) {
          print('⚠️ History parse error: $e');
        }
      }

      paymentHistory.value = history;

    } catch (e) {
      print('❌ Load history error: $e');
    } finally {
      isLoadingHistory.value = false;
    }
  }

  // ============================================================================
  // SHOW PAYMENT HISTORY DIALOG
  // ============================================================================
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

      // Qarzdorlar
      final debtsResponse = await _supabase
          .from('student_debts')
          .select('id')
          .eq('branch_id', selectedBranchId.value!)
          .eq('is_settled', false)
          .eq('period_month', currentMonth)
          .eq('period_year', currentYear);

      currentMonthDebtorsCount.value = (debtsResponse as List).length;

      // To'lamagan o'quvchilar
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
  // DEBT SELECTION
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

  // ============================================================================
  // STUDENT SELECTION
  // ============================================================================
  void selectStudent(StudentModel student) {
    selectedStudent.value = student;
    selectedStudentId.value = student.id;

    loadStudentDebts(student.id);
    loadPaymentHistory(student.id);

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
    } else {
      hasDiscount.value = false;
      discountController.clear();
      discountReasonController.clear();
    }

    paymentDateTime.value = DateTime.now();
    calculateFinalAmount();

    Get.snackbar(
      'Tanlandi',
      '${student.fullName} tanlandi',
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: Duration(seconds: 2),
    );
  }

  void clearSelection() {
    selectedStudent.value = null;
    selectedStudentId.value = null;
    studentDebts.clear();
    selectedDebts.clear();
    paymentHistory.clear();
    _resetForm();
  }

  void _resetForm() {
    amountController.clear();
    discountController.clear();
    discountReasonController.clear();
    paidAmountController.clear();
    notesController.clear();
    debtReasonController.clear();

    paymentType.value = 'tuition';
    paymentMethod.value = 'cash';
    hasDiscount.value = false;
    discountType.value = 'amount';
    isPartialPayment.value = false;

    finalAmount.value = 0;
    debtAmount.value = 0;
    totalSelectedDebts.value = 0;
    paymentDateTime.value = DateTime.now();
  }

  // ============================================================================
  // CALCULATIONS
  // ============================================================================
  void calculateFinalAmount() {
    double amount = double.tryParse(amountController.text) ?? 0;
    double discount = 0;

    if (hasDiscount.value) {
      double discountValue = double.tryParse(discountController.text) ?? 0;
      if (discountType.value == 'percent') {
        discount = amount * discountValue / 100;
      } else {
        discount = discountValue;
      }
    }

    finalAmount.value = amount - discount;

    if (isPartialPayment.value) {
      calculateDebtAmount();
    }
  }

  void calculateDebtAmount() {
    double paid = double.tryParse(paidAmountController.text) ?? 0;
    debtAmount.value = (finalAmount.value - paid).clamp(0, double.infinity);
  }

  // ============================================================================
  // MONTH SELECTION
  // ============================================================================
  Future<void> selectMonth(BuildContext context) async {
    final now = DateTime.now();
    final initialDate = DateTime(selectedYear.value, selectedMonth.value);
    
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 1),
      initialDatePickerMode: DatePickerMode.year,
      locale: Locale('uz', 'UZ'),
    );

    if (picked != null) {
      selectedMonth.value = picked.month;
      selectedYear.value = picked.year;
      
      await loadInitialStudents();
      await loadCurrentMonthStatistics();
      
      Get.snackbar(
        'Oy o\'zgartirildi',
        '${_getMonthName(picked.month)} ${picked.year}',
        backgroundColor: Colors.blue,
        colorText: Colors.white,
      );
    }
  }

  String _getMonthName(int month) {
    const months = ['Yanvar', 'Fevral', 'Mart', 'Aprel', 'May', 'Iyun',
                   'Iyul', 'Avgust', 'Sentabr', 'Oktabr', 'Noyabr', 'Dekabr'];
    return months[month - 1];
  }

  String get currentMonthYear {
    return '${_getMonthName(selectedMonth.value)} ${selectedYear.value}';
  }

  // ============================================================================
  // SAVE PAYMENT
  // ============================================================================
  Future<void> savePayment() async {
    if (!formKey.currentState!.validate()) return;

    if (selectedStudentId.value == null) {
      Get.snackbar('Xato', 'O\'quvchini tanlang');
      return;
    }

    if (selectedBranchId.value == null) {
      Get.snackbar('Xato', 'Filialni tanlang');
      return;
    }

    if (selectedDebts.isNotEmpty) {
      await _processMultipleDebtsPayment();
    } else {
      await _processRegularPayment();
    }
  }

  // ============================================================================
  // PROCESS DEBT PAYMENT
  // ============================================================================
  Future<void> _processMultipleDebtsPayment() async {
    try {
      isLoading.value = true;

      final paymentAmount = double.tryParse(amountController.text) ?? 0;
      if (paymentAmount <= 0) {
        throw Exception('To\'lov summasi noto\'g\'ri');
      }

      double remainingPayment = paymentAmount;
      final processedDebts = <String>[];
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

        // Update debt
        await _supabase
            .from('student_debts')
            .update({
              'paid_amount': newPaidAmount,
              'remaining_amount': isFullyPaid ? 0 : newRemainingAmount,
              'is_settled': isFullyPaid,
              'settled_at': isFullyPaid ? DateTime.now().toIso8601String() : null,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', debtId);

        // Create payment record
        final receiptNumber = 'QT-${DateTime.now().millisecondsSinceEpoch}';
        
        final paymentResult = await _supabase.from('payments').insert({
          'receipt_number': receiptNumber,
          'student_id': selectedStudentId.value!,
          'branch_id': selectedBranchId.value!,
          'class_id': selectedStudent.value!.classId,
          'amount': amountToPay,
          'discount_percent': 0,
          'discount_amount': 0,
          'final_amount': amountToPay,
          'paid_amount': amountToPay,
          'payment_method': paymentMethod.value,
          'payment_type': 'debt_payment',
          'payment_status': 'paid',
          'payment_date': DateTime.now().toIso8601String(),
          'payment_time': TimeOfDay.now().format(Get.context!),
          'period_month': debt.periodMonth,
          'period_year': debt.periodYear,
          'notes': 'Qarz to\'lovi. ${debt.periodText}',
          'received_by': currentStaffId.value,
          'debt_id': debtId,
          'is_debt': false,
          'debt_amount': 0,
          'remaining_debt': 0,
          'created_at': DateTime.now().toIso8601String(),
        }).select().single();

        remainingPayment -= amountToPay;
        processedDebts.add(debtId);
        paymentIds.add(paymentResult['id']);
      }

      // Show receipt for last payment
      if (paymentIds.isNotEmpty) {
        final lastPaymentId = paymentIds.last;
        await _showPaymentReceipt(lastPaymentId);
      }

      Get.snackbar(
        'Muvaffaqiyatli ✓',
        '${processedDebts.length} ta qarz to\'landi',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );

      await loadCurrentMonthStatistics();
      clearSelection();

    } catch (e) {
      print('❌ Multiple debts payment error: $e');
      Get.snackbar('Xato', 'To\'lovni saqlashda xatolik: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================================
  // PROCESS REGULAR PAYMENT
  // ============================================================================
  Future<void> _processRegularPayment() async {
    try {
      isLoading.value = true;

      double discountPercent = 0;
      double discountAmount = 0;

      if (hasDiscount.value) {
        double discountValue = double.tryParse(discountController.text) ?? 0;
        if (discountType.value == 'percent') {
          discountPercent = discountValue;
          discountAmount = (double.tryParse(amountController.text) ?? 0) * discountValue / 100;
        } else {
          discountAmount = discountValue;
          discountPercent = (discountAmount / (double.tryParse(amountController.text) ?? 1)) * 100;
        }
      }

      double paidAmount = finalAmount.value;
      String? debtReason;
      
      if (isPartialPayment.value) {
        paidAmount = double.tryParse(paidAmountController.text) ?? 0;
        debtReason = debtReasonController.text.trim();
      }

      final result = await _paymentRepo.processStudentPayment(
        studentId: selectedStudentId.value!,
        branchId: selectedBranchId.value!,
        classId: selectedStudent.value!.classId ?? '',
        amount: double.tryParse(amountController.text) ?? 0,
        discountPercent: discountPercent,
        discountAmount: discountAmount,
        discountReason: discountReasonController.text.isNotEmpty 
            ? discountReasonController.text : null,
        paymentMethod: paymentMethod.value,
        paymentType: paymentType.value,
        periodMonth: selectedMonth.value,
        periodYear: selectedYear.value,
        notes: notesController.text.isNotEmpty ? notesController.text : null,
        receivedBy: currentStaffId.value,
        isPartial: isPartialPayment.value,
        paidAmount: isPartialPayment.value ? paidAmount : null,
        debtReason: debtReason,
      );

      if (result != null && result['success'] == true) {
        // Show receipt
        if (result['payment_id'] != null) {
          await _showPaymentReceipt(result['payment_id']);
        }

        Get.snackbar(
          'Muvaffaqiyatli ✓',
          'To\'lov qabul qilindi',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
        
        await loadCurrentMonthStatistics();
        clearSelection();
      } else {
        throw Exception(result?['message'] ?? 'Noma\'lum xatolik');
      }
    } catch (e) {
      print('❌ Payment error: $e');
      Get.snackbar('Xato', 'To\'lovni saqlashda xatolik: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================================
  // SHOW PAYMENT RECEIPT
  // ============================================================================
  Future<void> _showPaymentReceipt(String paymentId) async {
    try {
      // Get complete payment data
      final paymentData = await _supabase
          .from('payments')
          .select('''
            *,
            users:received_by(first_name, last_name)
          ''')
          .eq('id', paymentId)
          .single();

      // Get branch data
      final branchData = await _supabase
          .from('branches')
          .select('name, address, phone')
          .eq('id', selectedBranchId.value!)
          .single();

      if (paymentData['users'] != null) {
        paymentData['received_by_name'] = 
            '${paymentData['users']['first_name']} ${paymentData['users']['last_name']}';
      }

      paymentData['branch_name'] = branchData['name'];
      paymentData['branch_address'] = branchData['address'];
      paymentData['branch_phone'] = branchData['phone'];

      // Student data
      final student = selectedStudent.value!;
      final studentData = {
        'full_name': student.fullName,
        'class_name': student.className,
        'class_level_name': student.classLevelName,
        'teacher_name': student.mainTeacherName,
        'parent_phone': student.parentPhone,
        'student_phone': student.phone,
      };

      Get.dialog(
        PaymentReceiptDialog(
          paymentData: paymentData,
          studentData: studentData,
        ),
        barrierDismissible: false,
      );

    } catch (e) {
      print('❌ Show receipt error: $e');
    }
  }

  // ============================================================================
  // HELPER FUNCTIONS
  // ============================================================================
  String formatCurrency(double amount) {
    try {
      final formatter = NumberFormat('#,###', 'uz_UZ');
      return formatter.format(amount);
    } catch (e) {
      return amount.toStringAsFixed(0);
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

  Future<void> onBranchChanged(String? newBranchId) async {
    if (newBranchId == null || newBranchId == selectedBranchId.value) return;
    
    selectedBranchId.value = newBranchId;
    
    clearSelection();
    await loadInitialStudents();
    await loadCurrentMonthStatistics();
  }

  @override
  void onClose() {
    searchController.dispose();
    amountController.dispose();
    discountController.dispose();
    discountReasonController.dispose();
    paidAmountController.dispose();
    notesController.dispose();
    debtReasonController.dispose();
    super.onClose();
  }
}