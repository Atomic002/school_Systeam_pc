// lib/presentation/controllers/student_detail_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

import '../../data/repositories/student_repositry.dart';
import '../../data/repositories/payment_repositry.dart';
import '../../data/repositories/attendance_repository.dart'
    hide PaymentRepository;
import '../../data/models/student_model.dart';

class StudentDetailController extends GetxController {
  final StudentRepository _studentRepo = StudentRepository();
  final PaymentRepository _paymentRepo = PaymentRepository();
  final AttendanceRepository _attendanceRepo = AttendanceRepository();
  final EnrollmentRepository _enrollmentRepo = EnrollmentRepository();
  final ScheduleRepository _scheduleRepo = ScheduleRepository();

  // Observable variables
  final Rx<StudentModel?> student = Rx<StudentModel?>(null);
  final RxBool isLoading = true.obs;
  final RxBool isLoadingPayments = false.obs;
  final RxBool isLoadingAttendance = false.obs;
  final RxBool isLoadingSchedule = false.obs;
  final RxBool isEditing = false.obs;

  // To'lovlar
  final RxList<dynamic> paymentHistory = [].obs;
  final RxDouble totalDebt = 0.0.obs;
  final RxDouble totalPaid = 0.0.obs;
  final RxDouble monthlyFee = 0.0.obs;
  final RxString selectedPaymentFilter = 'all'.obs; // all, paid, pending

  // Davomat
  final RxList<dynamic> attendanceRecords = [].obs;
  final RxInt presentCount = 0.obs;
  final RxInt absentCount = 0.obs;
  final RxInt lateCount = 0.obs;
  final RxInt excusedCount = 0.obs;
  final RxDouble attendancePercentage = 0.0.obs;
  final RxString selectedAttendanceFilter = 'all'.obs; // all, week, month

  // O'quv ma'lumotlari
  final Rx<dynamic> currentEnrollment = Rx<dynamic>(null);
  final Rx<String?> currentClassName = Rx<String?>(null);
  final Rx<String?> classTeacherName = Rx<String?>(null);
  final Rx<String?> classRoomName = Rx<String?>(null);
  final RxInt studyDuration = 0.obs;

  // Dars jadvali
  final RxList<Map<String, dynamic>> weeklySchedule =
      <Map<String, dynamic>>[].obs;

  // Edit form controllers
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final middleNameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final parentPhoneController = TextEditingController();
  final monthlyFeeController = TextEditingController();
  final discountPercentController = TextEditingController();

  String? studentId;

