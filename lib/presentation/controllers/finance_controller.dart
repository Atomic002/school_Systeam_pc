// lib/presentation/controllers/advanced_finance_controller.dart
// MUKAMMAL MOLIYA BOSHQARUVI - BARCHA FUNKSIYALAR BILAN

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class AdvancedFinanceController extends GetxController {
  final supabase = Supabase.instance.client;

  // Loading states
  var isLoading = false.obs;
  var isExporting = false.obs;

  // Filiallar
  var branches = <Map<String, dynamic>>[].obs;
  var selectedBranchId = 'all'.obs;
    var totalSalaryPayable = 0.0.obs;   // Jami hisoblangan (Net)
  var totalSalaryPaid = 0.0.obs;      // Jami to'langan
  var totalSalaryRemaining = 0.0.obs; // Jami qoldiq (Qarz)
  var staffSalaryList = <Map<String, dynamic>>[].obs;

  // Davr
  var selectedPeriod = 'month'.obs;
  var selectedMonth = DateTime.now().obs;
  var selectedYear = DateTime.now().year.obs;
  var availableYears = <int>[].obs;

  // Umumiy statistika
  var totalRevenue = 0.0.obs;
  var totalExpenses = 0.0.obs;
  var netProfit = 0.0.obs;
  var totalDebt = 0.0.obs;
  var totalDebtors = 0.obs;
  var collectionRate = 0.0.obs;

  // O'sish ko'rsatkichlari
  var revenueGrowth = 0.0.obs;
  var expenseGrowth = 0.0.obs;
  var profitGrowth = 0.0.obs;
  var debtCount = 0.obs;

  // Oylik to'lovlar
  var expectedMonthlyRevenue = 0.0.obs;
  var collectedMonthlyRevenue = 0.0.obs;
  var monthlyCollectionRate = 0.0.obs;
  var totalStudentsCount = 0.obs;
  var paidStudentsCount = 0.obs;
  var unpaidStudentsCount = 0.obs;
  var partialPaidStudentsCount = 0.obs;

  // To'lovlar tarixi
  var allPayments = <Map<String, dynamic>>[].obs;
  var allExpenses = <Map<String, dynamic>>[].obs;

  // Sinflar
  var classes = <Map<String, dynamic>>[].obs;
  var expandedClassId = ''.obs;
  var classStudents = <String, List<Map<String, dynamic>>>{}.obs;
  var expandedStudentId = ''.obs;
  var studentPaymentHistory = <Map<String, dynamic>>[].obs;

  // Yillik daromad
  var yearlyRevenue = 0.0.obs;
  var averageMonthlyRevenue = 0.0.obs;
  var projectedYearlyRevenue = 0.0.obs;
  var monthlyRevenueData = <int, double>{}.obs;

  // Daromad tarkibi
  var monthlyPaymentsRevenue = 0.0.obs;
  var oneTimePaymentsRevenue = 0.0.obs;
  var additionalRevenue = 0.0.obs;

  // Xodimlar maoshi
  var totalSalaryExpense = 0.0.obs;

  // O'quvchilar qarzlari
  var totalStudentDebt = 0.0.obs;
  var debtorStudentsCount = 0.obs;
  var topDebtors = <Map<String, dynamic>>[].obs;
  var allDebtorStudents = <Map<String, dynamic>>[].obs;

  // Xarajatlar
  var salaryExpenses = 0.0.obs;
  var utilityExpenses = 0.0.obs;
  var foodExpenses = 0.0.obs;
  var transportExpenses = 0.0.obs;
  var otherExpenses = 0.0.obs;
  var schoolStartYear = 2020.obs; // Default qiymat

  @override
  void onInit() {
    super.onInit();
    _initializeData();
  }

  Future<void> _initializeData() async {
    isLoading.value = true;
    try {
      await loadBranches();
      await loadSchoolStartYear();
      _generateYearsList();
      await refreshData();
    } catch (e) {
      print('❌ Initialize error: $e');
      _showError('Ma\'lumotlar yuklanmadi: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadSchoolStartYear() async {
    try {
      final result = await supabase.rpc(
        'get_school_start_year',
        params: {
          'p_branch_id': selectedBranchId.value != 'all'
              ? selectedBranchId.value
              : null,
        },
      );

      if (result != null) {
        schoolStartYear.value = result as int;
      }

      if (result != null) {
        schoolStartYear.value = result as int;
        print('✅ Maktab ochilgan yil: ${schoolStartYear.value}');
        return;
      }

      // Variant 2: To'g'ridan-to'g'ri system_settings'dan olish
      final settingsData = await supabase
          .from('system_settings')
          .select('setting_value')
          .eq('setting_key', 'school_start_year')
          .or('branch_id.is.null,branch_id.eq.${selectedBranchId.value}')
          .order('branch_id', ascending: false) // branch_id bo'lganlar birinchi
          .limit(1)
          .maybeSingle();

      if (settingsData != null && settingsData['setting_value'] != null) {
        schoolStartYear.value =
            int.tryParse(settingsData['setting_value']) ?? 2020;
        print('✅ Maktab ochilgan yil (settings): ${schoolStartYear.value}');
        return;
      }

      // Variant 3: Academic years'dan eng qadimgisini olish
      final academicYearsData = await supabase
          .from('academic_years')
          .select('start_date')
          .order('start_date', ascending: true)
          .limit(1)
          .maybeSingle();

      if (academicYearsData != null &&
          academicYearsData['start_date'] != null) {
        final startDate = DateTime.parse(academicYearsData['start_date']);
        schoolStartYear.value = startDate.year;
        print('✅ Maktab ochilgan yil (academic): ${schoolStartYear.value}');
        return;
      }

      // Default qiymat
      schoolStartYear.value = DateTime.now().year - 5;
      print('⚠️ Default yil ishlatilmoqda: ${schoolStartYear.value}');
    } catch (e) {
      print('❌ Load school start year error: $e');
      schoolStartYear.value = DateTime.now().year - 5; // Fallback
    }
  }

  // ✅ YANGILANGAN: Yillar ro'yxatini yaratish
  Future<void> _generateYearsList() async {
    try {
      // Variant 1: RPC funksiyasidan olish (eng samarali)
      final yearsData = await supabase.rpc(
        'get_available_years',
        params: {
          'p_branch_id': selectedBranchId.value != 'all'
              ? selectedBranchId.value
              : null,
        },
      );

      if (yearsData != null && yearsData is List && yearsData.isNotEmpty) {
        availableYears.value = yearsData
            .map((item) => item['year_value'] as int)
            .toList();
        print('✅ Yillar ro\'yxati (RPC): ${availableYears.length} ta');
        return;
      }

      // Variant 2: O'zimiz generate qilish
      final currentYear = DateTime.now().year;
      final startYear = schoolStartYear.value;

      availableYears.value = List.generate(
        currentYear - startYear + 1,
        (index) => startYear + index,
      ).reversed.toList();

      print(
        '✅ Yillar ro\'yxati: ${availableYears.length} ta ($startYear - $currentYear)',
      );
    } catch (e) {
      print('❌ Generate years error: $e');
      // Fallback
      final currentYear = DateTime.now().year;
      availableYears.value = List.generate(5, (index) => currentYear - index);
    }
  }

  // ✅ Filial o'zgarganda yilni qayta yuklash
  void changeBranch(String branchId) async {
    selectedBranchId.value = branchId;
    await loadSchoolStartYear();
    await _generateYearsList();
    refreshData();
  }

  Future<void> loadBranches() async {
    try {
      final response = await supabase
          .from('branches')
          .select('id, name, is_active')
          .eq('is_active', true)
          .order('name');

      branches.value = List<Map<String, dynamic>>.from(response);
      print('✅ Filiallar yuklandi: ${branches.length} ta');
    } catch (e) {
      print('❌ Load branches error: $e');
    }
  }

  Future<void> refreshData() async {
    isLoading.value = true;
    try {
      await Future.wait([
        loadGeneralStats(),
        loadMonthlyCollection(),
        loadClasses(),
        loadYearlyRevenue(),
        loadStaffSalaries(),
        loadStudentDebts(),
        loadExpenses(),
        loadAllPayments(),
        loadAllExpenses(),
      ]);

      _calculateAdditionalMetrics();
      print('✅ Barcha ma\'lumotlar yangilandi');
    } catch (e) {
      print('❌ Refresh error: $e');
      _showError('Ma\'lumotlar yangilanmadi');
    } finally {
      isLoading.value = false;
    }
  }

  // ==================== BARCHA TO'LOVLARNI YUKLASH ====================
  Future<void> loadAllPayments() async {
    try {
      final dateRange = _getDateRange();

      var query = supabase
          .from('payments')
          .select('''
            *,
            students:student_id(first_name, last_name, phone),
            classes:class_id(name)
          ''')
          .gte('payment_date', dateRange['start']!)
          .lte('payment_date', dateRange['end']!)
          .eq('payment_status', 'paid')
          .order('payment_date', ascending: false);

      if (selectedBranchId.value != 'all') {}

      final data = await query;
      allPayments.value = List<Map<String, dynamic>>.from(data);
      print('✅ Barcha to\'lovlar yuklandi: ${allPayments.length} ta');
    } catch (e) {
      print('❌ Load all payments error: $e');
      allPayments.value = [];
    }
  }

  // ==================== BARCHA XARAJATLARNI YUKLASH ====================
  Future<void> loadAllExpenses() async {
    try {
      final dateRange = _getDateRange();

      var query = supabase
          .from('expenses')
          .select('*')
          .gte('expense_date', dateRange['start']!)
          .lte('expense_date', dateRange['end']!)
          .order('expense_date', ascending: false);

      if (selectedBranchId.value != 'all') {}

      final data = await query;
      allExpenses.value = List<Map<String, dynamic>>.from(data);
      print('✅ Barcha xarajatlar yuklandi: ${allExpenses.length} ta');
    } catch (e) {
      print('❌ Load all expenses error: $e');
      allExpenses.value = [];
    }
  }

  // ==================== UMUMIY STATISTIKA ====================
  Future<void> loadGeneralStats() async {
    try {
      final dateRange = _getDateRange();

      // TUSHUMLAR
      var revenueQuery = supabase
          .from('payments')
          .select('final_amount, discount_amount')
          .gte('payment_date', dateRange['start']!)
          .lte('payment_date', dateRange['end']!)
          .eq('payment_status', 'paid');

      if (selectedBranchId.value != 'all') {
        revenueQuery = revenueQuery.eq('branch_id', selectedBranchId.value);
      }

      final revenueData = await revenueQuery;
      totalRevenue.value = _calculateSum(revenueData, 'final_amount');

      // XARAJATLAR
      var expensesQuery = supabase
          .from('expenses')
          .select('amount')
          .gte('expense_date', dateRange['start']!)
          .lte('expense_date', dateRange['end']!);

      if (selectedBranchId.value != 'all') {
        expensesQuery = expensesQuery.eq('branch_id', selectedBranchId.value);
      }

      final expensesData = await expensesQuery;
      totalExpenses.value = _calculateSum(expensesData, 'amount');

      // SOF FOYDA
      netProfit.value = totalRevenue.value - totalExpenses.value;

      // QARZLAR - JAMI O'QUVCHILAR QARZLARI
      await _calculateTotalStudentDebts();

      await _calculateGrowthRates();

      if (expectedMonthlyRevenue.value > 0) {
        collectionRate.value =
            (collectedMonthlyRevenue.value /
            expectedMonthlyRevenue.value *
            100);
      }

      print('✅ Umumiy statistika yuklandi');
    } catch (e) {
      print('❌ Load general stats error: $e');
    }
  }

  // ==================== JAMI O'QUVCHILAR QARZLARINI HISOBLASH ====================
  Future<void> _calculateTotalStudentDebts() async {
    try {
      // Barcha aktiv o'quvchilarni olish
      var studentsQuery = supabase
          .from('students')
          .select('id, monthly_fee, enrollment_date, branch_id')
          .eq('status', 'active');

      if (selectedBranchId.value != 'all') {
        studentsQuery = studentsQuery.eq('branch_id', selectedBranchId.value);
      }

      final students = await studentsQuery;

      double totalDebts = 0.0;
      int debtorsCount = 0;

      for (var student in students) {
        final studentId = student['id'].toString();
        final monthlyFee = _toDouble(student['monthly_fee']);
        final enrollmentDate = DateTime.parse(student['enrollment_date']);
        final now = DateTime.now();

        // Ro'yxatdan o'tganidan bugungi kungacha necha oy o'tganini hisoblash
        int monthsPassed =
            (now.year - enrollmentDate.year) * 12 +
            (now.month - enrollmentDate.month);

        if (now.day < enrollmentDate.day) {
          monthsPassed--;
        }

        if (monthsPassed < 0) monthsPassed = 0;

        // Kutilayotgan jami to'lov
        double expectedTotal = monthlyFee * monthsPassed;

        // To'langan jami summa
        final paymentsData = await supabase
            .from('payments')
            .select('final_amount')
            .eq('student_id', studentId)
            .eq('payment_status', 'paid');

        double totalPaid = _calculateSum(paymentsData, 'final_amount');

        // Qarz
        double debt = expectedTotal - totalPaid;

        if (debt > 0) {
          totalDebts += debt;
          debtorsCount++;
        }
      }

      totalDebt.value = totalDebts;
      totalDebtors.value = debtorsCount;
      debtCount.value = debtorsCount;

      print('✅ Jami qarzlar: $totalDebts, Qarzdorlar: $debtorsCount');
    } catch (e) {
      print('❌ Calculate total debts error: $e');
    }
  }

  Future<void> _calculateGrowthRates() async {
    try {
      final previousRange = _getPreviousDateRange();

      // Oldingi davr daromadi
      var prevRevenueQuery = supabase
          .from('payments')
          .select('final_amount')
          .gte('payment_date', previousRange['start']!)
          .lte('payment_date', previousRange['end']!)
          .eq('payment_status', 'paid');

      if (selectedBranchId.value != 'all') {
        prevRevenueQuery = prevRevenueQuery.eq(
          'branch_id',
          selectedBranchId.value,
        );
      }

      final prevRevenueData = await prevRevenueQuery;
      double prevRevenue = _calculateSum(prevRevenueData, 'final_amount');

      if (prevRevenue > 0) {
        revenueGrowth.value =
            ((totalRevenue.value - prevRevenue) / prevRevenue * 100);
      }

      // Oldingi davr xarajatlari
      var prevExpenseQuery = supabase
          .from('expenses')
          .select('amount')
          .gte('expense_date', previousRange['start']!)
          .lte('expense_date', previousRange['end']!);

      if (selectedBranchId.value != 'all') {
        prevExpenseQuery = prevExpenseQuery.eq(
          'branch_id',
          selectedBranchId.value,
        );
      }

      final prevExpenseData = await prevExpenseQuery;
      double prevExpense = _calculateSum(prevExpenseData, 'amount');

      if (prevExpense > 0) {
        expenseGrowth.value =
            ((totalExpenses.value - prevExpense) / prevExpense * 100);
      }

      final prevProfit = prevRevenue - prevExpense;
      if (prevProfit > 0) {
        profitGrowth.value =
            ((netProfit.value - prevProfit) / prevProfit * 100);
      }
    } catch (e) {
      print('❌ Calculate growth rates error: $e');
    }
  }

  // ==================== OYLIK YIG'ISH ====================
  Future<void> loadMonthlyCollection() async {
    try {
      final startDate = DateTime(
        selectedMonth.value.year,
        selectedMonth.value.month,
        1,
      );
      final endDate = DateTime(
        selectedMonth.value.year,
        selectedMonth.value.month + 1,
        0,
      );

      // Barcha aktiv o'quvchilar
      var studentsQuery = supabase
          .from('students')
          .select('id, monthly_fee, discount_percent')
          .eq('status', 'active');

      if (selectedBranchId.value != 'all') {
        studentsQuery = studentsQuery.eq('branch_id', selectedBranchId.value);
      }

      final studentsData = await studentsQuery;
      totalStudentsCount.value = studentsData.length;

      // Kutilayotgan daromad (chegirma bilan)
      double expected = 0.0;
      for (var student in studentsData) {
        final fee = _toDouble(student['monthly_fee']);
        final discountPercent = _toDouble(student['discount_percent']);
        final discountAmount = fee * (discountPercent / 100);
        expected += (fee - discountAmount);
      }
      expectedMonthlyRevenue.value = expected;

      // Bu oydagi to'lovlar
      var paymentsQuery = supabase
          .from('payments')
          .select('student_id, final_amount, discount_percent, discount_amount')
          .gte('payment_date', startDate.toIso8601String())
          .lte('payment_date', endDate.toIso8601String())
          .eq('payment_status', 'paid');

      if (selectedBranchId.value != 'all') {
        paymentsQuery = paymentsQuery.eq('branch_id', selectedBranchId.value);
      }

      final paymentsData = await paymentsQuery;

      Map<String, double> studentPayments = {};
      Map<String, double> studentDiscounts = {};

      for (var payment in paymentsData) {
        final studentId = payment['student_id']?.toString() ?? '';
        final amount = _toDouble(payment['final_amount']);
        final discount = _toDouble(payment['discount_amount']);

        if (studentId.isNotEmpty) {
          studentPayments[studentId] =
              (studentPayments[studentId] ?? 0.0) + amount;
          studentDiscounts[studentId] =
              (studentDiscounts[studentId] ?? 0.0) + discount;
        }
      }

      collectedMonthlyRevenue.value = studentPayments.values.fold(
        0.0,
        (sum, amount) => sum + amount,
      );

      // Statistika
      paidStudentsCount.value = 0;
      partialPaidStudentsCount.value = 0;

      for (var student in studentsData) {
        final studentId = student['id']?.toString() ?? '';
        final monthlyFee = _toDouble(student['monthly_fee']);
        final discountPercent = _toDouble(student['discount_percent']);
        final expectedFee = monthlyFee - (monthlyFee * discountPercent / 100);
        final paidAmount = studentPayments[studentId] ?? 0.0;

        if (paidAmount >= expectedFee && expectedFee > 0) {
          paidStudentsCount.value++;
        } else if (paidAmount > 0) {
          partialPaidStudentsCount.value++;
        }
      }

      unpaidStudentsCount.value =
          totalStudentsCount.value -
          paidStudentsCount.value -
          partialPaidStudentsCount.value;

      if (expectedMonthlyRevenue.value > 0) {
        monthlyCollectionRate.value =
            (collectedMonthlyRevenue.value /
            expectedMonthlyRevenue.value *
            100);
      }

      print('✅ Oylik yig\'ish yuklandi');
    } catch (e) {
      print('❌ Load monthly collection error: $e');
    }
  }

  // ==================== SINFLARNI YUKLASH ====================
  Future<void> loadClasses() async {
    try {
      var classesQuery = supabase
          .from('classes')
          .select('''
            id, 
            name, 
            branch_id, 
            main_teacher_id,
            monthly_fee,
            is_active
          ''')
          .eq('is_active', true);

      if (selectedBranchId.value != 'all') {
        classesQuery = classesQuery.eq('branch_id', selectedBranchId.value);
      }

      final classesData = await classesQuery;
      List<Map<String, dynamic>> processedClasses = [];

      for (var classItem in classesData) {
        final classId = classItem['id']?.toString() ?? '';

        // O'quvchilar soni va kutilayotgan daromad
        final studentsResponse = await supabase
            .from('students')
            .select('id, monthly_fee, discount_percent')
            .eq('class_id', classId)
            .eq('status', 'active');

        int studentsCount = studentsResponse.length;
        double expectedRevenue = 0.0;

        for (var student in studentsResponse) {
          final fee = _toDouble(student['monthly_fee']);
          final discount = _toDouble(student['discount_percent']);
          expectedRevenue += (fee - (fee * discount / 100));
        }

        // Bu oydagi to'lovlar
        final startDate = DateTime(
          selectedMonth.value.year,
          selectedMonth.value.month,
          1,
        );
        final endDate = DateTime(
          selectedMonth.value.year,
          selectedMonth.value.month + 1,
          0,
        );

        final payments = await supabase
            .from('payments')
            .select('final_amount')
            .eq('class_id', classId)
            .gte('payment_date', startDate.toIso8601String())
            .lte('payment_date', endDate.toIso8601String())
            .eq('payment_status', 'paid');

        double collectedRevenue = _calculateSum(payments, 'final_amount');

        // O'qituvchi nomi
        String teacherName = 'Tayinlanmagan';
        if (classItem['main_teacher_id'] != null) {
          final teacher = await supabase
              .from('staff')
              .select('first_name, last_name')
              .eq('id', classItem['main_teacher_id'])
              .maybeSingle();

          if (teacher != null) {
            teacherName = '${teacher['first_name']} ${teacher['last_name']}';
          }
        }

        processedClasses.add({
          'id': classId,
          'name': classItem['name'] ?? '',
          'students_count': studentsCount,
          'expected_revenue': expectedRevenue,
          'collected_revenue': collectedRevenue,
          'teacher_name': teacherName,
          'teacher_id': classItem['main_teacher_id']
              ?.toString(), // ✅ qo‘shimcha
        });
      }

      classes.value = processedClasses;
      print('✅ Sinflar yuklandi: ${classes.length} ta');
    } catch (e) {
      print('❌ Load classes error: $e');
    }
  }

  void showTeacherProfile(String staffId) {
    Get.toNamed(
      '/staff-detail', // yoki sizda qanday route bo‘lsa, o‘sha
      arguments: {'staffId': staffId},
    );
  }

  // ==================== SINF O'QUVCHILARINI YUKLASH ====================
  Future<void> loadClassStudents(String classId) async {
    try {
      final students = await supabase
          .from('students')
          .select('''
          id, 
          first_name, 
          last_name, 
          monthly_fee,
          discount_percent,
          enrollment_date,
          phone
        ''')
          .eq('class_id', classId)
          .eq('status', 'active')
          .order('last_name');

      final startDate = DateTime(
        selectedMonth.value.year,
        selectedMonth.value.month,
        1,
      );
      final endDate = DateTime(
        selectedMonth.value.year,
        selectedMonth.value.month + 1,
        0,
      );

      List<Map<String, dynamic>> processedStudents = [];

      for (var student in students) {
        final studentId = student['id']?.toString() ?? '';
        final monthlyFee = _toDouble(student['monthly_fee']);
        final discountPercent = _toDouble(student['discount_percent']);
        final expectedFee = monthlyFee - (monthlyFee * discountPercent / 100);

        final monthlyPayments = await supabase
            .from('payments')
            .select('final_amount, discount_amount, discount_percent')
            .eq('student_id', studentId)
            .gte('payment_date', startDate.toIso8601String())
            .lte('payment_date', endDate.toIso8601String())
            .eq('payment_status', 'paid');

        double paidAmount = _calculateSum(monthlyPayments, 'final_amount');
        double discountAmount = _calculateSum(
          monthlyPayments,
          'discount_amount',
        );

        final allPayments = await supabase
            .from('payments')
            .select('id')
            .eq('student_id', studentId)
            .eq('payment_status', 'paid');

        int paymentsCount = allPayments.length;

        final enrollmentDate = DateTime.parse(student['enrollment_date']);
        final now = DateTime.now();
        int monthsPassed =
            (now.year - enrollmentDate.year) * 12 +
            (now.month - enrollmentDate.month);
        if (now.day < enrollmentDate.day) monthsPassed--;
        if (monthsPassed < 0) monthsPassed = 0;

        double totalExpected = expectedFee * monthsPassed;

        final allPaymentsData = await supabase
            .from('payments')
            .select('final_amount')
            .eq('student_id', studentId)
            .eq('payment_status', 'paid');

        double totalPaid = _calculateSum(allPaymentsData, 'final_amount');
        double totalDebt = totalExpected - totalPaid;
        if (totalDebt < 0) totalDebt = 0;

        processedStudents.add({
          'id': studentId,
          'first_name': student['first_name'] ?? '',
          'last_name': student['last_name'] ?? '',
          'monthly_fee': monthlyFee,
          'discount_percent': discountPercent,
          'expected_fee': expectedFee,
          'paid_amount': paidAmount,
          'discount_amount': discountAmount,
          'payments_count': paymentsCount,
          'enrollment_date': student['enrollment_date'],
          'phone': student['phone'],
          'total_debt': totalDebt,
          'months_passed': monthsPassed,
        });
      }

      classStudents[classId] = processedStudents; // ✅ faqat bitta yozish
      // istasangiz: classStudents.refresh();
      print('✅ Sinf o\'quvchilari yuklandi: ${processedStudents.length} ta');
    } catch (e) {
      print('❌ Load class students error: $e');
    }
  }

  // ==================== O'QUVCHI TO'LOVLAR TARIXI ====================
  Future<void> loadStudentPaymentHistory(String studentId) async {
    try {
      final payments = await supabase
          .from('payments')
          .select('''
            *,
            classes:class_id(name)
          ''')
          .eq('student_id', studentId)
          .eq('payment_status', 'paid')
          .order('payment_date', ascending: false);

      studentPaymentHistory.value = List<Map<String, dynamic>>.from(payments);
      print('✅ O\'quvchi to\'lovlari yuklandi: ${payments.length} ta');
    } catch (e) {
      print('❌ Load student payment history error: $e');
      studentPaymentHistory.value = [];
    }
  }

  List<Map<String, dynamic>> getClassStudents(String classId) {
    return classStudents[classId] ?? const [];
  }

  // ==================== YILLIK DAROMAD ====================
  Future<void> loadYearlyRevenue() async {
    try {
      final startDate = DateTime(selectedYear.value, 1, 1);
      final endDate = DateTime(selectedYear.value, 12, 31);

      var query = supabase
          .from('payments')
          .select('final_amount, payment_date')
          .gte('payment_date', startDate.toIso8601String())
          .lte('payment_date', endDate.toIso8601String())
          .eq('payment_status', 'paid');

      if (selectedBranchId.value != 'all') {
        query = query.eq('branch_id', selectedBranchId.value);
      }

      final revenueData = await query;
      yearlyRevenue.value = _calculateSum(revenueData, 'final_amount');

      // Oylik taqsimot
      monthlyRevenueData.clear();
      for (int month = 1; month <= 12; month++) {
        final monthStart = DateTime(selectedYear.value, month, 1);
        final monthEnd = DateTime(selectedYear.value, month + 1, 0);

        final monthRevenue = revenueData
            .where((item) {
              try {
                final dateStr = item['payment_date']?.toString() ?? '';
                if (dateStr.isEmpty) return false;
                final date = DateTime.parse(dateStr);
                return date.isAfter(
                      monthStart.subtract(const Duration(seconds: 1)),
                    ) &&
                    date.isBefore(monthEnd.add(const Duration(seconds: 1)));
              } catch (e) {
                return false;
              }
            })
            .fold<double>(
              0.0,
              (sum, item) => sum + _toDouble(item['final_amount']),
            );

        monthlyRevenueData[month] = monthRevenue;
      }

      // O'rtacha va prognoz
      final currentMonth = DateTime.now().month;
      if (selectedYear.value == DateTime.now().year && currentMonth > 0) {
        averageMonthlyRevenue.value = yearlyRevenue.value / currentMonth;
        projectedYearlyRevenue.value = averageMonthlyRevenue.value * 12;
      } else {
        averageMonthlyRevenue.value = yearlyRevenue.value / 12;
        projectedYearlyRevenue.value = yearlyRevenue.value;
      }

      await _loadRevenueBreakdown();
      print('✅ Yillik daromad yuklandi');
    } catch (e) {
      print('❌ Load yearly revenue error: $e');
    }
  }

  Future<void> _loadRevenueBreakdown() async {
    try {
      final dateRange = _getDateRange();

      var paymentsQuery = supabase
          .from('payments')
          .select('payment_type, final_amount')
          .gte('payment_date', dateRange['start']!)
          .lte('payment_date', dateRange['end']!)
          .eq('payment_status', 'paid');

      if (selectedBranchId.value != 'all') {
        paymentsQuery = paymentsQuery.eq('branch_id', selectedBranchId.value);
      }

      final paymentsData = await paymentsQuery;

      monthlyPaymentsRevenue.value = paymentsData
          .where((p) => p['payment_type'] == 'monthly')
          .fold<double>(0.0, (sum, p) => sum + _toDouble(p['final_amount']));

      oneTimePaymentsRevenue.value = paymentsData
          .where((p) => p['payment_type'] == 'one_time')
          .fold<double>(0.0, (sum, p) => sum + _toDouble(p['final_amount']));

      additionalRevenue.value = paymentsData
          .where(
            (p) =>
                p['payment_type'] != 'monthly' &&
                p['payment_type'] != 'one_time',
          )
          .fold<double>(0.0, (sum, p) => sum + _toDouble(p['final_amount']));
    } catch (e) {
      print('⚠️ Load revenue breakdown error: $e');
    }
  }

  // ==================== XODIMLAR MAOSHI ====================
  Future<void> loadStaffSalaries() async {
    try {
      var staffQuery = supabase
          .from('staff')
          .select('id, first_name, last_name, position, base_salary')
          .eq('status', 'active');

      if (selectedBranchId.value != 'all') {
        staffQuery = staffQuery.eq('branch_id', selectedBranchId.value);
      }

      final staffData = await staffQuery;
      totalSalaryExpense.value = 0.0;
      List<Map<String, dynamic>> processedStaff = [];

      for (var staff in staffData) {
        double paidAmount = 0.0;
        String? lastPaymentDate;

        try {
          final salaryData = await supabase
              .from('salary_operations')
              .select('net_amount, paid_at')
              .eq('staff_id', staff['id'])
              .eq('is_paid', true)
              .eq('period_year', selectedYear.value)
              .order('paid_at', ascending: false)
              .limit(1);

          if (salaryData.isNotEmpty) {
            paidAmount = _toDouble(salaryData[0]['net_amount']);
            lastPaymentDate = salaryData[0]['paid_at']?.toString();
          }
        } catch (e) {
          print('⚠️ Xodim maoshi olishda xato: $e');
        }

        totalSalaryExpense.value += paidAmount;

        processedStaff.add({
          'id': staff['id'],
          'first_name': staff['first_name'] ?? '',
          'last_name': staff['last_name'] ?? '',
          'position': staff['position'] ?? '',
          'base_salary': _toDouble(staff['base_salary']),
          'paid_amount': paidAmount,
          'last_payment_date': lastPaymentDate,
        });
      }

      staffSalaryList.value = processedStaff;
      print('✅ Xodimlar maoshi yuklandi');
    } catch (e) {
      print('❌ Load staff salaries error: $e');
    }
  }

  // ==================== O'QUVCHILAR QARZLARI ====================
  Future<void> loadStudentDebts() async {
    try {
      var studentsQuery = supabase
          .from('students')
          .select(
            'id, first_name, last_name, phone, monthly_fee, discount_percent, enrollment_date',
          )
          .eq('status', 'active');

      if (selectedBranchId.value != 'all') {
        studentsQuery = studentsQuery.eq('branch_id', selectedBranchId.value);
      }

      final students = await studentsQuery;

      List<Map<String, dynamic>> debtorsList = [];
      double totalDebts = 0.0;

      for (var student in students) {
        final studentId = student['id'].toString();
        final monthlyFee = _toDouble(student['monthly_fee']);
        final discountPercent = _toDouble(student['discount_percent']);
        final expectedMonthlyFee =
            monthlyFee - (monthlyFee * discountPercent / 100);
        final enrollmentDate = DateTime.parse(student['enrollment_date']);
        final now = DateTime.now();

        // Necha oy o'tganini hisoblash
        int monthsPassed =
            (now.year - enrollmentDate.year) * 12 +
            (now.month - enrollmentDate.month);
        if (now.day < enrollmentDate.day) monthsPassed--;
        if (monthsPassed < 0) monthsPassed = 0;

        // Kutilayotgan jami to'lov
        double totalExpected = expectedMonthlyFee * monthsPassed;

        // To'langan jami summa
        final paymentsData = await supabase
            .from('payments')
            .select('final_amount')
            .eq('student_id', studentId)
            .eq('payment_status', 'paid');

        double totalPaid = _calculateSum(paymentsData, 'final_amount');

        // Qarz
        double debt = totalExpected - totalPaid;

        if (debt > 0) {
          totalDebts += debt;

          debtorsList.add({
            'student_id': studentId,
            'first_name': student['first_name'] ?? '',
            'last_name': student['last_name'] ?? '',
            'phone': student['phone'],
            'debt_amount': debt,
            'months_count': monthsPassed,
            'monthly_fee': monthlyFee,
            'discount_percent': discountPercent,
            'total_paid': totalPaid,
            'total_expected': totalExpected,
          });
        }
      }

      // Eng katta qarzdorlar
      debtorsList.sort(
        (a, b) =>
            (b['debt_amount'] as double).compareTo(a['debt_amount'] as double),
      );

      totalStudentDebt.value = totalDebts;
      debtorStudentsCount.value = debtorsList.length;
      topDebtors.value = debtorsList.take(5).toList();
      allDebtorStudents.value = debtorsList;

      print(
        '✅ Qarzdorlar yuklandi: ${debtorsList.length} ta, jami: $totalDebts',
      );
    } catch (e) {
      print('❌ Load student debts error: $e');
    }
  }

  // ==================== XARAJATLAR ====================
  Future<void> loadExpenses() async {
    try {
      final dateRange = _getDateRange();

      var expensesQuery = supabase
          .from('expenses')
          .select('category, amount')
          .gte('expense_date', dateRange['start']!)
          .lte('expense_date', dateRange['end']!);

      if (selectedBranchId.value != 'all') {
        expensesQuery = expensesQuery.eq('branch_id', selectedBranchId.value);
      }

      final expensesData = await expensesQuery;

      salaryExpenses.value = expensesData
          .where((e) => e['category'] == 'salary')
          .fold<double>(0.0, (sum, e) => sum + _toDouble(e['amount']));

      utilityExpenses.value = expensesData
          .where((e) => e['category'] == 'utilities')
          .fold<double>(0.0, (sum, e) => sum + _toDouble(e['amount']));

      foodExpenses.value = expensesData
          .where((e) => e['category'] == 'food')
          .fold<double>(0.0, (sum, e) => sum + _toDouble(e['amount']));

      transportExpenses.value = expensesData
          .where((e) => e['category'] == 'transport')
          .fold<double>(0.0, (sum, e) => sum + _toDouble(e['amount']));

      otherExpenses.value = expensesData
          .where(
            (e) =>
                e['category'] != 'salary' &&
                e['category'] != 'utilities' &&
                e['category'] != 'food' &&
                e['category'] != 'transport',
          )
          .fold<double>(0.0, (sum, e) => sum + _toDouble(e['amount']));

      print('✅ Xarajatlar yuklandi');
    } catch (e) {
      print('❌ Load expenses error: $e');
    }
  }

  void _calculateAdditionalMetrics() {
    // Qo'shimcha hisob-kitoblar
  }

  // ==================== FILTRLAR ====================

  void changePeriod(String period) {
    selectedPeriod.value = period;
    refreshData();
  }

  void changeYear(int year) {
    selectedYear.value = year;
    refreshData();
  }

  void previousMonth() {
    selectedMonth.value = DateTime(
      selectedMonth.value.year,
      selectedMonth.value.month - 1,
      1,
    );
    loadMonthlyCollection();
    loadClasses();
  }

  void nextMonth() {
    final candidate = DateTime(
      selectedMonth.value.year,
      selectedMonth.value.month + 1,
      1,
    );
    final now = DateTime.now();

    // kelajak oyga chiqmaslik
    if (candidate.isAfter(DateTime(now.year, now.month, 1))) return;

    selectedMonth.value = candidate;
    loadMonthlyCollection();
    loadClasses();
  }

  // ==================== SANA ORALIQLARI ====================
  Map<String, String> _getDateRange() {
    DateTime start;
    DateTime end = DateTime.now();

    switch (selectedPeriod.value) {
      case 'today':
        start = DateTime(end.year, end.month, end.day);
        break;
      case 'week':
        start = end.subtract(Duration(days: end.weekday - 1));
        break;
      case 'month':
        start = DateTime(end.year, end.month, 1);
        break;
      case 'year':
        start = DateTime(end.year, 1, 1);
        break;
      default:
        start = DateTime(2020, 1, 1);
    }

    return {'start': start.toIso8601String(), 'end': end.toIso8601String()};
  }

  Map<String, String> _getPreviousDateRange() {
    final current = _getDateRange();
    final currentStart = DateTime.parse(current['start']!);
    final currentEnd = DateTime.parse(current['end']!);
    final duration = currentEnd.difference(currentStart);

    final previousEnd = currentStart.subtract(const Duration(seconds: 1));
    final previousStart = previousEnd.subtract(duration);

    return {
      'start': previousStart.toIso8601String(),
      'end': previousEnd.toIso8601String(),
    };
  }

  // ==================== HARAKATLAR ====================
  void toggleClassExpansion(String classId) {
    if (expandedClassId.value == classId) {
      expandedClassId.value = '';
    } else {
      expandedClassId.value = classId;
      loadClassStudents(classId); // ✅ bu yerda yuklaymiz
    }
  }

  void toggleStudentExpansion(String studentId) {
    if (expandedStudentId.value == studentId) {
      expandedStudentId.value = '';
    } else {
      expandedStudentId.value = studentId;
      loadStudentPaymentHistory(studentId);
    }
  }

  void showStudentDetails(String studentId) {
    Get.toNamed('/student-detail', arguments: {'studentId': studentId});
  }

  void showAllPayments() {
    Get.dialog(
      Dialog(
        child: Container(
          width: 1000,
          height: 700,
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.payment, color: Colors.green, size: 32),
                  const SizedBox(width: 12),
                  const Text(
                    'Barcha To\'lovlar',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Obx(
                  () => ListView.builder(
                    itemCount: allPayments.length,
                    itemBuilder: (context, index) {
                      final payment = allPayments[index];
                      final student = payment['students'];
                      final studentName = student != null
                          ? '${student['first_name']} ${student['last_name']}'
                          : 'Noma\'lum';
                      final amount = _toDouble(payment['final_amount']);
                      final discount = _toDouble(payment['discount_amount']);
                      final discountPercent = _toDouble(
                        payment['discount_percent'],
                      );
                      final date = payment['payment_date'];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.green.shade100,
                            child: Text('${index + 1}'),
                          ),
                          title: Text(
                            studentName,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            'Sana: ${_formatDate(date)}${discount > 0 ? ' • Chegirma: $discountPercent%' : ''}',
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${_formatCurrency(amount)} so\'m',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              if (discount > 0)
                                Text(
                                  'Chegirma: ${_formatCurrency(discount)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showAllExpenses() {
    Get.dialog(
      Dialog(
        child: Container(
          width: 1000,
          height: 700,
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.receipt_long, color: Colors.red, size: 32),
                  const SizedBox(width: 12),
                  const Text(
                    'Barcha Xarajatlar',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Obx(
                  () => ListView.builder(
                    itemCount: allExpenses.length,
                    itemBuilder: (context, index) {
                      final expense = allExpenses[index];
                      final title = expense['title'] ?? '';
                      final category = expense['category'] ?? '';
                      final amount = _toDouble(expense['amount']);
                      final date = expense['expense_date'];
                      final notes = expense['notes'] ?? '';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.red.shade100,
                            child: Text('${index + 1}'),
                          ),
                          title: Text(
                            title,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            'Kategoriya: $category • Sana: ${_formatDate(date)}${notes.isNotEmpty ? '\n$notes' : ''}',
                          ),
                          trailing: Text(
                            '${_formatCurrency(amount)} so\'m',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> pickMonth(BuildContext context) async {
    final now = DateTime.now();

    // TODO: maktab boshlangan sanaga moslab o‘zgartiring
    final firstDate = DateTime(2020, 9, 1);

    final picked = await showDatePicker(
      context: context,
      initialDate: selectedMonth.value,
      firstDate: firstDate,
      lastDate: DateTime(now.year, now.month, 31),
      helpText: 'Oyni tanlang',
    );

    if (picked != null) {
      selectedMonth.value = DateTime(picked.year, picked.month, 1);
      // Faqat shu oyning maʼlumotlarini qayta yuklaymiz
      loadMonthlyCollection();
      loadClasses();
    }
  }

  void showAllDebtors() {
    Get.dialog(
      Dialog(
        child: Container(
          width: 1000,
          height: 700,
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.warning_amber,
                    color: Colors.orange,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Barcha Qarzdorlar',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  Text(
                    'Jami: ${_formatCurrency(totalStudentDebt.value)} so\'m',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Obx(
                  () => ListView.builder(
                    itemCount: allDebtorStudents.length,
                    itemBuilder: (context, index) {
                      final debtor = allDebtorStudents[index];
                      final name =
                          '${debtor['first_name']} ${debtor['last_name']}';
                      final debt = _toDouble(debtor['debt_amount']);
                      final months = debtor['months_count'];
                      final totalExpected = _toDouble(debtor['total_expected']);
                      final totalPaid = _toDouble(debtor['total_paid']);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ExpansionTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.orange.shade100,
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text('$months oy qarzdor'),
                          trailing: Text(
                            '${_formatCurrency(debt)} so\'m',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildInfoRow(
                                    'Kutilgan',
                                    '${_formatCurrency(totalExpected)} so\'m',
                                  ),
                                  _buildInfoRow(
                                    'To\'langan',
                                    '${_formatCurrency(totalPaid)} so\'m',
                                  ),
                                  _buildInfoRow(
                                    'Qarz',
                                    '${_formatCurrency(debt)} so\'m',
                                  ),
                                  if (debtor['phone'] != null)
                                    _buildInfoRow('Telefon', debtor['phone']),
                                  const SizedBox(height: 12),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      Get.back();
                                      showStudentDetails(debtor['student_id']);
                                    },
                                    icon: const Icon(Icons.visibility),
                                    label: const Text('Batafsil ko\'rish'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> exportReport() async {
    if (isExporting.value) return;
    isExporting.value = true;

    try {
      final pdf = pw.Document();
      final now = DateTime.now();
      final dateStr = DateFormat('dd.MM.yyyy HH:mm').format(now);

      pw.TableRow _row(String label, String value) {
        return pw.TableRow(
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 4),
              child: pw.Text(label),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 4),
              child: pw.Text(value, textAlign: pw.TextAlign.right),
            ),
          ],
        );
      }

      pdf.addPage(
        pw.MultiPage(
          margin: const pw.EdgeInsets.all(24),
          build: (context) => [
            pw.Text(
              'Moliya Hisoboti',
              style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            pw.Text('Sana: $dateStr'),
            pw.SizedBox(height: 24),

            pw.Text(
              'Umumiy statistika',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            pw.Table(
              columnWidths: {
                0: const pw.FlexColumnWidth(2),
                1: const pw.FlexColumnWidth(1),
              },
              children: [
                _row(
                  'Jami tushum',
                  '${_formatCurrency(totalRevenue.value)} so\'m',
                ),
                _row(
                  'Jami xarajat',
                  '${_formatCurrency(totalExpenses.value)} so\'m',
                ),
                _row('Sof foyda', '${_formatCurrency(netProfit.value)} so\'m'),
                _row(
                  'Jami qarz',
                  '${_formatCurrency(totalStudentDebt.value)} so\'m',
                ),
              ],
            ),

            pw.SizedBox(height: 16),
            pw.Text(
              'Eng katta qarzdorlar',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            if (topDebtors.isNotEmpty)
              pw.Table.fromTextArray(
                headers: ['#', 'O\'quvchi', 'Qarz', 'Oy'],
                data: [
                  for (int i = 0; i < topDebtors.length; i++)
                    [
                      (i + 1).toString(),
                      '${topDebtors[i]['first_name']} ${topDebtors[i]['last_name']}',
                      '${_formatCurrency(_toDouble(topDebtors[i]['debt_amount']))} so\'m',
                      topDebtors[i]['months_count'].toString(),
                    ],
                ],
              )
            else
              pw.Text('Qarzdorlar yo\'q'),
          ],
        ),
      );

      final bytes = await pdf.save();

      await Printing.sharePdf(
        bytes: bytes,
        filename: 'finance_${DateFormat('yyyyMMdd_HHmm').format(now)}.pdf',
      );

      Get.snackbar(
        'Muvaffaqiyatli',
        'Hisobot PDF formatida tayyor bo\'ldi',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print('❌ Export PDF error: $e');
      _showError('PDF yaratishda xato: $e');
    } finally {
      isExporting.value = false;
    }
  }

  // ==================== YORDAMCHI FUNKSIYALAR ====================
  double _calculateSum(List<dynamic> data, String field) {
    return data.fold<double>(0.0, (sum, item) => sum + _toDouble(item[field]));
  }

  double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  String _formatCurrency(double amount) {
    return NumberFormat('#,###', 'uz').format(amount);
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd.MM.yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    Get.snackbar(
      'Xato',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.shade100,
    );
  }

  @override
  void onClose() {
    classStudents.clear();
    super.onClose();
  }
  // Xodim maoshini mukammal hisoblash

  Future<Map<String, dynamic>> calculateStaffSalary(
    String staffId,
    int year,
    int month,
  ) async {
    try {
      // 1. Xodim ma'lumotlari
      final staff = await supabase
          .from('staff')
          .select(
            '*, salary_type, base_salary, hourly_rate, expected_hours_per_month',
          )
          .eq('id', staffId)
          .single();

      final salaryType = staff['salary_type'];

      // 2. Davomat asosida hisoblash
      // Eslatma: Agar sizda 'calculate_staff_worked_hours' RPC funksiyasi bo'lmasa,
      // bu qism xato berishi mumkin. Unday holda oddiyroq hisoblash usuliga o'tish kerak.
      Map<String, dynamic> workedData = {
        'worked_hours': 0,
        'worked_days': 0,
        'overtime_hours': 0,
        'total_sessions': 0,
      };

      try {
        final rpcResult = await supabase
            .rpc(
              'calculate_staff_worked_hours',
              params: {'p_staff_id': staffId, 'p_year': year, 'p_month': month},
            )
            .maybeSingle(); // maybeSingle xatolikni oldini oladi

        if (rpcResult != null) workedData = rpcResult;
      } catch (_) {
        // RPC yo'q bo'lsa yoki xato bersa, default qiymatlar qoladi
        // Yoki oddiyroq query yozish mumkin
      }

      double baseAmount = 0.0;
      double overtimeAmount = 0.0;

      if (salaryType == 'hourly') {
        final hourlyRate = _toDouble(staff['hourly_rate']);
        final workedHours = _toDouble(workedData['worked_hours']);
        final overtimeHours = _toDouble(workedData['overtime_hours']);
        baseAmount = workedHours * hourlyRate;
        overtimeAmount = overtimeHours * (hourlyRate * 1.5);
      } else if (salaryType == 'fixed') {
        baseAmount = _toDouble(staff['base_salary']);
      } else if (salaryType == 'daily') {
        final dailyRate = _toDouble(staff['daily_rate']);
        final workedDays = workedData['worked_days'] as int;
        baseAmount = dailyRate * workedDays;
      }

      // 3. Bonuslar va jarimalar
      final adjustments = await supabase
          .from('salary_adjustments')
          .select('adjustment_type, amount')
          .eq('staff_id', staffId)
          .gte('applied_date', '$year-${month.toString().padLeft(2, '0')}-01')
          .lte('applied_date', '$year-${month.toString().padLeft(2, '0')}-31');

      double bonusAmount = 0.0;
      double penaltyAmount = 0.0;
      double advanceDeduction = 0.0;
      double loanDeduction = 0.0;

      for (var adj in adjustments) {
        final amount = _toDouble(adj['amount']);
        switch (adj['adjustment_type']) {
          case 'bonus':
            bonusAmount += amount;
            break;
          case 'penalty':
            penaltyAmount += amount;
            break;
          case 'advance':
            advanceDeduction += amount;
            break;
          case 'loan':
            loanDeduction += amount;
            break;
        }
      }

      // 4. Gross va Net hisoblash
      final grossAmount = baseAmount + overtimeAmount + bonusAmount;
      // Net amount manfiy bo'lmasligi kerak
      double netAmount =
          grossAmount - penaltyAmount - advanceDeduction - loanDeduction;
      if (netAmount < 0) netAmount = 0;

      // 5. HAQIQATDA TO'LANGAN SUMMANI TEKSHIRISH (TUZATILGAN QISM)
      final paidOperations = await supabase
          .from('salary_operations')
          .select('net_amount')
          .eq('staff_id', staffId)
          .eq('period_year', year)
          .eq('period_month', month)
          .eq('is_paid', true);

      double actuallyPaid = 0.0;
      for (var op in paidOperations) {
        actuallyPaid += _toDouble(op['net_amount']);
      }

      // QOLDIQ
      double remainingBalance = netAmount - actuallyPaid;
      if (remainingBalance < 0) remainingBalance = 0;

      return {
        'staff_id': staffId,
        'period_month': month,
        'period_year': year,
        'salary_type': salaryType,
        'base_amount': baseAmount,
        'gross_amount': grossAmount,
        'net_amount': netAmount,
        'actually_paid': actuallyPaid,
        'remaining_balance': remainingBalance,
        'bonus_amount': bonusAmount,
        'penalty_amount': penaltyAmount,
      };
    } catch (e) {
      print('❌ Calculate staff salary error ($staffId): $e');
      return {};
    }
  }

  // Barcha xodimlar maoshini yuklash (oy bo'yicha)
  Future<void> loadStaffSalariesDetailed() async {
  try {
    var staffQuery = supabase
        .from('staff')
        .select('id, first_name, last_name, position, salary_type')
        .eq('status', 'active');

    if (selectedBranchId.value != 'all') {
      staffQuery = staffQuery.eq('branch_id', selectedBranchId.value);
    }

    final staffList = await staffQuery;
    List<Map<String, dynamic>> processedStaff = [];

    // Hisoblagichlarni 0 ga tushiramiz
    double sumNet = 0.0;
    double sumPaid = 0.0;
    double sumRemaining = 0.0;

    for (var staff in staffList) {
      final staffId = staff['id'].toString();
      
      final salaryData = await calculateStaffSalary(
        staffId,
        selectedYear.value,
        selectedMonth.value.month,
      );

      if (salaryData.isNotEmpty) {
        double net = _toDouble(salaryData['net_amount']);
        double paid = _toDouble(salaryData['actually_paid']);
        double remaining = _toDouble(salaryData['remaining_balance']);

        // Yig'indilarni hisoblash
        sumNet += net;
        sumPaid += paid;
        sumRemaining += remaining;

        processedStaff.add({
          ...staff,
          ...salaryData,
        });
      }
    }

    staffSalaryList.value = processedStaff;
    
    // Observables (ekrandagi raqamlar) ni yangilash
    totalSalaryPayable.value = sumNet;
    totalSalaryPaid.value = sumPaid;
    totalSalaryRemaining.value = sumRemaining;
    
    // totalSalaryExpense ni ham yangilab qo'yamiz (eski kod buzilmasligi uchun)
    totalSalaryExpense.value = sumPaid; 

    print('✅ Maoshlar: Jami=$sumNet, To\'landi=$sumPaid, Qarz=$sumRemaining');
  } catch (e) {
    print('❌ Load detailed salaries error: $e');
  }
}

  // O'quvchi to'lovini to'g'ri hisoblash (kanikulasiz)
  Future<double> calculateStudentExpectedFee(
    String studentId,
    int year,
    int month,
  ) async {
    try {
      final result = await supabase.rpc(
        'calculate_student_monthly_fee',
        params: {'p_student_id': studentId, 'p_year': year, 'p_month': month},
      );
      return _toDouble(result);
    } catch (e) {
      print('❌ Calculate student fee error: $e');
      return 0.0;
    }
  }
}
