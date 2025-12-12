// lib/presentation/screens/dashboard/dashboard_screen.dart
// IZOH: Asosiy dashboard sahifasi. Statistika va umumiy ma'lumotlar.

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/dashboard_controller.dart';
import '../../widgets/sidebar.dart';
import '../../../config/constants.dart';

class DashboardScreen extends StatelessWidget {
  DashboardScreen({Key? key}) : super(key: key);

  final DashboardController controller = Get.put(DashboardController());

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
          // Sarlavha
          Text(
            'Dashboard',
            style: TextStyle(
              fontSize: AppConstants.fontSizeXXLarge,
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimaryColor,
            ),
          ),
          Spacer(),

          // Yangilash tugmasi
          IconButton(
            onPressed: () => controller.refreshData(),
            icon: Icon(Icons.refresh),
            tooltip: 'Yangilash',
          ),

          SizedBox(width: AppConstants.paddingSmall),

          // Sana
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppConstants.paddingMedium,
              vertical: AppConstants.paddingSmall,
            ),
            decoration: BoxDecoration(
              color: AppConstants.backgroundLight,
              borderRadius: BorderRadius.circular(
                AppConstants.borderRadiusMedium,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: AppConstants.iconSizeSmall,
                  color: AppConstants.textSecondaryColor,
                ),
                SizedBox(width: AppConstants.paddingSmall),
                Text(
                  _getCurrentDate(),
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeMedium,
                    color: AppConstants.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
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
          // Statistika kartochkalari
          _buildStatisticsCards(),

          SizedBox(height: AppConstants.paddingLarge),

          // Grafik va qo'shimcha ma'lumotlar
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Chap taraf - Oylik daromad grafigi
              Expanded(flex: 2, child: _buildRevenueChart()),

              SizedBox(width: AppConstants.paddingLarge),

              // O'ng taraf - So'nggi to'lovlar
              Expanded(flex: 1, child: _buildRecentPayments()),
            ],
          ),
        ],
      ),
    );
  }

  // Statistika kartochkalari
  Widget _buildStatisticsCards() {
    return Obx(
      () => Row(
        children: [
          // Bugungi daromad
          Expanded(
            child: _buildStatCard(
              title: 'Bugungi daromad',
              value:
                  '${controller.formatCurrency(controller.todayRevenue.value)} ${AppConstants.currency}',
              icon: Icons.trending_up,
              color: AppConstants.successColor,
              subtitle: '${controller.todayPaymentsCount.value} ta to\'lov',
            ),
          ),
          SizedBox(width: AppConstants.paddingMedium),

          // Oylik daromad
          Expanded(
            child: _buildStatCard(
              title: 'Oylik daromad',
              value:
                  '${controller.formatCurrency(controller.monthRevenue.value)} ${AppConstants.currency}',
              icon: Icons.calendar_month,
              color: AppConstants.primaryColor,
              subtitle: 'Joriy oy',
            ),
          ),
          SizedBox(width: AppConstants.paddingMedium),

          // Aktiv o'quvchilar
          Expanded(
            child: _buildStatCard(
              title: 'Aktiv o\'quvchilar',
              value: '${controller.activeStudents.value}',
              icon: Icons.school,
              color: AppConstants.infoColor,
              subtitle: 'Umumiy: ${controller.totalStudents.value}',
            ),
          ),
          SizedBox(width: AppConstants.paddingMedium),

          // Qarzdorlar
          Expanded(
            child: _buildStatCard(
              title: 'Qarzdorlar',
              value: '${controller.debtorStudents.value}',
              icon: Icons.warning_amber_rounded,
              color: AppConstants.warningColor,
              subtitle: 'To\'lov kutilmoqda',
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
    required String subtitle,
  }) {
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
                fontSize: AppConstants.fontSizeXXLarge,
                fontWeight: FontWeight.bold,
                color: AppConstants.textPrimaryColor,
              ),
            ),
            SizedBox(height: AppConstants.paddingSmall),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: AppConstants.fontSizeSmall,
                color: AppConstants.textLightColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Daromad grafigi (placeholder)
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
            Text(
              'Oylik daromad dinamikasi',
              style: TextStyle(
                fontSize: AppConstants.fontSizeLarge,
                fontWeight: FontWeight.bold,
                color: AppConstants.textPrimaryColor,
              ),
            ),
            SizedBox(height: AppConstants.paddingLarge),
            Container(
              height: 300,
              child: Center(
                child: Text(
                  'Grafik bu yerda ko\'rsatiladi\n(fl_chart paketi orqali)',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppConstants.textSecondaryColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // So'nggi to'lovlar
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
            Text(
              'So\'nggi to\'lovlar',
              style: TextStyle(
                fontSize: AppConstants.fontSizeLarge,
                fontWeight: FontWeight.bold,
                color: AppConstants.textPrimaryColor,
              ),
            ),
            SizedBox(height: AppConstants.paddingLarge),
            Container(
              height: 300,
              child: Center(
                child: Text(
                  'So\'nggi to\'lovlar ro\'yxati\nbu yerda ko\'rsatiladi',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppConstants.textSecondaryColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Joriy sanani olish
  String _getCurrentDate() {
    final now = DateTime.now();
    const months = [
      'Yanvar',
      'Fevral',
      'Mart',
      'Aprel',
      'May',
      'Iyun',
      'Iyul',
      'Avgust',
      'Sentabr',
      'Oktabr',
      'Noyabr',
      'Dekabr',
    ];
    return '${now.day} ${months[now.month - 1]}, ${now.year}';
  }
}
