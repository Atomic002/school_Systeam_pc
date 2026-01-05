// lib/presentation/screens/expenses/expenses_screen_final.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_1/presentation/controllers/expenses_controller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../widgets/sidebar.dart';

class ExpensesScreenFinal extends StatelessWidget {
  ExpensesScreenFinal({Key? key}) : super(key: key);

  final controller = Get.put(ExpensesControllerFinal());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                            CircularProgressIndicator(color: Color(0xFF6C63FF)),
                            SizedBox(height: 16),
                            Text(
                              'Yuklanmoqda...',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      );
                    }
                    return RefreshIndicator(
                      onRefresh: controller.refresh,
                      color: Color(0xFF6C63FF),
                      child: SingleChildScrollView(
                        physics: AlwaysScrollableScrollPhysics(),
                        child: Column(
                          children: [
                            _buildStatisticsCards(),
                            _buildCashBalanceCards(),
                            _buildFilters(),
                            _buildExpensesList(),
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
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFF6C63FF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.receipt_long_rounded,
              color: Color(0xFF6C63FF),
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
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[900],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Barcha moliyaviy operatsiyalarni real vaqtda kuzating',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          _buildActionButton(
            icon: Icons.add_circle_outline,
            label: 'Xarajat qo\'shish',
            color: Color(0xFF6C63FF),
            onTap: _showAddExpenseDialog,
          ),
          SizedBox(width: 12),
          _buildActionButton(
            icon: Icons.picture_as_pdf,
            label: 'PDF',
            color: Colors.red,
            onTap: controller.exportToPDF,
          ),
          SizedBox(width: 12),
          IconButton(
            onPressed: controller.refresh,
            icon: Icon(Icons.refresh, color: Colors.grey[700], size: 28),
            tooltip: 'Yangilash',
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.w600),
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
              icon: Icons.today,
              color: Color(0xFF6C63FF),
              subtitle: DateFormat(
                'dd MMMM, yyyy',
                'uz',
              ).format(DateTime.now()),
            ),
            _buildStatCard(
              title: 'Haftalik',
              value: controller.formatCurrency(controller.weekExpenses.value),
              icon: Icons.date_range,
              color: Color(0xFF26C6DA),
              subtitle: 'Joriy hafta',
            ),
            _buildStatCard(
              title: 'Oylik',
              value: controller.formatCurrency(controller.monthExpenses.value),
              icon: Icons.calendar_month,
              color: Color(0xFFAB47BC),
              subtitle: DateFormat('MMMM yyyy', 'uz').format(DateTime.now()),
            ),
            _buildStatCard(
              title: 'Yillik',
              value: controller.formatCurrency(controller.yearExpenses.value),
              icon: Icons.event_note,
              color: Color(0xFFFF7043),
              subtitle: '${DateTime.now().year}-yil',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    String? subtitle,
  }) {
    return Container(
      width: 260,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: Offset(0, 4),
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
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(title, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (subtitle != null) ...[
            SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCashBalanceCards() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Obx(() {
        if (controller.cashRegisters.isEmpty) return SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kassa qoldiqlari',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildCashCard(
                  'Naqd pul',
                  controller.cashBalance.value,
                  Icons.payments,
                  Color(0xFF66BB6A),
                ),
                _buildCashCard(
                  'Click',
                  controller.clickBalance.value,
                  Icons.phone_android,
                  Color(0xFF42A5F5),
                ),
                _buildCashCard(
                  'Terminal',
                  controller.cardBalance.value,
                  Icons.credit_card,
                  Color(0xFFAB47BC),
                ),
                _buildCashCard(
                  'Bank',
                  controller.bankBalance.value,
                  Icons.account_balance,
                  Color(0xFFFF7043),
                ),
                _buildCashCard(
                  'JAMI',
                  controller.totalCashBalance.value,
                  Icons.account_balance_wallet,
                  Color(0xFF6C63FF),
                  isTotal: true,
                ),
              ],
            ),
            SizedBox(height: 24),
          ],
        );
      }),
    );
  }

  Widget _buildCashCard(
    String title,
    double balance,
    IconData icon,
    Color color, {
    bool isTotal = false,
  }) {
    return Container(
      width: isTotal ? 260 : 200,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white, size: isTotal ? 32 : 28),
              Spacer(),
              if (isTotal)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'JAMI',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
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
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '${controller.formatCurrency(balance)} so\'m',
            style: TextStyle(
              color: Colors.white,
              fontSize: isTotal ? 24 : 20,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(
          top: BorderSide(color: Colors.grey[200]!),
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
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
                    prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Obx(
                  () => DropdownButtonFormField<String>(
                    value: controller.selectedCategory.value,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: 'Kategoriya',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                    items: controller.categories.map((cat) {
                      return DropdownMenuItem<String>(
                        value: cat['id'] as String,
                        child: Row(
                          children: [
                            Icon(
                              cat['icon'] as IconData,
                              size: 18,
                              color: cat['color'] as Color,
                            ),
                            SizedBox(width: 8),
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
              ElevatedButton.icon(
                onPressed: _selectDateRange,
                icon: Icon(Icons.date_range),
                label: Text('Sana'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF6C63FF),
                  foregroundColor: Colors.white,
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
                  foregroundColor: Colors.grey[700],
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
    );
  }

  Widget _buildExpensesList() {
    return Obx(() {
      if (controller.expenses.isEmpty) {
        return Center(
          child: Padding(
            padding: EdgeInsets.all(60),
            child: Column(
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: 80,
                  color: Colors.grey[300],
                ),
                SizedBox(height: 16),
                Text(
                  'Xarajatlar topilmadi',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        );
      }

      return Container(
        margin: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Sarlavha',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Kategoriya',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Sana',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Summa',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  SizedBox(width: 80),
                ],
              ),
            ),
            ...controller.expenses
                .map((expense) => _buildExpenseItem(expense))
                .toList(),
          ],
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
        border: Border(bottom: BorderSide(color: Colors.grey[100]!)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (category['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    category['icon'] as IconData,
                    color: category['color'] as Color,
                    size: 24,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        expense['title'] ?? 'N/A',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[900],
                        ),
                      ),
                      if (expense['description'] != null &&
                          expense['description'].toString().isNotEmpty) ...[
                        SizedBox(height: 4),
                        Text(
                          expense['description'],
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: (category['color'] as Color).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                category['name'] as String,
                style: TextStyle(
                  fontSize: 12,
                  color: category['color'] as Color,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          Expanded(
            child: Text(
              expense['expense_date'] ?? '',
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
          ),
          Expanded(
            child: Text(
              '${controller.formatCurrency((expense['amount'] as num).toDouble())} so\'m',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: category['color'] as Color,
              ),
              textAlign: TextAlign.right,
            ),
          ),
          SizedBox(width: 12),
          PopupMenuButton(
            icon: Icon(Icons.more_vert, color: Colors.grey[600]),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
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
                    Icon(Icons.edit, size: 18, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('Tahrirlash'),
                  ],
                ),
                onTap: () => _showEditExpenseDialog(expense),
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

  // ==================== DIALOGS ====================

  void _showAddExpenseDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final receiptController = TextEditingController();
    final responsibleController = TextEditingController();

    String selectedCategory = 'utilities';
    DateTime selectedDate = DateTime.now();

    final cashAllocations = <Map<String, dynamic>>[].obs;

    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.add_circle, color: Color(0xFF6C63FF)),
            SizedBox(width: 12),
            Text('Xarajat qo\'shish'),
          ],
        ),
        content: Container(
          width: 600,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: InputDecoration(
                    labelText: 'Kategoriya *',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: controller.categories
                      .where((c) => c['id'] != 'all')
                      .map((cat) {
                        return DropdownMenuItem<String>(
                          value: cat['id'] as String,
                          child: Row(
                            children: [
                              Icon(
                                cat['icon'] as IconData,
                                size: 18,
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
                SizedBox(height: 24),
                Row(
                  children: [
                    Text(
                      'Kassalardan to\'lov *',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Spacer(),
                    ElevatedButton.icon(
                      onPressed: () => _addCashAllocation(cashAllocations),
                      icon: Icon(Icons.add, size: 18),
                      label: Text('Kassa qo\'shish'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF6C63FF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Obx(() {
                  if (cashAllocations.isEmpty) {
                    return Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Center(
                        child: Text(
                          'Kassalardan to\'lov qo\'shing',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: cashAllocations.asMap().entries.map((entry) {
                      final index = entry.key;
                      final allocation = entry.value;
                      return Container(
                        margin: EdgeInsets.only(bottom: 8),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.account_balance_wallet,
                              color: Color(0xFF6C63FF),
                              size: 20,
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                '${allocation['cash_name']}: ${controller.formatCurrency(allocation['amount'])} so\'m',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.close,
                                size: 20,
                                color: Colors.red,
                              ),
                              onPressed: () => cashAllocations.removeAt(index),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                }),
                if (cashAllocations.isNotEmpty) ...[
                  SizedBox(height: 12),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(0xFF6C63FF).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Text(
                          'JAMI SUMMA:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Spacer(),
                        Obx(() {
                          final total = cashAllocations.fold<double>(
                            0.0,
                            (sum, item) => sum + (item['amount'] as double),
                          );
                          return Text(
                            '${controller.formatCurrency(total)} so\'m',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6C63FF),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Bekor qilish')),
          ElevatedButton.icon(
            onPressed: () {
              if (titleController.text.isEmpty || cashAllocations.isEmpty) {
                Get.snackbar(
                  'Xato',
                  'Majburiy maydonlarni to\'ldiring va kamida bitta kassadan to\'lov qo\'shing!',
                  backgroundColor: Colors.red.shade100,
                  colorText: Colors.red.shade900,
                );
                return;
              }

              controller.addExpense(
                category: selectedCategory,
                title: titleController.text,
                cashAllocations: cashAllocations.toList(),
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
              backgroundColor: Color(0xFF6C63FF),
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _addCashAllocation(RxList<Map<String, dynamic>> cashAllocations) {
    String? selectedCashId;
    final amountController = TextEditingController();

    if (controller.cashRegisters.isNotEmpty) {
      selectedCashId = controller.cashRegisters[0]['id'];
    }

    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.account_balance_wallet, color: Color(0xFF6C63FF)),
            SizedBox(width: 12),
            Text('Kassadan to\'lov'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(
              () => DropdownButtonFormField<String>(
                value: selectedCashId,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: 'Kassa',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: controller.cashRegisters.map((cash) {
                  final balance = (cash['current_balance'] as num).toDouble();
                  final method = cash['payment_method'] ?? '';
                  final branchName = cash['branches']?['name'] ?? '';
                  return DropdownMenuItem<String>(
                    value: cash['id'],
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '$method - $branchName',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 8),
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
                onChanged: (value) => selectedCashId = value,
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Summa (so\'m)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: Icon(Icons.attach_money),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Bekor qilish')),
          ElevatedButton(
            onPressed: () {
              if (selectedCashId == null || amountController.text.isEmpty) {
                Get.snackbar('Xato', 'Barcha maydonlarni to\'ldiring');
                return;
              }

              final amount = double.tryParse(amountController.text);
              if (amount == null || amount <= 0) {
                Get.snackbar('Xato', 'Summani to\'g\'ri kiriting');
                return;
              }

              final cashRegister = controller.cashRegisters.firstWhere(
                (c) => c['id'] == selectedCashId,
              );

              cashAllocations.add({
                'cash_register_id': selectedCashId,
                'payment_method': cashRegister['payment_method'],
                'amount': amount,
                'cash_name':
                    '${cashRegister['payment_method']} - ${cashRegister['branches']?['name'] ?? ''}',
              });

              Get.back();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF6C63FF)),
            child: Text('Qo\'shish'),
          ),
        ],
      ),
    );
  }

  void _showEditExpenseDialog(Map<String, dynamic> expense) {
    final titleController = TextEditingController(text: expense['title']);
    final descriptionController = TextEditingController(
      text: expense['description'] ?? '',
    );
    final receiptController = TextEditingController(
      text: expense['receipt_number'] ?? '',
    );
    final responsibleController = TextEditingController(
      text: expense['responsible_person'] ?? '',
    );

    String selectedCategory = expense['category'] ?? 'other';

    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.edit, color: Colors.orange),
            SizedBox(width: 12),
            Text('Xarajatni tahrirlash'),
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
                      .where((c) => c['id'] != 'all')
                      .map((cat) {
                        return DropdownMenuItem<String>(
                          value: cat['id'] as String,
                          child: Row(
                            children: [
                              Icon(
                                cat['icon'] as IconData,
                                size: 18,
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
                    labelText: 'Sarlavha',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(Icons.title),
                  ),
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
              if (titleController.text.isEmpty) {
                Get.snackbar('Xato', 'Sarlavhani kiriting');
                return;
              }

              controller.updateExpense(
                expenseId: expense['id'],
                category: selectedCategory,
                title: titleController.text,
                description: descriptionController.text.isEmpty
                    ? null
                    : descriptionController.text,
                receiptNumber: receiptController.text.isEmpty
                    ? null
                    : receiptController.text,
                responsiblePerson: responsibleController.text.isEmpty
                    ? null
                    : responsibleController.text,
              );

              Get.back();
            },
            icon: Icon(Icons.save),
            label: Text('Saqlash'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _showExpenseDetails(Map<String, dynamic> expense) {
    final categoryId = expense['category'] ?? 'other';
    final category = controller.categories.firstWhere(
      (c) => c['id'] == categoryId,
      orElse: () => controller.categories.last,
    );

    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (category['color'] as Color).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                category['icon'] as IconData,
                color: category['color'] as Color,
                size: 28,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                expense['title'] ?? 'N/A',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: Container(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow(
                  'Kategoriya',
                  category['name'] as String,
                  category['color'] as Color,
                ),
                Divider(),
                _buildDetailRow(
                  'Summa',
                  '${controller.formatCurrency((expense['amount'] as num).toDouble())} so\'m',
                  Colors.green,
                ),
                Divider(),
                _buildDetailRow('Sana', expense['expense_date'] ?? 'N/A'),
                Divider(),
                _buildDetailRow('Vaqt', expense['expense_time'] ?? 'N/A'),
                if (expense['responsible_person'] != null) ...[
                  Divider(),
                  _buildDetailRow(
                    'Mas\'ul shaxs',
                    expense['responsible_person'],
                  ),
                ],
                if (expense['receipt_number'] != null) ...[
                  Divider(),
                  _buildDetailRow('Kvitansiya', expense['receipt_number']),
                ],
                if (expense['description'] != null &&
                    expense['description'].toString().isNotEmpty) ...[
                  Divider(),
                  _buildDetailRow('Izoh', expense['description']),
                ],
                if (expense['users'] != null) ...[
                  Divider(),
                  _buildDetailRow(
                    'Qayd qilgan',
                    '${expense['users']['first_name'] ?? ''} ${expense['users']['last_name'] ?? ''}'
                        .trim(),
                  ),
                ],
                if (expense['branches'] != null) ...[
                  Divider(),
                  _buildDetailRow(
                    'Filial',
                    expense['branches']['name'] ?? 'N/A',
                  ),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Yopish')),
          ElevatedButton.icon(
            onPressed: () {
              Get.back();
              _showEditExpenseDialog(expense);
            },
            icon: Icon(Icons.edit),
            label: Text('Tahrirlash'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, [Color? valueColor]) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: valueColor ?? Colors.grey[900],
                fontWeight: valueColor != null
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteExpense(String expenseId) {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red, size: 28),
            SizedBox(width: 12),
            Text('Xarajatni o\'chirish'),
          ],
        ),
        content: Text(
          'Bu xarajatni o\'chirmoqchimisiz?\n\n'
          'O\'chirilgan xarajat summasi kassaga qaytariladi.',
          style: TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Bekor qilish')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.deleteExpense(expenseId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text('O\'chirish'),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: Get.context!,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(Duration(days: 365)),
      initialDateRange:
          controller.startDate.value != null && controller.endDate.value != null
          ? DateTimeRange(
              start: controller.startDate.value!,
              end: controller.endDate.value!,
            )
          : null,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFF6C63FF),
              onPrimary: Colors.white,
            ),
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
}
