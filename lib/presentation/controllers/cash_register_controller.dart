import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../data/models/payment_model.dart';
import '../../data/repositories/payment_repositry.dart';
import 'auth_controller.dart';

class CashRegisterController extends GetxController {
  final PaymentRepository _paymentRepository = PaymentRepository();
  final AuthController _authController = Get.find<AuthController>();
  final supabase = Supabase.instance.client;

  // ==================== STATE VARIABLES ====================
  final RxBool isLoading = true.obs;
  
  // Sana filtrlari
  final RxString selectedPeriod = 'today'.obs;
  final Rx<DateTime> startDate = DateTime.now().obs;
  final Rx<DateTime> endDate = DateTime.now().obs;

  // --- KASSA QOLDIQLARI (Real vaqt) ---
  final RxDouble totalCashBalance = 0.0.obs;
  final RxDouble mainCashBalance = 0.0.obs;   // Naqd (cash)
  final RxDouble clickBalance = 0.0.obs;      // Click
  final RxDouble cardBalance = 0.0.obs;       // Terminal (card)
  final RxDouble bankBalance = 0.0.obs;       // Bank
  final RxDouble ownerCashBalance = 0.0.obs;  // Ega kassasi (owner_fund)

  // --- TUSHUM STATISTIKASI (Kirimlar) ---
  final RxDouble todayRevenue = 0.0.obs;
  final RxDouble periodRevenue = 0.0.obs;
  
  // --- QARZDORLIK ---
  final RxDouble totalDebt = 0.0.obs;         // Umumiy qarz
  final RxDouble totalStudentDebt = 0.0.obs;  // O'quvchilar qarzi

  // --- TO'LOV USULLARI BO'YICHA TUSHUM (Statistika uchun) ---
  final RxDouble cashPayments = 0.0.obs;
  final RxDouble clickPayments = 0.0.obs;
  final RxDouble cardPayments = 0.0.obs;
  final RxDouble bankPayments = 0.0.obs;

  // --- RO'YXATLAR ---
  final RxList<PaymentModel> payments = <PaymentModel>[].obs;
  final RxList<Map<String, dynamic>> cashTransactions = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> debtorStudents = <Map<String, dynamic>>[].obs;

  // --- FILTRLAR ---
  final RxString paymentMethodFilter = 'all'.obs;
  final RxString statusFilter = 'all'.obs;

  @override
  void onInit() {
    super.onInit();
    _setDateRange('today');

    // 1. Foydalanuvchi tizimga kirishini kutamiz (Null check)
    ever(_authController.currentUser, (user) {
      if (user != null && user.branchId != null) {
        _initializeData(user.branchId!);
      }
    });

    // 2. Agar foydalanuvchi allaqachon yuklangan bo'lsa
    if (_authController.currentUser.value?.branchId != null) {
      _initializeData(_authController.currentUser.value!.branchId!);
    }
  }

  void _initializeData(String branchId) {
    print("🚀 Controller ishga tushdi. Branch ID: $branchId");
    loadAllData();
    _setupRealtimeListeners(branchId);
  }

