// lib/presentation/controllers/new_payment_controller.dart
// ================================================================================
// TUZATILGAN VERSIYA V3 - Custom Auth bilan ishlaydi
// ================================================================================

import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/repositories/payment_repositry.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/models/student_model.dart';
import 'auth_controller.dart'; // ← Sizning AuthController

class NewPaymentController extends GetxController {
  final PaymentRepository _paymentRepo = PaymentRepository();
  final _supabase = Supabase.instance.client;

  final formKey = GlobalKey<FormState>();

  // Text Controllers
  final searchController = TextEditingController();
  final amountController = TextEditingController();
  final discountController = TextEditingController();
  final discountReasonController = TextEditingController();
  final paidAmountController = TextEditingController();
  final notesController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();

  // Observable variables
  var isLoading = false.obs;
  var isSearching = false.obs;
  var searchResults = <StudentModel>[].obs;
  var selectedStudent = Rxn<StudentModel>();
  var selectedStudentId = Rxn<String>();

  // Statistics
  var todayPaymentsCount = 0.obs;
  var todayRevenue = 0.0.obs;

  // To'lov ma'lumotlari
  var paymentType = 'tuition'.obs;
  var paymentMethod = 'cash'.obs;

  // Chegirma
  var hasDiscount = false.obs;
  var discountType = 'amount'.obs; // avval 'percent' edi

  // Qarz
  var isPartialPayment = false.obs;

  // Hisoblangan qiymatlar
  var finalAmount = 0.0.obs;
  var debtAmount = 0.0.obs;
  var searchText = ''.obs;

  // AuthController dan foydalanish
  late AuthController _authController;

  @override
  void onInit() {
    super.onInit();
    _initializeController();
  }

  // ============================================================================
  // CONTROLLER NI BOSHLASH
  // ============================================================================

  Future<void> _initializeController() async {
    try {
      isLoading.value = true;

      print('🚀 Starting controller initialization...');

      // AuthController ni topish
      try {
        _authController = Get.find<AuthController>();
        print('✅ AuthController found');
      } catch (e) {
        print('❌ AuthController not found, creating new instance');
        Get.put(AuthController());
        _authController = Get.find<AuthController>();
      }

      // User tekshirish
      if (!_authController.isAuthenticated) {
        print('❌ User not authenticated');
        throw Exception('Iltimos, tizimga kiring');
      }

      final user = _authController.currentUser.value;
      if (user == null) {
        throw Exception('Foydalanuvchi ma\'lumotlari topilmadi');
      }

      print('✅ User authenticated:');
      print('   - Name: ${user.fullName}');
      print('   - User ID: ${user.id}');
      print('   - Branch ID: ${user.branchId}');
      print('   - Role: ${user.role}');

      // Statistikani yuklash
      await loadTodayStatistics();

      print('✅ Controller initialized successfully');
    } catch (e) {
      print('❌ Controller initialization error: $e');

      Get.snackbar(
        'Xato',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );

      // Agar user topilmasa, login ga qaytarish
      if (e.toString().contains('kiring')) {
        Future.delayed(Duration(seconds: 1), () {
          Get.offAllNamed('/login');
        });
      }
    } finally {
      isLoading.value = false;
    }
  }

  // BARCHA O'QUVCHILARNI YUKLASH (initial)
  Future<void> loadAllStudents() async {
    try {
      isSearching.value = true;

      final branchId = _authController.currentUser.value?.branchId;
      if (branchId == null || branchId.isEmpty) {
        print('⚠️ Branch ID yo‘q, o‘quvchilar yuklanmaydi');
        return;
      }

      final studentsData = await _supabase
          .from('students')
          .select('''
            *,
            enrollments!inner(
              id,
              class_id,
              classes!inner(
                id,
                name
              )
            )
          ''')
          .eq('branch_id', branchId)
          .eq('status', 'active')
          .order('first_name')
          .limit(200);

      final students = <StudentModel>[];
      for (var json in studentsData) {
        try {
          students.add(StudentModel.fromJson(json));
        } catch (e) {
          print('⚠️ Student parse xato: $e');
        }
      }

      searchResults.value = students;
      print('✅ ${students.length} ta o‘quvchi yuklandi');
    } catch (e) {
      print('❌ loadAllStudents xato: $e');
      searchResults.clear();
    } finally {
      isSearching.value = false;
    }
  }
  // ============================================================================
  // BUGUNGI STATISTIKANI YUKLASH
  // ============================================================================

