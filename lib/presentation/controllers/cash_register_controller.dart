// lib/presentation/controllers/cash_register_controller.dart
// MUKAMMAL KASSA TIZIMI CONTROLLER

import 'package:flutter_application_1/data/repositories/payment_repositry.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/payment_model.dart';
import 'auth_controller.dart';

class CashRegisterController extends GetxController {
  final PaymentRepository _paymentRepository = PaymentRepository();
  final AuthController _authController = Get.find<AuthController>();

  // ASOSIY HOLATLAR
  final RxBool isLoading = true.obs;
  final RxString selectedPeriod =
      'today'.obs; // today, week, month, year, custom
  final Rx<DateTime> startDate = DateTime.now().obs;
  final Rx<DateTime> endDate = DateTime.now().obs;

  // KASSA STATISTIKASI
  final RxDouble totalCashBalance = 0.0.obs; // Jami kassa qoldig'i
  final RxDouble mainCashBalance = 0.0.obs; // Asosiy kassa (naqd)
  final RxDouble clickBalance = 0.0.obs; // Click hamyon
  final RxDouble ownerCashBalance = 0.0.obs; // Eganing kassasi

  // TUSHUM STATISTIKASI
  final RxDouble todayRevenue = 0.0.obs; // Bugungi tushum
  final RxDouble periodRevenue = 0.0.obs; // Tanlangan davr tushumi
  final RxDouble expectedRevenue = 0.0.obs; // Kutilayotgan tushum
  final RxDouble totalDebt = 0.0.obs; // Jami qarz

  // TO'LOV USULLARI BO'YICHA
  final RxDouble cashPayments = 0.0.obs; // Naqd to'lovlar
  final RxDouble clickPayments = 0.0.obs; // Click to'lovlar
  final RxDouble cardPayments = 0.0.obs; // Karta to'lovlar
  final RxDouble bankPayments = 0.0.obs; // Bank to'lovlar

  // TO'LOVLAR RO'YXATI
  final RxList<PaymentModel> payments = <PaymentModel>[].obs;
  final RxList<Map<String, dynamic>> cashTransactions =
      <Map<String, dynamic>>[].obs;

  // FILTER
  final RxString paymentMethodFilter =
      'all'.obs; // all, cash, click, card, bank
  final RxString statusFilter = 'all'.obs; // all, paid, pending, cancelled

  @override
  void onInit() {
    super.onInit();
    _setDateRange('today');
    loadAllData();
  }

  // ==================== ASOSIY MA'LUMOTLARNI YUKLASH ====================
  Future<void> loadAllData() async {
    try {
      isLoading.value = true;
      final branchId = _authController.currentUser.value?.branchId;
      if (branchId == null) return;

      await Future.wait([
        _loadCashBalances(branchId),
        _loadRevenueStatistics(branchId),
        _loadPayments(branchId),
        _loadCashTransactions(branchId),
      ]);
    } catch (e) {
      print('❌ Load all data error: $e');
      Get.snackbar('Xatolik', 'Ma\'lumotlarni yuklashda xatolik');
    } finally {
      isLoading.value = false;
    }
  }

  // ==================== KASSA QOLDIQLARI ====================
  Future<void> _loadCashBalances(String branchId) async {
    try {
      final supabase = Supabase.instance.client;

      // Kassa qoldiqlarini olish
      final response = await supabase
          .from('cash_register')
          .select('payment_method, current_balance')
          .eq('branch_id', branchId);

      mainCashBalance.value = 0;
      clickBalance.value = 0;
      ownerCashBalance.value = 0;

      for (var cash in response) {
        final method = cash['payment_method'] as String;
        final balance = (cash['current_balance'] as num).toDouble();

        switch (method) {
          case 'cash':
            mainCashBalance.value = balance;
            break;
          case 'click':
            clickBalance.value = balance;
            break;
          case 'owner_cash':
            ownerCashBalance.value = balance;
            break;
        }
      }

      totalCashBalance.value =
          mainCashBalance.value + clickBalance.value + ownerCashBalance.value;
    } catch (e) {
      print('❌ Load cash balances error: $e');
    }
  }

