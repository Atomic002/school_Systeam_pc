// lib/presentation/controllers/dashboard_controller.dart
// MUKAMMAL - To'liq real-time dashboard controller

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../data/services/supabase_service.dart';
import 'dart:async';

class DashboardController extends GetxController {
  final SupabaseService _supabaseService = Get.find<SupabaseService>();
  
  // Loading states
  var isLoading = true.obs;
  var isRefreshing = false.obs;
  
  // Branch selection
  var branches = <Map<String, dynamic>>[].obs;
  var selectedBranchId = ''.obs;
  
  // Financial metrics
  var todayRevenue = 0.0.obs;
  var todayPaymentsCount = 0.obs;
  var monthRevenue = 0.0.obs;
  var monthPaymentsCount = 0.obs;
  var yearRevenue = 0.0.obs;
  var todayExpenses = 0.0.obs;
  var monthExpenses = 0.0.obs;
  var netProfit = 0.0.obs;
  var monthNetProfit = 0.0.obs;
  
  // Balance
  var totalBalance = 0.0.obs;
  var cashBalance = 0.0.obs;
  var cardBalance = 0.0.obs;
  var transferBalance = 0.0.obs;
  
  // Students metrics
  var totalStudents = 0.obs;
  var activeStudents = 0.obs;
  var newStudentsThisMonth = 0.obs;
  var debtorStudents = 0.obs;
  var totalStudentDebt = 0.0.obs;
  var studentsWithDebt = <Map<String, dynamic>>[].obs;
  
  // Staff metrics
  var totalStaff = 0.obs;
  var teachers = 0.obs;
  var otherStaff = 0.obs;
  var totalMonthlySalary = 0.0.obs;
  var paidSalaries = 0.0.obs;
  var unpaidSalaries = 0.0.obs;
  var totalSalaryDebt = 0.0.obs;
  var staffWithUnpaidSalary = <Map<String, dynamic>>[].obs;
  var allUnpaidSalaries = <Map<String, dynamic>>[].obs;
  
  // Charts data
  var monthlyRevenueData = <Map<String, dynamic>>[].obs;
  
  // Classes details
  var classesDetails = <Map<String, dynamic>>[].obs;
  
  // Recent activities
  var recentPayments = <Map<String, dynamic>>[].obs;
  var recentExpenses = <Map<String, dynamic>>[].obs;
  
  // Notifications
  var notifications = <Map<String, dynamic>>[].obs;
  var unreadNotifications = 0.obs;
  
  // Subscription
  var subscriptionEndDate = Rxn<DateTime>();
  var daysUntilExpiry = 0.obs;
  var isSubscriptionExpiring = false.obs;
  
  // Auto-refresh timer
  Timer? _refreshTimer;
  
  @override
  void onInit() {
    super.onInit();
    _initializeData();
    _setupAutoRefresh();
  }
  
  @override
  void onClose() {
    _refreshTimer?.cancel();
    super.onClose();
  }
  
