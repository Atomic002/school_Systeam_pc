// lib/presentation/screens/finance/advanced_cash_register_screen.dart
// MUKAMMAL KASSA EKRANI

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../widgets/sidebar.dart';
import '../../controllers/cash_register_controller.dart';
import '../../../config/constants.dart';

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

  // ==================== APP BAR ====================
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
          Spacer(),
          _buildPeriodSelector(),
          SizedBox(width: AppConstants.paddingMedium),
          _buildFilterButtons(),
          IconButton(
            onPressed: () => controller.refreshData(),
            icon: Icon(Icons.refresh),
            tooltip: 'Yangilash',
          ),
        ],
      ),
    );
  }

  // ==================== DAVR TANLAGICH ====================
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

  // ==================== FILTER TUGMALARI ====================
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
              DropdownMenuItem(value: 'click', child: Text('Click')),
              DropdownMenuItem(value: 'card', child: Text('Karta')),
              DropdownMenuItem(value: 'bank', child: Text('Bank')),
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

  // ==================== ASOSIY KONTENT ====================
  Widget _buildContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppConstants.paddingLarge),
      child: Column(
        children: [
          // Kassa qoldiqlari
          _buildCashBalances(),
          SizedBox(height: AppConstants.paddingLarge),

          // Statistika kartochkalari
          _buildStatisticsCards(),
          SizedBox(height: AppConstants.paddingLarge),

          // To'lov usullari grafigi
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: _buildPaymentMethodsChart()),
              SizedBox(width: AppConstants.paddingLarge),
              Expanded(child: _buildQuickActions()),
            ],
          ),
          SizedBox(height: AppConstants.paddingLarge),

          // Tranzaksiyalar ro'yxati
          _buildTransactionsTable(),
        ],
      ),
    );
  }

  // ==================== KASSA QOLDIQLARI ====================
  Widget _buildCashBalances() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kassa Qoldiqlari',
              style: TextStyle(
                fontSize: AppConstants.fontSizeLarge,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppConstants.paddingLarge),
            Obx(
              () => Row(
                children: [
                  Expanded(
                    child: _buildCashBalanceCard(
                      'Asosiy Kassa (Naqd)',
                      controller.mainCashBalance.value,
                      Icons.payments,
                      AppConstants.successColor,
                    ),
                  ),
                  SizedBox(width: AppConstants.paddingMedium),
                  Expanded(
                    child: _buildCashBalanceCard(
                      'Click Hamyon',
                      controller.clickBalance.value,
                      Icons.phone_android,
                      AppConstants.infoColor,
                    ),
                  ),
                  SizedBox(width: AppConstants.paddingMedium),
                  Expanded(
                    child: _buildCashBalanceCard(
                      'Ega Kassasi',
                      controller.ownerCashBalance.value,
                      Icons.account_balance_wallet,
                      AppConstants.warningColor,
                    ),
                  ),
                  SizedBox(width: AppConstants.paddingMedium),
                  Expanded(
                    child: _buildCashBalanceCard(
                      'Jami Qoldiq',
                      controller.totalCashBalance.value,
                      Icons.account_balance,
                      AppConstants.primaryColor,
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

  Widget _buildCashBalanceCard(
    String title,
    double amount,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: color),
          SizedBox(height: AppConstants.paddingSmall),
          Text(
            title,
            style: TextStyle(
              fontSize: AppConstants.fontSizeSmall,
              color: AppConstants.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppConstants.paddingSmall),
          Text(
            _formatCurrency(amount),
            style: TextStyle(
              fontSize: AppConstants.fontSizeLarge,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== STATISTIKA KARTOCHKALARI ====================
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
          Expanded(
            child: _buildStatCard(
              'Kutilayotgan Tushum',
              _formatCurrency(controller.expectedRevenue.value),
              Icons.access_time,
              AppConstants.infoColor,
            ),
          ),
          SizedBox(width: AppConstants.paddingMedium),
          Expanded(
            child: _buildStatCard(
              'Jami Qarz',
              _formatCurrency(controller.totalDebt.value),
              Icons.warning,
              AppConstants.errorColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
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
    );
  }

  // ==================== TO'LOV USULLARI GRAFIGI ====================
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
                    AppConstants.warningColor,
                  ),
                  _buildPaymentMethodRow(
                    'Bank',
                    controller.bankPayments.value,
                    controller.periodRevenue.value,
                    AppConstants.primaryColor,
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

  // ==================== TEZKOR AMALLAR ====================
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
            _buildQuickActionButton(
              'Hisobot Eksport',
              Icons.file_download,
              AppConstants.successColor,
              () => _exportReport(),
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

  // ==================== TRANZAKSIYALAR JADVALI ====================
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

  // ==================== FLOATING BUTTONS ====================
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

  // ==================== DIALOGLAR ====================
  void _showTransferDialog() {
    final fromMethodController = TextEditingController();
    final toMethodController = TextEditingController();
    final amountController = TextEditingController();
    final descController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: Text('Kassa O\'tkazmasi'),
        content: Container(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Qayerdan'),
                items: [
                  DropdownMenuItem(value: 'cash', child: Text('Naqd kassa')),
                  DropdownMenuItem(value: 'click', child: Text('Click hamyon')),
                  DropdownMenuItem(
                    value: 'owner_cash',
                    child: Text('Ega kassasi'),
                  ),
                ],
                onChanged: (v) => fromMethodController.text = v ?? '',
              ),
              SizedBox(height: AppConstants.paddingMedium),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Qayerga'),
                items: [
                  DropdownMenuItem(value: 'cash', child: Text('Naqd kassa')),
                  DropdownMenuItem(value: 'click', child: Text('Click hamyon')),
                  DropdownMenuItem(
                    value: 'owner_cash',
                    child: Text('Ega kassasi'),
                  ),
                ],
                onChanged: (v) => toMethodController.text = v ?? '',
              ),
              SizedBox(height: AppConstants.paddingMedium),
              TextField(
                controller: amountController,
                decoration: InputDecoration(labelText: 'Summa'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: AppConstants.paddingMedium),
              TextField(
                controller: descController,
                decoration: InputDecoration(labelText: 'Izoh'),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Bekor qilish')),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text);
              if (amount != null && amount > 0) {
                controller.transferCash(
                  fromMethod: fromMethodController.text,
                  toMethod: toMethodController.text,
                  amount: amount,
                  description: descController.text,
                );
                Get.back();
              }
            },
            child: Text('O\'tkazish'),
          ),
        ],
      ),
    );
  }

  void _showDateRangePicker() {
    // Custom date range picker implementation
    Get.snackbar('Ma\'lumot', 'Sana tanlash funksiyasi keyinroq qo\'shiladi');
  }

  void _exportReport() {
    Get.snackbar('Ma\'lumot', 'Hisobot eksport qilish keyinroq qo\'shiladi');
  }

  void _showCashAudit() {
    Get.snackbar('Ma\'lumot', 'Kassa tekshiruvi keyinroq qo\'shiladi');
  }

  // ==================== HELPER METODLAR ====================
  String _formatCurrency(double amount) {
    return amount
            .toStringAsFixed(0)
            .replaceAllMapped(
              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
              (Match m) => '${m[1]} ',
            ) +
        ' so\'m';
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