  // ==================== TUSHUM STATISTIKASI ====================
  Future<void> _loadRevenueStatistics(String branchId) async {
    try {
      // Tanlangan davr uchun tushum
      periodRevenue.value = await _paymentRepository.getTotalRevenue(
        branchId: branchId,
        startDate: startDate.value,
        endDate: endDate.value,
      );

      // Bugungi tushum
      final today = DateTime.now();
      final todayStart = DateTime(today.year, today.month, today.day);
      final todayEnd = todayStart.add(Duration(days: 1));

      todayRevenue.value = await _paymentRepository.getTotalRevenue(
        branchId: branchId,
        startDate: todayStart,
        endDate: todayEnd,
      );

      // To'lov usullari bo'yicha
      await _loadPaymentMethodStatistics(branchId);

      // Qarz va kutilayotgan tushum
      await _loadDebtStatistics(branchId);
    } catch (e) {
      print('❌ Load revenue statistics error: $e');
    }
  }

  // ==================== TO'LOV USULLARI STATISTIKASI ====================
  Future<void> _loadPaymentMethodStatistics(String branchId) async {
    try {
      final supabase = Supabase.instance.client;

      final response = await supabase
          .from('payments')
          .select('payment_method, final_amount')
          .eq('branch_id', branchId)
          .eq('payment_status', 'paid')
          .gte('payment_date', startDate.value.toIso8601String())
          .lte('payment_date', endDate.value.toIso8601String());

      cashPayments.value = 0;
      clickPayments.value = 0;
      cardPayments.value = 0;
      bankPayments.value = 0;

      for (var payment in response) {
        final method = payment['payment_method'] as String?;
        final amount = (payment['final_amount'] as num).toDouble();

        switch (method) {
          case 'cash':
            cashPayments.value += amount;
            break;
          case 'click':
            clickPayments.value += amount;
            break;
          case 'card':
            cardPayments.value += amount;
            break;
          case 'bank':
            bankPayments.value += amount;
            break;
        }
      }
    } catch (e) {
      print('❌ Load payment method statistics error: $e');
    }
  }

  // ==================== QARZ STATISTIKASI ====================
  Future<void> _loadDebtStatistics(String branchId) async {
    try {
      final supabase = Supabase.instance.client;

      // Jami qarz (to'lanmagan to'lovlar)
      final debtResponse = await supabase
          .from('payments')
          .select('final_amount')
          .eq('branch_id', branchId)
          .eq('payment_status', 'pending');

      totalDebt.value = 0;
      for (var payment in debtResponse) {
        totalDebt.value += (payment['final_amount'] as num).toDouble();
      }

      // Kutilayotgan tushum (ushbu oy uchun)
      final now = DateTime.now();
      final monthStart = DateTime(now.year, now.month, 1);
      final monthEnd = DateTime(now.year, now.month + 1, 1);

      final expectedResponse = await supabase
          .from('payments')
          .select('final_amount')
          .eq('branch_id', branchId)
          .gte('payment_date', monthStart.toIso8601String())
          .lt('payment_date', monthEnd.toIso8601String());

      expectedRevenue.value = 0;
      for (var payment in expectedResponse) {
        expectedRevenue.value += (payment['final_amount'] as num).toDouble();
      }
    } catch (e) {
      print('❌ Load debt statistics error: $e');
    }
  }

  // ==================== TO'LOVLAR RO'YXATI ====================
  Future<void> _loadPayments(String branchId) async {
    try {
      var allPayments = await _paymentRepository.getPayments(
        branchId: branchId,
        startDate: startDate.value,
        endDate: endDate.value,
        limit: 500,
        paymentType: '',
      );

      // Filter qo'llash
      if (paymentMethodFilter.value != 'all') {
        allPayments = allPayments
            .where((p) => p.paymentMethod == paymentMethodFilter.value)
            .toList();
      }

      if (statusFilter.value != 'all') {
        allPayments = allPayments
            .where((p) => p.paymentStatus == statusFilter.value)
            .toList();
      }

      payments.value = allPayments;
    } catch (e) {
      print('❌ Load payments error: $e');
    }
  }

