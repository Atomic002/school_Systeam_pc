// lib/presentation/screens/rooms_classes/class_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_application_1/presentation/controllers/class_detail_controller.dart';
import 'package:flutter_application_1/presentation/widgets/sidebar.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ClassDetailScreen extends StatelessWidget {
  ClassDetailScreen({Key? key}) : super(key: key);

  final ClassDetailController controller = Get.put(ClassDetailController());
  final numberFormat = NumberFormat('#,###', 'uz');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
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
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (controller.classData.value == null) {
                      return _buildErrorState();
                    }
                    return SingleChildScrollView(
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
                                    _buildClassInfo(),
                                    const SizedBox(height: 20),
                                    _buildFinancialInfo(),
                                    const SizedBox(height: 20),
                                    _buildTeachersList(),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                flex: 3,
                                child: Column(
                                  children: [
                                    _buildStudentsList(),
                                    const SizedBox(height: 20),
                                    _buildPaymentStats(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
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
    return Obx(() {
      final classData = controller.classData.value;
      if (classData == null) return const SizedBox();

      return Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4CAF50), Color(0xFF388E3C)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4CAF50).withOpacity(0.3),
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
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.school,
                    size: 40,
                    color: Color(0xFF4CAF50),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        classData['name'],
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildBadge(
                            Icons.people,
                            '${classData['student_count']}/${classData['max_students']}',
                          ),
                          const SizedBox(width: 12),
                          if (classData['room_name'] != null)
                            _buildBadge(
                              Icons.meeting_room,
                              classData['room_name'],
                            ),
                          const SizedBox(width: 12),
                          if (classData['class_level'] != null)
                            _buildBadge(Icons.school, classData['class_level']),
                        ],
                      ),
                    ],
                  ),
                ),
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildBadge(IconData icon, String text) {
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

  Widget _buildActionButtons() {
    return Row(
      children: [
        _buildHeaderButton(
          icon: Icons.edit,
          label: 'Tahrirlash',
          onTap: controller.editClass,
        ),
        const SizedBox(width: 12),
        _buildHeaderButton(
          icon: Icons.person_add,
          label: 'O\'quvchi qo\'shish',
          onTap: controller.addStudent,
        ),
      ],
    );
  }

  Widget _buildHeaderButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
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
                Icon(icon, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
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

  Widget _buildQuickStats() {
    return Obx(
      () => Row(
        children: [
          _buildStatCard(
            title: 'Jami o\'quvchilar',
            value: controller.totalStudents.value.toString(),
            icon: Icons.people,
            color: const Color(0xFF4CAF50),
            subtitle: 'Aktiv o\'quvchilar',
          ),
          const SizedBox(width: 16),
          _buildStatCard(
            title: 'To\'langan',
            value: '${numberFormat.format(controller.totalPaid.value)} so\'m',
            icon: Icons.payments,
            color: const Color(0xFF2196F3),
            subtitle: 'Bu oyda',
          ),
          const SizedBox(width: 16),
          _buildStatCard(
            title: 'Qarzdorlik',
            value: '${numberFormat.format(controller.totalDebt.value)} so\'m',
            icon: Icons.account_balance_wallet,
            color: const Color(0xFFF44336),
            subtitle: 'Umumiy qarz',
          ),
          const SizedBox(width: 16),
          _buildStatCard(
            title: 'O\'rtacha davomat',
            value: '${controller.averageAttendance.value.toStringAsFixed(1)}%',
            icon: Icons.how_to_reg,
            color: const Color(0xFFFFA726),
            subtitle: 'Bu oyda',
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String subtitle,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [color, color.withOpacity(0.8)]),
          borderRadius: BorderRadius.circular(12),
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
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 11, color: Colors.white60),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassInfo() {
    return Obx(() {
      final classData = controller.classData.value!;
      return _buildCard(
        title: 'Sinf ma\'lumotlari',
        icon: Icons.info,
        child: Column(
          children: [
            _buildInfoRow('Sinf nomi', classData['name']),
            _buildInfoRow('Kod', classData['code'] ?? '—'),
            _buildInfoRow('Filial', classData['branch_name'] ?? '—'),
            _buildInfoRow('Xona', classData['room_name'] ?? '—'),
            _buildInfoRow('Sinf rahbari', classData['teacher_name'] ?? '—'),
            _buildInfoRow('Daraja', classData['class_level'] ?? '—'),
            _buildInfoRow(
              'Maksimal sig\'im',
              '${classData['max_students']} kishi',
            ),
            if (classData['specialization'] != null)
              _buildInfoRow(
                'Mutaxassislik',
                classData['specialization'],
                isHighlighted: true,
              ),
          ],
        ),
      );
    });
  }

  Widget _buildFinancialInfo() {
    return Obx(() {
      final classData = controller.classData.value!;
      return _buildCard(
        title: 'Moliyaviy ma\'lumotlar',
        icon: Icons.attach_money,
        child: Column(
          children: [
            _buildInfoRow(
              'Oylik to\'lov',
              '${numberFormat.format(classData['monthly_fee'])} so\'m',
            ),
            _buildInfoRow(
              'Jami daromad (potensial)',
              '${numberFormat.format(classData['monthly_fee'] * controller.totalStudents.value)} so\'m',
              isHighlighted: true,
            ),
            _buildInfoRow(
              'To\'langan',
              '${numberFormat.format(controller.totalPaid.value)} so\'m',
            ),
            _buildInfoRow(
              'To\'lov foizi',
              '${controller.paymentPercentage.value.toStringAsFixed(1)}%',
            ),
            _buildInfoRow(
              'Qarzdorlar',
              '${controller.debtorCount.value} ta o\'quvchi',
            ),
          ],
        ),
      );
    });
  }

  Widget _buildTeachersList() {
    return Obx(() {
      final teachers = controller.teachers;
      return _buildCard(
        title: 'O\'qituvchilar',
        icon: Icons.person,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFF4CAF50)),
            onPressed: controller.addTeacher,
          ),
        ],
        child: teachers.isEmpty
            ? _buildEmptySection('O\'qituvchilar biriktirilmagan')
            : ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: teachers.length,
                separatorBuilder: (_, __) => const Divider(height: 16),
                itemBuilder: (context, index) =>
                    _buildTeacherItem(teachers[index]),
              ),
      );
    });
  }

  Widget _buildTeacherItem(Map<String, dynamic> teacher) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF4CAF50).withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF4CAF50).withOpacity(0.2)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFF4CAF50),
            child: Text(
              teacher['first_name'][0] + teacher['last_name'][0],
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${teacher['first_name']} ${teacher['last_name']}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (teacher['subject_name'] != null)
                  Text(
                    teacher['subject_name'],
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.remove_circle, color: Colors.red, size: 20),
            onPressed: () => controller.removeTeacher(teacher['id']),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentsList() {
    return Obx(() {
      final students = controller.students;
      return _buildCard(
        title: 'O\'quvchilar ro\'yxati (${students.length})',
        icon: Icons.people,
        actions: [
          TextField(
            decoration: const InputDecoration(
              hintText: 'Qidirish...',
              prefixIcon: Icon(Icons.search, size: 20),
              border: InputBorder.none,
              isDense: true,
            ),
            style: const TextStyle(fontSize: 14),
            onChanged: controller.onSearchChanged,
          ),
        ],
        child: students.isEmpty
            ? _buildEmptySection('O\'quvchilar yo\'q')
            : Column(
                children: [
                  // Filter buttons
                  Row(
                    children: [
                      _buildFilterChip('Barchasi', 'all'),
                      const SizedBox(width: 8),
                      _buildFilterChip('To\'lagan', 'paid'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Qarzdor', 'debt'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: students.length,
                    separatorBuilder: (_, __) => const Divider(height: 12),
                    itemBuilder: (context, index) =>
                        _buildStudentItem(students[index]),
                  ),
                ],
              ),
      );
    });
  }

  Widget _buildFilterChip(String label, String value) {
    return Obx(() {
      final isSelected = controller.selectedFilter.value == value;
      return InkWell(
        onTap: () => controller.filterStudents(value),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF4CAF50) : Colors.grey.shade200,
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

  Widget _buildStudentItem(Map<String, dynamic> student) {
    final hasDebt = student['debt'] != null && student['debt'] > 0;

    return InkWell(
      onTap: () {
        // O'quvchi detayliga o'tish
        Get.toNamed('/student-detail', arguments: {'id': student['id']});
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: hasDebt
              ? Colors.red.withOpacity(0.05)
              : Colors.green.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: hasDebt
                ? Colors.red.withOpacity(0.2)
                : Colors.green.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: hasDebt ? Colors.red : Colors.green,
              child: Text(
                student['first_name'][0],
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${student['first_name']} ${student['last_name']}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (student['phone'] != null)
                    Text(
                      student['phone'],
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                ],
              ),
            ),
            if (hasDebt)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${numberFormat.format(student['debt'])} so\'m',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            else
              const Icon(Icons.check_circle, color: Colors.green, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentStats() {
    return Obx(() {
      final payments = controller.paymentHistory;
      return _buildCard(
        title: 'To\'lovlar tarixi',
        icon: Icons.payment,
        child: payments.isEmpty
            ? _buildEmptySection('To\'lovlar yo\'q')
            : ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: payments.take(10).length,
                separatorBuilder: (_, __) => const Divider(height: 16),
                itemBuilder: (context, index) =>
                    _buildPaymentItem(payments[index]),
              ),
      );
    });
  }

  Widget _buildPaymentItem(Map<String, dynamic> payment) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2196F3).withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF2196F3).withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF2196F3),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.payment, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payment['student_name'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  DateFormat('dd.MM.yyyy').format(payment['payment_date']),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Text(
            '${numberFormat.format(payment['amount'])} so\'m',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2196F3),
            ),
          ),
        ],
      ),
    );
  }

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
                    colors: [Color(0xFF4CAF50), Color(0xFF388E3C)],
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
                color: isHighlighted ? const Color(0xFF4CAF50) : Colors.black87,
                fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySection(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(Icons.inbox, size: 60, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
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
            'Sinf topilmadi',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Orqaga'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