  // ==================== REALTIME TIZIMI ====================
  void _setupRealtimeListeners(String branchId) {
    // Har bir filial uchun unikal kanal nomi
    final channelName = 'cash_register_updates_$branchId';
    
    try {
      supabase.removeAllChannels(); // Eski kanallarni tozalash

      supabase
          .channel(channelName)
          // A. Kassa qoldig'i o'zgarganda
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'cash_register',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'branch_id',
              value: branchId,
            ),
            callback: (payload) {
              print('📡 Realtime: Kassa balansi o\'zgardi');
              _loadCashBalances(branchId);
            },
          )
          // B. To'lovlar o'zgarganda (Tushum va ro'yxat)
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'payments',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'branch_id',
              value: branchId,
            ),
            callback: (payload) {
              print('📡 Realtime: To\'lovlar o\'zgardi');
              _loadRevenueStatistics(branchId);
              _loadPayments(branchId);
            },
          )
          // C. Kassa tranzaksiyalari tarixi
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'cash_transactions',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'branch_id',
              value: branchId,
            ),
            callback: (payload) {
              print('📡 Realtime: Yangi tranzaksiya');
              _loadCashTransactions(branchId);
            },
          )
           // D. Qarzlar o'zgarishi
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'student_debts',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'branch_id',
              value: branchId,
            ),
            callback: (payload) {
              print('📡 Realtime: Qarzlar o\'zgardi');
              _loadDebtStatistics(branchId);
              _loadDebtorStudents(branchId);
            },
          )
          .subscribe();
          
      print('✅ Realtime kanali ulandi: $channelName');
    } catch (e) {
      print('❌ Realtime xatolik: $e');
    }
  }

  // ==================== ASOSIY MA'LUMOT YUKLASH ====================
  Future<void> loadAllData() async {
    final branchId = _authController.currentUser.value?.branchId;
    if (branchId == null) return;

    isLoading.value = true;
    try {
      await Future.wait([
        _loadCashBalances(branchId),
        _loadRevenueStatistics(branchId),
        _loadPayments(branchId),
        _loadCashTransactions(branchId),
        _loadDebtorStudents(branchId),
        _loadDebtStatistics(branchId),
      ]);
    } catch (e) {
      print('❌ LoadAllData xatosi: $e');
      Get.snackbar('Xatolik', 'Ma\'lumotlarni yuklashda muammo: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // 1. KASSA QOLDIQLARI
  Future<void> _loadCashBalances(String branchId) async {
    try {
      final response = await supabase
          .from('cash_register')
          .select('payment_method, current_balance')
          .eq('branch_id', branchId);

      double tMain = 0, tClick = 0, tCard = 0, tBank = 0, tOwner = 0;

      for (var item in response) {
        // Bazadagi metod nomlarini normallashtirish
        String method = (item['payment_method'] ?? '').toString().toLowerCase();
        double balance = (item['current_balance'] as num?)?.toDouble() ?? 0.0;

        switch (method) {
          case 'cash':
            tMain = balance;
            break;
          case 'click':
            tClick = balance;
            break;
          case 'card':      // Terminal
          case 'terminal': 
            tCard = balance;
            break;
          case 'bank':
            tBank = balance;
            break;
          case 'owner_fund': // Ega kassasi
          case 'owner_cash':
            tOwner = balance;
            break;
        }
      }

      // Qiymatlarni yangilash
      mainCashBalance.value = tMain;
      clickBalance.value = tClick;
      cardBalance.value = tCard;
      bankBalance.value = tBank;
      ownerCashBalance.value = tOwner;

      totalCashBalance.value = tMain + tClick + tCard + tBank + tOwner;
    } catch (e) {
      print('❌ Balans yuklash xatosi: $e');
    }
  }

  // 2. TUSHUM VA STATISTIKA
  Future<void> _loadRevenueStatistics(String branchId) async {
    try {
      // Davr tushumi
      periodRevenue.value = await _paymentRepository.getTotalRevenue(
        branchId: branchId,
        startDate: startDate.value,
        endDate: endDate.value,
      );

      // Bugungi tushum
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = todayStart.add(Duration(days: 1));
      
      todayRevenue.value = await _paymentRepository.getTotalRevenue(
        branchId: branchId,
        startDate: todayStart,
        endDate: todayEnd,
      );

      // Metodlar bo'yicha statistika (Pie Chart uchun)
      await _loadPaymentMethodStatistics(branchId);
    } catch (e) {
      print('❌ Statistika xatosi: $e');
    }
  }

  Future<void> _loadPaymentMethodStatistics(String branchId) async {
    try {
      final startStr = startDate.value.toIso8601String().split('T')[0];
      final endStr = endDate.value.toIso8601String().split('T')[0];

      final response = await supabase
          .from('payments')
          .select('payment_method, final_amount, paid_amount, payment_status')
          .eq('branch_id', branchId)
          .or('payment_status.eq.paid,payment_status.eq.partial')
          .gte('payment_date', startStr)
          .lte('payment_date', endStr);

      double cash = 0, click = 0, card = 0, bank = 0;

      for (var p in response) {
        String method = (p['payment_method'] ?? '').toString().toLowerCase();
        
        // Summani aniqlash (qisman to'lovni hisobga olgan holda)
        double amount = p['payment_status'] == 'partial' 
            ? (p['paid_amount'] as num).toDouble() 
            : (p['final_amount'] as num).toDouble();

        if (method == 'cash') cash += amount;
        else if (method == 'click') click += amount;
        else if (method == 'card') card += amount;
        else if (method == 'bank') bank += amount;
      }

      cashPayments.value = cash;
      clickPayments.value = click;
      cardPayments.value = card;
      bankPayments.value = bank;
    } catch (e) {
      print('❌ Metod statistikasi xatosi: $e');
    }
  }

  // 3. QARZLAR
  Future<void> _loadDebtStatistics(String branchId) async {
    try {
      // O'quvchilar qarzi
      final debts = await supabase
          .from('student_debts')
          .select('remaining_amount')
          .eq('branch_id', branchId)
          .eq('is_settled', false);

      double sum = 0;
      for (var d in debts) sum += (d['remaining_amount'] as num).toDouble();
      
      totalStudentDebt.value = sum;
      
      // Payments jadvalidagi qarzlar (agar bo'lsa)
      final paymentDebts = await supabase
          .from('payments')
          .select('remaining_debt')
          .eq('branch_id', branchId)
          .eq('is_debt', true)
          .gt('remaining_debt', 0);
          
      double pSum = 0;
      for (var p in paymentDebts) pSum += (p['remaining_debt'] as num).toDouble();

      totalDebt.value = sum + pSum;
    } catch (e) {
      print('❌ Qarzlar xatosi: $e');
    }
  }

  // 4. TO'LOVLAR RO'YXATI
  Future<void> _loadPayments(String branchId) async {
    try {
      var list = await _paymentRepository.getPayments(
        branchId: branchId,
        startDate: startDate.value,
        endDate: endDate.value,
        limit: 100,
        paymentType: '',
      );
      
      // Filtrlar
      if (paymentMethodFilter.value != 'all') {
        list = list.where((p) => p.paymentMethod?.toLowerCase() == paymentMethodFilter.value.toLowerCase()).toList();
      }
      if (statusFilter.value != 'all') {
        list = list.where((p) => p.paymentStatus == statusFilter.value).toList();
      }
      
      payments.value = list;
    } catch (e) {
      print('❌ To\'lovlar ro\'yxati xatosi: $e');
    }
  }

  // 5. TRANZAKSIYALAR TARIXI
  Future<void> _loadCashTransactions(String branchId) async {
    try {
      final response = await supabase
          .from('cash_transactions')
          .select('*, performed_by_user:performed_by(first_name, last_name)')
          .eq('branch_id', branchId)
          .order('created_at', ascending: false)
          .limit(50);
      
      cashTransactions.value = List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Tranzaksiyalar xatosi: $e');
    }
  }

  // 6. QARZDOR O'QUVCHILAR RO'YXATI
  Future<void> _loadDebtorStudents(String branchId) async {
    try {
      final response = await supabase
          .from('student_debts')
          .select('*, students:student_id(first_name, last_name, phone, class_name)')
          .eq('branch_id', branchId)
          .eq('is_settled', false)
          .order('remaining_amount', ascending: false)
          .limit(100);
          
      debtorStudents.value = List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Qarzdorlar ro\'yxati xatosi: $e');
    }
  }

  // ==================== TRANSFER (O'TKAZMA) ====================
  Future<void> transferCash({
    required String fromMethod,
    required String toMethod,
    required double amount,
    double commission = 0,
    required String description,
  }) async {
    final branchId = _authController.currentUser.value?.branchId;
    final userId = _authController.currentUser.value?.id;

    if (branchId == null || userId == null) {
      Get.snackbar('Xato', 'Foydalanuvchi ma\'lumoti topilmadi');
      return;
    }

    try {
      print('💸 O\'tkazma: $fromMethod -> $toMethod, Summa: $amount');

      // RPC Funksiyani chaqirish (SQL da yozilgan function)
      await supabase.rpc(
        'process_cash_transfer',
        params: {
          'p_branch_id': branchId,
          'p_from_method': fromMethod,
          'p_to_method': toMethod,
          'p_amount': amount,
          'p_commission': commission,
          'p_description': description,
          'p_performed_by': userId,
        },
      );
      
      Get.back(); // Dialogni yopish
      Get.snackbar(
        'Muvaffaqiyatli', 
        'O\'tkazma bajarildi',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      
      // Ma'lumotlarni majburlab yangilash (Realtime ishlamasa ham)
      await loadAllData();
    } catch (e) {
      String errorMsg = e.toString();
      if (errorMsg.contains('Kassada mablag\' yetarli emas')) {
        errorMsg = 'Kassada mablag\' yetarli emas!';
      }
      Get.snackbar(
        'Xatolik', 
        'O\'tkazmada xatolik: $errorMsg',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 4),
      );
    }
  }

  // ==================== PDF EXPORT ====================
  Future<void> exportToPDF() async {
    try {
      final pdf = pw.Document();
      final now = DateTime.now();
      final dateFormat = DateFormat('dd.MM.yyyy HH:mm');

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (context) => [
            pw.Header(level: 0, child: pw.Text("KASSA HISOBOTI", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold))),
            pw.Text('Sana: ${dateFormat.format(now)}'),
            pw.Text('Davr: ${selectedPeriod.value.toUpperCase()}'),
            pw.Divider(),
            
            pw.SizedBox(height: 20),
            pw.Text("1. KASSA QOLDIQLARI", style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Table.fromTextArray(
              headers: ['Kassa turi', 'Summa'],
              data: [
                ['Naqd (Asosiy)', _formatMoney(mainCashBalance.value)],
                ['Click', _formatMoney(clickBalance.value)],
                ['Terminal (Karta)', _formatMoney(cardBalance.value)],
                ['Bank Hisob', _formatMoney(bankBalance.value)],
                ['Ega Kassasi', _formatMoney(ownerCashBalance.value)],
                ['JAMI', _formatMoney(totalCashBalance.value)],
              ],
            ),
            
            pw.SizedBox(height: 20),
            pw.Text("2. TUSHUMLAR STATISTIKASI", style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Table.fromTextArray(
              headers: ['Kategoriya', 'Summa'],
              data: [
                ['Jami Tushum', _formatMoney(periodRevenue.value)],
                ['Naqd orqali', _formatMoney(cashPayments.value)],
                ['Click orqali', _formatMoney(clickPayments.value)],
                ['Terminal orqali', _formatMoney(cardPayments.value)],
                ['Bank orqali', _formatMoney(bankPayments.value)],
              ],
            ),

            pw.SizedBox(height: 20),
            pw.Text("3. QARZDORLIK", style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Table.fromTextArray(
              data: [
                ['Jami qarzdorlik', _formatMoney(totalDebt.value)],
                ['O\'quvchilar qarzi', _formatMoney(totalStudentDebt.value)],
              ],
            ),
          ],
        ),
      );

      await Printing.layoutPdf(onLayout: (format) async => pdf.save());
      Get.snackbar('Muvaffaqiyatli', 'PDF tayyorlandi');
    } catch (e) {
      Get.snackbar('Xato', 'PDF yaratishda xatolik: $e');
    }
  }

  // ==================== YORDAMCHI FUNKSIYALAR ====================
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
        startDate.value = DateTime(startDate.value.year, startDate.value.month, startDate.value.day);
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
  
  void setCustomDateRange(DateTime start, DateTime end) {
    selectedPeriod.value = 'custom';
    startDate.value = start;
    endDate.value = end;
    loadAllData();
  }

  Future<void> refreshData() async => await loadAllData();

  String _formatMoney(double amount) {
    return NumberFormat('#,###').format(amount) + ' so\'m';
  }
  
  // Filter metodlar
  void changePaymentMethodFilter(String v) { 
    paymentMethodFilter.value = v; 
    final branchId = _authController.currentUser.value?.branchId;
    if(branchId != null) _loadPayments(branchId); 
  }
  
  void changeStatusFilter(String v) { 
    statusFilter.value = v; 
    final branchId = _authController.currentUser.value?.branchId;
    if(branchId != null) _loadPayments(branchId); 
  }
}