// lib/presentation/screens/expenses/expenses_screen_v2.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_1/presentation/controllers/expenses_controller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../widgets/sidebar.dart';
import '../../widgets/salary_calculation_dialog.dart';
import '../../widgets/advance_loan_dialogs.dart';
import '../../../config/constants.dart';

class ExpensesScreenV2 extends StatelessWidget {
  ExpensesScreenV2({Key? key}) : super(key: key);

  final controller = Get.put(ExpensesControllerV2());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
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
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              color: AppConstants.primaryColor,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Yuklanmoqda...',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return RefreshIndicator(
                      onRefresh: controller.refresh,
                      child: SingleChildScrollView(
                        physics: AlwaysScrollableScrollPhysics(),
                        child: Column(
                          children: [
                            _buildStatisticsCards(),
                            _buildTabBar(),
                            _buildTabContent(),
                          ],
                        ),
                      ),
                    );
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
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF667eea).withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 10),
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
              Icons.receipt_long_rounded,
              color: Colors.white,
              size: 40,
            ),
          ),
          SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Xarajatlar boshqaruvi',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Barcha moliyaviy operatsiyalarni boshqaring',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          _buildQuickActionButton(
            icon: Icons.add_circle_outline,
            label: 'Xarajat',
            onTap: _showAddExpenseDialog,
          ),
          SizedBox(width: 12),
          _buildQuickActionButton(
            icon: Icons.payments_outlined,
            label: 'Maosh',
            onTap: _showSalaryDialog,
          ),
          SizedBox(width: 12),
          _buildQuickActionButton(
            icon: Icons.money_off_outlined,
            label: 'Avans',
            onTap: _showAdvanceDialog,
          ),
          SizedBox(width: 12),
          _buildQuickActionButton(
            icon: Icons.account_balance_wallet_outlined,
            label: 'Qarz',
            onTap: _showLoanDialog,
          ),
          SizedBox(width: 12),
          IconButton(
            onPressed: controller.refresh,
            icon: Icon(Icons.refresh, color: Colors.white, size: 28),
            tooltip: 'Yangilash',
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsCards() {
    return Container(
      padding: EdgeInsets.all(24),
      child: Obx(
        () => Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _buildStatCard(
              title: 'Bugungi xarajatlar',
              value: controller.formatCurrency(controller.todayExpenses.value),
              unit: 'so\'m',
              icon: Icons.today,
              color: Colors.blue,
              subtitle: DateFormat(
                'dd MMMM, yyyy',
                'uz',
              ).format(DateTime.now()),
            ),
            _buildStatCard(
              title: 'Haftalik xarajatlar',
              value: controller.formatCurrency(controller.weekExpenses.value),
              unit: 'so\'m',
              icon: Icons.date_range,
              color: Colors.teal,
              subtitle: 'Joriy hafta',
            ),
            _buildStatCard(
              title: 'Oylik xarajatlar',
              value: controller.formatCurrency(controller.monthExpenses.value),
              unit: 'so\'m',
              icon: Icons.calendar_month,
              color: Colors.purple,
              subtitle: DateFormat('MMMM yyyy', 'uz').format(DateTime.now()),
            ),
            _buildStatCard(
              title: 'Jami maoshlar',
              value: controller.formatCurrency(controller.totalSalaries.value),
              unit: 'so\'m',
              icon: Icons.payments,
              color: Colors.green,
              subtitle: 'To\'langan maoshlar',
            ),
            _buildStatCard(
              title: 'Avanslar',
              value: controller.formatCurrency(controller.totalAdvances.value),
              unit: 'so\'m',
              icon: Icons.money_off,
              color: Colors.orange,
              subtitle: 'Ushlab qolinmagan',
            ),
            _buildStatCard(
              title: 'Qarzlar',
              value: controller.formatCurrency(controller.totalLoans.value),
              unit: 'so\'m',
              icon: Icons.account_balance,
              color: Colors.red,
              subtitle: 'Qaytarilmagan',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    String? unit,
    required IconData icon,
    required Color color,
    String? subtitle,
  }) {
    return Container(
      width: 280,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.2), width: 2),
      ),
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
                child: Icon(icon, color: color, size: 28),
              ),
              Spacer(),
            ],
          ),
          SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (unit != null) ...[
                SizedBox(width: 6),
                Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Text(
                    unit,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ),
              ],
            ],
          ),
          if (subtitle != null) ...[
            SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24),
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Row(
        children: [
          _buildTab('Umumiy xarajatlar', 0, Icons.list_alt),
          _buildTab('Xodimlar maoshi', 1, Icons.payments),
          _buildTab('Avanslar', 2, Icons.money_off),
          _buildTab('Qarzlar', 3, Icons.account_balance),
          _buildTab('Kassalar', 4, Icons.account_balance_wallet),
        ],
      ),
    );
  }

  Widget _buildTab(String label, int index, IconData icon) {
    return Obx(() {
      final isSelected = controller.selectedTab.value == index;
      return Expanded(
        child: InkWell(
          onTap: () => controller.selectedTab.value = index,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppConstants.primaryColor
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isSelected ? Colors.white : Colors.grey[600],
                ),
                SizedBox(width: 8),
                Flexible(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: isSelected ? Colors.white : Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildTabContent() {
    return Container(
      margin: EdgeInsets.all(24),
      child: Obx(() {
        switch (controller.selectedTab.value) {
          case 0:
            return _buildExpensesTab();
          case 1:
            return _buildSalariesTab();
          case 2:
            return _buildAdvancesTab();
          case 3:
            return _buildLoansTab();
          case 4:
            return _buildCashRegistersTab();
          default:
            return _buildExpensesTab();
        }
      }),
    );
  }

  // UMUMIY XARAJATLAR TAB
  Widget _buildExpensesTab() {
    return Column(
      children: [_buildFilters(), SizedBox(height: 16), _buildExpensesList()],
    );
  }

  Widget _buildFilters() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[300]!),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    onChanged: (value) {
                      controller.searchQuery.value = value;
                      controller.applyFilters();
                    },
                    decoration: InputDecoration(
                      hintText: 'Qidirish...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Obx(
                    () => DropdownButtonFormField<String>(
                      value: controller.selectedCategory.value,
                      isExpanded: true, // <--- SHUNI QO'SHING
                      decoration: InputDecoration(
                        labelText: 'Kategoriya',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      items: controller.categories.map((cat) {
                        return DropdownMenuItem<String>(
                          value: cat['id'] as String,
                          child: Row(
                            children: [
                              Icon(
                                cat['icon'] as IconData,
                                size: 20,
                                color: cat['color'] as Color,
                              ),
                              SizedBox(width: 8),
                              // Flexible endi bexato ishlaydi, chunki isExpanded: true bor
                              Flexible(
                                child: Text(
                                  cat['name'] as String,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        controller.selectedCategory.value = value ?? 'all';
                        controller.applyFilters();
                      },
                    ),
                  ),
                ),
                SizedBox(width: 16),
                if (controller.branches.isNotEmpty)
                  Expanded(
                    child: Obx(
                      () => DropdownButtonFormField<String>(
                        value: controller.selectedBranch.value,
                        decoration: InputDecoration(
                          labelText: 'Filial',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        items: [
                          DropdownMenuItem(
                            value: 'all',
                            child: Text('Barcha filiallar'),
                          ),
                          ...controller.branches.map(
                            (branch) => DropdownMenuItem<String>(
                              value: branch['id'],
                              child: Text(branch['name']),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          controller.selectedBranch.value = value ?? 'all';
                          controller.applyFilters();
                        },
                      ),
                    ),
                  ),
                SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: _selectDateRange,
                  icon: Icon(Icons.date_range),
                  label: Text('Sana'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: controller.clearFilters,
                  icon: Icon(Icons.clear_all),
                  label: Text('Tozalash'),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpensesList() {
    return Obx(() {
      if (controller.expenses.isEmpty) {
        return _buildEmptyState(
          'Xarajatlar topilmadi',
          Icons.receipt_long_outlined,
        );
      }

      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey[300]!),
        ),
        child: Column(
          children: controller.expenses
              .map((expense) => _buildExpenseItem(expense))
              .toList(),
        ),
      );
    });
  }

  Widget _buildExpenseItem(Map<String, dynamic> expense) {
    final categoryId = expense['category'] ?? 'other';
    final category = controller.categories.firstWhere(
      (c) => c['id'] == categoryId,
      orElse: () => controller.categories.last,
    );

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (category['color'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              category['icon'] as IconData,
              color: category['color'] as Color,
              size: 28,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense['title'] ?? 'N/A',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: Colors.grey[600],
                    ),
                    SizedBox(width: 4),
                    Text(
                      expense['expense_date'] ?? '',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    if (expense['responsible_person'] != null) ...[
                      SizedBox(width: 16),
                      Icon(Icons.person, size: 14, color: Colors.grey[600]),
                      SizedBox(width: 4),
                      Text(
                        expense['responsible_person'],
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                    if (expense['branches'] != null) ...[
                      SizedBox(width: 16),
                      Icon(Icons.business, size: 14, color: Colors.grey[600]),
                      SizedBox(width: 4),
                      Text(
                        expense['branches']['name'] ?? '',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ],
                ),
                if (expense['description'] != null &&
                    expense['description'].toString().isNotEmpty) ...[
                  SizedBox(height: 4),
                  Text(
                    expense['description'],
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${controller.formatCurrency((expense['amount'] as num).toDouble())} so\'m',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: category['color'] as Color,
                ),
              ),
              if (expense['receipt_number'] != null) ...[
                SizedBox(height: 4),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Kvit: ${expense['receipt_number']}',
                    style: TextStyle(fontSize: 10, color: Colors.blue),
                  ),
                ),
              ],
            ],
          ),
          SizedBox(width: 8),
          PopupMenuButton(
            icon: Icon(Icons.more_vert, color: Colors.grey[600]),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: Row(
                  children: [
                    Icon(Icons.visibility, size: 18, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Ko\'rish'),
                  ],
                ),
                onTap: () => _showExpenseDetails(expense),
              ),
              PopupMenuItem(
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 18, color: Colors.red),
                    SizedBox(width: 8),
                    Text('O\'chirish', style: TextStyle(color: Colors.red)),
                  ],
                ),
                onTap: () => _confirmDeleteExpense(expense['id']),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // MAOSHLAR TAB
  Widget _buildSalariesTab() {
    return Obx(() {
      if (controller.salaryOperations.isEmpty) {
        return _buildEmptyState(
          'Maosh ma\'lumotlari topilmadi',
          Icons.payments,
        );
      }

      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey[300]!),
        ),
        child: Column(
          children: controller.salaryOperations
              .map((salary) => _buildSalaryItem(salary))
              .toList(),
        ),
      );
    });
  }

  Widget _buildSalaryItem(Map<String, dynamic> salary) {
    final staff = salary['staff'];
    final isPaid = salary['is_paid'] == true;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
        color: isPaid ? Colors.green.withOpacity(0.05) : null,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppConstants.primaryColor.withOpacity(0.1),
            child: Text(
              '${staff['first_name'][0]}${staff['last_name'][0]}'.toUpperCase(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppConstants.primaryColor,
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
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        staff['position'] ?? 'N/A',
                        style: TextStyle(fontSize: 11, color: Colors.blue),
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      '${salary['period_month']}-oy, ${salary['period_year']}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
                if (salary['worked_days'] != null ||
                    salary['worked_hours'] != null) ...[
                  SizedBox(height: 4),
                  Text(
                    salary['worked_hours'] != null
                        ? 'Ishlagan: ${salary['worked_hours']} soat'
                        : 'Ishlagan: ${salary['worked_days']} kun',
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${controller.formatCurrency((salary['net_amount'] as num).toDouble())} so\'m',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isPaid ? Colors.green : Colors.orange,
                ),
              ),
              SizedBox(height: 4),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (isPaid ? Colors.green : Colors.orange).withOpacity(
                    0.1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isPaid ? 'To\'langan' : 'Kutilmoqda',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isPaid ? Colors.green : Colors.orange,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // AVANSLAR TAB
  Widget _buildAdvancesTab() {
    return Obx(() {
      if (controller.staffAdvances.isEmpty) {
        return _buildEmptyState('Avanslar topilmadi', Icons.money_off);
      }

      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey[300]!),
        ),
        child: Column(
          children: controller.staffAdvances
              .map((advance) => _buildAdvanceItem(advance))
              .toList(),
        ),
      );
    });
  }

  Widget _buildAdvanceItem(Map<String, dynamic> advance) {
    final staff = advance['staff'];
    final isDeducted = advance['is_deducted'] == true;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.money_off, color: Colors.orange, size: 28),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${staff['first_name']} ${staff['last_name']}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 4),
                Text(
                  'Ushlab qolinadi: ${advance['deduction_month']}-oy, ${advance['deduction_year']}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                if (advance['reason'] != null &&
                    advance['reason'].toString().isNotEmpty) ...[
                  SizedBox(height: 4),
                  Text(
                    advance['reason'],
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${controller.formatCurrency((advance['amount'] as num).toDouble())} so\'m',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              SizedBox(height: 4),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: (isDeducted ? Colors.green : Colors.orange)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isDeducted ? 'Ushlab qolindi' : 'Kutilmoqda',
                  style: TextStyle(
                    fontSize: 10,
                    color: isDeducted ? Colors.green : Colors.orange,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // QARZLAR TAB
  Widget _buildLoansTab() {
    return Obx(() {
      if (controller.staffLoans.isEmpty) {
        return _buildEmptyState('Qarzlar topilmadi', Icons.account_balance);
      }

      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey[300]!),
        ),
        child: Column(
          children: controller.staffLoans
              .map((loan) => _buildLoanItem(loan))
              .toList(),
        ),
      );
    });
  }

  Widget _buildLoanItem(Map<String, dynamic> loan) {
    final staff = loan['staff'];
    final isSettled = loan['is_settled'] == true;
    final totalAmount = (loan['total_amount'] as num).toDouble();
    final remainingAmount = (loan['remaining_amount'] as num).toDouble();
    final progress = totalAmount > 0
        ? (totalAmount - remainingAmount) / totalAmount
        : 0.0;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.account_balance, color: Colors.red, size: 28),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${staff['first_name']} ${staff['last_name']}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      staff['position'] ?? 'N/A',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${controller.formatCurrency(remainingAmount)} so\'m',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Jami: ${controller.formatCurrency(totalAmount)} so\'m',
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'To\'lov jarayoni',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          '${(progress * 100).toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isSettled ? Colors.green : Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 16),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: (isSettled ? Colors.green : Colors.red).withOpacity(
                    0.1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isSettled ? 'To\'langan' : 'Aktiv',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isSettled ? Colors.green : Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // KASSALAR TAB
  Widget _buildCashRegistersTab() {
    return Obx(() {
      if (controller.cashRegisters.isEmpty) {
        return _buildEmptyState(
          'Kassalar topilmadi',
          Icons.account_balance_wallet,
        );
      }

      return Column(
        children: [
          _buildCashSummary(),
          SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: controller.cashRegisters
                .map((cash) => _buildCashRegisterCard(cash))
                .toList(),
          ),
        ],
      );
    });
  }

  Widget _buildCashSummary() {
    return Obx(
      () => Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[700]!, Colors.blue[500]!],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.3),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildCashSummaryItem(
                'Naqd pul',
                controller.totalCashBalance.value,
                Icons.payments,
              ),
            ),
            Container(width: 2, height: 60, color: Colors.white24),
            Expanded(
              child: _buildCashSummaryItem(
                'Plastik karta',
                controller.totalCardBalance.value,
                Icons.credit_card,
              ),
            ),
            Container(width: 2, height: 60, color: Colors.white24),
            Expanded(
              child: _buildCashSummaryItem(
                'O\'tkazma',
                controller.totalTransferBalance.value,
                Icons.account_balance,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCashSummaryItem(String label, double amount, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 32),
        SizedBox(height: 8),
        Text(label, style: TextStyle(fontSize: 14, color: Colors.white70)),
        SizedBox(height: 4),
        Text(
          '${controller.formatCurrency(amount)} so\'m',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildCashRegisterCard(Map<String, dynamic> cash) {
    final methods = {
      'cash': {
        'name': 'Naqd pul',
        'icon': Icons.payments,
        'color': Colors.green,
      },
      'card': {
        'name': 'Plastik karta',
        'icon': Icons.credit_card,
        'color': Colors.blue,
      },
      'transfer': {
        'name': 'O\'tkazma',
        'icon': Icons.account_balance,
        'color': Colors.purple,
      },
    };

    final method = methods[cash['payment_method']] ?? methods['cash']!;

    return Container(
      width: 320,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            (method['color'] as Color),
            (method['color'] as Color).withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (method['color'] as Color).withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  method['icon'] as IconData,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              Spacer(),
            ],
          ),
          SizedBox(height: 24),
          Text(
            method['name'] as String,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          SizedBox(height: 8),
          Text(
            '${controller.formatCurrency((cash['current_balance'] as num).toDouble())} so\'m',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.business,
                size: 14,
                color: Colors.white.withOpacity(0.8),
              ),
              SizedBox(width: 4),
              Flexible(
                child: Text(
                  cash['branches']?['name'] ?? 'N/A',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.8),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // DIALOGS
  void _showAddExpenseDialog() {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    final descriptionController = TextEditingController();
    final receiptController = TextEditingController();
    final responsibleController = TextEditingController();

    String selectedCategory = 'utilities';
    String? selectedCashRegister;
    DateTime selectedDate = DateTime.now();

    if (controller.cashRegisters.isNotEmpty) {
      selectedCashRegister = controller.cashRegisters.first['id'];
    }

    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.add_circle, color: AppConstants.primaryColor),
            SizedBox(width: 12),
            Text('Yangi xarajat qo\'shish'),
          ],
        ),
        content: Container(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: InputDecoration(
                    labelText: 'Kategoriya',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: controller.categories
                      .where((c) => c['id'] != 'all' && c['id'] != 'salary')
                      .map((cat) {
                        return DropdownMenuItem<String>(
                          value: cat['id'] as String,
                          child: Row(
                            children: [
                              Icon(
                                cat['icon'] as IconData,
                                size: 20,
                                color: cat['color'] as Color,
                              ),
                              SizedBox(width: 8),
                              Text(cat['name'] as String),
                            ],
                          ),
                        );
                      })
                      .toList(),
                  onChanged: (value) => selectedCategory = value!,
                ),
                SizedBox(height: 16),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Sarlavha *',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(Icons.title),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Summa (so\'m) *',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                ),
                SizedBox(height: 16),
                if (controller.cashRegisters.isNotEmpty)
                  DropdownButtonFormField<String>(
                    value: selectedCashRegister,
                    isExpanded: true, // <--- SHUNI QO'SHING
                    decoration: InputDecoration(
                      labelText: 'Kassa *',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: Icon(Icons.account_balance_wallet),
                    ),
                    items: controller.cashRegisters.map((cash) {
                      final balance = (cash['current_balance'] as num)
                          .toDouble();
                      return DropdownMenuItem<String>(
                        value: cash['id'],
                        child: Row(
                          children: [
                            // Expanded bu yerda ishlashi uchun tepadagi isExpanded: true kerak
                            Expanded(
                              child: Text(
                                '${cash['payment_method']} - ${cash['branches']?['name']}',
                                overflow: TextOverflow
                                    .ellipsis, // Matn sig'masa kesish uchun
                              ),
                            ),
                            SizedBox(width: 8), // Yopishib qolmasligi uchun
                            Text(
                              '${controller.formatCurrency(balance)} so\'m',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) => selectedCashRegister = value,
                  ),
                SizedBox(height: 16),
                TextField(
                  controller: responsibleController,
                  decoration: InputDecoration(
                    labelText: 'Mas\'ul shaxs',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: receiptController,
                  decoration: InputDecoration(
                    labelText: 'Kvitansiya raqami',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(Icons.receipt),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Izoh',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(Icons.note),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Bekor qilish')),
          ElevatedButton.icon(
            onPressed: () {
              if (titleController.text.isEmpty ||
                  amountController.text.isEmpty) {
                Get.snackbar(
                  'Xato',
                  'Barcha majburiy maydonlarni to\'ldiring',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
                return;
              }
              if (selectedCashRegister == null) {
                Get.snackbar(
                  'Xato',
                  'Kassani tanlang',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
                return;
              }

              controller.addExpense(
                category: selectedCategory,
                title: titleController.text,
                amount: double.parse(amountController.text),
                cashRegisterId: selectedCashRegister!,
                description: descriptionController.text.isEmpty
                    ? null
                    : descriptionController.text,
                receiptNumber: receiptController.text.isEmpty
                    ? null
                    : receiptController.text,
                responsiblePerson: responsibleController.text.isEmpty
                    ? null
                    : responsibleController.text,
                expenseDate: selectedDate,
              );

              Get.back();
            },
            icon: Icon(Icons.save),
            label: Text('Saqlash'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _showSalaryDialog() {
    Get.dialog(
      SalaryCalculationDialog(
        onCalculate: (salaryData) async {
          try {
            await controller.paySalary(salaryData);
          } catch (e) {
            Get.snackbar(
              'Xato',
              'Maosh to\'lashda xatolik: $e',
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          }
        },
      ),
    );
  }

  void _showAdvanceDialog() {
    Get.dialog(
      AdvanceDialog(
        onSubmit: (advanceData) async {
          try {
            await controller.giveAdvance(advanceData);
          } catch (e) {
            Get.snackbar(
              'Xato',
              'Avans berishda xatolik: $e',
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          }
        },
      ),
    );
  }

  void _showLoanDialog() {
    Get.dialog(
      LoanDialog(
        onSubmit: (loanData) async {
          try {
            await controller.giveLoan(loanData);
          } catch (e) {
            Get.snackbar(
              'Xato',
              'Qarz berishda xatolik: $e',
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          }
        },
      ),
    );
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: Get.context!,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: AppConstants.primaryColor,
            colorScheme: ColorScheme.light(primary: AppConstants.primaryColor),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      controller.startDate.value = picked.start;
      controller.endDate.value = picked.end;
      controller.applyFilters();
    }
  }

  void _showExpenseDetails(Map<String, dynamic> expense) {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.info_outline, color: AppConstants.primaryColor),
            SizedBox(width: 12),
            Text('Xarajat tafsilotlari'),
          ],
        ),
        content: Container(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow(
                'Kategoriya',
                controller.getCategoryName(expense['category']),
              ),
              _buildDetailRow('Sarlavha', expense['title']),
              _buildDetailRow(
                'Summa',
                '${controller.formatCurrency((expense['amount'] as num).toDouble())} so\'m',
              ),
              _buildDetailRow('Sana', expense['expense_date']),
              if (expense['responsible_person'] != null)
                _buildDetailRow('Mas\'ul shaxs', expense['responsible_person']),
              if (expense['receipt_number'] != null)
                _buildDetailRow('Kvitansiya', expense['receipt_number']),
              if (expense['description'] != null)
                _buildDetailRow('Izoh', expense['description']),
              if (expense['branches'] != null)
                _buildDetailRow('Filial', expense['branches']['name']),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Yopish')),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: TextStyle(color: Colors.grey[800])),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteExpense(String expenseId) {
    Future.delayed(Duration(milliseconds: 100), () {
      Get.dialog(
        AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.red),
              SizedBox(width: 12),
              Text('O\'chirishni tasdiqlang'),
            ],
          ),
          content: Text(
            'Ushbu xarajatni o\'chirishni xohlaysizmi? Pul kassaga qaytariladi.',
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text('Bekor qilish'),
            ),
            ElevatedButton(
              onPressed: () {
                Get.back();
                controller.deleteExpense(expenseId);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('O\'chirish'),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: Colors.grey[300]),
            SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
