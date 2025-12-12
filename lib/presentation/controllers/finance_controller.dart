// lib/presentation/controllers/finance_controller.dart
// IZOH: Moliyaviy ma'lumotlarni boshqarish uchun controller.
// Bu controller tushumlar, xarajatlar, kassa qoldig'i kabi moliyaviy
// ma'lumotlarni yuklaydi va UI ga taqdim etadi.

import 'package:flutter_application_1/data/repositories/payment_repositry.dart';
import 'package:get/get.dart';
import 'auth_controller.dart';

class FinanceController extends GetxController {
  // REPOSITORIES - Ma'lumotlar bazasi bilan ishlash uchun
  final PaymentRepository _paymentRepository = PaymentRepository();

  // ✅ AuthController ni topish
  // Get.find() - AppBindings da yaratilgan controller ni topadi
  // Agar AppBindings ishlamagan bo'lsa - "not found" xatosi
  final AuthController _authController = Get.find<AuthController>();

  // REACTIVE VARIABLES - O'zgarsa UI avtomatik yangilanadi
  final RxBool isLoading = true.obs; // Yuklanish holati
  final RxString selectedPeriod = 'month'.obs; // Tanlangan davr

  // ASOSIY STATISTIKA
  final RxDouble totalRevenue = 0.0.obs; // Jami tushumlar
  final RxDouble totalExpenses = 0.0.obs; // Jami xarajatlar
  final RxDouble netProfit = 0.0.obs; // Sof foyda
  final RxDouble cashBalance = 0.0.obs; // Kassa qoldig'i

  // TUSHUMLAR TARKIBI
  final RxDouble monthlyPayments = 0.0.obs; // Oylik to'lovlar
  final RxDouble oneTimePayments = 0.0.obs; // Bir martalik to'lovlar
  final RxDouble otherRevenue = 0.0.obs; // Boshqa tushumlar

  // XARAJATLAR TARKIBI
  final RxDouble salaryExpenses = 0.0.obs; // Maosh xarajatlari
  final RxDouble utilityExpenses = 0.0.obs; // Kommunal xarajatlari
  final RxDouble kitchenExpenses = 0.0.obs; // Oshxona xarajatlari
  final RxDouble otherExpenses = 0.0.obs; // Boshqa xarajatlar

  @override
  void onInit() {
    super.onInit();
    // Controller yaratilishi bilan ma'lumotlarni yuklash
    loadFinanceData();
  }

  // MOLIYAVIY MA'LUMOTLARNI YUKLASH - Asosiy metod
  Future<void> loadFinanceData() async {
    try {
      isLoading.value = true; // Yuklanish boshlanadi

      // ✅ Foydalanuvchining filialini olish
      // currentUser - AuthController dan keladigan ma'lumot
      final branchId = _authController.currentUser.value?.branchId;

      // Agar filial yo'q bo'lsa - to'xtatish
      if (branchId == null) {
        print('Branch ID topilmadi');
        return;
      }

      // Davr bo'yicha sana oralig'ini aniqlash
      final dateRange = _getDateRangeForPeriod();

      // Tushumlarni ma'lumotlar bazasidan olish
      final revenue = await _paymentRepository.getTotalRevenue(
        branchId: branchId,
        startDate: dateRange['start']!,
        endDate: dateRange['end']!,
      );
      totalRevenue.value = revenue;

      // Tushumlar tarkibini yuklash
      await _loadRevenueBreakdown(branchId, dateRange);

      // ⚠️ PLACEHOLDER - Haqiqiy xarajatlarni hisoblash kerak
      // Hozircha tushumlarning 60% ni xarajat deb olamiz
      totalExpenses.value = revenue * 0.6;
      salaryExpenses.value = totalExpenses.value * 0.7; // 70% maosh
      utilityExpenses.value = totalExpenses.value * 0.15; // 15% kommunal
      kitchenExpenses.value = totalExpenses.value * 0.10; // 10% oshxona
      otherExpenses.value = totalExpenses.value * 0.05; // 5% boshqa

      // Sof foydani hisoblash: Tushum - Xarajat
      netProfit.value = totalRevenue.value - totalExpenses.value;

      // ⚠️ PLACEHOLDER - Kassa qoldig'i
      cashBalance.value = 45750000;
    } catch (e) {
      print('Load finance data xatolik: $e');
      Get.snackbar('Xatolik', 'Ma\'lumotlarni yuklashda xatolik');
    } finally {
      isLoading.value = false; // Yuklanish tugadi
    }
  }

