// lib/presentation/widgets/payment_history_dialog_v4.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class PaymentHistoryDialog extends StatelessWidget {
  final dynamic controller;

  const PaymentHistoryDialog({Key? key, required this.controller})
    : super(key: key);

  final Color primaryBlue = const Color(0xFF2196F3);
  final Color darkBlue = const Color(0xFF1565C0);
  final Color lightBlue = const Color(0xFFBBDEFB);
  final Color paleBlue = const Color(0xFFE3F2FD);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 10,
      backgroundColor: Colors.transparent,
      child: Container(
        width: 1000,
        height: 800,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
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
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryBlue, darkBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.history_edu_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TO\'LOV TARIXI',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
                SizedBox(height: 4),
                Obx(() {
                  if (controller.selectedStudent.value != null) {
                    return Row(
                      children: [
                        Icon(Icons.person, color: Colors.white70, size: 14),
                        SizedBox(width: 6),
                        Text(
                          controller.selectedStudent.value!.fullName,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
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
            tooltip: 'Yopish',
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Obx(() {
      if (controller.isLoadingHistory.value) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: primaryBlue),
              SizedBox(height: 16),
              Text('Yuklanmoqda...', style: TextStyle(color: Colors.grey)),
            ],
          ),
        );
      }

      if (controller.paymentHistory.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.receipt_long_outlined,
                  size: 80,
                  color: Colors.grey[400],
                ),
              ),
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
          Divider(height: 1),
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
        if (payment.status == 'cancelled')
          continue; // Bekor qilinganlarni hisoblamaymiz

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
        color: Colors.grey[50],
        child: Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                icon: Icons.check_circle_rounded,
                label: 'To\'liq to\'lovlar',
                value: '$paidCount ta',
                color: Colors.green,
                bgColor: Colors.green.withOpacity(0.1),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _buildSummaryCard(
                icon: Icons.attach_money_rounded,
                label: 'Jami to\'langan',
                value: _formatCurrency(totalPaid),
                color: primaryBlue,
                bgColor: primaryBlue.withOpacity(0.1),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _buildSummaryCard(
                icon: Icons.warning_amber_rounded,
                label: 'Qisman to\'lovlar',
                value: '$partialCount ta',
                color: Colors.orange,
                bgColor: Colors.orange.withOpacity(0.1),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _buildSummaryCard(
                icon: Icons.money_off_rounded,
                label: 'Jami qarz',
                value: _formatCurrency(totalDebt),
                color: Colors.red,
                bgColor: Colors.red.withOpacity(0.1),
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
    required Color bgColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    return Obx(() {
      final history = controller.paymentHistory;

      return ListView.separated(
        padding: EdgeInsets.all(24),
        itemCount: history.length,
        separatorBuilder: (_, __) => SizedBox(height: 16),
        itemBuilder: (context, index) {
          final payment = history[index];
          return _buildPaymentCard(context, payment);
        },
      );
    });
  }

  Widget _buildPaymentCard(BuildContext context, dynamic payment) {
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
      statusIcon = Icons.block_rounded;
      statusText = 'Bekor qilingan';
    }

    return Container(
      decoration: BoxDecoration(
        color: isCancelled ? Colors.grey[50] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Card Header
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.08),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
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
                          color: isCancelled ? Colors.grey : Colors.black87,
                          decoration: isCancelled
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Chek: ${payment.receiptNumber}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                          fontFamily: 'Monospace',
                        ),
                      ),
                    ],
                  ),
                ),
                // Status Badge
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
                SizedBox(width: 8),
                // ACTIONS MENU (Yangi qo'shilgan)
                if (!isCancelled)
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert_rounded,
                      color: Colors.grey[700],
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onSelected: (value) {
                      if (value == 'print') {
                        controller._showReceipt(payment.id); // Chek chiqarish
                      } else if (value == 'cancel') {
                        _showCancelDialog(context, payment.id); // Bekor qilish
                      }
                    },
                    itemBuilder: (BuildContext context) => [
                      PopupMenuItem(
                        value: 'print',
                        child: Row(
                          children: [
                            Icon(
                              Icons.print_rounded,
                              color: primaryBlue,
                              size: 20,
                            ),
                            SizedBox(width: 12),
                            Text('Chek chiqarish'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'cancel',
                        child: Row(
                          children: [
                            Icon(
                              Icons.cancel_rounded,
                              color: Colors.red,
                              size: 20,
                            ),
                            SizedBox(width: 12),
                            Text(
                              'To\'lovni bekor qilish',
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          // Card Body
          Padding(
            padding: EdgeInsets.all(20),
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
                    SizedBox(width: 16),
                    Expanded(
                      child: _buildInfoItem(
                        icon: Icons.person_outline_rounded,
                        label: 'Qabul qildi',
                        value: payment.receivedByName ?? '-',
                        color: Colors.purple,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 20),
                Divider(height: 1),
                SizedBox(height: 20),

                // Amount Details
                _buildAmountRow('Asl summa', payment.amount),

                if (payment.discountAmount > 0)
                  _buildAmountRow(
                    'Chegirma',
                    payment.discountAmount,
                    isDiscount: true,
                  ),

                SizedBox(height: 12),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'JAMI TO\'LANGAN:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                      Text(
                        '${_formatCurrency(payment.paidAmount ?? payment.finalAmount)} so\'m',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),

                if (isPartial &&
                    payment.remainingDebt != null &&
                    payment.remainingDebt! > 0) ...[
                  SizedBox(height: 12),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.red,
                          size: 20,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(
                                color: Colors.red[800],
                                fontSize: 14,
                              ),
                              children: [
                                TextSpan(text: 'Qolgan qarz: '),
                                TextSpan(
                                  text:
                                      '${_formatCurrency(payment.remainingDebt!)} so\'m',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                if (payment.notes != null && payment.notes!.isNotEmpty) ...[
                  SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.note_alt_rounded,
                          color: Colors.grey[600],
                          size: 18,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            payment.notes!,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[800],
                              fontStyle: FontStyle.italic,
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

  void _showCancelDialog(BuildContext context, String paymentId) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 400,
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red, size: 64),
              SizedBox(height: 16),
              Text(
                'To\'lovni bekor qilish',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text(
                'Siz haqiqatdan ham bu to\'lovni bekor qilmoqchimisiz? Bu amalni ortga qaytarib bo\'lmaydi va summa kassadan ayiriladi.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[700]),
              ),
              SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text('Yo\'q'),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back(); // Dialogni yopish
                        controller.voidPayment(
                          paymentId,
                        ); // Controllerdagi funksiyani chaqirish
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Ha, Bekor qilish',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
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
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
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
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountRow(
    String label,
    dynamic amount, {
    bool isDiscount = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            '${isDiscount ? '-' : ''}${_formatCurrency(amount)} so\'m',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isDiscount ? Colors.red[700] : Colors.black87,
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
      return DateFormat('dd.MM.yyyy, HH:mm').format(dt);
    } catch (e) {
      return date.toString();
    }
  }

  String _formatCurrency(dynamic amount) {
    if (amount == null) return '0';
    try {
      final formatter = NumberFormat('#,###', 'uz_UZ');
      return formatter.format(
        amount is num ? amount : double.parse(amount.toString()),
      );
    } catch (e) {
      return amount.toString();
    }
  }

  String _getPaymentMethodText(String? method) {
    switch (method) {
      case 'cash':
        return 'Naqd';
      case 'click':
        return 'Click';
      case 'terminal':
        return 'Terminal';
      case 'owner_fund':
        return 'Ega kassasi';
      default:
        return '-';
    }
  }
}
