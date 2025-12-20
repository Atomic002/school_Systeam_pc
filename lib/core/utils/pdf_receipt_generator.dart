// lib/utils/pdf_receipt_generator.dart
// ================================================================================
// PDF CHEK GENERATOR
// ================================================================================

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class PdfReceiptGenerator {
  static Future<void> generateAndDownload({
    required Map<String, dynamic> paymentData,
    required Map<String, dynamic> studentData,
    required String staffName,
    required DateTime paymentDateTime,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(paymentData, paymentDateTime),
              pw.SizedBox(height: 30),
              
              pw.Divider(thickness: 2),
              pw.SizedBox(height: 20),
              
              // O'quvchi ma'lumotlari
              _buildSection('O\'QUVCHI MA\'LUMOTLARI', [
                _buildRow('F.I.O', studentData['fullName']),
                _buildRow('Sinf', studentData['class']),
                _buildRow('Xona', studentData['room']),
                _buildRow('Sinf rahbari', studentData['teacher']),
              ]),
              
              pw.SizedBox(height: 20),
              pw.Divider(),
              pw.SizedBox(height: 20),
              
              // To'lov ma'lumotlari
              _buildSection('TO\'LOV MA\'LUMOTLARI', [
                _buildRow('To\'lov turi', paymentData['type']),
                _buildRow('To\'lov usuli', paymentData['method']),
                _buildRow('Asosiy summa', '${paymentData['amount']} so\'m'),
                if (paymentData['discountAmount'] > 0)
                  _buildRow('Chegirma', '${paymentData['discountAmount']} so\'m',
                      valueColor: PdfColors.red),
                if (paymentData['discountReason'] != null)
                  _buildRow('Chegirma sababi', paymentData['discountReason']),
              ]),
              
              pw.SizedBox(height: 20),
              pw.Divider(),
              pw.SizedBox(height: 20),
              
              // Qarz ma'lumotlari (agar bo'lsa)
              if (paymentData['isPartial'] == true) ...[
                _buildSection('QARZ MA\'LUMOTLARI', [
                  _buildRow('To\'langan', '${paymentData['paidAmount']} so\'m',
                      valueColor: PdfColors.blue),
                  _buildRow('Qarz', '${paymentData['debtAmount']} so\'m',
                      valueColor: PdfColors.red),
                  if (paymentData['debtReason'] != null)
                    _buildRow('Qarz sababi', paymentData['debtReason']),
                ]),
                pw.SizedBox(height: 20),
                pw.Divider(),
                pw.SizedBox(height: 20),
              ],
              
              // Yakuniy summa
              pw.Container(
                padding: pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: PdfColors.green50,
                  border: pw.Border.all(color: PdfColors.green, width: 2),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'JAMI TO\'LANGAN:',
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      '${paymentData['finalAmount']} so\'m',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.green900,
                      ),
                    ),
                  ],
                ),
              ),
              
              pw.Spacer(),
              
              // Footer
              pw.Divider(),
              pw.SizedBox(height: 10),
              _buildFooter(staffName, paymentDateTime),
              
              // Imzo
              pw.SizedBox(height: 40),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  _buildSignature('Qabul qildi', staffName),
                  _buildSignature('Topshirdi', studentData['parentName'] ?? ''),
                ],
              ),
            ],
          );
        },
      ),
    );

    // PDF ni yuklab olish
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'chek_${paymentData['receiptNumber']}.pdf',
    );
  }

  static pw.Widget _buildHeader(Map<String, dynamic> paymentData, DateTime dateTime) {
    return pw.Container(
      padding: pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'TO\'LOV CHEKI',
                    style: pw.TextStyle(
                      fontSize: 28,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue900,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    paymentData['branchName'] ?? 'O\'quv markazi',
                    style: pw.TextStyle(fontSize: 14, color: PdfColors.blue700),
                  ),
                ],
              ),
              pw.Container(
                padding: pw.EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: pw.BoxDecoration(
                  color: PdfColors.white,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'Chek №',
                      style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                    ),
                    pw.Text(
                      paymentData['receiptNumber'] ?? 'N/A',
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 12),
          pw.Row(
            children: [
              pw.Icon(pw.IconData(0xe192), size: 16, color: PdfColors.blue700),
              pw.SizedBox(width: 8),
              pw.Text(
                'Sana: ${DateFormat('dd.MM.yyyy').format(dateTime)}',
                style: pw.TextStyle(fontSize: 12),
              ),
              pw.SizedBox(width: 20),
              pw.Icon(pw.IconData(0xe192), size: 16, color: PdfColors.blue700),
              pw.SizedBox(width: 8),
              pw.Text(
                'Vaqt: ${DateFormat('HH:mm:ss').format(dateTime)}',
                style: pw.TextStyle(fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSection(String title, List<pw.Widget> rows) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.grey800,
          ),
        ),
        pw.SizedBox(height: 12),
        pw.Container(
          padding: pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            color: PdfColors.grey50,
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Column(
            children: rows,
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildRow(String label, String value,
      {PdfColor? valueColor}) {
    return pw.Padding(
      padding: pw.EdgeInsets.symmetric(vertical: 6),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 12,
              color: PdfColors.grey700,
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: valueColor ?? PdfColors.black,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter(String staffName, DateTime dateTime) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          children: [
            pw.Text(
              'Qabul qildi: ',
              style: pw.TextStyle(fontSize: 11, color: PdfColors.grey700),
            ),
            pw.Text(
              staffName,
              style: pw.TextStyle(
                fontSize: 11,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue900,
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          'Chop etildi: ${DateFormat('dd.MM.yyyy HH:mm:ss').format(DateTime.now())}',
          style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          'Bu chek elektron tarzda yaratilgan va imzo talab qilmaydi.',
          style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600, fontStyle: pw.FontStyle.italic),
        ),
      ],
    );
  }

  static pw.Widget _buildSignature(String label, String name) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
        ),
        pw.SizedBox(height: 8),
        pw.Container(
          width: 200,
          decoration: pw.BoxDecoration(
            border: pw.Border(
              bottom: pw.BorderSide(width: 1, color: PdfColors.grey400),
            ),
          ),
          child: pw.Text(
            name,
            style: pw.TextStyle(fontSize: 11),
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          'Imzo',
          style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
        ),
      ],
    );
  }
}

// ============================================================================
// CONTROLLER ICHIDA ISHLATISH
// ============================================================================

// NewPaymentController ichida _downloadReceipt metodini yangilang:
/*
Future<void> _downloadReceipt(Map<String, dynamic> result) async {
  try {
    Get.snackbar(
      'PDF yaratilmoqda',
      'Iltimos kuting...',
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      duration: Duration(seconds: 2),
    );

    final student = selectedStudent.value!;
    
    await PdfReceiptGenerator.generateAndDownload(
      paymentData: {
        'receiptNumber': result['receipt_number'],
        'type': paymentType.value == 'tuition' ? 'Oylik to\'lov' : 
                paymentType.value == 'registration' ? 'Ro\'yxatga olish' :
                paymentType.value == 'exam' ? 'Imtihon' : 'Boshqa',
        'method': paymentMethod.value == 'cash' ? 'Naqd' :
                  paymentMethod.value == 'click' ? 'Click' :
                  paymentMethod.value == 'terminal' ? 'Terminal' : 'Ega kassasi',
        'amount': formatCurrency(double.tryParse(amountController.text) ?? 0),
        'discountAmount': hasDiscount.value 
            ? formatCurrency(double.tryParse(discountController.text) ?? 0)
            : 0,
        'discountReason': discountReasonController.text.isNotEmpty 
            ? discountReasonController.text : null,
        'isPartial': isPartialPayment.value,
        'paidAmount': isPartialPayment.value 
            ? formatCurrency(double.tryParse(paidAmountController.text) ?? 0)
            : null,
        'debtAmount': isPartialPayment.value 
            ? formatCurrency(debtAmount.value)
            : null,
        'debtReason': isPartialPayment.value && debtReasonController.text.isNotEmpty
            ? debtReasonController.text
            : null,
        'finalAmount': formatCurrency(finalAmount.value),
        'branchName': availableBranches.firstWhere(
          (b) => b['id'] == selectedBranchId.value,
          orElse: () => {'name': 'Filial'},
        )['name'],
      },
      studentData: {
        'fullName': student.fullName,
        'class': student.classFullName,
        'room': student.roomInfo,
        'teacher': student.teacherInfo,
        'parentName': student.parentFullName,
      },
      staffName: currentStaffName.value,
      paymentDateTime: paymentDateTime.value,
    );

    Get.back(); // Dialog yopish
    clearSelection();
    
    Get.snackbar(
      'Muvaffaqiyatli',
      'PDF chek yuklab olindi',
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  } catch (e) {
    print('❌ PDF generation error: $e');
    Get.snackbar(
      'Xato',
      'PDF yaratishda xatolik: $e',
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }
}
*/