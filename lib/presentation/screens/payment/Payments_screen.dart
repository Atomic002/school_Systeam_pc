// lib/presentation/screens/finance/new_payment_screen.dart
// ================================================================================
// YANGI TO'LOV QABUL QILISH - Tuzatilgan versiya
// ================================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/presentation/controllers/payment_controller.dart';
import 'package:get/get.dart';
import '../../../config/constants.dart';

class NewPaymentScreen extends StatelessWidget {
  // MUHIM: final o'rniga to'g'ridan-to'g'ri Get.put
  NewPaymentScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Controller ni bu yerda yaratamiz
    final controller = Get.put(NewPaymentController());

    return Scaffold(
      backgroundColor: AppConstants.backgroundLight,
      body: Row(
        children: [
          // Main content
          Expanded(
            child: Column(
              children: [
                _buildAppBar(controller),
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: AppConstants.primaryColor,
                        ),
                      );
                    }
                    return _buildContent(controller);
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // APP BAR
  // ============================================================================

  Widget _buildAppBar(NewPaymentController controller) {
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
          IconButton(
            onPressed: () => Get.back(),
            icon: Icon(Icons.arrow_back, color: AppConstants.textPrimaryColor),
          ),
          SizedBox(width: AppConstants.paddingMedium),
          Icon(Icons.payment, color: AppConstants.primaryColor, size: 28),
          SizedBox(width: AppConstants.paddingMedium),
          Text(
            'Yangi to\'lov qabul qilish',
            style: TextStyle(
              fontSize: AppConstants.fontSizeXXLarge,
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimaryColor,
            ),
          ),
          Spacer(),
          _buildQuickStats(controller),
        ],
      ),
    );
  }