  Future<void> loadTodayStatistics() async {
    try {
      final branchId = _authController.currentUser.value?.branchId;

      if (branchId == null || branchId.isEmpty) {
        print('⚠️ Branch ID yo\'q, statistika yuklanmaydi');
        return;
      }

      final today = DateTime.now();
      final startDate = DateTime(today.year, today.month, today.day);
      final startDateStr = startDate.toIso8601String().split('T')[0];

      print('📊 Loading statistics for branch: $branchId');
      print('📅 Date: $startDateStr');

      // Bugungi to'lovlar sonini olish
      final countResponse = await _supabase
          .from('payments')
          .select('id')
          .eq('branch_id', branchId)
          .gte('payment_date', startDateStr);

      todayPaymentsCount.value = countResponse.count ?? 0;
      print('✅ Today payments count: ${todayPaymentsCount.value}');

      // Bugungi tushumni hisoblash
      final revenueResponse = await _supabase
          .from('payments')
          .select('final_amount, paid_amount')
          .eq('branch_id', branchId)
          .eq('payment_status', 'paid')
          .gte('payment_date', startDateStr);

      double totalRevenue = 0;
      for (var payment in revenueResponse) {
        // paid_amount bor bo'lsa uni, yo'q bo'lsa final_amount ni ishlatamiz
        final amount = payment['paid_amount'] ?? payment['final_amount'];
        if (amount != null) {
          totalRevenue += (amount as num).toDouble();
        }
      }

      todayRevenue.value = totalRevenue;

      print('✅ Statistics loaded successfully:');
      print('   - Payments: ${todayPaymentsCount.value}');
      print('   - Revenue: ${formatCurrency(todayRevenue.value)} so\'m');
    } catch (e) {
      print('❌ Load statistics error: $e');
      // Statistika yuklanmasa ham davom etamiz
      todayPaymentsCount.value = 0;
      todayRevenue.value = 0;
    }
  }

  // ============================================================================
  // O'QUVCHILARNI QIDIRISH (ONLINE)
  // ============================================================================

  // Faqat Enter yoki search tugmasi bosilganda chaqiriladi
  Future<void> searchStudents(String value) async {
    final firstName = firstNameController.text.trim();
    final lastName = lastNameController.text.trim();

    // Hech narsa kiritilmagan bo‘lsa – barcha o‘quvchilarni ko‘rsatamiz
    if (firstName.isEmpty && lastName.isEmpty) {
      await loadAllStudents();
      return;
    }

    final branchId = _authController.currentUser.value?.branchId;
    if (branchId == null || branchId.isEmpty) {
      Get.snackbar('Xato', 'Filial ma\'lumoti topilmadi');
      return;
    }

    try {
      isSearching.value = true;
      print('🔍 Searching: first="$firstName", last="$lastName"');

      var query = _supabase
          .from('students')
          .select('''
            *,
            enrollments!inner(
              id,
              class_id,
              classes!inner(
                id,
                name
              )
            )
          ''')
          .eq('branch_id', branchId)
          .eq('status', 'active');

      if (firstName.isNotEmpty) {
        query = query.ilike('first_name', '%$firstName%');
      }
      if (lastName.isNotEmpty) {
        query = query.ilike('last_name', '%$lastName%');
      }

      final studentsData = await query.order('first_name').limit(200);

      final students = <StudentModel>[];
      for (var json in studentsData) {
        try {
          students.add(StudentModel.fromJson(json));
        } catch (e) {
          print('⚠️ Student parse xato: $e');
        }
      }

      searchResults.value = students;
      print('✅ Search natija: ${students.length} ta');

      if (students.isEmpty) {
        Get.snackbar(
          'Ma\'lumot',
          'Hech qanday o\'quvchi topilmadi',
          duration: Duration(seconds: 2),
        );
      }
    } catch (e) {
      print('❌ Search error: $e');
      Get.snackbar(
        'Xato',
        'Qidirishda xatolik: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isSearching.value = false;
    }
  }

  // ============================================================================
  // O'QUVCHINI TANLASH
  // ============================================================================

  void selectStudent(StudentModel student) {
    selectedStudent.value = student;
    selectedStudentId.value = student.id;

    // Oylik to'lovni avtomatik qo'yamiz
    amountController.text = student.monthlyFee.toStringAsFixed(0);

    // Chegirma bo‘lsa avtomatik
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
      discountType.value = 'amount';
    }

    calculateFinalAmount();

    Get.snackbar(
      'Tanlandi',
      '${student.fullName} tanlandi',
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: Duration(seconds: 2),
    );
  }
  // ============================================================================
  // TANLOVNI TOZALASH
  // ============================================================================

  void clearSelection() {
    selectedStudent.value = null;
    selectedStudentId.value = null;
    searchController.clear();
    searchResults.clear();
    _resetForm();
  }

  void _resetForm() {
    amountController.clear();
    discountController.clear();
    discountReasonController.clear();
    paidAmountController.clear();
    notesController.clear();

    paymentType.value = 'tuition';
    paymentMethod.value = 'cash';
    hasDiscount.value = false;
    discountType.value = 'percent';
    isPartialPayment.value = false;

    finalAmount.value = 0;
    debtAmount.value = 0;
  }

  // ============================================================================
  // YAKUNIY SUMMANI HISOBLASH
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

  // ============================================================================
  // QARZ SUMMASINI HISOBLASH
  // ============================================================================

