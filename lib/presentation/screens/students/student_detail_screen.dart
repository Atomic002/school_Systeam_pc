

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/student_detail_controller.dart';
import '../../widgets/sidebar.dart';
import '../../../config/constants.dart';

class StudentDetailScreen extends StatelessWidget {
  StudentDetailScreen({Key? key}) : super(key: key);

  final controller = Get.put(StudentDetailController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundLight,
      body: Row(
        children: [
          Sidebar(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(child: CircularProgressIndicator());
              }

              if (controller.studentData.value == null) {
                return Center(child: Text('O\'quvchi topilmadi'));
              }

              return Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [_buildProfileCard(), _buildTabSection()],
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
          IconButton(
            onPressed: () => Get.back(),
            icon: Icon(Icons.arrow_back, color: AppConstants.primaryColor),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() => Text(
                  controller.fullName,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                )),
                Obx(() => Text(
                  controller.currentClassName.value ?? 'Sinf biriktirilmagan',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                )),
              ],
            ),
          ),
          _buildQuickActions(),
        ],
      ),
    );
  }

   Widget _buildQuickActions() {
    return Row(
      children: [
        IconButton(
          onPressed: controller.callParent,
          icon: Icon(Icons.phone, color: AppConstants.successColor),
          tooltip: 'Qo\'ng\'iroq',
        ),
        IconButton(
          onPressed: controller.sendMessage,
          icon: Icon(Icons.message, color: AppConstants.infoColor),
          tooltip: 'Xabar',
        ),
        IconButton(
          onPressed: controller.makePayment,
          icon: Icon(Icons.payment, color: AppConstants.warningColor),
          tooltip: 'To\'lov',
        ),
        
        // POPUP MENU (YANGILANGAN)
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert),
          onSelected: (value) {
            switch (value) {
              case 'pdf':
                controller.exportToPDF();
                break;
              case 'edit':
                controller.editStudent(); // <--- Controllerdagi yangi funksiya
                break;
              case 'deactivate':
                controller.deactivateStudent(); // <--- Controllerdagi yangi funksiya
                break;
              case 'delete':
                controller.deleteStudent(); // <--- Controllerdagi yangi funksiya
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'pdf',
              child: ListTile(
                leading: Icon(Icons.download),
                title: Text('PDF yuklash'),
                contentPadding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              ),
            ),
            const PopupMenuItem(
              value: 'edit',
              child: ListTile(
                leading: Icon(Icons.edit, color: Colors.blue),
                title: Text('Tahrirlash'),
                contentPadding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              ),
            ),
            const PopupMenuItem(
              value: 'deactivate',
              child: ListTile(
                leading: Icon(Icons.block, color: Colors.orange),
                title: Text('Faolsizlantirish'),
                contentPadding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('O\'chirish'),
                contentPadding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              ),
            ),
          ],
        ),
      ],
    );
  }
  Widget _buildProfileCard() {
    return Container(
      margin: EdgeInsets.all(24),
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF667eea).withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Obx(() {
        final data = controller.studentData.value;
        if (data == null) return SizedBox();

        return Row(
          children: [
            // Avatar
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
                color: Colors.white.withOpacity(0.2),
              ),
              child: controller.photoUrl != null
                  ? ClipOval(
                      child: Image.network(
                        controller.photoUrl!,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Center(
                      child: Text(
                        '${data['first_name'][0]}${data['last_name'][0]}'
                            .toUpperCase(),
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
            ),
            SizedBox(width: 24),

            // Ma'lumotlar
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        controller.fullName,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 12),
                      _buildStatusBadge(controller.status),
                    ],
                  ),
                  SizedBox(height: 8),
                  Obx(() => Text(
                    controller.currentClassName.value ?? 'Sinf biriktirilmagan',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  )),
                  SizedBox(height: 16),
                  Wrap(
                    spacing: 24,
                    runSpacing: 12,
                    children: [
                      _buildProfileStat(
                        Icons.calendar_today,
                        'Yoshi',
                        '${controller.age ?? 0} yosh',
                      ),
                      _buildProfileStat(
                        Icons.school,
                        'O\'qish muddati',
                        controller.getStudyDuration(),
                      ),
                      Obx(() => _buildProfileStat(
                        Icons.payments,
                        'Oylik',
                        '${_formatCurrency(controller.monthlyFee.value)} so\'m',
                      )),
                      Obx(() => _buildProfileStat(
                        Icons.people,
                        'Sinfdoshlar',
                        '${controller.classmates.length} ta',
                      )),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildStatusBadge(String status) {
    final config = _getStatusConfig(status);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: config['color'],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        config['text'],
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Map<String, dynamic> _getStatusConfig(String status) {
    switch (status) {
      case 'active':
        return {'color': Color(0xFF06D6A0), 'text': 'Faol'};
      case 'paused':
        return {'color': Color(0xFFFFC857), 'text': 'To\'xtatilgan'};
      case 'graduated':
        return {'color': Color(0xFF667eea), 'text': 'Bitirgan'};
      default:
        return {'color': Colors.grey, 'text': status};
    }
  }

  Widget _buildProfileStat(IconData icon, String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTabSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _buildTabBar(),
          SizedBox(height: 16),
          Obx(() => _buildTabContent()),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Row(
        children: [
          _buildTab('Umumiy', 0, Icons.info),
          _buildTab('To\'lovlar', 1, Icons.payments),
          _buildTab('Davomat', 2, Icons.calendar_today),
          _buildTab('Jadval', 3, Icons.schedule),
          _buildTab('Sinfdoshlar', 4, Icons.people),
        ],
      ),
    );
  }

  Widget _buildTab(String label, int index, IconData icon) {
    return Obx(() {
      final isSelected = controller.selectedTab.value == index;
      return Expanded(
        child: InkWell(
          onTap: () => controller.selectedTab.value = index,
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? AppConstants.primaryColor : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 18,
                    color: isSelected ? Colors.white : Colors.grey[600],
                  ),
                  SizedBox(width: 6),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected ? Colors.white : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildTabContent() {
    switch (controller.selectedTab.value) {
      case 0:
        return _buildGeneralTab();
      case 1:
        return _buildPaymentsTab();
      case 2:
        return _buildAttendanceTab();
      case 3:
        return _buildScheduleTab();
      case 4:
        return _buildClassmatesTab();
      default:
        return _buildGeneralTab();
    }
  }

  Widget _buildGeneralTab() {
    return Obx(() {
      final data = controller.studentData.value;
      if (data == null) return SizedBox();

      return Column(
        children: [
          _buildInfoCard(
            title: 'Shaxsiy ma\'lumotlar',
            icon: Icons.person,
            children: [
              _buildInfoRow('F.I.Sh', controller.fullName),
              _buildInfoRow('Jinsi', controller.genderText),
              _buildInfoRow('Tug\'ilgan sana', _formatDate(data['birth_date'])),
              _buildInfoRow('Yoshi', '${controller.age ?? 0} yosh'),
              _buildInfoRow('Telefon', controller.phone),
              _buildInfoRow('Manzil', controller.address),
            ],
          ),
          SizedBox(height: 16),
          _buildInfoCard(
            title: 'Ota-ona ma\'lumotlari',
            icon: Icons.family_restroom,
            children: [
              _buildInfoRow('F.I.Sh', controller.parentFullName),
              _buildInfoRow('Aloqasi', controller.parentRelation),
              _buildInfoRow('Telefon', controller.parentPhone),
              if (controller.parentPhoneSecondary != null)
                _buildInfoRow('Qo\'shimcha telefon', controller.parentPhoneSecondary!),
              _buildInfoRow('Ish joyi', controller.parentWorkplace),
            ],
          ),
          SizedBox(height: 16),
          _buildInfoCard(
            title: 'O\'quv ma\'lumotlari',
            icon: Icons.school,
            children: [
              Obx(() => _buildInfoRow('Sinf', controller.currentClassName.value ?? '—')),
              Obx(() => _buildInfoRow('Sinf kodi', controller.currentClassCode.value ?? '—')),
              Obx(() => _buildInfoRow('Sinf darajasi', controller.classLevelName.value ?? '—')),
              Obx(() => _buildInfoRow(
                'Sinf rahbari',
                controller.classTeacherName.value ?? '—',
                onTap: controller.classTeacherId.value != null 
                    ? controller.viewTeacherProfile 
                    : null,
              )),
              Obx(() => _buildInfoRow('Sinf xonasi', controller.classRoomName.value ?? '—')),
              Obx(() => _buildInfoRow('Filial', controller.branchName.value ?? '—')),
              Obx(() => _buildInfoRow('O\'qish muddati', controller.getStudyDuration())),
              Obx(() => _buildInfoRow(
                'Sinf sig\'imi',
                '${controller.currentClassSize.value}/${controller.classCapacity.value}',
              )),
            ],
          ),
          if (controller.hasMedicalNotes) ...[
            SizedBox(height: 16),
            _buildInfoCard(
              title: 'Tibbiy ma\'lumotlar',
              icon: Icons.medical_services,
              children: [
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    controller.medicalNotes,
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ],
          if (controller.hasNotes) ...[
            SizedBox(height: 16),
            _buildInfoCard(
              title: 'Qo\'shimcha izohlar',
              icon: Icons.note,
              children: [
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    controller.notes,
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ],
        ],
      );
    });
  }

  Widget _buildPaymentsTab() {
    return Obx(() {
      if (controller.isLoadingPayments.value) {
        return Center(child: CircularProgressIndicator());
      }

      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Jami to\'landi',
                  _formatCurrency(controller.totalPaid.value),
                  Icons.check_circle,
                  AppConstants.successColor,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Qarzdorlik',
                  _formatCurrency(controller.totalDebt.value),
                  Icons.warning,
                  AppConstants.errorColor,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Oylik',
                  _formatCurrency(controller.monthlyFee.value),
                  Icons.payments,
                  AppConstants.primaryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          _buildMonthlyPayments(),
          SizedBox(height: 16),
          _buildPaymentsHistory(),
        ],
      );
    });
  }

  Widget _buildMonthlyPayments() {
    return Obx(() {
      if (controller.monthlyPayments.isEmpty) return SizedBox();

      return Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Oylik to\'lovlar (so\'nggi 12 oy)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Divider(height: 1),
            Padding(
              padding: EdgeInsets.all(16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: controller.monthlyPayments.map((m) {
                  final isPaid = m['isPaid'] as bool;
                  final month = m['month'] as int;
                  final year = m['year'] as int;
                  final paid = (m['paid'] as num).toDouble();
                  final expected = (m['expected'] as num).toDouble();

                  return Tooltip(
                    message: '$month-oy, $year\nTo\'langan: ${_formatCurrency(paid)}\nKutilgan: ${_formatCurrency(expected)}',
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: isPaid 
                            ? AppConstants.successColor.withOpacity(0.1)
                            : AppConstants.errorColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isPaid ? AppConstants.successColor : AppConstants.errorColor,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$month',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isPaid ? AppConstants.successColor : AppConstants.errorColor,
                            ),
                          ),
                          Text(
                            '$year'.substring(2),
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildPaymentsHistory() {
    return Obx(() {
      final payments = controller.paymentHistory;

      if (payments.isEmpty) {
        return _buildEmptyCard('To\'lovlar tarixi bo\'sh', Icons.payment);
      }

      return Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'To\'lovlar tarixi',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Divider(height: 1),
            ...payments.map((payment) => _buildPaymentRow(payment)),
          ],
        ),
      );
    });
  }

  Widget _buildPaymentRow(dynamic payment) {
    final isPaid = payment['payment_status'] == 'paid';
    final date = DateTime.parse(payment['payment_date']);
    final amount = ((payment['final_amount'] ?? 0) as num).toDouble();

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: (isPaid ? AppConstants.successColor : AppConstants.warningColor)
                  .withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isPaid ? Icons.check_circle : Icons.pending,
              color: isPaid ? AppConstants.successColor : AppConstants.warningColor,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${payment['period_month']}-oy, ${payment['period_year']}',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                Text(
                  DateFormat('dd.MM.yyyy').format(date),
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            '${_formatCurrency(amount)} so\'m',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isPaid ? AppConstants.successColor : AppConstants.warningColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceTab() {
    return Obx(() {
      if (controller.isLoadingAttendance.value) {
        return Center(child: CircularProgressIndicator());
      }

      return Column(
        children: [
          // Statistika
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Kelgan',
                  controller.presentCount.toString(),
                  Icons.check_circle,
                  AppConstants.successColor,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Kelmagan',
                  controller.absentCount.toString(),
                  Icons.cancel,
                  AppConstants.errorColor,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Kechikkan',
                  controller.lateCount.toString(),
                  Icons.access_time,
                  AppConstants.warningColor,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Davomat %',
                  '${controller.attendancePercentage.toStringAsFixed(1)}%',
                  Icons.analytics,
                  AppConstants.infoColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          
          // Sana filtri
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Text('Sana oralig\'i:', style: TextStyle(fontWeight: FontWeight.w600)),
                  SizedBox(width: 12),
                  Obx(() => _buildDateButton(
                    controller.attendanceStartDate.value,
                    controller.selectAttendanceStartDate,
                  )),
                  SizedBox(width: 12),
                  Text('dan'),
                  SizedBox(width: 12),
                  Obx(() => _buildDateButton(
                    controller.attendanceEndDate.value,
                    controller.selectAttendanceEndDate,
                  )),
                  SizedBox(width: 12),
                  Text('gacha'),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),

          // Davomat ro'yxati
          _buildAttendanceList(),
        ],
      );
    });
  }

  Widget _buildAttendanceList() {
    final records = controller.attendanceRecords;
    
    if (records.isEmpty) {
      return _buildEmptyCard('Davomat ma\'lumotlari topilmadi', Icons.calendar_today);
    }

    return Card(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Davomat tarixi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Divider(height: 1),
          ...records.map((record) => _buildAttendanceRow(record)),
        ],
      ),
    );
  }

  Widget _buildAttendanceRow(dynamic record) {
    final date = DateTime.parse(record['attendance_date']);
    final status = record['status'];
    final session = record['schedule_sessions'];
    final subject = session?['subjects'];
    final teacher = session?['staff'];

    final statusColor = status == 'present'
        ? AppConstants.successColor
        : status == 'late'
        ? AppConstants.warningColor
        : AppConstants.errorColor;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              status == 'present'
                  ? Icons.check_circle
                  : status == 'late'
                  ? Icons.access_time
                  : Icons.cancel,
              color: statusColor,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('dd.MM.yyyy - EEEE', 'uz').format(date),
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                if (subject != null)
                  Text(
                    'Fan: ${subject['name']}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                if (teacher != null)
                  Text(
                    'O\'qituvchi: ${teacher['first_name']} ${teacher['last_name']}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status == 'present'
                  ? 'Keldi'
                  : status == 'late'
                  ? 'Kechikdi'
                  : 'Kelmadi',
              style: TextStyle(
                color: statusColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleTab() {
    return Obx(() {
      if (controller.isLoadingSchedule.value) {
        return Center(child: CircularProgressIndicator());
      }

      if (controller.weeklySchedule.isEmpty) {
        return _buildEmptyCard('Dars jadvali topilmadi', Icons.schedule);
      }

      return Column(
        children: [
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Haftalik dars jadvali',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Obx(() => Text(
                    'Sinf: ${controller.currentClassName.value ?? "—"}',
                    style: TextStyle(color: Colors.grey[600]),
                  )),
                  Obx(() => Text(
                    'Sinf rahbari: ${controller.classTeacherName.value ?? "—"}',
                    style: TextStyle(color: Colors.grey[600]),
                  )),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          ...controller.weeklySchedule.map((daySchedule) {
            return _buildDaySchedule(daySchedule);
          }),
        ],
      );
    });
  }

  Widget _buildDaySchedule(Map<String, dynamic> daySchedule) {
    final day = daySchedule['day'] as String;
    final lessons = daySchedule['lessons'] as List;

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppConstants.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: AppConstants.primaryColor),
                SizedBox(width: 12),
                Text(
                  day,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.primaryColor,
                  ),
                ),
                Spacer(),
                Text(
                  '${lessons.length} ta dars',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          ...lessons.asMap().entries.map((entry) {
            final index = entry.key;
            final lesson = entry.value;
            return _buildLessonRow(lesson, index + 1);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildLessonRow(dynamic lesson, int lessonNumber) {
    final subject = lesson['subjects'] as Map<String, dynamic>?;
    final teacher = lesson['staff'] as Map<String, dynamic>?;
    final room = lesson['rooms'] as Map<String, dynamic>?;
    final startTime = lesson['start_time'] as String?;
    final endTime = lesson['end_time'] as String?;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          // Dars raqami
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppConstants.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '$lessonNumber',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.primaryColor,
                ),
              ),
            ),
          ),
          SizedBox(width: 16),

          // Vaqt
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                startTime ?? '—',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              Text(
                endTime ?? '—',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          SizedBox(width: 16),

          // Fan va o'qituvchi
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject?['name'] ?? 'Fan ko\'rsatilmagan',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                if (teacher != null)
                  InkWell(
                    onTap: () {
                      final teacherId = teacher['id'];
                      if (teacherId != null) {
                        Get.toNamed('/staff-detail', arguments: {'staffId': teacherId});
                      }
                    },
                    child: Text(
                      '${teacher['first_name']} ${teacher['last_name']}',
                      style: TextStyle(
                        color: AppConstants.primaryColor,
                        fontSize: 14,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Xona
          if (room != null)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppConstants.infoColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.room, size: 16, color: AppConstants.infoColor),
                  SizedBox(width: 4),
                  Text(
                    room['name'] ?? '—',
                    style: TextStyle(
                      color: AppConstants.infoColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildClassmatesTab() {
    return Obx(() {
      if (controller.isLoadingClassmates.value) {
        return Center(child: CircularProgressIndicator());
      }

      if (controller.classmates.isEmpty) {
        return _buildEmptyCard('Sinfdoshlar topilmadi', Icons.people);
      }

      return Column(
        children: [
          // Sinf ma'lumotlari
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sinf ma\'lumotlari',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildClassInfoItem(
                          'Sinf',
                          controller.currentClassName.value ?? '—',
                          Icons.class_,
                        ),
                      ),
                      Expanded(
                        child: _buildClassInfoItem(
                          'Sinf rahbari',
                          controller.classTeacherName.value ?? '—',
                          Icons.person,
                          onTap: controller.classTeacherId.value != null
                              ? controller.viewTeacherProfile
                              : null,
                        ),
                      ),
                      Expanded(
                        child: _buildClassInfoItem(
                          'Xona',
                          controller.classRoomName.value?.split('(')[0].trim() ?? '—',
                          Icons.room,
                        ),
                      ),
                      Expanded(
                        child: _buildClassInfoItem(
                          'O\'quvchilar',
                          '${controller.currentClassSize.value}/${controller.classCapacity.value}',
                          Icons.people,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),

          // Sinfdoshlar ro'yxati
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Sinfdoshlar ro\'yxati',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Divider(height: 1),
                ...controller.classmates.map((classmate) {
                  return _buildClassmateRow(classmate);
                }).toList(),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _buildClassInfoItem(String label, String value, IconData icon, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: Colors.grey[600]),
              SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: onTap != null ? AppConstants.primaryColor : Colors.black,
              decoration: onTap != null ? TextDecoration.underline : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassmateRow(Map<String, dynamic> classmate) {
    final status = classmate['status'] ?? 'active';
    final monthlyFee = (classmate['monthly_fee'] as num?)?.toDouble() ?? 0;

    return InkWell(
      onTap: () => controller.viewClassmateProfile(classmate['id']),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppConstants.primaryColor.withOpacity(0.1),
              ),
              child: classmate['photo_url'] != null
                  ? ClipOval(
                      child: Image.network(
                        classmate['photo_url'],
                        fit: BoxFit.cover,
                      ),
                    )
                  : Center(
                      child: Text(
                        classmate['name'].toString().split(' ').map((e) => e[0]).take(2).join().toUpperCase(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppConstants.primaryColor,
                        ),
                      ),
                    ),
            ),
            SizedBox(width: 16),

            // Ma'lumotlar
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    classmate['name'],
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.phone, size: 14, color: Colors.grey[600]),
                      SizedBox(width: 4),
                      Text(
                        classmate['phone'] ?? 'Telefon yo\'q',
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

            // Oylik va status
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${_formatCurrency(monthlyFee)} so\'m',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 4),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: status == 'active'
                        ? AppConstants.successColor.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status == 'active' ? 'Faol' : 'Noaktiv',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: status == 'active' ? AppConstants.successColor : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(width: 12),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  // ==================== HELPER WIDGETS ====================

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppConstants.primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Icon(icon, color: AppConstants.primaryColor, size: 24),
                SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.primaryColor,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                label,
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: onTap != null ? AppConstants.primaryColor : Colors.black,
                  decoration: onTap != null ? TextDecoration.underline : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
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
              Spacer(),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildEmptyCard(String message, IconData icon) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: Center(
          child: Column(
            children: [
              Icon(icon, size: 64, color: Colors.grey[300]),
              SizedBox(height: 16),
              Text(message, style: TextStyle(color: Colors.grey[600])),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateButton(DateTime date, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: AppConstants.primaryColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.calendar_today, size: 16, color: AppConstants.primaryColor),
            SizedBox(width: 8),
            Text(
              DateFormat('dd.MM.yyyy').format(date),
              style: TextStyle(color: AppConstants.primaryColor),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return '—';
    try {
      if (date is String) {
        return DateFormat('dd.MM.yyyy').format(DateTime.parse(date));
      } else if (date is DateTime) {
        return DateFormat('dd.MM.yyyy').format(date);
      }
    } catch (e) {
      return '—';
    }
    return '—';
  }

  String _formatCurrency(double amount) {
    return NumberFormat('#,###').format(amount);
  }
}