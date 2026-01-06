// lib/presentation/screens/new_payment_screen_v5.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_1/presentation/controllers/payment_controller.dart';
import 'package:flutter_application_1/presentation/widgets/payment_widgets.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class NewPaymentScreenV5 extends StatelessWidget {
  NewPaymentScreenV5({Key? key}) : super(key: key);

  final primaryBlue = Color(0xFF0D47A1); // Quyuqroq ko'k
  final accentBlue = Color(0xFF2196F3); // Yorqin ko'k
  final lightBlue = Color(0xFFE3F2FD); // Och ko'k
  final white = Colors.white;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NewPaymentControllerV5());

    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      body: Obx(() {
        // Branch selector (agar biriktirilmagan bo'lsa)
        if (controller.showBranchSelector.value) {
          return _buildBranchSelector(controller, context);
        }

        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator(color: accentBlue));
        }

        return Column(
          children: [
            _buildModernHeader(controller, context),
            Expanded(child: _buildMainContent(controller, context)),
          ],
        );
      }),
    );
  }

  // ============================================================================
  // BRANCH SELECTOR
  // ============================================================================
  Widget _buildBranchSelector(
    NewPaymentControllerV5 controller,
    BuildContext context,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryBlue, accentBlue],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Center(
          child: Container(
            width: 500,
            margin: EdgeInsets.all(32),
            padding: EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.business_rounded, size: 80, color: accentBlue),
                SizedBox(height: 24),
                Text(
                  'FILIALNI TANLANG',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: primaryBlue,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Davom etish uchun filialni tanlang',
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32),
                Obx(
                  () => ListView.separated(
                    shrinkWrap: true,
                    itemCount: controller.availableBranches.length,
                    separatorBuilder: (_, __) => SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final branch = controller.availableBranches[index];
                      return InkWell(
                        onTap: () => controller.selectBranch(branch['id']),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: lightBlue,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: accentBlue.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: accentBlue,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.apartment_rounded,
                                  color: white,
                                  size: 28,
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      branch['name'],
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: primaryBlue,
                                      ),
                                    ),
                                    if (branch['address'] != null)
                                      Text(
                                        branch['address'],
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: accentBlue,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================================
  // MODERN HEADER
  // ============================================================================
  Widget _buildModernHeader(
    NewPaymentControllerV5 controller,
    BuildContext context,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryBlue, accentBlue],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: () => Get.back(),
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: white,
                        size: 20,
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TO\'LOV QABUL QILISH',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: primaryBlue,
                          ),
                        ),
                        SizedBox(height: 4),
                        Obx(
                          () => Text(
                            '${controller.currentStaffName.value} | ${DateFormat('dd.MM.yyyy').format(DateTime.now())}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryBlue, accentBlue],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: () => controller.refreshData(),
                      icon: Icon(Icons.refresh_rounded, color: white, size: 22),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              _buildMonthSelector(controller, context),
              SizedBox(height: 20),
              _buildStatsRow(controller),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMonthSelector(
    NewPaymentControllerV5 controller,
    BuildContext context,
  ) {
    return Obx(
      () => InkWell(
        onTap: () => controller.selectMonth(context),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [primaryBlue, accentBlue]),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: accentBlue.withOpacity(0.3),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.calendar_month_rounded, color: white, size: 24),
              SizedBox(width: 12),
              Text(
                controller.currentMonthYear,
                style: TextStyle(
                  color: white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 8),
              Icon(
                Icons.arrow_drop_down_circle_rounded,
                color: white,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow(NewPaymentControllerV5 controller) {
    return Obx(
      () => Row(
        children: [
          Expanded(
            child: _buildStatCard(
              Icons.check_circle,
              'To\'ladi',
              '${controller.currentMonthPaymentsCount.value}',
              Colors.green,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              Icons.pending_actions,
              'To\'lamadi',
              '${controller.unpaidStudentsCount.value}',
              Colors.orange,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              Icons.warning_amber,
              'Qarzdor',
              '${controller.currentMonthDebtorsCount.value}',
              Colors.red,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              Icons.attach_money,
              'Tushum',
              _formatShortCurrency(controller.currentMonthRevenue.value),
              accentBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2), width: 2),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: primaryBlue,
            ),
          ),
          SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
        ],
      ),
    );
  }

  String _formatShortCurrency(double amount) {
    if (amount >= 1000000) return '${(amount / 1000000).toStringAsFixed(1)}M';
    if (amount >= 1000) return '${(amount / 1000).toStringAsFixed(0)}K';
    return amount.toStringAsFixed(0);
  }

  // ============================================================================
  // MAIN CONTENT
  // ============================================================================
  Widget _buildMainContent(
    NewPaymentControllerV5 controller,
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

  // ============================================================================
  // STUDENTS PANEL
  // ============================================================================
  Widget _buildStudentsPanel(NewPaymentControllerV5 controller) {
    return Container(
      margin: EdgeInsets.only(left: 16, top: 16, bottom: 16),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
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
              color: lightBlue,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.search_rounded, color: accentBlue, size: 28),
                    SizedBox(width: 12),
                    Text(
                      'O\'quvchi qidirish',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryBlue,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                TextField(
                  controller: controller.searchController,
                  decoration: InputDecoration(
                    hintText: 'Ism, familiya yoki telefon...',
                    prefixIcon: Icon(Icons.search_rounded, color: accentBlue),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.clear_rounded, color: Colors.grey),
                      onPressed: () => controller.clearSearch(),
                    ),
                    filled: true,
                    fillColor: white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: accentBlue, width: 2),
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
                      backgroundColor: accentBlue,
                      foregroundColor: white,
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
                  child: CircularProgressIndicator(color: accentBlue),
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

           // ...
              return ListView.separated(
                padding: EdgeInsets.all(16),
                itemCount: controller.searchResults.length,
                separatorBuilder: (_, __) => SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final student = controller.searchResults[index];
                  final isSelected = controller.selectedStudentId.value == student.id;

                  // O'ZGARTIRILDI: Statusni modeldan emas, Controllerdagi Mapdan olamiz
                  // Agar mapda bu o'quvchi bo'lmasa, 'unpaid' deb olamiz
                  final status = controller.studentStatuses[student.id] ?? 'unpaid';

                  return _buildStudentCard(
                    controller,
                    student,
                    isSelected,
                    status, // To'g'ri statusni uzatamiz
                  );
                },
              );
// ...
            }),
          ),
        ],
      ),
    );
  }

  // BU YANGI FUNKSIYA (Eskisini o'chirib shuni qo'ying):
  Widget _buildStudentCard(
    NewPaymentControllerV5 controller,
    dynamic student,
    bool isSelected,
    String status,
  ) {
    // Rang va Iconlarni statusga qarab tanlaymiz
    Color statusColor;
    String statusText;
    IconData statusIcon;

    // Mantiq shu yerda:
    switch (status) {
      case 'paid':
        statusColor = Colors.green;
        statusText = 'To\'ladi';
        statusIcon = Icons.check_circle_rounded;
        break;
      case 'partial':
        statusColor = Colors.orange;
        statusText = 'Qisman';
        statusIcon = Icons.timelapse_rounded;
        break;
      default: // 'unpaid'
        statusColor = Colors.red;
        statusText = 'To\'lamadi';
        statusIcon = Icons.cancel_outlined;
    }

    // Tanlanganda orqa fon rangi
    Color cardBgColor = isSelected ? lightBlue : white;
    Color borderColor = isSelected ? accentBlue : Colors.grey[200]!;

    return InkWell(
      onTap: () => controller.selectStudent(student),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardBgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
        ),
        child: Row(
          children: [
            // Avatar (Rangli doira)
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                // To'lamagan bo'lsa kulrang, bo'lmasa status rangida
                color: status == 'unpaid'
                    ? Colors.grey[200]
                    : statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: status == 'unpaid' ? Colors.transparent : statusColor,
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  student.firstName[0].toUpperCase(),
                  style: TextStyle(
                    color: status == 'unpaid' ? Colors.grey : statusColor,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(width: 12),

            // Ism va Sinf
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student.fullName,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? primaryBlue : Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.class_rounded, size: 14, color: accentBlue),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          student.classFullName,
                          style: TextStyle(
                            fontSize: 13,
                            color: accentBlue,
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

            // O'ng tarafdagi kichkina status yozuvi
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: statusColor.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(statusIcon, size: 14, color: statusColor),
                  SizedBox(width: 4),
                  Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
            ),

            if (isSelected)
              Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(Icons.check_circle, color: accentBlue),
              ),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // PAYMENT PANEL
  // ============================================================================
  Widget _buildPaymentPanel(
    NewPaymentControllerV5 controller,
    BuildContext context,
  ) {
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
              _buildPaymentDetailsCard(controller, context),
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
        color: white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(40),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [lightBlue, lightBlue.withOpacity(0.5)],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_search_rounded,
                size: 80,
                color: accentBlue,
              ),
            ),
            SizedBox(height: 30),
            Text(
              'O\'quvchini tanlang',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: primaryBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedStudentCard(NewPaymentControllerV5 controller) {
    return Obx(() {
      final student = controller.selectedStudent.value!;
      return Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: accentBlue, width: 2),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [primaryBlue, accentBlue]),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Center(
                    child: Text(
                      student.firstName[0].toUpperCase(),
                      style: TextStyle(
                        color: white,
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
                          color: primaryBlue,
                        ),
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.class_rounded,
                            size: 16,
                            color: accentBlue,
                          ),
                          SizedBox(width: 6),
                          Text(
                            student.classFullName,
                            style: TextStyle(
                              color: accentBlue,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
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
                  child: _buildInfoChip(Icons.phone, student.parentPhone),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildInfoChip(
                    Icons.attach_money_rounded,
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

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: lightBlue,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: accentBlue),
          SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: primaryBlue,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentHistoryCard(NewPaymentControllerV5 controller) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: white,
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
                  Icon(Icons.history_rounded, color: accentBlue, size: 24),
                  SizedBox(width: 12),
                  Text(
                    'TO\'LOV TARIXI',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: primaryBlue,
                    ),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: () => controller.showPaymentHistory(),
                icon: Icon(Icons.open_in_new_rounded, size: 18),
                label: Text('BARCHASI'),
                style: TextButton.styleFrom(foregroundColor: accentBlue),
              ),
            ],
          ),
          SizedBox(height: 16),
          Obx(() {
            if (controller.isLoadingHistory.value) {
              return Center(
                child: CircularProgressIndicator(color: accentBlue),
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
              // Ko'pi bilan 3 ta oxirgi to'lovni ko'rsatish
              itemCount: controller.paymentHistory.length > 3
                  ? 3
                  : controller.paymentHistory.length,
              separatorBuilder: (_, __) => Divider(),
              itemBuilder: (context, index) {
                final payment = controller.paymentHistory[index];

                // --- RANG VA IKONANI ANIQLASH ---
                IconData icon;
                Color color;
                String statusText = '';
                bool isCancelled = false;

                switch (payment.status) {
                  case 'partial':
                    icon =
                        Icons.timelapse_rounded; // Yoki warning_amber_rounded
                    color = Colors.orange;
                    statusText = ' (Qisman)';
                    break;
                  case 'cancelled':
                    icon = Icons.block_rounded; // Yoki cancel_rounded
                    color = Colors.red;
                    isCancelled = true;
                    statusText = ' (Bekor qilingan)';
                    break;
                  case 'paid':
                  default:
                    icon = Icons.check_circle_rounded;
                    color = Colors.green;
                }
                // --------------------------------

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(icon, color: color, size: 28),
                  title: Row(
                    children: [
                      Text(
                        payment.periodText,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          // Bekor qilingan bo'lsa chizilgan yozuv
                          decoration: isCancelled
                              ? TextDecoration.lineThrough
                              : null,
                          color: isCancelled ? Colors.grey : Colors.black87,
                        ),
                      ),
                      if (statusText.isNotEmpty && !isCancelled)
                        Text(
                          statusText,
                          style: TextStyle(
                            fontSize: 12,
                            color: color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                  subtitle: Text(
                    DateFormat('dd.MM.yyyy').format(payment.paymentDate),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${controller.formatCurrency(payment.finalAmount)} so\'m',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isCancelled ? Colors.grey : accentBlue,
                          decoration: isCancelled
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      if (isCancelled)
                        Text(
                          'BEKOR QILINGAN',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDebtsSection(NewPaymentControllerV5 controller) {
    return Obx(() {
      if (controller.studentDebts.isEmpty) return SizedBox.shrink();

      return Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: white,
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

  Widget _buildPaymentDetailsCard(
    NewPaymentControllerV5 controller,
    BuildContext context,
  ) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: white,
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
                  Icon(Icons.payment_rounded, color: accentBlue, size: 24),
                  SizedBox(width: 12),
                  Text(
                    'TO\'LOV MA\'LUMOTLARI',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryBlue,
                    ),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: () => controller.selectPaymentDate(context),
                icon: Icon(Icons.calendar_month, color: accentBlue),
                label: Obx(
                  () => Text(
                    DateFormat(
                      'dd.MM.yyyy',
                    ).format(controller.paymentDate.value),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: accentBlue,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          TextFormField(
            controller: controller.amountController,
            keyboardType: TextInputType.number,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              labelText: 'Summa *',
              hintText: '500000',
              suffixText: 'so\'m',
              prefixIcon: Icon(Icons.attach_money_rounded, color: accentBlue),
              filled: true,
              fillColor: lightBlue,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (_) => controller.calculateFinalAmount(),
          ),
          SizedBox(height: 16),

          // Multi-payment section (YANGI)
          Obx(
            () => CheckboxListTile(
              value: controller.useMultiPayment.value,
              onChanged: (val) => controller.toggleMultiPayment(val ?? false),
              title: Text(
                'Ko\'p usulda to\'lash',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text('Naqd + Click yoki boshqa usullar'),
              activeColor: accentBlue,
            ),
          ),

          Obx(() {
            if (controller.useMultiPayment.value) {
              return Container(
                padding: EdgeInsets.all(16),
                margin: EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  color: lightBlue,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: accentBlue.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: controller.paymentSplits.length,
                      itemBuilder: (context, index) {
                        final split = controller.paymentSplits[index];
                        return Padding(
                          padding: EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: DropdownButtonFormField<String>(
                                  value: split.method,
                                  decoration: InputDecoration(
                                    labelText: 'Usul',
                                    filled: true,
                                    fillColor: white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  items: [
                                    DropdownMenuItem(
                                      value: 'cash',
                                      child: Text('Naqd'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'click',
                                      child: Text('Click'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'terminal',
                                      child: Text('Terminal'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'owner_fund',
                                      child: Text('Ega kassasi'),
                                    ),
                                  ],
                                  onChanged: (val) {
                                    if (val != null) split.method = val;
                                  },
                                ),
                              ),
                              SizedBox(width: 12),
                                                            // ... (Boshqa kodlar)
                              Expanded(
                                flex: 3,
                                child: TextFormField(
                                  // InitialValue faqat bir marta ishlaydi, shuning uchun controller kerak bo'lishi mumkin
                                  // Lekin oddiy holatda initialValue ham yetadi agar list qayta chizilsa
                                  initialValue: split.amount == 0 ? '' : split.amount.toStringAsFixed(0),
                                  
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white,
                                    // ...
                                  ),
                                  
                                  // >>> MANA SHU YER MUHIM <<<
                                  onChanged: (val) {
                                    // Controller funksiyasini chaqiramiz
                                    controller.updateSplitAmount(index, val);
                                  },
                                ),
                              ),
                              if (controller.paymentSplits.length > 1)
                                IconButton(
                                  onPressed: () =>
                                      controller.removePaymentSplit(index),
                                  icon: Icon(Icons.delete, color: Colors.red),
                                ),
                            ],
                          ),
                        );
                      },
                    ),

                    // Multi-payment konteynerining eng pastki qismida:
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () {
                            controller.addPaymentSplit();
                            controller.calculateFinalAmount();
                          },
                          icon: Icon(Icons.add),
                          label: Text('Usul qo\'shish'),
                        ),

                        // >>> MANA SHU YERNI O'ZGARTIRING: <<<
                        Obx(
                          () => Text(
                            // Controllerdagi totalPaidAmount o'zgaruvchisini ishlatamiz
                            'Jami: ${controller.formatCurrency(controller.totalPaidAmount.value)} so\'m',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              // Agar oshiqcha to'lov bo'lsa qizil, bo'lmasa ko'k
                              color: controller.isOverPayment.value
                                  ? Colors.red
                                  : primaryBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }
            return SizedBox.shrink();
          }),

          if (!controller.useMultiPayment.value) ...[
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Obx(
                    () => DropdownButtonFormField<String>(
                      value: controller.paymentSplits.isEmpty
                          ? 'cash'
                          : controller.paymentSplits.first.method,
                      decoration: InputDecoration(
                        labelText: 'To\'lov usuli *',
                        filled: true,
                        fillColor: lightBlue,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: [
                        DropdownMenuItem(value: 'cash', child: Text('Naqd')),
                        DropdownMenuItem(value: 'click', child: Text('Click')),
                        DropdownMenuItem(
                          value: 'terminal',
                          child: Text('Terminal'),
                        ),
                        DropdownMenuItem(
                          value: 'owner_fund',
                          child: Text('Ega kassasi'),
                        ),
                      ],
                      onChanged: (v) {
                        if (v != null) {
                          if (controller.paymentSplits.isEmpty) {
                            controller.paymentSplits.add(
                              PaymentSplit(method: v),
                            );
                          } else {
                            controller.paymentSplits.first.method = v;
                          }
                        }
                      },
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Obx(
                    () => DropdownButtonFormField<String>(
                      value: controller.paymentType.value,
                      decoration: InputDecoration(
                        labelText: 'To\'lov turi *',
                        filled: true,
                        fillColor: lightBlue,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 'tuition',
                          child: Text('Oylik to\'lov'),
                        ),
                        DropdownMenuItem(
                          value: 'registration',
                          child: Text('Ro\'yxatga olish'),
                        ),
                        DropdownMenuItem(value: 'exam', child: Text('Imtihon')),
                        DropdownMenuItem(value: 'other', child: Text('Boshqa')),
                      ],
                      onChanged: (v) => controller.paymentType.value = v!,
                    ),
                  ),
                ),
              ],
            ),
          ],

          SizedBox(height: 20),
          PaymentWidgetsV5.buildDiscountSection(
            controller,
            accentBlue,
            primaryBlue,
            lightBlue,
          ),
          SizedBox(height: 20),
          PaymentWidgetsV5.buildFinalAmountDisplay(controller, accentBlue),
          SizedBox(height: 20),
          PaymentWidgetsV5.buildPartialPaymentSection(
            controller,
            accentBlue,
            primaryBlue,
            lightBlue,
          ),
          SizedBox(height: 20),
          TextFormField(
            controller: controller.notesController,
            decoration: InputDecoration(
              labelText: 'Qo\'shimcha izoh',
              prefixIcon: Icon(Icons.note_alt_rounded, color: accentBlue),
              filled: true,
              fillColor: lightBlue,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(NewPaymentControllerV5 controller) {
    return Obx(
      () => SizedBox(
        width: double.infinity,
        height: 60,
        child: ElevatedButton.icon(
          onPressed: controller.isLoading.value
              ? null
              : () => controller.confirmPayment(),
          icon: controller.isLoading.value
              ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: white,
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
            backgroundColor: accentBlue,
            foregroundColor: white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}
