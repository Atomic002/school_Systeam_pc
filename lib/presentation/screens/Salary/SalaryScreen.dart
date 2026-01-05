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
                  child: RefreshIndicator(
                    onRefresh: () async {
                      await controller.loadAllData();
                      Get.snackbar(
                        'Yangilandi',
                        'Ma\'lumotlar yangilandi',
                        snackPosition: SnackPosition.TOP,
                        duration: Duration(seconds: 2),
                      );
                    },
                    child: SingleChildScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Header va boshqa widgetlar bir xil qoladi...
  // Faqat _buildListView() va _buildCalculateView() o'zgaradi

  Widget _buildModernHeader() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.white, Color(0xFFF8F9FA)]),
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
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppConstants.primaryColor,
                  AppConstants.primaryColor.withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
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
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Obx(
                  () => Text(
                    controller.getPeriodString(),
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
          _buildModernFilters(),
        ],
      ),
    );
  }

  Widget _buildModernFilters() {
    return Row(
      children: [
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
      ),
      child: DropdownButtonFormField<T>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20, color: AppConstants.primaryColor),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: InputBorder.none,
        ),
        items: items,
        onChanged: onChanged,
      ),
    );
  }

  // Statistika kartochkalari
  Widget _buildStatisticsCards() {
    return Obx(
      () => Column(
        children: [
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
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            SizedBox(height: 8),
            Text(
              controller.formatCurrency(value),
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
                  style: TextStyle(color: Colors.grey[600], fontSize: 11),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Tabs
  Widget _buildModernTabs() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
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
                    )
                  : null,
              borderRadius: BorderRadius.circular(12),
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

  // LIST VIEW - Yangilangan
  Widget _buildListView() {
    return Column(
      children: [
        _buildModernSearchBar(),
        SizedBox(height: 20),
        Obx(() {
          if (controller.isLoading.value) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(),
              ),
            );
          }
          if (controller.filteredOperations.isEmpty) {
            return _modernEmptyState('Ma\'lumot yo\'q', Icons.inbox_rounded);
          }
          return ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: controller.filteredOperations.length,
            itemBuilder: (context, index) =>
                _modernSalaryCard(controller.filteredOperations[index]),
          );
        }),
      ],
    );
  }

  // CALCULATE VIEW - To'liq Yangilangan
  Widget _buildCalculateView() {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Maoshni Hisoblash",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    controller.getPeriodString(),
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: controller.isCalculating.value
                        ? null
                        : () => controller.calculateSalariesPreview(),
                    icon: controller.isCalculating.value
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          )
                        : Icon(Icons.calculate),
                    label: Text("Qayta Hisoblash"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.all(16),
                    ),
                  ),
                  if (controller.calculationResults.isNotEmpty) ...[
                    SizedBox(width: 12),
                    // YANGILANGAN SAVE BUTTON
                    ElevatedButton.icon(
                      onPressed: () => controller
                          .saveSelectedCalculations(), // Yangi funksiya
                      icon: Icon(Icons.save),
                      label: Text(
                        "Tanlanganlarni Saqlash (${controller.selectedCalculationIds.length})",
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.all(16),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          SizedBox(height: 24),

          // Content
          if (controller.calculationResults.isNotEmpty)
            Column(
              children: [
                // Select All Checkbox Row
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: Colors.grey[100],
                  child: Row(
                    children: [
                      Obx(
                        () => Checkbox(
                          value:
                              controller.calculationResults.length ==
                                  controller.selectedCalculationIds.length &&
                              controller.calculationResults.isNotEmpty,
                          onChanged: (v) => controller.toggleSelectAll(v),
                        ),
                      ),
                      Text("Barchasini tanlash"),
                      Spacer(),
                      Text(
                        "Jami: ${controller.formatCurrency(controller.calculationResults.fold(0.0, (sum, item) => sum + (item['net_amount'] as num).toDouble()))}",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),

                // List
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: controller.calculationResults.length,
                  itemBuilder: (context, index) {
                    final item = controller.calculationResults[index];
                    final staffId = item['staff_id'] as String;

                    return Card(
                      margin: EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Obx(
                          () => Checkbox(
                            value: controller.selectedCalculationIds.contains(
                              staffId,
                            ),
                            onChanged: (v) =>
                                controller.toggleSelection(staffId),
                          ),
                        ),
                        title: Text(
                          "${item['staff']['first_name']} ${item['staff']['last_name']}",
                        ),
                        subtitle: Text("Ishladi: ${item['worked_days']} kun"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              controller.formatCurrency(item['net_amount']),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(width: 16),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                controller.calculationResults.removeAt(index);
                                controller.selectedCalculationIds.remove(
                                  staffId,
                                );
                              },
                              tooltip: "Ro'yxatdan chiqarish",
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            )
          else
            _modernEmptyState(
              "Hisoblash tugmasini bosing",
              Icons.calculate_outlined,
            ),
        ],
      ),
    );
  }


  // History, Advances, Loans viewlar oldingicha...
  Widget _buildHistoryView() {
    final paidOps = controller.salaryOperations
        .where((o) => o['is_paid'])
        .toList();
    return Column(
      children: [
        Text(
          "To'lovlar Tarixi",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),
        paidOps.isEmpty
            ? _modernEmptyState("To'lovlar tarixi bo'sh", Icons.history)
            : ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: paidOps.length,
                itemBuilder: (context, index) {
                  final op = paidOps[index];
                  return Card(
                    margin: EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: Icon(Icons.history, color: Colors.green),
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
    return Obx(
      () => Column(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: () => _showAdvanceDialog(),
              icon: Icon(Icons.add),
              label: Text("Avans Berish"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: EdgeInsets.all(16),
              ),
            ),
          ),
          SizedBox(height: 16),
          controller.advancesList.isEmpty
              ? _modernEmptyState("Avanslar yo'q", Icons.monetization_on)
              : ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: controller.advancesList.length,
                  itemBuilder: (context, index) {
                    final adv = controller.advancesList[index];
                    bool deducted = adv['is_deducted'] ?? false;
                    return Card(
                      margin: EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: Icon(
                          Icons.monetization_on,
                          color: Colors.orange,
                        ),
                        title: Text(
                          "${adv['staff']['first_name']} ${adv['staff']['last_name']}",
                        ),
                        subtitle: Text(
                          "${adv['deduction_month']}/${adv['deduction_year']} oyligidan",
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              controller.formatCurrency(
                                (adv['amount'] as num).toDouble(),
                              ),
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              deducted ? "USHLAB QOLINDI" : "OCHIQ",
                              style: TextStyle(
                                color: deducted ? Colors.green : Colors.red,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildLoansView() {
    return Obx(
      () => Column(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: () => _showLoanDialog(),
              icon: Icon(Icons.add),
              label: Text("Qarz Berish"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                padding: EdgeInsets.all(16),
              ),
            ),
          ),
          SizedBox(height: 16),
          controller.loansList.isEmpty
              ? _modernEmptyState("Qarzlar yo'q", Icons.account_balance)
              : ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: controller.loansList.length,
                  itemBuilder: (context, index) {
                    final loan = controller.loansList[index];
                    bool settled = loan['is_settled'] ?? false;
                    return Card(
                      margin: EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: Icon(
                          Icons.account_balance,
                          color: Colors.purple,
                        ),
                        title: Text(
                          "${loan['staff']['first_name']} ${loan['staff']['last_name']}",
                        ),
                        subtitle: Text(
                          "Oylik to'lov: ${controller.formatCurrency((loan['monthly_deduction'] as num).toDouble())}",
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "Qoldiq: ${controller.formatCurrency((loan['remaining_amount'] as num).toDouble())}",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              settled ? "YOPILGAN" : "FAOL",
                              style: TextStyle(
                                color: settled ? Colors.green : Colors.blue,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }

  // Dialogs
  void _showAdvanceDialog() {
    if (controller.staffList.isEmpty) {
      controller.loadStaffForCalculation();
    }

    String? sId;
    double? amt;
    int mon = controller.selectedMonth.value;
    int year = controller.selectedYear.value;
    String? srcId;
    String note = '';

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          width: 500,
          padding: EdgeInsets.all(32),
          child: SingleChildScrollView(
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

                // Xodim tanlash
                Obx(
                  () => DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Xodim',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: controller.staffList
                        .map(
                          (s) => DropdownMenuItem(
                            value: s['id'] as String,
                            child: Text('${s['first_name']} ${s['last_name']}'),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => sId = v,
                  ),
                ),
                SizedBox(height: 16),

                // Summa
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Summa',
                    prefixIcon: Icon(Icons.attach_money),
                    suffixText: 'so\'m',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (v) => amt = double.tryParse(v),
                ),
                SizedBox(height: 16),

                // Oy va Yil
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: mon,
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
                        onChanged: (v) => mon = v!,
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
                        items: List.generate(
                          3,
                          (i) => DropdownMenuItem(
                            value: DateTime.now().year + i,
                            child: Text('${DateTime.now().year + i}'),
                          ),
                        ),
                        onChanged: (v) => year = v!,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),

                // Kassa tanlash
                Obx(
                  () => DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'To\'lov Manbai',
                      prefixIcon: Icon(Icons.account_balance_wallet),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: controller.cashRegisters.map((s) {
                      final balance = s['balance'] != null
                          ? ' (${NumberFormat('#,###').format(s['balance'])} so\'m)'
                          : '';
                      return DropdownMenuItem(
                        value: s['id'] as String,
                        child: Text('${s['name']}$balance'),
                      );
                    }).toList(),
                    onChanged: (v) => srcId = v,
                  ),
                ),
                SizedBox(height: 16),

                // Izoh
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Izoh (Ixtiyoriy)',
                    prefixIcon: Icon(Icons.note),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  maxLines: 2,
                  onChanged: (v) => note = v,
                ),
                SizedBox(height: 24),

                // Tugmalar
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
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
                          if (sId != null && amt != null && srcId != null) {
                            Get.back();
                            final sourceName = controller.cashRegisters
                                .firstWhere((s) => s['id'] == srcId)['name'];
                            controller.giveAdvance(
                              staffId: sId!,
                              amount: amt!,
                              deductionMonth: mon,
                              deductionYear: year,
                              sourceId: srcId!,
                              sourceName: sourceName,
                              comment: note,
                            );
                          } else {
                            Get.snackbar(
                              'Xatolik',
                              'Barcha maydonlarni to\'ldiring!',
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                            );
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
      ),
    );
  }

  void _showLoanDialog() {
    if (controller.staffList.isEmpty) {
      controller.loadStaffForCalculation();
    }

    String? sId;
    double? totalAmt;
    double? monthlyAmt;
    String? srcId;
    String note = '';

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          width: 500,
          padding: EdgeInsets.all(32),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.account_balance, size: 64, color: Colors.purple),
                SizedBox(height: 16),
                Text(
                  'Qarz Berish',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 24),

                // Xodim
                Obx(
                  () => DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Xodim',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: controller.staffList
                        .map(
                          (s) => DropdownMenuItem(
                            value: s['id'] as String,
                            child: Text('${s['first_name']} ${s['last_name']}'),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => sId = v,
                  ),
                ),
                SizedBox(height: 16),

                // Jami summa
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Jami Summa',
                    prefixIcon: Icon(Icons.attach_money),
                    suffixText: 'so\'m',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (v) => totalAmt = double.tryParse(v),
                ),
                SizedBox(height: 16),

                // Oylik ushlanma
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Oylik Ushlanma',
                    prefixIcon: Icon(Icons.calendar_month),
                    suffixText: 'so\'m',
                    hintText: 'Har oy qancha ushlanadi',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (v) => monthlyAmt = double.tryParse(v),
                ),
                SizedBox(height: 16),

                // Kassa
                Obx(
                  () => DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Kassa / Hamyon',
                      prefixIcon: Icon(Icons.account_balance_wallet),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: controller.cashRegisters.map((c) {
                      final balance = c['balance'] != null
                          ? ' (${NumberFormat('#,###').format(c['balance'])} so\'m)'
                          : '';
                      return DropdownMenuItem(
                        value: c['id'] as String,
                        child: Text('${c['name']}$balance'),
                      );
                    }).toList(),
                    onChanged: (v) => srcId = v,
                  ),
                ),
                SizedBox(height: 16),

                // Izoh
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Izoh',
                    prefixIcon: Icon(Icons.note),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  maxLines: 2,
                  onChanged: (v) => note = v,
                ),
                SizedBox(height: 24),

                // Tugmalar
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
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
                          if (sId != null &&
                              totalAmt != null &&
                              monthlyAmt != null &&
                              srcId != null) {
                            Get.back();
                            controller.giveLoan(
                              staffId: sId!,
                              totalAmount: totalAmt!,
                              monthlyDeduction: monthlyAmt!,
                              startMonth: controller.selectedMonth.value,
                              startYear: controller.selectedYear.value,
                              sourceId: srcId!,
                              reason: note,
                            );
                          } else {
                            Get.snackbar(
                              'Xatolik',
                              'Barcha maydonlarni to\'ldiring!',
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                            );
                          }
                        },
                        icon: Icon(Icons.save),
                        label: Text('Saqlash'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
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

  // Qolgan widgetlar (searchBar, salaryCard, detailsDialog va boshqalar)
  Widget _buildModernSearchBar() {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${staff['first_name']} ${staff['last_name']}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
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
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
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
Row(
  children: [
    Expanded(
      child: OutlinedButton.icon(
        onPressed: () => _showDetailsDialog(op),
        icon: Icon(Icons.visibility_rounded, size: 18),
        label: Text('Batafsil'),
        // ... style
      ),
    ),
    SizedBox(width: 12),
    
    // AGAR TO'LANMAGAN BO'LSA
    if (!isPaid) ...[
      // 1. TO'LASH TUGMASI
      Expanded(
        child: ElevatedButton.icon(
          onPressed: () => _showPaymentSourceDialog(op),
          icon: Icon(Icons.payment_rounded, size: 18),
          label: Text('To\'lash'),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 12),
            backgroundColor: Colors.green,
          ),
        ),
      ),
      SizedBox(width: 12),

      // 2. O'CHIRISH TUGMASI (YANGI)
      Expanded(
        child: ElevatedButton.icon(
          onPressed: () => _confirmDeleteDialog(op), // Tasdiqlash oynasini chaqirish
          icon: Icon(Icons.delete_forever_rounded, size: 18),
          label: Text('O\'chirish'),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 12),
            backgroundColor: Colors.red.shade100, // Och qizil fon
            foregroundColor: Colors.red, // Qizil yozuv
            elevation: 0,
          ),
        ),
      ),
    ],

    // AGAR TO'LANGAN BO'LSA
    if (isPaid)
      Expanded(
        child: ElevatedButton.icon(
          onPressed: () => _showEditDialog(op),
          icon: Icon(Icons.edit_rounded, size: 18),
          label: Text('Tahrirlash'),
          // ... style
        ),
      ),
  ],
),
        ],
      ),
    );
  }
  void _confirmDeleteDialog(Map<String, dynamic> op) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: EdgeInsets.all(24),
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.warning_amber_rounded, size: 60, color: Colors.red),
              SizedBox(height: 16),
              Text(
                "Hisobni o'chirmoqchimisiz?",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text(
                "Bu amalni ortga qaytarib bo'lmaydi.\n\n"
                "• Ushbu maosh hisobi o'chiriladi.\n"
                "• Ushlab qolingan AVANSLAR qayta ochiladi.\n"
                "• Qarz to'lovlari bekor qilinib, qarz qoldig'i joyiga qaytadi.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[700]),
              ),
              SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      child: Text("Bekor qilish"),
                      style: OutlinedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 16)),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back(); // Dialogni yopish
                        controller.deleteSalaryOperation(op['id']); // O'chirishni boshlash
                      },
                      child: Text("Ha, O'chirish"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              )
            ],
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

  Widget _modernEmptyState(String text, IconData icon) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(icon, size: 80, color: Colors.grey[300]),
            SizedBox(height: 16),
            Text(text, style: TextStyle(color: Colors.grey[600], fontSize: 16)),
          ],
        ),
      ),
    );
  }

  // Details, Payment Source, Edit dialoglar uchun placeholder
  // (Bu metodlar sizning asl faylingizda bor, men ularni qisqartirdim)

  void _showDetailsDialog(Map<String, dynamic> op) {
    final staff = op['staff'];
    final isPaid = op['is_paid'] == true;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          width: 600,
          padding: EdgeInsets.all(32),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
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
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
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

  void _showPaymentSourceDialog(Map<String, dynamic> op) {
    // Mahalliy controllerlar
   final RxList<Map<String, dynamic>> paymentParts = <Map<String, dynamic>>[].obs;
  final double totalToPay = (op['net_amount'] as num).toDouble();

    // Boshlang'ich bitta qator qo'shamiz (default source bilan)
  if (controller.cashRegisters.isNotEmpty) {
    paymentParts.add({
      'sourceId': controller.cashRegisters.first['id'], // Endi xato bermaydi
      'amount': totalToPay,
      'controller': TextEditingController(text: totalToPay.toString())
    });
  } else {
    // Agar kassa topilmasa, xabar chiqaramiz yoki default qiymat
    Get.snackbar("Xatolik", "Filialda kassalar mavjud emas!");
    return; 
  }

    showDialog(
      context: Get.context!,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          width: 600,
          padding: EdgeInsets.all(24),
          child: Obx(() {
            double currentTotal = paymentParts.fold(
              0,
              (sum, item) =>
                  sum + (double.tryParse(item['controller'].text) ?? 0),
            );
            double remaining = totalToPay - currentTotal;

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "To'lov Amalga Oshirish",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  "Jami to'lanishi kerak: ${controller.formatCurrency(totalToPay)}",
                  style: TextStyle(color: Colors.grey[700]),
                ),

                SizedBox(height: 20),
                // Payment Parts List
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: paymentParts.length,
                    itemBuilder: (ctx, idx) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Row(
                          children: [
                            // Source Dropdown
                            Expanded(
                              flex: 2,
                              child: DropdownButtonFormField<String>(
                                value: paymentParts[idx]['sourceId'],
                                decoration: InputDecoration(
                                  labelText: 'Hamyon/Kassa',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 14,
                                  ),
                                ),
                                items: controller.cashRegisters.map((c) {
                                  return DropdownMenuItem(
                                    value: c['id'] as String,
                                    child: Text(
                                      "${c['name']} (${controller.formatCurrency((c['balance'] as num).toDouble())})",
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontSize: 13),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (v) =>
                                    paymentParts[idx]['sourceId'] = v,
                              ),
                            ),
                            SizedBox(width: 12),
                            // Amount Field
                            Expanded(
                              child: TextField(
                                controller: paymentParts[idx]['controller'],
                                decoration: InputDecoration(
                                  labelText: 'Summa',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                keyboardType: TextInputType.number,
                                onChanged: (val) {
                                  paymentParts[idx]['amount'] =
                                      double.tryParse(val) ?? 0;
                                  paymentParts.refresh(); // UI update trigger
                                },
                              ),
                            ),
                            // Remove Button
                            if (paymentParts.length > 1)
                              IconButton(
                                icon: Icon(
                                  Icons.remove_circle,
                                  color: Colors.red,
                                ),
                                onPressed: () => paymentParts.removeAt(idx),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Add Line Button
                if (remaining > 0)
                  TextButton.icon(
                    onPressed: () {
                      paymentParts.add({
                        'sourceId': controller.cashRegisters.first['id'],
                        'amount': remaining,
                        'controller': TextEditingController(
                          text: remaining.toString(),
                        ),
                      });
                    },
                    icon: Icon(Icons.add),
                    label: Text(
                      "Yana manba qo'shish (Qoldiq: ${controller.formatCurrency(remaining)})",
                    ),
                  ),

                if (remaining != 0)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      remaining > 0
                          ? "Yana ${controller.formatCurrency(remaining)} kiritilishi kerak"
                          : "Summa oshib ketdi! (${controller.formatCurrency(remaining.abs())})",
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Get.back(),
                      child: Text("Bekor qilish"),
                    ),
                    SizedBox(width: 12),
                    ElevatedButton(
                      onPressed:
                          remaining.abs() <
                              100 // Allow small floating point diff
                          ? () {
                              // Prepare simple data for controller
                              List<Map<String, dynamic>> finalPayments =
                                  paymentParts.map((p) {
                                    String sName = controller.cashRegisters
                                        .firstWhere(
                                          (c) => c['id'] == p['sourceId'],
                                        )['name'];
                                    return {
                                      'sourceId': p['sourceId'],
                                      'sourceName': sName,
                                      'amount': double.parse(
                                        p['controller'].text,
                                      ),
                                    };
                                  }).toList();

                              Get.back();
                              controller.paySalarySplit(
                                operationId: op['id'],
                                payments: finalPayments,
                              );
                            }
                          : null,
                      child: Text("To'lash"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

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
          child: SingleChildScrollView(
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
      ),
    );
  }

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
}
