// lib/presentation/controllers/complete_salary_controller.dart
// TO'LIQ MAOSH BOSHQARUVI CONTROLLER - Barcha xatolar tuzatilgan

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';

class CompleteSalaryController extends GetxController {
  final _supabase = Supabase.instance.client;

  // UMUMIY STATE
  final currentView = 'list'.obs; // 'list', 'calculate', 'history', 'advances', 'loans'
  final isLoading = false.obs;
  
  // FILIAL VA DAVR
  final branches = <Map<String, dynamic>>[].obs;
  final selectedBranchId = Rxn<String>();
  final selectedMonth = DateTime.now().month.obs;
  final selectedYear = DateTime.now().year.obs;

  // MAOSH RO'YXATI
  final salaryOperations = <Map<String, dynamic>>[].obs;
  final filteredOperations = <Map<String, dynamic>>[].obs;
  final selectedStatus = 'all'.obs; // 'all', 'paid', 'unpaid'
  final searchQuery = ''.obs;

  // STATISTIKA
  final totalPaid = 0.0.obs;
  final totalUnpaid = 0.0.obs;
  final paidCount = 0.obs;
  final unpaidCount = 0.obs;
  final totalGross = 0.0.obs;
  final totalDeductions = 0.0.obs;

  // HISOBLASH UCHUN
  final staffList = <Map<String, dynamic>>[].obs;
  final selectedStaffIds = <String>[].obs;
  final calculationResults = <Map<String, dynamic>>[].obs;
  final isCalculating = false.obs;

  // AVANS VA QARZ
  final advancesList = <Map<String, dynamic>>[].obs;
  final loansList = <Map<String, dynamic>>[].obs;
  final advancesData = <String, List<Map<String, dynamic>>>{}.obs;
  final loansData = <String, List<Map<String, dynamic>>>{}.obs;
  final attendanceData = <String, Map<String, dynamic>>{}.obs;

  // TARIXI
  final salaryHistory = <Map<String, dynamic>>[].obs;
  final historyStartDate = DateTime.now().subtract(Duration(days: 365)).obs;
  final historyEndDate = DateTime.now().obs;

  @override
  void onInit() {
    super.onInit();
    _initialize();
  }

  // BOSHLANG'ICH SOZLASH
  Future<void> _initialize() async {
    await loadBranches();
    if (selectedBranchId.value != null) {
      await loadSalaryOperations();
    }
  }

  // FILIALLARNI YUKLASH
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

  // MAOSH OPERATSIYALARINI YUKLASH - XATO TUZATILGAN
  Future<void> loadSalaryOperations() async {
    if (selectedBranchId.value == null) {
      salaryOperations.clear();
      filteredOperations.clear();
      return;
    }

    try {
      isLoading.value = true;

      // To'g'ri usul - alohida query yaratish
      final data = await _supabase
          .from('salary_operations')
          .select('''
            *,
            staff:staff_id(
              id, first_name, last_name, position,
              salary_type, photo_url
            )
          ''')
          .eq('branch_id', selectedBranchId.value!)
          .eq('period_month', selectedMonth.value)
          .eq('period_year', selectedYear.value)
          .order('created_at', ascending: false);

      salaryOperations.value = List<Map<String, dynamic>>.from(data);
      
      _applyFilters();
      _calculateStatistics();

    } catch (e) {
      _showError('Maosh ma\'lumotlari yuklanmadi: $e');
      salaryOperations.clear();
      filteredOperations.clear();
    } finally {
      isLoading.value = false;
    }
  }

  // FILTRLARNI QO'LLASH
  void _applyFilters() {
    var filtered = salaryOperations.toList();

    // Status filtri
    if (selectedStatus.value != 'all') {
      filtered = filtered.where((op) {
        if (selectedStatus.value == 'paid') {
          return op['is_paid'] == true;
        } else {
          return op['is_paid'] == false;
        }
      }).toList();
    }

    // Qidiruv
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filtered = filtered.where((op) {
        final staff = op['staff'];
        if (staff == null) return false;
        
        final name = '${staff['first_name'] ?? ''} ${staff['last_name'] ?? ''}'.toLowerCase();
        final position = (staff['position'] ?? '').toLowerCase();
        return name.contains(query) || position.contains(query);
      }).toList();
    }

