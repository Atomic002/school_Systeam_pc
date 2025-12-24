// lib/presentation/screens/dashboard/dashboard_screen.dart
// MUKAMMAL - To'liq real-time dashboard sahifasi

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/dashboard_controller.dart';
import '../../widgets/sidebar.dart';
import '../../../config/constants.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardScreen extends StatelessWidget {
  DashboardScreen({Key? key}) : super(key: key);

  final DashboardController controller = Get.put(DashboardController());

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
                    child: Obx(() {
                      if (controller.isLoading.value) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppConstants.primaryColor,
                                ),
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Ma\'lumotlar yuklanmoqda...',
                                style: TextStyle(
                                  color: AppConstants.textSecondaryColor,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        );
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
            Icons.dashboard_rounded,
            size: 32,
            color: AppConstants.primaryColor,
          ),
          SizedBox(width: 12),
          Text(
            'Dashboard',
            style: TextStyle(
              fontSize: AppConstants.fontSizeXXLarge, 
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimaryColor,
            ),
          ),
          SizedBox(width: AppConstants.paddingLarge),
          
          // Branch selector
          Obx(() {
            if (controller.branches.isEmpty) {
              return SizedBox();
            }
            return Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppConstants.paddingMedium,
                vertical: AppConstants.paddingSmall,
              ),
              decoration: BoxDecoration(
                color: AppConstants.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                border: Border.all(
                  color: AppConstants.primaryColor.withOpacity(0.3),
                ),
              ),
              child: DropdownButton<String>(
                value: controller.selectedBranchId.value,
                underline: SizedBox(),
                icon: Icon(Icons.arrow_drop_down, color: AppConstants.primaryColor),
                items: controller.branches.map((branch) {
                  return DropdownMenuItem<String>(
                    value: branch['id'],
                    child: Row(
                      children: [
                        Icon(Icons.business, size: 16, color: AppConstants.primaryColor),
                        SizedBox(width: 8),
                        Text(
                          branch['name'],
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        if (branch['is_main']) ...[
                          SizedBox(width: 8),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppConstants.successColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Asosiy',
                              style: TextStyle(fontSize: 10, color: Colors.white),
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) controller.changeBranch(value);
                },
              ),
            );
          }),
          
          Spacer(),
          
          // Balance indicator
          Obx(() => Container(
            padding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppConstants.successColor,
                  AppConstants.successColor.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppConstants.successColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.account_balance_wallet, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Umumiy balans',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      '${controller.formatCurrency(controller.totalBalance.value)} so\'m',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )),
          
          SizedBox(width: 16),
          
          // Notifications
          Obx(() => Stack(
            children: [
              IconButton(
                onPressed: () => _showNotifications(),
                icon: Icon(
                  Icons.notifications_rounded,
                  color: controller.unreadNotifications.value > 0
                      ? AppConstants.errorColor
                      : AppConstants.textSecondaryColor,
                ),
                tooltip: 'Bildirishnomalar',
              ),
              if (controller.unreadNotifications.value > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppConstants.errorColor,
                      shape: BoxShape.circle,
                    ),
                    constraints: BoxConstraints(minWidth: 20, minHeight: 20),
                    child: Center(
                      child: Text(
                        '${controller.unreadNotifications.value > 99 ? "99+" : controller.unreadNotifications.value}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          )),
          
          Obx(() => IconButton(
            onPressed: controller.isRefreshing.value ? null : () => controller.refreshData(),
            icon: controller.isRefreshing.value
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(Icons.refresh_rounded),
            tooltip: 'Yangilash',
          )),
          
          SizedBox(width: 8),
          
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppConstants.paddingMedium,
              vertical: AppConstants.paddingSmall,
            ),
            decoration: BoxDecoration(
              color: AppConstants.backgroundLight,
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: AppConstants.textSecondaryColor),
                SizedBox(width: 8),
                Text(
                  _getCurrentDate(),
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeMedium,
                    color: AppConstants.textSecondaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppConstants.paddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Subscription warning
          Obx(() {
            if (controller.isSubscriptionExpiring.value) {
              return _buildSubscriptionWarning();
            }
            return SizedBox.shrink();
          }),
          
          // Financial Overview
          _buildSectionTitle('Moliyaviy ko\'rsatkichlar', Icons.attach_money),
          SizedBox(height: AppConstants.paddingMedium),
          _buildFinancialCards(),
          
          SizedBox(height: AppConstants.paddingLarge),
          
          // Students & Staff Overview
          _buildSectionTitle('O\'quvchilar va Xodimlar', Icons.people),
          SizedBox(height: AppConstants.paddingMedium),
          _buildStudentStaffCards(),
          
          SizedBox(height: AppConstants.paddingLarge),
          
          // Charts and Details
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: _buildRevenueChart()),
              SizedBox(width: AppConstants.paddingLarge),
              Expanded(flex: 1, child: _buildDebtSummary()),
            ],
          ),
          
          SizedBox(height: AppConstants.paddingLarge),
          
          // Classes Details
          _buildSectionTitle('Sinflar ma\'lumotlari', Icons.class_),
          SizedBox(height: AppConstants.paddingMedium),
          _buildClassesTable(),
          
          SizedBox(height: AppConstants.paddingLarge),
          
          // Recent Activity
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildRecentPayments()),
              SizedBox(width: AppConstants.paddingLarge),
              Expanded(child: _buildRecentExpenses()),
            ],
          ),
          
          SizedBox(height: AppConstants.paddingLarge),
          
          // Cash Register Status
          _buildCashRegisterStatus(),
        ],
      ),
    );
  }

  Widget _buildSubscriptionWarning() {
    return Container(
      margin: EdgeInsets.only(bottom: AppConstants.paddingLarge),
      padding: EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: controller.daysUntilExpiry.value <= 7
              ? [Colors.red[400]!, Colors.red[700]!]
              : [Colors.orange[400]!, Colors.deepOrange[600]!],
        ),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
        boxShadow: [
          BoxShadow(
            color: (controller.daysUntilExpiry.value <= 7 ? Colors.red : Colors.orange)
                .withOpacity(0.4),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.warning_amber_rounded,
              color: Colors.white,
              size: 40,
            ),
          ),
          SizedBox(width: AppConstants.paddingLarge),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.daysUntilExpiry.value <= 7
                      ? '⚠️ KRITIK: Obuna muddati tugayapti!'
                      : '⏰ Obuna muddati tugayapti!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 6),
                Obx(() => Text(
                  'Sizning obunangiz ${controller.daysUntilExpiry.value} kundan so\'ng tugaydi. Tizimdan uzluksiz foydalanish uchun obunani yangilang!',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.95),
                    height: 1.4,
                  ),
                )),
              ],
            ),
          ),
          SizedBox(width: 16),
          ElevatedButton.icon(
            onPressed: () {
              Get.snackbar(
                'Obuna',
                'Obuna bo\'limi tez orada ochiladi',
                snackPosition: SnackPosition.TOP,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: controller.daysUntilExpiry.value <= 7
                  ? Colors.red[700]
                  : Colors.deepOrange,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              elevation: 0,
            ),
            icon: Icon(Icons.payment),
            label: Text(
              'Obunani yangilash',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppConstants.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppConstants.primaryColor, size: 24),
        ),
        SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: AppConstants.fontSizeLarge + 2,
            fontWeight: FontWeight.bold,
            color: AppConstants.textPrimaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildFinancialCards() {
    return Obx(() => Wrap(
      spacing: AppConstants.paddingMedium,
      runSpacing: AppConstants.paddingMedium,
      children: [
        _buildStatCard(
          title: 'Bugungi daromad',
          value: controller.formatCurrency(controller.todayRevenue.value),
          unit: 'so\'m',
          icon: Icons.trending_up,
          color: AppConstants.successColor,
          subtitle: '${controller.todayPaymentsCount.value} ta to\'lov',
          trend: controller.netProfit.value >= 0 ? 'up' : 'down',
          trendValue: '${controller.formatCurrency(controller.netProfit.value.abs())} sof',
          width: 280,
        ),
        _buildStatCard(
          title: 'Oylik daromad',
          value: controller.formatCurrency(controller.monthRevenue.value),
          unit: 'so\'m',
          icon: Icons.calendar_month,
          color: AppConstants.primaryColor,
          subtitle: '${controller.monthPaymentsCount.value} ta to\'lov',
          trend: controller.monthNetProfit.value >= 0 ? 'up' : 'down',
          trendValue: '${controller.formatCurrency(controller.monthNetProfit.value.abs())} sof',
          width: 280,
        ),
        _buildStatCard(
          title: 'Bugungi xarajat',
          value: controller.formatCurrency(controller.todayExpenses.value),
          unit: 'so\'m',
          icon: Icons.payment,
          color: AppConstants.errorColor,
          subtitle: 'Kunlik xarajatlar',
          width: 280,
        ),
        _buildStatCard(
          title: 'Oylik xarajat',
          value: controller.formatCurrency(controller.monthExpenses.value),
          unit: 'so\'m',
          icon: Icons.receipt_long,
          color: AppConstants.warningColor,
          subtitle: 'Oy xarajatlari',
          width: 280,
        ),
      ],
    ));
  }

  Widget _buildStudentStaffCards() {
    return Obx(() => Wrap(
      spacing: AppConstants.paddingMedium,
      runSpacing: AppConstants.paddingMedium,
      children: [
        _buildStatCard(
          title: 'Jami o\'quvchilar',
          value: '${controller.totalStudents.value}',
          icon: Icons.school,
          color: AppConstants.infoColor,
          subtitle: 'Aktiv: ${controller.activeStudents.value}',
          detail: 'Yangi (oy): ${controller.newStudentsThisMonth.value}',
          width: 220,
        ),
        _buildStatCard(
          title: 'Qarzdorlar',
          value: '${controller.debtorStudents.value}',
          icon: Icons.warning_amber_rounded,
          color: AppConstants.errorColor,
          subtitle: '${controller.formatCurrency(controller.totalStudentDebt.value)} so\'m',
          isClickable: true,
          onTap: () => _showDebtDetails(),
          width: 220,
        ),
        _buildStatCard(
          title: 'Jami xodimlar',
          value: '${controller.totalStaff.value}',
          icon: Icons.badge,
          color: AppConstants.successColor,
          subtitle: 'O\'qituvchi: ${controller.teachers.value}',
          detail: 'Boshqa: ${controller.otherStaff.value}',
          width: 220,
        ),
        _buildStatCard(
          title: 'Oylik maoshlar',
          value: controller.formatCurrency(controller.totalMonthlySalary.value),
          unit: 'so\'m',
          icon: Icons.attach_money,
          color: AppConstants.primaryColor,
          subtitle: 'To\'langan: ${controller.formatCurrency(controller.paidSalaries.value)}',
          detail: 'Qolgan: ${controller.formatCurrency(controller.unpaidSalaries.value)}',
          isClickable: controller.staffWithUnpaidSalary.isNotEmpty,
          onTap: () => _showUnpaidSalaries(),
          width: 220,
        ),
        if (controller.totalSalaryDebt.value > 0)
          _buildStatCard(
            title: 'Jami maosh qarzi',
            value: controller.formatCurrency(controller.totalSalaryDebt.value),
            unit: 'so\'m',
            icon: Icons.money_off,
            color: Colors.red[700]!,
            subtitle: '${controller.allUnpaidSalaries.length} ta to\'lov',
            isClickable: true,
            onTap: () => _showAllUnpaidSalaries(),
            width: 220,
          ),
      ],
    ));
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    String? unit,
    required IconData icon,
    required Color color,
    required String subtitle,
    String? detail,
    String? trend,
    String? trendValue,
    bool isClickable = false,
    VoidCallback? onTap,
    double width = 250,
  }) {
    return SizedBox(
      width: width,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
        ),
        child: InkWell(
          onTap: isClickable ? onTap : null,
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
          child: Padding(
            padding: EdgeInsets.all(AppConstants.paddingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: color, size: 24),
                    ),
                    Spacer(),
                    if (trend != null)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: trend == 'up' 
                              ? AppConstants.successColor.withOpacity(0.1)
                              : AppConstants.errorColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              trend == 'up' ? Icons.arrow_upward : Icons.arrow_downward,
                              size: 12,
                              color: trend == 'up' 
                                  ? AppConstants.successColor
                                  : AppConstants.errorColor,
                            ),
                            if (trendValue != null) ...[
                              SizedBox(width: 4),
                              Text(
                                trendValue,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: trend == 'up' 
                                      ? AppConstants.successColor
                                      : AppConstants.errorColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ],
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
                SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Text(
                        value,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: AppConstants.textPrimaryColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (unit != null) ...[
                      SizedBox(width: 4),
                      Padding(
                        padding: EdgeInsets.only(bottom: 3),
                        child: Text(
                          unit,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppConstants.textSecondaryColor,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeSmall,
                    color: AppConstants.textLightColor,
                  ),
                ),
                if (detail != null) ...[
                  SizedBox(height: 4),
                  Text(
                    detail,
                    style: TextStyle(
                      fontSize: AppConstants.fontSizeSmall,
                      color: AppConstants.textLightColor,
                    ),
                  ),
                ],
                if (isClickable) ...[
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        'Batafsil',
                        style: TextStyle(
                          fontSize: AppConstants.fontSizeSmall,
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward, size: 14, color: color),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRevenueChart() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Oylik daromad va xarajat dinamikasi',
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeLarge,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                Obx(() => Text(
                  'Yillik: ${controller.formatCurrency(controller.yearRevenue.value)} so\'m',
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeMedium,
                    color: AppConstants.successColor,
                    fontWeight: FontWeight.w600,
                  ),
                )),
              ],
            ),
            SizedBox(height: AppConstants.paddingLarge),
            Container(
              height: 300,
              child: Obx(() {
                if (controller.monthlyRevenueData.isEmpty) {
                  return Center(child: CircularProgressIndicator());
                }
                return LineChart(
                  LineChartData(
                    gridData: FlGridData(show: true, drawVerticalLine: false),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 60,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              '${(value / 1000000).toStringAsFixed(0)}M',
                              style: TextStyle(fontSize: 10),
                            );
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            if (value.toInt() >= 0 && 
                                value.toInt() < controller.monthlyRevenueData.length) {
                              return Text(
                                controller.monthlyRevenueData[value.toInt()]['month'],
                                style: TextStyle(fontSize: 10),
                              );
                            }
                            return Text('');
                          },
                        ),
                      ),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: controller.monthlyRevenueData
                            .asMap()
                            .entries
                            .map((e) => FlSpot(
                                  e.key.toDouble(),
                                  (e.value['revenue'] as num).toDouble(),
                                ))
                            .toList(),
                        isCurved: true,
                        color: AppConstants.successColor,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: FlDotData(show: true),
                        belowBarData: BarAreaData(
                          show: true,
                          color: AppConstants.successColor.withOpacity(0.1),
                        ),
                      ),
                      LineChartBarData(
                        spots: controller.monthlyRevenueData
                            .asMap()
                            .entries
                            .map((e) => FlSpot(
                                  e.key.toDouble(),
                                  (e.value['expense'] as num).toDouble(),
                                ))
                            .toList(),
                        isCurved: true,
                        color: AppConstants.errorColor,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: FlDotData(show: true),
                        belowBarData: BarAreaData(
                          show: true,
                          color: AppConstants.errorColor.withOpacity(0.1),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildChartLegend('Daromad', AppConstants.successColor),
                SizedBox(width: 24),
                _buildChartLegend('Xarajat', AppConstants.errorColor),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartLegend(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        SizedBox(width: 8),
        Text(label, style: TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildDebtSummary() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: AppConstants.warningColor),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Eng katta qarzlar',
                    style: TextStyle(
                      fontSize: AppConstants.fontSizeLarge,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppConstants.paddingLarge),
            Obx(() {
              if (controller.studentsWithDebt.isEmpty) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppConstants.paddingLarge),
                    child: Column(
                      children: [
                        Icon(Icons.check_circle, size: 48, color: AppConstants.successColor),
                        SizedBox(height: 8),
                        Text(
                          'Qarzdorlar yo\'q',
                          style: TextStyle(color: AppConstants.textSecondaryColor),
                        ),
                      ],
                    ),
                  ),
                );
              }
              
              return ListView.separated(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: controller.studentsWithDebt.take(5).length,
                separatorBuilder: (_, __) => Divider(height: 1),
                itemBuilder: (context, index) {
                  final debt = controller.studentsWithDebt[index];
                  return ListTile(
                    contentPadding: EdgeInsets.symmetric(vertical: 4),
                    leading: CircleAvatar(
                      backgroundColor: AppConstants.errorColor.withOpacity(0.1),
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: AppConstants.errorColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      debt['student_name'],
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text('${debt['class_name']} • ${debt['months_count']} oy'),
                    trailing: Text(
                      '${controller.formatCurrency(debt['total_debt'])} so\'m',
                      style: TextStyle(
                        color: AppConstants.errorColor,
                        fontWeight: FontWeight.bold,
                        fontSize: AppConstants.fontSizeMedium,
                      ),
                    ),
                  );
                },
              );
            }),
            if (controller.studentsWithDebt.length > 5) ...[
              SizedBox(height: 8),
              TextButton(
                onPressed: () => _showDebtDetails(),
                child: Text('Barchasini ko\'rish (${controller.studentsWithDebt.length})'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildClassesTable() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppConstants.paddingLarge),
        child: Obx(() {
          if (controller.classesDetails.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(AppConstants.paddingLarge),
                child: Text('Sinflar ma\'lumoti yo\'q'),
              ),
            );
          }
          
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(
                AppConstants.primaryColor.withOpacity(0.1),
              ),
              columns: [
                DataColumn(label: Text('Sinf', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Daraja', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Xona', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('O\'qituvchi', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('O\'quvchilar', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('To\'lagan', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('To\'lamagan', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('To\'lov %', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Oylik summa', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Qarz', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: controller.classesDetails.map((cls) {
                return DataRow(cells: [
                  DataCell(Text(cls['class_name'])),
                  DataCell(Text(cls['class_level'])),
                  DataCell(Text(cls['room_name'] ?? '-')),
                  DataCell(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(cls['teacher_name']),
                        if (cls['teacher_phone'] != '')
                          Text(
                            cls['teacher_phone'],
                            style: TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                      ],
                    ),
                  ),
                  DataCell(
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppConstants.infoColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${cls['student_count']}',
                        style: TextStyle(
                          color: AppConstants.infoColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  DataCell(
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppConstants.successColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${cls['paid_count']}',
                        style: TextStyle(
                          color: AppConstants.successColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  DataCell(
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: cls['unpaid_count'] > 0
                            ? AppConstants.errorColor.withOpacity(0.1)
                            : AppConstants.successColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${cls['unpaid_count']}',
                        style: TextStyle(
                          color: cls['unpaid_count'] > 0
                              ? AppConstants.errorColor
                              : AppConstants.successColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  DataCell(
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: cls['payment_percent'] >= 80
                            ? AppConstants.successColor.withOpacity(0.1)
                            : cls['payment_percent'] >= 50
                                ? AppConstants.warningColor.withOpacity(0.1)
                                : AppConstants.errorColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${cls['payment_percent']}%',
                        style: TextStyle(
                          color: cls['payment_percent'] >= 80
                              ? AppConstants.successColor
                              : cls['payment_percent'] >= 50
                                  ? AppConstants.warningColor
                                  : AppConstants.errorColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  DataCell(Text(
                    '${controller.formatCurrency(cls['total_monthly_fee'])} so\'m',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  )),
                  DataCell(
                    cls['debt_amount'] > 0
                        ? Text(
                            '${controller.formatCurrency(cls['debt_amount'])} so\'m',
                            style: TextStyle(
                              color: AppConstants.errorColor,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : Text('-', style: TextStyle(color: Colors.grey)),
                  ),
                ]);
              }).toList(),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildRecentPayments() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.payment, color: AppConstants.successColor),
                SizedBox(width: 8),
                Text(
                  'So\'nggi to\'lovlar',
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeLarge,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppConstants.paddingMedium),
            Obx(() {
              if (controller.recentPayments.isEmpty) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppConstants.paddingLarge),
                    child: Text('To\'lovlar yo\'q'),
                  ),
                );
              }
              
              return ListView.separated(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: controller.recentPayments.take(7).length,
                separatorBuilder: (_, __) => Divider(height: 1),
                itemBuilder: (context, index) {
                  final payment = controller.recentPayments[index];
                  final student = payment['students'];
                  return ListTile(
                    contentPadding: EdgeInsets.symmetric(vertical: 4),
                    leading: CircleAvatar(
                      backgroundColor: AppConstants.successColor.withOpacity(0.1),
                      child: Icon(Icons.person, color: AppConstants.successColor, size: 20),
                    ),
                    title: Text(
                      student != null 
                          ? '${student['first_name']} ${student['last_name']}'
                          : 'Noma\'lum',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      '${payment['payment_date']} ${payment['payment_time'] ?? ''} • ${student?['class_name'] ?? ''}',
                      style: TextStyle(fontSize: 12),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${controller.formatCurrency(payment['amount'])} so\'m',
                          style: TextStyle(
                            color: AppConstants.successColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          payment['payment_method'] ?? 'cash',
                          style: TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentExpenses() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.receipt_long, color: AppConstants.errorColor),
                SizedBox(width: 8),
                Text(
                  'So\'nggi xarajatlar',
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeLarge,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppConstants.paddingMedium),
            Obx(() {
              if (controller.recentExpenses.isEmpty) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppConstants.paddingLarge),
                    child: Text('Xarajatlar yo\'q'),
                  ),
                );
              }
              
              return ListView.separated(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: controller.recentExpenses.take(7).length,
                separatorBuilder: (_, __) => Divider(height: 1),
                itemBuilder: (context, index) {
                  final expense = controller.recentExpenses[index];
                  return ListTile(
                    contentPadding: EdgeInsets.symmetric(vertical: 4),
                    leading: CircleAvatar(
                      backgroundColor: AppConstants.errorColor.withOpacity(0.1),
                      child: Icon(Icons.money_off, color: AppConstants.errorColor, size: 20),
                    ),
                    title: Text(
                      expense['title'] ?? 'Noma\'lum',
                      style: TextStyle(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      '${expense['expense_date']} • ${expense['category'] ?? ''}',
                      style: TextStyle(fontSize: 12),
                    ),
                    trailing: Text(
                      '${controller.formatCurrency(expense['amount'])} so\'m',
                      style: TextStyle(
                        color: AppConstants.errorColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }

      Widget _buildCashRegisterStatus() {
    return Obx(() => Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.account_balance_wallet, color: AppConstants.primaryColor),
                SizedBox(width: 8),
                Text(
                  'Kassa holati',
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeLarge,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppConstants.paddingLarge),
            
            // 4 ta ustunli qator
            Row(
              children: [
                // 1. NAQD PUL
                Expanded(
                  child: _buildBalanceCard(
                    'Naqd pul',
                    controller.cashBalance.value,
                    Icons.payments,
                    Colors.green,
                  ),
                ),
                SizedBox(width: AppConstants.paddingMedium),
                
                // 2. PLASTIK KARTA (TERMINAL)
                Expanded(
                  child: _buildBalanceCard(
                    'Plastik karta',
                    controller.cardBalance.value, // To'g'irlandi
                    Icons.credit_card,
                    Colors.blue,
                  ),
                ),
                SizedBox(width: AppConstants.paddingMedium),
                
                // 3. O'TKAZMA (CLICK)
                Expanded(
                  child: _buildBalanceCard(
                    'O\'tkazma (Click)',
                    controller.transferBalance.value,
                    Icons.account_balance,
                    Colors.purple,
                  ),
                ),
                SizedBox(width: AppConstants.paddingMedium),
                
                // 4. EGA KASSASI (YANGI)
                Expanded(
                  child: _buildBalanceCard(
                    'Ega kassasi',
                    controller.ownerFundBalance.value,
                    Icons.savings_rounded,
                    Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ));
  }

  Widget _buildBalanceCard(String title, double amount, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 4),
          Text(
            '${controller.formatCurrency(amount)}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            'so\'m',
            style: TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  void _showNotifications() {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.notifications, color: AppConstants.primaryColor),
            SizedBox(width: 8),
            Text('Bildirishnomalar'),
            Spacer(),
            if (controller.notifications.isNotEmpty)
              TextButton(
                onPressed: () => controller.markAllNotificationsAsRead(),
                child: Text('Barchasini o\'qildi'),
              ),
          ],
        ),
        content: Container(
          width: 600,
          height: 500,
          child: Obx(() {
            if (controller.notifications.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.notifications_none, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('Bildirishnomalar yo\'q'),
                  ],
                ),
              );
            }
            
            return ListView.separated(
              itemCount: controller.notifications.length,
              separatorBuilder: (_, __) => Divider(),
              itemBuilder: (context, index) {
                final notification = controller.notifications[index];
                final isRead = notification['is_read'];
                
                Color iconColor = AppConstants.infoColor;
                IconData iconData = Icons.info;
                
                switch (notification['type']) {
                  case 'error':
                    iconColor = AppConstants.errorColor;
                    iconData = Icons.error;
                    break;
                  case 'warning':
                    iconColor = AppConstants.warningColor;
                    iconData = Icons.warning;
                    break;
                  case 'success':
                    iconColor = AppConstants.successColor;
                    iconData = Icons.check_circle;
                    break;
                }
                
                return ListTile(
                  leading: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(iconData, color: iconColor),
                  ),
                  title: Text(
                    notification['title'],
                    style: TextStyle(
                      fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(notification['message']),
                  trailing: isRead
                      ? null
                      : IconButton(
                          icon: Icon(Icons.check, color: AppConstants.successColor),
                          onPressed: () {
                            controller.markNotificationAsRead(notification['id']);
                          },
                        ),
                  tileColor: isRead ? null : iconColor.withOpacity(0.05),
                );
              },
            );
          }),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Yopish'),
          ),
        ],
      ),
    );
  }

  void _showDebtDetails() {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppConstants.warningColor),
            SizedBox(width: 8),
            Text('Qarzdor o\'quvchilar'),
          ],
        ),
        content: Container(
          width: 700,
          height: 550,
          child: Obx(() {
            if (controller.studentsWithDebt.isEmpty) {
              return Center(child: Text('Qarzdorlar yo\'q'));
            }
            
            return Column(
              children: [
                Container(
                  padding: EdgeInsets.all(AppConstants.paddingMedium),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.orange[100]!, Colors.deepOrange[100]!],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Jami qarzdorlar',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(
                              '${controller.debtorStudents.value} ta o\'quvchi',
                              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Jami qarz',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            '${controller.formatCurrency(controller.totalStudentDebt.value)} so\'m',
                            style: TextStyle(
                              color: AppConstants.errorColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppConstants.paddingMedium),
                Expanded(
                  child: ListView.builder(
                    itemCount: controller.studentsWithDebt.length,
                    itemBuilder: (context, index) {
                      final debt = controller.studentsWithDebt[index];
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppConstants.errorColor.withOpacity(0.1),
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: AppConstants.errorColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            debt['student_name'],
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(debt['class_name']),
                              if (debt['phone'] != '')
                                Text(
                                  'Tel: ${debt['phone']}',
                                  style: TextStyle(fontSize: 12),
                                ),
                              if (debt['parent_phone'] != '')
                                Text(
                                  'Ota-ona: ${debt['parent_phone']}',
                                  style: TextStyle(fontSize: 12),
                                ),
                            ],
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${controller.formatCurrency(debt['total_debt'])} so\'m',
                                style: TextStyle(
                                  color: AppConstants.errorColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                '${debt['months_count']} oy qarzi',
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Yopish'),
          ),
        ],
      ),
    );
  }

  void _showUnpaidSalaries() {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.attach_money, color: AppConstants.warningColor),
            SizedBox(width: 8),
            Text('Joriy oy to\'lanmagan maoshlar'),
          ],
        ),
        content: Container(
          width: 600,
          height: 500,
          child: Obx(() {
            if (controller.staffWithUnpaidSalary.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, size: 64, color: AppConstants.successColor),
                    SizedBox(height: 16),
                    Text('Barcha maoshlar to\'langan'),
                  ],
                ),
              );
            }
            
            return Column(
              children: [
                Container(
                  padding: EdgeInsets.all(AppConstants.paddingMedium),
                  decoration: BoxDecoration(
                    color: AppConstants.warningColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'To\'lanmagan maoshlar',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            '${controller.staffWithUnpaidSalary.length} ta xodim',
                            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                          ),
                        ],
                      ),
                      Text(
                        '${controller.formatCurrency(controller.paidSalaries.value)} so\'m',
                        style: TextStyle(
                          color: AppConstants.errorColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppConstants.paddingMedium),
                Expanded(
                  child: ListView.builder(
                    itemCount: controller.staffWithUnpaidSalary.length,
                    itemBuilder: (context, index) {
                      final salary = controller.staffWithUnpaidSalary[index];
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppConstants.primaryColor.withOpacity(0.1),
                            child: Icon(Icons.person, color: AppConstants.primaryColor),
                          ),
                          title: Text(
                            salary['staff_name'],
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${salary['position']} • ${salary['period']}'),
                              if (salary['phone'] != '')
                                Text(
                                  'Tel: ${salary['phone']}',
                                  style: TextStyle(fontSize: 12),
                                ),
                            ],
                          ),
                          trailing: Text(
                            '${controller.formatCurrency((salary['amount'] as num).toDouble())} so\'m',
                            style: TextStyle(
                              color: AppConstants.errorColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Yopish'),
          ),
        ],
      ),
    );
  }

  void _showAllUnpaidSalaries() {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.money_off, color: Colors.red[700]),
            SizedBox(width: 8),
            Text('Barcha to\'lanmagan maoshlar'),
          ],
        ),
        content: Container(
          width: 700,
          height: 550,
          child: Obx(() {
            if (controller.allUnpaidSalaries.isEmpty) {
              return Center(child: Text('Barcha maoshlar to\'langan'));
            }
            
            final groupedSalaries = <String, List<Map<String, dynamic>>>{};
            for (var salary in controller.allUnpaidSalaries) {
              final key = '${salary['period_year']}-${salary['period_month'].toString().padLeft(2, '0')}';
              if (!groupedSalaries.containsKey(key)) {
                groupedSalaries[key] = [];
              }
              groupedSalaries[key]!.add(salary);
            }
            
            final sortedKeys = groupedSalaries.keys.toList()..sort((a, b) => b.compareTo(a));
            
            return Column(
              children: [
                Container(
                  padding: EdgeInsets.all(AppConstants.paddingMedium),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.red[100]!, Colors.red[200]!],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Jami to\'lanmagan maoshlar',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(
                              '${controller.allUnpaidSalaries.length} ta maosh',
                              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Jami summa',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            '${controller.formatCurrency(controller.totalSalaryDebt.value)} so\'m',
                            style: TextStyle(
                              color: Colors.red[700],
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppConstants.paddingMedium),
                Expanded(
                  child: ListView.builder(
                    itemCount: sortedKeys.length,
                    itemBuilder: (context, index) {
                      final key = sortedKeys[index];
                      final salaries = groupedSalaries[key]!;
                      final totalAmount = salaries.fold(0.0, 
                        (sum, s) => sum + (s['amount'] as num).toDouble());
                      
                      return ExpansionTile(
                        title: Text(
                          salaries.first['period'],
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('${salaries.length} ta xodim'),
                        trailing: Text(
                          '${controller.formatCurrency(totalAmount)} so\'m',
                          style: TextStyle(
                            color: Colors.red[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        children: salaries.map((salary) {
                          return ListTile(
                            contentPadding: EdgeInsets.only(left: 60, right: 16),
                            leading: CircleAvatar(
                              backgroundColor: Colors.red.withOpacity(0.1),
                              radius: 16,
                              child: Icon(Icons.person, color: Colors.red[700], size: 16),
                            ),
                            title: Text(salary['staff_name']),
                            subtitle: Text(
                              '${salary['position']}${salary['phone'] != '' ? ' • ${salary['phone']}' : ''}',
                              style: TextStyle(fontSize: 12),
                            ),
                            trailing: Text(
                              '${controller.formatCurrency((salary['amount'] as num).toDouble())} so\'m',
                              style: TextStyle(
                                color: Colors.red[700],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),
              ],
            );
          }),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Yopish'),
          ),
        ],
      ),
    );
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    const months = [
      'Yanvar', 'Fevral', 'Mart', 'Aprel', 'May', 'Iyun',
      'Iyul', 'Avgust', 'Sentabr', 'Oktabr', 'Noyabr', 'Dekabr',
    ];
    return '${now.day} ${months[now.month - 1]}, ${now.year}';
  }
}