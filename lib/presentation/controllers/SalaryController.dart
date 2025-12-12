// lib/presentation/controllers/salary_controller.dart
// IZOH: Maosh boshqaruvi uchun controller - barcha maosh operatsiyalarini boshqaradi

import 'package:flutter_application_1/data/models/salary_operations_model.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SalaryController extends GetxController {
  // Supabase client
  final _supabase = Supabase.instance.client;

  // Observable o'zgaruvchilar
  var isLoading = false.obs; // Yuklanish holati
  var salaryOperations =
      <SalaryOperation>[].obs; // Maosh operatsiyalari ro'yxati
  var filteredOperations = <SalaryOperation>[].obs; // Filtrlangan ro'yxat

  // Filter parametrlari
  var selectedMonth = DateTime.now().month.obs; // Tanlangan oy
  var selectedYear = DateTime.now().year.obs; // Tanlangan yil
  var selectedStatus = 'all'.obs; // 'all', 'paid', 'unpaid'
  var searchQuery = ''.obs; // Qidiruv matni

  // Statistika
  var totalPaidSalaries = 0.0.obs; // To'langan maoshlar jami
  var totalUnpaidSalaries = 0.0.obs; // To'lanmagan maoshlar jami
  var paidCount = 0.obs; // To'langan operatsiyalar soni
  var unpaidCount = 0.obs; // To'lanmagan operatsiyalar soni

  @override
  void onInit() {
    super.onInit();
    loadSalaryOperations(); // Controller yaratilganda ma'lumotlarni yuklash
  }

  // 1. MAOSH OPERATSIYALARINI YUKLASH
  // IZOH: Supabase dan barcha maosh operatsiyalarini olish
  Future<void> loadSalaryOperations() async {
    try {
      isLoading.value = true;

      // Supabase so'rovi - staff ma'lumotlarini JOIN qilish
      final response = await _supabase
          .from('salary_operations')
          .select('''
            *,
            staff:staff_id (
              first_name,
              last_name,
              position,
              salary_type
            )
          ''')
          .eq('period_month', selectedMonth.value)
          .eq('period_year', selectedYear.value)
          .order('created_at', ascending: false);

      // Ma'lumotlarni modelga aylantirish
      salaryOperations.value = (response as List)
          .map((json) => SalaryOperation.fromJson(json))
          .toList();

      // Filtrlash
      applyFilters();

      // Statistikani hisoblash
      calculateStatistics();
    } catch (e) {
      Get.snackbar(
        'Xatolik',
        'Ma\'lumotlarni yuklashda xatolik: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // 2. FILTRLARNI QO'LLASH
  // IZOH: Status va qidiruv bo'yicha filtrlash
  void applyFilters() {
    var filtered = salaryOperations.toList();

    // Status bo'yicha filtrlash
    if (selectedStatus.value == 'paid') {
      filtered = filtered.where((op) => op.isPaid).toList();
    } else if (selectedStatus.value == 'unpaid') {
      filtered = filtered.where((op) => !op.isPaid).toList();
    }

    // Qidiruv bo'yicha filtrlash
    if (searchQuery.value.isNotEmpty) {
      filtered = filtered.where((op) {
        final fullName = op.staffFullName.toLowerCase();
        final position = op.staffPosition?.toLowerCase() ?? '';
        final query = searchQuery.value.toLowerCase();
        return fullName.contains(query) || position.contains(query);
      }).toList();
    }

    filteredOperations.value = filtered;
  }

  // 3. STATISTIKANI HISOBLASH
  // IZOH: Umumiy summa va soni hisoblash
  void calculateStatistics() {
    totalPaidSalaries.value = salaryOperations
        .where((op) => op.isPaid)
        .fold(0.0, (sum, op) => sum + op.netAmount);

    totalUnpaidSalaries.value = salaryOperations
        .where((op) => !op.isPaid)
        .fold(0.0, (sum, op) => sum + op.netAmount);

    paidCount.value = salaryOperations.where((op) => op.isPaid).length;
    unpaidCount.value = salaryOperations.where((op) => !op.isPaid).length;
  }

  // 4. MAOSH TO'LASH
  // IZOH: Tanlangan operatsiyani to'langan deb belgilash
  Future<void> paySalary(String operationId) async {
    try {
      isLoading.value = true;

      // Supabase da yangilash
      await _supabase
          .from('salary_operations')
          .update({
            'is_paid': true,
            'paid_at': DateTime.now().toIso8601String(),
            'paid_by': _supabase.auth.currentUser?.id,
          })
          .eq('id', operationId);

      // Lokal ma'lumotlarni yangilash
      await loadSalaryOperations();

      Get.snackbar(
        'Muvaffaqiyat',
        'Maosh to\'landi',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Xatolik',
        'Maosh to\'lashda xatolik: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // 5. MAOSH HISOBLASH VA YARATISH
  // IZOH: Yangi maosh operatsiyasini yaratish va hisoblash
  Future<void> calculateAndCreateSalary({
    required String staffId,
    required String branchId,
    required double baseAmount,
    required String salaryType,
    int? workedDays,
    int? workedHours,
    double bonusPercent = 0,
    double penaltyPercent = 0,
    double advanceDeduction = 0,
    double loanDeduction = 0,
    String? notes,
  }) async {
    try {
      isLoading.value = true;

      // Bonus hisoblash
      final bonusAmount = baseAmount * (bonusPercent / 100);

      // Jarima hisoblash
      final penaltyAmount = baseAmount * (penaltyPercent / 100);

      // Gross amount (asosiy + bonus - jarima)
      final grossAmount = baseAmount + bonusAmount - penaltyAmount;

      // Net amount (gross - avans - qarz)
      final netAmount = grossAmount - advanceDeduction - loanDeduction;

      // Yangi operatsiya yaratish
      final newOperation = {
        'branch_id': branchId,
        'staff_id': staffId,
        'operation_type': 'salary',
        'period_month': selectedMonth.value,
        'period_year': selectedYear.value,
        'base_amount': baseAmount,
        'worked_days': workedDays,
        'worked_hours': workedHours,
        'bonus_percent': bonusPercent,
        'bonus_amount': bonusAmount,
        'penalty_percent': penaltyPercent,
        'penalty_amount': penaltyAmount,
        'advance_deduction': advanceDeduction,
        'loan_deduction': loanDeduction,
        'gross_amount': grossAmount,
        'net_amount': netAmount,
        'is_paid': false,
        'calculated_by': _supabase.auth.currentUser?.id,
        'notes': notes,
      };

      // Supabase ga qo'shish
      await _supabase.from('salary_operations').insert(newOperation);

      // Ma'lumotlarni yangilash
      await loadSalaryOperations();

      Get.snackbar(
        'Muvaffaqiyat',
        'Maosh hisoblandi',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Xatolik',
        'Maosh hisoblashda xatolik: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // 6. OY VA YIL O'ZGARTIRISH
  // IZOH: Boshqa oy va yilni tanlash
  void changePeriod(int month, int year) {
    selectedMonth.value = month;
    selectedYear.value = year;
    loadSalaryOperations();
  }

  // 7. STATUS FILTRI O'ZGARTIRISH
  // IZOH: To'langan/to'lanmagan bo'yicha filtrlash
  void changeStatusFilter(String status) {
    selectedStatus.value = status;
    applyFilters();
  }

  // 8. QIDIRUV
  // IZOH: Hodim nomi yoki lavozimi bo'yicha qidirish
  void search(String query) {
    searchQuery.value = query;
    applyFilters();
  }

  // 9. OPERATSIYANI O'CHIRISH
  // IZOH: Maosh operatsiyasini o'chirish
  Future<void> deleteSalaryOperation(String operationId) async {
    try {
      isLoading.value = true;

      await _supabase.from('salary_operations').delete().eq('id', operationId);

      await loadSalaryOperations();

      Get.snackbar(
        'Muvaffaqiyat',
        'Operatsiya o\'chirildi',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Xatolik',
        'O\'chirishda xatolik: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