  // ==================== KASSA TRANZAKSIYALARI ====================
  Future<void> _loadCashTransactions(String branchId) async {
    try {
      final supabase = Supabase.instance.client;

      final response = await supabase
          .from('cash_transactions')
          .select('''
            *,
            performed_by_user:performed_by(first_name, last_name)
          ''')
          .eq('branch_id', branchId)
          .gte(
            'transaction_date',
            startDate.value.toIso8601String().split('T')[0],
          )
          .lte(
            'transaction_date',
            endDate.value.toIso8601String().split('T')[0],
          )
          .order('created_at', ascending: false)
          .limit(100);

      cashTransactions.value = List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Load cash transactions error: $e');
    }
  }

  // ==================== DAVRNI O'ZGARTIRISH ====================
  void changePeriod(String period) {
    selectedPeriod.value = period;
    _setDateRange(period);
    loadAllData();
  }

  void _setDateRange(String period) {
    final now = DateTime.now();
    switch (period) {
      case 'today':
        startDate.value = DateTime(now.year, now.month, now.day);
        endDate.value = startDate.value.add(Duration(days: 1));
        break;
      case 'week':
        startDate.value = now.subtract(Duration(days: now.weekday - 1));
        startDate.value = DateTime(
          startDate.value.year,
          startDate.value.month,
          startDate.value.day,
        );
        endDate.value = startDate.value.add(Duration(days: 7));
        break;
      case 'month':
        startDate.value = DateTime(now.year, now.month, 1);
        endDate.value = DateTime(now.year, now.month + 1, 1);
        break;
      case 'year':
        startDate.value = DateTime(now.year, 1, 1);
        endDate.value = DateTime(now.year + 1, 1, 1);
        break;
    }
  }

  // Custom sana orlig'i
  void setCustomDateRange(DateTime start, DateTime end) {
    selectedPeriod.value = 'custom';
    startDate.value = start;
    endDate.value = end;
    loadAllData();
  }

  // ==================== FILTERLAR ====================
  void changePaymentMethodFilter(String method) {
    paymentMethodFilter.value = method;
    _loadPayments(_authController.currentUser.value!.branchId!);
  }

  void changeStatusFilter(String status) {
    statusFilter.value = status;
    _loadPayments(_authController.currentUser.value!.branchId!);
  }

  // ==================== KASSA O'TKAZMALARI ====================
  Future<void> transferCash({
    required String fromMethod,
    required String toMethod,
    required double amount,
    required String description,
  }) async {
    try {
      final branchId = _authController.currentUser.value?.branchId;
      final userId = _authController.currentUser.value?.id;
      if (branchId == null || userId == null) return;

      final supabase = Supabase.instance.client;

      // 1. From kassadan pul chiqarish
      await supabase.rpc(
        'process_cash_transfer',
        params: {
          'p_branch_id': branchId,
          'p_from_method': fromMethod,
          'p_to_method': toMethod,
          'p_amount': amount,
          'p_description': description,
          'p_performed_by': userId,
        },
      );

      Get.snackbar(
        'Muvaffaqiyatli',
        'Pul muvaffaqiyatli o\'tkazildi',
        snackPosition: SnackPosition.TOP,
      );

      await loadAllData();
    } catch (e) {
      print('❌ Transfer cash error: $e');
      Get.snackbar('Xatolik', 'Pul o\'tkazishda xatolik: $e');
    }
  }

  // ==================== TO'LOVNI BEKOR QILISH ====================
  Future<void> cancelPayment(String paymentId) async {
    try {
      final success = await _paymentRepository.cancelPayment(paymentId);
      if (success) {
        Get.snackbar('Muvaffaqiyatli', 'To\'lov bekor qilindi');
        await loadAllData();
      } else {
        Get.snackbar('Xatolik', 'To\'lovni bekor qilishda xatolik');
      }
    } catch (e) {
      print('❌ Cancel payment error: $e');
      Get.snackbar('Xatolik', 'Xatolik yuz berdi');
    }
  }

  // ==================== MA'LUMOTLARNI YANGILASH ====================
  Future<void> refreshData() async {
    await loadAllData();
  }
}
