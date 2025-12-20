// lib/presentation/widgets/salary_calculation_dialog.dart
// MUKAMMAL MAOSH HISOBLASH VA TO'LASH DIALOG

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SalaryCalculationDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onCalculate;

  const SalaryCalculationDialog({Key? key, required this.onCalculate}) : super(key: key);

  @override
  State<SalaryCalculationDialog> createState() => _SalaryCalculationDialogState();
}

class _SalaryCalculationDialogState extends State<SalaryCalculationDialog> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final bonusAmountController = TextEditingController();
  final bonusReasonController = TextEditingController();
  final penaltyAmountController = TextEditingController();
  final penaltyReasonController = TextEditingController();
  final notesController = TextEditingController();
  
  // Variables
  String? selectedStaffId;
  Map<String, dynamic>? selectedStaff;
  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;
  String? selectedCashRegister;
  
  // Calculation results
  double baseAmount = 0;
  double workedDays = 0;
  double workedHours = 0;
  double grossAmount = 0;
  double bonusAmount = 0;
  double penaltyAmount = 0;
  double advanceTotal = 0;
  double loanTotal = 0;
  double netAmount = 0;
  
  List<Map<String, dynamic>> staffList = [];
  List<Map<String, dynamic>> cashRegisters = [];
  List<Map<String, dynamic>> attendanceRecords = [];
  List<Map<String, dynamic>> advances = [];
  List<Map<String, dynamic>> loans = [];
  
  bool isLoading = false;
  bool isCalculated = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => isLoading = true);
    
    try {
      // Load staff
      final staffResponse = await Supabase.instance.client
          .from('staff')
          .select('id, first_name, last_name, position, salary_type, base_salary, hourly_rate, daily_rate, expected_hours_per_month')
          .eq('status', 'active')
          .order('last_name');
      
      // Load cash registers
      final cashResponse = await Supabase.instance.client
          .from('cash_register')
          .select('id, payment_method, current_balance, branches(name)')
          .order('payment_method');
      
      setState(() {
        staffList = List<Map<String, dynamic>>.from(staffResponse);
        cashRegisters = List<Map<String, dynamic>>.from(cashResponse);
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      Get.snackbar('Xato', 'Ma\'lumotlarni yuklashda xatolik: $e');
    }
  }

  Future<void> _calculateSalary() async {
    if (selectedStaffId == null) {
      Get.snackbar('Xato', 'Xodimni tanlang');
      return;
    }

    setState(() => isLoading = true);

    try {
      // Get staff details
      selectedStaff = staffList.firstWhere((s) => s['id'] == selectedStaffId);
      
      final startDate = DateTime(selectedYear, selectedMonth, 1);
      final endDate = DateTime(selectedYear, selectedMonth + 1, 0);
      
      // Load attendance
      final attendanceResponse = await Supabase.instance.client
          .from('staff_attendance')
          .select('*')
          .eq('staff_id', selectedStaffId as Object)
          .gte('attendance_date', startDate.toIso8601String())
          .lte('attendance_date', endDate.toIso8601String());
      
      attendanceRecords = List<Map<String, dynamic>>.from(attendanceResponse);
      
      // Load advances
      final advancesResponse = await Supabase.instance.client
          .from('staff_advances')
          .select('amount')
          .eq('staff_id', selectedStaffId as Object)
          .eq('deduction_month', selectedMonth)
          .eq('deduction_year', selectedYear)
          .eq('is_deducted', false);
      
      advances = List<Map<String, dynamic>>.from(advancesResponse);
      
      // Load active loans
      final loansResponse = await Supabase.instance.client
          .from('staff_loans')
          .select('monthly_deduction')
          .eq('staff_id', selectedStaffId as Object)
          .eq('is_settled', false);
      
      loans = List<Map<String, dynamic>>.from(loansResponse);
      
      // Calculate based on salary type
      final salaryType = selectedStaff!['salary_type'];
      baseAmount = (selectedStaff!['base_salary'] ?? 0.0).toDouble();
      
      if (salaryType == 'monthly') {
        // Oylik - davomat asosida hisoblash
        workedDays = attendanceRecords
            .where((a) => a['status'] == 'present' || a['status'] == 'late')
            .length
            .toDouble();
        
        // Oyning ish kunlari (dam olish kunlarini hisobga olmagan holda)
        final totalWorkDays = _getWorkingDaysInMonth(selectedYear, selectedMonth);
        
        // Agar barcha kunlar ishlamagan bo'lsa, proporsional hisoblash
        if (workedDays < totalWorkDays) {
          grossAmount = baseAmount * (workedDays / totalWorkDays);
        } else {
          grossAmount = baseAmount;
        }
        
      } else if (salaryType == 'hourly') {
        // Soatlik
        workedHours = 0;
        
        for (var record in attendanceRecords) {
          if (record['check_in_time'] != null && record['check_out_time'] != null) {
            final checkIn = _parseTime(record['check_in_time']);
            final checkOut = _parseTime(record['check_out_time']);
            
            if (checkIn != null && checkOut != null) {
              final hours = (checkOut.hour - checkIn.hour) + 
                           (checkOut.minute - checkIn.minute) / 60.0;
              workedHours += hours.abs();
            }
          }
        }
        
        final hourlyRate = (selectedStaff!['hourly_rate'] ?? 0.0).toDouble();
        grossAmount = workedHours * hourlyRate;
        
      } else if (salaryType == 'daily') {
        // Kunlik
        workedDays = attendanceRecords
            .where((a) => a['status'] == 'present')
            .length
            .toDouble();
        
        final dailyRate = (selectedStaff!['daily_rate'] ?? 0.0).toDouble();
        grossAmount = workedDays * dailyRate;
      }
      
      // Calculate deductions
      advanceTotal = advances.fold(0.0, (sum, item) => sum + (item['amount'] ?? 0.0));
      loanTotal = loans.fold(0.0, (sum, item) => sum + (item['monthly_deduction'] ?? 0.0));
      
      // Bonus and penalty
      bonusAmount = double.tryParse(bonusAmountController.text) ?? 0.0;
      penaltyAmount = double.tryParse(penaltyAmountController.text) ?? 0.0;
      
      // Net amount
      netAmount = grossAmount + bonusAmount - penaltyAmount - advanceTotal - loanTotal;
      
      setState(() {
        isCalculated = true;
        isLoading = false;
      });
      
    } catch (e) {
      setState(() => isLoading = false);
      Get.snackbar('Xato', 'Maosh hisoblashda xatolik: $e');
    }
  }

  int _getWorkingDaysInMonth(int year, int month) {
    final firstDay = DateTime(year, month, 1);
    final lastDay = DateTime(year, month + 1, 0);
    
    int workingDays = 0;
    for (var day = firstDay; day.isBefore(lastDay) || day.isAtSameMomentAs(lastDay); 
         day = day.add(Duration(days: 1))) {
      // Shanba va yakshanba kunlarini hisobga olmaymiz
      if (day.weekday != DateTime.saturday && day.weekday != DateTime.sunday) {
        workingDays++;
      }
    }
    return workingDays;
  }

  TimeOfDay? _parseTime(String timeStr) {
    try {
      final parts = timeStr.split(':');
      return TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    } catch (e) {
      return null;
    }
  }

  Future<void> _paySalary() async {
    if (!_formKey.currentState!.validate()) return;
    if (selectedCashRegister == null) {
      Get.snackbar('Xato', 'Kassani tanlang');
      return;
    }

    setState(() => isLoading = true);

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      
      // Check cash register balance
      final cashRegister = cashRegisters.firstWhere((c) => c['id'] == selectedCashRegister);
      
      if (cashRegister['current_balance'] < netAmount) {
        Get.snackbar('Xato', 'Kassada yetarli mablag\' yo\'q');
        setState(() => isLoading = false);
        return;
      }
      
      // Create salary operation
      final salaryData = {
        'branch_id': selectedStaff!['branch_id'],
        'staff_id': selectedStaffId,
        'operation_type': 'salary',
        'period_month': selectedMonth,
        'period_year': selectedYear,
        'base_amount': baseAmount,
        'worked_days': workedDays.toInt(),
        'worked_hours': workedHours,
        'actual_worked_hours': workedHours,
        'bonus_amount': bonusAmount,
        'bonus_reason': bonusReasonController.text.isEmpty ? null : bonusReasonController.text,
        'penalty_amount': penaltyAmount,
        'penalty_reason': penaltyReasonController.text.isEmpty ? null : penaltyReasonController.text,
        'advance_deduction': advanceTotal,
        'loan_deduction': loanTotal,
        'gross_amount': grossAmount,
        'net_amount': netAmount,
        'is_paid': true,
        'paid_at': DateTime.now().toIso8601String(),
        'notes': notesController.text.isEmpty ? null : notesController.text,
        'calculated_by': userId,
        'paid_by': userId,
      };
      
      widget.onCalculate(salaryData);
      
      Get.back();
      Get.snackbar(
        'Muvaffaqiyat',
        'Maosh muvaffaqiyatli hisoblandi va to\'landi',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      
    } catch (e) {
      Get.snackbar('Xato', 'Maosh to\'lashda xatolik: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 900,
        height: 700,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildStaffSelection(),
                              SizedBox(height: 20),
                              _buildPeriodSelection(),
                              SizedBox(height: 20),
                              if (isCalculated) ...[
                                _buildCalculationResults(),
                                SizedBox(height: 20),
                                _buildAdjustments(),
                                SizedBox(height: 20),
                                _buildCashRegisterSelection(),
                                SizedBox(height: 20),
                                _buildNotes(),
                              ],
                            ],
                          ),
                        ),
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
          colors: [Colors.green[600]!, Colors.green[400]!],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          Icon(Icons.payments, color: Colors.white, size: 32),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Maosh hisoblash va to\'lash',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Xodim maoshini hisoblang va to\'lang',
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

  Widget _buildStaffSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Xodimni tanlang',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: selectedStaffId,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: Icon(Icons.person),
            hintText: 'Xodimni tanlang',
          ),
          items: staffList.map((staff) {
            return DropdownMenuItem<String>(
              value: staff['id'],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${staff['first_name']} ${staff['last_name']}',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '${staff['position']} • ${staff['salary_type']}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedStaffId = value;
              isCalculated = false;
            });
          },
          validator: (value) => value == null ? 'Xodimni tanlang' : null,
        ),
      ],
    );
  }

  Widget _buildPeriodSelection() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Oy',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8),
              DropdownButtonFormField<int>(
                value: selectedMonth,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: Icon(Icons.calendar_month),
                ),
                items: List.generate(12, (index) {
                  final month = index + 1;
                  final monthNames = [
                    'Yanvar', 'Fevral', 'Mart', 'Aprel', 'May', 'Iyun',
                    'Iyul', 'Avgust', 'Sentabr', 'Oktabr', 'Noyabr', 'Dekabr'
                  ];
                  return DropdownMenuItem<int>(
                    value: month,
                    child: Text('$month - ${monthNames[index]}'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedMonth = value!;
                    isCalculated = false;
                  });
                },
              ),
            ],
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Yil',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8),
              DropdownButtonFormField<int>(
                value: selectedYear,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                items: List.generate(5, (index) {
                  final year = DateTime.now().year - index;
                  return DropdownMenuItem<int>(
                    value: year,
                    child: Text(year.toString()),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedYear = value!;
                    isCalculated = false;
                  });
                },
              ),
            ],
          ),
        ),
        SizedBox(width: 16),
        Padding(
          padding: EdgeInsets.only(top: 32),
          child: ElevatedButton.icon(
            onPressed: _calculateSalary,
            icon: Icon(Icons.calculate),
            label: Text('Hisoblash'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              backgroundColor: Colors.blue,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCalculationResults() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hisoblash natijalari',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green[900],
            ),
          ),
          SizedBox(height: 16),
          _buildResultRow('Asosiy maosh', baseAmount, Colors.blue),
          if (selectedStaff!['salary_type'] == 'monthly')
            _buildResultRow('Ishlangan kunlar', workedDays, Colors.grey, isDay: true),
          if (selectedStaff!['salary_type'] == 'hourly')
            _buildResultRow('Ishlangan soatlar', workedHours, Colors.grey, isHour: true),
          if (selectedStaff!['salary_type'] == 'daily')
            _buildResultRow('Ishlangan kunlar', workedDays, Colors.grey, isDay: true),
          Divider(height: 24),
          _buildResultRow('Yalpi maosh', grossAmount, Colors.green),
          if (advanceTotal > 0)
            _buildResultRow('Avanslar (-)', advanceTotal, Colors.orange, isNegative: true),
          if (loanTotal > 0)
            _buildResultRow('Qarz to\'lovi (-)', loanTotal, Colors.red, isNegative: true),
          Divider(height: 24, thickness: 2),
          _buildResultRow('SOF MAOSH', netAmount, Colors.green[900]!, isBold: true, isLarge: true),
        ],
      ),
    );
  }

  Widget _buildResultRow(
    String label,
    double value,
    Color color, {
    bool isNegative = false,
    bool isBold = false,
    bool isLarge = false,
    bool isDay = false,
    bool isHour = false,
  }) {
    String valueText;
    if (isDay) {
      valueText = '${value.toInt()} kun';
    } else if (isHour) {
      valueText = '${value.toStringAsFixed(1)} soat';
    } else {
      valueText = '${isNegative ? '-' : ''}${NumberFormat('#,###').format(value)} so\'m';
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isLarge ? 18 : 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: Colors.grey[700],
            ),
          ),
          Text(
            valueText,
            style: TextStyle(
              fontSize: isLarge ? 24 : 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdjustments() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Qo\'shimcha va jarima',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: bonusAmountController,
                keyboardType: TextInputType.number,
                onChanged: (value) => _recalculate(),
                decoration: InputDecoration(
                  labelText: 'Bonus (so\'m)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: Icon(Icons.add_circle, color: Colors.green),
                ),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: TextField(
                controller: bonusReasonController,
                decoration: InputDecoration(
                  labelText: 'Bonus sababi',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: penaltyAmountController,
                keyboardType: TextInputType.number,
                onChanged: (value) => _recalculate(),
                decoration: InputDecoration(
                  labelText: 'Jarima (so\'m)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: Icon(Icons.remove_circle, color: Colors.red),
                ),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: TextField(
                controller: penaltyReasonController,
                decoration: InputDecoration(
                  labelText: 'Jarima sababi',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _recalculate() {
    bonusAmount = double.tryParse(bonusAmountController.text) ?? 0.0;
    penaltyAmount = double.tryParse(penaltyAmountController.text) ?? 0.0;
    netAmount = grossAmount + bonusAmount - penaltyAmount - advanceTotal - loanTotal;
    setState(() {});
  }

  Widget _buildCashRegisterSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kassa tanlash',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: selectedCashRegister,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: Icon(Icons.account_balance_wallet),
            hintText: 'Kassani tanlang',
          ),
          items: cashRegisters.map((cash) {
            final method = cash['payment_method'];
            final balance = cash['current_balance'];
            final branch = cash['branches']?['name'] ?? '';
            
            return DropdownMenuItem<String>(
              value: cash['id'],
              child: Row(
                children: [
                  Icon(
                    method == 'cash' ? Icons.payments :
                    method == 'card' ? Icons.credit_card : Icons.account_balance,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text('$method - $branch'),
                  ),
                  Text(
                    '${NumberFormat('#,###').format(balance)} so\'m',
                    style: TextStyle(
                      fontSize: 12,
                      color: balance >= netAmount ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) => setState(() => selectedCashRegister = value),
          validator: (value) => value == null ? 'Kassani tanlang' : null,
        ),
      ],
    );
  }

  Widget _buildNotes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Izoh (ixtiyoriy)',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 8),
        TextField(
          controller: notesController,
          maxLines: 3,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            hintText: 'Qo\'shimcha izoh yozing...',
          ),
        ),
      ],
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
            onPressed: isCalculated ? _paySalary : null,
            icon: Icon(Icons.payment),
            label: Text('To\'lash'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              backgroundColor: Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}