import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ExpensesControllerFinal extends GetxController {
  final _supabase = Supabase.instance.client;

  // ==================== STATE ====================
  final isLoading = false.obs;
  final expenses = <Map<String, dynamic>>[].obs;
  final cashRegisters = <Map<String, dynamic>>[].obs;
  final branches = <Map<String, dynamic>>[].obs;

  // Filters
  final selectedCategory = 'all'.obs;
  final selectedBranch = 'all'.obs; // Default 'all'
  final searchQuery = ''.obs;
  final startDate = Rx<DateTime?>(null);
  final endDate = Rx<DateTime?>(null);

  // Statistics
  final totalExpenses = 0.0.obs;
  final todayExpenses = 0.0.obs;
  final monthExpenses = 0.0.obs;
  final weekExpenses = 0.0.obs;
  final yearExpenses = 0.0.obs;

  // Cash Balances (Real-time)
  final totalCashBalance = 0.0.obs;
  final cashBalance = 0.0.obs;
  final clickBalance = 0.0.obs;
  final cardBalance = 0.0.obs;
  final bankBalance = 0.0.obs;

  // User Role Info
  String? _userRole;
  String? _userBranchId; // Userning o'z branchi (agar bo'lsa)

  // Categories
  final categories = [
    {
      'id': 'all',
      'name': 'Barchasi',
      'icon': Icons.all_inclusive,
      'color': Colors.blue,
    },
    {
      'id': 'utilities',
      'name': 'Kommunal xizmatlar',
      'icon': Icons.bolt,
      'color': Colors.orange,
    },
    {
      'id': 'supplies',
      'name': 'Jihozlar va ta\'minot',
      'icon': Icons.inventory_2,
      'color': Colors.purple,
    },
    {
      'id': 'maintenance',
      'name': 'Ta\'mirlash',
      'icon': Icons.build,
      'color': Colors.red,
    },
    {
      'id': 'marketing',
      'name': 'Marketing va Reklama',
      'icon': Icons.campaign,
      'color': Colors.pink,
    },
    {
      'id': 'rent',
      'name': 'Ijara to\'lovi',
      'icon': Icons.home,
      'color': Colors.brown,
    },
    {
      'id': 'transport',
      'name': 'Transport',
      'icon': Icons.local_shipping,
      'color': Colors.teal,
    },
    {
      'id': 'food',
      'name': 'Oziq-ovqat',
      'icon': Icons.restaurant,
      'color': Colors.deepOrange,
    },
    {
      'id': 'salary',
      'name': 'Ish haqi',
      'icon': Icons.payments,
      'color': Colors.green,
    }, // Qo'shildi
    {
      'id': 'education',
      'name': 'Ta\'lim materiallari',
      'icon': Icons.school,
      'color': Colors.indigo,
    },
    {
      'id': 'tax',
      'name': 'Soliqlar',
      'icon': Icons.account_balance,
      'color': Colors.blueGrey,
    },
    {
      'id': 'insurance',
      'name': 'Sug\'urta',
      'icon': Icons.health_and_safety,
      'color': Colors.cyan,
    },
    {
      'id': 'operational_expense',
      'name': 'Operatsion xarajat',
      'icon': Icons.business_center,
      'color': Colors.amber,
    },
    {
      'id': 'other',
      'name': 'Boshqa',
      'icon': Icons.more_horiz,
      'color': Colors.grey,
    },
  ].obs;

  @override
  void onInit() {
    super.onInit();
    _initializeData();
  }

  Future<void> _initializeData() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      isLoading.value = true;

      // 1. User ma'lumotlarini olish
      final userInfo = await _supabase
          .from('users')
          .select('branch_id, role')
          .eq('id', userId)
          .single();

      _userBranchId = userInfo['branch_id'];
      _userRole = userInfo['role'];

      // 2. Filiallarni yuklash
      await loadBranches();

      // Agar user oddiy xodim bo'lsa, faqat o'z filialini ko'radi
      if (_userBranchId != null && _userRole != 'owner') {
        selectedBranch.value = _userBranchId!;
      } else {
        // Owner yoki Admin hammasini ko'ra oladi, default 'all'
        selectedBranch.value = 'all';
      }

      await loadData();
      _setupRealtimeListeners();
    } catch (e) {
      print('❌ Initialization error: $e');
      _showError('Tizimga ulanishda xatolik: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ==================== REAL-TIME LISTENERS ====================
  void _setupRealtimeListeners() {
    // Agar aniq filial bo'lmasa, global tinglash
    final channelName = 'expenses_global';

    try {
      _supabase.removeAllChannels();

      final channel = _supabase.channel(channelName);

      // Expenses changes
      channel
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'expenses',
            callback: (payload) {
              print('📡 Realtime: Expenses changed');
              loadExpenses();
              calculateStatistics();
            },
          )
          // Cash register changes
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'cash_register',
            callback: (payload) {
              print('📡 Realtime: Cash register changed');
              loadCashRegisters();
            },
          )
          .subscribe();

      print('✅ Realtime channel connected');
    } catch (e) {
      print('❌ Realtime error: $e');
    }
  }

  // ==================== DATA LOADING ====================
  Future<void> loadData() async {
    isLoading.value = true;
    try {
      await Future.wait([
        loadExpenses(),
        loadCashRegisters(),
        calculateStatistics(),
      ]);
    } catch (e) {
      _showError('Ma\'lumotlarni yuklashda xatolik: $e');
    } finally {
      isLoading.value = false;
    }
  }

   Future<void> loadExpenses() async {
    try {
      // O'ZGARTIRISH: 'var' o'rniga 'dynamic' ishlatamiz
      dynamic query = _supabase
          .from('expenses')
          .select('*, branches(name), users:recorded_by(first_name, last_name)');

      // Kategoriya filtri
      if (selectedCategory.value != 'all') {
        query = query.eq('category', selectedCategory.value);
      }
      
      // Filial filtri
      if (selectedBranch.value != 'all') {
        query = query.eq('branch_id', selectedBranch.value);
      } else if (_userBranchId != null && _userRole != 'owner') {
        query = query.eq('branch_id', _userBranchId!);
      }
      
      // Qidiruv
      if (searchQuery.value.isNotEmpty) {
        query = query.or(
          'title.ilike.%${searchQuery.value}%,description.ilike.%${searchQuery.value}%',
        );
      }
      
      // Sana filtri
      if (startDate.value != null) {
        query = query.gte(
          'expense_date',
          DateFormat('yyyy-MM-dd').format(startDate.value!),
        );
      }
      
      if (endDate.value != null) {
        query = query.lte(
          'expense_date',
          DateFormat('yyyy-MM-dd').format(endDate.value!),
        );
      }

      // Sorting va Limit
      // O'ZGARTIRISH: .order va .limit ni oxirida chaqiramiz
      final response = await query
          .order('expense_date', ascending: false)
          .order('expense_time', ascending: false)
          .limit(1000); 
      
      expenses.value = List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Load expenses error: $e');
    }
  }
    Future<void> loadCashRegisters() async {
    try {
      // O'ZGARTIRISH: 'var' o'rniga 'dynamic'
      dynamic query = _supabase
          .from('cash_register')
          .select('*, branches(name)'); // .order() ni bu yerda chaqirmaymiz

      // Filial bo'yicha filter
      if (selectedBranch.value != 'all') {
        query = query.eq('branch_id', selectedBranch.value);
      } else if (_userBranchId != null && _userRole != 'owner') {
        query = query.eq('branch_id', _userBranchId!);
      }

      // O'ZGARTIRISH: .order() ni oxirida chaqiramiz
      final response = await query.order('payment_method');

      cashRegisters.value = List<Map<String, dynamic>>.from(response);
      
      // Balanslarni hisoblash
      double cash = 0, click = 0, card = 0, bank = 0;
      
      for (var c in cashRegisters) {
        final method = (c['payment_method'] ?? '').toString().toLowerCase();
        final balance = (c['current_balance'] as num?)?.toDouble() ?? 0.0;
        
        if (method.contains('cash') || method == 'naqd') {
          cash += balance;
        } else if (method.contains('click') || method == 'payme') {
          click += balance;
        } else if (method.contains('card') || method.contains('terminal')) {
          card += balance;
        } else if (method.contains('bank')) {
          bank += balance;
        }
      }
      
      cashBalance.value = cash;
      clickBalance.value = click;
      cardBalance.value = card;
      bankBalance.value = bank;
      totalCashBalance.value = cash + click + card + bank;
    } catch (e) {
      print('❌ Load cash registers error: $e');
    }
  }
  Future<void> loadBranches() async {
    try {
      final response = await _supabase
          .from('branches')
          .select('id, name')
          .eq('is_active', true)
          .order('name');

      branches.value = List<Map<String, dynamic>>.from(response);

      // Agar list boshiga "Barchasi" ni qo'shmoqchi bo'lsangiz:
      // branches.insert(0, {'id': 'all', 'name': 'Barcha filiallar'});
    } catch (e) {
      print('❌ Load branches error: $e');
    }
  }

  Future<void> calculateStatistics() async {
    try {
      final today = DateTime.now();
      final todayStr = DateFormat('yyyy-MM-dd').format(today);
      
      // Yordamchi query funksiyasi (dynamic qaytaradi)
      dynamic getBaseQuery() {
        dynamic q = _supabase.from('expenses').select('amount');
        if (selectedBranch.value != 'all') {
          q = q.eq('branch_id', selectedBranch.value);
        } else if (_userBranchId != null && _userRole != 'owner') {
          q = q.eq('branch_id', _userBranchId!);
        }
        return q;
      }
      
      // 1. Bugungi
      final todayData = await getBaseQuery().eq('expense_date', todayStr);
      todayExpenses.value = _sumAmounts(todayData);
      
      // 2. Haftalik
      final weekStart = today.subtract(Duration(days: today.weekday - 1));
      final weekData = await getBaseQuery().gte('expense_date', DateFormat('yyyy-MM-dd').format(weekStart));
      weekExpenses.value = _sumAmounts(weekData);
      
      // 3. Oylik
      final monthStart = DateTime(today.year, today.month, 1);
      final monthEnd = DateTime(today.year, today.month + 1, 0);
      final monthData = await getBaseQuery()
          .gte('expense_date', DateFormat('yyyy-MM-dd').format(monthStart))
          .lte('expense_date', DateFormat('yyyy-MM-dd').format(monthEnd));
      monthExpenses.value = _sumAmounts(monthData);
      
      // 4. Yillik
      final yearStart = DateTime(today.year, 1, 1);
      final yearData = await getBaseQuery().gte('expense_date', DateFormat('yyyy-MM-dd').format(yearStart));
      yearExpenses.value = _sumAmounts(yearData);
      
      // 5. Jami (Siz yuklagan ro'yxatdagilar)
      totalExpenses.value = expenses.fold(
        0.0,
        (sum, item) => sum + ((item['amount'] ?? 0.0) as num).toDouble(),
      );
    } catch (e) {
      print('❌ Statistics error: $e');
    }
  }
    // Yordamchi funksiya: Dynamic kelgan ma'lumotni hisoblash
  double _sumAmounts(dynamic data) {
    // Agar ma'lumot null bo'lsa yoki List bo'lmasa, 0 qaytaramiz
    if (data == null || data is! List) return 0.0;

    // List ichidagi summalarni qo'shib chiqamiz
    return data.fold<double>(0.0, (sum, item) {
      final amount = item['amount']; // Map ichidan amount ni olamiz
      if (amount == null) return sum;
      return sum + (amount as num).toDouble();
    });
  }
  // ==================== ADD EXPENSE ====================
    // ==================== ADD EXPENSE (YANGILANGAN) ====================
  Future<void> addExpense({
    required String category,
    required String title,
    required List<Map<String, dynamic>> cashAllocations,
    String? description,
    String? receiptNumber,
    String? responsiblePerson,
    DateTime? expenseDate,
  }) async {
    print("DEBUG: Xarajat qo'shish boshlandi...");

    // 1. Validatsiya: Kassadan to'lov bormi?
    if (cashAllocations.isEmpty) {
      _showError("Iltimos, kamida bitta kassadan to'lov summasini kiriting!");
      return;
    }

    // 2. Filialni aniqlash (Branch ID Logic)
    String? targetBranchId;
    
    // Agar aniq filial tanlangan bo'lsa
    if (selectedBranch.value != 'all') {
      targetBranchId = selectedBranch.value;
    } 
    // Agar userning o'z filiali bo'lsa
    else if (_userBranchId != null) {
      targetBranchId = _userBranchId;
    } 
    // Agar ro'yxatda filiallar bo'lsa, birinchisini olamiz (Fallback)
    else if (branches.isNotEmpty) {
      targetBranchId = branches.first['id'];
    }

    print("DEBUG: Target Branch ID: $targetBranchId");

    if (targetBranchId == null) {
      _showError("Xatolik: Filial (Branch) aniqlanmadi. Iltimos, filialni tanlang.");
      return;
    }
    
    try {
      isLoading.value = true;
      
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        _showError('Siz tizimga kirmagansiz!');
        return;
      }

      final totalAmount = cashAllocations.fold<double>(
        0.0,
        (sum, item) => sum + (item['amount'] as double),
      );
      
      print("DEBUG: Jami summa: $totalAmount");

      // 3. Balanslarni tekshirish va yangilash
      for (var allocation in cashAllocations) {
        final cashRegisterId = allocation['cash_register_id'];
        final amount = allocation['amount'] as double;
        
        // Kassa balansini tekshiramiz
        final cashRegister = await _supabase
            .from('cash_register')
            .select('current_balance')
            .eq('id', cashRegisterId)
            .single();
        
        final currentBalance = (cashRegister['current_balance'] as num).toDouble();
        
        // Kassani yangilash (Minus qilish)
        await _supabase.from('cash_register').update({
          'current_balance': currentBalance - amount,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', cashRegisterId);
      }
      
      // 4. Xarajatni yozish
      final expenseData = {
        'branch_id': targetBranchId,
        'category': category,
        'sub_category': '',
        'title': title,
        'description': description,
        'amount': totalAmount,
        'expense_date': DateFormat('yyyy-MM-dd').format(expenseDate ?? DateTime.now()),
        'expense_time': DateFormat('HH:mm:ss').format(DateTime.now()),
        'responsible_person': responsiblePerson,
        'receipt_number': receiptNumber,
        'recorded_by': userId,
      };

      print("DEBUG: Expense insert qilinmoqda...");

      final expenseResult = await _supabase
          .from('expenses')
          .insert(expenseData)
          .select('id')
          .single();
      
      final newExpenseId = expenseResult['id'];
      print("DEBUG: Yangi Xarajat ID: $newExpenseId");

      // 5. Tranzaktsiyalarni yozish
      for (var allocation in cashAllocations) {
        await _supabase.from('cash_transactions').insert({
          'branch_id': targetBranchId,
          'cash_register_id': allocation['cash_register_id'],
          'transaction_type': 'expense',
          'payment_method': allocation['payment_method'], // Bu yerda method to'g'ri kelayotganiga ishonch hosil qiling
          'amount': allocation['amount'],
          'description': title,
          'expense_id': newExpenseId,
          'performed_by': userId,
          'transaction_date': DateTime.now().toIso8601String(),
        });
      }
      
      print("DEBUG: Muvaffaqiyatli yakunlandi.");
      _showSuccess('Xarajat muvaffaqiyatli qo\'shildi');
      await loadData(); // Ro'yxatni yangilash

    } catch (e) {
      print("ERROR: $e"); // Konsolga to'liq xatoni chiqarish
      _showError('Xatolik yuz berdi: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ==================== UPDATE EXPENSE ====================
  Future<void> updateExpense({
    required String expenseId,
    required String category,
    required String title,
    String? description,
    String? receiptNumber,
    String? responsiblePerson,
  }) async {
    try {
      isLoading.value = true;

      await _supabase
          .from('expenses')
          .update({
            'category': category,
            'title': title,
            'description': description,
            'receipt_number': receiptNumber,
            'responsible_person': responsiblePerson,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', expenseId);

      _showSuccess('Xarajat yangilandi');
      await loadData();
    } catch (e) {
      _showError('Yangilashda xatolik: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ==================== DELETE EXPENSE ====================
  Future<void> deleteExpense(String expenseId) async {
    try {
      isLoading.value = true;

      // 1. Tranzaktsiyalarni topish (puli qaysi kassadan chiqqan)
      final transactions = await _supabase
          .from('cash_transactions')
          .select('cash_register_id, amount')
          .eq('expense_id', expenseId);

      // 2. Pulni kassaga qaytarish
      for (var transaction in transactions) {
        final regId = transaction['cash_register_id'];
        final amount = (transaction['amount'] as num).toDouble();

        if (regId != null) {
          final cashRegister = await _supabase
              .from('cash_register')
              .select('current_balance')
              .eq('id', regId)
              .single();

          final currentBalance = (cashRegister['current_balance'] as num)
              .toDouble();

          await _supabase
              .from('cash_register')
              .update({
                'current_balance':
                    currentBalance + amount, // Pulni qaytarish (+)
                'updated_at': DateTime.now().toIso8601String(),
              })
              .eq('id', regId);
        }
      }

      // 3. Tranzaktsiyalarni o'chirish
      await _supabase
          .from('cash_transactions')
          .delete()
          .eq('expense_id', expenseId);

      // 4. Xarajatni o'chirish
      await _supabase.from('expenses').delete().eq('id', expenseId);

      _showSuccess('Xarajat o\'chirildi va pul kassaga qaytarildi');
      await loadData();
    } catch (e) {
      _showError('O\'chirishda xatolik: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ==================== PDF EXPORT ====================
  Future<void> exportToPDF() async {
    try {
      final pdf = pw.Document();
      final now = DateTime.now();
      final dateFormat = DateFormat('dd.MM.yyyy HH:mm');

      // PDF uchun Font (Kirill alifbosini qo'llab quvvatlashi kerak)
      // Printing package default fonti ko'pincha yetarli bo'ladi, lekin ba'zida
      // maxsus font yuklash kerak. Hozircha standart ishlatamiz.

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (context) => [
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    "XARAJATLAR HISOBOTI",
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(dateFormat.format(now)),
                ],
              ),
            ),
            pw.Divider(),

            pw.SizedBox(height: 10),
            pw.Text(
              "Filial: ${selectedBranch.value == 'all' ? 'Barchasi' : _getBranchName(selectedBranch.value)}",
            ),
            pw.SizedBox(height: 20),

            pw.Text(
              "KASSA QOLDIQLARI",
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 5),
            pw.Table.fromTextArray(
              headers: ['Kassa turi', 'Balans'],
              border: pw.TableBorder.all(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              data: [
                ['Naqd pul', formatCurrency(cashBalance.value)],
                ['Click/Payme', formatCurrency(clickBalance.value)],
                ['Terminal', formatCurrency(cardBalance.value)],
                ['Bank hisobi', formatCurrency(bankBalance.value)],
                ['JAMI', formatCurrency(totalCashBalance.value)],
              ],
            ),

            pw.SizedBox(height: 20),
            pw.Text(
              "XARAJATLAR RO'YXATI",
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 5),
            pw.Table.fromTextArray(
              headers: ['Sana', 'Kategoriya', 'Nomi', 'Summa'],
              border: pw.TableBorder.all(),
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 10,
              ),
              cellStyle: pw.TextStyle(fontSize: 10),
              columnWidths: {
                0: pw.FlexColumnWidth(2),
                1: pw.FlexColumnWidth(3),
                2: pw.FlexColumnWidth(4),
                3: pw.FlexColumnWidth(2),
              },
              data: expenses
                  .take(100)
                  .map(
                    (e) => [
                      e['expense_date'] ?? '',
                      getCategoryName(e['category'] ?? ''),
                      e['title'] ?? '',
                      formatCurrency((e['amount'] as num).toDouble()),
                    ],
                  )
                  .toList(),
            ),
          ],
        ),
      );

      await Printing.layoutPdf(onLayout: (format) async => pdf.save());
      _showSuccess('PDF tayyorlandi');
    } catch (e) {
      _showError('PDF yaratishda xatolik: $e');
    }
  }

  // ==================== HELPERS ====================
  void applyFilters() => loadData();

  void clearFilters() {
    selectedCategory.value = 'all';
    // Agar owner bo'lsa 'all' ga qaytadi, bo'lmasa o'z branchiga
    if (_userRole == 'owner') {
      selectedBranch.value = 'all';
    }
    searchQuery.value = '';
    startDate.value = null;
    endDate.value = null;
    applyFilters();
  }

  String formatCurrency(double amount) => NumberFormat('#,###').format(amount);

  String getCategoryName(String categoryId) {
    final cat = categories.firstWhere(
      (c) => c['id'] == categoryId,
      orElse: () => categories.last,
    );
    return cat['name'] as String;
  }

  String _getBranchName(String id) {
    final b = branches.firstWhere(
      (element) => element['id'] == id,
      orElse: () => {'name': 'Noma\'lum'},
    );
    return b['name'];
  }

  String _formatMethodName(String method) {
    // Metod nomlarini chiroyli qilish
    final m = method.toLowerCase();
    if (m.contains('cash')) return 'Naqd';
    if (m.contains('click')) return 'Click';
    if (m.contains('card')) return 'Terminal';
    return method;
  }

  void _showError(String message) {
    Get.snackbar(
      'Xato',
      message,
      backgroundColor: Colors.red.shade100,
      colorText: Colors.red.shade900,
      icon: Icon(Icons.error_outline, color: Colors.red.shade900),
      snackPosition: SnackPosition.TOP,
      duration: Duration(seconds: 4),
    );
  }

  void _showSuccess(String message) {
    Get.snackbar(
      'Muvaffaqiyat',
      message,
      backgroundColor: Colors.green.shade100,
      colorText: Colors.green.shade900,
      icon: Icon(Icons.check_circle_outline, color: Colors.green.shade900),
      snackPosition: SnackPosition.TOP,
      duration: Duration(seconds: 3),
    );
  }

  Future<void> refresh() async => await loadData();
}
