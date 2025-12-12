// lib/data/repositories/payment_repository.dart
// ================================================================================
// PAYMENT REPOSITORY - To'liq funksional to'lovlar repository
// ================================================================================

import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:postgrest/postgrest.dart';
import '../models/payment_model.dart';

class PaymentRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ============================================================================
  // 1. TO'LOV QABUL QILISH (DATABASE FUNCTION ORQALI)
  // ============================================================================

  Future<Map<String, dynamic>?> processStudentPayment({
    required String studentId,
    required String branchId,
    required String classId,
    required double amount,
    double discountPercent = 0,
    double discountAmount = 0,
    String? discountReason,
    String paymentMethod = 'cash',
    String paymentType = 'tuition',
    int? periodMonth,
    int? periodYear,
    String? notes,
    String? receivedBy,
    bool isPartial = false,
    double? paidAmount,
  }) async {
    try {
      final response = await _supabase.rpc(
        'process_student_payment',
        params: {
          'p_student_id': studentId,
          'p_branch_id': branchId,
          'p_class_id': classId,
          'p_amount': amount,
          'p_discount_percent': discountPercent,
          'p_discount_amount': discountAmount,
          'p_discount_reason': discountReason,
          'p_payment_method': paymentMethod,
          'p_payment_type': paymentType,
          'p_period_month': periodMonth,
          'p_period_year': periodYear,
          'p_notes': notes,
          'p_received_by': receivedBy,
          'p_is_partial': isPartial,
          'p_paid_amount': paidAmount,
        },
      );

      if (response != null && response is List && response.isNotEmpty) {
        return response.first as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Process payment xatolik: $e');
      return null;
    }
  }

  // ============================================================================
  // 2. TO'LOVLAR RO'YXATI (FILTRLASH BILAN)
  // ============================================================================

  Future<List<PaymentModel>> getPayments({
    String? branchId,
    String? studentId,
    String? classId,
    String? paymentMethod,
    String? paymentStatus,
    DateTime? startDate,
    DateTime? endDate,
    int? month,
    int? year,
    int limit = 100,
    int offset = 0,
    required String paymentType,
  }) async {
    try {
      // VIEW dan foydalanamiz (qo'shimcha ma'lumotlar bilan)
      PostgrestFilterBuilder query = _supabase
          .from('v_student_payment_details')
          .select();

      // Filtrlar qo'shish
      if (branchId != null) {
        query = query.eq('branch_id', branchId);
      }
      if (studentId != null) {
        query = query.eq('student_id', studentId);
      }
      if (classId != null) {
        query = query.eq('class_id', classId);
      }
      if (paymentMethod != null) {
        query = query.eq('payment_method', paymentMethod);
      }
      if (paymentStatus != null) {
        query = query.eq('payment_status', paymentStatus);
      }

      if (startDate != null) {
        query = query.gte(
          'payment_date',
          startDate.toIso8601String().split('T')[0],
        );
      }
      if (endDate != null) {
        query = query.lte(
          'payment_date',
          endDate.toIso8601String().split('T')[0],
        );
      }
      if (month != null) {
        query = query.eq('period_month', month);
      }
      if (year != null) {
        query = query.eq('period_year', year);
      }

      // Ordering va limit
      final response = await query
          .order('payment_date', ascending: false)
          .order('payment_time', ascending: false)
          .range(offset, offset + limit - 1);

      return (response as List)
          .map((json) => PaymentModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Get payments xatolik: $e');
      rethrow; // Xatolikni qaytarish
    }
  }

  // ============================================================================
  // 3. BITTA TO'LOVNI OLISH
  // ============================================================================

  Future<PaymentModel?> getPaymentById(String paymentId) async {
    try {
      final response = await _supabase
          .from('v_student_payment_details')
          .select()
          .eq('payment_id', paymentId)
          .single();

      return PaymentModel.fromJson(response);
    } catch (e) {
      print('Get payment by ID xatolik: $e');
      return null;
    }
  }

  // ============================================================================
  // 4. TO'LOVNI BEKOR QILISH
  // ============================================================================

  Future<bool> cancelPayment(String paymentId) async {
    try {
      await _supabase
          .from('payments')
          .update({
            'payment_status': 'cancelled',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', paymentId);
      return true;
    } catch (e) {
      print('Cancel payment xatolik: $e');
      return false;
    }
  }

  // ============================================================================
  // 5. BUGUNGI TO'LOVLAR
  // ============================================================================

  Future<List<PaymentModel>> getTodayPayments(String branchId) async {
    final today = DateTime.now();
    return getPayments(
      branchId: branchId,
      startDate: DateTime(today.year, today.month, today.day),
      endDate: DateTime(today.year, today.month, today.day, 23, 59, 59),
      limit: 1000,
      paymentType: '',
    );
  }

  // ============================================================================
  // 6. OYLIK STATISTIKA
  // ============================================================================

  Future<Map<String, dynamic>> getMonthlyStatistics({
    required String branchId,
    required int month,
    required int year,
  }) async {
    try {
      final payments = await getPayments(
        branchId: branchId,
        month: month,
        year: year,
        limit: 10000,
        paymentType: '',
      );

      double totalRevenue = 0;
      double totalDiscount = 0;
      double totalDebt = 0;
      int paidCount = 0;
      int partialCount = 0;
      int cancelledCount = 0;

      Map<String, double> byMethod = {
        'cash': 0,
        'click': 0,
        'terminal': 0,
        'owner_fund': 0,
      };

      for (var payment in payments) {
        if (payment.paymentStatus == 'paid') {
          totalRevenue += payment.finalAmount;
          totalDiscount += payment.discountAmount;
          paidCount++;
          byMethod[payment.paymentMethod] =
              (byMethod[payment.paymentMethod] ?? 0) + payment.finalAmount;
        } else if (payment.paymentStatus == 'partial') {
          totalRevenue += payment.paidAmount;
          totalDebt += payment.remainingDebt;
          partialCount++;
        } else if (payment.paymentStatus == 'cancelled') {
          cancelledCount++;
        }
      }

      return {
        'total_revenue': totalRevenue,
        'total_discount': totalDiscount,
        'total_debt': totalDebt,
        'paid_count': paidCount,
        'partial_count': partialCount,
        'cancelled_count': cancelledCount,
        'total_count': payments.length,
        'by_method': byMethod,
      };
    } catch (e) {
      print('Get monthly statistics xatolik: $e');
      return {};
    }
  }

  // ============================================================================
  // 7. O'QUVCHI TO'LOV TARIXI
  // ============================================================================

  Future<List<PaymentModel>> getStudentPaymentHistory(String studentId) async {
    return getPayments(studentId: studentId, limit: 1000, paymentType: '');
  }

  // ============================================================================
  // 8. O'QUVCHI QARZLARI
  // ============================================================================

  Future<List<StudentDebtModel>> getStudentDebts(
    String s, {
    String? studentId,
    String? branchId,
    bool onlyUnsettled = true,
  }) async {
    try {
      PostgrestFilterBuilder query = _supabase.from('student_debts').select();

      if (studentId != null) {
        query = query.eq('student_id', studentId);
      }
      if (branchId != null) {
        query = query.eq('branch_id', branchId);
      }
      if (onlyUnsettled) {
        query = query.eq('is_settled', false);
      }

      final response = await query.order('created_at', ascending: false);

      return (response as List)
          .map((json) => StudentDebtModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Get student debts xatolik: $e');
      rethrow;
    }
  }

  // ============================================================================
  // 9. QARZ TO'LASH (DATABASE FUNCTION ORQALI)
  // ============================================================================

  Future<Map<String, dynamic>?> payStudentDebt({
    required String debtId,
    required double paidAmount,
    String paymentMethod = 'cash',
    String? receivedBy,
    String? notes,
  }) async {
    try {
      final response = await _supabase.rpc(
        'pay_student_debt',
        params: {
          'p_debt_id': debtId,
          'p_paid_amount': paidAmount,
          'p_payment_method': paymentMethod,
          'p_received_by': receivedBy,
          'p_notes': notes,
        },
      );

      if (response != null && response is List && response.isNotEmpty) {
        return response.first as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Pay debt xatolik: $e');
      return null;
    }
  }

  // ============================================================================
  // 10. KASSALAR RO'YXATI
  // ============================================================================

  Future<List<CashRegisterModel>> getCashRegisters({
    String? branchId,
    String? registerType,
  }) async {
    try {
      PostgrestFilterBuilder query = _supabase.from('cash_register').select();

      if (branchId != null) {
        query = query.eq('branch_id', branchId);
      }
      if (registerType != null) {
        query = query.eq('register_type', registerType);
      }

      final response = await query;
      return (response as List)
          .map((json) => CashRegisterModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Get cash registers xatolik: $e');
      rethrow;
    }
  }

  // ============================================================================
  // 11. KASSA BALANSI
  // ============================================================================

  Future<double> getCashBalance(String registerId) async {
    try {
      final response = await _supabase
          .from('cash_register')
          .select('current_balance')
          .eq('id', registerId)
          .single();

      return (response['current_balance'] as num).toDouble();
    } catch (e) {
      print('Get cash balance xatolik: $e');
      return 0;
    }
  }

  // ============================================================================
  // 12. KASSADAN KASSAGA O'TKAZISH (DATABASE FUNCTION ORQALI)
  // ============================================================================

  Future<Map<String, dynamic>?> transferBetweenRegisters({
    required String fromRegisterId,
    required String toRegisterId,
    required double amount,
    String? reason,
    String? notes,
    String? requestedBy,
    String? branchId,
  }) async {
    try {
      final response = await _supabase.rpc(
        'transfer_between_registers',
        params: {
          'p_from_register_id': fromRegisterId,
          'p_to_register_id': toRegisterId,
          'p_amount': amount,
          'p_reason': reason,
          'p_notes': notes,
          'p_requested_by': requestedBy,
          'p_branch_id': branchId,
        },
      );

      if (response != null && response is List && response.isNotEmpty) {
        return response.first as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Transfer between registers xatolik: $e');
      return null;
    }
  }

  // ============================================================================
  // 13. KASSA HISOBOTI (DATABASE FUNCTION ORQALI)
  // ============================================================================

  Future<Map<String, dynamic>?> getCashRegisterReport({
    required String registerId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final response = await _supabase.rpc(
        'get_cash_register_report',
        params: {
          'p_register_id': registerId,
          'p_start_date': startDate?.toIso8601String().split('T')[0],
          'p_end_date': endDate?.toIso8601String().split('T')[0],
        },
      );

      if (response != null && response is List && response.isNotEmpty) {
        return response.first as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Get cash register report xatolik: $e');
      return null;
    }
  }

  // ============================================================================
  // 14. JAMI DAROMAD (MA'LUM DAVR UCHUN)
  // ============================================================================

  Future<double> getTotalRevenue({
    required String branchId,
    DateTime? startDate,
    DateTime? endDate,
    int? month,
    int? year,
  }) async {
    try {
      final payments = await getPayments(
        branchId: branchId,
        startDate: startDate,
        endDate: endDate,
        month: month,
        year: year,
        paymentStatus: 'paid',
        limit: 100000,
        paymentType: '',
      );

      return payments.fold<double>(
        0.0,
        (sum, payment) => sum + (payment.finalAmount),
      );
    } catch (e) {
      print('Get total revenue xatolik: $e');
      return 0;
    }
  }

  // ============================================================================
  // 15. TO'LOV USULLARI BO'YICHA STATISTIKA
  // ============================================================================

  Future<Map<String, double>> getRevenueByPaymentMethod({
    required String branchId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final payments = await getPayments(
        branchId: branchId,
        startDate: startDate,
        endDate: endDate,
        paymentStatus: 'paid',
        limit: 100000,
        paymentType: '',
      );

      Map<String, double> result = {
        'cash': 0,
        'click': 0,
        'terminal': 0,
        'owner_fund': 0,
      };

      for (var payment in payments) {
        result[payment.paymentMethod] =
            (result[payment.paymentMethod] ?? 0) + payment.finalAmount;
      }

      return result;
    } catch (e) {
      print('Get revenue by payment method xatolik: $e');
      return {};
    }
  }

  Future<dynamic> getPaymentsCount({
    required String branchId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {}
}
