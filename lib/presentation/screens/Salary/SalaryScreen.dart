// lib/presentation/screens/finance/complete_salary_screen.dart
// TO'LIQ MAOSH BOSHQARUVI EKRANI - Barcha funksiyalar

import 'package:flutter/material.dart';
import 'package:flutter_application_1/presentation/controllers/SalaryController.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../config/constants.dart';

class CompleteSalaryScreen extends StatelessWidget {
  const CompleteSalaryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CompleteSalaryController());

    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(_getViewTitle(controller.currentView.value))),
        elevation: 0,
        actions: [
          // Export tugmasi
          Obx(() {
            if (controller.currentView.value == 'list' &&
                controller.filteredOperations.isNotEmpty) {
              return IconButton(
                icon: const Icon(Icons.file_download),
                onPressed: controller.exportToCSV,
                tooltip: 'CSV yuklab olish',
              );
            }
            return const SizedBox();
          }),
        ],
      ),
      body: Obx(() => _buildCurrentView(controller)),
      bottomNavigationBar: _buildBottomNavigation(controller),
    );
  }

  // ASOSIY VIEW
  Widget _buildCurrentView(CompleteSalaryController controller) {
    switch (controller.currentView.value) {
      case 'list':
        return _buildListView(controller);
      case 'calculate':
        return _buildCalculateView(controller);
      case 'history':
        return _buildHistoryView(controller);
      case 'advances':
        return _buildAdvancesView(controller);
      case 'loans':
        return _buildLoansView(controller);
      default:
        return _buildListView(controller);
    }
  }

  // 1. RO'YXAT VIEW
  Widget _buildListView(CompleteSalaryController controller) {
    return Column(
      children: [
        // Filtrlar va statistika
        _buildFilterAndStats(controller),
        
        // Ro'yxat
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.filteredOperations.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.receipt_long, size: 64, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    Text(
                      'Maosh operatsiyalari topilmadi',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: () => controller.changeView('calculate'),
                      icon: const Icon(Icons.calculate),
                      label: const Text('Maosh hisoblash'),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: controller.loadSalaryOperations,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.filteredOperations.length,
                itemBuilder: (context, index) {
                  final operation = controller.filteredOperations[index];
                  return _buildSalaryCard(operation, controller);
                },
              ),
            );
          }),
        ),
      ],
    );
  }

  // FILTR VA STATISTIKA
  Widget _buildFilterAndStats(CompleteSalaryController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          // Filial, Oy, Yil
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Obx(() => DropdownButtonFormField<String>(
                  value: controller.selectedBranchId.value,
                  decoration: InputDecoration(
                    labelText: 'Filial',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items: controller.branches.map((branch) {
                    return DropdownMenuItem<String>(
                      value: branch['id'] as String,
                      child: Text(branch['name']),
                    );
                  }).toList(),
                  onChanged: controller.changeBranch,
                )),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Obx(() => DropdownButtonFormField<int>(
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
                  items: List.generate(12, (i) {
                    const months = [
                      'Yan', 'Fev', 'Mar', 'Apr', 'May', 'Iyun',
                      'Iyul', 'Avg', 'Sen', 'Okt', 'Noy', 'Dek',
                    ];
                    return DropdownMenuItem(
                      value: i + 1,
                      child: Text(months[i]),
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
                )),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Obx(() => DropdownButtonFormField<int>(
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
                  items: List.generate(5, (i) {
                    final year = DateTime.now().year - 2 + i;
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
                )),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Qidiruv va filtr
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Hodim qidirish...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  onChanged: controller.search,
                ),
              ),
              const SizedBox(width: 8),
              Obx(() => SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'all',
                    label: Text('Barchasi'),
                  ),
                  ButtonSegment(
                    value: 'paid',
                    label: Text('To\'langan'),
                  ),
                  ButtonSegment(
                    value: 'unpaid',
                    label: Text('Kutilmoqda'),
                  ),
                ],
                selected: {controller.selectedStatus.value},
                onSelectionChanged: (Set<String> newSelection) {
                  controller.changeStatusFilter(newSelection.first);
                },
              )),
            ],
          ),
          const SizedBox(height: 12),
          
          // Statistika
          Obx(() => Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'To\'langan',
                  controller.formatCurrency(controller.totalPaid.value),
                  controller.paidCount.value.toString(),
                  Colors.green,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  'Kutilmoqda',
                  controller.formatCurrency(controller.totalUnpaid.value),
                  controller.unpaidCount.value.toString(),
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  'Jami',
                  controller.formatCurrency(controller.totalGross.value),
                  (controller.paidCount.value + controller.unpaidCount.value)
                      .toString(),
                  AppConstants.primaryColor,
                ),
              ),
            ],
          )),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String amount, String count, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            '$count ta',
            style: TextStyle(
              fontSize: 11,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // MAOSH KARTOCHKASI
  Widget _buildSalaryCard(
    Map<String, dynamic> operation,
    CompleteSalaryController controller,
  ) {
    final staff = operation['staff'];
    final isPaid = operation['is_paid'] == true;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showSalaryDetails(operation, controller),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppConstants.primaryColor.withOpacity(0.1),
                    backgroundImage: staff?['photo_url'] != null
                        ? NetworkImage(staff['photo_url'])
                        : null,
                    child: staff?['photo_url'] == null
                        ? Text(
                            '${staff?['first_name']?[0] ?? ''}${staff?['last_name']?[0] ?? ''}'
                                .toUpperCase(),
                            style: TextStyle(
                              color: AppConstants.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  
                  // Ma'lumotlar
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${staff?['first_name'] ?? ''} ${staff?['last_name'] ?? ''}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          staff?['position'] ?? '',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: isPaid
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                isPaid ? 'To\'langan' : 'Kutilmoqda',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isPaid ? Colors.green : Colors.orange,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${operation['worked_days'] ?? 0} kun',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Summa
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${controller.formatCurrency(operation['net_amount'] ?? 0)} so\'m',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isPaid
                              ? AppConstants.successColor
                              : Colors.orange,
                        ),
                      ),
                      if (!isPaid)
                        TextButton(
                          onPressed: () => _confirmPayment(operation, controller),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'To\'lash',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 2. HISOBLASH VIEW
  Widget _buildCalculateView(CompleteSalaryController controller) {
    return Obx(() {
      if (controller.calculationResults.isNotEmpty) {
        return _buildCalculationResults(controller);
      }
      return _buildStaffSelection(controller);
    });
  }

  Widget _buildStaffSelection(CompleteSalaryController controller) {
    return Column(
      children: [
        // Filter va tanlash
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    'Tanlandi: ${controller.selectedStaffIds.length} / ${controller.staffList.length}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: controller.selectAllStaff,
                    child: const Text('Barchasi'),
                  ),
                  TextButton(
                    onPressed: controller.deselectAllStaff,
                    child: const Text('Bekor qilish'),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Hodimlar ro'yxati
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.staffList.isEmpty) {
              return const Center(
                child: Text('Hodimlar topilmadi'),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: controller.staffList.length,
              itemBuilder: (context, index) {
                final staff = controller.staffList[index];
                final staffId = staff['id'] as String;
                final isSelected = controller.selectedStaffIds.contains(staffId);

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSelected
                          ? AppConstants.primaryColor
                          : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: CheckboxListTile(
                    value: isSelected,
                    onChanged: (_) => controller.toggleStaffSelection(staffId),
                    secondary: CircleAvatar(
                      backgroundColor:
                          AppConstants.primaryColor.withOpacity(0.1),
                      backgroundImage: staff['photo_url'] != null
                          ? NetworkImage(staff['photo_url'])
                          : null,
                      child: staff['photo_url'] == null
                          ? Text(
                              '${staff['first_name'][0]}${staff['last_name'][0]}'
                                  .toUpperCase(),
                              style: TextStyle(
                                color: AppConstants.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                    title: Text(
                      '${staff['first_name']} ${staff['last_name']}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(staff['position'] ?? ''),
                        const SizedBox(height: 4),
                        Text(
                          _getSalaryInfo(staff),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
        ),
        
        // Hisoblash tugmasi
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
              ),
            ],
          ),
          child: Obx(() => ElevatedButton(
            onPressed: controller.isCalculating.value ||
                    controller.selectedStaffIds.isEmpty
                ? null
                : controller.calculateSalaries,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              minimumSize: const Size.fromHeight(50),
            ),
            child: controller.isCalculating.value
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Maosh hisoblash',
                    style: TextStyle(fontSize: 16),
                  ),
          )),
        ),
      ],
    );
  }

  Widget _buildCalculationResults(CompleteSalaryController controller) {
    final results = controller.calculationResults;
    final totalNet = results.fold<double>(
      0,
      (sum, r) => sum + (r['net_amount'] ?? 0),
    );

    return Column(
      children: [
        // Umumiy ma'lumot
        Container(
          padding: const EdgeInsets.all(16),
          color: AppConstants.primaryColor.withOpacity(0.1),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  const Text('Hodimlar'),
                  Text(
                    '${results.length}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  const Text('Jami summa'),
                  Text(
                    controller.formatCurrency(totalNet),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.successColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Natijalar ro'yxati
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: results.length,
            itemBuilder: (context, index) {
              final result = results[index];
              return _buildResultCard(result, controller);
            },
          ),
        ),
        
        // Saqlash tugmalari
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    controller.calculationResults.clear();
                  },
                  child: const Text('Bekor qilish'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: Obx(() => ElevatedButton(
                  onPressed: controller.isCalculating.value
                      ? null
                      : controller.saveSalaries,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: controller.isCalculating.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Saqlash'),
                )),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResultCard(
    Map<String, dynamic> result,
    CompleteSalaryController controller,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: AppConstants.successColor.withOpacity(0.1),
          child: const Icon(Icons.check, color: AppConstants.successColor),
        ),
        title: Text(
          result['staff_name'],
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(result['position']),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${controller.formatCurrency(result['net_amount'])}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppConstants.successColor,
              ),
            ),
            const Text(
              'so\'m',
              style: TextStyle(fontSize: 11),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildDetailRow(
                  'Asosiy maosh',
                  '${controller.formatCurrency(result['base_amount'])} so\'m',
                ),
                _buildDetailRow(
                  'Ishlagan kunlar',
                  '${result['worked_days']} kun',
                ),
                _buildDetailRow(
                  'Ishlagan soatlar',
                  '${result['worked_hours'].toStringAsFixed(1)} soat',
                ),
                if (result['bonus_amount'] > 0)
                  _buildDetailRow(
                    'Bonus (${result['bonus_percent']}%)',
                    '${controller.formatCurrency(result['bonus_amount'])} so\'m',
                    color: Colors.green,
                  ),
                if (result['penalty_amount'] > 0)
                  _buildDetailRow(
                    'Jarima (${result['penalty_percent']}%)',
                    '${controller.formatCurrency(result['penalty_amount'])} so\'m',
                    color: Colors.red,
                  ),
                if (result['advance_deduction'] > 0)
                  _buildDetailRow(
                    'Avans chegirma',
                    '${controller.formatCurrency(result['advance_deduction'])} so\'m',
                    color: Colors.orange,
                  ),
                if (result['loan_deduction'] > 0)
                  _buildDetailRow(
                    'Qarz chegirma',
                    '${controller.formatCurrency(result['loan_deduction'])} so\'m',
                    color: Colors.orange,
                  ),
                if (result['late_deductions'] > 0)
                  _buildDetailRow(
                    'Kechikish jarimasi',
                    '${controller.formatCurrency(result['late_deductions'])} so\'m',
                    color: Colors.red,
                  ),
                if (result['early_leave_deductions'] > 0)
                  _buildDetailRow(
                    'Erta ketish jarimasi',
                    '${controller.formatCurrency(result['early_leave_deductions'])} so\'m',
                    color: Colors.red,
                  ),
                const Divider(height: 24),
                _buildDetailRow(
                  'Gross summa',
                  '${controller.formatCurrency(result['gross_amount'])} so\'m',
                  isBold: true,
                ),
                _buildDetailRow(
                  'Net summa (to\'lanadigan)',
                  '${controller.formatCurrency(result['net_amount'])} so\'m',
                  isBold: true,
                  color: AppConstants.successColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 3. TARIX VIEW
  Widget _buildHistoryView(CompleteSalaryController controller) {
    return Column(
      children: [
        // Sana filtri
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: Get.context!,
                      initialDate: controller.historyStartDate.value,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      controller.historyStartDate.value = date;
                      controller.loadSalaryHistory();
                    }
                  },
                  icon: const Icon(Icons.calendar_today, size: 16),
                  label: Obx(() => Text(
                    DateFormat('dd.MM.yyyy')
                        .format(controller.historyStartDate.value),
                  )),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text('-'),
              ),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: Get.context!,
                      initialDate: controller.historyEndDate.value,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      controller.historyEndDate.value = date;
                      controller.loadSalaryHistory();
                    }
                  },
                  icon: const Icon(Icons.calendar_today, size: 16),
                  label: Obx(() => Text(
                    DateFormat('dd.MM.yyyy')
                        .format(controller.historyEndDate.value),
                  )),
                ),
              ),
            ],
          ),
        ),
        
        // Tarix ro'yxati
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.salaryHistory.isEmpty) {
              return const Center(
                child: Text('Tarix topilmadi'),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: controller.salaryHistory.length,
              itemBuilder: (context, index) {
                final operation = controller.salaryHistory[index];
                return _buildHistoryCard(operation, controller);
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildHistoryCard(
    Map<String, dynamic> operation,
    CompleteSalaryController controller,
  ) {
    final staff = operation['staff'];
    final isPaid = operation['is_paid'] == true;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: staff?['photo_url'] != null
              ? NetworkImage(staff['photo_url'])
              : null,
          child: staff?['photo_url'] == null
              ? Text(
                  '${staff?['first_name']?[0] ?? ''}${staff?['last_name']?[0] ?? ''}'
                      .toUpperCase(),
                )
              : null,
        ),
        title: Text('${staff?['first_name'] ?? ''} ${staff?['last_name'] ?? ''}'),
        subtitle: Text(
          '${_formatDate(operation['created_at'])} • ${operation['operation_type']}',
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${controller.formatCurrency(operation['net_amount'])} so\'m',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isPaid ? Colors.green : Colors.orange,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isPaid
                    ? Colors.green.withOpacity(0.1)
                    : Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                isPaid ? 'To\'langan' : 'Kutilmoqda',
                style: TextStyle(
                  fontSize: 10,
                  color: isPaid ? Colors.green : Colors.orange,
                ),
              ),
            ),
          ],
        ),
        onTap: () => _showSalaryDetails(operation, controller),
      ),
    );
  }

  // 4. AVANSLAR VIEW
  Widget _buildAdvancesView(CompleteSalaryController controller) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.advancesList.isEmpty) {
        return const Center(
          child: Text('Avanslar topilmadi'),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.advancesList.length,
        itemBuilder: (context, index) {
          final advance = controller.advancesList[index];
          final staff = advance['staff'];
          final isDeducted = advance['is_deducted'] == true;

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Icon(
                Icons.payments,
                color: isDeducted ? Colors.grey : Colors.orange,
              ),
              title: Text(
                '${staff?['first_name'] ?? ''} ${staff?['last_name'] ?? ''}',
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(staff?['position'] ?? ''),
                  Text(
                    _formatDate(advance['advance_date']),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${controller.formatCurrency(advance['amount'])} so\'m',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDeducted ? Colors.grey : Colors.orange,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: isDeducted
                          ? Colors.grey.withOpacity(0.1)
                          : Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      isDeducted ? 'Ushlab qolingan' : 'Kutilmoqda',
                      style: TextStyle(
                        fontSize: 10,
                        color: isDeducted ? Colors.grey : Colors.orange,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  // 5. QARZLAR VIEW
  Widget _buildLoansView(CompleteSalaryController controller) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.loansList.isEmpty) {
        return const Center(
          child: Text('Qarzlar topilmadi'),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.loansList.length,
        itemBuilder: (context, index) {
          final loan = controller.loansList[index];
          final staff = loan['staff'];
          final isSettled = loan['is_settled'] == true;
          final progress = (loan['loan_amount'] - loan['remaining_amount']) /
              loan['loan_amount'];

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.account_balance_wallet,
                        color: isSettled ? Colors.grey : Colors.red,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${staff?['first_name'] ?? ''} ${staff?['last_name'] ?? ''}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              staff?['position'] ?? '',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isSettled
                              ? Colors.grey.withOpacity(0.1)
                              : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          isSettled ? 'To\'langan' : 'Faol',
                          style: TextStyle(
                            fontSize: 11,
                            color: isSettled ? Colors.grey : Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Qarz summasi',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            '${controller.formatCurrency(loan['loan_amount'])} so\'m',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Qoldiq',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            '${controller.formatCurrency(loan['remaining_amount'])} so\'m',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isSettled ? Colors.grey : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey[200],
                    color: isSettled ? Colors.grey : Colors.red,
                  ),
                  const SizedBox(height: 4),
                  
                  Text(
                    'Oylik to\'lov: ${controller.formatCurrency(loan['monthly_deduction'])} so\'m',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  // PASTKI NAVIGATSIYA
  Widget _buildBottomNavigation(CompleteSalaryController controller) {
    return Obx(() => BottomNavigationBar(
      currentIndex: _getNavIndex(controller.currentView.value),
      onTap: (index) {
        final views = ['list', 'calculate', 'history', 'advances', 'loans'];
        controller.changeView(views[index]);
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppConstants.primaryColor,
      unselectedItemColor: Colors.grey,
      selectedFontSize: 12,
      unselectedFontSize: 11,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.list),
          label: 'Ro\'yxat',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calculate),
          label: 'Hisoblash',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.history),
          label: 'Tarix',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.payments),
          label: 'Avanslar',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_balance_wallet),
          label: 'Qarzlar',
        ),
      ],
    ));
  }

  // YORDAMCHI FUNKSIYALAR
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
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  void _showSalaryDetails(
    Map<String, dynamic> operation,
    CompleteSalaryController controller,
  ) {
    final staff = operation['staff'];
    final isPaid = operation['is_paid'] == true;

    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: staff?['photo_url'] != null
                            ? NetworkImage(staff['photo_url'])
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${staff?['first_name'] ?? ''} ${staff?['last_name'] ?? ''}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(staff?['position'] ?? ''),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  
                  _buildDetailRow('Asosiy maosh',
                      '${controller.formatCurrency(operation['base_amount'])} so\'m'),
                  _buildDetailRow('Ishlagan kunlar',
                      '${operation['worked_days']} kun'),
                  _buildDetailRow('Ishlagan soatlar',
                      '${operation['worked_hours']} soat'),
                  
                  if (operation['bonus_amount'] > 0)
                    _buildDetailRow(
                      'Bonus (${operation['bonus_percent']}%)',
                      '${controller.formatCurrency(operation['bonus_amount'])} so\'m',
                      color: Colors.green,
                    ),
                  
                  if (operation['penalty_amount'] > 0)
                    _buildDetailRow(
                      'Jarima (${operation['penalty_percent']}%)',
                      '${controller.formatCurrency(operation['penalty_amount'])} so\'m',
                      color: Colors.red,
                    ),
                  
                  if (operation['advance_deduction'] > 0)
                    _buildDetailRow(
                      'Avans chegirma',
                      '${controller.formatCurrency(operation['advance_deduction'])} so\'m',
                      color: Colors.orange,
                    ),
                  
                  if (operation['loan_deduction'] > 0)
                    _buildDetailRow(
                      'Qarz chegirma',
                      '${controller.formatCurrency(operation['loan_deduction'])} so\'m',
                      color: Colors.orange,
                    ),
                  
                  const Divider(height: 24),
                  
                  _buildDetailRow(
                    'Gross summa',
                    '${controller.formatCurrency(operation['gross_amount'])} so\'m',
                    isBold: true,
                  ),
                  
                  _buildDetailRow(
                    'Net summa',
                    '${controller.formatCurrency(operation['net_amount'])} so\'m',
                    isBold: true,
                    color: AppConstants.successColor,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      if (!isPaid) ...[
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Get.back();
                              _confirmPayment(operation, controller);
                            },
                            icon: const Icon(Icons.payment),
                            label: const Text('To\'lash'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppConstants.successColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Get.back();
                            _confirmDelete(operation, controller);
                          },
                          icon: const Icon(Icons.delete),
                          label: const Text('O\'chirish'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _confirmPayment(
    Map<String, dynamic> operation,
    CompleteSalaryController controller,
  ) {
    Get.dialog(
      AlertDialog(
        title: const Text('Maosh to\'lash'),
        content: Text(
          'Maoshni to\'lashni tasdiqlaysizmi?\n\nSumma: ${controller.formatCurrency(operation['net_amount'])} so\'m',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Bekor qilish'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.paySalary(operation['id']);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.successColor,
            ),
            child: const Text('To\'lash'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(
    Map<String, dynamic> operation,
    CompleteSalaryController controller,
  ) {
    Get.dialog(
      AlertDialog(
        title: const Text('O\'chirish'),
        content: const Text('Bu maosh operatsiyasini o\'chirishni xohlaysizmi?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Bekor qilish'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.deleteSalaryOperation(operation['id']);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('O\'chirish'),
          ),
        ],
      ),
    );
  }

  String _getViewTitle(String view) {
    switch (view) {
      case 'list':
        return 'Maosh ro\'yxati';
      case 'calculate':
        return 'Maosh hisoblash';
      case 'history':
        return 'Maosh tarixi';
      case 'advances':
        return 'Avanslar';
      case 'loans':
        return 'Qarzlar';
      default:
        return 'Maosh';
    }
  }

  int _getNavIndex(String view) {
    switch (view) {
      case 'list':
        return 0;
      case 'calculate':
        return 1;
      case 'history':
        return 2;
      case 'advances':
        return 3;
      case 'loans':
        return 4;
      default:
        return 0;
    }
  }

  String _getSalaryInfo(Map<String, dynamic> staff) {
    final type = staff['salary_type'];
    final numberFormat = NumberFormat('#,###');

    switch (type) {
      case 'monthly':
        return 'Oylik: ${numberFormat.format(staff['base_salary'] ?? 0)} so\'m';
      case 'hourly':
        return 'Soatlik: ${numberFormat.format(staff['hourly_rate'] ?? 0)} so\'m';
      case 'daily':
        return 'Kunlik: ${numberFormat.format(staff['daily_rate'] ?? 0)} so\'m';
      default:
        return 'N/A';
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return '';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd.MM.yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }
}