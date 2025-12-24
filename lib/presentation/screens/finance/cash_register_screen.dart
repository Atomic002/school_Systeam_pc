import 'package:flutter/material.dart';
import 'package:flutter_application_1/presentation/controllers/auth_controller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../widgets/sidebar.dart';
import '../../controllers/cash_register_controller.dart';
import '../../../config/constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// --- MUHIM: Qarzdorlar oynasini import qilish ---
import 'debtor_students_screen.dart';

class AdvancedCashRegisterScreen extends StatelessWidget {
  AdvancedCashRegisterScreen({Key? key}) : super(key: key);

  final controller = Get.put(CashRegisterController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Sidebar(),
          Expanded(
            child: Container(
              color: AppConstants.backgroundLight,
              child: Column(
                children: [
                  _buildAppBar(),
                  Expanded(
                    child: Obx(
                      () => controller.isLoading.value
                          ? Center(child: CircularProgressIndicator())
                          : _buildContent(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingButtons(),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.account_balance_wallet,
            size: 32,
            color: AppConstants.primaryColor,
          ),
          SizedBox(width: AppConstants.paddingMedium),
          Text(
            'Kassa Boshqaruvi',
            style: TextStyle(
              fontSize: AppConstants.fontSizeXXLarge,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: 16),
          // Obx olib tashlandi (Online yozuvi uchun)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  'ONLINE',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
          Spacer(),
          _buildPeriodSelector(),
          SizedBox(width: AppConstants.paddingMedium),
          _buildFilterButtons(),
          SizedBox(width: AppConstants.paddingMedium),
          ElevatedButton.icon(
            onPressed: () => controller.exportToPDF(),
            icon: Icon(Icons.picture_as_pdf, size: 20),
            label: Text('PDF'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          SizedBox(width: 8),
          IconButton(
            onPressed: () => controller.refreshData(),
            icon: Icon(Icons.refresh),
            tooltip: 'Yangilash',
          ),
        ],
      ),
    );
  }

  // ... _buildPeriodSelector va _buildFilterButtons o'zgarishsiz qoladi ...
  Widget _buildPeriodSelector() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
      ),
      child: Obx(
        () => DropdownButton<String>(
          value: controller.selectedPeriod.value,
          underline: SizedBox.shrink(),
          items: [
            DropdownMenuItem(value: 'today', child: Text('Bugun')),
            DropdownMenuItem(value: 'week', child: Text('Hafta')),
            DropdownMenuItem(value: 'month', child: Text('Oy')),
            DropdownMenuItem(value: 'year', child: Text('Yil')),
            DropdownMenuItem(value: 'custom', child: Text('Tanlash')),
          ],
          onChanged: (value) {
            if (value == 'custom') {
              _showDateRangePicker();
            } else if (value != null) {
              controller.changePeriod(value);
            }
          },
        ),
      ),
    );
  }

  Widget _buildFilterButtons() {
    return Row(
      children: [
        Obx(
          () => DropdownButton<String>(
            value: controller.paymentMethodFilter.value,
            hint: Text('To\'lov usuli'),
            underline: SizedBox.shrink(),
            items: [
              DropdownMenuItem(value: 'all', child: Text('Barchasi')),
              DropdownMenuItem(value: 'cash', child: Text('Naqd')),
              DropdownMenuItem(value: 'click', child: Text('Click,Bank')),
              DropdownMenuItem(value: 'card', child: Text('Terminal Karta')),
            ],
            onChanged: (value) => controller.changePaymentMethodFilter(value!),
          ),
        ),
        SizedBox(width: AppConstants.paddingSmall),
        Obx(
          () => DropdownButton<String>(
            value: controller.statusFilter.value,
            hint: Text('Holat'),
            underline: SizedBox.shrink(),
            items: [
              DropdownMenuItem(value: 'all', child: Text('Barchasi')),
              DropdownMenuItem(value: 'paid', child: Text('To\'langan')),
              DropdownMenuItem(value: 'pending', child: Text('Kutilmoqda')),
              DropdownMenuItem(value: 'cancelled', child: Text('Bekor')),
            ],
            onChanged: (value) => controller.changeStatusFilter(value!),
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppConstants.paddingLarge),
      child: Column(
        children: [
          _buildCashBalances(),
          SizedBox(height: AppConstants.paddingLarge),
          _buildStatisticsCards(),
          SizedBox(height: AppConstants.paddingLarge),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: _buildPaymentMethodsChart()),
              SizedBox(width: AppConstants.paddingLarge),
              Expanded(child: _buildQuickActions()),
            ],
          ),
          SizedBox(height: AppConstants.paddingLarge),
          _buildTransactionsTable(),
        ],
      ),
    );
  }

  Widget _buildCashBalances() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Kassa Qoldiqlari',
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeLarge,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                // Obx olib tashlandi (Date time uchun)
                Text(
                  'Oxirgi yangilanish: ${DateFormat('HH:mm:ss').format(DateTime.now())}',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),
            // ... Qolgan qismlar o'zgarishsiz ...
            SizedBox(height: AppConstants.paddingLarge),
            Obx(
              () => Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _buildCashBalanceCard(
                    'Asosiy Kassa (Naqd)',
                    controller.mainCashBalance.value,
                    Icons.payments,
                    AppConstants.successColor,
                  ),
                  _buildCashBalanceCard(
                    'Click, Bank',
                    controller.clickBalance.value,
                    Icons.phone_android,
                    AppConstants.infoColor,
                  ),
                  _buildCashBalanceCard(
                    'Terminal Karta',
                    controller.cardBalance.value,
                    Icons.credit_card,
                    Color(0xFF9C27B0),
                  ),
          
                 _buildCashBalanceCard(
                    'Ega Kassasi',
                    controller.ownerCashBalance.value,
                    Icons.account_balance_wallet,
                    AppConstants.warningColor,
                  ),
                  _buildCashBalanceCard(
                    'JAMI QOLDIQ',
                    controller.totalCashBalance.value,
                    Icons.account_balance,
                    AppConstants.primaryColor,
                    isTotal: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method: Cash Balance Card (o'zgarishsiz)
  Widget _buildCashBalanceCard(
    String title,
    double amount,
    IconData icon,
    Color color, {
    bool isTotal = false,
  }) {
    return Container(
      width: isTotal ? double.infinity : 180,
      padding: EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: isTotal ? 3 : 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: isTotal ? 40 : 32, color: color),
          SizedBox(height: AppConstants.paddingSmall),
          Text(
            title,
            style: TextStyle(
              fontSize: isTotal ? 14 : AppConstants.fontSizeSmall,
              color: AppConstants.textSecondaryColor,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppConstants.paddingSmall),
          Text(
            _formatCurrency(amount),
            style: TextStyle(
              fontSize: isTotal ? 24 : AppConstants.fontSizeLarge,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // --- STATISTIKA KARTALARI (O'ZGARISH BOR) ---
  Widget _buildStatisticsCards() {
    return Obx(
      () => Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Bugungi Tushum',
              _formatCurrency(controller.todayRevenue.value),
              Icons.trending_up,
              AppConstants.successColor,
            ),
          ),
          SizedBox(width: AppConstants.paddingMedium),
          Expanded(
            child: _buildStatCard(
              'Davr Tushumi',
              _formatCurrency(controller.periodRevenue.value),
              Icons.show_chart,
              AppConstants.primaryColor,
            ),
          ),
          SizedBox(width: AppConstants.paddingMedium),

          // --- O'ZGARISH #1: Jami Qarz Navigatsiyasi ---
          Expanded(
            child: _buildStatCard(
              'Jami Qarz',
              _formatCurrency(controller.totalDebt.value),
              Icons.warning,
              AppConstants.errorColor,
              // Get.toNamed o'rniga to'g'ridan-to'g'ri Class ga o'tish
              onTap: () => Get.to(() => DebtorStudentsScreen()),
            ),
          ),
          SizedBox(width: AppConstants.paddingMedium),

          // --- O'ZGARISH #2: O'quvchilar Qarzi Navigatsiyasi ---
          Expanded(
            child: _buildStatCard(
              'O\'quvchilar qarzi',
              _formatCurrency(controller.totalStudentDebt.value),
              Icons.people_outline,
              Color(0xFFFF5722),
              // Get.toNamed o'rniga to'g'ridan-to'g'ri Class ga o'tish
              onTap: () => Get.to(() => DebtorStudentsScreen()),
            ),
          ),
        ],
      ),
    );
  }

  // ... _buildStatCard, _buildPaymentMethodsChart, _buildPaymentMethodRow o'zgarishsiz ...
  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 2,
        child: Padding(
          padding: EdgeInsets.all(AppConstants.paddingLarge),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(AppConstants.paddingSmall),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(
                        AppConstants.borderRadiusMedium,
                      ),
                    ),
                    child: Icon(icon, color: color),
                  ),
                  Spacer(),
                  if (onTap != null)
                    Icon(Icons.arrow_forward_ios, size: 14, color: color),
                ],
              ),
              SizedBox(height: AppConstants.paddingMedium),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeMedium,
                    color: AppConstants.textSecondaryColor,
                  ),
                ),
              ),
              SizedBox(height: AppConstants.paddingSmall),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodsChart() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'To\'lov Usullari Bo\'yicha Statistika',
              style: TextStyle(
                fontSize: AppConstants.fontSizeLarge,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppConstants.paddingLarge),
            Obx(
              () => Column(
                children: [
                  _buildPaymentMethodRow(
                    'Naqd',
                    controller.cashPayments.value,
                    controller.periodRevenue.value,
                    AppConstants.successColor,
                  ),
                  _buildPaymentMethodRow(
                    'Click',
                    controller.clickPayments.value,
                    controller.periodRevenue.value,
                    AppConstants.infoColor,
                  ),
                  _buildPaymentMethodRow(
                    'Karta',
                    controller.cardPayments.value,
                    controller.periodRevenue.value,
                    Color(0xFF9C27B0),
                  ),
                  _buildPaymentMethodRow(
                    'Bank',
                    controller.bankPayments.value,
                    controller.periodRevenue.value,
                    Color(0xFF3F51B5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodRow(
    String method,
    double amount,
    double total,
    Color color,
  ) {
    final percentage = total > 0 ? (amount / total * 100) : 0.0;
    return Padding(
      padding: EdgeInsets.only(bottom: AppConstants.paddingMedium),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(method, style: TextStyle(fontWeight: FontWeight.w600)),
              Text(
                '${_formatCurrency(amount)} (${percentage.toStringAsFixed(1)}%)',
                style: TextStyle(fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
          SizedBox(height: AppConstants.paddingSmall),
          LinearProgressIndicator(
            value: total > 0 ? amount / total : 0,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ],
      ),
    );
  }

  // --- TEZKOR AMALLAR (O'ZGARISH BOR) ---
  Widget _buildQuickActions() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tezkor Amallar',
              style: TextStyle(
                fontSize: AppConstants.fontSizeLarge,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppConstants.paddingLarge),
            _buildQuickActionButton(
              'Kassa O\'tkazmasi',
              Icons.swap_horiz,
              AppConstants.primaryColor,
              () => _showTransferDialog(),
            ),
            SizedBox(height: AppConstants.paddingSmall),

            // --- O'ZGARISH #3: Qarzdorlar Navigatsiyasi ---
            _buildQuickActionButton(
              'Qarzdorlar',
              Icons.warning_amber,
              AppConstants.errorColor,
              // Get.toNamed o'rniga to'g'ridan-to'g'ri Class ga o'tish
              () => Get.to(() => DebtorStudentsScreen()),
            ),
            SizedBox(height: AppConstants.paddingSmall),
            _buildQuickActionButton(
              'PDF Hisobot',
              Icons.picture_as_pdf,
              Colors.red,
              () => controller.exportToPDF(),
            ),
            SizedBox(height: AppConstants.paddingSmall),
            _buildQuickActionButton(
              'Kassa Tekshiruvi',
              Icons.fact_check,
              AppConstants.infoColor,
              () => _showCashAudit(),
            ),
          ],
        ),
      ),
    );
  }

  // ... Qolgan barcha metodlar (TransactionTable, FloatingButtons va Dialoglar) o'zgarishsiz qoladi ...
  Widget _buildQuickActionButton(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(AppConstants.paddingMedium),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            SizedBox(width: AppConstants.paddingMedium),
            Expanded(
              child: Text(
                title,
                style: TextStyle(fontWeight: FontWeight.w600, color: color),
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: color),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsTable() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'So\'nggi Tranzaksiyalar',
              style: TextStyle(
                fontSize: AppConstants.fontSizeLarge,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppConstants.paddingLarge),
            Obx(
              () => SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: MaterialStateProperty.all(
                    AppConstants.backgroundLight,
                  ),
                  columns: [
                    DataColumn(
                      label: Text(
                        'Vaqt',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Turi',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Usul',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Summa',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Oldingi',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Keyingi',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Izoh',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Kim',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                  rows: controller.cashTransactions.take(50).map((trans) {
                    final type = trans['transaction_type'] as String;
                    final color = type == 'income'
                        ? AppConstants.successColor
                        : type == 'expense'
                        ? AppConstants.errorColor
                        : AppConstants.infoColor;

                    return DataRow(
                      cells: [
                        DataCell(
                          Text(
                            DateFormat(
                              'dd.MM.yyyy HH:mm',
                            ).format(DateTime.parse(trans['created_at'])),
                          ),
                        ),
                        DataCell(
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _getTransactionTypeName(type),
                              style: TextStyle(color: color, fontSize: 12),
                            ),
                          ),
                        ),
                        DataCell(
                          Text(_getPaymentMethodName(trans['payment_method'])),
                        ),
                        DataCell(
                          Text(
                            _formatCurrency(trans['amount']),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(_formatCurrency(trans['balance_before'])),
                        ),
                        DataCell(Text(_formatCurrency(trans['balance_after']))),
                        DataCell(Text(trans['description'] ?? '-')),
                        DataCell(
                          Text(
                            trans['performed_by_user']?['first_name'] ?? '-',
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingButtons() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton(
          heroTag: 'transfer',
          onPressed: () => _showTransferDialog(),
          child: Icon(Icons.swap_horiz),
          tooltip: 'O\'tkazma',
          backgroundColor: AppConstants.primaryColor,
        ),
        SizedBox(height: AppConstants.paddingSmall),
        FloatingActionButton(
          heroTag: 'refresh',
          onPressed: () => controller.refreshData(),
          child: Icon(Icons.refresh),
          tooltip: 'Yangilash',
        ),
      ],
    );
  }

  // Dialoglar va Helper metodlar o'zgarishsiz qoladi...
  Future<void> _showTransferDialog() async {
    final supabase = Supabase.instance.client;
    final authController = Get.find<AuthController>();
    final branchId = authController.currentUser.value?.branchId;

    if (branchId == null) {
      Get.snackbar("Xato", "Filial topilmadi. Tizimga qayta kiring.");
      return;
    }

    // Faqat shu filial kassalarini yuklaymiz
    final cashRegisters = await supabase
        .from('cash_register')
        .select('*')
        .eq('branch_id', branchId); // <--- FILIAL FILTRI

    // Agar kassa yo'q bo'lsa (yangi filial), default kassalarni qo'shamiz
    List<Map<String, dynamic>> registersList = List<Map<String, dynamic>>.from(
      cashRegisters,
    );

    // UI da ko'rsatish uchun ro'yxatni to'ldiramiz (agar bazada bo'lmasa ham)
    final existingMethods = registersList
        .map((e) => e['payment_method'])
        .toList();

    // Standart metodlar
    final defaults = ['cash', 'click', 'card', 'bank', 'owner_fund'];

    // Bazada yo'q metodlarni 0 balans bilan ko'rsatish (vizualizatsiya uchun)
    for (var method in defaults) {
      if (!existingMethods.contains(method)) {
        registersList.add({
          'id': method, // ID yo'q, lekin metod nomi bor
          'payment_method': method,
          'current_balance': 0.0,
          'branch_id': branchId,
        });
      }
    }

    Get.dialog(
      _CashTransferDialog(
        cashRegisters: registersList,
        onSubmit: (data) {
          controller.transferCash(
            fromMethod: data['from_method'],
            toMethod: data['to_method'],
            amount: data['amount'],
            commission: data['commission'],
            description: data['description'],
          );
        },
      ),
    );
  }

  void _showDateRangePicker() async {
    final picked = await showDateRangePicker(
      context: Get.context!,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(primary: AppConstants.primaryColor),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      controller.setCustomDateRange(picked.start, picked.end);
    }
  }

  void _showCashAudit() {
    Get.snackbar('Ma\'lumot', 'Kassa tekshiruvi funksiyasi ishlab chiqilmoqda');
  }

  String _formatCurrency(dynamic amount) {
    if (amount == null) return '0';
    try {
      final value = amount is num
          ? amount.toDouble()
          : double.parse(amount.toString());
      return value
              .toStringAsFixed(0)
              .replaceAllMapped(
                RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                (Match m) => '${m[1]} ',
              ) +
          ' so\'m';
    } catch (e) {
      return '0 so\'m';
    }
  }

  String _getTransactionTypeName(String type) {
    switch (type) {
      case 'income':
        return 'Kirim';
      case 'expense':
        return 'Chiqim';
      case 'transfer_in':
        return 'Kirish';
      case 'transfer_out':
        return 'Chiqish';
      default:
        return type;
    }
  }

  String _getPaymentMethodName(String method) {
    switch (method) {
      case 'cash':
        return 'Naqd';
      case 'click':
        return 'Click';
      case 'card':
        return 'Bank';
      case 'owner_cash':
        return 'Ega kassasi';
      default:
        return method;
    }
  }
}

// ==================== TRANSFER DIALOG ====================
// Dialog kodi o'zgarishsiz qoladi...
// Agar kerak bo'lsa tepadan ko'chirib olishingiz mumkin
class _CashTransferDialog extends StatefulWidget {
  final List<Map<String, dynamic>> cashRegisters;
  final Function(Map<String, dynamic>) onSubmit;

  const _CashTransferDialog({
    required this.cashRegisters,
    required this.onSubmit,
  });

  @override
  State<_CashTransferDialog> createState() => _CashTransferDialogState();
}

class _CashTransferDialogState extends State<_CashTransferDialog> {
  // ... Eski dialog logikasi ...
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

  @override
  void dispose() {
    amountController.dispose();
    commissionController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void _calculateTotal() {
    final amount = double.tryParse(amountController.text) ?? 0;
    final commission = double.tryParse(commissionController.text) ?? 0;
    setState(() {
      totalAmount = amount + commission;
    });
  }

  void _submit() {
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

    if (fromCash['current_balance'] < totalAmount) {
      Get.snackbar('Xato', 'Kassada yetarli mablag\' yo\'q');
      return;
    }

    widget.onSubmit({
      'from_method': fromCash['payment_method'],
      'to_method': widget.cashRegisters.firstWhere(
        (c) => c['id'] == toCashRegister,
      )['payment_method'],
      'amount': double.parse(amountController.text),
      'commission': double.parse(commissionController.text),
      'description': descriptionController.text,
    });

    Get.back();
  }

  String _formatCurrency(num amount) {
    return NumberFormat('#,###').format(amount);
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

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 700,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
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
            ),
            // Form
            SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        value: fromCashRegister,
                        decoration: InputDecoration(
                          labelText: 'Qayerdan',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: Icon(
                            Icons.account_balance_wallet,
                            color: Colors.red,
                          ),
                        ),
                        items: widget.cashRegisters.map((cash) {
                          final balance = cash['current_balance'];
                          return DropdownMenuItem<String>(
                            value: cash['id'],
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _getPaymentMethodName(cash['payment_method']),
                                ),
                                Text(
                                  'Qoldiq: ${_formatCurrency(balance)} so\'m',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) =>
                            setState(() => fromCashRegister = value),
                        validator: (value) =>
                            value == null ? 'Kassani tanlang' : null,
                      ),
                      SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: toCashRegister,
                        decoration: InputDecoration(
                          labelText: 'Qayerga',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: Icon(
                            Icons.account_balance_wallet,
                            color: Colors.green,
                          ),
                        ),
                        items: widget.cashRegisters.map((cash) {
                          final balance = cash['current_balance'];
                          return DropdownMenuItem<String>(
                            value: cash['id'],
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _getPaymentMethodName(cash['payment_method']),
                                ),
                                Text(
                                  'Qoldiq: ${_formatCurrency(balance)} so\'m',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) =>
                            setState(() => toCashRegister = value),
                        validator: (value) =>
                            value == null ? 'Kassani tanlang' : null,
                      ),
                      SizedBox(height: 24),
                      TextFormField(
                        controller: amountController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'O\'tkaziladigan summa',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: Icon(Icons.attach_money),
                          suffixText: 'so\'m',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return 'Summani kiriting';
                          if (double.tryParse(value) == null)
                            return 'Noto\'g\'ri format';
                          if (double.parse(value) <= 0)
                            return 'Summa 0 dan katta bo\'lishi kerak';
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: commissionController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Komissiya (xarajat)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: Icon(Icons.percent, color: Colors.orange),
                          suffixText: 'so\'m',
                          helperText: 'Bank yoki Click komissiyasi',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return null;
                          if (double.tryParse(value) == null)
                            return 'Noto\'g\'ri format';
                          if (double.parse(value) < 0)
                            return 'Manfiy bo\'lmasligi kerak';
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      Container(
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
                                  '${_formatCurrency(double.tryParse(amountController.text) ?? 0)} so\'m',
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
                                  '${_formatCurrency(double.tryParse(commissionController.text) ?? 0)} so\'m',
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
                                  '${_formatCurrency(totalAmount)} so\'m',
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
                                    Icon(
                                      Icons.info_outline,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'Kassadan ${_formatCurrency(totalAmount)} so\'m chiqariladi',
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
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: descriptionController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Izoh',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          hintText: 'O\'tkazma sababi...',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Actions
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Get.back(),
                    child: Text('Bekor qilish'),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: _submit,
                    icon: Icon(Icons.check),
                    label: Text('O\'tkazish'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      backgroundColor: Color(0xFF2196F3),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