  @override
  void onInit() {
    super.onInit();
    studentId = Get.arguments as String?;
    if (studentId != null) {
      loadAllData();
    } else {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    middleNameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    parentPhoneController.dispose();
    monthlyFeeController.dispose();
    discountPercentController.dispose();
    super.onClose();
  }

  // ==================== BARCHA MA'LUMOTLARNI YUKLASH ====================
  Future<void> loadAllData() async {
    try {
      isLoading.value = true;

      final studentData = await _studentRepo.getStudentById(studentId!);
      if (studentData == null) {
        student.value = null;
        Get.snackbar(
          'Xatolik',
          'O\'quvchi topilmadi',
          backgroundColor: Colors.red.shade100,
          snackPosition: SnackPosition.TOP,
        );
        return;
      }

      student.value = studentData;
      monthlyFee.value = studentData.finalMonthlyFee!;

      // O'qish muddatini hisoblash
      if (studentData.enrollmentDate != null) {
        final duration = DateTime.now().difference(studentData.enrollmentDate!);
        studyDuration.value = (duration.inDays / 365).floor();
      }

      // Edit form'ni to'ldirish
      _populateEditForm(studentData);

      // Parallel ravishda boshqa ma'lumotlarni yuklash
      await Future.wait([
        loadEnrollmentInfo(),
        loadPaymentHistory(),
        loadAttendanceHistory(),
        loadSchedule(),
      ]);
    } catch (e) {
      print('Load all data error: $e');
      Get.snackbar(
        'Xatolik',
        'Ma\'lumotlarni yuklashda xatolik yuz berdi',
        backgroundColor: Colors.red.shade100,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _populateEditForm(StudentModel student) {
    firstNameController.text = student.firstName;
    lastNameController.text = student.lastName;
    middleNameController.text = student.middleName ?? '';
    phoneController.text = student.phone ?? '';
    addressController.text = student.address!;
    parentPhoneController.text = student.parentPhone;
    monthlyFeeController.text = student.monthlyFee.toString();
    discountPercentController.text = student.discountPercent.toString();
  }

  // ==================== ENROLLMENT MA'LUMOTLARI ====================
  Future<void> loadEnrollmentInfo() async {
    try {
      final enrollment = await _enrollmentRepo.getCurrentEnrollment(studentId!);
      if (enrollment != null) {
        currentEnrollment.value = enrollment;
        currentClassName.value = enrollment['class_name'] as String?;
        classTeacherName.value = enrollment['teacher_name'] as String?;
        classRoomName.value = enrollment['room_name'] as String?;
      }
    } catch (e) {
      print('Load enrollment error: $e');
    }
  }

  // ==================== TO'LOVLAR TARIXI ====================
  Future<void> loadPaymentHistory() async {
    if (studentId == null) return;

    try {
      isLoadingPayments.value = true;

      final payments = await _paymentRepo.getStudentPaymentHistory(studentId!);
      paymentHistory.value = payments;

      // Umumiy to'langan summa
      double paid = 0;
      for (final payment in payments) {
        if (payment.paymentStatus == 'paid') {
          paid += payment.finalAmount;
        }
      }
      totalPaid.value = paid;

      // Qarzdorlikni hisoblash
      final debts = await _paymentRepo.getStudentDebts(studentId!);
      double debt = 0;
      for (final d in debts) {
        debt += d['remaining_amount'] as double;
      }
      totalDebt.value = debt;
    } catch (e) {
      print('Load payment history error: $e');
    } finally {
      isLoadingPayments.value = false;
    }
  }

  void filterPayments(String filter) {
    selectedPaymentFilter.value = filter;
  }

  List<dynamic> get filteredPayments {
    if (selectedPaymentFilter.value == 'all') {
      return paymentHistory;
    } else if (selectedPaymentFilter.value == 'paid') {
      return paymentHistory.where((p) => p.paymentStatus == 'paid').toList();
    } else {
      return paymentHistory.where((p) => p.paymentStatus == 'pending').toList();
    }
  }

  // ==================== DAVOMAT TARIXI ====================
  Future<void> loadAttendanceHistory() async {
    if (studentId == null) return;

    try {
      isLoadingAttendance.value = true;

      final records = await _attendanceRepo.getStudentAttendance(studentId!);
      attendanceRecords.value = records;

      _calculateAttendanceStats(records);
    } catch (e) {
      print('Load attendance history error: $e');
    } finally {
      isLoadingAttendance.value = false;
    }
  }

  void _calculateAttendanceStats(List<dynamic> records) {
    int present = 0, absent = 0, late = 0, excused = 0;

    for (final record in records) {
      switch (record.status) {
        case 'present':
          present++;
          break;
        case 'absent':
          absent++;
          break;
        case 'late':
          late++;
          break;
        case 'excused':
          excused++;
          break;
      }
    }

    presentCount.value = present;
    absentCount.value = absent;
    lateCount.value = late;
    excusedCount.value = excused;

    final total = present + absent + late + excused;
    if (total > 0) {
      attendancePercentage.value = (present / total) * 100;
    } else {
      attendancePercentage.value = 0;
    }
  }

  void filterAttendance(String filter) {
    selectedAttendanceFilter.value = filter;
  }

  List<dynamic> get filteredAttendance {
    if (selectedAttendanceFilter.value == 'all') {
      return attendanceRecords;
    } else if (selectedAttendanceFilter.value == 'week') {
      final weekAgo = DateTime.now().subtract(const Duration(days: 7));
      return attendanceRecords
          .where((r) => r.attendanceDate.isAfter(weekAgo))
          .toList();
    } else {
      final monthAgo = DateTime.now().subtract(const Duration(days: 30));
      return attendanceRecords
          .where((r) => r.attendanceDate.isAfter(monthAgo))
          .toList();
    }
  }

  // ==================== DARS JADVALI ====================
  Future<void> loadSchedule() async {
    if (currentEnrollment.value == null) return;

    try {
      isLoadingSchedule.value = true;

      final classId = currentEnrollment.value['class_id'] as String?;
      if (classId == null) return;

      final schedule = await _scheduleRepo.getClassSchedule(classId);
      weeklySchedule.value = schedule;
    } catch (e) {
      print('Load schedule error: $e');
    } finally {
      isLoadingSchedule.value = false;
    }
  }

  // ==================== TAHRIRLASH ====================
  void toggleEditMode() {
    isEditing.value = !isEditing.value;
    if (!isEditing.value && student.value != null) {
      _populateEditForm(student.value!);
    }
  }

  Future<void> saveChanges() async {
    try {
      // Validatsiya
      if (firstNameController.text.trim().isEmpty ||
          lastNameController.text.trim().isEmpty) {
        Get.snackbar(
          'Xatolik',
          'Ism va familiya majburiy',
          backgroundColor: Colors.red.shade100,
          snackPosition: SnackPosition.TOP,
        );
        return;
      }

      // Ma'lumotlarni yangilash
      await _studentRepo.updateStudent(
        studentId: studentId!,
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        middleName: middleNameController.text.trim(),
        phone: phoneController.text.trim(),
        address: addressController.text.trim(),
        parentPhone: parentPhoneController.text.trim(),
        monthlyFee: double.tryParse(monthlyFeeController.text) ?? 0,
        discountPercent: double.tryParse(discountPercentController.text) ?? 0,
        photoUrl: '',
      );

      Get.snackbar(
        'Muvaffaqiyatli',
        'O\'quvchi ma\'lumotlari yangilandi',
        backgroundColor: const Color(0xFF2196F3).withOpacity(0.1),
        colorText: const Color(0xFF2196F3),
        icon: const Icon(Icons.check_circle, color: Color(0xFF2196F3)),
        snackPosition: SnackPosition.TOP,
      );

      isEditing.value = false;
      await loadAllData();
    } catch (e) {
      Get.snackbar(
        'Xatolik',
        'Ma\'lumotlarni yangilashda xatolik',
        backgroundColor: Colors.red.shade100,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  // ==================== TO'LOV QABUL QILISH ====================
  Future<void> makePayment() async {
    final amountController = TextEditingController();
    final noteController = TextEditingController();

    final result = await Get.dialog<bool>(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.payment, size: 48, color: Colors.white),
              ),
              const SizedBox(height: 24),
              const Text(
                'To\'lov qabul qilish',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: amountController,
                decoration: InputDecoration(
                  labelText: 'Summa (so\'m)',
                  prefixIcon: const Icon(
                    Icons.attach_money,
                    color: Color(0xFF2196F3),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: noteController,
                decoration: InputDecoration(
                  labelText: 'Izoh (ixtiyoriy)',
                  prefixIcon: const Icon(Icons.note, color: Color(0xFF2196F3)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(result: false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Color(0xFF2196F3)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Bekor qilish'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final amount = double.tryParse(amountController.text);
                        if (amount == null || amount <= 0) {
                          Get.snackbar(
                            'Xatolik',
                            'To\'g\'ri summa kiriting',
                            backgroundColor: Colors.red.shade100,
                          );
                          return;
                        }
                        Get.back(result: true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2196F3),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('To\'lov qilish'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (result == true) {
      // To'lovni saqlash logikasi
      await loadPaymentHistory();
      Get.snackbar(
        'Muvaffaqiyatli',
        'To\'lov qabul qilindi',
        backgroundColor: const Color(0xFF4CAF50).withOpacity(0.1),
        colorText: const Color(0xFF4CAF50),
        icon: const Icon(Icons.check_circle, color: Color(0xFF4CAF50)),
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  // ==================== PDF EXPORT ====================
  Future<void> exportToPDF() async {
    final pdf = pw.Document();
    final student = this.student.value!;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          // Sarlavha
          pw.Container(
            padding: const pw.EdgeInsets.all(20),
            decoration: pw.BoxDecoration(
              color: PdfColors.blue50,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'O\'QUVCHI PROFILI',
                  style: pw.TextStyle(
                    fontSize: 28,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue900,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Sana: ${DateFormat('dd.MM.yyyy').format(DateTime.now())}',
                  style: const pw.TextStyle(
                    fontSize: 12,
                    color: PdfColors.grey700,
                  ),
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 20),

          // Shaxsiy ma'lumotlar
          _buildPdfSection('SHAXSIY MA\'LUMOTLAR', [
            _buildPdfRow('F.I.Sh', student.fullName),
            _buildPdfRow(
              'Jinsi',
              student.gender == 'male' ? 'O\'g\'il' : 'Qiz',
            ),
            _buildPdfRow('Tug\'ilgan sana', _formatDate(student.birthDate)),
            _buildPdfRow('Yoshi', '${student.age} yosh'),
            _buildPdfRow('Telefon', student.phone ?? '—'),
            _buildPdfRow('Manzil', student.address ?? '—'),
          ]),

          pw.SizedBox(height: 20),

          // Ota-ona ma'lumotlari
          _buildPdfSection('OTA-ONA MA\'LUMOTLARI', [
            _buildPdfRow('F.I.Sh', student.parentFullName),
            _buildPdfRow('Aloqasi', student.parentRelation ?? '—'),
            _buildPdfRow('Telefon', student.parentPhone),
            _buildPdfRow('Ish joyi', student.parentWorkplace ?? '—'),
          ]),

          pw.SizedBox(height: 20),

          // Moliyaviy ma'lumotlar
          _buildPdfSection('MOLIYAVIY MA\'LUMOTLAR', [
            _buildPdfRow(
              'Oylik to\'lov',
              '${_formatCurrency(student.monthlyFee)} so\'m',
            ),
            if (student.discountPercent > 0)
              _buildPdfRow(
                'Chegirma',
                '${student.discountPercent}% (${_formatCurrency(student.discountAmount)} so\'m)',
              ),
            _buildPdfRow(
              'Yakuniy to\'lov',
              '${_formatCurrency(student.finalMonthlyFee!)} so\'m',
            ),
            _buildPdfRow(
              'Umumiy qarzdorlik',
              '${_formatCurrency(totalDebt.value)} so\'m',
            ),
            _buildPdfRow(
              'To\'langan',
              '${_formatCurrency(totalPaid.value)} so\'m',
            ),
          ]),

          pw.SizedBox(height: 20),

          // Davomat statistikasi
          _buildPdfSection('DAVOMAT STATISTIKASI', [
            _buildPdfRow('Keldi', '${presentCount.value} kun'),
            _buildPdfRow('Kelmadi', '${absentCount.value} kun'),
            _buildPdfRow('Kechikdi', '${lateCount.value} kun'),
            _buildPdfRow(
              'Davomat foizi',
              '${attendancePercentage.value.toStringAsFixed(1)}%',
            ),
          ]),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  pw.Widget _buildPdfSection(String title, List<pw.Widget> children) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue900,
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Divider(color: PdfColors.grey300),
          pw.SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  pw.Widget _buildPdfRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 150,
            child: pw.Text(
              label,
              style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== HELPER ====================
  String _formatDate(DateTime? date) {
    if (date == null) return '—';
    return DateFormat('dd.MM.yyyy').format(date);
  }

  String _formatCurrency(double amount) {
    return amount
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
  }

  Future<void> refreshData() async {
    await loadAllData();
  }
}
