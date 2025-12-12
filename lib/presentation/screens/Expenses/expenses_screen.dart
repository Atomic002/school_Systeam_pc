// expenses_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/models/expenses_model.dart';
import 'package:flutter_application_1/presentation/controllers/expenses_controller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ExpensesScreen extends StatelessWidget {
  ExpensesScreen({Key? key}) : super(key: key);

  final ExpensesController controller = Get.put(ExpensesController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return _buildLoadingState();
              }

              if (controller.filteredExpenses.isEmpty) {
                return _buildEmptyState();
              }

              return Column(
                children: [
                  _buildStats(),
                  _buildFilters(),
                  Expanded(
                    child: Obx(() {
                      return controller.showGridView.value
                          ? _buildGridView()
                          : _buildListView();
                    }),
                  ),
                  _buildPagination(),
                ],
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddExpenseDialog(),
        backgroundColor: const Color(0xFF667eea),
        icon: const Icon(Icons.add),
        label: const Text('Xarajat qo\'shish'),
      ),
    );
  }

  // ============= HEADER =============
  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667eea).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Xarajatlar',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Barcha xarajatlarni boshqaring',
                      style: TextStyle(fontSize: 15, color: Colors.white70),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _showExportDialog(),
                icon: const Icon(Icons.file_download, color: Colors.white),
                tooltip: 'Export',
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.2),
                ),
              ),
              const SizedBox(width: 8),
              Obx(() {
                return IconButton(
                  onPressed: () => controller.showGridView.toggle(),
                  icon: Icon(
                    controller.showGridView.value
                        ? Icons.list_rounded
                        : Icons.grid_view_rounded,
                    color: Colors.white,
                  ),
                  tooltip: controller.showGridView.value
                      ? 'Ro\'yxat ko\'rinishi'
                      : 'Grid ko\'rinishi',
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.2),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  // ============= STATISTIKA =============
  Widget _buildStats() {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Obx(() {
        final total = controller.getTotalAmount();
        final categoryTotals = controller.getExpensesByCategory();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Jami xarajat',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatCurrency(total),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF667eea),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${controller.filteredExpenses.length} ta xarajat',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                if (categoryTotals.isNotEmpty)
                  Container(
                    width: 200,
                    height: 100,
                    child: _buildMiniChart(categoryTotals),
                  ),
              ],
            ),
          ],
        );
      }),
    );
  }

  Widget _buildMiniChart(Map<String, double> data) {
    final total = data.values.fold(0.0, (sum, val) => sum + val);

    return Row(
      children: data.entries.take(5).map((entry) {
        final percent = (entry.value / total);
        return Expanded(
          flex: (percent * 100).toInt() + 1,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: controller.getCategoryColor(entry.key),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: Text(
                '${(percent * 100).toInt()}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ============= FILTERS =============
  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Search bar
          TextField(
            onChanged: (value) {
              controller.searchQuery.value = value;
              controller.applyFilters();
            },
            decoration: InputDecoration(
              hintText: 'Xarajat qidirish...',
              prefixIcon: const Icon(Icons.search, color: Color(0xFF667eea)),
              suffixIcon: Obx(() {
                if (controller.searchQuery.value.isEmpty) {
                  return const SizedBox();
                }
                return IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    controller.searchQuery.value = '';
                    controller.applyFilters();
                  },
                );
              }),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF667eea)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Category and date filters
          Row(
            children: [
              Expanded(child: _buildCategoryFilter()),
              const SizedBox(width: 16),
              _buildDateRangeFilter(),
              const SizedBox(width: 16),
              Obx(() {
                final hasFilters =
                    controller.selectedCategory.value != 'all' ||
                    controller.selectedDateRange.value != null ||
                    controller.searchQuery.value.isNotEmpty;

                if (!hasFilters) return const SizedBox();

                return OutlinedButton.icon(
                  onPressed: controller.clearFilters,
                  icon: const Icon(Icons.clear_all, size: 18),
                  label: const Text('Tozalash'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Obx(() {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            isExpanded: true,
            value: controller.selectedCategory.value,
            hint: const Text('Kategoriya'),
            items: controller.categories.map((category) {
              return DropdownMenuItem<String>(
                value: category.id,
                child: Row(
                  children: [
                    Icon(category.icon, size: 20, color: category.color),
                    const SizedBox(width: 12),
                    Text(category.name),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              controller.selectedCategory.value = value;
              controller.applyFilters();
            },
          ),
        ),
      );
    });
  }

  Widget _buildDateRangeFilter() {
    return Obx(() {
      final range = controller.selectedDateRange.value;

      return OutlinedButton.icon(
        onPressed: () => controller.selectDateRange(Get.context!),
        icon: const Icon(Icons.date_range),
        label: Text(
          range != null
              ? '${_formatShortDate(range.start)} - ${_formatShortDate(range.end)}'
              : 'Sana tanlang',
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF667eea),
          side: BorderSide(
            color: range != null
                ? const Color(0xFF667eea)
                : Colors.grey.shade300,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      );
    });
  }

  // ============= GRID VIEW =============
  Widget _buildGridView() {
    return Obx(() {
      final expenses = controller.getPaginatedExpenses();

      return GridView.builder(
        padding: const EdgeInsets.all(24),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1.2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: expenses.length,
        itemBuilder: (context, index) {
          return _buildExpenseCard(expenses[index]);
        },
      );
    });
  }

  Widget _buildExpenseCard(Expense expense) {
    final category = controller.categories.firstWhere(
      (cat) => cat.id == expense.category,
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: category.color.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showExpenseDetails(expense),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: category.color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        category.icon,
                        color: category.color,
                        size: 24,
                      ),
                    ),
                    const Spacer(),
                    PopupMenuButton(
                      icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 18),
                              SizedBox(width: 8),
                              Text('Tahrirlash'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 18, color: Colors.red),
                              SizedBox(width: 8),
                              Text(
                                'O\'chirish',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'delete') {
                          _confirmDelete(expense);
                        }
                      },
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  expense.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  expense.subCategory,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _formatCurrency(expense.amount),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: category.color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 12,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatShortDate(expense.expenseDate),
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
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

  // ============= LIST VIEW =============
  Widget _buildListView() {
    return Obx(() {
      final expenses = controller.getPaginatedExpenses();

      return ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: expenses.length,
        itemBuilder: (context, index) {
          return _buildExpenseListItem(expenses[index]);
        },
      );
    });
  }

  Widget _buildExpenseListItem(Expense expense) {
    final category = controller.categories.firstWhere(
      (cat) => cat.id == expense.category,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: category.color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(category.icon, color: category.color, size: 24),
        ),
        title: Text(
          expense.title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(expense.subCategory),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.person, size: 12, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  expense.responsiblePerson,
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
                const SizedBox(width: 12),
                Icon(Icons.calendar_today, size: 12, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  _formatShortDate(expense.expenseDate),
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _formatCurrency(expense.amount),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: category.color,
              ),
            ),
            if (expense.receiptNumber != null) ...[
              const SizedBox(height: 4),
              Text(
                expense.receiptNumber!,
                style: TextStyle(fontSize: 10, color: Colors.grey[600]),
              ),
            ],
          ],
        ),
        onTap: () => _showExpenseDetails(expense),
      ),
    );
  }

  // ============= PAGINATION =============
  Widget _buildPagination() {
    return Obx(() {
      final totalPages = controller.getTotalPages();
      if (totalPages <= 1) return const SizedBox();

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: controller.currentPage.value > 1
                  ? controller.previousPage
                  : null,
              icon: const Icon(Icons.chevron_left),
            ),
            const SizedBox(width: 16),
            Text(
              '${controller.currentPage.value} / $totalPages',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 16),
            IconButton(
              onPressed: controller.currentPage.value < totalPages
                  ? controller.nextPage
                  : null,
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
      );
    });
  }

  // ============= STATES =============
  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667eea)),
          ),
          SizedBox(height: 16),
          Text('Yuklanmoqda...'),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_rounded,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          const Text(
            'Xarajatlar topilmadi',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Yangi xarajat qo\'shing',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  // ============= DIALOGS =============
  void _showExpenseDetails(Expense expense) {
    final category = controller.categories.firstWhere(
      (cat) => cat.id == expense.category,
    );

    showDialog(
      context: Get.context!,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: 600,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: category.color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(category.icon, color: category.color, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          expense.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          expense.subCategory,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const Divider(height: 32),
              _buildDetailRow('Summa', _formatCurrency(expense.amount)),
              _buildDetailRow('Sana', _formatDate(expense.expenseDate)),
              _buildDetailRow('Mas\'ul', expense.responsiblePerson),
              if (expense.staffName != null)
                _buildDetailRow('Xodim', expense.staffName!),
              if (expense.receiptNumber != null)
                _buildDetailRow('Kvitansiya', expense.receiptNumber!),
              if (expense.notes != null) ...[
                const SizedBox(height: 16),
                const Text(
                  'Izoh:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(expense.notes!),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddExpenseDialog() {
    Get.snackbar(
      'Ma\'lumot',
      'Xarajat qo\'shish funksiyasi tez orada qo\'shiladi',
      snackPosition: SnackPosition.TOP,
    );
  }

  void _showExportDialog() {
    showDialog(
      context: Get.context!,
      builder: (context) => AlertDialog(
        title: const Text('Export'),
        content: const Text('CSV formatda export qilasizmi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Bekor qilish'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              final csv = controller.getExportData();
              Get.snackbar(
                'Muvaffaqiyat',
                'Ma\'lumotlar tayyorlandi',
                snackPosition: SnackPosition.TOP,
              );
              // ignore: avoid_print
              print(csv);
            },
            child: const Text('Export'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(Expense expense) {
    Get.dialog(
      AlertDialog(
        title: const Text('O\'chirish'),
        content: Text('${expense.title} xarajatini o\'chirmoqchimisiz?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Bekor qilish'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar('Muvaffaqiyat', 'Xarajat o\'chirildi');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('O\'chirish'),
          ),
        ],
      ),
    );
  }

  // ============= HELPERS =============
  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'uz',
      symbol: '',
      decimalDigits: 0,
    );
    return '${formatter.format(amount)} so\'m';
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMMM yyyy', 'uz').format(date);
  }

  String _formatShortDate(DateTime date) {
    return DateFormat('dd.MM.yyyy').format(date);
  }
}
