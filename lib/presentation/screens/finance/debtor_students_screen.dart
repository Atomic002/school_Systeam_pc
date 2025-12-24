// lib/presentation/screens/finance/debtor_students_screen.dart
// MUKAMMAL QARZDOR O'QUVCHILAR EKRANI

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../widgets/sidebar.dart';
import '../../controllers/auth_controller.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class DebtorStudentsScreen extends StatefulWidget {
  const DebtorStudentsScreen({Key? key}) : super(key: key);

  @override
  State<DebtorStudentsScreen> createState() => _DebtorStudentsScreenState();
}

class _DebtorStudentsScreenState extends State<DebtorStudentsScreen> {
  final AuthController authController = Get.find<AuthController>();
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> debtorStudents = [];
  Map<String, List<Map<String, dynamic>>> studentDebts = {};
  Map<String, List<Map<String, dynamic>>> studentPayments = {};
  String? expandedStudentId;

  bool isLoading = true;
  double totalDebt = 0;
  int totalDebtors = 0;

  String searchQuery = '';
  String sortBy = 'amount';

  @override
  void initState() {
    super.initState();
    _loadDebtors();
    _setupRealtimeListeners();
  }

  void _setupRealtimeListeners() {
    final branchId = authController.currentUser.value?.branchId;
    if (branchId == null) return;

    supabase.channel('debtor_changes').onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'student_debts',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'branch_id',
        value: branchId,
      ),
      callback: (payload) {
        print('📡 Debts changed: ${payload.eventType}');
        _loadDebtors();
      },
    ).subscribe();

    supabase.channel('payment_changes').onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'payments',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'branch_id',
        value: branchId,
      ),
      callback: (payload) {
        print('📡 Payments changed: ${payload.eventType}');
        if (expandedStudentId != null) {
          _loadStudentPayments(expandedStudentId!);
        }
      },
    ).subscribe();
  }

  @override
  void dispose() {
    supabase.removeAllChannels();
    super.dispose();
  }

  Future<void> _loadDebtors() async {
    setState(() => isLoading = true);

    try {
      final branchId = authController.currentUser.value?.branchId;
      if (branchId == null) return;

      print('🔄 Loading debtors for branch: $branchId');

      final response = await supabase.from('student_debts').select('''
            id,
            student_id,
            debt_amount,
            paid_amount,
            remaining_amount,
            period_month,
            period_year,
            due_date,
            created_at,
            students:student_id (
              id,
              first_name,
              last_name,
              phone,
              parent_phone,
              class_name,
              balance
            )
          ''').eq('branch_id', branchId).eq('is_settled', false).order('remaining_amount', ascending: false);

      final Map<String, Map<String, dynamic>> studentsMap = {};

      for (var debt in response) {
        final studentId = debt['student_id'] as String;
        final student = debt['students'] as Map<String, dynamic>;

        if (!studentsMap.containsKey(studentId)) {
          studentsMap[studentId] = {
            'student': student,
            'total_debt': 0.0,
            'debts': <Map<String, dynamic>>[],
          };
        }

        studentsMap[studentId]!['total_debt'] += (debt['remaining_amount'] as num).toDouble();
        studentsMap[studentId]!['debts'].add(debt);
      }

      setState(() {
        debtorStudents = studentsMap.entries.map((entry) {
          return <String, dynamic>{
            'student_id': entry.key,
            ...entry.value['student'] as Map<String, dynamic>,
            'total_debt': entry.value['total_debt'],
            'debts_count': (entry.value['debts'] as List).length,
          };
        }).toList();

        studentDebts = studentsMap.map((key, value) => MapEntry(key, List<Map<String, dynamic>>.from(value['debts'])));

        totalDebt = debtorStudents.fold(0, (sum, student) => sum + (student['total_debt'] as double));
        totalDebtors = debtorStudents.length;

        _sortStudents();
      });

      print('✅ Loaded ${totalDebtors} debtor students, total debt: $totalDebt');
    } catch (e) {
      print('❌ Load debtors error: $e');
      Get.snackbar('Xatolik', 'Qarzdorlarni yuklashda xatolik');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _loadStudentPayments(String studentId) async {
    try {
      final response = await supabase.from('payments').select('*').eq('student_id', studentId).order('payment_date', ascending: false).limit(50);

      setState(() {
        studentPayments[studentId] = List<Map<String, dynamic>>.from(response);
      });

      print('✅ Loaded ${response.length} payments for student $studentId');
    } catch (e) {
      print('❌ Load student payments error: $e');
    }
  }

  void _sortStudents() {
    switch (sortBy) {
      case 'amount':
        debtorStudents.sort((a, b) => (b['total_debt'] as double).compareTo(a['total_debt'] as double));
        break;
      case 'name':
        debtorStudents.sort((a, b) => '${a['last_name']} ${a['first_name']}'.compareTo('${b['last_name']} ${b['first_name']}'));
        break;
      case 'date':
        break;
    }
  }

  List<Map<String, dynamic>> get filteredStudents {
    if (searchQuery.isEmpty) return debtorStudents;

    return debtorStudents.where((student) {
      final fullName = '${student['first_name']} ${student['last_name']}'.toLowerCase();
      final phone = (student['phone'] ?? '').toLowerCase();
      final parentPhone = (student['parent_phone'] ?? '').toLowerCase();
      final query = searchQuery.toLowerCase();

      return fullName.contains(query) || phone.contains(query) || parentPhone.contains(query);
    }).toList();
  }

  Future<void> _exportToPDF() async {
    try {
      final pdf = pw.Document();
      final now = DateTime.now();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (context) => [
            pw.Header(
              level: 0,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('QARZDOR O\'QUVCHILAR HISOBOTI', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 5),
                  pw.Text('Sana: ${DateFormat('dd.MM.yyyy HH:mm').format(now)}'),
                  pw.Divider(),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Text('UMUMIY STATISTIKA', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Table.fromTextArray(
              headers: ['Ko\'rsatkich', 'Qiymat'],
              data: [
                ['Jami qarzdorlar', '$totalDebtors ta'],
                ['Jami qarz', '${_formatCurrency(totalDebt)} so\'m'],
                ['O\'rtacha qarz', totalDebtors > 0 ? '${_formatCurrency(totalDebt / totalDebtors)} so\'m' : '0 so\'m'],
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Text('QARZDORLAR RO\'YXATI', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Table.fromTextArray(
              headers: ['№', 'F.I.SH', 'Telefon', 'Qarz', 'Qarzlar soni'],
              data: filteredStudents.asMap().entries.map((entry) {
                final index = entry.key;
                final student = entry.value;
                return [
                  '${index + 1}',
                  '${student['first_name']} ${student['last_name']}',
                  student['parent_phone'] ?? student['phone'] ?? '-',
                  '${_formatCurrency(student['total_debt'])} so\'m',
                  '${student['debts_count']} ta',
                ];
              }).toList(),
            ),
          ],
        ),
      );

      await Printing.layoutPdf(onLayout: (format) async => pdf.save());
      Get.snackbar('Muvaffaqiyatli', 'PDF hisobot yaratildi');
    } catch (e) {
      print('❌ Export to PDF error: $e');
      Get.snackbar('Xatolik', 'PDF yaratishda xatolik: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      body: Row(
        children: [
          Sidebar(),
          Expanded(
            child: Column(
              children: [
                _buildHeader(),
                _buildStatCards(),
                _buildFilters(),
                Expanded(
                  child: isLoading ? Center(child: CircularProgressIndicator()) : _buildDebtorsList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFFF44336), Color(0xFFE53935)]),
        boxShadow: [BoxShadow(color: Color(0xFFF44336).withOpacity(0.3), blurRadius: 20, offset: Offset(0, 10))],
      ),
      child: Row(
        children: [
          IconButton(icon: Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Get.back()),
          SizedBox(width: 16),
          Icon(Icons.warning_amber_rounded, size: 32, color: Colors.white),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Qarzdor O\'quvchilar', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                Text('To\'lov qilmagan o\'quvchilar ro\'yxati', style: TextStyle(fontSize: 14, color: Colors.white70)),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: _exportToPDF,
            icon: Icon(Icons.picture_as_pdf, size: 20),
            label: Text('PDF'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Color(0xFFF44336)),
          ),
          SizedBox(width: 8),
          IconButton(onPressed: _loadDebtors, icon: Icon(Icons.refresh, color: Colors.white), tooltip: 'Yangilash'),
        ],
      ),
    );
  }

  Widget _buildStatCards() {
    return Container(
      padding: EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(child: _buildStatCard('Jami Qarzdorlar', '$totalDebtors ta', Icons.people_outline, Color(0xFFF44336))),
          SizedBox(width: 16),
          Expanded(child: _buildStatCard('Jami Qarz', '${_formatCurrency(totalDebt)} so\'m', Icons.money_off_rounded, Color(0xFFE53935))),
          SizedBox(width: 16),
          Expanded(child: _buildStatCard('O\'rtacha Qarz', totalDebtors > 0 ? '${_formatCurrency(totalDebt / totalDebtors)} so\'m' : '0 so\'m', Icons.analytics_outlined, Color(0xFFD32F2F))),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(gradient: LinearGradient(colors: [color, color.withOpacity(0.8)]), borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 15, offset: Offset(0, 8))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(padding: EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: Colors.white, size: 28)),
          SizedBox(height: 16),
          Text(title, style: TextStyle(fontSize: 13, color: Colors.white70, fontWeight: FontWeight.w500)),
          SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(hintText: 'Ism, telefon orqali qidirish...', prefixIcon: Icon(Icons.search), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: Colors.grey[100]),
              onChanged: (value) => setState(() => searchQuery = value),
            ),
          ),
          SizedBox(width: 16),
          DropdownButton<String>(
            value: sortBy,
            items: [
              DropdownMenuItem(value: 'amount', child: Text('Qarz miqdori')),
              DropdownMenuItem(value: 'name', child: Text('Ism bo\'yicha')),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  sortBy = value;
                  _sortStudents();
                });
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDebtorsList() {
    final students = filteredStudents;

    if (students.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 80, color: Colors.green),
            SizedBox(height: 16),
            Text('Qarzdor o\'quvchilar yo\'q!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey[700])),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(24),
      itemCount: students.length,
      itemBuilder: (context, index) => _buildStudentCard(students[index]),
    );
  }

  Widget _buildStudentCard(Map<String, dynamic> student) {
    final studentId = student['student_id'] as String;
    final isExpanded = expandedStudentId == studentId;
    final debts = studentDebts[studentId] ?? [];
    final payments = studentPayments[studentId] ?? [];

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Column(
        children: [
          InkWell(
            onTap: () async {
              if (!isExpanded) {
                await _loadStudentPayments(studentId);
              }
              setState(() {
                expandedStudentId = isExpanded ? null : studentId;
              });
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(gradient: LinearGradient(colors: [Color(0xFFF44336), Color(0xFFE53935)]), shape: BoxShape.circle),
                    child: Center(child: Text('${student['first_name'][0]}${student['last_name'][0]}', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${student['first_name']} ${student['last_name']}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.school, size: 14, color: Colors.grey[600]),
                            SizedBox(width: 4),
                            Text(student['class_name'] ?? 'Sinf biriktirilmagan', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                            SizedBox(width: 16),
                            Icon(Icons.phone, size: 14, color: Colors.grey[600]),
                            SizedBox(width: 4),
                            Text(student['parent_phone'] ?? student['phone'] ?? '-', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                          ],
                        ),
                        SizedBox(height: 4),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: Color(0xFFF44336).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                          child: Text('${student['debts_count']} ta qarz', style: TextStyle(fontSize: 11, color: Color(0xFFF44336), fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('${_formatCurrency(student['total_debt'])} so\'m', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFF44336))),
                      SizedBox(height: 4),
                      ElevatedButton.icon(
                        onPressed: () => _makePayment(student),
                        icon: Icon(Icons.payment, size: 16),
                        label: Text('To\'lov'),
                        style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF4CAF50), padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
                      ),
                    ],
                  ),
                  SizedBox(width: 16),
                  Icon(isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: Colors.grey[600]),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            Divider(height: 1),
            _buildExpandedContent(debts, payments),
          ],
        ],
      ),
    );
  }

  Widget _buildExpandedContent(List<Map<String, dynamic>> debts, List<Map<String, dynamic>> payments) {
    return Container(
      padding: EdgeInsets.all(20),
      color: Color(0xFFF44336).withOpacity(0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Qarzlar tafsiloti', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFF44336))),
          SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: debts.length,
            separatorBuilder: (_, __) => SizedBox(height: 12),
            itemBuilder: (context, index) => _buildDebtItem(debts[index]),
          ),
          if (payments.isNotEmpty) ...[
            SizedBox(height: 24),
            Text('To\'lovlar tarixi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF4CAF50))),
            SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: payments.length,
              separatorBuilder: (_, __) => SizedBox(height: 8),
              itemBuilder: (context, index) => _buildPaymentItem(payments[index]),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDebtItem(Map<String, dynamic> debt) {
    final month = debt['period_month'];
    final year = debt['period_year'];
    final monthNames = ['Yanvar', 'Fevral', 'Mart', 'Aprel', 'May', 'Iyun', 'Iyul', 'Avgust', 'Sentabr', 'Oktabr', 'Noyabr', 'Dekabr'];

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Color(0xFFF44336).withOpacity(0.3))),
      child: Row(
        children: [
          Container(padding: EdgeInsets.all(12), decoration: BoxDecoration(color: Color(0xFFF44336).withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(Icons.calendar_month, color: Color(0xFFF44336))),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(month != null && year != null ? '${monthNames[month - 1]} $year' : 'Davr ko\'rsatilmagan', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                SizedBox(height: 4),
                Row(
                  children: [
                    Text('To\'langan: ${_formatCurrency(debt['paid_amount'])}', style: TextStyle(fontSize: 12, color: Colors.green)),
                    SizedBox(width: 12),
                    Text('Jami: ${_formatCurrency(debt['debt_amount'])}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${_formatCurrency(debt['remaining_amount'])} so\'m', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFF44336))),
              if (debt['due_date'] != null) ...[SizedBox(height: 4), Text('Muddat: ${_formatDate(debt['due_date'])}', style: TextStyle(fontSize: 11, color: Colors.grey[600]))],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentItem(Map<String, dynamic> payment) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.green[200]!)),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_formatDate(payment['payment_date']), style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                Text(_getPaymentMethodName(payment['payment_method']), style: TextStyle(fontSize: 11, color: Colors.grey[600])),
              ],
            ),
          ),
          Text('${_formatCurrency(payment['final_amount'])} so\'m', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green[700])),
        ],
      ),
    );
  }

  void _makePayment(Map<String, dynamic> student) {
    Get.toNamed('/student-detail', arguments: {'studentId': student['student_id']});
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

  String _formatDate(dynamic date) {
    if (date == null) return '-';
    try {
      final dt = date is DateTime ? date : DateTime.parse(date.toString());
      return DateFormat('dd.MM.yyyy').format(dt);
    } catch (e) {
      return date.toString();
    }
  }

  String _getPaymentMethodName(String method) => {'cash': 'Naqd', 'click': 'Click', 'card': 'Karta', 'bank': 'Bank'}[method] ?? method;
}