  void calculateDebtAmount() {
    double paid = double.tryParse(paidAmountController.text) ?? 0;
    debtAmount.value = (finalAmount.value - paid).clamp(0, double.infinity);
  }

  // ============================================================================
  // TO'LOVNI SAQLASH
  // ============================================================================

  Future<void> savePayment() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    if (selectedStudentId.value == null) {
      Get.snackbar(
        'Xato',
        'O\'quvchini tanlang',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final currentUser = _authController.currentUser.value;
    if (currentUser == null) {
      Get.snackbar(
        'Xato',
        'Foydalanuvchi ma\'lumotlari topilmadi',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // DEBUGGING: User ma'lumotlarini tekshirish
    print('🔍 DEBUG: Checking user data...');
    print('   User object: $currentUser');
    print('   User ID: ${currentUser.id}');

    // Branch ID ni olish - turli usullar
    String? branchId;
    try {
      branchId = currentUser.branchId;
      print('   Branch ID (direct): $branchId');
    } catch (e) {
      print('   ❌ Error getting branchId directly: $e');
    }

    if (branchId == null || branchId.isEmpty) {
      Get.snackbar(
        'Xato',
        'Filial ma\'lumoti topilmadi. Admin bilan bog\'laning.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final amount = double.tryParse(amountController.text) ?? 0;
    if (amount <= 0) {
      Get.snackbar(
        'Xato',
        'To\'lov summasi noto\'g\'ri',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (isPartialPayment.value) {
      final paid = double.tryParse(paidAmountController.text) ?? 0;
      if (paid <= 0 || paid >= finalAmount.value) {
        Get.snackbar(
          'Xato',
          'To\'lanadigan summa noto\'g\'ri',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }
    }

    try {
      isLoading.value = true;

      print('💰 Saving payment...');
      print('   Student: ${selectedStudent.value!.fullName}');
      print('   Amount: $amount');
      print('   Final: ${finalAmount.value}');
      print('   Branch: ${currentUser.branchId}');
      print('   User: ${currentUser.id}');

      // Ma'lumotlarni tayyorlash
      double discountPercent = 0;
      double discountAmount = 0;

      if (hasDiscount.value) {
        double discountValue = double.tryParse(discountController.text) ?? 0;

        if (discountType.value == 'percent') {
          discountPercent = discountValue;
          discountAmount = amount * discountValue / 100;
        } else {
          discountAmount = discountValue;
          discountPercent = (discountAmount / amount) * 100;
        }
      }

      double paidAmount = finalAmount.value;
      if (isPartialPayment.value) {
        paidAmount = double.tryParse(paidAmountController.text) ?? 0;
      }

      // Database function ni chaqirish
      final result = await _paymentRepo.processStudentPayment(
        studentId: selectedStudentId.value!,
        branchId: branchId, // ← Tekshirilgan branchId
        classId: selectedStudent.value!.classId ?? '',
        amount: amount,
        discountPercent: discountPercent,
        discountAmount: discountAmount,
        discountReason: discountReasonController.text.isNotEmpty
            ? discountReasonController.text
            : null,
        paymentMethod: paymentMethod.value,
        paymentType: paymentType.value,
        periodMonth: DateTime.now().month,
        periodYear: DateTime.now().year,
        notes: notesController.text.isNotEmpty ? notesController.text : null,
        receivedBy: currentUser.id,
        isPartial: isPartialPayment.value,
        paidAmount: isPartialPayment.value ? paidAmount : null,
      );

      if (result != null && result['success'] == true) {
        print('✅ Payment saved successfully');

        Get.snackbar(
          'Muvaffaqiyatli ✓',
          'To\'lov qabul qilindi',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );

        await loadTodayStatistics();
        _showPrintReceiptDialog(result['receipt_number'] ?? 'N/A');
      } else {
        throw Exception(result?['message'] ?? 'Noma\'lum xatolik');
      }
    } catch (e) {
      print('❌ Payment save error: $e');
      Get.snackbar(
        'Xato',
        'To\'lovni saqlashda xatolik: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================================
  // CHEK DIALOGI
  // ============================================================================

  void _showPrintReceiptDialog(String receiptNumber) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 12),
            Text('To\'lov qabul qilindi'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text('Chek raqami', style: TextStyle(fontSize: 12)),
                  SizedBox(height: 4),
                  Text(
                    receiptNumber,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              clearSelection();
            },
            child: Text('Yo\'q, keyinroq'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Get.back();
              clearSelection();
            },
            icon: Icon(Icons.print),
            label: Text('Chop etish'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  // ============================================================================
  // HELPER
  // ============================================================================

  String formatCurrency(double amount) {
    try {
      final formatter = NumberFormat('#,###', 'uz_UZ');
      return formatter.format(amount);
    } catch (e) {
      return amount.toStringAsFixed(0);
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    amountController.dispose();
    discountController.dispose();
    discountReasonController.dispose();
    paidAmountController.dispose();
    notesController.dispose();
    super.onClose();
  }
}

extension on PostgrestList {
  get count => null;
}
