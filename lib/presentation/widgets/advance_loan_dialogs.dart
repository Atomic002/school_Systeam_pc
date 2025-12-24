// lib/presentation/widgets/advance_loan_dialogs.dart
// AVANS VA QARZ BERISH DIALOGLARI

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ==================== AVANS BERISH DIALOG ====================

class AdvanceDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onSubmit;

  const AdvanceDialog({Key? key, required this.onSubmit}) : super(key: key);

  @override
  State<AdvanceDialog> createState() => _AdvanceDialogState();
}

class _AdvanceDialogState extends State<AdvanceDialog> {
  final _formKey = GlobalKey<FormState>();
  final amountController = TextEditingController();
  final reasonController = TextEditingController();
  
  String? selectedStaffId;
  int deductionMonth = DateTime.now().month;
  int deductionYear = DateTime.now().year;
  String? selectedCashRegister;
  
  List<Map<String, dynamic>> staffList = [];
  List<Map<String, dynamic>> cashRegisters = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    
    try {
      final staffResponse = await Supabase.instance.client
          .from('staff')
          .select('id, first_name, last_name, position, base_salary')
          .eq('status', 'active')
          .order('last_name');
      
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
      Get.snackbar('Xato', 'Ma\'lumotlarni yuklashda xatolik');
    }
  }

  Future<void> _submitAdvance() async {
    if (!_formKey.currentState!.validate()) return;
    if (selectedCashRegister == null) {
      Get.snackbar('Xato', 'Kassani tanlang');
      return;
    }

    final amount = double.parse(amountController.text);
    final cashRegister = cashRegisters.firstWhere((c) => c['id'] == selectedCashRegister);
    
    if (cashRegister['current_balance'] < amount) {
      Get.snackbar('Xato', 'Kassada yetarli mablag\' yo\'q');
      return;
    }

    final userId = Supabase.instance.client.auth.currentUser?.id;
    final userInfo = await Supabase.instance.client
        .from('users')
        .select('branch_id')
        .eq('id', userId!)
        .single();

    final advanceData = {
      'branch_id': userInfo['branch_id'],
      'staff_id': selectedStaffId,
      'amount': amount,
      'deduction_month': deductionMonth,
      'deduction_year': deductionYear,
      'reason': reasonController.text.isEmpty ? null : reasonController.text,
      'advance_date': DateTime.now().toIso8601String(),
      'given_by': userId,
    };

    widget.onSubmit(advanceData);
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 600,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            if (isLoading)
              Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(),
              )
            else
              Padding(
                padding: EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStaffSelection(),
                      SizedBox(height: 16),
                      _buildAmountField(),
                      SizedBox(height: 16),
                      _buildDeductionPeriod(),
                      SizedBox(height: 16),
                      _buildCashRegisterSelection(),
                      SizedBox(height: 16),
                      _buildReasonField(),
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
          colors: [Colors.orange[600]!, Colors.orange[400]!],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          Icon(Icons.money_off, color: Colors.white, size: 32),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Avans berish',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Xodimga oylik maoshidan avans bering',
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
    return DropdownButtonFormField<String>(
      value: selectedStaffId,
      decoration: InputDecoration(
        labelText: 'Xodim',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: Icon(Icons.person),
      ),
      items: staffList.map((staff) {
        return DropdownMenuItem<String>(
          value: staff['id'],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${staff['first_name']} ${staff['last_name']}'),
              Text(
                '${staff['position']} • Maosh: ${NumberFormat('#,###').format(staff['base_salary'] ?? 0)} so\'m',
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) => setState(() => selectedStaffId = value),
      validator: (value) => value == null ? 'Xodimni tanlang' : null,
    );
  }

  Widget _buildAmountField() {
    return TextFormField(
      controller: amountController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: 'Avans summasi (so\'m)',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: Icon(Icons.attach_money),
        hintText: '0',
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Summani kiriting';
        if (double.tryParse(value) == null) return 'Noto\'g\'ri format';
        if (double.parse(value) <= 0) return 'Summa 0 dan katta bo\'lishi kerak';
        return null;
      },
    );
  }

  Widget _buildDeductionPeriod() {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<int>(
            value: deductionMonth,
            decoration: InputDecoration(
              labelText: 'Ushlab qolinadigan oy',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
            onChanged: (value) => setState(() => deductionMonth = value!),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: DropdownButtonFormField<int>(
            value: deductionYear,
            decoration: InputDecoration(
              labelText: 'Yil',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            items: List.generate(3, (index) {
              final year = DateTime.now().year + index;
              return DropdownMenuItem<int>(
                value: year,
                child: Text(year.toString()),
              );
            }).toList(),
            onChanged: (value) => setState(() => deductionYear = value!),
          ),
        ),
      ],
    );
  }

  Widget _buildCashRegisterSelection() {
    return DropdownButtonFormField<String>(
    value: selectedCashRegister,
    isExpanded: true, // <--- MANA SHUNI QO'SHING
    decoration: InputDecoration(
      labelText: 'Kassa',
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      prefixIcon: Icon(Icons.account_balance_wallet),
    ),
      items: cashRegisters.map((cash) {
        final amount = double.tryParse(amountController.text) ?? 0;
        final balance = cash['current_balance'];
        final hasEnough = balance >= amount;
        
        return DropdownMenuItem<String>(
          value: cash['id'],
          child: Row(
            children: [
              Expanded(
                child: Text('${cash['payment_method']} - ${cash['branches']?['name']}'),
              ),
              Text(
                '${NumberFormat('#,###').format(balance)} so\'m',
                style: TextStyle(
                  fontSize: 12,
                  color: hasEnough ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) => setState(() => selectedCashRegister = value),
      validator: (value) => value == null ? 'Kassani tanlang' : null,
    );
  }

  Widget _buildReasonField() {
    return TextFormField(
      controller: reasonController,
      maxLines: 3,
      decoration: InputDecoration(
        labelText: 'Sabab (ixtiyoriy)',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        hintText: 'Avans berishning sababini yozing...',
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
            onPressed: _submitAdvance,
            icon: Icon(Icons.check),
            label: Text('Berish'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              backgroundColor: Colors.orange,
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== QARZ BERISH DIALOG ====================

class LoanDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onSubmit;

  const LoanDialog({Key? key, required this.onSubmit}) : super(key: key);

  @override
  State<LoanDialog> createState() => _LoanDialogState();
}

class _LoanDialogState extends State<LoanDialog> {
  final _formKey = GlobalKey<FormState>();
  final amountController = TextEditingController();
  final installmentsController = TextEditingController(text: '6');
  final purposeController = TextEditingController();
  
  String? selectedStaffId;
  String? selectedCashRegister;
  int startMonth = DateTime.now().month;
  int startYear = DateTime.now().year;
  
  double monthlyPayment = 0;
  List<Map<String, dynamic>> staffList = [];
  List<Map<String, dynamic>> cashRegisters = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    amountController.addListener(_calculateMonthly);
    installmentsController.addListener(_calculateMonthly);
  }

  void _calculateMonthly() {
    final amount = double.tryParse(amountController.text) ?? 0;
    final installments = int.tryParse(installmentsController.text) ?? 1;
    
    if (amount > 0 && installments > 0) {
      setState(() {
        monthlyPayment = amount / installments;
      });
    }
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    
    try {
      final staffResponse = await Supabase.instance.client
          .from('staff')
          .select('id, first_name, last_name, position, base_salary')
          .eq('status', 'active')
          .order('last_name');
      
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
      Get.snackbar('Xato', 'Ma\'lumotlarni yuklashda xatolik');
    }
  }

  Future<void> _submitLoan() async {
    if (!_formKey.currentState!.validate()) return;
    if (selectedCashRegister == null) {
      Get.snackbar('Xato', 'Kassani tanlang');
      return;
    }

    final amount = double.parse(amountController.text);
    final cashRegister = cashRegisters.firstWhere((c) => c['id'] == selectedCashRegister);
    
    if (cashRegister['current_balance'] < amount) {
      Get.snackbar('Xato', 'Kassada yetarli mablag\' yo\'q');
      return;
    }

    final userId = Supabase.instance.client.auth.currentUser?.id;
    final userInfo = await Supabase.instance.client
        .from('users')
        .select('branch_id')
        .eq('id', userId!)
        .single();

    int.parse(installmentsController.text);
    
    final loanData = {
      'branch_id': userInfo['branch_id'],
      'staff_id': selectedStaffId,
      'total_amount': amount,
      'remaining_amount': amount,
      'monthly_deduction': monthlyPayment,
      'start_month': startMonth,
      'start_year': startYear,
      'reason': purposeController.text.isEmpty ? null : purposeController.text,
      'loan_date': DateTime.now().toIso8601String(),
      'given_by': userId,
    };

    widget.onSubmit(loanData);
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 700,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            if (isLoading)
              Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(),
              )
            else
              SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStaffSelection(),
                        SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(child: _buildAmountField()),
                            SizedBox(width: 16),
                            Expanded(child: _buildInstallmentsField()),
                          ],
                        ),
                        SizedBox(height: 16),
                        _buildPaymentInfo(),
                        SizedBox(height: 16),
                        _buildStartPeriod(),
                        SizedBox(height: 16),
                        _buildCashRegisterSelection(),
                        SizedBox(height: 16),
                        _buildPurposeField(),
                      ],
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
          colors: [Colors.red[600]!, Colors.red[400]!],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          Icon(Icons.account_balance, color: Colors.white, size: 32),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Qarz berish',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Xodimga bo\'lib-bo\'lib qaytariladigan qarz bering',
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
    return DropdownButtonFormField<String>(
      value: selectedStaffId,
      decoration: InputDecoration(
        labelText: 'Xodim',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: Icon(Icons.person),
      ),
      items: staffList.map((staff) {
        return DropdownMenuItem<String>(
          value: staff['id'],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${staff['first_name']} ${staff['last_name']}'),
              Text(
                '${staff['position']} • Maosh: ${NumberFormat('#,###').format(staff['base_salary'] ?? 0)} so\'m',
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) => setState(() => selectedStaffId = value),
      validator: (value) => value == null ? 'Xodimni tanlang' : null,
    );
  }

  Widget _buildAmountField() {
    return TextFormField(
      controller: amountController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: 'Qarz summasi',
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

  Widget _buildInstallmentsField() {
    return TextFormField(
      controller: installmentsController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: 'Oylar soni',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: Icon(Icons.calendar_month),
        suffixText: 'oy',
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Oylar sonini kiriting';
        final months = int.tryParse(value);
        if (months == null || months <= 0) return 'Noto\'g\'ri qiymat';
        if (months > 36) return 'Maksimal 36 oy';
        return null;
      },
    );
  }

  Widget _buildPaymentInfo() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.red[700]),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Oylik to\'lov',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),
                Text(
                  '${NumberFormat('#,###').format(monthlyPayment)} so\'m',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.red[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartPeriod() {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<int>(
            value: startMonth,
            decoration: InputDecoration(
              labelText: 'Boshlash oyi',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
            onChanged: (value) => setState(() => startMonth = value!),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: DropdownButtonFormField<int>(
            value: startYear,
            decoration: InputDecoration(
              labelText: 'Yil',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            items: List.generate(3, (index) {
              final year = DateTime.now().year + index;
              return DropdownMenuItem<int>(
                value: year,
                child: Text(year.toString()),
              );
            }).toList(),
            onChanged: (value) => setState(() => startYear = value!),
          ),
        ),
      ],
    );
  }

  Widget _buildCashRegisterSelection() {
    return DropdownButtonFormField<String>(
      value: selectedCashRegister,
      decoration: InputDecoration(
        labelText: 'Kassa',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: Icon(Icons.account_balance_wallet),
      ),
      items: cashRegisters.map((cash) {
        final amount = double.tryParse(amountController.text) ?? 0;
        final balance = cash['current_balance'];
        final hasEnough = balance >= amount;
        
        return DropdownMenuItem<String>(
          value: cash['id'],
          child: Row(
            children: [
              Expanded(
                child: Text('${cash['payment_method']} - ${cash['branches']?['name']}'),
              ),
              Text(
                '${NumberFormat('#,###').format(balance)} so\'m',
                style: TextStyle(
                  fontSize: 12,
                  color: hasEnough ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) => setState(() => selectedCashRegister = value),
      validator: (value) => value == null ? 'Kassani tanlang' : null,
    );
  }

  Widget _buildPurposeField() {
    return TextFormField(
      controller: purposeController,
      maxLines: 3,
      decoration: InputDecoration(
        labelText: 'Maqsad (ixtiyoriy)',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        hintText: 'Qarz olish maqsadini yozing...',
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
            onPressed: _submitLoan,
            icon: Icon(Icons.check),
            label: Text('Berish'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              backgroundColor: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}