  Future<void> _initializeData() async {
    try {
      isLoading.value = true;
      
      // Load branches
      await _loadBranches();
      
      // Load all data
      await _loadAllData();
      
      // Check subscription
      await _checkSubscription();
      
      // Load notifications
      await _loadNotifications();
      
    } catch (e) {
      print('Error initializing dashboard: $e');
      Get.snackbar(
        'Xato',
        'Ma\'lumotlar yuklanishda xatolik yuz berdi',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  void _setupAutoRefresh() {
    // Auto-refresh every 5 minutes
    _refreshTimer = Timer.periodic(Duration(minutes: 5), (timer) {
      refreshData();
    });
  }
  
  Future<void> _loadBranches() async {
    try {
      final response = await _supabaseService.client
          .from('branches')
          .select('id, name, is_main')
          .eq('is_active', true)
          .order('is_main', ascending: false);
      
      branches.value = List<Map<String, dynamic>>.from(response);
      
      if (branches.isNotEmpty) {
        // Select main branch or first branch
        final mainBranch = branches.firstWhere(
          (b) => b['is_main'] == true,
          orElse: () => branches.first,
        );
        selectedBranchId.value = mainBranch['id'];
      }
    } catch (e) {
      print('Error loading branches: $e');
    }
  }
  
  Future<void> changeBranch(String branchId) async {
    selectedBranchId.value = branchId;
    await _loadAllData();
  }
  
  Future<void> refreshData() async {
    if (isRefreshing.value) return;
    
    try {
      isRefreshing.value = true;
      await _loadAllData();
      await _loadNotifications();
      
      Get.snackbar(
        'Muvaffaqiyatli',
        'Ma\'lumotlar yangilandi',
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 2),
      );
    } catch (e) {
      print('Error refreshing data: $e');
    } finally {
      isRefreshing.value = false;
    }
  }
  
  Future<void> _loadAllData() async {
    await Future.wait([
      _loadFinancialMetrics(),
      _loadStudentsMetrics(),
      _loadStaffMetrics(),
      _loadMonthlyRevenueChart(),
      _loadClassesDetails(),
      _loadRecentActivities(),
      _loadCashRegisterBalance(),
    ]);
  }
  
  Future<void> _loadFinancialMetrics() async {
    try {
      final now = DateTime.now();
      final today = DateFormat('yyyy-MM-dd').format(now);
      final monthStart = DateFormat('yyyy-MM-dd').format(DateTime(now.year, now.month, 1));
      final yearStart = DateFormat('yyyy-MM-dd').format(DateTime(now.year, 1, 1));
      
      // Today's revenue
      final todayPaymentsResponse = await _supabaseService.client
          .from('payments')
          .select('final_amount')
          .eq('branch_id', selectedBranchId.value)
          .eq('payment_status', 'paid')
          .gte('payment_date', today)
          .lte('payment_date', today);
      
      todayRevenue.value = todayPaymentsResponse.fold(
        0.0,
        (sum, p) => sum + ((p['final_amount'] ?? 0) as num).toDouble(),
      );
      todayPaymentsCount.value = todayPaymentsResponse.length;
      
      // Month's revenue
      final monthPaymentsResponse = await _supabaseService.client
          .from('payments')
          .select('final_amount')
          .eq('branch_id', selectedBranchId.value)
          .eq('payment_status', 'paid')
          .gte('payment_date', monthStart);
      
      monthRevenue.value = monthPaymentsResponse.fold(
        0.0,
        (sum, p) => sum + ((p['final_amount'] ?? 0) as num).toDouble(),
      );
      monthPaymentsCount.value = monthPaymentsResponse.length;
      
      // Year's revenue
      final yearPaymentsResponse = await _supabaseService.client
          .from('payments')
          .select('final_amount')
          .eq('branch_id', selectedBranchId.value)
          .eq('payment_status', 'paid')
          .gte('payment_date', yearStart);
      
      yearRevenue.value = yearPaymentsResponse.fold(
        0.0,
        (sum, p) => sum + ((p['final_amount'] ?? 0) as num).toDouble(),
      );
      
      // Today's expenses
      final todayExpensesResponse = await _supabaseService.client
          .from('expenses')
          .select('amount')
          .eq('branch_id', selectedBranchId.value)
          .gte('expense_date', today)
          .lte('expense_date', today);
      
      todayExpenses.value = todayExpensesResponse.fold(
        0.0,
        (sum, e) => sum + ((e['amount'] ?? 0) as num).toDouble(),
      );
      
      // Month's expenses
      final monthExpensesResponse = await _supabaseService.client
          .from('expenses')
          .select('amount')
          .eq('branch_id', selectedBranchId.value)
          .gte('expense_date', monthStart);
      
      monthExpenses.value = monthExpensesResponse.fold(
        0.0,
        (sum, e) => sum + ((e['amount'] ?? 0) as num).toDouble(),
      );
      
      // Calculate net profit
      netProfit.value = todayRevenue.value - todayExpenses.value;
      monthNetProfit.value = monthRevenue.value - monthExpenses.value;
      
    } catch (e) {
      print('Error loading financial metrics: $e');
    }
  }
  
  Future<void> _loadStudentsMetrics() async {
    try {
      final now = DateTime.now();
      final monthStart = DateTime(now.year, now.month, 1);
      
      // Total and active students
      final studentsResponse = await _supabaseService.client
          .from('students')
          .select('id, status, created_at')
          .eq('branch_id', selectedBranchId.value);
      
      totalStudents.value = studentsResponse.length;
      activeStudents.value = studentsResponse.where((s) => s['status'] == 'active').length;
      
      newStudentsThisMonth.value = studentsResponse.where((s) {
        final createdAt = DateTime.parse(s['created_at']);
        return createdAt.isAfter(monthStart);
      }).length;
      
      // Students with debt - calculate from payments
      final paymentsWithDebtResponse = await _supabaseService.client
          .from('payments')
          .select('''
            student_id,
            remaining_debt,
            students!inner(
              id,
              first_name,
              last_name,
              phone,
              parent_phone,
              class_id,
              classes(name)
            )
          ''')
          .eq('students.branch_id', selectedBranchId.value)
          .gt('remaining_debt', 0)
          .order('remaining_debt', ascending: false);
      
      // Group by student_id and sum debts
      final Map<String, Map<String, dynamic>> debtMap = {};
      
      for (var payment in paymentsWithDebtResponse) {
        final studentId = payment['student_id'];
        final debt = ((payment['remaining_debt'] ?? 0) as num).toDouble();
        final student = payment['students'];
        
        if (debtMap.containsKey(studentId)) {
          debtMap[studentId]!['total_debt'] = 
              (debtMap[studentId]!['total_debt'] as double) + debt;
        } else {
          debtMap[studentId] = {
            'student_id': studentId,
            'student_name': '${student['first_name']} ${student['last_name']}',
            'class_name': student['classes']?['name'] ?? 'Sinf biriktirilmagan',
            'phone': student['phone'] ?? '',
            'parent_phone': student['parent_phone'] ?? '',
            'total_debt': debt,
          };
        }
      }
      
      studentsWithDebt.value = debtMap.values.toList()
        ..sort((a, b) => (b['total_debt'] as double).compareTo(a['total_debt'] as double));
      
      debtorStudents.value = studentsWithDebt.length;
      totalStudentDebt.value = studentsWithDebt.fold(
        0.0,
        (sum, d) => sum + (d['total_debt'] as num).toDouble(),
      );
      
    } catch (e) {
      print('Error loading students metrics: $e');
    }
  }
  
  Future<void> _loadStaffMetrics() async {
    try {
      // Total staff
      final staffResponse = await _supabaseService.client
          .from('staff')
          .select('id, position, is_teacher, base_salary, status')
          .eq('branch_id', selectedBranchId.value)
          .eq('status', 'active');
      
      totalStaff.value = staffResponse.length;
      teachers.value = staffResponse.where((s) => s['is_teacher'] == true).length;
      otherStaff.value = totalStaff.value - teachers.value;
      
      totalMonthlySalary.value = staffResponse.fold(
        0.0,
        (sum, s) => sum + ((s['base_salary'] ?? 0) as num).toDouble(),
      );
      
      // Unpaid salaries
      final now = DateTime.now();
      final currentMonth = now.month;
      final currentYear = now.year;
      
      final unpaidSalariesResponse = await _supabaseService.client
          .from('salary_operations')
          .select('''
            id,
            staff_id,
            net_amount,
            period_month,
            period_year,
            is_paid,
            staff!inner(
              first_name,
              last_name,
              position,
              phone,
              branch_id
            )
          ''')
          .eq('staff.branch_id', selectedBranchId.value)
          .eq('period_month', currentMonth)
          .eq('period_year', currentYear)
          .eq('is_paid', false);
      
      staffWithUnpaidSalary.value = unpaidSalariesResponse.map((s) {
        final staff = s['staff'];
        return {
          'salary_id': s['id'],
          'staff_id': s['staff_id'],
          'staff_name': '${staff['first_name']} ${staff['last_name']}',
          'position': staff['position'],
          'phone': staff['phone'] ?? '',
          'amount': s['net_amount'],
          'period': _formatPeriod(s['period_month'], s['period_year']),
          'period_month': s['period_month'],
          'period_year': s['period_year'],
        };
      }).toList();
      
      unpaidSalaries.value = staffWithUnpaidSalary.fold(
        0.0,
        (sum, s) => sum + ((s['amount'] ?? 0) as num).toDouble(),
      );
      
      // All unpaid salaries
      final allUnpaidResponse = await _supabaseService.client
          .from('salary_operations')
          .select('''
            id,
            staff_id,
            net_amount,
            period_month,
            period_year,
            staff!inner(
              first_name,
              last_name,
              position,
              phone,
              branch_id
            )
          ''')
          .eq('staff.branch_id', selectedBranchId.value)
          .eq('is_paid', false)
          .order('period_year', ascending: false)
          .order('period_month', ascending: false);
      
      allUnpaidSalaries.value = allUnpaidResponse.map((s) {
        final staff = s['staff'];
        return {
          'salary_id': s['id'],
          'staff_id': s['staff_id'],
          'staff_name': '${staff['first_name']} ${staff['last_name']}',
          'position': staff['position'],
          'phone': staff['phone'] ?? '',
          'amount': s['net_amount'],
          'period': _formatPeriod(s['period_month'], s['period_year']),
        };
      }).toList();
      
      totalSalaryDebt.value = allUnpaidSalaries.fold(
        0.0,
        (sum, s) => sum + ((s['amount'] ?? 0) as num).toDouble(),
      );
      
    } catch (e) {
      print('Error loading staff metrics: $e');
    }
  }
  
  Future<void> _loadMonthlyRevenueChart() async {
    try {
      final now = DateTime.now();
      final monthlyData = <Map<String, dynamic>>[];
      
      for (int i = 11; i >= 0; i--) {
        final date = DateTime(now.year, now.month - i, 1);
        final monthStart = DateFormat('yyyy-MM-dd').format(date);
        final monthEnd = DateFormat('yyyy-MM-dd').format(
          DateTime(date.year, date.month + 1, 0),
        );
        
        final revenueResponse = await _supabaseService.client
            .from('payments')
            .select('final_amount')
            .eq('branch_id', selectedBranchId.value)
            .eq('payment_status', 'paid')
            .gte('payment_date', monthStart)
            .lte('payment_date', monthEnd);
        
        final revenue = revenueResponse.fold(
          0.0,
          (sum, p) => sum + ((p['final_amount'] ?? 0) as num).toDouble(),
        );
        
        final expenseResponse = await _supabaseService.client
            .from('expenses')
            .select('amount')
            .eq('branch_id', selectedBranchId.value)
            .gte('expense_date', monthStart)
            .lte('expense_date', monthEnd);
        
        final expense = expenseResponse.fold(
          0.0,
          (sum, e) => sum + ((e['amount'] ?? 0) as num).toDouble(),
        );
        
        monthlyData.add({
          'month': _getShortMonthName(date.month),
          'revenue': revenue,
          'expense': expense,
        });
      }
      
      monthlyRevenueData.value = monthlyData;
      
    } catch (e) {
      print('Error loading monthly revenue chart: $e');
    }
  }
  
  Future<void> _loadClassesDetails() async {
    try {
      final classesResponse = await _supabaseService.client
          .from('classes')
          .select('''
            id,
            name,
            grade,
            monthly_fee,
            room_id,
            main_teacher_id,
            rooms(name),
            staff(first_name, last_name, phone)
          ''')
          .eq('branch_id', selectedBranchId.value)
          .eq('is_active', true);
      
      final details = <Map<String, dynamic>>[];
      
      for (var cls in classesResponse) {
        final studentsResponse = await _supabaseService.client
            .from('students')
            .select('id, monthly_fee')
            .eq('class_id', cls['id'])
            .eq('status', 'active');
        
        final studentCount = studentsResponse.length;
        
        double totalClassFee = studentsResponse.fold(
          0.0,
          (sum, s) => sum + ((s['monthly_fee'] ?? cls['monthly_fee'] ?? 0) as num).toDouble(),
        );
        
        final teacher = cls['staff'];
        final room = cls['rooms'];
        
        details.add({
          'class_id': cls['id'],
          'class_name': cls['name'],
          'class_level': cls['grade'] ?? '-',
          'room_name': room?['name'] ?? 'Biriktirilmagan',
          'teacher_name': teacher != null
              ? '${teacher['first_name']} ${teacher['last_name']}'
              : 'Biriktirilmagan',
          'teacher_phone': teacher?['phone'] ?? '',
          'student_count': studentCount,
          'total_monthly_fee': totalClassFee,
        });
      }
      
      classesDetails.value = details;
      
    } catch (e) {
      print('Error loading classes details: $e');
    }
  }
  
  Future<void> _loadRecentActivities() async {
    try {
      final paymentsResponse = await _supabaseService.client
          .from('payments')
          .select('''
            id,
            final_amount,
            payment_date,
            payment_time,
            payment_method,
            students!inner(first_name, last_name, classes(name))
          ''')
          .eq('branch_id', selectedBranchId.value)
          .eq('payment_status', 'paid')
          .order('payment_date', ascending: false)
          .order('payment_time', ascending: false)
          .limit(10);
      
      recentPayments.value = paymentsResponse.map((p) {
        final student = p['students'];
        return {
          'id': p['id'],
          'amount': p['final_amount'],
          'payment_date': p['payment_date'],
          'payment_method': p['payment_method'],
          'students': {
            'first_name': student['first_name'],
            'last_name': student['last_name'],
            'class_name': student['classes']?['name'] ?? '',
          },
        };
      }).toList();
      
      final expensesResponse = await _supabaseService.client
          .from('expenses')
          .select('id, title, amount, expense_date, category')
          .eq('branch_id', selectedBranchId.value)
          .order('expense_date', ascending: false)
          .limit(10);
      
      recentExpenses.value = List<Map<String, dynamic>>.from(expensesResponse);
      
    } catch (e) {
      print('Error loading recent activities: $e');
    }
  }
  
  Future<void> _loadCashRegisterBalance() async {
    try {
      final response = await _supabaseService.client
          .from('cash_register')
          .select('payment_method, current_balance')
          .eq('branch_id', selectedBranchId.value);
      
      double cash = 0.0;
      double card = 0.0;
      double transfer = 0.0;
      
      for (var register in response) {
        final method = register['payment_method'];
        final balance = ((register['current_balance'] ?? 0) as num).toDouble();
        
        switch (method) {
          case 'cash':
            cash = balance;
            break;
          case 'card':
          case 'terminal':
            card += balance;
            break;
          case 'click':
          case 'bank':
            transfer += balance;
            break;
        }
      }
      
      cashBalance.value = cash;
      cardBalance.value = card;
      transferBalance.value = transfer;
      totalBalance.value = cash + card + transfer;
      
    } catch (e) {
      print('Error loading cash register balance: $e');
    }
  }
  
  Future<void> _checkSubscription() async {
    try {
      final response = await _supabaseService.client
          .from('system_settings')
          .select('setting_value')
          .eq('setting_key', 'subscription_end_date')
          .maybeSingle();
      
      if (response != null && response['setting_value'] != null) {
        subscriptionEndDate.value = DateTime.parse(response['setting_value']);
        
        final now = DateTime.now();
        final difference = subscriptionEndDate.value!.difference(now);
        daysUntilExpiry.value = difference.inDays;
        
        isSubscriptionExpiring.value = daysUntilExpiry.value <= 30 && daysUntilExpiry.value >= 0;
      }
    } catch (e) {
      print('Error checking subscription: $e');
    }
  }
  
  Future<void> _loadNotifications() async {
    try {
      final userId = _supabaseService.currentUserId;
      if (userId.isEmpty) return;
      
      final response = await _supabaseService.client
          .from('notifications')
          .select('*')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(50);
      
      notifications.value = List<Map<String, dynamic>>.from(response);
      
      unreadNotifications.value = notifications.where((n) => n['is_read'] != true).length;
      
    } catch (e) {
      print('Error loading notifications: $e');
    }
  }
  
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _supabaseService.client
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId);
      
      final index = notifications.indexWhere((n) => n['id'] == notificationId);
      if (index != -1) {
        notifications[index]['is_read'] = true;
        notifications.refresh();
        unreadNotifications.value--;
      }
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }
  
