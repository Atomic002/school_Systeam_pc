// lib/presentation/screens/finance/finance_screen.dart
// IZOH: Moliyaviy ko'rsatkichlar, hisobotlar va statistika.

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../widgets/sidebar.dart';
import '../../controllers/finance_controller.dart';
import '../../../config/constants.dart';

class FinanceScreen extends StatelessWidget {
  FinanceScreen({Key? key}) : super(key: key);

  final FinanceController controller = Get.put(FinanceController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          Sidebar(),

          // Main content
          Expanded(
            child: Container(
              color: AppConstants.backgroundLight,
              child: Column(
                children: [
                  // AppBar
                  _buildAppBar(),

                  // Content
                  Expanded(
                    child: Obx(() {
                      if (controller.isLoading.value) {
                        return Center(child: CircularProgressIndicator());
                      }
                      return _buildContent();
                    }),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // AppBar
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
          Text(
            'Moliya boshqaruvi',
            style: TextStyle(
              fontSize: AppConstants.fontSizeXXLarge,
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimaryColor,
            ),
          ),
          Spacer(),

          // Davr tanlash
          _buildPeriodSelector(),

          SizedBox(width: AppConstants.paddingMedium),

          IconButton(
            onPressed: () => controller.refreshData(),
            icon: Icon(Icons.refresh),
            tooltip: 'Yangilash',
          ),
        ],
      ),
    );
  }

  // Davr tanlagich
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
          ],
          onChanged: (value) {
            if (value != null) controller.changePeriod(value);
          },
        ),
      ),
    );
  }

  // Asosiy kontent
  Widget _buildContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppConstants.paddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Asosiy statistika
          _buildMainStatistics(),

          SizedBox(height: AppConstants.paddingLarge),

          // Tushum va xarajat taqqoslash
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildRevenueCard()),
              SizedBox(width: AppConstants.paddingLarge),
              Expanded(child: _buildExpensesCard()),
            ],
          ),

          SizedBox(height: AppConstants.paddingLarge),

          // Grafik
          _buildRevenueChart(),

          SizedBox(height: AppConstants.paddingLarge),

          // So'nggi tranzaksiyalar
          _buildRecentTransactions(),
        ],
      ),
    );
  }

  // Asosiy statistika
  Widget _buildMainStatistics() {
    return Obx(
      () => Row(
        children: [
          Expanded(
            child: _buildStatCard(
              title: 'Tushumlar',
              value:
                  '${_formatCurrency(controller.totalRevenue.value)} ${AppConstants.currency}',
              icon: Icons.trending_up,
              color: AppConstants.successColor,
              trend: '+12.5%',
            ),
          ),
          SizedBox(width: AppConstants.paddingMedium),
          Expanded(
            child: _buildStatCard(
              title: 'Xarajatlar',
              value:
                  '${_formatCurrency(controller.totalExpenses.value)} ${AppConstants.currency}',
              icon: Icons.trending_down,
              color: AppConstants.errorColor,
              trend: '+8.3%',
            ),
          ),
          SizedBox(width: AppConstants.paddingMedium),
          Expanded(
            child: _buildStatCard(
              title: 'Sof foyda',
              value:
                  '${_formatCurrency(controller.netProfit.value)} ${AppConstants.currency}',
              icon: Icons.account_balance,
              color: AppConstants.primaryColor,
              trend: '+15.2%',
            ),
          ),
          SizedBox(width: AppConstants.paddingMedium),
          Expanded(
            child: _buildStatCard(
              title: 'Kassa qoldig\'i',
              value:
                  '${_formatCurrency(controller.cashBalance.value)} ${AppConstants.currency}',
              icon: Icons.account_balance_wallet,
              color: AppConstants.infoColor,
            ),
          ),
        ],
      ),
    );
  }

  // Statistika kartochkasi
  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    String? trend,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                  child: Icon(icon, color: color, size: 24),
                ),
                Spacer(),
                if (trend != null)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppConstants.paddingSmall,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppConstants.successColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(
                        AppConstants.borderRadiusSmall,
                      ),
                    ),
                    child: Text(
                      trend,
                      style: TextStyle(
                        fontSize: AppConstants.fontSizeSmall,
                        color: AppConstants.successColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: AppConstants.paddingMedium),
            Text(
              title,
              style: TextStyle(
                fontSize: AppConstants.fontSizeMedium,
                color: AppConstants.textSecondaryColor,
              ),
            ),
            SizedBox(height: AppConstants.paddingSmall),
            Text(
              value,
              style: TextStyle(
                fontSize: AppConstants.fontSizeLarge,
                fontWeight: FontWeight.bold,
                color: AppConstants.textPrimaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Tushumlar kartochkasi
  Widget _buildRevenueCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tushumlar tarkibi',
              style: TextStyle(
                fontSize: AppConstants.fontSizeLarge,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppConstants.paddingLarge),
            Obx(
              () => Column(
                children: [
                  _buildRevenueItem(
                    'Oylik tolovlar',
                    controller.monthlyPayments.value,
                    AppConstants.successColor,
                  ),
                  _buildRevenueItem(
                    'Bir martalik tolovlar',
                    controller.oneTimePayments.value,
                    AppConstants.infoColor,
                  ),
                  _buildRevenueItem(
                    'Boshqa tushumlar',
                    controller.otherRevenue.value,
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

  // Xarajatlar kartochkasi
  Widget _buildExpensesCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Xarajatlar tarkibi',
              style: TextStyle(
                fontSize: AppConstants.fontSizeLarge,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppConstants.paddingLarge),
            Obx(
              () => Column(
                children: [
                  _buildExpenseItem(
                    'Maoshlar',
                    controller.salaryExpenses.value,
                    AppConstants.errorColor,
                  ),
                  _buildExpenseItem(
                    'Kommunal',
                    controller.utilityExpenses.value,
                    AppConstants.warningColor,
                  ),
                  _buildExpenseItem(
                    'Oshxona',
                    controller.kitchenExpenses.value,
                    AppConstants.infoColor,
                  ),
                  _buildExpenseItem(
                    'Boshqa',
                    controller.otherExpenses.value,
                    AppConstants.textSecondaryColor,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Tushum elementi
  Widget _buildRevenueItem(String label, double amount, Color color) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppConstants.paddingMedium),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: AppConstants.paddingSmall),
          Expanded(child: Text(label)),
          Text(
            '${_formatCurrency(amount)} ${AppConstants.currency}',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  // Xarajat elementi
  Widget _buildExpenseItem(String label, double amount, Color color) {
    return _buildRevenueItem(label, amount, color);
  }

  // Grafik (placeholder)
  Widget _buildRevenueChart() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Oylik dinamika',
              style: TextStyle(
                fontSize: AppConstants.fontSizeLarge,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppConstants.paddingLarge),
            Container(
              height: 250,
              child: Center(
                child: Text(
                  'Grafik (fl_chart paketi bilan)',
                  style: TextStyle(color: AppConstants.textSecondaryColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // So'nggi tranzaksiyalar
  Widget _buildRecentTransactions() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Songgi tranzaksiyalar',
              style: TextStyle(
                fontSize: AppConstants.fontSizeLarge,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppConstants.paddingLarge),
            Text(
              'Tranzaksiyalar royxati',
              style: TextStyle(color: AppConstants.textSecondaryColor),
            ),
          ],
        ),
      ),
    );
  }

  // Summani formatlash
  String _formatCurrency(double amount) {
    return amount
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }
}
