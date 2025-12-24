import 'package:flutter/material.dart';
import 'package:flutter_application_1/presentation/controllers/payment_controller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../widgets/payment_widgets.dart';

class NewPaymentScreenV4 extends StatelessWidget {
  NewPaymentScreenV4({Key? key}) : super(key: key);

  final primaryBlue = Color(0xFF2196F3);
  final darkBlue = Color(0xFF1565C0);
  final lightBlue = Color(0xFFBBDEFB);
  final paleBlue = Color(0xFFE3F2FD);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NewPaymentControllerV4());

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          _buildHeader(controller, context),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(child: CircularProgressIndicator(color: primaryBlue));
              }
              return _buildMainContent(controller, context);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(NewPaymentControllerV4 controller, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [primaryBlue, darkBlue]),
        boxShadow: [BoxShadow(color: primaryBlue.withOpacity(0.3), blurRadius: 15, offset: Offset(0, 5))],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  _buildIconButton(icon: Icons.arrow_back_ios_new, onPressed: () => Get.back()),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('TO\'LOV QABUL QILISH', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                        SizedBox(height: 4),
                        Obx(() => Text('${controller.currentStaffName.value} | ${DateFormat('dd.MM.yyyy').format(DateTime.now())}', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13))),
                      ],
                    ),
                  ),
                  _buildIconButton(icon: Icons.refresh_rounded, onPressed: () => controller.refreshData()),
                ],
              ),
              SizedBox(height: 20),
              _buildMonthSelector(controller, context),
              SizedBox(height: 20),
              _buildStatsCards(controller),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }

  Widget _buildMonthSelector(
    NewPaymentControllerV4 controller,
    BuildContext context,
  ) {
    return Obx(
      () => InkWell(
        onTap: () => controller.selectMonth(context),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.calendar_today_rounded, color: Colors.white, size: 24),
              SizedBox(width: 12),
              Text(
                controller.currentMonthYear,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 8),
              Icon(
                Icons.arrow_drop_down_rounded,
                color: Colors.white,
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCards(NewPaymentControllerV4 controller) {
    return Obx(
      () => Row(
        children: [
          Expanded(
            child: _buildStatCard(
              icon: Icons.check_circle_outline,
              label: 'To\'ladi',
              value: '${controller.currentMonthPaymentsCount.value}',
              color: Colors.white,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              icon: Icons.pending_actions_outlined,
              label: 'To\'lamadi',
              value: '${controller.unpaidStudentsCount.value}',
              color: Colors.white,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              icon: Icons.warning_amber_rounded,
              label: 'Qarzdor',
              value: '${controller.currentMonthDebtorsCount.value}',
              color: Colors.white,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              icon: Icons.attach_money_rounded,
              label: 'Tushum',
              value: _formatShortCurrency(controller.currentMonthRevenue.value),
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(color: color.withOpacity(0.9), fontSize: 11),
          ),
        ],
      ),
    );
  }

  String _formatShortCurrency(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K';
    }
    return amount.toStringAsFixed(0);
  }

  Widget _buildMainContent(
    NewPaymentControllerV4 controller,
    BuildContext context,
  ) {
    return Row(
      children: [
        Expanded(flex: 35, child: _buildStudentsPanel(controller)),
        SizedBox(width: 16),
        Expanded(flex: 65, child: _buildPaymentPanel(controller, context)),
      ],
    );
  }

  Widget _buildStudentsPanel(NewPaymentControllerV4 controller) {
    return Container(
      margin: EdgeInsets.only(left: 16, top: 16, bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: paleBlue,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.search_rounded, color: primaryBlue, size: 28),
                    SizedBox(width: 12),
                    Text(
                      'O\'quvchi qidirish',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: darkBlue,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                TextField(
                  controller: controller.searchController,
                  decoration: InputDecoration(
                    hintText: 'Ism, familiya yoki telefon...',
                    prefixIcon: Icon(Icons.search_rounded, color: primaryBlue),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.clear_rounded, color: Colors.grey),
                      onPressed: () => controller.clearSearch(),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: primaryBlue, width: 2),
                    ),
                  ),
                  onSubmitted: (_) => controller.searchStudents(),
                ),
                SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => controller.searchStudents(),
                    icon: Icon(Icons.search_rounded),
                    label: Text('QIDIRISH'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isSearching.value) {
                return Center(
                  child: CircularProgressIndicator(color: primaryBlue),
                );
              }

              if (controller.searchResults.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off_rounded,
                        size: 80,
                        color: Colors.grey[300],
                      ),
                      SizedBox(height: 20),
                      Text(
                        'O\'quvchi topilmadi',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                padding: EdgeInsets.all(16),
                itemCount: controller.searchResults.length,
                separatorBuilder: (_, __) => SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final student = controller.searchResults[index];
                  final isSelected =
                      controller.selectedStudentId.value == student.id;
                  final hasPaid =
                      student.toJson()['has_paid_current_month'] == true;

                  return _buildStudentCard(
                    controller,
                    student,
                    isSelected,
                    hasPaid,
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard(
    NewPaymentControllerV4 controller,
    dynamic student,
    bool isSelected,
    bool hasPaid,
  ) {
    return InkWell(
      onTap: () => controller.selectStudent(student),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? paleBlue : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? primaryBlue : Colors.grey[200]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: hasPaid ? Colors.green : Colors.grey[400],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      student.firstName[0].toUpperCase(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                if (hasPaid)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Icon(Icons.check, color: Colors.white, size: 12),
                    ),
                  ),
              ],
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student.fullName,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? darkBlue : Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.class_rounded, size: 14, color: primaryBlue),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          student.classFullName,
                          style: TextStyle(
                            fontSize: 13,
                            color: primaryBlue,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: hasPaid ? Colors.green[100] : Colors.orange[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                hasPaid ? 'To\'ladi' : 'To\'lamadi',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: hasPaid ? Colors.green[700] : Colors.orange[700],
                ),
              ),
            ),
            if (isSelected)
              Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(Icons.check_circle, color: primaryBlue),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentPanel(NewPaymentControllerV4 controller, BuildContext context) {
    return Obx(() {
      if (controller.selectedStudent.value == null) {
        return _buildEmptyState();
      }

      return SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: controller.formKey,
          child: Column(
            children: [
              _buildSelectedStudentCard(controller),
              SizedBox(height: 16),
              _buildPaymentHistoryCard(controller),
              SizedBox(height: 16),
              _buildDebtsSection(controller),
              SizedBox(height: 16),
              _buildPaymentDetailsCard(controller, context), // Context berildi
              SizedBox(height: 16),
              _buildSaveButton(controller),
            ],
          ),
        ),
      );
    });
  }
  Widget _buildEmptyState() {
    return Container(
      margin: EdgeInsets.only(right: 16, top: 16, bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: paleBlue,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_search_rounded,
                size: 80,
                color: primaryBlue,
              ),
            ),
            SizedBox(height: 30),
            Text(
              'O\'quvchini tanlang',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: darkBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedStudentCard(NewPaymentControllerV4 controller) {
    return Obx(() {
      final student = controller.selectedStudent.value!;
      return Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: primaryBlue, width: 2),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: primaryBlue,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Center(
                    child: Text(
                      student.firstName[0].toUpperCase(),
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
                        student.fullName,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: darkBlue,
                        ),
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.class_rounded,
                            size: 16,
                            color: primaryBlue,
                          ),
                          SizedBox(width: 6),
                          Text(
                            student.classFullName,
                            style: TextStyle(
                              color: primaryBlue,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      if (student.mainTeacherName != null) ...[
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.person_outline,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Rahbar: ${student.mainTeacherName}',
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => controller.clearSelection(),
                  icon: Icon(Icons.close_rounded, color: Colors.grey),
                ),
              ],
            ),
            SizedBox(height: 16),
            Divider(),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildInfoChip(
                    icon: Icons.phone,
                    label: student.parentPhone,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildInfoChip(
                    icon: Icons.attach_money_rounded,
                    label:
                        '${controller.formatCurrency(student.monthlyFee)} so\'m/oy',
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildInfoChip({required IconData icon, required String label}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: paleBlue,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: primaryBlue),
          SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: darkBlue,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentHistoryCard(NewPaymentControllerV4 controller) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.history_rounded, color: primaryBlue, size: 24),
                  SizedBox(width: 12),
                  Text(
                    'TO\'LOV TARIXI',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: darkBlue,
                    ),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: () => controller.showPaymentHistory(),
                icon: Icon(Icons.open_in_new_rounded, size: 18),
                label: Text('BARCHASI'),
                style: TextButton.styleFrom(foregroundColor: primaryBlue),
              ),
            ],
          ),
          SizedBox(height: 16),
          Obx(() {
            if (controller.isLoadingHistory.value) {
              return Center(
                child: CircularProgressIndicator(color: primaryBlue),
              );
            }

            if (controller.paymentHistory.isEmpty) {
              return Text(
                'Hali to\'lov qilinmagan',
                style: TextStyle(color: Colors.grey),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: controller.paymentHistory.length > 3
                  ? 3
                  : controller.paymentHistory.length,
              separatorBuilder: (_, __) => Divider(),
              itemBuilder: (context, index) {
                final payment = controller.paymentHistory[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.check_circle, color: Colors.green),
                  title: Text(
                    payment.periodText,
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    DateFormat('dd.MM.yyyy').format(payment.paymentDate),
                  ),
                  trailing: Text(
                    '${controller.formatCurrency(payment.finalAmount)} so\'m',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: primaryBlue,
                    ),
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDebtsSection(NewPaymentControllerV4 controller) {
    return Obx(() {
      if (controller.studentDebts.isEmpty) return SizedBox.shrink();

      return Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.orange[200]!, width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.orange[700]),
                SizedBox(width: 12),
                Text(
                  'QARZLAR (${controller.studentDebts.length})',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[900],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: controller.studentDebts.length,
              itemBuilder: (context, index) {
                final debt = controller.studentDebts[index];
                final isSelected = controller.selectedDebts.contains(debt.id);

                return CheckboxListTile(
                  value: isSelected,
                  onChanged: (_) => controller.toggleDebtSelection(debt.id),
                  title: Text(debt.periodText),
                  subtitle: Text(
                    debt.isOverdue
                        ? '${debt.daysOverdue} kun kechikkan'
                        : debt.dueDate != null
                        ? 'Muddati: ${DateFormat('dd.MM.yyyy').format(debt.dueDate!)}'
                        : 'Muddati belgilanmagan',
                    style: TextStyle(
                      color: debt.isOverdue ? Colors.red : Colors.grey,
                    ),
                  ),
                  secondary: Text(
                    '${controller.formatCurrency(debt.remainingAmount)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[700],
                    ),
                  ),
                  activeColor: Colors.orange[700],
                );
              },
            ),

            if (controller.selectedDebts.isNotEmpty) ...[
              Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Jami tanlangan:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${controller.formatCurrency(controller.totalSelectedDebts.value)} so\'m',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[700],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      );
    });
  }

 Widget _buildPaymentDetailsCard(NewPaymentControllerV4 controller, BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.payment_rounded, color: primaryBlue, size: 24),
                  SizedBox(width: 12),
                  Text('TO\'LOV MA\'LUMOTLARI', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkBlue)),
                ],
              ),
              // YANGI: Sana tanlash
              TextButton.icon(
                onPressed: () => controller.selectPaymentDate(context),
                icon: Icon(Icons.calendar_month, color: primaryBlue),
                label: Obx(() => Text(DateFormat('dd.MM.yyyy').format(controller.paymentDate.value), style: TextStyle(fontWeight: FontWeight.bold, color: primaryBlue))),
              ),
            ],
          ),
          SizedBox(height: 20),
          TextFormField(
            controller: controller.amountController,
            keyboardType: TextInputType.number,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              labelText: 'Summa *', hintText: '500000', suffixText: 'so\'m',
              prefixIcon: Icon(Icons.attach_money_rounded, color: primaryBlue),
              filled: true, fillColor: paleBlue,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onChanged: (_) => controller.calculateFinalAmount(),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Obx(() => DropdownButtonFormField<String>(
                  value: controller.paymentMethod.value,
                  decoration: InputDecoration(labelText: 'To\'lov usuli *', filled: true, fillColor: paleBlue, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                  items: [
                    DropdownMenuItem(value: 'cash', child: Text('Naqd')),
                    DropdownMenuItem(value: 'click', child: Text('Click')),
                    DropdownMenuItem(value: 'terminal', child: Text('Terminal')),
                    DropdownMenuItem(value: 'owner_fund', child: Text('Ega kassasi')),
                  ],
                  onChanged: (v) => controller.paymentMethod.value = v!,
                )),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Obx(() => DropdownButtonFormField<String>(
                  value: controller.paymentType.value,
                  decoration: InputDecoration(labelText: 'To\'lov turi *', filled: true, fillColor: paleBlue, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                  items: [
                    DropdownMenuItem(value: 'tuition', child: Text('Oylik to\'lov')),
                    DropdownMenuItem(value: 'registration', child: Text('Ro\'yxatga olish')),
                    DropdownMenuItem(value: 'exam', child: Text('Imtihon')),
                    DropdownMenuItem(value: 'other', child: Text('Boshqa')),
                  ],
                  onChanged: (v) => controller.paymentType.value = v!,
                )),
              ),
            ],
          ),
          SizedBox(height: 20),
          PaymentDetailsWidgets.buildDiscountSection(controller),
          SizedBox(height: 20),
          PaymentDetailsWidgets.buildFinalAmountDisplay(controller),
          SizedBox(height: 20),
          PaymentDetailsWidgets.buildPartialPaymentSection(controller),
          SizedBox(height: 20),
          TextFormField(
            controller: controller.notesController,
            decoration: InputDecoration(labelText: 'Qo\'shimcha izoh', prefixIcon: Icon(Icons.note_alt_rounded, color: primaryBlue), filled: true, fillColor: paleBlue, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(NewPaymentControllerV4 controller) {
    return Obx(
      () => SizedBox(
        width: double.infinity,
        height: 60,
        child: ElevatedButton.icon(
          // O'ZGARTIRILDI: confirmPayment chaqiriladi
          onPressed: controller.isLoading.value
              ? null
              : () => controller.confirmPayment(),
          icon: controller.isLoading.value
              ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Icon(Icons.check_circle_rounded, size: 28),
          label: Text(
            controller.isLoading.value
                ? 'SAQLANMOQDA...'
                : 'TO\'LOVNI QABUL QILISH',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryBlue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}
