// lib/presentation/widgets/payment_receipt_dialog_v5.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PaymentReceiptDialog extends StatelessWidget {
  final Map<String, dynamic> paymentData;
  final Map<String, dynamic> studentData;

  const PaymentReceiptDialog({
    Key? key,
    required this.paymentData,
    required this.studentData,
  }) : super(key: key);

  final Color primaryBlue = const Color(0xFF0D47A1);
  final Color accentBlue = const Color(0xFF2196F3);
  final Color white = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 800,
        height: 900,
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(child: _buildReceiptPreview()),
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [primaryBlue, accentBlue]),
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      child: Row(
        children: [
          Icon(Icons.receipt_long_rounded, color: white, size: 32),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('TO\'LOV CHEKI', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: white)),
                Text('Chek raqami: ${paymentData['receipt_number'] ?? '-'}', style: TextStyle(color: white.withOpacity(0.9), fontSize: 14)),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.close_rounded, color: white, size: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptPreview() {
    return Container(
      padding: EdgeInsets.all(32),
      color: Colors.grey[100],
      child: Container(
        decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: Offset(0, 2))],
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [primaryBlue.withOpacity(0.1), accentBlue.withOpacity(0.1)]),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.school_rounded, size: 60, color: accentBlue),
                    ),
                    SizedBox(height: 16),
                    Text(
                      paymentData['branch_name'] ?? 'O\'QUV MARKAZI',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: primaryBlue),
                      textAlign: TextAlign.center,
                    ),
                    if (paymentData['branch_address'] != null) ...[
                      SizedBox(height: 8),
                      Text(paymentData['branch_address'], style: TextStyle(fontSize: 14, color: Colors.grey[600]), textAlign: TextAlign.center),
                    ],
                    if (paymentData['branch_phone'] != null) ...[
                      SizedBox(height: 4),
                      Text('Tel: ${paymentData['branch_phone']}', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                    ],
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [primaryBlue, accentBlue]),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('TO\'LOV CHEKI', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: white)),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 40),
              Divider(thickness: 2, color: accentBlue),
              SizedBox(height: 24),

              _buildInfoRow('Chek raqami:', paymentData['receipt_number'] ?? '-'),
              _buildInfoRow('Sana:', _formatDate(paymentData['payment_date'])),
              
              SizedBox(height: 24),
              Divider(color: Colors.grey[300]),
              SizedBox(height: 24),

              Row(
                children: [
                  Icon(Icons.person, color: accentBlue, size: 24),
                  SizedBox(width: 12),
                  Text('O\'QUVCHI MA\'LUMOTLARI', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryBlue)),
                ],
              ),
              SizedBox(height: 16),
              _buildInfoRow('F.I.Sh:', studentData['full_name'] ?? '-'),
              _buildInfoRow('Sinf:', studentData['class_name'] ?? '-'),
              _buildInfoRow('Telefon:', studentData['parent_phone'] ?? studentData['student_phone'] ?? '-'),

              SizedBox(height: 24),
              Divider(color: Colors.grey[300]),
              SizedBox(height: 24),

              Row(
                children: [
                  Icon(Icons.payment_rounded, color: accentBlue, size: 24),
                  SizedBox(width: 12),
                  Text('TO\'LOV MA\'LUMOTLARI', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryBlue)),
                ],
              ),
              SizedBox(height: 16),
              _buildInfoRow('To\'lov davri:', _getPeriodText()),
              _buildInfoRow('To\'lov turi:', _getPaymentTypeText()),
              
              // Multi-payment agar bo'lsa
              if (paymentData['payment_method'] == 'multi' && paymentData['payment_splits'] != null) ...[
                SizedBox(height: 12),
                Text('To\'lov usullari:', style: TextStyle(fontWeight: FontWeight.bold, color: primaryBlue)),
                SizedBox(height: 8),
                ...(paymentData['payment_splits'] as List).map((split) => Padding(
                  padding: EdgeInsets.only(left: 16, bottom: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('• ${_getPaymentMethodText(split['method'])}'),
                      Text('${_formatCurrency(split['amount'])} so\'m', style: TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                )).toList(),
              ] else
                _buildInfoRow('To\'lov usuli:', _getPaymentMethodText(paymentData['payment_method'])),
              
              SizedBox(height: 24),
              Divider(color: Colors.grey[300]),
              SizedBox(height: 24),

              _buildAmountRow('Oylik to\'lov:', paymentData['amount']),
              
              if ((paymentData['discount_amount'] ?? 0) > 0) ...[
                _buildAmountRow('Chegirma:', paymentData['discount_amount'], isDiscount: true),
                if (paymentData['discount_reason'] != null)
                  Padding(
                    padding: EdgeInsets.only(left: 16, top: 4),
                    child: Text('Sabab: ${paymentData['discount_reason']}', style: TextStyle(fontSize: 12, color: Colors.grey[600], fontStyle: FontStyle.italic)),
                  ),
              ],

              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Colors.green[400]!, Colors.green[600]!]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('JAMI TO\'LANDI:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: white)),
                    Text('${_formatCurrency(paymentData['final_amount'])} so\'m', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: white)),
                  ],
                ),
              ),

              if (paymentData['is_debt'] == true || (paymentData['remaining_debt'] ?? 0) > 0) ...[
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red, width: 2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.warning_amber_rounded, color: Colors.red[700], size: 20),
                              SizedBox(width: 8),
                              Text('QARZ:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red[700])),
                            ],
                          ),
                          Text('${_formatCurrency(paymentData['remaining_debt'])} so\'m', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red[700])),
                        ],
                      ),
                      if (paymentData['debt_reason'] != null) ...[
                        SizedBox(height: 8),
                        Text('Sabab: ${paymentData['debt_reason']}', style: TextStyle(fontSize: 12, color: Colors.red[600], fontStyle: FontStyle.italic)),
                      ],
                    ],
                  ),
                ),
              ],

              if (paymentData['notes'] != null) ...[
                SizedBox(height: 24),
                Divider(color: Colors.grey[300]),
                SizedBox(height: 16),
                Text('Izoh:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[700])),
                SizedBox(height: 8),
                Text(paymentData['notes'], style: TextStyle(fontSize: 13, color: Colors.grey[600])),
              ],

              SizedBox(height: 40),
              Divider(color: Colors.grey[300]),
              SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Qabul qildi:', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                      SizedBox(height: 8),
                      Text(paymentData['received_by_name'] ?? '-', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Imzo:', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                      SizedBox(height: 8),
                      Container(width: 120, height: 1, color: Colors.grey[400]),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 40),

              Center(
                child: Column(
                  children: [
                    Text('Rahmat! Muvaffaqiyatlar tilaymiz!', style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: Colors.grey[600])),
                    SizedBox(height: 8),
                    Text('Bu chek elektron shaklda yaratilgan', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: white,
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _printReceipt(),
              icon: Icon(Icons.print_rounded),
              label: Text('PRINT QILISH'),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(color: accentBlue, width: 2),
                foregroundColor: accentBlue,
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _downloadPDF(),
              icon: Icon(Icons.download_rounded),
              label: Text('PDF YUKLASH'),
              style: ElevatedButton.styleFrom(
                backgroundColor: accentBlue,
                foregroundColor: white,
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[700], fontWeight: FontWeight.w500)),
          ),
          Expanded(child: Text(value, style: TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w600))),
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
          Text(label, style: TextStyle(fontSize: 15, color: Colors.grey[700])),
          Text(
            '${isDiscount ? '-' : ''}${_formatCurrency(amount)} so\'m',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: isDiscount ? Colors.red[600] : Colors.black87),
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

  String _getPeriodText() {
    final month = paymentData['period_month'];
    final year = paymentData['period_year'];
    if (month == null || year == null) return '-';
    
    const months = ['Yanvar', 'Fevral', 'Mart', 'Aprel', 'May', 'Iyun', 'Iyul', 'Avgust', 'Sentabr', 'Oktabr', 'Noyabr', 'Dekabr'];
    return '${months[month - 1]} $year';
  }

  String _getPaymentTypeText() {
    switch (paymentData['payment_type']) {
      case 'tuition': return 'Oylik to\'lov';
      case 'registration': return 'Ro\'yxatga olish';
      case 'exam': return 'Imtihon';
      case 'debt_payment': return 'Qarz to\'lovi';
      default: return 'Boshqa';
    }
  }

  String _getPaymentMethodText(String? method) {
    switch (method) {
      case 'cash': return 'Naqd pul';
      case 'click': return 'Click orqali';
      case 'terminal': return 'Terminal';
      case 'owner_fund': return 'Ega kassasi';
      case 'multi': return 'Ko\'p usulda';
      default: return '-';
    }
  }

  Future<void> _printReceipt() async {
    final pdf = await _generatePDF();
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  Future<void> _downloadPDF() async {
    final pdf = await _generatePDF();
    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'chek_${paymentData['receipt_number']}.pdf',
    );
  }

  Future<pw.Document> _generatePDF() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      paymentData['branch_name'] ?? 'O\'QUV MARKAZI',
                      style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text('TO\'LOV CHEKI', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
              ),
              pw.SizedBox(height: 40),
              pw.Divider(thickness: 2),
              pw.SizedBox(height: 24),
              
              pw.Text('Chek raqami: ${paymentData['receipt_number'] ?? '-'}'),
              pw.Text('Sana: ${_formatDate(paymentData['payment_date'])}'),
              pw.SizedBox(height: 24),
              
              pw.Text('O\'QUVCHI MA\'LUMOTLARI', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 12),
              pw.Text('F.I.Sh: ${studentData['full_name'] ?? '-'}'),
              pw.Text('Sinf: ${studentData['class_name'] ?? '-'}'),
              
              pw.SizedBox(height: 40),
              pw.Text('JAMI TO\'LANDI: ${_formatCurrency(paymentData['final_amount'])} so\'m', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
            ],
          );
        },
      ),
    );

    return pdf;
  }
}