  Future<void> markAllNotificationsAsRead() async {
    try {
      final userId = _supabaseService.currentUserId;
      if (userId.isEmpty) return;
      
      await _supabaseService.client
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', userId);
      
      for (var notification in notifications) {
        notification['is_read'] = true;
      }
      notifications.refresh();
      unreadNotifications.value = 0;
      
      Get.snackbar(
        'Muvaffaqiyatli',
        'Barcha bildirishnomalar o\'qildi deb belgilandi',
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      print('Error marking all notifications as read: $e');
    }
  }
  
  String formatCurrency(double amount) {
    final formatter = NumberFormat('#,##0', 'en_US');
    return formatter.format(amount);
  }
  
  String _formatPeriod(int month, int year) {
    const months = [
      'Yanvar', 'Fevral', 'Mart', 'Aprel', 'May', 'Iyun',
      'Iyul', 'Avgust', 'Sentabr', 'Oktabr', 'Noyabr', 'Dekabr'
    ];
    return '${months[month - 1]} $year';
  }
  
  String _getShortMonthName(int month) {
    const months = ['Yan', 'Fev', 'Mar', 'Apr', 'May', 'Iyun',
                    'Iyul', 'Avg', 'Sen', 'Okt', 'Noy', 'Dek'];
    return months[month - 1];
  }
}