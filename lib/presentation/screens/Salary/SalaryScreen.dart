import 'package:flutter/material.dart';
import 'package:flutter_application_1/presentation/controllers/SalaryController.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../config/constants.dart';
import '../../widgets/sidebar.dart';

class CompleteSalaryDesktopScreen extends StatelessWidget {
  CompleteSalaryDesktopScreen({Key? key}) : super(key: key);

  final SalaryController controller = Get.put(SalaryController());

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
                _buildModernHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Column(
                        children: [
                          _buildStatisticsCards(),
                          SizedBox(height: 24),
                          _buildModernTabs(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== ZAMONAVIY HEADER ====================
  Widget _buildModernHeader() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Color(0xFFF8F9FA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon va Title
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppConstants.primaryColor,
                  AppConstants.primaryColor.withOpacity(0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppConstants.primaryColor.withOpacity(0.3),
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Icon(
              Icons.account_balance_wallet,
              color: Colors.white,
              size: 32,
            ),
          ),
          SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Maosh Boshqaruvi',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 4),
                Obx(
                  () => Text(
                    controller.getPeriodString(),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Filters
          _buildModernFilters(),
        ],
      ),
    );
  }

  Widget _buildModernFilters() {
    return Row(
      children: [
        // Filial
        Obx(
          () => _modernDropdown(
            value: controller.selectedBranchId.value,
            label: 'Filial',
            icon: Icons.business,
            items: controller.branches
                .map(
                  (b) => DropdownMenuItem(
                    value: b['id'] as String,
                    child: Text(b['name'], overflow: TextOverflow.ellipsis),
                  ),
                )
                .toList(),
            onChanged: controller.changeBranch,
            width: 200,
          ),
        ),
        SizedBox(width: 12),
        // Oy
        Obx(
          () => _modernDropdown(
            value: controller.selectedMonth.value,
            label: 'Oy',
            icon: Icons.calendar_month,
            items: List.generate(
              12,
              (i) => DropdownMenuItem(
                value: i + 1,
                child: Text(
                  [
                    'Yan',
                    'Fev',
                    'Mar',
                    'Apr',
                    'May',
                    'Iyun',
                    'Iyul',
                    'Avg',
                    'Sen',
                    'Okt',
                    'Noy',
                    'Dek',
                  ][i],
                ),
              ),
            ),
            onChanged: (v) =>
                controller.changePeriod(v!, controller.selectedYear.value),
            width: 130,
          ),
        ),
        SizedBox(width: 12),
        // Yil
        Obx(
          () => _modernDropdown(
            value: controller.selectedYear.value,
            label: 'Yil',
            icon: Icons.event,
            items: List.generate(
              5,
              (i) => DropdownMenuItem(
                value: DateTime.now().year - 2 + i,
                child: Text('${DateTime.now().year - 2 + i}'),
              ),
            ),
            onChanged: (v) =>
                controller.changePeriod(controller.selectedMonth.value, v!),
            width: 130,
          ),
        ),
      ],
    );
  }

  Widget _modernDropdown<T>({
    required T? value,
    required String label,
    required IconData icon,
    required List<DropdownMenuItem<T>> items,
    required Function(T?) onChanged,
    required double width,
  }) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<T>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20, color: AppConstants.primaryColor),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: InputBorder.none,
          labelStyle: TextStyle(fontSize: 13),
        ),
        items: items,
        onChanged: onChanged,
        dropdownColor: Colors.white,
      ),
    );
  }

  // ==================== STATISTIKA CARDS ====================
  Widget _buildStatisticsCards() {
    return Obx(
      () => Column(
        children: [
          // Asosiy 4 ta card
          Row(
            children: [
              _modernStatCard(
                title: 'To\'langan',
                value: controller.totalPaid.value,
                icon: Icons.check_circle_rounded,
                color: Color(0xFF10B981),
                gradient: LinearGradient(
                  colors: [Color(0xFF10B981), Color(0xFF059669)],
                ),
                count: controller.paidCount.value,
              ),
              SizedBox(width: 20),
              _modernStatCard(
                title: 'Kutilmoqda',
                value: controller.totalUnpaid.value,
                icon: Icons.schedule_rounded,
                color: Color(0xFFF59E0B),
                gradient: LinearGradient(
                  colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                ),
                count: controller.unpaidCount.value,
              ),
              SizedBox(width: 20),
              _modernStatCard(
                title: 'Jami Gross',
                value: controller.totalGross.value,
                icon: Icons.trending_up_rounded,
                color: Color(0xFF6366F1),
                gradient: LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                ),
              ),
              SizedBox(width: 20),
              _modernStatCard(
                title: 'Chegirmalar',
                value: controller.totalDeductions.value,
                icon: Icons.trending_down_rounded,
                color: Color(0xFFEF4444),
                gradient: LinearGradient(
                  colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          // Qo'shimcha 3 ta kichik card
          Row(
            children: [
              Expanded(
                child: _miniStatCard(
                  title: 'Jami Xodimlar',
                  value: '${controller.salaryOperations.length}',
                  icon: Icons.people_rounded,
                  color: Color(0xFF8B5CF6),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _miniStatCard(
                  title: 'O\'rtacha Maosh',
                  value: controller.salaryOperations.isEmpty
                      ? '0'
                      : controller.formatCurrency(
                          controller.totalGross.value /
                              controller.salaryOperations.length,
                        ),
                  icon: Icons.calculate_rounded,
                  color: Color(0xFF06B6D4),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _miniStatCard(
                  title: 'To\'lov Foizi',
                  value: controller.salaryOperations.isEmpty
                      ? '0%'
                      : '${((controller.paidCount.value / controller.salaryOperations.length) * 100).toStringAsFixed(1)}%',
                  icon: Icons.pie_chart_rounded,
                  color: Color(0xFFEC4899),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _modernStatCard({
    required String title,
    required double value,
    required IconData icon,
    required Color color,
    required Gradient gradient,
    int? count,
    String? trend,
  }) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.1), width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 20,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: gradient,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 28),
                ),
                if (trend != null)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: trend.startsWith('+')
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      trend,
                      style: TextStyle(
                        color: trend.startsWith('+')
                            ? Colors.green
                            : Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              controller.formatCurrency(value),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            if (count != null) ...[
              SizedBox(height: 4),
              Text(
                '$count ta to\'lov',
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _miniStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== ZAMONAVIY TABS ====================
  Widget _buildModernTabs() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              _modernTabItem('Ro\'yxat', 'list', Icons.view_list_rounded),
              _modernTabItem('Hisoblash', 'calculate', Icons.calculate_rounded),
              _modernTabItem('Tarix', 'history', Icons.history_rounded),
              _modernTabItem(
                'Avanslar',
                'advances',
                Icons.monetization_on_rounded,
              ),
              _modernTabItem('Qarzlar', 'loans', Icons.account_balance_rounded),
            ],
          ),
        ),
        SizedBox(height: 24),
        Obx(() => _buildTabContent()),
      ],
    );
  }

  Widget _modernTabItem(String title, String id, IconData icon) {
    return Expanded(
      child: Obx(() {
        final active = controller.currentView.value == id;
        return InkWell(
          onTap: () => controller.changeView(id),
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              gradient: active
                  ? LinearGradient(
                      colors: [
                        AppConstants.primaryColor,
                        AppConstants.primaryColor.withOpacity(0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              borderRadius: BorderRadius.circular(12),
              boxShadow: active
                  ? [
                      BoxShadow(
                        color: AppConstants.primaryColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: active ? Colors.white : Colors.grey[600],
                ),
                SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    color: active ? Colors.white : Colors.grey[600],
                    fontWeight: active ? FontWeight.bold : FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTabContent() {
    switch (controller.currentView.value) {
      case 'list':
        return _buildListView();
      case 'calculate':
        return _buildCalculateView();
      case 'history':
        return _buildHistoryView();
      case 'advances':
        return _buildAdvancesView();
      case 'loans':
        return _buildLoansView();
      default:
        return _buildListView();
    }
  }

  // ==================== LIST VIEW ====================
   Widget _buildListView() {
    return Column(
      children: [
        _buildModernSearchBar(),
        SizedBox(height: 20),
        Obx(() {
          if (controller.isLoading.value) {
            return Center(child: CircularProgressIndicator());
          }
          if (controller.filteredOperations.isEmpty) {
            return _modernEmptyState('Ma\'lumot yo\'q', Icons.inbox_rounded);
          }
          return ListView.builder(
            shrinkWrap: true, // <--- MUHIM: O'zgartirildi
            physics: NeverScrollableScrollPhysics(), // <--- MUHIM: O'zgartirildi
            itemCount: controller.filteredOperations.length,
            itemBuilder: (context, index) => _modernSalaryCard(controller.filteredOperations[index]),
          );
        }),
      ],
    );
  }

  Widget _modernSalaryCard(Map<String, dynamic> op) {
    final staff = op['staff'];
    final isPaid = op['is_paid'] == true;

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isPaid
              ? Color(0xFF10B981).withOpacity(0.2)
              : Colors.grey.shade200,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppConstants.primaryColor,
                      AppConstants.primaryColor.withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppConstants.primaryColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: staff['photo_url'] != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          staff['photo_url'],
                          fit: BoxFit.cover,
                        ),
                      )
                    : Center(
                        child: Text(
                          staff['first_name'][0].toUpperCase(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              ),
              SizedBox(width: 16),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${staff['first_name']} ${staff['last_name']}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.work_outline_rounded,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        SizedBox(width: 4),
                        Text(
                          staff['position'] ?? '-',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                        if (staff['phone'] != null) ...[
                          SizedBox(width: 12),
                          Icon(
                            Icons.phone_rounded,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          SizedBox(width: 4),
                          Text(
                            staff['phone'],
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              // Status Badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isPaid
                        ? [Color(0xFF10B981), Color(0xFF059669)]
                        : [Color(0xFFF59E0B), Color(0xFFD97706)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: (isPaid ? Color(0xFF10B981) : Color(0xFFF59E0B))
                          .withOpacity(0.3),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      isPaid
                          ? Icons.check_circle_rounded
                          : Icons.schedule_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    SizedBox(width: 6),
                    Text(
                      isPaid ? 'To\'langan' : 'Kutilmoqda',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          // Financial Details
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _financeRow(
                  'Asosiy maosh',
                  op['base_amount'],
                  Icons.attach_money_rounded,
                ),
                if ((op['bonus_amount'] ?? 0) > 0)
                  _financeRow(
                    'Bonus',
                    op['bonus_amount'],
                    Icons.add_circle_outline_rounded,
                    color: Colors.green,
                  ),
                if ((op['penalty_amount'] ?? 0) > 0)
                  _financeRow(
                    'Jarima',
                    op['penalty_amount'],
                    Icons.remove_circle_outline_rounded,
                    color: Colors.red,
                    isNegative: true,
                  ),
                if ((op['advance_deduction'] ?? 0) > 0)
                  _financeRow(
                    'Avans',
                    op['advance_deduction'],
                    Icons.money_off_rounded,
                    color: Colors.orange,
                    isNegative: true,
                  ),
                if ((op['loan_deduction'] ?? 0) > 0)
                  _financeRow(
                    'Qarz',
                    op['loan_deduction'],
                    Icons.account_balance_rounded,
                    color: Colors.purple,
                    isNegative: true,
                  ),
                Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.account_balance_wallet_rounded,
                          color: Colors.green[700],
                          size: 24,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'TO\'LANADIGAN',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                    Text(
                      controller.formatCurrency(op['net_amount']),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showDetailsDialog(op),
                  icon: Icon(Icons.visibility_rounded, size: 18),
                  label: Text('Batafsil'),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: AppConstants.primaryColor),
                    foregroundColor: AppConstants.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),
              if (!isPaid)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _showPaymentSourceDialog(op);
                    },
                    icon: Icon(Icons.payment_rounded, size: 18),
                    label: Text('To\'lash'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              if (isPaid)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showEditDialog(op),
                    icon: Icon(Icons.edit_rounded, size: 18),
                    label: Text('Tahrirlash'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: AppConstants.primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModernSearchBar() {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Xodim nomi bo\'yicha qidiruv...',
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: AppConstants.primaryColor,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
              onChanged: controller.search,
            ),
          ),
        ),
        SizedBox(width: 16),
        Obx(
          () => Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                _filterChip('Barchasi', 'all'),
                _filterChip('To\'langan', 'paid'),
                _filterChip('Kutilmoqda', 'unpaid'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _filterChip(String label, String value) {
    final active = controller.selectedStatus.value == value;
    return InkWell(
      onTap: () => controller.changeStatusFilter(value),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          gradient: active
              ? LinearGradient(
                  colors: [
                    AppConstants.primaryColor,
                    AppConstants.primaryColor.withOpacity(0.8),
                  ],
                )
              : null,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : Colors.grey[700],
            fontWeight: active ? FontWeight.bold : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _financeRow(
    String label,
    dynamic value,
    IconData icon, {
    Color? color,
    bool isNegative = false,
  }) {
    final amount = (value as num?)?.toDouble() ?? 0.0;
    if (amount == 0) return SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color ?? Colors.grey[700]),
              SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(fontSize: 13, color: Colors.grey[700]),
              ),
            ],
          ),
          Text(
            '${isNegative ? '-' : ''}${controller.formatCurrency(amount)}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color ?? Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== DETALS DIALOG ====================
  void _showDetailsDialog(Map<String, dynamic> op) {
    final staff = op['staff'];
    final isPaid = op['is_paid'] == true;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          width: 600,
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Avatar va Ism
              Row(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppConstants.primaryColor,
                          AppConstants.primaryColor.withOpacity(0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: staff['photo_url'] != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.network(
                              staff['photo_url'],
                              fit: BoxFit.cover,
                            ),
                          )
                        : Center(
                            child: Text(
                              staff['first_name'][0].toUpperCase(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${staff['first_name']} ${staff['last_name']}',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          staff['position'] ?? '',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isPaid
                            ? [Color(0xFF10B981), Color(0xFF059669)]
                            : [Color(0xFFF59E0B), Color(0xFFD97706)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isPaid ? 'TO\'LANGAN' : 'KUTILMOQDA',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),

              // Malumotlar
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    // Soatlik xodim uchun qo'shimcha ma'lumot
                    if (op['expected_hours_per_month'] != null &&
                        op['expected_hours_per_month'] > 0) ...[
                      _detailRow(
                        'Ishlashi kerak edi',
                        '${op['expected_hours_per_month']} soat (100%)',
                        icon: Icons.schedule,
                      ),
                      _detailRow(
                        'Haqiqatda ishladi',
                        '${op['actual_worked_hours'] ?? op['worked_hours']} soat',
                        icon: Icons.access_time,
                      ),
                      _detailRow(
                        'Ishlagan foizi',
                        '${((op['actual_worked_hours'] ?? op['worked_hours']) / op['expected_hours_per_month'] * 100).toStringAsFixed(1)}%',
                        icon: Icons.percent,
                        color:
                            (op['actual_worked_hours'] ?? op['worked_hours']) >=
                                op['expected_hours_per_month']
                            ? Colors.green
                            : Colors.orange,
                      ),
                      Divider(height: 24),
                    ],

                    _detailRow('Asosiy Maosh', op['base_amount']),
                    if ((op['bonus_amount'] ?? 0) > 0)
                      _detailRow(
                        'Bonus',
                        op['bonus_amount'],
                        color: Colors.green,
                        prefix: '+',
                      ),
                    if ((op['penalty_amount'] ?? 0) > 0)
                      _detailRow(
                        'Jarima',
                        op['penalty_amount'],
                        color: Colors.red,
                        prefix: '-',
                      ),
                    if ((op['advance_deduction'] ?? 0) > 0)
                      _detailRow(
                        'Avans',
                        op['advance_deduction'],
                        color: Colors.orange,
                        prefix: '-',
                      ),
                    if ((op['loan_deduction'] ?? 0) > 0)
                      _detailRow(
                        'Qarz',
                        op['loan_deduction'],
                        color: Colors.purple,
                        prefix: '-',
                      ),

                    Divider(height: 24, thickness: 2),

                    _detailRow(
                      'TO\'LANADIGAN SUMMA',
                      op['net_amount'],
                      isBold: true,
                      fontSize: 20,
                      color: Colors.green[700],
                    ),

                    if (isPaid && op['paid_at'] != null) ...[
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 16,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'To\'langan: ${DateFormat('dd.MM.yyyy HH:mm').format(DateTime.parse(op['paid_at']))}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      if (op['payment_source'] != null)
                        Text(
                          'Manba: ${op['payment_source']}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ],
                ),
              ),

              SizedBox(height: 24),

              // Tugmalar
              Row(
                children: [
                  if (!isPaid) ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        child: Text('Yopish'),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Get.back();
                          _showPaymentSourceDialog(op);
                        },
                        icon: Icon(Icons.payment),
                        label: Text('TO\'LASH'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                  if (isPaid) ...[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Get.back();
                          _confirmCancel(op);
                        },
                        icon: Icon(Icons.undo),
                        label: Text('Bekor qilish'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          padding: EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Get.back();
                          _showEditDialog(op);
                        },
                        icon: Icon(Icons.edit),
                        label: Text('Tahrirlash'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConstants.primaryColor,
                          padding: EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(
    String label,
    dynamic value, {
    Color? color,
    bool isBold = false,
    double fontSize = 14,
    String prefix = '',
    IconData? icon,
  }) {
    final val = (value is num) ? value.toDouble() : 0.0;
    if (val == 0 && !isBold && value is! String) return SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: color ?? Colors.grey[700]),
                SizedBox(width: 8),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          Text(
            value is String
                ? value
                : '$prefix${controller.formatCurrency(val)}',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: color ?? Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== TO'LOV MANBAI DIALOG ====================
  void _showPaymentSourceDialog(Map<String, dynamic> op) {
    String? selectedSourceId;
    String? selectedSourceName;

    showDialog(
      context: Get.context!,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Container(
            width: 500,
            padding: EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.account_balance_wallet,
                  size: 64,
                  color: AppConstants.primaryColor,
                ),
                SizedBox(height: 16),
                Text(
                  'To\'lov Manbaini Tanlang',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Jami: ${controller.formatCurrency(op['net_amount'])}',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.green[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 24),

                // Kassa tanlash
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Kassa / Hamyon',
                      prefixIcon: Icon(
                        Icons.account_balance,
                        color: AppConstants.primaryColor,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                    ),
                    items: controller.cashRegisters.map((s) {
                      final balance = s['balance'] != null
                          ? ' (${NumberFormat('#,###').format(s['balance'])} so\'m)'
                          : ' (Cheksiz)';
                      return DropdownMenuItem(
                        value: s['id'] as String,
                        child: Text(
                          '${s['name']}$balance',
                          style: TextStyle(fontSize: 14),
                        ),
                      );
                    }).toList(),
                    onChanged: (v) {
                      setState(() {
                        selectedSourceId = v;
                        selectedSourceName = controller.cashRegisters
                            .firstWhere((s) => s['id'] == v)['name'];
                      });
                    },
                  ),
                ),

                SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Bekor qilish'),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: selectedSourceId == null
                            ? null
                            : () {
                                Navigator.pop(context);
                                controller.paySalary(
                                  operationId: op['id'],
                                  amount: (op['net_amount'] as num).toDouble(),
                                  sourceId: selectedSourceId!,
                                  sourceName: selectedSourceName!,
                                );
                              },
                        icon: Icon(Icons.check),
                        label: Text('To\'lash'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==================== TAHRIRLASH DIALOG ====================
  void _showEditDialog(Map<String, dynamic> op) {
    final baseController = TextEditingController(
      text: op['base_amount'].toString(),
    );
    final bonusController = TextEditingController(
      text: (op['bonus_amount'] ?? 0).toString(),
    );
    final penaltyController = TextEditingController(
      text: (op['penalty_amount'] ?? 0).toString(),
    );
    final notesController = TextEditingController(text: op['notes'] ?? '');

    showDialog(
      context: Get.context!,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          width: 500,
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Maoshni Tahrirlash',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 24),

              TextField(
                controller: baseController,
                decoration: InputDecoration(
                  labelText: 'Asosiy Maosh',
                  prefixIcon: Icon(Icons.attach_money),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16),

              TextField(
                controller: bonusController,
                decoration: InputDecoration(
                  labelText: 'Bonus',
                  prefixIcon: Icon(
                    Icons.add_circle_outline,
                    color: Colors.green,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16),

              TextField(
                controller: penaltyController,
                decoration: InputDecoration(
                  labelText: 'Jarima',
                  prefixIcon: Icon(
                    Icons.remove_circle_outline,
                    color: Colors.red,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16),

              TextField(
                controller: notesController,
                decoration: InputDecoration(
                  labelText: 'Izoh',
                  prefixIcon: Icon(Icons.note),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 2,
              ),

              SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Bekor qilish'),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        controller.updateSalary(
                          operationId: op['id'],
                          baseAmount: double.parse(baseController.text),
                          bonusAmount: double.parse(bonusController.text),
                          penaltyAmount: double.parse(penaltyController.text),
                          notes: notesController.text,
                        );
                      },
                      icon: Icon(Icons.save),
                      label: Text('Saqlash'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.primaryColor,
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== BEKOR QILISH TASDIQI ====================
  void _confirmCancel(Map<String, dynamic> op) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.warning_amber_rounded, size: 64, color: Colors.orange),
              SizedBox(height: 16),
              Text(
                'Diqqat!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Ushbu to\'lovni bekor qilmoqchimisiz?\nSumma kassaga qaytariladi.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
              SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      child: Text('Yo\'q'),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => controller.cancelPayment(op['id']),
                      child: Text('Ha, Bekor qilish'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== AVANS DIALOG ====================
  void _showAdvanceDialog() {
    if (controller.staffList.isEmpty) controller.loadStaffForCalculation();

    showDialog(
      context: Get.context!,
      builder: (context) => AdvanceDialog(
        staffList: controller.staffList,
        registers: controller.cashRegisters,
        onSave: (staffId, amount, month, year, sourceId, sourceName, note) {
          controller.giveAdvance(
            staffId: staffId,
            amount: amount,
            deductionMonth: month,
            deductionYear: year,
            sourceId: sourceId,
            sourceName: sourceName,
            comment: note,
          );
        },
      ),
    );
  }

  // Empty state va boshqa yordamchi widgetlar...
  Widget _modernEmptyState(String text, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey[300]),
          SizedBox(height: 16),
          Text(text, style: TextStyle(color: Colors.grey[600], fontSize: 16)),
        ],
      ),
    );
  }

  // Boshqa view'lar (calculate, history, advances, loans) uchun placeholder
  Widget _buildCalculateView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Maoshni Hisoblash", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => controller.calculateSalariesPreview(),
                  icon: Icon(Icons.calculate),
                  label: Text("Hozir Hisoblash"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white, padding: EdgeInsets.all(16)),
                ),
                SizedBox(width: 12),
                if(controller.calculationResults.isNotEmpty)
                ElevatedButton.icon(
                  onPressed: () => controller.saveCalculatedSalaries(),
                  icon: Icon(Icons.save),
                  label: Text("Bazaga Saqlash"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, padding: EdgeInsets.all(16)),
                ),
              ],
            )
          ],
        ),
        SizedBox(height: 20),
        controller.isCalculating.value 
          ? Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
          : controller.calculationResults.isEmpty
            ? Center(child: Padding(padding: EdgeInsets.all(20), child: Text("Hisoblash tugmasini bosing...", style: TextStyle(color: Colors.grey))))
            : ListView.builder(
                shrinkWrap: true, // <--- MUHIM
                physics: NeverScrollableScrollPhysics(), // <--- MUHIM
                itemCount: controller.calculationResults.length,
                itemBuilder: (context, index) {
                  final item = controller.calculationResults[index];
                  return Card(
                    margin: EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: CircleAvatar(child: Text(item['staff']['first_name'][0])),
                      title: Text("${item['staff']['first_name']} ${item['staff']['last_name']}"),
                      subtitle: Text("Ishladi: ${item['worked_days']} kun / ${item['worked_hours']} soat"),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text("Net: ${controller.formatCurrency(item['net_amount'])}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green)),
                          Text("Ushlanma: ${controller.formatCurrency(item['advance_deduction'] + item['loan_deduction'])}", style: TextStyle(fontSize: 12, color: Colors.red)),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ],
    );
  }
  Widget _buildHistoryView() {
    final paidOps = controller.salaryOperations
        .where((o) => o['is_paid'])
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "To'lovlar Tarixi",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),
        paidOps.isEmpty
            ? Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text("To'lovlar tarixi bo'sh"),
                ),
              )
            : ListView.builder(
                shrinkWrap: true, // <--- MUHIM: Balandligini o'zi oladi
                physics:
                    NeverScrollableScrollPhysics(), // <--- MUHIM: Ota scrollga xalaqit bermaydi
                itemCount: paidOps.length,
                itemBuilder: (context, index) {
                  final op = paidOps[index];
                  return Card(
                    child: ListTile(
                      leading: Icon(Icons.history, color: Colors.grey),
                      title: Text(
                        "${op['staff']['first_name']} ${op['staff']['last_name']}",
                      ),
                      subtitle: Text(
                        "${DateFormat('dd.MM.yyyy HH:mm').format(DateTime.parse(op['paid_at']))} | ${op['payment_source']}",
                      ),
                      trailing: Text(
                        controller.formatCurrency(
                          (op['net_amount'] as num).toDouble(),
                        ),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  );
                },
              ),
      ],
    );
  }

   Widget _buildAdvancesView() {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton.icon(
            onPressed: () => _showAdvanceDialog(),
            icon: Icon(Icons.add), 
            label: Text("Avans Berish"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white, padding: EdgeInsets.all(16)),
          ),
        ),
        SizedBox(height: 16),
        controller.advancesList.isEmpty
          ? Center(child: Padding(padding: EdgeInsets.all(20), child: Text("Avanslar yo'q")))
          : ListView.builder(
              shrinkWrap: true, // <--- MUHIM
              physics: NeverScrollableScrollPhysics(), // <--- MUHIM
              itemCount: controller.advancesList.length,
              itemBuilder: (context, index) {
                final adv = controller.advancesList[index];
                bool deducted = adv['is_deducted'] ?? false;
                return Card(
                  child: ListTile(
                    leading: Icon(Icons.monetization_on, color: Colors.orange),
                    title: Text("${adv['staff']['first_name']} ${adv['staff']['last_name']}"),
                    subtitle: Text("${adv['deduction_month']}/${adv['deduction_year']} oyligidan"),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(controller.formatCurrency((adv['amount'] as num).toDouble()), style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(deducted ? "USHLAB QOLINDI" : "OCHIQ", style: TextStyle(color: deducted ? Colors.green : Colors.red, fontSize: 11, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                );
              },
            ),
      ],
    );
  }
    Widget _buildLoansView() { // Context argumenti olib tashlandi
    return Column(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton.icon(
            // O'ZGARTIRILDI: context o'rniga Get.context!
            onPressed: () => _showLoanDialog(Get.context!),
            icon: Icon(Icons.add),
            label: Text("Qarz Berish"),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                padding: EdgeInsets.all(16)),
          ),
        ),
        SizedBox(height: 16),
        // ... (List qismi o'zgarishsiz qoladi) ...
         controller.loansList.isEmpty
          ? Center(child: Padding(padding: EdgeInsets.all(20), child: Text("Qarzlar yo'q")))
          : ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: controller.loansList.length,
              itemBuilder: (context, index) {
                final loan = controller.loansList[index];
                bool settled = loan['is_settled'] ?? false;
                return Card(
                  child: ListTile(
                    leading: Icon(Icons.account_balance, color: Colors.purple),
                    title: Text("${loan['staff']['first_name']} ${loan['staff']['last_name']}"),
                    subtitle: Text("Oylik to'lov: ${controller.formatCurrency((loan['monthly_deduction'] as num).toDouble())}"),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text("Qoldiq: ${controller.formatCurrency((loan['remaining_amount'] as num).toDouble())}", style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(settled ? "YOPILGAN" : "FAOL", style: TextStyle(color: settled ? Colors.green : Colors.blue, fontSize: 11, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                );
              },
            ),
      ],
    );
  }
  // DIALOGLAR:
  // UI faylingizda _showLoanDialog funksiyasi allaqachon bo'lishi kerak.
  // Agar yo'q bo'lsa, quyidagicha qo'shing:

    void _showLoanDialog(BuildContext context) {
    // Agar ro'yxat bo'sh bo'lsa yuklashni so'raymiz
    if (controller.staffList.isEmpty) controller.loadStaffForCalculation();
    
    String? sId;
    double? amt;
    double? mon;
    String? srcId;
    String note = '';

    Get.defaultDialog(
      title: "Qarz Berish",
      titleStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      contentPadding: EdgeInsets.all(20),
      radius: 16,
      content: SizedBox( // O'lcham berish uchun
        width: 400, 
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 1. XODIM TANLASH (Obx ichida bo'lishi shart)
              Obx(() => DropdownButtonFormField<String>(
                isExpanded: true,
                items: controller.staffList
                    .map(
                      (s) => DropdownMenuItem(
                        value: s['id'] as String,
                        child: Text("${s['first_name']} ${s['last_name']}"),
                      ),
                    )
                    .toList(),
                onChanged: (v) => sId = v,
                decoration: InputDecoration(
                  labelText: "Xodim",
                  prefixIcon: Icon(Icons.person, color: Colors.purple),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              )),
              SizedBox(height: 16),
              
              // 2. JAMI SUMMA
              TextField(
                decoration: InputDecoration(
                  labelText: "Jami Summa",
                  prefixIcon: Icon(Icons.attach_money, color: Colors.purple),
                  suffixText: "so'm",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                keyboardType: TextInputType.number,
                onChanged: (v) => amt = double.tryParse(v),
              ),
              SizedBox(height: 16),
              
              // 3. OYLIK USHLANMA
              TextField(
                decoration: InputDecoration(
                  labelText: "Oylik Ushlanma (ixtiyoriy)",
                  prefixIcon: Icon(Icons.calendar_month, color: Colors.purple),
                  suffixText: "so'm",
                  hintText: "Har oy qancha ushlanadi",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                keyboardType: TextInputType.number,
                onChanged: (v) => mon = double.tryParse(v),
              ),
              SizedBox(height: 16),

              // 4. KASSA TANLASH
              DropdownButtonFormField<String>(
                isExpanded: true,
                items: controller.cashRegisters
                    .map(
                      (c) => DropdownMenuItem(
                        value: c['id'] as String,
                        child: Text(c['name']),
                      ),
                    )
                    .toList(),
                onChanged: (v) => srcId = v,
                decoration: InputDecoration(
                  labelText: "Kassa / Hamyon",
                  prefixIcon: Icon(Icons.account_balance_wallet, color: Colors.purple),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              SizedBox(height: 16),

              // 5. IZOH
              TextField(
                decoration: InputDecoration(
                  labelText: "Izoh",
                  prefixIcon: Icon(Icons.note, color: Colors.purple),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onChanged: (v) => note = v,
              ),
            ],
          ),
        ),
      ),
      textConfirm: "Saqlash",
      textCancel: "Bekor qilish",
      confirmTextColor: Colors.white,
      buttonColor: Colors.purple,
      cancelTextColor: Colors.purple,
      onConfirm: () {
        // VALIDATSIYA: Ma'lumotlar to'liq ekanligini tekshiramiz
        if (sId != null && amt != null && srcId != null) {
          Get.back(); // Dialogni yopish
          
          controller.giveLoan(
            staffId: sId!,
            totalAmount: amt!,
            monthlyDeduction: mon ?? 0, // Agar kiritilmasa 0 ketadi
            startMonth: controller.selectedMonth.value,
            startYear: controller.selectedYear.value,
            sourceId: srcId!,
            reason: note,
          );
          
          // Muvaffaqiyatli xabar
          Get.snackbar(
            "Muvaffaqiyat", 
            "Qarz muvaffaqiyatli rasmiylashtirildi",
            backgroundColor: Colors.green,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM
          );
        } else {
          // XATOLIK XABARI: Agar maydonlar to'ldirilmagan bo'lsa
          Get.snackbar(
            "Xatolik", 
            "Iltimos, Xodim, Summa va Kassani tanlang!",
            backgroundColor: Colors.red,
            colorText: Colors.white,
             snackPosition: SnackPosition.BOTTOM
          );
        }
      },
    );
  }}

// ==================== ALOHIDA DIALOGLAR ====================
class AdvanceDialog extends StatefulWidget {
  final List<Map<String, dynamic>> staffList;
  final List<Map<String, dynamic>> registers;
  final Function(String, double, int, int, String, String, String) onSave;

  const AdvanceDialog({
    required this.staffList,
    required this.registers,
    required this.onSave,
  });

  @override
  _AdvanceDialogState createState() => _AdvanceDialogState();
}

class _AdvanceDialogState extends State<AdvanceDialog> {
  final _formKey = GlobalKey<FormState>();
  String? staffId;
  double? amount;
  int month = DateTime.now().month;
  int year = DateTime.now().year;
  String? sourceId;
  String? sourceName;
  String comment = '';

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: 500,
        padding: EdgeInsets.all(32),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.monetization_on, size: 64, color: Colors.orange),
              SizedBox(height: 16),
              Text(
                'Avans Berish',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 24),

              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Xodim',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: widget.staffList
                    .map(
                      (s) => DropdownMenuItem(
                        value: s['id'] as String,
                        child: Text('${s['first_name']} ${s['last_name']}'),
                      ),
                    )
                    .toList(),
                onChanged: (v) => staffId = v,
                validator: (v) => v == null ? 'Tanlang' : null,
              ),
              SizedBox(height: 16),

              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Summa',
                  prefixIcon: Icon(Icons.attach_money),
                  suffixText: 'so\'m',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (v) => (v == null || double.tryParse(v) == null)
                    ? 'Kiriting'
                    : null,
                onSaved: (v) => amount = double.parse(v!),
              ),
              SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: month,
                      decoration: InputDecoration(
                        labelText: 'Qaysi oydan ushlanadi',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: List.generate(
                        12,
                        (i) => DropdownMenuItem(
                          value: i + 1,
                          child: Text('${i + 1}-oy'),
                        ),
                      ),
                      onChanged: (v) => month = v!,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: year,
                      decoration: InputDecoration(
                        labelText: 'Yil',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: DateTime.now().year,
                          child: Text('${DateTime.now().year}'),
                        ),
                      ],
                      onChanged: (v) => year = v!,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),

              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'To\'lov Manbai',
                  prefixIcon: Icon(Icons.account_balance_wallet),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: widget.registers
                    .map(
                      (s) => DropdownMenuItem(
                        value: s['id'] as String,
                        child: Text(s['name']),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  sourceId = v;
                  sourceName = widget.registers.firstWhere(
                    (s) => s['id'] == v,
                  )['name'];
                },
                validator: (v) => v == null ? 'Tanlang' : null,
              ),
              SizedBox(height: 16),

              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Izoh (Ixtiyoriy)',
                  prefixIcon: Icon(Icons.note),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 2,
                onSaved: (v) => comment = v ?? '',
              ),

              SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Bekor qilish'),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          widget.onSave(
                            staffId!,
                            amount!,
                            month,
                            year,
                            sourceId!,
                            sourceName!,
                            comment,
                          );
                          Navigator.pop(context);
                        }
                      },
                      icon: Icon(Icons.save),
                      label: Text('Saqlash'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
