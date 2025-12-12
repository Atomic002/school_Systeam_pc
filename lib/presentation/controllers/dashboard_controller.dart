// lib/presentation/controllers/dashboard_controller.dart
// IZOH: Asosiy dashboard sahifasining state management'i.
// Statistika, hisobotlar va umumiy ma'lumotlarni boshqaradi.

import 'package:flutter_application_1/data/repositories/payment_repositry.dart';
import 'package:flutter_application_1/data/repositories/student_repositry.dart';
import 'package:get/get.dart';

import 'auth_controller.dart';

class DashboardController extends GetxController {
  // Repositories
  final StudentRepository _studentRepository = StudentRepository();
  final PaymentRepository _paymentRepository = PaymentRepository();
  final AuthController _authController = Get.find<AuthController>();

  // Reactive variables
  final RxBool isLoading = true.obs;
  final RxInt totalStudents = 0.obs;
  final RxInt activeStudents = 0.obs;
  final RxInt debtorStudents = 0.obs;
  final RxDouble todayRevenue = 0.0.obs;
  final RxDouble monthRevenue = 0.0.obs;
  final RxDouble yearRevenue = 0.0.obs;
  final RxInt todayPaymentsCount = 0.obs;
  final RxString selectedBranchId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Foydalanuvchining filialni olish
    selectedBranchId.value = _authController.currentUser.value?.branchId ?? '';
    // Ma'lumotlarni yuklash
    loadDashboardData();
  }

  // Barcha dashboard ma'lumotlarini yuklash
  Future<void> loadDashboardData() async {
    try {
      isLoading.value = true;

      // Parallel ravishda barcha ma'lumotlarni yuklash
      await Future.wait([_loadStudentStatistics(), _loadRevenueStatistics()]);
    } catch (e) {
      print('Load dashboard data xatolik: $e');
      Get.snackbar(
        'Xatolik',
        'Ma\'lumotlarni yuklashda xatolik',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // O'quvchilar statistikasini yuklash
  Future<void> _loadStudentStatistics() async {
    try {
      if (selectedBranchId.value.isEmpty) return;

      // Umumiy o'quvchilar soni
      final total = await _studentRepository.getStudentsCount(
        branchId: selectedBranchId.value,
      );
      totalStudents.value = total;

      // Aktiv o'quvchilar
      final active = await _studentRepository.getStudentsCount(
        branchId: selectedBranchId.value,
        status: 'active',
      );
      activeStudents.value = active;

      // Qarzdor o'quvchilar soni
      // final debtors = await _studentRepository.getDebtorStudents(
      //   selectedBranchId.value,
      // );
      //   debtorStudents.value = debtors.length;
      // } catch (e) {
      //   print('Load student statistics xatolik: $e');
    } catch (e) {
      print('Load student statistics xatolik: $e');
    }
  }

  // Moliyaviy statistikani yuklash
  Future<void> _loadRevenueStatistics() async {
    try {
      if (selectedBranchId.value.isEmpty) return;

      final now = DateTime.now();

      // Bugungi daromad
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = todayStart.add(Duration(days: 1));

      final todayRev = await _paymentRepository.getTotalRevenue(
        branchId: selectedBranchId.value,
        startDate: todayStart,
        endDate: todayEnd,
      );
      todayRevenue.value = todayRev;

      // Bugungi to'lovlar soni
      final todayCount = await _paymentRepository.getPaymentsCount(
        branchId: selectedBranchId.value,
        startDate: todayStart,
        endDate: todayEnd,
      );
      todayPaymentsCount.value = todayCount;

      // Oylik daromad
      final monthRev = await _paymentRepository.getTotalRevenue(
        branchId: selectedBranchId.value,
        month: now.month,
        year: now.year,
      );
      monthRevenue.value = monthRev;

      // Yillik daromad
      final yearRev = await _paymentRepository.getTotalRevenue(
        branchId: selectedBranchId.value,
        year: now.year,
      );
      yearRevenue.value = yearRev;
    } catch (e) {
      print('Load revenue statistics xatolik: $e');
    }
  }

  // Ma'lumotlarni yangilash (refresh)
  Future<void> refreshData() async {
    await loadDashboardData();
  }

  // Summani formatlash (123456789 -> 123,456,789)
  String formatCurrency(double amount) {
    return amount
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }
}