  // TUSHUMLAR TARKIBINI YUKLASH
  // Oylik, bir martalik va boshqa to'lovlarni ajratib ko'rsatish
  Future<void> _loadRevenueBreakdown(
    String branchId,
    Map<String, DateTime> dateRange,
  ) async {
    try {
      // Barcha to'lovlarni olish
      final payments = await _paymentRepository.getPayments(
        branchId: branchId,
        startDate: dateRange['start']!,
        endDate: dateRange['end']!,
        paymentType: 'monthly', // Filter bo'yicha
        limit: 10000,
      );

      // To'lovlarni turlariga ajratish
      double monthly = 0;
      double oneTime = 0;
      double other = 0;

      for (var payment in payments) {
        // Faqat to'langan to'lovlarni hisoblash
        if (payment.paymentStatus == 'paid') {
          switch (payment.paymentType) {
            case 'monthly':
              monthly += payment.finalAmount;
              break;
            case 'one_time':
              oneTime += payment.finalAmount;
              break;
            default:
              other += payment.finalAmount;
          }
        }
      }

      // Qiymatlarni saqlash
      monthlyPayments.value = monthly;
      oneTimePayments.value = oneTime;
      otherRevenue.value = other;
    } catch (e) {
      print('Load revenue breakdown xatolik: $e');
    }
  }

  // DAVRNI O'ZGARTIRISH
  // Foydalanuvchi davr tanlasa (bugun, hafta, oy, yil)
  void changePeriod(String period) {
    selectedPeriod.value = period;
    loadFinanceData(); // Ma'lumotlarni qayta yuklash
  }

  // DAVR UCHUN SANA ORALIG'INI OLISH
  // Masalan: "oy" tanlansa - oyning 1-sanasidan oxirigacha
  Map<String, DateTime> _getDateRangeForPeriod() {
    final now = DateTime.now();
    DateTime start;
    DateTime end = now;

    switch (selectedPeriod.value) {
      case 'today':
        // Bugun: 00:00:00 dan 23:59:59 gacha
        start = DateTime(now.year, now.month, now.day);
        end = start.add(Duration(days: 1));
        break;

      case 'week':
        // Hafta: Dushanbadan boshlanadi
        start = now.subtract(Duration(days: now.weekday - 1));
        start = DateTime(start.year, start.month, start.day);
        end = start.add(Duration(days: 7));
        break;

      case 'month':
        // Oy: 1-sanadan keyingi oyning 1-sanasigacha
        start = DateTime(now.year, now.month, 1);
        end = DateTime(now.year, now.month + 1, 1);
        break;

      case 'year':
        // Yil: 1-yanvardan 31-dekabrgacha
        start = DateTime(now.year, 1, 1);
        end = DateTime(now.year + 1, 1, 1);
        break;

      default:
        // Agar noma'lum davr bo'lsa - oy deb olish
        start = DateTime(now.year, now.month, 1);
        end = DateTime(now.year, now.month + 1, 1);
    }

    return {'start': start, 'end': end};
  }

  // MA'LUMOTLARNI YANGILASH
  // Foydalanuvchi "yangilash" tugmasini bossa
  Future<void> refreshData() async {
    await loadFinanceData();
  }
}

// MUHIM ESLATMALAR:
// 1. Get.find<AuthController>() - AppBindings da yaratilgan controller ni topadi
// 2. Agar AppBindings ishlamagan bo'lsa - "AuthController not found" xatosi
// 3. currentUser.value?.branchId - null safety, agar user yo'q bo'lsa crash bo'lmaydi
// 4. Rx variables (.obs) - UI avtomatik yangilanadi (Obx widget orqali)
