// lib/presentation/widgets/cash_transfer_dialog.dart
// KASSADAN KASSAGA O'TKAZISH (KOMISSIYA BILAN)

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class CashTransferDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onSubmit;
  final List<Map<String, dynamic>> cashRegisters;

  const CashTransferDialog({
    Key? key,
    required this.onSubmit,
    required this.cashRegisters,
  }) : super(key: key);

  @override
  State<CashTransferDialog> createState() => _CashTransferDialogState();
}

class _CashTransferDialogState extends State<CashTransferDialog> {
  final _formKey = GlobalKey<FormState>();
  final amountController = TextEditingController();
  final commissionController = TextEditingController(text: '0');
  final descriptionController = TextEditingController();

  String? fromCashRegister;
  String? toCashRegister;
  double totalAmount = 0;

  @override
  void initState() {
    super.initState();
    amountController.addListener(_calculateTotal);
    commissionController.addListener(_calculateTotal);
  }

  void _calculateTotal() {
    final amount = double.tryParse(amountController.text) ?? 0;
    final commission = double.tryParse(commissionController.text) ?? 0;
    setState(() {
      totalAmount = amount + commission;
    });
  }

  void _submitTransfer() {
    if (!_formKey.currentState!.validate()) return;
    if (fromCashRegister == null || toCashRegister == null) {
      Get.snackbar('Xato', 'Kassalarni tanlang');
      return;
    }

    if (fromCashRegister == toCashRegister) {
      Get.snackbar('Xato', 'Bir xil kassani tanlab bo\'lmaydi');
      return;
    }

    final fromCash = widget.cashRegisters.firstWhere(
      (c) => c['id'] == fromCashRegister,
    );
    
    final amount = double.parse(amountController.text);
    final commission = double.parse(commissionController.text);
    
    if (fromCash['current_balance'] < totalAmount) {
      Get.snackbar('Xato', 'Kassada yetarli mablag\' yo\'q');
      return;
    }

    widget.onSubmit({
      'from_method': fromCash['payment_method'],
      'to_method': widget.cashRegisters
          .firstWhere((c) => c['id'] == toCashRegister)['payment_method'],
      'amount': amount,
      'commission': commission,
      'description': descriptionController.text,
    });

    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 700,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            Padding(
              padding: EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: _buildFromCashSelector()),
                        SizedBox(width: 16),
                        Icon(
                          Icons.arrow_forward,
                          color: Colors.blue,
                          size: 32,
                        ),
                        SizedBox(width: 16),
                        Expanded(child: _buildToCashSelector()),
                      ],
                    ),
                    SizedBox(height: 24),
                    _buildAmountField(),
                    SizedBox(height: 16),
                    _buildCommissionField(),
                    SizedBox(height: 16),
                    _buildTotalInfo(),
                    SizedBox(height: 16),
                    _buildDescriptionField(),
                  ],
                ),
              ),
            ),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2196F3), Color(0xFF1565C0)],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          Icon(Icons.swap_horiz, color: Colors.white, size: 32),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kassadan Kassaga O\'tkazish',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Bir kassadan boshqa kassaga pul o\'tkazing',
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Get.back(),
            icon: Icon(Icons.close, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildFromCashSelector() {
    return DropdownButtonFormField<String>(
      value: fromCashRegister,
      decoration: InputDecoration(
        labelText: 'Qayerdan',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: Icon(Icons.account_balance_wallet, color: Colors.red),
      ),
      items: widget.cashRegisters.map((cash) {
        final balance = cash['current_balance'];
        return DropdownMenuItem<String>(
          value: cash['id'],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_getPaymentMethodName(cash['payment_method'])),
              Text(
                'Qoldiq: ${NumberFormat('#,###').format(balance)} so\'m',
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) => setState(() => fromCashRegister = value),
      validator: (value) => value == null ? 'Kassani tanlang' : null,
    );
  }

  Widget _buildToCashSelector() {
    return DropdownButtonFormField<String>(
      value: toCashRegister,
      decoration: InputDecoration(
        labelText: 'Qayerga',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: Icon(Icons.account_balance_wallet, color: Colors.green),
      ),
      items: widget.cashRegisters.map((cash) {
        final balance = cash['current_balance'];
        return DropdownMenuItem<String>(
          value: cash['id'],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_getPaymentMethodName(cash['payment_method'])),
              Text(
                'Qoldiq: ${NumberFormat('#,###').format(balance)} so\'m',
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) => setState(() => toCashRegister = value),
      validator: (value) => value == null ? 'Kassani tanlang' : null,
    );
  }

  Widget _buildAmountField() {
    return TextFormField(
      controller: amountController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: 'O\'tkaziladigan summa',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: Icon(Icons.attach_money),
        suffixText: 'so\'m',
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Summani kiriting';
        if (double.tryParse(value) == null) return 'Noto\'g\'ri format';
        if (double.parse(value) <= 0) return 'Summa 0 dan katta bo\'lishi kerak';
        return null;
      },
    );
  }

  Widget _buildCommissionField() {
    return TextFormField(
      controller: commissionController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: 'Komissiya (xarajat)',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: Icon(Icons.percent, color: Colors.orange),
        suffixText: 'so\'m',
        helperText: 'Bank yoki Click komissiyasi',
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return null;
        if (double.tryParse(value) == null) return 'Noto\'g\'ri format';
        if (double.parse(value) < 0) return 'Manfiy bo\'lmasligi kerak';
        return null;
      },
    );
  }

  Widget _buildTotalInfo() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2196F3), Color(0xFF1565C0)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF2196F3).withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'O\'tkaziladigan:',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              Text(
                '${NumberFormat('#,###').format(double.tryParse(amountController.text) ?? 0)} so\'m',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Komissiya:',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              Text(
                '${NumberFormat('#,###').format(double.tryParse(commissionController.text) ?? 0)} so\'m',
                style: TextStyle(
                  color: Colors.orangeAccent,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Divider(color: Colors.white30, height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'JAMI:',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${NumberFormat('#,###').format(totalAmount)} so\'m',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          if (fromCashRegister != null) ...[
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.white, size: 20),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Kassadan ${NumberFormat('#,###').format(totalAmount)} so\'m chiqariladi',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: descriptionController,
      maxLines: 3,
      decoration: InputDecoration(
        labelText: 'Izoh',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        hintText: 'O\'tkazma sababi...',
      ),
    );
  }

  Widget _buildActions() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          OutlinedButton(
            onPressed: () => Get.back(),
            child: Text('Bekor qilish'),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
          SizedBox(width: 16),
          ElevatedButton.icon(
            onPressed: _submitTransfer,
            icon: Icon(Icons.check),
            label: Text('O\'tkazish'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              backgroundColor: Color(0xFF2196F3),
            ),
          ),
        ],
      ),
    );
  }

  String _getPaymentMethodName(String method) {
    switch (method) {
      case 'cash':
        return 'Naqd kassa';
      case 'click':
        return 'Click hamyon';
      case 'card':
        return 'Karta';
      case 'bank':
        return 'Bank';
      case 'owner_cash':
        return 'Ega kassasi';
      default:
        return method;
    }
  }
}