  Widget _buildQuickStats(NewPaymentController controller) {
    return Obx(
      () => Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppConstants.paddingLarge,
          vertical: AppConstants.paddingSmall,
        ),
        decoration: BoxDecoration(
          color: AppConstants.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              size: 16,
              color: AppConstants.primaryColor,
            ),
            SizedBox(width: 8),
            Text(
              'Bugun: ${controller.todayPaymentsCount.value} ta to\'lov',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppConstants.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // MAIN CONTENT
  // ============================================================================

  Widget _buildContent(NewPaymentController controller) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left side - Student search
        Expanded(flex: 2, child: _buildStudentSearchSection(controller)),

        SizedBox(width: AppConstants.paddingLarge),

        // Right side - Payment form
        Expanded(flex: 3, child: _buildPaymentFormSection(controller)),
      ],
    );
  }

  // ============================================================================
  // STUDENT SEARCH SECTION
  // ============================================================================

  Widget _buildStudentSearchSection(NewPaymentController controller) {
    return Container(
      margin: EdgeInsets.all(AppConstants.paddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search header
          Container(
            padding: EdgeInsets.all(AppConstants.paddingLarge),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppConstants.borderRadiusMedium),
                topRight: Radius.circular(AppConstants.borderRadiusMedium),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppConstants.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(
                          AppConstants.borderRadiusSmall,
                        ),
                      ),
                      child: Icon(
                        Icons.search,
                        color: AppConstants.primaryColor,
                        size: 20,
                      ),
                    ),
                    SizedBox(width: AppConstants.paddingMedium),
                    Text(
                      'O\'quvchini tanlash',
                      style: TextStyle(
                        fontSize: AppConstants.fontSizeXLarge,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.textPrimaryColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppConstants.paddingLarge),

                // Search field
                // Ism / Familiya qidirish
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: controller.firstNameController,
                        decoration: InputDecoration(
                          labelText: 'Ism',
                          hintText: 'Masalan: Ali',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppConstants.borderRadiusMedium,
                            ),
                          ),
                          isDense: true,
                        ),
                        textInputAction: TextInputAction.search,
                        onFieldSubmitted: (_) => controller.searchStudents,
                      ),
                    ),
                    SizedBox(width: AppConstants.paddingMedium),
                    Expanded(
                      child: TextFormField(
                        controller: controller.lastNameController,
                        decoration: InputDecoration(
                          labelText: 'Familiya',
                          hintText: 'Masalan: Karimov',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppConstants.borderRadiusMedium,
                            ),
                          ),
                          isDense: true,
                        ),
                        textInputAction: TextInputAction.search,
                        onFieldSubmitted: (_) {
                          controller.searchStudents; // ← shu yer
                        },
                      ),
                    ),
                    SizedBox(width: AppConstants.paddingMedium),
                    IconButton(
                      icon: Icon(
                        Icons.search,
                        color: AppConstants.primaryColor,
                      ),
                      tooltip: 'Qidirish',
                      onPressed: () => controller.searchStudents,
                    ),
                    IconButton(
                      icon: Icon(Icons.clear, color: Colors.grey[600]),
                      tooltip: 'Tozalash',
                      onPressed: () {
                        controller.firstNameController.clear();
                        controller.lastNameController.clear();
                        controller.loadAllStudents();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Search results
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(AppConstants.borderRadiusMedium),
                  bottomRight: Radius.circular(AppConstants.borderRadiusMedium),
                ),
              ),
              child: Obx(() {
                if (controller.isSearching.value) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(AppConstants.paddingLarge),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (controller.searchResults.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey[300],
                        ),
                        SizedBox(height: AppConstants.paddingMedium),
                        Text(
                          'O\'quvchi topilmadi',
                          style: TextStyle(
                            fontSize: AppConstants.fontSizeLarge,
                            color: AppConstants.textSecondaryColor,
                          ),
                        ),
                        SizedBox(height: AppConstants.paddingSmall),
                        Text(
                          'Ism, familiya yoki telefon raqam kiriting',
                          style: TextStyle(
                            color: AppConstants.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: EdgeInsets.all(AppConstants.paddingMedium),
                  itemCount: controller.searchResults.length,
                  separatorBuilder: (_, __) => Divider(height: 1),
                  itemBuilder: (context, index) {
                    final student = controller.searchResults[index];
                    final isSelected =
                        controller.selectedStudentId.value == student.id;

                    return _buildStudentCard(controller, student, isSelected);
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard(
    NewPaymentController controller,
    dynamic student,
    bool isSelected,
  ) {
    return InkWell(
      onTap: () => controller.selectStudent(student),
      child: Container(
        padding: EdgeInsets.all(AppConstants.paddingMedium),
        decoration: BoxDecoration(
          color: isSelected
              ? AppConstants.primaryColor.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
          border: isSelected
              ? Border.all(color: AppConstants.primaryColor, width: 2)
              : null,
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppConstants.primaryColor,
                    AppConstants.primaryColor.withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(
                  AppConstants.borderRadiusSmall,
                ),
              ),
              child: Center(
                child: Text(
                  student.firstName[0].toUpperCase(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: AppConstants.fontSizeXLarge,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            SizedBox(width: AppConstants.paddingMedium),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student.fullName,
                    style: TextStyle(
                      fontSize: AppConstants.fontSizeMedium,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.textPrimaryColor,
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.phone, size: 14, color: Colors.grey[600]),
                      SizedBox(width: 4),
                      Text(
                        student.phone ?? student.parentPhone ?? '-',
                        style: TextStyle(
                          fontSize: AppConstants.fontSizeSmall,
                          color: AppConstants.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppConstants.successColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Oylik: ${_formatCurrency(student.monthlyFee)} so\'m',
                      style: TextStyle(
                        fontSize: AppConstants.fontSizeSmall,
                        color: AppConstants.successColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Selection indicator
            if (isSelected)
              Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppConstants.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check, color: Colors.white, size: 16),
              ),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // PAYMENT FORM SECTION
  // ============================================================================

  Widget _buildPaymentFormSection(NewPaymentController controller) {
    return Obx(() {
      if (controller.selectedStudent.value == null) {
        return Container(
          margin: EdgeInsets.all(AppConstants.paddingLarge),
          padding: EdgeInsets.all(AppConstants.paddingXXLarge),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(
              AppConstants.borderRadiusMedium,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_search, size: 100, color: Colors.grey[300]),
                SizedBox(height: AppConstants.paddingLarge),
                Text(
                  'O\'quvchini tanlang',
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeXXLarge,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.textSecondaryColor,
                  ),
                ),
                SizedBox(height: AppConstants.paddingSmall),
                Text(
                  'To\'lov qabul qilish uchun chapdan o\'quvchini tanlang',
                  style: TextStyle(color: AppConstants.textSecondaryColor),
                ),
              ],
            ),
          ),
        );
      }

      return SingleChildScrollView(
        padding: EdgeInsets.all(AppConstants.paddingLarge),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSelectedStudentCard(controller),
              SizedBox(height: AppConstants.paddingLarge),
              _buildPaymentTypeSelector(controller),
              SizedBox(height: AppConstants.paddingLarge),
              _buildPaymentMethodSelector(controller),
              SizedBox(height: AppConstants.paddingLarge),
              _buildAmountSection(controller),
              SizedBox(height: AppConstants.paddingLarge),
              _buildDiscountSection(controller),
              SizedBox(height: AppConstants.paddingLarge),
              _buildDebtSection(controller),
              SizedBox(height: AppConstants.paddingLarge),
              _buildNotesField(controller),
              SizedBox(height: AppConstants.paddingXXLarge),
              _buildSaveButton(controller),
            ],
          ),
        ),
      );
    });
  }

  // ============================================================================
  // SELECTED STUDENT CARD
  // ============================================================================

  Widget _buildSelectedStudentCard(NewPaymentController controller) {
    return Obx(() {
      final student = controller.selectedStudent.value!;
      return Container(
        padding: EdgeInsets.all(AppConstants.paddingLarge),
        decoration: BoxDecoration(
          color: Colors.blueAccent,
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          border: Border.all(color: AppConstants.primaryColor.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(
                      AppConstants.borderRadiusMedium,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      student.firstName[0].toUpperCase(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: AppConstants.paddingLarge),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student.fullName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: AppConstants.fontSizeXXLarge,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'ID: ${student.id.substring(0, 8)}...',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: AppConstants.fontSizeSmall,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => controller.clearSelection(),
                  icon: Icon(Icons.close, color: Colors.white),
                  tooltip: 'Boshqasini tanlash',
                ),
              ],
            ),
            SizedBox(height: AppConstants.paddingLarge),
            Divider(color: Colors.white.withOpacity(0.3), height: 1),
            SizedBox(height: AppConstants.paddingLarge),
            Row(
              children: [
                Expanded(
                  child: _buildInfoChip(
                    Icons.phone,
                    'Telefon',
                    student.phone ?? student.parentPhone,
                  ),
                ),
                SizedBox(width: AppConstants.paddingMedium),
                Expanded(
                  child: _buildInfoChip(
                    Icons.attach_money,
                    'Oylik to\'lov',
                    '${_formatCurrency(student.monthlyFee)} so\'m',
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildInfoChip(IconData icon, String label, String value) {
    return Container(
      padding: EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 16),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: AppConstants.fontSizeSmall,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
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

  // ============================================================================
  // PAYMENT TYPE
  // ============================================================================

  Widget _buildPaymentTypeSelector(NewPaymentController controller) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('To\'lov turi', Icons.category),
            SizedBox(height: AppConstants.paddingMedium),
            Obx(
              () => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildTypeChip(
                    controller,
                    'Oylik to\'lov',
                    'tuition',
                    Icons.calendar_month,
                  ),
                  _buildTypeChip(
                    controller,
                    'Ro\'yxatga olish',
                    'registration',
                    Icons.app_registration,
                  ),
                  _buildTypeChip(controller, 'Imtihon', 'exam', Icons.quiz),
                  _buildTypeChip(
                    controller,
                    'Boshqa',
                    'other',
                    Icons.more_horiz,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeChip(
    NewPaymentController controller,
    String label,
    String value,
    IconData icon,
  ) {
    final isSelected = controller.paymentType.value == value;
    return InkWell(
      onTap: () => controller.paymentType.value = value,
      borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppConstants.paddingMedium,
          vertical: AppConstants.paddingSmall,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppConstants.primaryColor : Colors.grey[100],
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : Colors.grey[700],
            ),
            SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // PAYMENT METHOD
  // ============================================================================

  Widget _buildPaymentMethodSelector(NewPaymentController controller) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('To\'lov usuli', Icons.payment),
            SizedBox(height: AppConstants.paddingMedium),
            Obx(
              () => GridView.count(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 3,
                children: [
                  _buildMethodCard(
                    controller,
                    'Naqd',
                    'cash',
                    Icons.money,
                    Colors.green,
                  ),
                  _buildMethodCard(
                    controller,
                    'Click',
                    'click',
                    Icons.phone_android,
                    Colors.blue,
                  ),
                  _buildMethodCard(
                    controller,
                    'Terminal',
                    'terminal',
                    Icons.credit_card,
                    Colors.purple,
                  ),
                  _buildMethodCard(
                    controller,
                    'Ega kassasi',
                    'owner_fund',
                    Icons.account_balance_wallet,
                    Colors.orange,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodCard(
    NewPaymentController controller,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    final isSelected = controller.paymentMethod.value == value;
    return InkWell(
      onTap: () => controller.paymentMethod.value = value,
      borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppConstants.paddingMedium,
          vertical: AppConstants.paddingSmall,
        ),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.grey[50],
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
          border: Border.all(
            color: isSelected ? color : Colors.grey[200]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            SizedBox(width: AppConstants.paddingSmall),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? color : AppConstants.textPrimaryColor,
                ),
              ),
            ),
            if (isSelected) Icon(Icons.check_circle, color: color, size: 20),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // AMOUNT SECTION
  // ============================================================================

  Widget _buildAmountSection(NewPaymentController controller) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('To\'lov summasi', Icons.attach_money),
            SizedBox(height: AppConstants.paddingMedium),
            TextFormField(
              controller: controller.amountController,
              readOnly: true, // ← MUHIM
              enableInteractiveSelection: false,
              keyboardType: TextInputType.number,
              style: TextStyle(
                fontSize: AppConstants.fontSizeXLarge,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                labelText: 'Asosiy oylik to\'lov',
                hintText: '0',
                suffixText: 'so\'m',
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    AppConstants.borderRadiusMedium,
                  ),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.all(AppConstants.paddingLarge),
              ),
              validator: (value) {
                if (controller.selectedStudent.value == null) {
                  return 'O\'quvchini tanlang';
                }
                if (value == null || value.isEmpty) {
                  return 'Summani avtomatik hisoblashda xatolik';
                }
                return null;
              },
              // onChanged kerak emas, chunki foydalanuvchi o'zgartira olmaydi
            ),
            SizedBox(height: AppConstants.paddingMedium),
            Obx(
              () => Container(
                padding: EdgeInsets.all(AppConstants.paddingLarge),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppConstants.successColor,
                      AppConstants.successColor.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(
                    AppConstants.borderRadiusMedium,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Yakuniy summa:',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: AppConstants.fontSizeMedium,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${_formatCurrency(controller.finalAmount.value)} so\'m',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: AppConstants.fontSizeXLarge,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // DISCOUNT SECTION
  // ============================================================================

  Widget _buildDiscountSection(NewPaymentController controller) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          children: [
            Row(
              children: [
                _buildSectionTitle('Chegirma', Icons.local_offer),
                Spacer(),
                Obx(
                  () => Switch(
                    value: controller.hasDiscount.value,
                    onChanged: (value) => controller.hasDiscount.value = value,
                    activeColor: AppConstants.successColor,
                  ),
                ),
              ],
            ),
            Obx(() {
              if (!controller.hasDiscount.value) return SizedBox.shrink();

              return Column(
                children: [
                  SizedBox(height: AppConstants.paddingMedium),
                  TextFormField(
                    controller: controller.discountController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      labelText: 'Chegirma summasi',
                      suffixText: 'so\'m',
                      filled: true,
                      fillColor: Colors.grey[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppConstants.borderRadiusMedium,
                        ),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) => controller.calculateFinalAmount(),
                  ),
                  SizedBox(height: AppConstants.paddingMedium),
                  TextFormField(
                    controller: controller.discountReasonController,
                    decoration: InputDecoration(
                      labelText: 'Chegirma sababi',
                      hintText: 'Masalan: Ikkinchi farzand',
                      filled: true,
                      fillColor: Colors.grey[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppConstants.borderRadiusMedium,
                        ),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // DEBT SECTION
  // ============================================================================

  Widget _buildDebtSection(NewPaymentController controller) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          children: [
            Row(
              children: [
                _buildSectionTitle('Qarz qoldirish', Icons.account_balance),
                Spacer(),
                Obx(
                  () => Switch(
                    value: controller.isPartialPayment.value,
                    onChanged: (value) =>
                        controller.isPartialPayment.value = value,
                    activeColor: AppConstants.warningColor,
                  ),
                ),
              ],
            ),
            Obx(() {
              if (!controller.isPartialPayment.value) return SizedBox.shrink();

              return Column(
                children: [
                  SizedBox(height: AppConstants.paddingMedium),
                  TextFormField(
                    controller: controller.paidAmountController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      labelText: 'Hozir to\'lanadigan summa',
                      suffixText: 'so\'m',
                      filled: true,
                      fillColor: Colors.grey[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppConstants.borderRadiusMedium,
                        ),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) => controller.calculateDebtAmount(),
                  ),
                  SizedBox(height: AppConstants.paddingMedium),
                  Obx(
                    () => Container(
                      padding: EdgeInsets.all(AppConstants.paddingLarge),
                      decoration: BoxDecoration(
                        color: AppConstants.warningColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(
                          AppConstants.borderRadiusMedium,
                        ),
                        border: Border.all(
                          color: AppConstants.warningColor.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.warning_amber,
                                color: AppConstants.warningColor,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Qarz summasi:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppConstants.warningColor,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '${_formatCurrency(controller.debtAmount.value)} so\'m',
                            style: TextStyle(
                              fontSize: AppConstants.fontSizeLarge,
                              fontWeight: FontWeight.bold,
                              color: AppConstants.warningColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // NOTES FIELD
  // ============================================================================

  Widget _buildNotesField(NewPaymentController controller) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Izohlar', Icons.note),
            SizedBox(height: AppConstants.paddingMedium),
            TextFormField(
              controller: controller.notesController,

              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Qo\'shimcha ma\'lumotlar...',
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    AppConstants.borderRadiusMedium,
                  ),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // SAVE BUTTON
  // ============================================================================

  Widget _buildSaveButton(NewPaymentController controller) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () => controller.savePayment(),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.successColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppConstants.borderRadiusMedium,
            ),
          ),
          elevation: 4,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 24),
            SizedBox(width: 12),
            Text(
              'TO\'LOVNI QABUL QILISH',
              style: TextStyle(
                fontSize: AppConstants.fontSizeLarge,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // HELPER WIDGETS
  // ============================================================================

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppConstants.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 18, color: AppConstants.primaryColor),
        ),
        SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: AppConstants.fontSizeLarge,
            fontWeight: FontWeight.bold,
            color: AppConstants.textPrimaryColor,
          ),
        ),
      ],
    );
  }

  String _formatCurrency(double amount) {
    return amount
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]} ',
        )
        .trim();
  }
}
