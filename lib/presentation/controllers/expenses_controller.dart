// lib/presentation/controllers/expenses_controller_v2.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class ExpensesControllerV2 extends GetxController {
  final _supabase = Supabase.instance.client;
  
  final isLoading = false.obs;
  final selectedTab = 0.obs;
  final expenses = <Map<String, dynamic>>[].obs;
  final salaryOperations = <Map<String, dynamic>>[].obs;
  final staffAdvances = <Map<String, dynamic>>[].obs;
  final staffLoans = <Map<String, dynamic>>[].obs;
  final cashRegisters = <Map<String, dynamic>>[].obs;
  final staffList = <Map<String, dynamic>>[].obs;
  final branches = <Map<String, dynamic>>[].obs;
  
  final selectedCategory = 'all'.obs;
  final selectedCashRegister = 'all'.obs;
  final selectedBranch = 'all'.obs;
  final searchQuery = ''.obs;
  final startDate = Rx<DateTime?>(null);
  final endDate = Rx<DateTime?>(null);
  
  final currentPage = 1.obs;
  final itemsPerPage = 20;
  final hasMore = true.obs;
  
  final totalExpenses = 0.0.obs;
  final totalSalaries = 0.0.obs;
  final totalAdvances = 0.0.obs;
  final totalLoans = 0.0.obs;
  final todayExpenses = 0.0.obs;
  final monthExpenses = 0.0.obs;
  final weekExpenses = 0.0.obs;
  final yearExpenses = 0.0.obs;
  
  final totalCashBalance = 0.0.obs;
  final totalCardBalance = 0.0.obs;
  final totalTransferBalance = 0.0.obs;
  
  final categories = [
    {'id': 'all', 'name': 'Barchasi', 'icon': Icons.all_inclusive, 'color': Colors.blue},
    {'id': 'salary', 'name': 'Xodimlar maoshi', 'icon': Icons.payments, 'color': Colors.green},
    {'id': 'utilities', 'name': 'Kommunal xizmatlar', 'icon': Icons.bolt, 'color': Colors.orange},
    {'id': 'supplies', 'name': 'Jihozlar va ta\'minot', 'icon': Icons.inventory_2, 'color': Colors.purple},
    {'id': 'maintenance', 'name': 'Ta\'mirlash', 'icon': Icons.build, 'color': Colors.red},
    {'id': 'marketing', 'name': 'Marketing va reklama', 'icon': Icons.campaign, 'color': Colors.pink},
    {'id': 'rent', 'name': 'Ijara to\'lovi', 'icon': Icons.home, 'color': Colors.brown},
    {'id': 'transport', 'name': 'Transport', 'icon': Icons.local_shipping, 'color': Colors.teal},
    {'id': 'food', 'name': 'Oziq-ovqat', 'icon': Icons.restaurant, 'color': Colors.deepOrange},
    {'id': 'education', 'name': 'Ta\'lim materiallari', 'icon': Icons.school, 'color': Colors.indigo},
    {'id': 'tax', 'name': 'Soliqlar', 'icon': Icons.account_balance, 'color': Colors.blueGrey},
    {'id': 'insurance', 'name': 'Sug\'urta', 'icon': Icons.health_and_safety, 'color': Colors.cyan},
    {'id': 'other', 'name': 'Boshqa', 'icon': Icons.more_horiz, 'color': Colors.grey},
  ].obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    try {
      await Future.wait([
        loadExpenses(),
        loadSalaryOperations(),
        loadStaffAdvances(),
        loadStaffLoans(),
        loadCashRegisters(),
        loadStaffList(),
        loadBranches(),
        calculateStatistics(),
      ]);
    } catch (e) {
      Get.snackbar(
        'Xato', 
        'Ma\'lumotlarni yuklashda xatolik: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadExpenses() async {
    try {
      var query = _supabase
          .from('expenses')
          .select('''
            *,
            branches(name),
            staff(first_name, last_name),
            users:recorded_by(first_name, last_name)
          ''');

      if (selectedCategory.value != 'all') {
        query = query.eq('category', selectedCategory.value);
      }
      
      if (selectedBranch.value != 'all') {
        query = query.eq('branch_id', selectedBranch.value);
      }
      
      if (searchQuery.value.isNotEmpty) {
        query = query.or('title.ilike.%${searchQuery.value}%,description.ilike.%${searchQuery.value}%');
      }
      
      if (startDate.value != null) {
        query = query.gte('expense_date', DateFormat('yyyy-MM-dd').format(startDate.value!));
      }
      
      if (endDate.value != null) {
        query = query.lte('expense_date', DateFormat('yyyy-MM-dd').format(endDate.value!));
      }

      final response = await query
          .order('expense_date', ascending: false)
          .order('expense_time', ascending: false)
          .limit(itemsPerPage * currentPage.value);
      
      expenses.value = List<Map<String, dynamic>>.from(response);
      hasMore.value = response.length >= itemsPerPage * currentPage.value;
    } catch (e) {
      print('Xarajatlarni yuklashda xato: $e');
    }
  }

  Future<void> loadSalaryOperations() async {
    try {
      var query = _supabase
          .from('salary_operations')
          .select('''
            *,
            staff(id, first_name, last_name, position, salary_type, base_salary, hourly_rate, daily_rate),
            branches(name),
            users:calculated_by(first_name, last_name),
            paid_user:paid_by(first_name, last_name)
          ''');

      if (selectedBranch.value != 'all') {
        query = query.eq('branch_id', selectedBranch.value);
      }

      final response = await query.order('created_at', ascending: false);
      salaryOperations.value = List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Maosh ma\'lumotlarini yuklashda xato: $e');
    }
  }

  Future<void> loadStaffAdvances() async {
    try {
      var query = _supabase
          .from('staff_advances')
          .select('''
            *,
            staff(first_name, last_name, position),
            branches(name),
            users:given_by(first_name, last_name)
          ''');

      if (selectedBranch.value != 'all') {
        query = query.eq('branch_id', selectedBranch.value);
      }

      final response = await query.order('advance_date', ascending: false);
      staffAdvances.value = List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Avanslarni yuklashda xato: $e');
    }
  }

  Future<void> loadStaffLoans() async {
    try {
      var query = _supabase
          .from('staff_loans')
          .select('''
            *,
            staff(first_name, last_name, position),
            branches(name),
            users:given_by(first_name, last_name)
          ''');

      if (selectedBranch.value != 'all') {
        query = query.eq('branch_id', selectedBranch.value);
      }

      final response = await query.order('loan_date', ascending: false);
      staffLoans.value = List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Qarzlarni yuklashda xato: $e');
    }
  }

  Future<void> loadCashRegisters() async {
    try {
      var query = _supabase
          .from('cash_register')
          .select('*, branches(name)');

      if (selectedBranch.value != 'all') {
        query = query.eq('branch_id', selectedBranch.value);
      }

      final response = await query.order('current_balance', ascending: false);
      cashRegisters.value = List<Map<String, dynamic>>.from(response);
      
      totalCashBalance.value = cashRegisters
          .where((c) => c['payment_method'] == 'cash')
          .fold(0.0, (sum, item) => sum + ((item['current_balance'] ?? 0.0) as num).toDouble());
      
      totalCardBalance.value = cashRegisters
          .where((c) => c['payment_method'] == 'card')
          .fold(0.0, (sum, item) => sum + ((item['current_balance'] ?? 0.0) as num).toDouble());
      
      totalTransferBalance.value = cashRegisters
          .where((c) => c['payment_method'] == 'transfer')
          .fold(0.0, (sum, item) => sum + ((item['current_balance'] ?? 0.0) as num).toDouble());
    } catch (e) {
      print('Kassalarni yuklashda xato: $e');
    }
  }

  Future<void> loadStaffList() async {
    try {
      final response = await _supabase
          .from('staff')
          .select('id, first_name, last_name, position, salary_type, base_salary, hourly_rate, daily_rate, status, branch_id')
          .eq('status', 'active')
          .order('last_name');
      
      staffList.value = List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Xodimlar ro\'yxatini yuklashda xato: $e');
    }
  }

  Future<void> loadBranches() async {
    try {
      final response = await _supabase
          .from('branches')
          .select('id, name')
          .order('name');
      
      branches.value = List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Filiallarni yuklashda xato: $e');
    }
  }

  Future<void> calculateStatistics() async {
    try {
      final today = DateTime.now();
      final todayStr = DateFormat('yyyy-MM-dd').format(today);
      
      var todayQuery = _supabase.from('expenses').select('amount').eq('expense_date', todayStr);
      if (selectedBranch.value != 'all') todayQuery = todayQuery.eq('branch_id', selectedBranch.value);
      final todayData = await todayQuery;
      todayExpenses.value = todayData.fold(0.0, (sum, item) => sum + ((item['amount'] ?? 0.0) as num).toDouble());
      
      final weekStart = today.subtract(Duration(days: today.weekday - 1));
      var weekQuery = _supabase.from('expenses').select('amount').gte('expense_date', DateFormat('yyyy-MM-dd').format(weekStart));
      if (selectedBranch.value != 'all') weekQuery = weekQuery.eq('branch_id', selectedBranch.value);
      final weekData = await weekQuery;
      weekExpenses.value = weekData.fold(0.0, (sum, item) => sum + ((item['amount'] ?? 0.0) as num).toDouble());
      
      final monthStart = DateTime(today.year, today.month, 1);
      final monthEnd = DateTime(today.year, today.month + 1, 0);
      var monthQuery = _supabase.from('expenses').select('amount')
          .gte('expense_date', DateFormat('yyyy-MM-dd').format(monthStart))
          .lte('expense_date', DateFormat('yyyy-MM-dd').format(monthEnd));
      if (selectedBranch.value != 'all') monthQuery = monthQuery.eq('branch_id', selectedBranch.value);
      final monthData = await monthQuery;
      monthExpenses.value = monthData.fold(0.0, (sum, item) => sum + ((item['amount'] ?? 0.0) as num).toDouble());
      
      final yearStart = DateTime(today.year, 1, 1);
      var yearQuery = _supabase.from('expenses').select('amount').gte('expense_date', DateFormat('yyyy-MM-dd').format(yearStart));
      if (selectedBranch.value != 'all') yearQuery = yearQuery.eq('branch_id', selectedBranch.value);
      final yearData = await yearQuery;
      yearExpenses.value = yearData.fold(0.0, (sum, item) => sum + ((item['amount'] ?? 0.0) as num).toDouble());
      
      totalExpenses.value = expenses.fold(0.0, (sum, item) => sum + ((item['amount'] ?? 0.0) as num).toDouble());
      totalSalaries.value = salaryOperations.fold(0.0, (sum, item) => sum + ((item['net_amount'] ?? 0.0) as num).toDouble());
      totalAdvances.value = staffAdvances.where((a) => a['is_deducted'] != true).fold(0.0, (sum, item) => sum + ((item['amount'] ?? 0.0) as num).toDouble());
      totalLoans.value = staffLoans.where((l) => l['is_settled'] != true).fold(0.0, (sum, item) => sum + ((item['remaining_amount'] ?? 0.0) as num).toDouble());
    } catch (e) {
      print('Statistika hisoblashda xato: $e');
    }
  }

  Future<void> addExpense({
    required String category,
    required String title,
    required double amount,
    required String cashRegisterId,
    String? description,
    String? receiptNumber,
    String? responsiblePerson,
    DateTime? expenseDate,
  }) async {
    try {
      isLoading.value = true;
      
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('Foydalanuvchi topilmadi');

      final userInfo = await _supabase.from('users').select('branch_id').eq('id', userId).single();
      final branchId = userInfo['branch_id'];
      
      final cashRegister = await _supabase.from('cash_register')
          .select('current_balance, payment_method, branches(name)')
          .eq('id', cashRegisterId).single();
      
      final currentBalance = (cashRegister['current_balance'] as num).toDouble();
      
      if (currentBalance < amount) {
        Get.snackbar('Xato', 'Kassada yetarli mablag\' yo\'q!\nMavjud: ${formatCurrency(currentBalance)} so\'m',
          backgroundColor: Colors.red, colorText: Colors.white, duration: Duration(seconds: 4));
        return;
      }
      
      final expenseData = {
        'branch_id': branchId,
        'category': category,
        'sub_category': '',
        'title': title,
        'description': description,
        'amount': amount,
        'expense_date': DateFormat('yyyy-MM-dd').format(expenseDate ?? DateTime.now()),
        'expense_time': DateFormat('HH:mm:ss').format(DateTime.now()),
        'responsible_person': responsiblePerson,
        'receipt_number': receiptNumber,
        'recorded_by': userId,
      };

      await _supabase.from('expenses').insert(expenseData);
      await _supabase.from('cash_register').update({
        'current_balance': currentBalance - amount,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', cashRegisterId);
      
      Get.snackbar('Muvaffaqiyat', 'Xarajat muvaffaqiyatli qo\'shildi',
        backgroundColor: Colors.green, colorText: Colors.white);
      
      await loadData();
    } catch (e) {
      Get.snackbar('Xato', 'Xarajat qo\'shishda xatolik: $e',
        backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteExpense(String expenseId) async {
    try {
      isLoading.value = true;
      
      final expense = await _supabase.from('expenses')
          .select('*, cash_register:cash_register_id(*)')
          .eq('id', expenseId).single();
      
      if (expense['cash_register_id'] != null) {
        final cashRegister = await _supabase.from('cash_register')
            .select('current_balance').eq('id', expense['cash_register_id']).single();
        
        final currentBalance = (cashRegister['current_balance'] as num).toDouble();
        final expenseAmount = (expense['amount'] as num).toDouble();
        
        await _supabase.from('cash_register').update({
          'current_balance': currentBalance + expenseAmount,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', expense['cash_register_id']);
      }
      
      await _supabase.from('expenses').delete().eq('id', expenseId);
      Get.snackbar('Muvaffaqiyat', 'Xarajat o\'chirildi',
        backgroundColor: Colors.green, colorText: Colors.white);
      
      await loadData();
    } catch (e) {
      Get.snackbar('Xato', 'Xarajatni o\'chirishda xatolik: $e',
        backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  // ==================== MAOSH TO'LASH ====================
  
  Future<void> paySalary(Map<String, dynamic> salaryData) async {
    try {
      isLoading.value = true;

      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('Foydalanuvchi topilmadi');

      // Insert salary operation
      final salaryResult = await _supabase
          .from('salary_operations')
          .insert(salaryData)
          .select()
          .single();

      // Update cash register
      final cashRegisterId = salaryData['cash_register_id'];
      if (cashRegisterId != null) {
        final cashRegister = await _supabase
            .from('cash_register')
            .select('current_balance')
            .eq('id', cashRegisterId)
            .single();

        final currentBalance = (cashRegister['current_balance'] as num).toDouble();
        final netAmount = (salaryData['net_amount'] as num).toDouble();

        await _supabase.from('cash_register').update({
          'current_balance': currentBalance - netAmount,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', cashRegisterId);
      }

      // Mark advances as deducted
      if (salaryData['advance_deduction'] > 0) {
        await _supabase
            .from('staff_advances')
            .update({
              'is_deducted': true,
              'deducted_at': DateTime.now().toIso8601String(),
              'deducted_from_operation_id': salaryResult['id'],
            })
            .eq('staff_id', salaryData['staff_id'])
            .eq('deduction_month', salaryData['period_month'])
            .eq('deduction_year', salaryData['period_year'])
            .eq('is_deducted', false);
      }

      // Update loan payments
      if (salaryData['loan_deduction'] > 0) {
        final loans = await _supabase
            .from('staff_loans')
            .select('id, monthly_deduction, remaining_amount')
            .eq('staff_id', salaryData['staff_id'])
            .eq('is_settled', false);

        for (var loan in loans) {
          final monthlyDeduction = (loan['monthly_deduction'] as num).toDouble();

          await _supabase.from('staff_loan_payments').insert({
            'loan_id': loan['id'],
            'salary_operation_id': salaryResult['id'],
            'amount': monthlyDeduction,
            'payment_month': salaryData['period_month'],
            'payment_year': salaryData['period_year'],
            'payment_date': DateTime.now().toIso8601String(),
          });

          final remainingAmount = (loan['remaining_amount'] as num).toDouble();
          final newRemaining = (remainingAmount - monthlyDeduction).clamp(0.0, double.infinity);

          await _supabase.from('staff_loans').update({
            'remaining_amount': newRemaining,
            'is_settled': newRemaining <= 0,
            'settled_at': newRemaining <= 0 ? DateTime.now().toIso8601String() : null,
          }).eq('id', loan['id']);
        }
      }

      Get.snackbar(
        'Muvaffaqiyat',
        'Maosh muvaffaqiyatli to\'landi!\nSof maosh: ${formatCurrency(salaryData['net_amount'])} so\'m',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );

      await loadData();
    } catch (e) {
      Get.snackbar('Xato', 'Maosh to\'lashda xatolik: $e',
        backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  // ==================== AVANS BERISH ====================
  
  Future<void> giveAdvance(Map<String, dynamic> advanceData) async {
    try {
      isLoading.value = true;

      final cashRegisterId = advanceData['cash_register_id'];
      final amount = (advanceData['amount'] as num).toDouble();

      // Check cash register balance
      final cashRegister = await _supabase
          .from('cash_register')
          .select('current_balance, payment_method')
          .eq('id', cashRegisterId)
          .single();

      final currentBalance = (cashRegister['current_balance'] as num).toDouble();

      if (currentBalance < amount) {
        Get.snackbar(
          'Xato',
          'Kassada yetarli mablag\' yo\'q!\nMavjud: ${formatCurrency(currentBalance)} so\'m',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Insert advance
      await _supabase.from('staff_advances').insert(advanceData);

      // Update cash register
      await _supabase.from('cash_register').update({
        'current_balance': currentBalance - amount,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', cashRegisterId);

      final staff = await _supabase
          .from('staff')
          .select('first_name, last_name')
          .eq('id', advanceData['staff_id'])
          .single();

      Get.snackbar(
        'Muvaffaqiyat',
        'Avans muvaffaqiyatli berildi!\n${staff['first_name']} ${staff['last_name']}\nSumma: ${formatCurrency(amount)} so\'m',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );

      await loadData();
    } catch (e) {
      Get.snackbar('Xato', 'Avans berishda xatolik: $e',
        backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  // ==================== QARZ BERISH ====================
  
  Future<void> giveLoan(Map<String, dynamic> loanData) async {
    try {
      isLoading.value = true;

      final cashRegisterId = loanData['cash_register_id'];
      final amount = (loanData['total_amount'] as num).toDouble();

      // Check cash register balance
      final cashRegister = await _supabase
          .from('cash_register')
          .select('current_balance, payment_method')
          .eq('id', cashRegisterId)
          .single();

      final currentBalance = (cashRegister['current_balance'] as num).toDouble();

      if (currentBalance < amount) {
        Get.snackbar(
          'Xato',
          'Kassada yetarli mablag\' yo\'q!\nMavjud: ${formatCurrency(currentBalance)} so\'m',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Insert loan
      await _supabase.from('staff_loans').insert(loanData);

      // Update cash register
      await _supabase.from('cash_register').update({
        'current_balance': currentBalance - amount,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', cashRegisterId);

      final staff = await _supabase
          .from('staff')
          .select('first_name, last_name')
          .eq('id', loanData['staff_id'])
          .single();

      Get.snackbar(
        'Muvaffaqiyat',
        'Qarz muvaffaqiyatli berildi!\n${staff['first_name']} ${staff['last_name']}\nSumma: ${formatCurrency(amount)} so\'m',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );

      await loadData();
    } catch (e) {
      Get.snackbar('Xato', 'Qarz berishda xatolik: $e',
        backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  void applyFilters() {
    currentPage.value = 1;
    loadData();
  }

  void clearFilters() {
    selectedCategory.value = 'all';
    selectedCashRegister.value = 'all';
    selectedBranch.value = 'all';
    searchQuery.value = '';
    startDate.value = null;
    endDate.value = null;
    applyFilters();
  }

  String formatCurrency(double amount) => NumberFormat('#,###').format(amount);
  String formatDate(DateTime date) => DateFormat('dd.MM.yyyy').format(date);
  String formatDateTime(DateTime date) => DateFormat('dd.MM.yyyy HH:mm').format(date);

  Color getCategoryColor(String category) {
    final cat = categories.firstWhere((c) => c['id'] == category, orElse: () => categories.last);
    return cat['color'] as Color;
  }

  IconData getCategoryIcon(String category) {
    final cat = categories.firstWhere((c) => c['id'] == category, orElse: () => categories.last);
    return cat['icon'] as IconData;
  }

  String getCategoryName(String categoryId) {
    final cat = categories.firstWhere((c) => c['id'] == categoryId, orElse: () => categories.last);
    return cat['name'] as String;
  }

  Future<void> refresh() async => await loadData();
}