// lib/data/repositories/branch_repository.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/branch_model.dart';

class BranchRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ==================== ASOSIY METODLAR ====================

  /// Foydalanuvchining filiallari (role-based)
  /// Bu metod visitor controller uchun kerak
  Future<List<Map<String, dynamic>>> getUserBranches(String userId) async {
    try {
      // Foydalanuvchi rolini tekshirish
      final userResponse = await _supabase
          .from('users')
          .select('branch_id, role')
          .eq('id', userId)
          .maybeSingle();

      if (userResponse == null) return [];

      final role = userResponse['role'] as String?;

      // Agar owner yoki admin bo'lsa - barcha aktiv filiallar
      if (role == 'owner' || role == 'admin') {
        final response = await _supabase
            .from('branches')
            .select('id, name, address, phone, email, is_main, is_active')
            .eq('is_active', true)
            .order('is_main', ascending: false)
            .order('name');

        return List<Map<String, dynamic>>.from(response);
      }

      // Oddiy foydalanuvchi - faqat o'z filiallari
      final branchId = userResponse['branch_id'] as String?;
      if (branchId == null) return [];

      final branch = await _supabase
          .from('branches')
          .select('id, name, address, phone, email, is_main, is_active')
          .eq('id', branchId)
          .eq('is_active', true)
          .maybeSingle();

      return branch != null ? [branch] : [];
    } catch (e) {
      print('getUserBranches error: $e');
      throw Exception('Filiallarni yuklashda xatolik: $e');
    }
  }

  /// Barcha aktiv filiallarni olish (soddalashtirilgan versiya)
  Future<List<Map<String, dynamic>>> getAllBranches() async {
    try {
      final response = await _supabase
          .from('branches')
          .select('id, name, address, phone, email, is_main, is_active')
          .eq('is_active', true)
          .order('is_main', ascending: false)
          .order('name');

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('getAllBranches error: $e');
      return [];
    }
  }

  // ==================== TO'LIQ STATISTIKA BILAN ====================

  /// Barcha filiallarni statistika bilan olish
  Future<List<BranchModel>> getAllBranchesWithStats() async {
    try {
      final response = await _supabase
          .from('branches')
          .select()
          .order('created_at', ascending: false);

      final List<BranchModel> branches = [];

      for (var item in response) {
        final branch = BranchModel.fromJson(item);
        await _loadBranchStatistics(branch);
        branches.add(branch);
      }

      return branches;
    } catch (e) {
      print('Error loading branches with stats: $e');
      rethrow;
    }
  }

  /// Bitta filial ma'lumotlarini statistika bilan olish
  Future<BranchModel?> getBranchById(String id) async {
    try {
      final response = await _supabase
          .from('branches')
          .select()
          .eq('id', id)
          .single();

      final branch = BranchModel.fromJson(response);
      await _loadBranchStatistics(branch);

      return branch;
    } catch (e) {
      print('Error loading branch: $e');
      return null;
    }
  }

  /// Bitta filial (sodda versiya - statistikasiz)
  Future<Map<String, dynamic>?> getBranchByIdSimple(String id) async {
    try {
      final response = await _supabase
          .from('branches')
          .select('id, name, address, phone, email, is_main, is_active')
          .eq('id', id)
          .maybeSingle();

      return response;
    } catch (e) {
      print('getBranchByIdSimple error: $e');
      return null;
    }
  }

  // ==================== CRUD OPERATSIYALARI ====================

  /// Yangi filial yaratish
  Future<BranchModel?> createBranch(BranchModel branch) async {
    try {
      final data = branch.toJson();
      data.remove('id'); // ID ni o'chirish, Supabase o'zi yaratadi

      final response = await _supabase
          .from('branches')
          .insert(data)
          .select()
          .single();

      return BranchModel.fromJson(response);
    } catch (e) {
      print('Error creating branch: $e');
      rethrow;
    }
  }

  /// Filialni yangilash
  Future<BranchModel?> updateBranch(String id, BranchModel branch) async {
    try {
      final data = branch.toJson();
      data['updated_at'] = DateTime.now().toIso8601String();

      final response = await _supabase
          .from('branches')
          .update(data)
          .eq('id', id)
          .select()
          .single();

      final updatedBranch = BranchModel.fromJson(response);
      await _loadBranchStatistics(updatedBranch);

      return updatedBranch;
    } catch (e) {
      print('Error updating branch: $e');
      rethrow;
    }
  }

  /// Filial ma'lumotlarini yangilash (sodda versiya)
  Future<bool> updateBranchSimple({
    required String branchId,
    String? name,
    String? address,
    String? phone,
    String? email,
    bool? isMain,
    bool? isActive,
  }) async {
    try {
      final Map<String, dynamic> updates = {};

      if (name != null) updates['name'] = name;
      if (address != null) updates['address'] = address;
      if (phone != null) updates['phone'] = phone;
      if (email != null) updates['email'] = email;
      if (isMain != null) updates['is_main'] = isMain;
      if (isActive != null) updates['is_active'] = isActive;

      updates['updated_at'] = DateTime.now().toIso8601String();

      await _supabase.from('branches').update(updates).eq('id', branchId);

      return true;
    } catch (e) {
      print('updateBranchSimple error: $e');
      throw Exception('Filialni yangilashda xatolik: $e');
    }
  }

  /// Filial statusini yangilash
  Future<BranchModel?> updateBranchStatus(String id, bool isActive) async {
    try {
      final response = await _supabase
          .from('branches')
          .update({
            'is_active': isActive,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id)
          .select()
          .single();

      final branch = BranchModel.fromJson(response);
      await _loadBranchStatistics(branch);

      return branch;
    } catch (e) {
      print('Error updating branch status: $e');
      rethrow;
    }
  }

  /// Filialni o'chirish (soft delete)
  Future<bool> deleteBranch(String id) async {
    try {
      await _supabase
          .from('branches')
          .update({
            'is_active': false,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id);

      return true;
    } catch (e) {
      print('Error deleting branch: $e');
      throw Exception('Filialni o\'chirishda xatolik: $e');
    }
  }

  // ==================== QIDIRUV VA FILTER ====================

  /// Asosiy filialni olish
  Future<BranchModel?> getMainBranch() async {
    try {
      final response = await _supabase
          .from('branches')
          .select()
          .eq('is_main', true)
          .single();

      final branch = BranchModel.fromJson(response);
      await _loadBranchStatistics(branch);

      return branch;
    } catch (e) {
      print('Error loading main branch: $e');
      return null;
    }
  }

  /// Faol filiallarni olish (sodda versiya)
  Future<List<BranchModel>> getActiveBranches() async {
    try {
      final response = await _supabase
          .from('branches')
          .select()
          .eq('is_active', true)
          .order('name', ascending: true);

      final List<BranchModel> branches = [];
      for (var item in response) {
        branches.add(BranchModel.fromJson(item));
      }

      return branches;
    } catch (e) {
      print('Error loading active branches: $e');
      return [];
    }
  }

  /// Filiallar sonini olish
  Future<int> getBranchesCount() async {
    try {
      final response = await _supabase.from('branches').select('*');
      return (response as List).length;
    } catch (e) {
      print('Error getting branches count: $e');
      return 0;
    }
  }

  // ==================== FOYDALANUVCHILAR BILAN ISHLASH ====================

  /// Foydalanuvchini filialga qo'shish
  Future<bool> addUserToBranch({
    required String userId,
    required String branchId,
  }) async {
    try {
      await _supabase
          .from('users')
          .update({
            'branch_id': branchId,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);

      return true;
    } catch (e) {
      print('addUserToBranch error: $e');
      return false;
    }
  }

  /// Filialning barcha foydalanuvchilarini olish
  Future<List<Map<String, dynamic>>> getBranchUsers(String branchId) async {
    try {
      final response = await _supabase
          .from('users')
          .select('id, first_name, last_name, middle_name, role, status, phone')
          .eq('branch_id', branchId)
          .eq('status', 'active')
          .order('role')
          .order('last_name');

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('getBranchUsers error: $e');
      return [];
    }
  }

  // ==================== STATISTIKA ====================

  /// Filial statistikasi (sodda versiya)
  Future<Map<String, dynamic>> getBranchStatistics(String branchId) async {
    try {
      // O'quvchilar soni
      final studentsResponse = await _supabase
          .from('students')
          .select('id')
          .eq('branch_id', branchId)
          .eq('status', 'active');

      // O'qituvchilar soni
      final teachersResponse = await _supabase
          .from('users')
          .select('id')
          .eq('branch_id', branchId)
          .eq('role', 'teacher')
          .eq('status', 'active');

      // Sinflar soni
      final classesResponse = await _supabase
          .from('classes')
          .select('id')
          .eq('branch_id', branchId)
          .eq('is_active', true);

      return {
        'students_count': (studentsResponse as List).length,
        'teachers_count': (teachersResponse as List).length,
        'classes_count': (classesResponse as List).length,
      };
    } catch (e) {
      print('getBranchStatistics error: $e');
      return {'students_count': 0, 'teachers_count': 0, 'classes_count': 0};
    }
  }

  // ==================== PRIVATE METODLAR (STATISTIKA) ====================

  /// Filial statistikasini yuklash (to'liq versiya)
  Future<void> _loadBranchStatistics(BranchModel branch) async {
    try {
      // O'quvchilar statistikasi
      final studentsData = await _getStudentsStatistics(branch.id);
      branch.totalStudents = studentsData['total'];
      branch.activeStudents = studentsData['active'];
      branch.pausedStudents = studentsData['paused'];
      branch.graduatedStudents = studentsData['graduated'];

      // Xodimlar statistikasi
      final staffData = await _getStaffStatistics(branch.id);
      branch.totalStaff = staffData['total'];
      branch.totalTeachers = staffData['teachers'];

      // Sinflar va xonalar
      branch.totalClasses = await _getTotalClasses(branch.id);
      branch.totalRooms = await _getTotalRooms(branch.id);

      // Moliyaviy statistika
      final financialData = await _getFinancialStatistics(branch.id);
      branch.monthlyRevenue = financialData['monthly_revenue'];
      branch.yearlyRevenue = financialData['yearly_revenue'];
      branch.totalExpenses = financialData['total_expenses'];
      branch.netProfit = financialData['net_profit'];
      branch.averageMonthlyFee = financialData['average_fee'];

      // Qarzlar statistikasi
      final debtsData = await _getDebtsStatistics(branch.id);
      branch.totalDebts = debtsData['total_debts'];
      branch.totalDebtAmount = debtsData['total_amount'];
    } catch (e) {
      print('Error loading branch statistics: $e');
      // Xatolik bo'lsa, statistikani 0 qilib qo'yamiz
      branch.totalStudents = 0;
      branch.activeStudents = 0;
      branch.totalStaff = 0;
      branch.totalTeachers = 0;
      branch.totalClasses = 0;
      branch.totalRooms = 0;
    }
  }

  Future<Map<String, int>> _getStudentsStatistics(String branchId) async {
    try {
      final totalResponse = await _supabase
          .from('students')
          .select('*')
          .eq('branch_id', branchId);

      final activeResponse = await _supabase
          .from('students')
          .select('*')
          .eq('branch_id', branchId)
          .eq('status', 'active');

      final pausedResponse = await _supabase
          .from('students')
          .select('*')
          .eq('branch_id', branchId)
          .eq('status', 'paused');

      final graduatedResponse = await _supabase
          .from('students')
          .select('*')
          .eq('branch_id', branchId)
          .eq('status', 'graduated');

      return {
        'total': (totalResponse as List).length,
        'active': (activeResponse as List).length,
        'paused': (pausedResponse as List).length,
        'graduated': (graduatedResponse as List).length,
      };
    } catch (e) {
      print('Error loading students statistics: $e');
      return {'total': 0, 'active': 0, 'paused': 0, 'graduated': 0};
    }
  }

  Future<Map<String, int>> _getStaffStatistics(String branchId) async {
    try {
      final totalResponse = await _supabase
          .from('users')
          .select('*')
          .eq('branch_id', branchId);

      final teachersResponse = await _supabase
          .from('users')
          .select('*')
          .eq('branch_id', branchId)
          .eq('role', 'teacher');

      return {
        'total': (totalResponse as List).length,
        'teachers': (teachersResponse as List).length,
      };
    } catch (e) {
      print('Error loading staff statistics: $e');
      return {'total': 0, 'teachers': 0};
    }
  }

  Future<int> _getTotalClasses(String branchId) async {
    try {
      final response = await _supabase
          .from('classes')
          .select('*')
          .eq('branch_id', branchId);
      return (response as List).length;
    } catch (e) {
      print('Error loading classes: $e');
      return 0;
    }
  }

  Future<int> _getTotalRooms(String branchId) async {
    try {
      final response = await _supabase
          .from('rooms')
          .select('*')
          .eq('branch_id', branchId);
      return (response as List).length;
    } catch (e) {
      print('Error loading rooms: $e');
      return 0;
    }
  }

  Future<Map<String, double>> _getFinancialStatistics(String branchId) async {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final startOfYear = DateTime(now.year, 1, 1);

      // Oylik to'lovlar
      final monthlyPaymentsResponse = await _supabase
          .from('payments')
          .select('amount')
          .eq('branch_id', branchId)
          .eq('status', 'paid')
          .gte('payment_date', startOfMonth.toIso8601String());

      double monthlyRevenue = 0;
      for (var payment in monthlyPaymentsResponse) {
        monthlyRevenue += (payment['amount'] as num).toDouble();
      }

      // Yillik to'lovlar
      final yearlyPaymentsResponse = await _supabase
          .from('payments')
          .select('amount')
          .eq('branch_id', branchId)
          .eq('status', 'paid')
          .gte('payment_date', startOfYear.toIso8601String());

      double yearlyRevenue = 0;
      for (var payment in yearlyPaymentsResponse) {
        yearlyRevenue += (payment['amount'] as num).toDouble();
      }

      // Xarajatlar
      final expensesResponse = await _supabase
          .from('expenses')
          .select('amount')
          .eq('branch_id', branchId)
          .gte('expense_date', startOfYear.toIso8601String());

      double totalExpenses = 0;
      for (var expense in expensesResponse) {
        totalExpenses += (expense['amount'] as num).toDouble();
      }

      // O'rtacha oylik to'lov
      final activeStudentsResponse = await _supabase
          .from('students')
          .select('monthly_fee')
          .eq('branch_id', branchId)
          .eq('status', 'active');

      double totalFees = 0;
      int studentCount = activeStudentsResponse.length;
      for (var student in activeStudentsResponse) {
        totalFees += (student['monthly_fee'] as num?)?.toDouble() ?? 0;
      }
      double averageFee = studentCount > 0 ? totalFees / studentCount : 0;

      return {
        'monthly_revenue': monthlyRevenue,
        'yearly_revenue': yearlyRevenue,
        'total_expenses': totalExpenses,
        'net_profit': yearlyRevenue - totalExpenses,
        'average_fee': averageFee,
      };
    } catch (e) {
      print('Error loading financial statistics: $e');
      return {
        'monthly_revenue': 0,
        'yearly_revenue': 0,
        'total_expenses': 0,
        'net_profit': 0,
        'average_fee': 0,
      };
    }
  }

  Future<Map<String, dynamic>> _getDebtsStatistics(String branchId) async {
    try {
      final debtsResponse = await _supabase
          .from('student_debts')
          .select('student_id, debt_amount')
          .eq('branch_id', branchId)
          .gt('debt_amount', 0);

      int totalDebts = debtsResponse.length;
      double totalAmount = 0;

      for (var debt in debtsResponse) {
        totalAmount += (debt['debt_amount'] as num).toDouble();
      }

      return {'total_debts': totalDebts, 'total_amount': totalAmount};
    } catch (e) {
      print('Error loading debts statistics: $e');
      return {'total_debts': 0, 'total_amount': 0.0};
    }
  }

  Future<List<Map<String, dynamic>>> getTeachers(String branchId) async {
    try {
      final response = await _supabase
          .from('staff')
          .select('''
            id,
            first_name,
            last_name,
            middle_name,
            phone,
            position,
            classes!classes_main_teacher_id_fkey(
              id,
              name,
              default_room_id,
              rooms!classes_default_room_id_fkey(
                id,
                name,
                capacity
              )
            )
          ''')
          .eq('branch_id', branchId)
          .eq('is_active', true)
          .order('last_name');

      return (response as List).map((item) {
        final classes = item['classes'] as List?;
        final mainClass = classes?.isNotEmpty == true ? classes!.first : null;
        final room = mainClass?['rooms'] as Map<String, dynamic>?;

        return {
          'id': item['id'],
          'first_name': item['first_name'],
          'last_name': item['last_name'],
          'middle_name': item['middle_name'],
          'full_name':
              '${item['last_name']} ${item['first_name']} ${item['middle_name'] ?? ''}',
          'phone': item['phone'],
          'position': item['position'],
          'class_id': mainClass?['id'],
          'class_name': mainClass?['name'],
          'room_id': mainClass?['default_room_id'],
          'room_name': room?['name'],
          'room_capacity': room?['capacity'],
        };
      }).toList();
    } catch (e) {
      print('❌ getTeachers xatolik: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getRooms(String branchId) async {
    try {
      final response = await _supabase
          .from('rooms')
          .select('''
            id,
            name,
            capacity,
            floor,
            room_type,
            classes!classes_default_room_id_fkey(
              id,
              name,
              main_teacher_id,
              staff!classes_main_teacher_id_fkey(
                id,
                first_name,
                last_name,
                middle_name
              )
            )
          ''')
          .eq('branch_id', branchId)
          .eq('is_active', true)
          .order('name');

      return (response as List).map((item) {
        final classes = item['classes'] as List?;
        final mainClass = classes?.isNotEmpty == true ? classes!.first : null;
        final teacher = mainClass?['staff'] as Map<String, dynamic>?;

        return {
          'id': item['id'],
          'name': item['name'],
          'capacity': item['capacity'],
          'floor': item['floor'],
          'room_type': item['room_type'],
          'class_id': mainClass?['id'],
          'class_name': mainClass?['name'],
          'teacher_id': mainClass?['main_teacher_id'],
          'teacher_name': teacher != null
              ? '${teacher['last_name']} ${teacher['first_name']}'
              : null,
        };
      }).toList();
    } catch (e) {
      print('❌ getRooms xatolik: $e');
      return [];
    }
  }
}