    filteredOperations.value = filtered;
  }

  // STATISTIKANI HISOBLASH
  void _calculateStatistics() {
    totalPaid.value = 0;
    totalUnpaid.value = 0;
    totalGross.value = 0;
    totalDeductions.value = 0;
    paidCount.value = 0;
    unpaidCount.value = 0;

    for (var op in salaryOperations) {
      final net = (op['net_amount'] ?? 0).toDouble();
      final gross = (op['gross_amount'] ?? 0).toDouble();
      
      totalGross.value += gross;
      
      if (op['is_paid'] == true) {
        totalPaid.value += net;
        paidCount.value++;
      } else {
        totalUnpaid.value += net;
        unpaidCount.value++;
      }
    }
    
    totalDeductions.value = totalGross.value - (totalPaid.value + totalUnpaid.value);
  }

  // HODIMLARNI YUKLASH (HISOBLASH UCHUN)
  Future<void> loadStaffForCalculation() async {
    if (selectedBranchId.value == null) {
      _showError('Filialni tanlang');
      return;
    }

    try {
      isLoading.value = true;

      final data = await _supabase
          .from('staff')
          .select('''
            id, first_name, last_name, position, salary_type,
            base_salary, hourly_rate, daily_rate,
            expected_hours_per_month, is_teacher, photo_url
          ''')
          .eq('branch_id', selectedBranchId.value!)
          .eq('status', 'active')
          .order('last_name');

      staffList.value = List<Map<String, dynamic>>.from(data);
      selectedStaffIds.value = staffList.map((s) => s['id'] as String).toList();

    } catch (e) {
      _showError('Hodimlar yuklanmadi: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // MAOSH HISOBLASH
  Future<void> calculateSalaries() async {
    if (selectedStaffIds.isEmpty) {
      _showError('Hodimlarni tanlang');
      return;
    }

    try {
      isCalculating.value = true;
      calculationResults.clear();

      // Ma'lumotlarni yuklash
      await _loadAttendanceData(selectedStaffIds);
      await _loadAdvancesData(selectedStaffIds);
      await _loadLoansData(selectedStaffIds);

      // Har bir hodim uchun hisoblash
      for (var staffId in selectedStaffIds) {
        final staff = staffList.firstWhere((s) => s['id'] == staffId);
        final result = await _calculateStaffSalary(staff);
        calculationResults.add(result);
      }

      _showSuccess('${calculationResults.length} ta hodim maoshi hisoblandi');

    } catch (e) {
      _showError('Hisoblashda xatolik: $e');
    } finally {
      isCalculating.value = false;
    }
  }

  // DAVOMATNI YUKLASH
  Future<void> _loadAttendanceData(List<String> staffIds) async {
    try {
      final startDate = DateTime(selectedYear.value, selectedMonth.value, 1);
      final endDate = DateTime(selectedYear.value, selectedMonth.value + 1, 0);

      final data = await _supabase
          .from('attendance_staff')
          .select('*')
          .inFilter('staff_id', staffIds)
          .gte('attendance_date', startDate.toIso8601String().split('T')[0])
          .lte('attendance_date', endDate.toIso8601String().split('T')[0]);

      attendanceData.clear();
      for (var record in data) {
        final staffId = record['staff_id'] as String;
        
        if (!attendanceData.containsKey(staffId)) {
          attendanceData[staffId] = {
            'records': <Map<String, dynamic>>[],
            'present_days': 0,
            'absent_days': 0,
            'late_days': 0,
            'total_hours': 0.0,
            'overtime_hours': 0.0,
          };
        }

        final records = attendanceData[staffId]!['records'] as List;
        records.add(record);

        if (record['status'] == 'present') {
          attendanceData[staffId]!['present_days']++;
        } else if (record['status'] == 'absent') {
          attendanceData[staffId]!['absent_days']++;
        } else if (record['status'] == 'late') {
          attendanceData[staffId]!['late_days']++;
        }

        attendanceData[staffId]!['total_hours'] += 
            (record['actual_hours'] ?? 0.0);
        attendanceData[staffId]!['overtime_hours'] += 
            (record['overtime_hours'] ?? 0.0);
      }
    } catch (e) {
      print('Davomat yuklanmadi: $e');
    }
  }

  // AVANSLARNI YUKLASH
  Future<void> _loadAdvancesData(List<String> staffIds) async {
    try {
      final data = await _supabase
          .from('staff_advances')
          .select('*')
          .inFilter('staff_id', staffIds)
          .eq('deduction_month', selectedMonth.value)
          .eq('deduction_year', selectedYear.value)
          .eq('is_deducted', false);

      advancesData.clear();
      for (var adv in data) {
        final staffId = adv['staff_id'] as String;
        if (!advancesData.containsKey(staffId)) {
          advancesData[staffId] = [];
        }
        advancesData[staffId]!.add(adv);
      }
    } catch (e) {
      print('Avanslar yuklanmadi: $e');
    }
  }

  // QARZLARNI YUKLASH
  Future<void> _loadLoansData(List<String> staffIds) async {
    try {
      final data = await _supabase
          .from('staff_loans')
          .select('*')
          .inFilter('staff_id', staffIds)
          .eq('is_settled', false);

      loansData.clear();
      for (var loan in data) {
        final staffId = loan['staff_id'] as String;
        if (!loansData.containsKey(staffId)) {
          loansData[staffId] = [];
        }
        loansData[staffId]!.add(loan);
      }
    } catch (e) {
      print('Qarzlar yuklanmadi: $e');
    }
  }

  // BIR HODIM UCHUN MAOSH HISOBLASH
  Future<Map<String, dynamic>> _calculateStaffSalary(
    Map<String, dynamic> staff,
  ) async {
    final staffId = staff['id'] as String;
final salaryType = staff['salary_type'] as String? ?? 'salary';

    double baseAmount = 0;
    int workedDays = 0;
    double workedHours = 0;

    // Davomat
    final attendance = attendanceData[staffId];
    if (attendance != null) {
      workedDays = attendance['present_days'] + attendance['late_days'];
      workedHours = attendance['total_hours'];
    }

    // Asosiy maosh
    switch (salaryType) {
      case 'monthly':
        final totalDays = DateTime(
          selectedYear.value,
          selectedMonth.value + 1,
          0,
        ).day;
        final baseSalary = (staff['base_salary'] ?? 0).toDouble();
        baseAmount = (baseSalary / totalDays) * workedDays;
        break;

      case 'hourly':
        final hourlyRate = (staff['hourly_rate'] ?? 0).toDouble();
        baseAmount = hourlyRate * workedHours;
        break;

      case 'daily':
        final dailyRate = (staff['daily_rate'] ?? 0).toDouble();
        baseAmount = dailyRate * workedDays;
        break;
    }

    // Bonus va jarima
    double bonusAmount = 0;
    double bonusPercent = 0;
    double penaltyAmount = 0;
    double penaltyPercent = 0;

    if (attendance != null) {
      final totalDays = attendance['present_days'] + 
          attendance['absent_days'] + 
          attendance['late_days'];
      
      if (totalDays > 0) {
        final attendancePercent = 
            (attendance['present_days'] / totalDays) * 100;
        
        if (attendancePercent >= 95) {
          bonusPercent = 5;
          bonusAmount = baseAmount * 0.05;
        }
      }

      if (attendance['late_days'] > 3) {
        penaltyPercent = 2;
        penaltyAmount = baseAmount * 0.02;
      }
    }

    // Avans va qarz
    double totalAdvances = 0;
    final advances = advancesData[staffId] ?? [];
    for (var adv in advances) {
      totalAdvances += (adv['amount'] ?? 0).toDouble();
    }

    double totalLoanDeduction = 0;
    final loans = loansData[staffId] ?? [];
    for (var loan in loans) {
      totalLoanDeduction += (loan['monthly_deduction'] ?? 0).toDouble();
    }

    // Kechikish jarimasi
    double lateDeductions = 0;
    double earlyLeaveDeductions = 0;
    if (attendance != null) {
      final records = attendance['records'] as List<Map<String, dynamic>>;
      for (var record in records) {
        lateDeductions += (record['late_deduction'] ?? 0).toDouble();
        earlyLeaveDeductions += 
            (record['early_leave_deduction'] ?? 0).toDouble();
      }
    }

    // Yakuniy hisoblash
    final grossAmount = baseAmount + bonusAmount - penaltyAmount;
    final netAmount = grossAmount - 
        totalAdvances - 
        totalLoanDeduction - 
        lateDeductions - 
        earlyLeaveDeductions;

    return {
      'staff_id': staffId,
      'staff_name': '${staff['first_name'] ?? ''} ${staff['last_name'] ?? ''}',
      'position': staff['position'] ?? '',
      'salary_type': salaryType,
      'photo_url': staff['photo_url'],
      'base_amount': baseAmount,
      'worked_days': workedDays,
      'worked_hours': workedHours,
      'bonus_percent': bonusPercent,
      'bonus_amount': bonusAmount,
      'penalty_percent': penaltyPercent,
      'penalty_amount': penaltyAmount,
      'advance_deduction': totalAdvances,
      'loan_deduction': totalLoanDeduction,
      'late_deductions': lateDeductions,
      'early_leave_deductions': earlyLeaveDeductions,
      'gross_amount': grossAmount,
      'net_amount': netAmount,
      'attendance_summary': attendance,
      'advances': advances,
      'loans': loans,
    };
  }
String mapOperationType(String salaryType) {
  switch (salaryType) {
    case 'monthly':
      return 'salary'; // ENUM dagi qiymat
    case 'hourly':
      return 'salary';
    case 'daily':
      return 'salary';
    default:
      return 'salary';
  }
}

  // MAOSHLARNI SAQLASH
  Future<void> saveSalaries() async {
    if (calculationResults.isEmpty) {
      _showError('Avval maoshlarni hisoblang');
      return;
    }

    try {
      isCalculating.value = true;

      for (var result in calculationResults) {
        // Salary operation yaratish
        final operation = await _supabase
            .from('salary_operations')
            .insert({
              'branch_id': selectedBranchId.value,
              'staff_id': result['staff_id'],
              'operation_type': mapOperationType(result['salary_type']),

              'period_month': selectedMonth.value,
              'period_year': selectedYear.value,
              'base_amount': result['base_amount'],
              'worked_days': result['worked_days'],
              'worked_hours': result['worked_hours'],
              'bonus_percent': result['bonus_percent'],
              'bonus_amount': result['bonus_amount'],
              'penalty_percent': result['penalty_percent'],
              'penalty_amount': result['penalty_amount'],
              'advance_deduction': result['advance_deduction'],
              'loan_deduction': result['loan_deduction'],
              'gross_amount': result['gross_amount'],
              'net_amount': result['net_amount'],
              'is_paid': false,
              'calculated_by': _supabase.auth.currentUser?.id,
            })
            .select()
            .single();

        final operationId = operation['id'];

        // Avanslarni yangilash
        final advances = result['advances'] as List<Map<String, dynamic>>;
        for (var adv in advances) {
          await _supabase
              .from('staff_advances')
              .update({
                'is_deducted': true,
                'deducted_from_operation_id': operationId,
                'deducted_at': DateTime.now().toIso8601String(),
              })
              .eq('id', adv['id']);
        }

        // Qarz to'lovlari
        final loans = result['loans'] as List<Map<String, dynamic>>;
        for (var loan in loans) {
          final monthlyDeduction = (loan['monthly_deduction'] ?? 0).toDouble();
          
          await _supabase.from('staff_loan_payments').insert({
            'loan_id': loan['id'],
            'salary_operation_id': operationId,
            'amount': monthlyDeduction,
            'payment_month': selectedMonth.value,
            'payment_year': selectedYear.value,
          });

          final remaining = (loan['remaining_amount'] ?? 0).toDouble();
          final newRemaining = remaining - monthlyDeduction;

          await _supabase
              .from('staff_loans')
              .update({
                'remaining_amount': newRemaining,
                'is_settled': newRemaining <= 0,
                'settled_at': newRemaining <= 0 
                    ? DateTime.now().toIso8601String() 
                    : null,
              })
              .eq('id', loan['id']);
        }
      }

      calculationResults.clear();
      currentView.value = 'list';
      await loadSalaryOperations();
      
      _showSuccess('Maoshlar muvaffaqiyatli saqlandi');

    } catch (e) {
      _showError('Saqlashda xatolik: $e');
    } finally {
      isCalculating.value = false;
    }
  }

  // MAOSH TO'LASH
  Future<void> paySalary(String operationId) async {
    try {
      isLoading.value = true;

      final operation = salaryOperations.firstWhere(
        (op) => op['id'] == operationId,
      );

      // To'lovni tasdiqlash
      await _supabase
          .from('salary_operations')
          .update({
            'is_paid': true,
            'paid_at': DateTime.now().toIso8601String(),
            'paid_by': _supabase.auth.currentUser?.id,
          })
          .eq('id', operationId);

      // Xarajatga qo'shish
      final staff = operation['staff'];
      await _supabase.from('expenses').insert({
        'branch_id': operation['branch_id'],
        'category': 'salary',
        'title': 'Maosh: ${staff['first_name'] ?? ''} ${staff['last_name'] ?? ''}',
        'amount': operation['net_amount'],
        'staff_id': operation['staff_id'],
        'salary_operation_id': operationId,
        'expense_date': DateTime.now().toIso8601String().split('T')[0],
        'recorded_by': _supabase.auth.currentUser?.id,
      });

      await loadSalaryOperations();
      _showSuccess('Maosh to\'landi');

    } catch (e) {
      _showError('To\'lashda xatolik: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // MAOSH OPERATSIYASINI O'CHIRISH
  Future<void> deleteSalaryOperation(String operationId) async {
    try {
      isLoading.value = true;

      await _supabase
          .from('salary_operations')
          .delete()
          .eq('id', operationId);

      await loadSalaryOperations();
      _showSuccess('O\'chirildi');

    } catch (e) {
      _showError('O\'chirishda xatolik: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // AVANSLAR RO'YXATINI YUKLASH
  Future<void> loadAdvances() async {
    if (selectedBranchId.value == null) return;

    try {
      isLoading.value = true;

      final data = await _supabase
          .from('staff_advances')
          .select('''
            *,
            staff:staff_id(first_name, last_name, position)
          ''')
          .eq('branch_id', selectedBranchId.value!)
          .order('advance_date', ascending: false)
          .limit(100);

      advancesList.value = List<Map<String, dynamic>>.from(data);

    } catch (e) {
      _showError('Avanslar yuklanmadi: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // QARZLAR RO'YXATINI YUKLASH
  Future<void> loadLoans() async {
    if (selectedBranchId.value == null) return;

    try {
      isLoading.value = true;

      final data = await _supabase
          .from('staff_loans')
          .select('''
            *,
            staff:staff_id(first_name, last_name, position)
          ''')
          .eq('branch_id', selectedBranchId.value!)
          .order('loan_date', ascending: false)
          .limit(100);

      loansList.value = List<Map<String, dynamic>>.from(data);

    } catch (e) {
      _showError('Qarzlar yuklanmadi: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // MAOSH TARIXINI YUKLASH
  Future<void> loadSalaryHistory() async {
    if (selectedBranchId.value == null) return;

    try {
      isLoading.value = true;

      final data = await _supabase
          .from('salary_operations')
          .select('''
            *,
            staff:staff_id(first_name, last_name, position, photo_url)
          ''')
          .eq('branch_id', selectedBranchId.value!)
          .gte('created_at', historyStartDate.value.toIso8601String())
          .lte('created_at', historyEndDate.value.toIso8601String())
          .order('created_at', ascending: false);

      salaryHistory.value = List<Map<String, dynamic>>.from(data);

    } catch (e) {
      _showError('Tarix yuklanmadi: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // CSV EXPORT
  Future<void> exportToCSV() async {
    try {
      String csv = 'Hodim,Lavozim,Asosiy maosh,Bonus,Jarima,Avans,Qarz,Net summa,Status\n';
      
      for (var op in filteredOperations) {
        final staff = op['staff'];
        csv += '"${staff['first_name']} ${staff['last_name']}",';
        csv += '"${staff['position'] ?? ''}",';
        csv += '${op['base_amount']},';
        csv += '${op['bonus_amount']},';
        csv += '${op['penalty_amount']},';
        csv += '${op['advance_deduction']},';
        csv += '${op['loan_deduction']},';
        csv += '${op['net_amount']},';
        csv += '${op['is_paid'] ? 'To\'langan' : 'Kutilmoqda'}\n';
      }

      await _saveFile(csv, 'maosh_${getPeriodString()}.csv');
      _showSuccess('Fayl saqlandi');

    } catch (e) {
      _showError('Export xatolik: $e');
    }
  }

  // FAYLNI SAQLASH
  Future<void> _saveFile(String content, String fileName) async {
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/$fileName');
        await file.writeAsString(content);
        _showSuccess('Saqlandi: ${file.path}');
      } else {
        String? outputPath = await FilePicker.platform.saveFile(
          dialogTitle: 'Faylni saqlash',
          fileName: fileName,
        );
        if (outputPath != null) {
          final file = File(outputPath);
          await file.writeAsString(content);
          _showSuccess('Saqlandi: $outputPath');
        }
      }
    } catch (e) {
      _showError('Saqlashda xatolik: $e');
    }
  }

  // FILTR VA QIDIRUV
  void changeStatusFilter(String status) {
    selectedStatus.value = status;
    _applyFilters();
  }

  void search(String query) {
    searchQuery.value = query;
    _applyFilters();
  }

  void changePeriod(int month, int year) {
    selectedMonth.value = month;
    selectedYear.value = year;
    loadSalaryOperations();
  }

  void changeBranch(String? branchId) {
    if (branchId != null) {
      selectedBranchId.value = branchId;
      loadSalaryOperations();
    }
  }

  // VIEW O'ZGARTIRISH
  void changeView(String view) {
    currentView.value = view;
    
    switch (view) {
      case 'calculate':
        loadStaffForCalculation();
        break;
      case 'history':
        loadSalaryHistory();
        break;
      case 'advances':
        loadAdvances();
        break;
      case 'loans':
        loadLoans();
        break;
    }
  }

  // HODIM TANLASH
  void toggleStaffSelection(String staffId) {
    if (selectedStaffIds.contains(staffId)) {
      selectedStaffIds.remove(staffId);
    } else {
      selectedStaffIds.add(staffId);
    }
  }

  void selectAllStaff() {
    selectedStaffIds.value = staffList.map((s) => s['id'] as String).toList();
  }

  void deselectAllStaff() {
    selectedStaffIds.clear();
  }

  // YORDAMCHI FUNKSIYALAR
  String formatCurrency(double amount) {
    return NumberFormat('#,###', 'uz').format(amount);
  }

  String getPeriodString() {
    const months = [
      'Yanvar', 'Fevral', 'Mart', 'Aprel', 'May', 'Iyun',
      'Iyul', 'Avgust', 'Sentabr', 'Oktabr', 'Noyabr', 'Dekabr',
    ];
    return '${months[selectedMonth.value - 1]} ${selectedYear.value}';
  }

  void _showError(String message) {
    Get.snackbar(
      'Xatolik',
      message,
      backgroundColor: Colors.red.shade100,
      snackPosition: SnackPosition.TOP,
      duration: Duration(seconds: 3),
    );
  }

  void _showSuccess(String message) {
    Get.snackbar(
      'Muvaffaqiyatli',
      message,
      backgroundColor: Colors.green.shade100,
      snackPosition: SnackPosition.TOP,
      duration: Duration(seconds: 2),
    );
  }
}