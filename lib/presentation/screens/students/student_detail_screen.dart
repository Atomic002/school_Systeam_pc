// lib/presentation/screens/students/student_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/student_detail_controller.dart';
import '../../widgets/sidebar.dart';

class StudentDetailScreen extends StatelessWidget {
  StudentDetailScreen({Key? key}) : super(key: key);

  final StudentDetailController controller = Get.put(StudentDetailController());

  @override
  Widget build(BuildContext context) {
     final args = Get.arguments as Map<String, dynamic>;
    args['studentId'].toString(); // shu kalit bilan
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Row(
        children: [
          Sidebar(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return _buildLoadingState();
              }

              if (controller.student.value == null) {
                return _buildErrorState();
              }

              return Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: controller.refreshData,
                      color: const Color(0xFF2196F3),
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            _buildQuickStats(),
                            const SizedBox(height: 24),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    children: [
                                      _buildPersonalInfo(),
                                      const SizedBox(height: 20),
                                      _buildParentInfo(),
                                      const SizedBox(height: 20),
                                      _buildAcademicInfo(),
                                      const SizedBox(height: 20),
                                      _buildFinancialInfo(),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 24),
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    children: [
                                      _buildPaymentHistory(),
                                      const SizedBox(height: 20),
                                      _buildAttendanceHistory(),
                                      const SizedBox(height: 20),
                                      _buildSchedule(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  // ==================== HEADER ====================
  Widget _buildHeader() {
    return Obx(() {
      final student = controller.student.value!;
      final isEditing = controller.isEditing.value;

      return Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2196F3).withOpacity(0.3),
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
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Get.back(),
                ),
                const SizedBox(width: 16),
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student.fullName,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildBadge(
                            Icons.cake,
                            '${student.age} yosh',
                            Colors.white,
                          ),
                          const SizedBox(width: 12),
                          Obx(() {
                            final className = controller.currentClassName.value;
                            return _buildBadge(
                              Icons.school,
                              className ?? 'Sinf biriktirilmagan',
                              Colors.white,
                            );
                          }),
                          const SizedBox(width: 12),
                          _buildStatusBadge(student.status),
                        ],
                      ),
                    ],
                  ),
                ),
                _buildHeaderActions(isEditing),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildBadge(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String? status) {
    Color color;
    String text;
    IconData icon;

    switch (status) {
      case 'active':
        color = const Color(0xFF4CAF50);
        text = 'Faol';
        icon = Icons.check_circle;
        break;
      case 'paused':
        color = const Color(0xFFFFA726);
        text = 'To\'xtatilgan';
        icon = Icons.pause_circle;
        break;
      case 'graduated':
        color = Colors.white;
        text = 'Bitirgan';
        icon = Icons.school;
        break;
      default:
        color = Colors.white70;
        text = 'Noma\'lum';
        icon = Icons.help_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderActions(bool isEditing) {
    return Row(
      children: [
        if (isEditing) ...[
          _buildActionButton(
            icon: Icons.close,
            label: 'Bekor',
            onTap: controller.toggleEditMode,
            color: Colors.white70,
          ),
          const SizedBox(width: 12),
          _buildActionButton(
            icon: Icons.check,
            label: 'Saqlash',
            onTap: controller.saveChanges,
            color: Colors.white,
          ),
        ] else ...[
          _buildActionButton(
            icon: Icons.edit,
            label: 'Tahrirlash',
            onTap: controller.toggleEditMode,
            color: Colors.white,
          ),
          const SizedBox(width: 12),
          _buildActionButton(
            icon: Icons.payment,
            label: 'To\'lov',
            onTap: controller.makePayment,
            color: Colors.white,
          ),
          const SizedBox(width: 12),
          _buildActionButton(
            icon: Icons.picture_as_pdf,
            label: 'PDF',
            onTap: controller.exportToPDF,
            color: Colors.white,
          ),
        ],
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Icon(icon, color: color, size: 18),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==================== QUICK STATS ====================
  Widget _buildQuickStats() {
    return Obx(
      () => Row(
        children: [
          _buildStatCard(
            icon: Icons.account_balance_wallet,
            title: 'Qarzdorlik',
            value: '${_formatCurrency(controller.totalDebt.value)} so\'m',
            color: controller.totalDebt.value > 0
                ? const Color(0xFFF44336)
                : const Color(0xFF4CAF50),
            gradient: controller.totalDebt.value > 0
                ? const LinearGradient(
                    colors: [Color(0xFFF44336), Color(0xFFE53935)],
                  )
                : const LinearGradient(
                    colors: [Color(0xFF4CAF50), Color(0xFF43A047)],
                  ),
          ),
          const SizedBox(width: 16),
          _buildStatCard(
            icon: Icons.payments,
            title: 'To\'langan',
            value: '${_formatCurrency(controller.totalPaid.value)} so\'m',
            color: const Color(0xFF4CAF50),
            gradient: const LinearGradient(
              colors: [Color(0xFF4CAF50), Color(0xFF43A047)],
            ),
          ),
          const SizedBox(width: 16),
          _buildStatCard(
            icon: Icons.calendar_month,
            title: 'Oylik to\'lov',
            value: '${_formatCurrency(controller.monthlyFee.value)} so\'m',
            color: const Color(0xFF2196F3),
            gradient: const LinearGradient(
              colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
            ),
          ),
          const SizedBox(width: 16),
          _buildStatCard(
            icon: Icons.how_to_reg,
            title: 'Davomat',
            value:
                '${controller.attendancePercentage.value.toStringAsFixed(1)}%',
            color: controller.attendancePercentage.value >= 80
                ? const Color(0xFF4CAF50)
                : const Color(0xFFFFA726),
            gradient: controller.attendancePercentage.value >= 80
                ? const LinearGradient(
                    colors: [Color(0xFF4CAF50), Color(0xFF43A047)],
                  )
                : const LinearGradient(
                    colors: [Color(0xFFFFA726), Color(0xFFFB8C00)],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required Gradient gradient,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== MA'LUMOT KARTALARI ====================
  Widget _buildPersonalInfo() {
    return Obx(() {
      final student = controller.student.value!;
      final isEditing = controller.isEditing.value;

      return _buildCard(
        title: 'Shaxsiy ma\'lumotlar',
        icon: Icons.person,
        child: Column(
          children: [
            if (isEditing) ...[
              _buildEditField('Ism', controller.firstNameController),
              const SizedBox(height: 12),
              _buildEditField('Familiya', controller.lastNameController),
              const SizedBox(height: 12),
              _buildEditField(
                'Otasining ismi',
                controller.middleNameController,
              ),
              const SizedBox(height: 12),
              _buildEditField('Telefon', controller.phoneController),
              const SizedBox(height: 12),
              _buildEditField(
                'Manzil',
                controller.addressController,
                maxLines: 2,
              ),
            ] else ...[
              _buildInfoRow('F.I.Sh', student.fullName),
              _buildInfoRow(
                'Jinsi',
                student.gender == 'male' ? 'O\'g\'il' : 'Qiz',
              ),
              _buildInfoRow('Tug\'ilgan sana', _formatDate(student.birthDate)),
              _buildInfoRow('Yoshi', '${student.age} yosh'),
              _buildInfoRow('Telefon', student.phone ?? '—'),
              _buildInfoRow('Qo\'shimcha tel.', student.phoneSecondary ?? '—'),
              _buildInfoRow('Manzil', student.address ?? '—'),
              _buildInfoRow(
                'Ro\'yxatdan o\'tgan',
                _formatDate(student.enrollmentDate),
              ),
              if (student.medicalNotes != null &&
                  student.medicalNotes!.isNotEmpty)
                _buildInfoRow(
                  'Tibbiy',
                  student.medicalNotes!,
                  isHighlighted: true,
                ),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildParentInfo() {
    return Obx(() {
      final student = controller.student.value!;
      final isEditing = controller.isEditing.value;

      return _buildCard(
        title: 'Ota-ona ma\'lumotlari',
        icon: Icons.family_restroom,
        child: Column(
          children: [
            if (isEditing) ...[
              _buildEditField('Telefon', controller.parentPhoneController),
            ] else ...[
              _buildInfoRow('F.I.Sh', student.parentFullName),
              _buildInfoRow('Aloqasi', student.parentRelation ?? '—'),
              _buildInfoRow('Telefon 1', student.parentPhone),
              _buildInfoRow('Telefon 2', student.parentPhoneSecondary ?? '—'),
              _buildInfoRow('Ish joyi', student.parentWorkplace ?? '—'),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildAcademicInfo() {
    return Obx(() {
      final enrollment = controller.currentEnrollment.value;

      return _buildCard(
        title: 'O\'quv ma\'lumotlari',
        icon: Icons.school,
        child: Column(
          children: [
            _buildInfoRow(
              'Sinf',
              controller.currentClassName.value ?? 'Biriktirilmagan',
            ),
            _buildInfoRow(
              'Sinf rahbari',
              controller.classTeacherName.value ?? '—',
            ),
            _buildInfoRow('Sinf xonasi', controller.classRoomName.value ?? '—'),
            _buildInfoRow(
              'O\'qish muddati',
              '${controller.studyDuration.value} yil',
            ),
            if (enrollment != null)
              _buildInfoRow(
                'Sinfga qo\'shilgan',
                _formatDate(enrollment['enrolled_at']),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildFinancialInfo() {
    return Obx(() {
      final student = controller.student.value!;
      final isEditing = controller.isEditing.value;

      return _buildCard(
        title: 'Moliyaviy ma\'lumotlar',
        icon: Icons.attach_money,
        child: Column(
          children: [
            if (isEditing) ...[
              _buildEditField('Oylik to\'lov', controller.monthlyFeeController),
              const SizedBox(height: 12),
              _buildEditField(
                'Chegirma %',
                controller.discountPercentController,
              ),
            ] else ...[
              _buildInfoRow(
                'Oylik to\'lov',
                '${_formatCurrency(student.monthlyFee)} so\'m',
              ),
              if (student.discountPercent > 0) ...[
                _buildInfoRow(
                  'Chegirma',
                  '${student.discountPercent}% (${_formatCurrency(student.discountAmount)} so\'m)',
                ),
                if (student.discountReason != null)
                  _buildInfoRow('Sabab', student.discountReason!),
              ],
              _buildInfoRow(
                'Yakuniy to\'lov',
                '${_formatCurrency(student.finalMonthlyFee)} so\'m',
                isHighlighted: true,
              ),
            ],
          ],
        ),
      );
    });
  }

  // ==================== TO'LOVLAR TARIXI ====================
  Widget _buildPaymentHistory() {
    return _buildCard(
      title: 'To\'lovlar tarixi',
      icon: Icons.payment,
      actions: [
        _buildFilterChip('Barchasi', 'all', controller.selectedPaymentFilter),
        const SizedBox(width: 8),
        _buildFilterChip(
          'To\'langan',
          'paid',
          controller.selectedPaymentFilter,
        ),
        const SizedBox(width: 8),
        _buildFilterChip(
          'Kutilmoqda',
          'pending',
          controller.selectedPaymentFilter,
        ),
      ],
      child: Obx(() {
        if (controller.isLoadingPayments.value) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(color: Color(0xFF2196F3)),
            ),
          );
        }

        final payments = controller.filteredPayments.take(10).toList();

        if (payments.isEmpty) {
          return _buildEmptyState('To\'lovlar tarixi bo\'sh', Icons.payment);
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: payments.length,
          separatorBuilder: (_, __) => const Divider(height: 24),
          itemBuilder: (context, index) {
            final payment = payments[index];
            return _buildPaymentItem(payment);
          },
        );
      }),
    );
  }

  Widget _buildFilterChip(
    String label,
    String value,
    Rx<String> currentFilter,
  ) {
    return Obx(() {
      final isSelected = currentFilter.value == value;
      return InkWell(
        onTap: () => controller.filterPayments(value),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF2196F3) : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : Colors.grey.shade700,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildPaymentItem(payment) {
    final isPaid = payment.paymentStatus == 'paid';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isPaid
            ? const Color(0xFF4CAF50).withOpacity(0.05)
            : const Color(0xFFFFA726).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPaid
              ? const Color(0xFF4CAF50).withOpacity(0.2)
              : const Color(0xFFFFA726).withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isPaid
                    ? [const Color(0xFF4CAF50), const Color(0xFF43A047)]
                    : [const Color(0xFFFFA726), const Color(0xFFFB8C00)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isPaid ? Icons.check_circle : Icons.pending,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payment.periodName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(payment.paymentDate),
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${_formatCurrency(payment.finalAmount)} so\'m',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isPaid
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFFFFA726),
                ),
              ),
              if (payment.discountPercent > 0) ...[
                const SizedBox(height: 2),
                Text(
                  '${payment.discountPercent}% chegirma',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // ==================== DAVOMAT TARIXI ====================
  Widget _buildAttendanceHistory() {
    return _buildCard(
      title: 'Davomat tarixi',
      icon: Icons.checklist,
      actions: [
        _buildFilterChip(
          'Barchasi',
          'all',
          controller.selectedAttendanceFilter,
        ),
        const SizedBox(width: 8),
        _buildFilterChip('Hafta', 'week', controller.selectedAttendanceFilter),
        const SizedBox(width: 8),
        _buildFilterChip('Oy', 'month', controller.selectedAttendanceFilter),
      ],
      child: Obx(() {
        if (controller.isLoadingAttendance.value) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(color: Color(0xFF2196F3)),
            ),
          );
        }

        return Column(
          children: [
            Row(
              children: [
                _buildAttendanceStat(
                  'Keldi',
                  controller.presentCount.value,
                  const Color(0xFF4CAF50),
                ),
                const SizedBox(width: 12),
                _buildAttendanceStat(
                  'Kelmadi',
                  controller.absentCount.value,
                  const Color(0xFFF44336),
                ),
                const SizedBox(width: 12),
                _buildAttendanceStat(
                  'Kechikdi',
                  controller.lateCount.value,
                  const Color(0xFFFFA726),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 20),
            _buildAttendanceList(),
          ],
        );
      }),
    );
  }

  Widget _buildAttendanceStat(String label, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [color, color.withOpacity(0.8)]),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceList() {
    return Obx(() {
      final records = controller.filteredAttendance.take(10).toList();

      if (records.isEmpty) {
        return _buildEmptyState('Davomat tarixi bo\'sh', Icons.checklist);
      }

      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: records.length,
        separatorBuilder: (_, __) => const Divider(height: 16),
        itemBuilder: (context, index) {
          final record = records[index];
          return _buildAttendanceItem(record);
        },
      );
    });
  }

  Widget _buildAttendanceItem(record) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (record.status) {
      case 'present':
        statusColor = const Color(0xFF4CAF50);
        statusIcon = Icons.check_circle;
        statusText = 'Keldi';
        break;
      case 'absent':
        statusColor = const Color(0xFFF44336);
        statusIcon = Icons.cancel;
        statusText = 'Kelmadi';
        break;
      case 'late':
        statusColor = const Color(0xFFFFA726);
        statusIcon = Icons.access_time;
        statusText = 'Kechikdi';
        break;
      case 'excused':
        statusColor = const Color(0xFF2196F3);
        statusIcon = Icons.event_note;
        statusText = 'Sababli';
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help_outline;
        statusText = 'Noma\'lum';
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: statusColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _formatDate(record.attendanceDate),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              statusText,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== DARS JADVALI ====================
  Widget _buildSchedule() {
    return _buildCard(
      title: 'Dars jadvali',
      icon: Icons.schedule,
      child: Obx(() {
        if (controller.isLoadingSchedule.value) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(color: Color(0xFF2196F3)),
            ),
          );
        }

        final schedule = controller.weeklySchedule;

        if (schedule.isEmpty) {
          return _buildEmptyState('Dars jadvali mavjud emas', Icons.schedule);
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: schedule.length,
          separatorBuilder: (_, __) => const Divider(height: 24),
          itemBuilder: (context, index) {
            final day = schedule[index];
            return _buildScheduleDay(day);
          },
        );
      }),
    );
  }

  Widget _buildScheduleDay(Map<String, dynamic> day) {
    final lessons = day['lessons'] as List<Map<String, String>>;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            day['day'] as String,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 12),
        ...lessons.map(
          (lesson) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF2196F3).withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFF2196F3).withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2196F3),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    lesson['time']!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    lesson['subject']!,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  lesson['teacher']!,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ==================== HELPER WIDGETS ====================
  Widget _buildCard({
    required String title,
    required IconData icon,
    required Widget child,
    List<Widget>? actions,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              if (actions != null) ...actions,
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    bool isHighlighted = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: isHighlighted ? const Color(0xFF2196F3) : Colors.black87,
                fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2196F3), width: 2),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(icon, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Color(0xFF2196F3)),
          const SizedBox(height: 16),
          Text(
            'Ma\'lumotlar yuklanmoqda...',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: Colors.red.shade300),
          const SizedBox(height: 16),
          Text(
            'O\'quvchi topilmadi',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Orqaga'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '—';
    return DateFormat('dd.MM.yyyy').format(date);
  }

  String _formatCurrency(double amount) {
    return amount
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
  }
}
