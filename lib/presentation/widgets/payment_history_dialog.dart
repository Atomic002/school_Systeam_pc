// lib/presentation/widgets/payment_history_dialog_v4.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class PaymentHistoryDialog extends StatelessWidget {
  final dynamic controller;

  const PaymentHistoryDialog({
    Key? key,
    required this.controller,
  }) : super(key: key);

  final Color primaryBlue = const Color(0xFF2196F3);
  final Color darkBlue = const Color(0xFF1565C0);
  final Color lightBlue = const Color(0xFFBBDEFB);
  final Color paleBlue = const Color(0xFFE3F2FD);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 1000,
        height: 800,
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryBlue, darkBlue],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.history_rounded, color: Colors.white, size: 32),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TO\'LOV TARIXI',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Obx(() {
                  if (controller.selectedStudent.value != null) {
                    return Text(
                      controller.selectedStudent.value!.fullName,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.95),
                        fontSize: 14,
                      ),
                    );
                  }
                  return SizedBox.shrink();
                }),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.close_rounded, color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Obx(() {
      if (controller.isLoadingHistory.value) {
        return Center(
          child: CircularProgressIndicator(color: primaryBlue),
        );
      }

      if (controller.paymentHistory.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey[300]),
              SizedBox(height: 20),
              Text(
                'Hali to\'lov qilinmagan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        );
      }

      return Column(
        children: [
          _buildSummaryCards(),
          Expanded(child: _buildHistoryList()),
        ],
      );
    });
  }

  Widget _buildSummaryCards() {
    return Obx(() {
      final history = controller.paymentHistory;
      
      double totalPaid = 0;
      double totalDebt = 0;
      int paidCount = 0;
      int partialCount = 0;

      for (var payment in history) {
        if (payment.status == 'paid') {
          totalPaid += payment.finalAmount;
          paidCount++;
        } else if (payment.status == 'partial') {
          totalPaid += payment.paidAmount ?? 0;
          totalDebt += payment.remainingDebt ?? 0;
          partialCount++;
        }
      }

      return Container(
        padding: EdgeInsets.all(20),
        color: paleBlue,
        child: Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                icon: Icons.check_circle_rounded,
                label: 'To\'liq to\'lovlar',
                value: '$paidCount ta',
                color: Colors.green,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _buildSummaryCard(
                icon: Icons.attach_money_rounded,
                label: 'Jami to\'langan',
                value: _formatCurrency(totalPaid),
                color: primaryBlue,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _buildSummaryCard(
                icon: Icons.warning_amber_rounded,
                label: 'Qisman to\'lovlar',
                value: '$partialCount ta',
                color: Colors.orange,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _buildSummaryCard(
                icon: Icons.money_off_rounded,
                label: 'Jami qarz',
                value: _formatCurrency(totalDebt),
                color: Colors.red,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    return Obx(() {
      final history = controller.paymentHistory;
      
      return ListView.separated(
        padding: EdgeInsets.all(20),
        itemCount: history.length,
        separatorBuilder: (_, __) => SizedBox(height: 16),
        itemBuilder: (context, index) {
          final payment = history[index];
          return _buildPaymentCard(payment);
        },
      );
    });
  }

  Widget _buildPaymentCard(dynamic payment) {
    final isPaid = payment.status == 'paid';
    final isPartial = payment.status == 'partial';
    final isCancelled = payment.status == 'cancelled';

    Color statusColor = Colors.green;
    IconData statusIcon = Icons.check_circle_rounded;
    String statusText = 'To\'landi';

    if (isPartial) {
      statusColor = Colors.orange;
      statusIcon = Icons.warning_amber_rounded;
      statusText = 'Qisman';
    } else if (isCancelled) {
      statusColor = Colors.red;
      statusIcon = Icons.cancel_rounded;
      statusText = 'Bekor qilingan';
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withOpacity(0.3), width: 2),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(statusIcon, color: statusColor, size: 24),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        payment.periodText,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Chek: ${payment.receiptNumber}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        icon: Icons.calendar_today_rounded,
                        label: 'Sana',
                        value: _formatDate(payment.paymentDate),
                        color: primaryBlue,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: _buildInfoItem(
                        icon: Icons.payment_rounded,
                        label: 'To\'lov usuli',
                        value: _getPaymentMethodText(payment.paymentMethod),
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        icon: Icons.category_rounded,
                        label: 'To\'lov turi',
                        value: _getPaymentTypeText(payment.paymentType),
                        color: Colors.orange,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: _buildInfoItem(
                        icon: Icons.person_outline,
                        label: 'Qabul qildi',
                        value: payment.receivedByName ?? '-',
                        color: Colors.purple,
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 16),
                Divider(),
                SizedBox(height: 16),

                _buildAmountRow('Asl summa:', payment.amount),
                
                if (payment.discountAmount > 0)
                  _buildAmountRow('Chegirma:', payment.discountAmount, isDiscount: true),
                
                SizedBox(height: 12),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor, width: 2),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'JAMI:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                      Text(
                        '${_formatCurrency(payment.finalAmount)} so\'m',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),

                if (isPartial && payment.remainingDebt != null && payment.remainingDebt! > 0) ...[
                  SizedBox(height: 12),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red, width: 1),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, color: Colors.red, size: 20),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Qarz: ${_formatCurrency(payment.remainingDebt!)} so\'m',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red[700],
                                ),
                              ),
                              if (payment.debtReason != null) ...[
                                SizedBox(height: 4),
                                Text(
                                  'Sabab: ${payment.debtReason}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.red[600],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                if (payment.notes != null) ...[
                  SizedBox(height: 12),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: paleBlue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.note_alt_rounded, color: primaryBlue, size: 20),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            payment.notes,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountRow(String label, dynamic amount, {bool isDiscount = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          Text(
            '${isDiscount ? '-' : ''}${_formatCurrency(amount)} so\'m',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDiscount ? Colors.red[600] : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return '-';
    try {
      final dt = date is DateTime ? date : DateTime.parse(date.toString());
      return DateFormat('dd.MM.yyyy').format(dt);
    } catch (e) {
      return date.toString();
    }
  }

  String _formatCurrency(dynamic amount) {
    if (amount == null) return '0';
    try {
      final formatter = NumberFormat('#,###', 'uz_UZ');
      return formatter.format(amount is num ? amount : double.parse(amount.toString()));
    } catch (e) {
      return amount.toString();
    }
  }

  String _getPaymentMethodText(String? method) {
    switch (method) {
      case 'cash': return 'Naqd';
      case 'click': return 'Click';
      case 'terminal': return 'Terminal';
      case 'owner_fund': return 'Ega kassasi';
      default: return '-';
    }
  }

  String _getPaymentTypeText(String? type) {
    switch (type) {
      case 'tuition': return 'Oylik';
      case 'registration': return 'Ro\'yxat';
      case 'exam': return 'Imtihon';
      case 'debt_payment': return 'Qarz';
      default: return 'Boshqa';
    }
  }
}