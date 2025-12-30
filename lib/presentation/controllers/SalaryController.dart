import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class SalaryController extends GetxController {
  final _supabase = Supabase.instance.client;

  // ==================== STATE VARIABLES ====================
  final RxString currentView =
      'list'.obs; // list, calculate, history, advances, loans
  final RxBool isLoading = false.obs;
  final RxBool isCalculating = false.obs;

  // Filters
  final RxList<Map<String, dynamic>> branches = <Map<String, dynamic>>[].obs;
  final RxnString selectedBranchId = RxnString();
  final RxInt selectedMonth = DateTime.now().month.obs;
  final RxInt selectedYear = DateTime.now().year.obs;

  // Data Lists
  final RxList<Map<String, dynamic>> salaryOperations =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> filteredOperations =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> cashRegisters =
      <Map<String, dynamic>>[].obs;

  // Hisoblash uchun
  final RxList<Map<String, dynamic>> staffList = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> calculationResults =
      <Map<String, dynamic>>[].obs;

  // Qo'shimcha
  final RxList<Map<String, dynamic>> advancesList =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> loansList = <Map<String, dynamic>>[].obs;

  // Statistika
  final RxDouble totalPaid = 0.0.obs;
  final RxDouble totalUnpaid = 0.0.obs;
  final RxDouble totalGross = 0.0.obs;
  final RxDouble totalDeductions = 0.0.obs;
  final RxInt paidCount = 0.obs;
  final RxInt unpaidCount = 0.obs;

  // Search
  final RxString searchQuery = ''.obs;
  final RxString selectedStatus = 'all'.obs;

  @override
  void onInit() {
    super.onInit();
    _initialLoad();
  }

  Future<void> _initialLoad() async {
    await loadBranches();
    if (selectedBranchId.value != null) {
      // Parallel yuklash (Tezroq ishlashi uchun)
      await Future.wait([
        loadSalaryOperations(),
        loadCashRegisters(),
        loadAdvances(),
        loadLoans(),
      ]);
    }
  }

  // ==================== 1. LOADERS (YUKLASH) ====================

  Future<void> loadBranches() async {
    try {
      final data = await _supabase
          .from('branches')
          .select('id, name')
          .eq('is_active', true)
          .order('name');
      branches.value = List<Map<String, dynamic>>.from(data);
      if (branches.isNotEmpty && selectedBranchId.value == null) {
        selectedBranchId.value = branches[0]['id'];
      }
    } catch (e) {
      _showError('Filiallar yuklanmadi: $e');
    }
  }

  Future<void> loadCashRegisters() async {
    if (selectedBranchId.value == null) return;
    try {
      final data = await _supabase
          .from('cash_register')
          .select('id, payment_method, current_balance')
          .eq('branch_id', selectedBranchId.value!);
      cashRegisters.value = List<Map<String, dynamic>>.from(
        data.map(
          (e) => {
            'id': e['id'],
            'name': _formatMethodName(e['payment_method']),
            'balance': e['current_balance'],
            'method': e['payment_method'],
          },
        ),
      );
    } catch (e) {
      print('Kassalar yuklashda xato: $e');
    }
  }

  Future<void> loadSalaryOperations() async {
    if (selectedBranchId.value == null) return;
    try {
      isLoading.value = true;
      final data = await _supabase
          .from('salary_operations')
          .select(
            '*, staff:staff_id(id, first_name, last_name, position, phone, photo_url, expected_hours_per_month)',
          )
          .eq('branch_id', selectedBranchId.value!)
          .eq('period_month', selectedMonth.value)
          .eq('period_year', selectedYear.value)
          .order('created_at', ascending: false);

      salaryOperations.value = List<Map<String, dynamic>>.from(data);
      _applyFilters();
      _calculateStats();
    } catch (e) {
      _showError('Maoshlar yuklanmadi: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadStaffForCalculation() async {
    if (selectedBranchId.value == null) return;
    try {
      isLoading.value = true;
      final data = await _supabase
          .from('staff')
          .select('*')
          .eq('branch_id', selectedBranchId.value!)
          .eq('status', 'active');
      staffList.value = List<Map<String, dynamic>>.from(data);
    } catch (e) {
      _showError('Xodimlar yuklanmadi');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadAdvances() async {
    if (selectedBranchId.value == null) return;
    try {
      final data = await _supabase
          .from('staff_advances')
          .select('*, staff:staff_id(first_name, last_name)')
          .eq('branch_id', selectedBranchId.value!)
          .order('created_at', ascending: false)
          .limit(50);
      advancesList.value = List<Map<String, dynamic>>.from(data);
    } catch (e) {
      print(e);
    }
  }

  Future<void> loadLoans() async {
    if (selectedBranchId.value == null) return;
    try {
      final data = await _supabase
          .from('staff_loans')
          .select('*, staff:staff_id(first_name, last_name)')
          .eq('branch_id', selectedBranchId.value!)
          .order('created_at', ascending: false)
          .limit(50);
      loansList.value = List<Map<String, dynamic>>.from(data);
    } catch (e) {
      print(e);
    }
  }

  // ==================== 2. CALCULATOR (HISOBLASH) ====================

  double _safeDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Future<void> calculateSalariesPreview() async {
    if (selectedBranchId.value == null) {
      _showError("Filial tanlanmagan");
      return;
    }

    try {
      isCalculating.value = true;
      calculationResults.clear();

      final staffData = await _supabase
          .from('staff')
          .select('*')
          .eq('branch_id', selectedBranchId.value!)
          .eq('status', 'active');

      final advancesData = await _supabase
          .from('staff_advances')
          .select()
          .eq('branch_id', selectedBranchId.value!)
          .eq('deduction_month', selectedMonth.value)
          .eq('deduction_year', selectedYear.value)
          .eq('is_deducted', false);

      final loansData = await _supabase
          .from('staff_loans')
          .select()
          .eq('branch_id', selectedBranchId.value!)
          .eq('is_settled', false)
          .or(
            'start_year.lt.${selectedYear.value},and(start_year.eq.${selectedYear.value},start_month.lte.${selectedMonth.value})',
          );

      final start = DateFormat(
        'yyyy-MM-dd',
      ).format(DateTime(selectedYear.value, selectedMonth.value, 1));
      final end = DateFormat(
        'yyyy-MM-dd',
      ).format(DateTime(selectedYear.value, selectedMonth.value + 1, 0));

      final attendanceData = await _supabase
          .from('attendance_staff')
          .select('staff_id, status, actual_hours')
          .eq('branch_id', selectedBranchId.value!)
          .gte('attendance_date', start)
          .lte('attendance_date', end);

      for (var staff in staffData) {
        String staffId = staff['id'];
        double baseAmount = 0;
        double workedHours = 0;
        int workedDays = 0;

        final myAttendance = attendanceData
            .where((a) => a['staff_id'] == staffId)
            .toList();
        workedDays = myAttendance.where((a) => a['status'] == 'present').length;
        for (var a in myAttendance)
          workedHours += _safeDouble(a['actual_hours']);

        String sType = (staff['salary_type'] ?? 'monthly')
            .toString()
            .toLowerCase();
        if (sType == 'hourly') {
          baseAmount = _safeDouble(staff['hourly_rate']) * workedHours;
        } else if (sType == 'daily') {
          baseAmount = _safeDouble(staff['daily_rate']) * workedDays;
        } else {
          baseAmount = _safeDouble(staff['base_salary']);
        }

        double advanceTotal = 0;
        final myAdvances = advancesData
            .where((a) => a['staff_id'] == staffId)
            .toList();
        for (var adv in myAdvances) advanceTotal += _safeDouble(adv['amount']);

        double loanDeduction = 0;
        final myLoans = loansData
            .where((l) => l['staff_id'] == staffId)
            .toList();
        for (var loan in myLoans)
          loanDeduction += _safeDouble(loan['monthly_deduction']);

        double gross = baseAmount;
        double net = gross - advanceTotal - loanDeduction;
        if (net < 0) net = 0;

        calculationResults.add({
          'staff_id': staffId,
          'staff': staff,
          'base_amount': baseAmount,
          'worked_days': workedDays,
          'worked_hours': workedHours,
          'advance_deduction': advanceTotal,
          'loan_deduction': loanDeduction,
          'gross_amount': gross,
          'net_amount': net,
          'advances_ids': myAdvances.map((e) => e['id']).toList(),
          'loans_ids': myLoans.map((e) => e['id']).toList(),
        });
      }
    } catch (e) {
      _showError('Hisoblashda xato: $e');
    } finally {
      isCalculating.value = false;
    }
  }

  Future<void> saveCalculatedSalaries() async {
    if (calculationResults.isEmpty) return;
    try {
      isLoading.value = true;
      final userId = _supabase.auth.currentUser?.id;

      for (var item in calculationResults) {
        final res = await _supabase
            .from('salary_operations')
            .insert({
              'branch_id': selectedBranchId.value,
              'staff_id': item['staff_id'],
              'operation_type': 'salary',
              'period_month': selectedMonth.value,
              'period_year': selectedYear.value,
              'base_amount': item['base_amount'],
              'worked_days': item['worked_days'],
              'worked_hours': item['worked_hours'],
              'advance_deduction': item['advance_deduction'],
              'loan_deduction': item['loan_deduction'],
              'gross_amount': item['gross_amount'],
              'net_amount': item['net_amount'],
              'is_paid': false,
              'calculated_by': userId,
            })
            .select('id')
            .single();

        String opId = res['id'];

        List advIds = item['advances_ids'];
        if (advIds.isNotEmpty) {
          await _supabase
              .from('staff_advances')
              .update({
                'is_deducted': true,
                'deducted_from_operation_id': opId,
                'deducted_at': DateTime.now().toIso8601String(),
              })
              .inFilter('id', advIds);
        }

        List loanIds = item['loans_ids'];
        for (var loanId in loanIds) {
          await _supabase.from('staff_loan_payments').insert({
            'loan_id': loanId,
            'salary_operation_id': opId,
            'amount': item['loan_deduction'],
            'payment_month': selectedMonth.value,
            'payment_year': selectedYear.value,
          });

          final loan = await _supabase
              .from('staff_loans')
              .select('remaining_amount')
              .eq('id', loanId)
              .single();
          double newRem =
              _safeDouble(loan['remaining_amount']) -
              (item['loan_deduction'] as num).toDouble();

          await _supabase
              .from('staff_loans')
              .update({
                'remaining_amount': newRem,
                'is_settled': newRem <= 0,
                'settled_at': newRem <= 0
                    ? DateTime.now().toIso8601String()
                    : null,
              })
              .eq('id', loanId);
        }
      }

      calculationResults.clear();
      loadSalaryOperations();
      currentView.value = 'list';
      _showSuccess('Maoshlar muvaffaqiyatli saqlandi!');
    } catch (e) {
      _showError('Saqlashda xato: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ==================== 3. ACTIONS (TO'LOV, AVANS, QARZ) ====================

  Future<void> paySalary({
    required String operationId,
    required double amount,
    required String sourceId,
    required String sourceName,
  }) async {
    try {
      isLoading.value = true;
      final userId = _supabase.auth.currentUser?.id;

      await _supabase
          .from('salary_operations')
          .update({
            'is_paid': true,
            'paid_at': DateTime.now().toIso8601String(),
            'paid_by': userId,
            'payment_source': sourceName,
            'payment_source_id': sourceId == 'manager' ? null : sourceId,
            'notes': 'To\'landi: $sourceName',
          })
          .eq('id', operationId);

      final op = await _supabase
          .from('salary_operations')
          .select('staff_id, staff:staff_id(first_name, last_name)')
          .eq('id', operationId)
          .single();
      final staffName =
          '${op['staff']['first_name']} ${op['staff']['last_name']}';

      final expenseRes = await _supabase
          .from('expenses')
          .insert({
            'branch_id': selectedBranchId.value,
            'category': 'salary',
            'sub_category': 'monthly_salary',
            'title': 'Maosh: $staffName',
            'amount': amount,
            'salary_operation_id': operationId,
            'staff_id': op['staff_id'],
            'recorded_by': userId,
          })
          .select('id')
          .single();

      if (sourceId != 'manager') {
        await _processTransaction(
          amount: amount,
          sourceId: sourceId,
          type: 'expense',
          expenseId: expenseRes['id'],
          salaryOpId: operationId,
          description: 'Maosh to\'landi: $staffName',
        );
      }

      await loadSalaryOperations();
      await loadCashRegisters();
      _showSuccess('To\'landi!');
    } catch (e) {
      _showError('To\'lovda xatolik: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> giveAdvance({
    required String staffId,
    required double amount,
    required int deductionMonth,
    required int deductionYear,
    required String sourceId,
    required String sourceName,
    String? comment,
  }) async {
    try {
      isLoading.value = true;
      final userId = _supabase.auth.currentUser?.id;

      await _supabase.from('staff_advances').insert({
        'branch_id': selectedBranchId.value,
        'staff_id': staffId,
        'amount': amount,
        'deduction_month': deductionMonth,
        'deduction_year': deductionYear,
        'is_deducted': false,
        'reason': comment,
        'given_by': userId,
      });

      final expenseRes = await _supabase
          .from('expenses')
          .insert({
            'branch_id': selectedBranchId.value,
            'category': 'salary',
            'sub_category': 'advance',
            'title': 'Avans berildi',
            'amount': amount,
            'staff_id': staffId,
            'recorded_by': userId,
          })
          .select('id')
          .single();

      if (sourceId != 'manager') {
        await _processTransaction(
          amount: amount,
          sourceId: sourceId,
          type: 'expense',
          expenseId: expenseRes['id'],
          description: 'Avans berildi',
        );
      }
      _showSuccess('Avans berildi');
      loadAdvances();
      loadCashRegisters();
    } catch (e) {
      _showError('Xato: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> giveLoan({
    required String staffId,
    required double totalAmount,
    required double monthlyDeduction,
    required int startMonth,
    required int startYear,
    required String sourceId,
    String? reason,
  }) async {
    try {
      isLoading.value = true;
      final userId = _supabase.auth.currentUser?.id;

      await _supabase.from('staff_loans').insert({
        'branch_id': selectedBranchId.value,
        'staff_id': staffId,
        'total_amount': totalAmount,
        'remaining_amount': totalAmount,
        'monthly_deduction': monthlyDeduction,
        'start_month': startMonth,
        'start_year': startYear,
        'is_settled': false,
        'reason': reason,
        'given_by': userId,
      });

      final expenseRes = await _supabase
          .from('expenses')
          .insert({
            'branch_id': selectedBranchId.value,
            'category': 'operational_expense',
            'sub_category': 'loan',
            'title': 'Qarz berildi',
            'amount': totalAmount,
            'staff_id': staffId,
            'recorded_by': userId,
          })
          .select('id')
          .single();

      if (sourceId != 'manager') {
        await _processTransaction(
          amount: totalAmount,
          sourceId: sourceId,
          type: 'expense',
          expenseId: expenseRes['id'],
          description: 'Qarz (Kredit)',
        );
      }
      _showSuccess('Qarz berildi');
      loadLoans();
      loadCashRegisters();
    } catch (e) {
      _showError('Xato: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> cancelPayment(String operationId) async {
    try {
      isLoading.value = true;
      final expense = await _supabase
          .from('expenses')
          .select()
          .eq('salary_operation_id', operationId)
          .maybeSingle();
      if (expense != null) {
        final transaction = await _supabase
            .from('cash_transactions')
            .select()
            .eq('salary_operation_id', operationId)
            .eq('transaction_type', 'expense')
            .maybeSingle();
        if (transaction != null) {
          await _processTransaction(
            amount: _safeDouble(transaction['amount']),
            sourceId: transaction['cash_register_id'],
            type: 'income',
            description: 'Refund: Maosh bekor qilindi',
          );
        }
        await _supabase.from('expenses').delete().eq('id', expense['id']);
      }
      await _supabase
          .from('salary_operations')
          .update({
            'is_paid': false,
            'paid_at': null,
            'paid_by': null,
            'payment_source': null,
          })
          .eq('id', operationId);
      await loadSalaryOperations();
      await loadCashRegisters();
      _showSuccess('Bekor qilindi');
    } catch (e) {
      _showError('Xato: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateSalary({
    required String operationId,
    required double baseAmount,
    required double bonusAmount,
    required double penaltyAmount,
    String? notes,
  }) async {
    try {
      isLoading.value = true;
      final op = salaryOperations.firstWhere((e) => e['id'] == operationId);
      double advance = _safeDouble(op['advance_deduction']);
      double loan = _safeDouble(op['loan_deduction']);
      double gross = baseAmount + bonusAmount - penaltyAmount;
      double net = gross - advance - loan;
      if (net < 0) net = 0;

      await _supabase
          .from('salary_operations')
          .update({
            'base_amount': baseAmount,
            'bonus_amount': bonusAmount,
            'penalty_amount': penaltyAmount,
            'gross_amount': gross,
            'net_amount': net,
            'notes': notes,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', operationId);

      await loadSalaryOperations();
      _showSuccess('O\'zgartirildi');
    } catch (e) {
      _showError('Xato: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _processTransaction({
    required double amount,
    required String sourceId,
    required String type,
    String? expenseId,
    String? salaryOpId,
    required String description,
  }) async {
    final kassa = await _supabase
        .from('cash_register')
        .select('current_balance, payment_method')
        .eq('id', sourceId)
        .single();
    double current = _safeDouble(kassa['current_balance']);
    double newB = type == 'income' ? current + amount : current - amount;
    if (newB < 0 && type == 'expense') throw "Kassada mablag' yetarli emas!";

    await _supabase
        .from('cash_register')
        .update({'current_balance': newB})
        .eq('id', sourceId);
    await _supabase.from('cash_transactions').insert({
      'branch_id': selectedBranchId.value,
      'cash_register_id': sourceId,
      'transaction_type': type,
      'payment_method': kassa['payment_method'],
      'amount': amount,
      'balance_before': current,
      'balance_after': newB,
      'description': description,
      'expense_id': expenseId,
      'salary_operation_id': salaryOpId,
      'performed_by': _supabase.auth.currentUser?.id,
    });
  }

  // ==================== 4. HELPERS ====================

  void _applyFilters() {
    var list = salaryOperations.toList();
    if (selectedStatus.value == 'paid')
      list = list.where((op) => op['is_paid'] == true).toList();
    else if (selectedStatus.value == 'unpaid')
      list = list.where((op) => op['is_paid'] == false).toList();

    if (searchQuery.value.isNotEmpty) {
      final q = searchQuery.value.toLowerCase();
      list = list
          .where(
            (op) =>
                op['staff']['first_name'].toString().toLowerCase().contains(
                  q,
                ) ||
                op['staff']['last_name'].toString().toLowerCase().contains(q),
          )
          .toList();
    }
    filteredOperations.value = list;
  }

  void _calculateStats() {
    double p = 0, u = 0, g = 0, d = 0;
    int pc = 0, uc = 0;
    for (var op in salaryOperations) {
      double net = _safeDouble(op['net_amount']);
      double gr = _safeDouble(op['gross_amount']);
      double ded =
          _safeDouble(op['advance_deduction']) +
          _safeDouble(op['loan_deduction']) +
          _safeDouble(op['penalty_amount']);
      g += gr;
      d += ded;
      if (op['is_paid'] == true) {
        p += net;
        pc++;
      } else {
        u += net;
        uc++;
      }
    }
    totalPaid.value = p;
    totalUnpaid.value = u;
    totalGross.value = g;
    totalDeductions.value = d;
    paidCount.value = pc;
    unpaidCount.value = uc;
  }

  void search(String q) {
    searchQuery.value = q;
    _applyFilters();
  }

  void changeStatusFilter(String s) {
    selectedStatus.value = s;
    _applyFilters();
  }

  void changeBranch(String? id) {
    if (id != null) {
      selectedBranchId.value = id;
      _initialLoad();
    }
  }

  void changePeriod(int m, int y) {
    selectedMonth.value = m;
    selectedYear.value = y;
    loadSalaryOperations();
  }

  void changeView(String v) {
    currentView.value = v;
    if (v == 'calculate' && staffList.isEmpty) loadStaffForCalculation();
    if (v == 'advances') loadAdvances();
    if (v == 'loans') loadLoans();
  }

  String getPeriodString() {
    final m = [
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
    return '${m[selectedMonth.value - 1]} ${selectedYear.value}';
  }

  String formatCurrency(double v) => NumberFormat.currency(
    locale: 'uz_UZ',
    symbol: 'so\'m',
    decimalDigits: 0,
  ).format(v);
  String _formatMethodName(String m) =>
      {'cash': 'Naqd', 'card': 'Plastik', 'click': 'Click'}[m] ??
      m.toUpperCase();
  void _showError(String m) => Get.snackbar(
    'Xatolik',
    m,
    backgroundColor: Colors.red.shade100,
    colorText: Colors.red[900],
  );
  void _showSuccess(String m) => Get.snackbar(
    'OK',
    m,
    backgroundColor: Colors.green.shade100,
    colorText: Colors.green[900],
  );
}
