// lib/presentation/screens/finance/salary_screen.dart
// IZOH: Maosh boshqaruvi ekrani - hodimlar maoshini ko'rish va to'lash

import 'package:flutter/material.dart';
import 'package:flutter_application_1/presentation/controllers/SalaryController.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class SalaryScreen extends StatelessWidget {
  const SalaryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Controller ni yaratish
    final controller = Get.put(SalaryController());

    // Raqamlarni formatlash uchun
    final numberFormat = NumberFormat('#,###', 'uz');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Maosh boshqaruvi'),
        elevation: 0,
        actions: [
          // Yangi maosh hisoblash tugmasi
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => _showCalculateSalaryDialog(context, controller),
            tooltip: 'Maosh hisoblash',
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. STATISTIKA KARTOCHKALARI
          // IZOH: Umumiy summalar va sonlarni ko'rsatish
          _buildStatisticsCards(controller, numberFormat),

          // 2. FILTRLAR VA QIDIRUV
          // IZOH: Oy, yil, status va qidiruv filtrlari
          _buildFiltersSection(controller),

          // 3. MAOSH RO'YXATI
          // IZOH: Barcha maosh operatsiyalari ro'yxati
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.filteredOperations.isEmpty) {
                return _buildEmptyState();
              }

              return _buildSalaryList(controller, numberFormat);
            }),
          ),
        ],
      ),
    );
  }

  // STATISTIKA KARTOCHKALARI
  // IZOH: 4 ta karta - to'langan, to'lanmagan, soni va umumiy
  Widget _buildStatisticsCards(
    SalaryController controller,
    NumberFormat numberFormat,
  ) {
    return Obx(
      () => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                // To'langan maoshlar
                Expanded(
                  child: _buildStatCard(
                    title: 'To\'langan',
                    value:
                        '${numberFormat.format(controller.totalPaidSalaries.value)} so\'m',
                    icon: Icons.check_circle,
                    color: Colors.green,
                    subtitle: '${controller.paidCount.value} ta',
                  ),
                ),
                const SizedBox(width: 12),
                // To'lanmagan maoshlar
                Expanded(
                  child: _buildStatCard(
                    title: 'To\'lanmagan',
                    value:
                        '${numberFormat.format(controller.totalUnpaidSalaries.value)} so\'m',
                    icon: Icons.pending,
                    color: Colors.orange,
                    subtitle: '${controller.unpaidCount.value} ta',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                // Jami operatsiyalar
                Expanded(
                  child: _buildStatCard(
                    title: 'Jami operatsiyalar',
                    value: '${controller.salaryOperations.length} ta',
                    icon: Icons.list_alt,
                    color: Colors.blue,
                    subtitle: controller.salaryOperations.isNotEmpty
                        ? controller.salaryOperations.first.periodString
                        : '',
                  ),
                ),
                const SizedBox(width: 12),
                // Umumiy summa
                Expanded(
                  child: _buildStatCard(
                    title: 'Umumiy summa',
                    value:
                        '${numberFormat.format(controller.totalPaidSalaries.value + controller.totalUnpaidSalaries.value)} so\'m',
                    icon: Icons.account_balance_wallet,
                    color: Colors.purple,
                    subtitle: 'Barcha maoshlar',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // STATISTIKA KARTASI
  // IZOH: Bitta statistika ko'rsatkichi uchun karta
  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    String? subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          if (subtitle != null && subtitle.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
          ],
        ],
      ),
    );
  }

  // FILTRLAR BO'LIMI
  // IZOH: Oy, yil, status va qidiruv filtrlari
  Widget _buildFiltersSection(SalaryController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          // Oy va yil tanlash
          Row(
            children: [
              // Oy tanlash
              Expanded(
                child: Obx(
                  () => DropdownButtonFormField<int>(
                    value: controller.selectedMonth.value,
                    decoration: InputDecoration(
                      labelText: 'Oy',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    items: List.generate(12, (index) {
                      final months = [
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
                      return DropdownMenuItem(
                        value: index + 1,
                        child: Text(months[index]),
                      );
                    }),
                    onChanged: (value) {
                      if (value != null) {
                        controller.changePeriod(
                          value,
                          controller.selectedYear.value,
                        );
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Yil tanlash
              Expanded(
                child: Obx(
                  () => DropdownButtonFormField<int>(
                    value: controller.selectedYear.value,
                    decoration: InputDecoration(
                      labelText: 'Yil',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    items: List.generate(5, (index) {
                      final year = DateTime.now().year - 2 + index;
                      return DropdownMenuItem(
                        value: year,
                        child: Text(year.toString()),
                      );
                    }),
                    onChanged: (value) {
                      if (value != null) {
                        controller.changePeriod(
                          controller.selectedMonth.value,
                          value,
                        );
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Status filtri va qidiruv
          Row(
            children: [
              // Status filtri
              Expanded(
                child: Obx(
                  () => SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(
                        value: 'all',
                        label: Text('Barchasi'),
                        icon: Icon(Icons.list, size: 16),
                      ),
                      ButtonSegment(
                        value: 'paid',
                        label: Text('To\'langan'),
                        icon: Icon(Icons.check_circle, size: 16),
                      ),
                      ButtonSegment(
                        value: 'unpaid',
                        label: Text('Kutilmoqda'),
                        icon: Icon(Icons.pending, size: 16),
                      ),
                    ],
                    selected: {controller.selectedStatus.value},
                    onSelectionChanged: (Set<String> selected) {
                      controller.changeStatusFilter(selected.first);
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Qidiruv
          TextField(
            onChanged: (value) => controller.search(value),
            decoration: InputDecoration(
              hintText: 'Hodim nomi yoki lavozimi bo\'yicha qidirish',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // MAOSH RO'YXATI
  // IZOH: Barcha maosh operatsiyalarini ko'rsatish
  Widget _buildSalaryList(
    SalaryController controller,
    NumberFormat numberFormat,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.filteredOperations.length,
      itemBuilder: (context, index) {
        final operation = controller.filteredOperations[index];
        return _buildSalaryCard(context, operation, controller, numberFormat);
      },
    );
  }

  // MAOSH KARTASI
  // IZOH: Bitta maosh operatsiyasi uchun karta
  Widget _buildSalaryCard(
    BuildContext context,
    operation,
    SalaryController controller,
    NumberFormat numberFormat,
  ) {
    final statusColor = operation.isPaid ? Colors.green : Colors.orange;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: statusColor.withOpacity(0.3), width: 1),
      ),
      child: InkWell(
        onTap: () =>
            _showOperationDetailsDialog(context, operation, controller),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hodim nomi va status
              Row(
                children: [
                  // Hodim avatari
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: statusColor.withOpacity(0.2),
                    child: Text(
                      operation.staffFirstName?[0] ?? 'H',
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Ism va lavozim
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          operation.staffFullName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          operation.staffPosition ?? 'Lavozim ko\'rsatilmagan',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Status belgisi
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          operation.isPaid ? Icons.check_circle : Icons.pending,
                          size: 16,
                          color: statusColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          operation.statusText,
                          style: TextStyle(
                            fontSize: 12,
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              // Maosh tafsilotlari
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildInfoColumn(
                    label: 'Asosiy maosh',
                    value: '${numberFormat.format(operation.baseAmount)} so\'m',
                    icon: Icons.attach_money,
                  ),
                  _buildInfoColumn(
                    label: 'Bonus',
                    value: operation.bonusAmount > 0
                        ? '+${numberFormat.format(operation.bonusAmount)}'
                        : '0',
                    icon: Icons.add_circle_outline,
                    color: Colors.green,
                  ),
                  _buildInfoColumn(
                    label: 'Jarima',
                    value: operation.penaltyAmount > 0
                        ? '-${numberFormat.format(operation.penaltyAmount)}'
                        : '0',
                    icon: Icons.remove_circle_outline,
                    color: Colors.red,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Chegirmalar
              if (operation.advanceDeduction > 0 || operation.loanDeduction > 0)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        size: 20,
                        color: Colors.red,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Chegirmalar: '
                          '${operation.advanceDeduction > 0 ? "Avans: ${numberFormat.format(operation.advanceDeduction)}" : ""}'
                          '${operation.advanceDeduction > 0 && operation.loanDeduction > 0 ? ", " : ""}'
                          '${operation.loanDeduction > 0 ? "Qarz: ${numberFormat.format(operation.loanDeduction)}" : ""}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 12),
              // Yakuniy summa
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'To\'lanadigan summa:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${numberFormat.format(operation.netAmount)} so\'m',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
              // To'lash tugmasi
              if (!operation.isPaid) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        _confirmPaySalary(context, operation, controller),
                    icon: const Icon(Icons.payment),
                    label: const Text('Maosh to\'lash'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // MA'LUMOT USTUNI
  // IZOH: Kichik ma'lumot ko'rsatish uchun widget
  Widget _buildInfoColumn({
    required String label,
    required String value,
    required IconData icon,
    Color? color,
  }) {
    return Column(
      children: [
        Icon(icon, size: 20, color: color ?? Colors.grey[700]),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: color ?? Colors.black87,
          ),
        ),
      ],
    );
  }

  // BO'SH HOLAT
  // IZOH: Ma'lumot yo'q bo'lganda ko'rsatiladigan widget
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Maosh operatsiyalari topilmadi',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Yangi maosh hisoblash uchun + tugmasini bosing',
            style: TextStyle(fontSize: 13, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  // MAOSH TO'LASHNI TASDIQLASH
  // IZOH: Foydalanuvchidan tasdiqlash so'rash
  void _confirmPaySalary(
    BuildContext context,
    operation,
    SalaryController controller,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Maosh to\'lash'),
        content: Text(
          '${operation.staffFullName} ga '
          '${NumberFormat('#,###', 'uz').format(operation.netAmount)} so\'m '
          'maosh to\'lashni tasdiqlaysizmi?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Bekor qilish'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              controller.paySalary(operation.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Tasdiqlash'),
          ),
        ],
      ),
    );
  }

  // OPERATSIYA TAFSILOTLARI DIALOGI
  // IZOH: To'liq tafsilotlarni ko'rsatish
  void _showOperationDetailsDialog(
    BuildContext context,
    operation,
    SalaryController controller,
  ) {
    final numberFormat = NumberFormat('#,###', 'uz');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(operation.staffFullName),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Davr', operation.periodString),
              _buildDetailRow('Lavozim', operation.staffPosition ?? 'N/A'),
              _buildDetailRow('Maosh turi', operation.staffSalaryType ?? 'N/A'),
              const Divider(),
              _buildDetailRow(
                'Asosiy maosh',
                '${numberFormat.format(operation.baseAmount)} so\'m',
              ),
              if (operation.workedDays != null)
                _buildDetailRow(
                  'Ishlagan kunlar',
                  '${operation.workedDays} kun',
                ),
              if (operation.workedHours != null)
                _buildDetailRow(
                  'Ishlagan soatlar',
                  '${operation.workedHours} soat',
                ),
              if (operation.bonusPercent > 0)
                _buildDetailRow(
                  'Bonus',
                  '+${numberFormat.format(operation.bonusAmount)} so\'m '
                      '(${operation.bonusPercent}%)',
                  color: Colors.green,
                ),
              if (operation.penaltyPercent > 0)
                _buildDetailRow(
                  'Jarima',
                  '-${numberFormat.format(operation.penaltyAmount)} so\'m '
                      '(${operation.penaltyPercent}%)',
                  color: Colors.red,
                ),
              if (operation.advanceDeduction > 0)
                _buildDetailRow(
                  'Avans ushlab qolish',
                  '-${numberFormat.format(operation.advanceDeduction)} so\'m',
                  color: Colors.orange,
                ),
              if (operation.loanDeduction > 0)
                _buildDetailRow(
                  'Qarz ushlab qolish',
                  '-${numberFormat.format(operation.loanDeduction)} so\'m',
                  color: Colors.orange,
                ),
              const Divider(),
              _buildDetailRow(
                'Gross summa',
                '${numberFormat.format(operation.grossAmount)} so\'m',
                isBold: true,
              ),
              _buildDetailRow(
                'Net summa (to\'lanadigan)',
                '${numberFormat.format(operation.netAmount)} so\'m',
                isBold: true,
                color: operation.isPaid ? Colors.green : Colors.orange,
              ),
              const Divider(),
              _buildDetailRow('Status', operation.statusText),
              if (operation.isPaid && operation.paidAt != null)
                _buildDetailRow(
                  'To\'langan vaqt',
                  DateFormat('dd.MM.yyyy HH:mm').format(operation.paidAt!),
                ),
              if (operation.notes != null && operation.notes!.isNotEmpty)
                _buildDetailRow('Izoh', operation.notes!),
            ],
          ),
        ),
        actions: [
          if (!operation.isPaid)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                controller.deleteSalaryOperation(operation.id);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('O\'chirish'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Yopish'),
          ),
        ],
      ),
    );
  }

  // TAFSILOT QATORI
  // IZOH: Dialog ichida ma'lumot ko'rsatish uchun
  Widget _buildDetailRow(
    String label,
    String value, {
    bool isBold = false,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                color: color ?? Colors.black87,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  // MAOSH HISOBLASH DIALOGI
  // IZOH: Yangi maosh hisoblash uchun forma
  void _showCalculateSalaryDialog(
    BuildContext context,
    SalaryController controller,
  ) {
    // Bu juda katta forma bo'lgani uchun, alohida screen yoki
    // maxsus widget yaratish tavsiya etiladi.
    // Bu yerda faqat placeholder ko'rsatamiz:

    Get.snackbar(
      'Xabarnoma',
      'Maosh hisoblash formasi uchun alohida screen yarating',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
