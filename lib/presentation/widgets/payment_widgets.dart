// lib/presentation/widgets/payment_widgets_v5.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PaymentWidgetsV5 {
  // ============================================================================
  // DISCOUNT SECTION
  // ============================================================================
  static Widget buildDiscountSection(
    dynamic controller,
    Color accentBlue,
    Color primaryBlue,
    Color lightBlue,
  ) {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CheckboxListTile(
            value: controller.hasDiscount.value,
            onChanged: (value) {
              controller.hasDiscount.value = value ?? false;
              if (!value!) {
                controller.discountController.clear();
                controller.discountReasonController.clear();
              }
              controller.calculateFinalAmount();
            },
            title: Text(
              'Chegirma qo\'llash',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: primaryBlue,
              ),
            ),
            activeColor: Colors.orange[700],
            contentPadding: EdgeInsets.zero,
          ),

          if (controller.hasDiscount.value) ...[
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.orange[200]!, width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildDiscountTypeButton(
                          controller,
                          'Foiz %',
                          'percent',
                          Icons.percent_rounded,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildDiscountTypeButton(
                          controller,
                          'Summa',
                          'amount',
                          Icons.money_off_rounded,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),

                  TextFormField(
                    controller: controller.discountController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        controller.discountType.value == 'percent'
                            ? Icons.percent_rounded
                            : Icons.money_off_rounded,
                        color: Colors.orange[700],
                      ),
                      labelText: controller.discountType.value == 'percent'
                          ? 'Chegirma foizi'
                          : 'Chegirma summasi',
                      suffixText: controller.discountType.value == 'percent'
                          ? '%'
                          : 'so\'m',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (_) => controller.calculateFinalAmount(),
                    validator: (value) {
                      if (controller.hasDiscount.value) {
                        if (value == null || value.isEmpty)
                          return 'Chegirma qiymatini kiriting';
                        final discount = double.tryParse(value);
                        if (discount == null || discount < 0)
                          return 'Noto\'g\'ri qiymat';
                        if (controller.discountType.value == 'percent' &&
                            discount > 100)
                          return 'Foiz 100 dan oshmasligi kerak';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 12),

                  TextFormField(
                    controller: controller.discountReasonController,
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.description_rounded,
                        color: Colors.orange[700],
                      ),
                      labelText: 'Chegirma sababi',
                      hintText: 'Masalan: Ikkinchi bola',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    maxLines: 2,
                  ),

                  if (controller.finalAmount.value > 0) ...[
                    SizedBox(height: 16),
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange[300]!),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.discount_rounded,
                                color: Colors.orange[700],
                                size: 24,
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Chegirma summasi:',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.orange[900],
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '${_formatCurrency(controller, _calculateDiscountAmount(controller))} so\'m',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  static Widget _buildDiscountTypeButton(
    dynamic controller,
    String label,
    String value,
    IconData icon,
  ) {
    return Obx(() {
      final isSelected = controller.discountType.value == value;
      return InkWell(
        onTap: () {
          controller.discountType.value = value;
          controller.calculateFinalAmount();
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? Colors.orange[700] : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Colors.orange[700]! : Colors.orange[300]!,
              width: 2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : Colors.orange[700],
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.orange[700],
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  // ============================================================================
  // PARTIAL PAYMENT SECTION
  // ============================================================================
  static Widget buildPartialPaymentSection(
    dynamic controller,
    Color accentBlue,
    Color primaryBlue,
    Color lightBlue,
  ) 
  
  {
      return Obx(() {
      // >>> YANGI QO'SHILGAN QISM <<<
      // Agar Multi-payment yoqilgan bo'lsa, bu seksiyani umuman ko'rsatma.
      // Shunda ziddiyat bo'lmaydi.
      if (controller.useMultiPayment.value) {
        return SizedBox.shrink(); 
      }
      // -----------------------------

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CheckboxListTile(
            value: controller.isPartialPayment.value,
            onChanged: (value) {
              controller.isPartialPayment.value = value ?? false;
                if (controller.useMultiPayment.value) {
      }
              
            },
            title: Text(
              'Qisman to\'lov (qarz)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: primaryBlue,
              ),
            ),
            activeColor: Colors.red[700],
            contentPadding: EdgeInsets.zero,
          ),

          if (controller.isPartialPayment.value) ...[
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.red[200]!, width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.red[700],
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Diqqat: Qisman to\'lov - o\'quvchi qarzga qoladi',
                            style: TextStyle( 
                              color: Colors.red[900],
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),

                  TextFormField(
                    controller: controller.paidAmountController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.payments_rounded,
                        color: Colors.red[700],
                      ),
                      labelText: 'To\'lanadigan summa',
                      suffixText: 'so\'m',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (controller.isPartialPayment.value) {
                        if (value == null || value.isEmpty)
                          return 'To\'lanadigan summani kiriting';
                        final paid = double.tryParse(value);
                        if (paid == null || paid <= 0)
                          return 'Noto\'g\'ri summa';
                        if (paid >= controller.finalAmount.value)
                          return 'To\'lov yakuniy summadan kam bo\'lishi kerak';
                      }
                      return null;
                    },
                    onChanged: (_) => controller.calculateFinalAmount(),
                  ),
                  SizedBox(height: 12),

                  TextFormField(
                    controller: controller.debtReasonController,
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.edit_note_rounded,
                        color: Colors.red[700],
                      ),
                      labelText: 'Qarz sababi',
                      hintText: 'Masalan: Puli yetarli emas',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    maxLines: 2,
                    validator: (value) {
                      if (controller.isPartialPayment.value) {
                        if (value == null || value.trim().isEmpty)
                          return 'Qarz sababini kiriting';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),

                  if (controller.debtAmount.value > 0)
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.red[600]!, Colors.red[700]!],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.3),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.warning_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                              SizedBox(width: 12),
                              Text(
                                'QARZ SUMMASI:',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '${_formatCurrency(controller, controller.debtAmount.value)} so\'m',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      );}
    );
  }

  // ============================================================================
  // FINAL AMOUNT DISPLAY
  // ============================================================================
  // ============================================================================
  // FINAL AMOUNT DISPLAY (O'ZGARTIRILDI)
  // ============================================================================
  static Widget buildFinalAmountDisplay(dynamic controller, Color accentBlue) {
    return Obx(() {
      double displayAmount = controller.finalAmount.value;
      String labelText = 'YAKUNIY SUMMA';
      bool isPartial = controller.isPartialPayment.value;

      // Agar o'quvchining qarzlari bo'lsa, uni ko'rsatamiz
      bool hasDebts = controller.totalAllDebts.value > 0;

      if (isPartial) {
        double paid =
            double.tryParse(
              controller.paidAmountController.text.replaceAll(' ', ''),
            ) ??
            0;
        displayAmount = paid;
        labelText = 'TO\'LANADIGAN SUMMA';
      }

      return Column(
        children: [
          // 1. JAMI QARZLAR BLOCKI (YANGI)
          if (hasDebts)
            Container(
              margin: EdgeInsets.only(bottom: 16),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red[50],
                border: Border.all(color: Colors.red[200]!),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red[100],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.warning_rounded, color: Colors.red[700]),
                  ),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'O\'quvchining jami qarzi:',
                        style: TextStyle(color: Colors.red[900], fontSize: 14),
                      ),
                      Text(
                        '${_formatCurrency(controller, controller.totalAllDebts.value)} so\'m',
                        style: TextStyle(
                          color: Colors.red[700],
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          // 2. YAKUNIY SUMMA BLOCKI
          if (controller.finalAmount.value > 0 || isPartial)
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: isPartial
                    ? LinearGradient(
                        colors: [Colors.blue[600]!, Colors.blue[800]!],
                      )
                    : LinearGradient(
                        colors: [Colors.green[400]!, Colors.green[600]!],
                      ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: isPartial
                        ? Colors.blue.withOpacity(0.3)
                        : Colors.green.withOpacity(0.3),
                    blurRadius: 15,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isPartial
                                ? Icons.handshake_rounded
                                : Icons.calculate_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                          SizedBox(width: 12),
                          Text(
                            labelText,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${_formatCurrency(controller, displayAmount)} so\'m',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),

                  if (isPartial) ...[
                    SizedBox(height: 12),
                    Divider(color: Colors.white.withOpacity(0.3), height: 1),
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Jami hisoblangan:',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        Text(
                          '${_formatCurrency(controller, controller.finalAmount.value)} so\'m',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Qarzga qoladi:',
                          style: TextStyle(color: Colors.orangeAccent),
                        ),
                        Text(
                          '${_formatCurrency(controller, controller.debtAmount.value)} so\'m',
                          style: TextStyle(
                            color: Colors.orangeAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ] else if (controller.hasDiscount.value) ...[
                    SizedBox(height: 12),
                    Divider(color: Colors.white.withOpacity(0.3), height: 1),
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Asl summa:',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        Text(
                          '${_formatCurrency(controller, double.tryParse(controller.amountController.text) ?? 0)} so\'m',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Chegirma:',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        Text(
                          '- ${_formatCurrency(controller, _calculateDiscountAmount(controller))} so\'m',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
        ],
      );
    });
  }

  // ============================================================================
  // HELPER FUNCTIONS
  // ============================================================================
  static double _calculateDiscountAmount(dynamic controller) {
    final amount = double.tryParse(controller.amountController.text) ?? 0;
    final discountValue =
        double.tryParse(controller.discountController.text) ?? 0;

    if (controller.discountType.value == 'percent') {
      return amount * discountValue / 100;
    } else {
      return discountValue;
    }
  }

  static String _formatCurrency(dynamic controller, double amount) {
    return controller.formatCurrency(amount);
  }
}
