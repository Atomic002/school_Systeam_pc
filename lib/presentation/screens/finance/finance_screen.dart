// lib/presentation/screens/finance/advanced_finance_screen.dart
// MUKAMMAL MOLIYA EKRANI - TO'LIQ FUNKSIONAL

import 'package:flutter/material.dart';
import 'package:flutter_application_1/presentation/controllers/finance_controller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../config/constants.dart';
import '../../widgets/sidebar.dart';

class AdvancedFinanceScreen extends StatelessWidget {
  AdvancedFinanceScreen({Key? key}) : super(key: key);

  final controller = Get.put(AdvancedFinanceController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundLight,
      body: Row(
        children: [
          Sidebar(),
          Expanded(
            child: Column(
              children: [
                _buildHeader(),
               Expanded(
  child: Obx(() {
    if (controller.isLoading.value) {
      return Center(child: CircularProgressIndicator());
    }
    return _buildContent(context);
  }),
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
      padding: EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppConstants.primaryColor, AppConstants.secondaryColor],
        ),
        boxShadow: [
          BoxShadow(
            color: AppConstants.primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.account_balance, color: Colors.white, size: 32),
              SizedBox(width: 16),
              Text(
                'Moliya Boshqaruvi',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Spacer(),
              _buildHeaderFilters(),
            ],
          ),
          SizedBox(height: 20),
          _buildQuickStats(),
        ],
      ),
    );
  }

  Widget _buildHeaderFilters() {
    return Row(
      children: [
        Obx(() => Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: DropdownButton<String>(
                value: controller.selectedBranchId.value,
                dropdownColor: AppConstants.primaryColor,
                style: TextStyle(color: Colors.white),
                underline: SizedBox(),
                icon: Icon(Icons.arrow_drop_down, color: Colors.white),
                items: [
                  DropdownMenuItem(value: 'all', child: Text('Barcha filiallar')),
                  ...controller.branches.map((branch) {
                    return DropdownMenuItem(
                      value: branch['id'],
                      child: Text(branch['name']),
                    );
                  }),
                ],
                onChanged: (value) {
                  if (value != null) controller.changeBranch(value);
                },
              ),
            )),
        SizedBox(width: 16),
        Obx(() => Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: DropdownButton<String>(
                value: controller.selectedPeriod.value,
                dropdownColor: AppConstants.primaryColor,
                style: TextStyle(color: Colors.white),
                underline: SizedBox(),
                icon: Icon(Icons.arrow_drop_down, color: Colors.white),
                items: [
                  DropdownMenuItem(value: 'today', child: Text('Bugun')),
                  DropdownMenuItem(value: 'week', child: Text('Bu hafta')),
                  DropdownMenuItem(value: 'month', child: Text('Bu oy')),
                  DropdownMenuItem(value: 'year', child: Text('Bu yil')),
                  DropdownMenuItem(value: 'all', child: Text('Barchasi')),
                ],
                onChanged: (value) {
                  if (value != null) controller.changePeriod(value);
                },
              ),
            )),
        SizedBox(width: 16),
        IconButton(
          onPressed: controller.refreshData,
          icon: Icon(Icons.refresh, color: Colors.white),
          tooltip: 'Yangilash',
        ),
        IconButton(
          onPressed: controller.exportReport,
          icon: Icon(Icons.download, color: Colors.white),
          tooltip: 'Hisobotni yuklab olish',
        ),
      ],
    );
  }

  Widget _buildQuickStats() {
    return Obx(() => Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: controller.showAllPayments,
                child: _buildStatCard(
                  'Jami Tushum',
                  '${_formatCurrency(controller.totalRevenue.value)} so\'m',
                  Icons.trending_up,
                  Colors.green.shade400,
                  '+${controller.revenueGrowth.value.toStringAsFixed(1)}%',
                  true,
                ),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: InkWell(
                onTap: controller.showAllExpenses,
                child: _buildStatCard(
                  'Jami Xarajat',
                  '${_formatCurrency(controller.totalExpenses.value)} so\'m',
                  Icons.trending_down,
                  Colors.red.shade400,
                  '+${controller.expenseGrowth.value.toStringAsFixed(1)}%',
                  true,
                ),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'Sof Foyda',
                '${_formatCurrency(controller.netProfit.value)} so\'m',
                Icons.attach_money,
                Colors.blue.shade400,
                '+${controller.profitGrowth.value.toStringAsFixed(1)}%',
                false,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: InkWell(
                onTap: controller.showAllDebtors,
                child: _buildStatCard(
                  'Jami Qarzdorlar',
                  '${_formatCurrency(controller.totalDebt.value)} so\'m',
                  Icons.warning,
                  Colors.orange.shade400,
                  '${controller.totalDebtors.value} ta',
                  true,
                ),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'Yig\'ish %',
                '${controller.collectionRate.value.toStringAsFixed(1)}%',
                Icons.analytics,
                Colors.purple.shade400,
                controller.collectionRate.value >= 80 ? 'Yaxshi' : 'Past',
                false,
              ),
            ),
          ],
        ));
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String trend,
    bool isClickable,
  ) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isClickable
              ? Colors.white.withOpacity(0.5)
              : Colors.white.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  trend,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (isClickable)
                Icon(Icons.open_in_new, color: Colors.white70, size: 16),
            ],
          ),
          SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: Colors.white70,
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  
 Widget _buildContent(BuildContext context) {
  return SingleChildScrollView(
    padding: EdgeInsets.all(AppConstants.paddingLarge),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMonthlyCollection(context),
          SizedBox(height: 24),
          _buildClassesSection(),
          SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: _buildYearlyRevenue()),
              SizedBox(width: 24),
              Expanded(child: _buildRevenueBreakdown()),
            ],
          ),
          SizedBox(height: 24),
          _buildStaffSalaries(),
          SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildStudentDebts()),
              SizedBox(width: 24),
              Expanded(child: _buildExpensesSummary()),
            ],
          ),
        ],
      ),
    );
  }



  Widget _buildYearlyRevenue() {
    return Obx(() => Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.show_chart, color: AppConstants.primaryColor, size: 28),
                    SizedBox(width: 12),
                    Text(
                      'Yillik Daromad',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    Spacer(),
                    DropdownButton<int>(
                      value: controller.selectedYear.value,
                      underline: SizedBox(),
                      items: controller.availableYears.map((year) {
                        return DropdownMenuItem(
                          value: year,
                          child: Text('$year', style: TextStyle(fontWeight: FontWeight.w600)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) controller.changeYear(value);
                      },
                    ),
                  ],
                ),
                SizedBox(height: 24),
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppConstants.primaryColor,
                        AppConstants.primaryColor.withOpacity(0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Jami Daromad (${controller.selectedYear.value})',
                        style: TextStyle(fontSize: 16, color: Colors.white70),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '${_formatCurrency(controller.yearlyRevenue.value)} so\'m',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Text(
                                'O\'rtacha oylik',
                                style: TextStyle(fontSize: 12, color: Colors.white70),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '${_formatCurrency(controller.averageMonthlyRevenue.value)} so\'m',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          Container(width: 1, height: 40, color: Colors.white30),
                          Column(
                            children: [
                              Text(
                                'Prognoz (yil oxiri)',
                                style: TextStyle(fontSize: 12, color: Colors.white70),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '${_formatCurrency(controller.projectedYearlyRevenue.value)} so\'m',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  'Oylik Taqsimot',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                _buildMonthlyChart(),
              ],
            ),
          ),
        ));
  }

  Widget _buildMonthlyChart() {
    return Obx(() {
      final monthlyData = controller.monthlyRevenueData;
      final expandedId = controller.expandedClassId.value; // Rx o‘qildi
      final classes = controller.classes;                  // Rx o‘qildi

      return Container(
        height: 300,
        child: ListView.builder(
          itemCount: 12,
          itemBuilder: (context, index) {
            final month = index + 1;
            final monthName = _getMonthName(month);
            final revenue = monthlyData[month] ?? 0.0;
            final maxRevenue = monthlyData.values.isEmpty
                ? 1.0
                : monthlyData.values.reduce((a, b) => a > b ? a : b);
            final percentage = maxRevenue > 0 ? (revenue / maxRevenue) : 0.0;

            return Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  SizedBox(
                    width: 80,
                    child: Text(
                      monthName,
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: percentage,
                        minHeight: 24,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation(
                          AppConstants.primaryColor.withOpacity(0.7 + (percentage * 0.3)),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  SizedBox(
                    width: 120,
                    child: Text(
                      '${_formatCurrency(revenue)} so\'m',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: revenue > 0 ? AppConstants.successColor : Colors.grey[600],
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildRevenueBreakdown() {
    return Obx(() => Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tushum Tarkibi',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 24),
                _buildRevenueItem(
                  'Oylik to\'lovlar',
                  controller.monthlyPaymentsRevenue.value,
                  AppConstants.primaryColor,
                ),
                SizedBox(height: 16),
                _buildRevenueItem(
                  'Bir martalik to\'lovlar',
                  controller.oneTimePaymentsRevenue.value,
                  AppConstants.successColor,
                ),
                SizedBox(height: 16),
                _buildRevenueItem(
                  'Qo\'shimcha to\'lovlar',
                  controller.additionalRevenue.value,
                  AppConstants.infoColor,
                ),
                SizedBox(height: 24),
                Divider(),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'JAMI',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${_formatCurrency(controller.totalRevenue.value)} so\'m',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.primaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ));
  }

  Widget _buildRevenueItem(String label, double amount, Color color) {
    final percentage = controller.totalRevenue.value > 0
        ? (amount / controller.totalRevenue.value * 100)
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                ),
                SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            Text(
              '${percentage.toStringAsFixed(1)}%',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
        SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: percentage / 100,
            minHeight: 8,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
        SizedBox(height: 4),
        Text(
          '${_formatCurrency(amount)} so\'m',
          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildStaffSalaries() {
    return Obx(() => Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.people, color: AppConstants.primaryColor, size: 28),
                    SizedBox(width: 12),
                    Text(
                      'Xodimlar Maoshi',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    Spacer(),
                    Text(
                      'Jami: ${_formatCurrency(controller.totalSalaryExpense.value)} so\'m',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.errorColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24),
                ...controller.staffSalaryList.map((staff) {
                  return _buildStaffSalaryRow(staff);
                }).toList(),
              ],
            ),
          ),
        ));
  }

  Widget _buildStaffSalaryRow(Map<String, dynamic> staff) {
    final name = '${staff['first_name']} ${staff['last_name']}';
    final position = staff['position'] ?? '';
    final baseSalary = staff['base_salary'] ?? 0.0;
    final paidAmount = staff['paid_amount'] ?? 0.0;
    final remaining = baseSalary - paidAmount;

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: AppConstants.primaryColor.withOpacity(0.1),
          child: Text(
            '${staff['first_name'][0]}${staff['last_name'][0]}'.toUpperCase(),
            style: TextStyle(fontWeight: FontWeight.bold, color: AppConstants.primaryColor),
          ),
        ),
        title: Text(name, style: TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(position),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${_formatCurrency(paidAmount)} so\'m',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppConstants.successColor,
              ),
            ),
            if (remaining > 0)
              Text(
                'Qoldi: ${_formatCurrency(remaining)} so\'m',
                style: TextStyle(fontSize: 12, color: AppConstants.errorColor),
              ),
          ],
        ),
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                _buildInfoRow('Asosiy maosh', '${_formatCurrency(baseSalary)} so\'m'),
                _buildInfoRow('To\'langan', '${_formatCurrency(paidAmount)} so\'m'),
                _buildInfoRow('Qoldiq', '${_formatCurrency(remaining)} so\'m'),
                if (staff['last_payment_date'] != null)
                  _buildInfoRow('Oxirgi to\'lov', _formatDate(staff['last_payment_date'])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentDebts() {
    return Obx(() => Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.warning_amber, color: AppConstants.errorColor, size: 28),
                    SizedBox(width: 12),
                    Text(
                      'O\'quvchilar Qarzlari',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppConstants.errorColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppConstants.errorColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Jami Qarz', style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                          SizedBox(height: 4),
                          Text(
                            '${_formatCurrency(controller.totalStudentDebt.value)} so\'m',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppConstants.errorColor,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Qarzdorlar', style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                          SizedBox(height: 4),
                          Text(
                            '${controller.debtorStudentsCount.value} ta',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppConstants.errorColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Eng Katta Qarzdorlar',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 12),
                ...controller.topDebtors.take(5).map((debtor) {
                  return _buildDebtorRow(debtor);
                }).toList(),
                if (controller.topDebtors.length > 5) ...[
                  SizedBox(height: 12),
                  Center(
                    child: TextButton(
                      onPressed: controller.showAllDebtors,
                      child: Text('Barchasini ko\'rish'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ));
  }

  Widget _buildDebtorRow(Map<String, dynamic> debtor) {
    final name = '${debtor['first_name']} ${debtor['last_name']}';
    final debtAmount = debtor['debt_amount'] ?? 0.0;
    final monthsCount = debtor['months_count'] ?? 0;

    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppConstants.errorColor.withOpacity(0.1),
            child: Text(
              '${debtor['first_name'][0]}${debtor['last_name'][0]}'.toUpperCase(),
              style: TextStyle(fontWeight: FontWeight.bold, color: AppConstants.errorColor),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: TextStyle(fontWeight: FontWeight.w600)),
                Text(
                  '$monthsCount oy qarzdor',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Text(
            '${_formatCurrency(debtAmount)} so\'m',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppConstants.errorColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpensesSummary() {
    return Obx(() => Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.receipt_long, color: AppConstants.primaryColor, size: 28),
                    SizedBox(width: 12),
                    Text(
                      'Xarajatlar',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppConstants.errorColor,
                        AppConstants.errorColor.withOpacity(0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Jami Xarajat',
                        style: TextStyle(fontSize: 14, color: Colors.white70),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '${_formatCurrency(controller.totalExpenses.value)} so\'m',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                _buildExpenseItem('Maoshlar', controller.salaryExpenses.value, AppConstants.errorColor),
                SizedBox(height: 12),
                _buildExpenseItem('Kommunal', controller.utilityExpenses.value, AppConstants.warningColor),
                SizedBox(height: 12),
                _buildExpenseItem('Oziq-ovqat', controller.foodExpenses.value, AppConstants.infoColor),
                SizedBox(height: 12),
                _buildExpenseItem('Transport', controller.transportExpenses.value, AppConstants.primaryColor),
                SizedBox(height: 12),
                _buildExpenseItem('Boshqa', controller.otherExpenses.value, Colors.grey[600]!),
              ],
            ),
          ),
        ));
  }

  Widget _buildExpenseItem(String label, double amount, Color color) {
    final percentage = controller.totalExpenses.value > 0
        ? (amount / controller.totalExpenses.value * 100)
        : 0.0;

    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
        Text(
          '${percentage.toStringAsFixed(1)}%',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        SizedBox(width: 8),
        Text(
          '${_formatCurrency(amount)}',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    return NumberFormat('#,###', 'uz').format(amount);
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd.MM.yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Yanvar', 'Fevral', 'Mart', 'Aprel', 'May', 'Iyun',
      'Iyul', 'Avgust', 'Sentabr', 'Oktabr', 'Noyabr', 'Dekabr',
    ];
    return months[month - 1];
  }

  double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

                  
  Widget _buildSmallStatCard(String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
            ),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildClassesSection() {
    return Obx(() => Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.school, color: AppConstants.primaryColor, size: 28),
                    SizedBox(width: 12),
                    Text(
                      'Sinflar bo\'yicha To\'lovlar',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    Spacer(),
                    Text(
                      '${controller.classes.length} ta sinf',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600], fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                SizedBox(height: 24),
                ...controller.classes.map((classData) {
                  return _buildClassCard(classData);
                }).toList(),
              ],
            ),
          ),
        ));
  }

Widget _buildClassCard(Map<String, dynamic> classData) {
  final String classId = classData['id'].toString();
  final String className = classData['name'] ?? '';
  final String teacherName = classData['teacher_name'] ?? 'Tayinlanmagan';
  final String? teacherId = classData['teacher_id']?.toString();

  final int studentsCount = (classData['students_count'] ?? 0) as int;

  final double expectedRevenue =
      _toDouble(classData['expected_revenue']);
  final double collectedRevenue =
      _toDouble(classData['collected_revenue']);

  final double collectionRate = expectedRevenue > 0
      ? (collectedRevenue / expectedRevenue * 100)
      : 0.0;

  return Obx(() {
    final bool isExpanded = controller.expandedClassId.value == classId;

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          InkWell(
            onTap: () => controller.toggleClassExpansion(classId),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  // chap blok: sinf nomi va o‘qituvchi
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          className,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppConstants.primaryColor,
                          ),
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.person,
                                size: 16, color: Colors.grey[600]),
                            SizedBox(width: 4),
                            GestureDetector(
                              onTap: (teacherId != null &&
                                      teacherId.isNotEmpty)
                                  ? () => controller
                                      .showTeacherProfile(teacherId)
                                  : null,
                              child: Text(
                                teacherName,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: (teacherId != null &&
                                          teacherId.isNotEmpty)
                                      ? AppConstants.primaryColor
                                      : Colors.grey[600],
                                  decoration: (teacherId != null &&
                                          teacherId.isNotEmpty)
                                      ? TextDecoration.underline
                                      : TextDecoration.none,
                                ),
                              ),
                            ),
                            SizedBox(width: 16),
                            Icon(Icons.people,
                                size: 16, color: Colors.grey[600]),
                            SizedBox(width: 4),
                            Text(
                              '$studentsCount o\'quvchi',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // o‘ng blok: yig‘ilgan / kutilgan va % progress bar
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${_formatCurrency(collectedRevenue)} / '
                              '${_formatCurrency(expectedRevenue)} so\'m',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${collectionRate.toStringAsFixed(1)}%',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: collectionRate >= 80
                                    ? AppConstants.successColor
                                    : collectionRate >= 50
                                        ? AppConstants.warningColor
                                        : AppConstants.errorColor,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: collectionRate / 100,
                            minHeight: 12,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation(
                              collectionRate >= 80
                                  ? AppConstants.successColor
                                  : collectionRate >= 50
                                      ? AppConstants.warningColor
                                      : AppConstants.errorColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 20),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: AppConstants.primaryColor,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            Divider(height: 1),
            _buildStudentsList(classId), // e’tibor bering: String id
          ],
        ],
      ),
    );
  });
}
  

  Widget _buildStudentsList(String classId) {
  return Obx(() {
    final students = controller.getClassStudents(classId);

    if (students.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(40),
        child: Center(
          child: Text(
            'O\'quvchilar topilmadi',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(20),
      itemCount: students.length,
      separatorBuilder: (_, __) => Divider(height: 24),
      itemBuilder: (context, index) {
        return _buildStudentRow(students[index]);
      },
    );
  });
}
  Widget _buildStudentRow(Map<String, dynamic> student) {
    final studentId = student['id'].toString();
    final studentName = '${student['first_name']} ${student['last_name']}';
    _toDouble(student['monthly_fee']);
    final expectedFee = _toDouble(student['expected_fee']);
    final paidAmount = _toDouble(student['paid_amount']);
    final discountPercent = _toDouble(student['discount_percent']);
    _toDouble(student['discount_amount']);
    final totalDebt = _toDouble(student['total_debt']);
    final paymentRate = expectedFee > 0 ? (paidAmount / expectedFee * 100) : 0.0;
    final paymentsCount = student['payments_count'] ?? 0;

    return Obx(() {
      final isExpanded = controller.expandedStudentId.value == studentId;

      return Container(
        margin: EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          children: [
            InkWell(
              onTap: () => controller.toggleStudentExpansion(studentId),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: AppConstants.primaryColor.withOpacity(0.1),
                      child: Text(
                        '${student['first_name'][0]}${student['last_name'][0]}'.toUpperCase(),
                        style: TextStyle(fontWeight: FontWeight.bold, color: AppConstants.primaryColor),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(studentName, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.payment, size: 14, color: Colors.grey[600]),
                              SizedBox(width: 4),
                              Text(
                                '$paymentsCount marta to\'lagan',
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              ),
                              if (discountPercent > 0) ...[
                                SizedBox(width: 12),
                                Icon(Icons.local_offer, size: 14, color: Colors.orange),
                                SizedBox(width: 4),
                                Text(
                                  '${discountPercent.toStringAsFixed(0)}% chegirma',
                                  style: TextStyle(fontSize: 12, color: Colors.orange),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Oylik: ${_formatCurrency(expectedFee)} so\'m',
                                style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                              ),
                              Text(
                                '${paymentRate.toStringAsFixed(0)}%',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: paymentRate >= 100
                                      ? AppConstants.successColor
                                      : paymentRate >= 50
                                          ? AppConstants.warningColor
                                          : AppConstants.errorColor,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: paymentRate / 100,
                              minHeight: 10,
                              backgroundColor: Colors.grey[200],
                              valueColor: AlwaysStoppedAnimation(
                                paymentRate >= 100
                                    ? AppConstants.successColor
                                    : paymentRate >= 50
                                        ? AppConstants.warningColor
                                        : AppConstants.errorColor,
                              ),
                            ),
                          ),
                          SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'To\'langan: ${_formatCurrency(paidAmount)}',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppConstants.successColor),
                              ),
                              if (totalDebt > 0)
                                Text(
                                  'Qarz: ${_formatCurrency(totalDebt)}',
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppConstants.errorColor),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 20),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: paymentRate >= 100
                            ? AppConstants.successColor
                            : paymentRate > 0
                                ? AppConstants.warningColor
                                : AppConstants.errorColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        paymentRate >= 100
                            ? 'To\'liq'
                            : paymentRate > 0
                                ? 'Qisman'
                                : 'To\'lamagan',
                        style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      onPressed: () => controller.showStudentDetails(studentId),
                      icon: Icon(Icons.visibility, color: AppConstants.primaryColor),
                    ),
                    Icon(
                      isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      color: AppConstants.primaryColor,
                    ),
                  ],
                ),
              ),
            ),
            if (isExpanded) ...[
              Divider(height: 1),
              _buildStudentPaymentHistory(studentId),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildStudentPaymentHistory(String studentId) {
    return Obx(() {
      final payments = controller.studentPaymentHistory;

      if (payments.isEmpty) {
        return Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            'To\'lovlar tarixi yo\'q',
            style: TextStyle(color: Colors.grey[600]),
          ),
        );
      }

      return Container(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'To\'lovlar Tarixi',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            ...payments.map((payment) {
              final amount = _toDouble(payment['final_amount']);
              final discount = _toDouble(payment['discount_amount']);
              final discountPercent = _toDouble(payment['discount_percent']);
              final date = payment['payment_date'];

              return Container(
                margin: EdgeInsets.only(bottom: 8),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.check_circle, color: Colors.green, size: 20),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '${_formatCurrency(amount)} so\'m',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ),
                        Text(
                          _formatDate(date),
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    if (discount > 0) ...[
                      SizedBox(height: 8),
                      Row(
                        children: [
                          SizedBox(width: 52),
                          Text(
                            'Chegirma: ${discountPercent.toStringAsFixed(0)}% (${_formatCurrency(discount)})',
                            style: TextStyle(fontSize: 12, color: Colors.orange),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      );
    });
  }

Widget _buildMonthlyCollection(BuildContext context) {
  return Obx(() => Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.calendar_month,
                      color: AppConstants.primaryColor, size: 28),
                  SizedBox(width: 12),
                  Text(
                    'Oylik Yig\'ish',
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Spacer(),
                  IconButton(
                    onPressed: controller.previousMonth,
                    icon: Icon(Icons.arrow_back_ios, size: 20),
                    tooltip: 'Oldingi oy',
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => controller.pickMonth(context),
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppConstants.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppConstants.primaryColor),
                      ),
                      child: Text(
                        DateFormat('MMMM yyyy', 'uz')
                            .format(controller.selectedMonth.value),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppConstants.primaryColor,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: controller.nextMonth,
                    icon: Icon(Icons.arrow_forward_ios, size: 20),
                    tooltip: 'Keyingi oy',
                  ),
                ],
              ),
                SizedBox(height: 24),
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppConstants.primaryColor,
                        AppConstants.primaryColor.withOpacity(0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  'Kutilayotgan',
                                  style: TextStyle(fontSize: 14, color: Colors.white70),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  '${_formatCurrency(controller.expectedMonthlyRevenue.value)} so\'m',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(width: 2, height: 60, color: Colors.white30),
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  'Yig\'ilgan',
                                  style: TextStyle(fontSize: 14, color: Colors.white70),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  '${_formatCurrency(controller.collectedMonthlyRevenue.value)} so\'m',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(width: 2, height: 60, color: Colors.white30),
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  'Yig\'ish %',
                                  style: TextStyle(fontSize: 14, color: Colors.white70),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  '${controller.monthlyCollectionRate.value.toStringAsFixed(1)}%',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: controller.monthlyCollectionRate.value / 100,
                          minHeight: 20,
                          backgroundColor: Colors.white.withOpacity(0.3),
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _buildSmallStatCard(
                        'To\'liq to\'lagan',
                        '${controller.paidStudentsCount.value} ta',
                        AppConstants.successColor,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildSmallStatCard(
                        'Qisman to\'lagan',
                        '${controller.partialPaidStudentsCount.value} ta',
                        AppConstants.warningColor,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildSmallStatCard(
                        'To\'lamagan',
                        '${controller.unpaidStudentsCount.value} ta',
                        AppConstants.errorColor,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildSmallStatCard(
                        'Jami o\'quvchi',
                        '${controller.totalStudentsCount.value} ta',
                        AppConstants.infoColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ));}}