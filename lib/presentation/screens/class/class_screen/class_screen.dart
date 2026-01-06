import 'package:flutter/material.dart';
import 'package:flutter_application_1/presentation/controllers/class_detail_controller.dart';
import 'package:flutter_application_1/presentation/widgets/sidebar.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ClassDetailScreen extends StatelessWidget {
  ClassDetailScreen({Key? key}) : super(key: key);

  final ClassDetailController controller = Get.put(ClassDetailController());
  final currencyFormat = NumberFormat('#,###', 'uz');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE), // Zamonaviy och fon
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Sidebar(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.classData.value == null) {
                return _buildErrorState();
              }

              return Column(
                children: [
                  _buildHeader(), // Title, Buttons
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildStatisticsCards(), // Top 4 cards
                          const SizedBox(height: 24),

                          // Main Content Split
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // LEFT: Students Table (70% width)
                              Expanded(
                                flex: 7,
                                child: Column(
                                  children: [_buildStudentsSection()],
                                ),
                              ),
                              const SizedBox(width: 24),
                              // RIGHT: Details Sidebar (30% width)
                              Expanded(
                                flex: 3,
                                child: Column(
                                  children: [
                                    _buildClassInfoCard(),
                                    const SizedBox(height: 24),
                                    _buildTeachersCard(),
                                    const SizedBox(height: 24),
                                    _buildRecentPaymentsCard(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
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

  // --- 1. HEADER QISMI ---
  Widget _buildHeader() {
    final cData = controller.classData.value!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      color: Colors.white,
      child: Row(
        children: [
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back_ios, size: 20),
            color: Colors.grey[700],
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                cData['name'],
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2B3674),
                ),
              ),
              Text(
                'Sinf rahbari: ${cData['main_teacher'] != null ? "${cData['main_teacher']['first_name']} ${cData['main_teacher']['last_name']}" : "Biriktirilmagan"}',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],
          ),
          const Spacer(),
          // Action Buttons
          _actionButton(
            icon: Icons.edit,
            label: 'Tahrirlash',
            color: Colors.blue[700]!,
            onTap: controller.editClass,
          ),
          const SizedBox(width: 12),
          _actionButton(
            icon: Icons.person_add,
            label: 'O\'quvchi',
            color: Colors.green[600]!,
            onTap: controller.addStudent,
          ),
          const SizedBox(width: 12),
          _actionButton(
            icon: Icons.delete_outline,
            label: 'O\'chirish',
            color: Colors.red,
            onTap: controller.deleteClass,
          ),

          const SizedBox(width: 12),
          Obx(
            () => ElevatedButton.icon(
              onPressed: controller.isExporting.value
                  ? null
                  : controller.exportToPdf,
              icon: controller.isExporting.value
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.picture_as_pdf, size: 18),
              label: const Text('PDF Yuklash'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE02D1B), // PDF red color
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18, color: color),
      label: Text(label, style: TextStyle(color: color)),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        side: BorderSide(color: color.withOpacity(0.5)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // --- 2. STATISTIKA KARTALARI ---
  Widget _buildStatisticsCards() {
    return Row(
      children: [
        _statCard(
          title: 'O\'quvchilar',
          value: controller.totalStudents.value.toString(),
          icon: Icons.groups,
          color: Colors.blue,
          subtitle: 'Jami faol o\'quvchilar',
        ),
        const SizedBox(width: 16),
        _statCard(
          title: 'To\'langan Summa',
          value:
              '${currencyFormat.format(controller.totalCollectedRevenue.value)} so\'m',
          icon: Icons.account_balance_wallet,
          color: Colors.green,
          subtitle:
              '${controller.collectionRate.value.toStringAsFixed(1)}% yig\'ildi',
        ),
        const SizedBox(width: 16),
        _statCard(
          title: 'Jami Qarzdorlik',
          value: '${currencyFormat.format(controller.totalDebt.value)} so\'m',
          icon: Icons.warning_rounded,
          color: Colors.red,
          subtitle: '${controller.debtorsCount.value} ta o\'quvchida qarz bor',
        ),
        const SizedBox(width: 16),
        _statCard(
          title: 'Davomat (Oy)',
          value: '${controller.averageAttendance.value.toStringAsFixed(1)}%',
          icon: Icons.checklist_rtl,
          color: Colors.orange,
          subtitle: 'O\'rtacha ishtirok',
        ),
      ],
    );
  }

  Widget _statCard({
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
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
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2B3674),
              ),
            ),
            const SizedBox(height: 4),
            Text(subtitle, style: TextStyle(fontSize: 12, color: color)),
          ],
        ),
      ),
    );
  }

  // --- 3. O'QUVCHILAR RO'YXATI (ASOSIY) ---
  Widget _buildStudentsSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'O\'quvchilar ro\'yxati',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2B3674),
                ),
              ),
              SizedBox(
                width: 250,
                child: TextField(
                  onChanged: (v) => controller.searchQuery.value = v,
                  decoration: InputDecoration(
                    hintText: 'Qidirish...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    filled: true,
                    fillColor: const Color(0xFFF4F7FE),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 0,
                      horizontal: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Filters
          Row(
            children: [
              _filterChip('Barchasi', 'all'),
              const SizedBox(width: 10),
              _filterChip('Qarzdorlar', 'debt', color: Colors.red),
              const SizedBox(width: 10),
              _filterChip('To\'laganlar', 'paid', color: Colors.green),
            ],
          ),
          const SizedBox(height: 20),

          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F7FE),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: const [
                SizedBox(
                  width: 40,
                  child: Text(
                    '#',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'F.I.SH & Telefon',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Oylik (Net)',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Jami To\'lov',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Qarz',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'Holat',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // List
          Obx(
            () => ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.filteredStudents.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, color: Color(0xFFEEEEEE)),
              itemBuilder: (context, index) {
                final student = controller.filteredStudents[index];
                return _buildStudentRow(index, student);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, String value, {Color color = Colors.blue}) {
    return Obx(() {
      final isSelected = controller.filterType.value == value;
      return InkWell(
        onTap: () => controller.filterType.value = value,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? color : Colors.grey.shade300,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[700],
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildStudentRow(int index, Map<String, dynamic> student) {
    bool hasDebt = student['debt'] > 0;
    return InkWell(
      // --- TUZATILGAN QISM ---
      onTap: () => Get.toNamed(
        '/student-detail',
        arguments: {
          'studentId': student['id'],
        }, // Controller shu nomni kutyapti
      ),
      // -----------------------
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Row(
          children: [
            SizedBox(
              width: 40,
              child: Text(
                '${index + 1}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.indigo.shade50,
                    radius: 18,
                    child: Text(
                      student['first_name'][0],
                      style: TextStyle(
                        color: Colors.indigo.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${student['first_name']} ${student['last_name']}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2B3674),
                        ),
                      ),
                      if (student['phone'] != null)
                        Text(
                          student['phone'],
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                currencyFormat.format(student['net_monthly_fee']),
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                currencyFormat.format(student['total_paid']),
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                hasDebt ? currencyFormat.format(student['debt']) : '-',
                style: TextStyle(
                  color: hasDebt ? Colors.red : Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: hasDebt
                      ? Colors.red.withOpacity(0.1)
                      : Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  hasDebt ? 'Qarzdor' : 'To\'lagan',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: hasDebt ? Colors.red : Colors.green,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 4. O'NG SIDEBAR QISMI ---

  // Sinf ma'lumotlari
  Widget _buildClassInfoCard() {
    final cData = controller.classData.value!;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sinf Haqida',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2B3674),
            ),
          ),
          const SizedBox(height: 16),
          _infoRow(
            Icons.meeting_room_outlined,
            'Xona',
            cData['room']?['name'] ?? '-',
          ),
          _infoRow(
            Icons.layers_outlined,
            'Daraja',
            cData['class_level']?['name'] ?? '-',
          ),
          _infoRow(
            Icons.people_outline,
            'Maksimal sig\'im',
            '${cData['max_students']} o\'quvchi',
          ),
          _infoRow(
            Icons.monetization_on_outlined,
            'Oylik to\'lov',
            '${currencyFormat.format(cData['monthly_fee'])} so\'m',
          ),
          if (cData['specialization'] != null)
            _infoRow(
              Icons.star_border,
              'Mutaxassislik',
              cData['specialization'],
            ),
        ],
      ),
    );
  }

  // O'qituvchilar ro'yxati
  // O'qituvchilar kartasida removeTeacher() chaqirilganida to'g'ri id uzatish
  // _buildTeachersCard() funksiyasidagi o'zgartirish:

  Widget _buildTeachersCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Fan O\'qituvchilari',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2B3674),
                ),
              ),
              IconButton(
                onPressed: controller.addTeacher,
                icon: const Icon(Icons.add_circle_outline, color: Colors.blue),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Obx(() {
            if (controller.teachers.isEmpty) {
              return const Text(
                'Biriktirilgan o\'qituvchi yo\'q',
                style: TextStyle(color: Colors.grey),
              );
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.teachers.length,
              itemBuilder: (context, index) {
                final t = controller.teachers[index];
                final staff = t['staff'];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.blue.shade50,
                        radius: 16,
                        child: Text(
                          staff['first_name'][0],
                          style: TextStyle(
                            color: Colors.blue.shade800,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${staff['first_name']} ${staff['last_name']}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              t['subject']?['name'] ?? 'Fan yo\'q',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          size: 18,
                          color: Colors.red,
                        ),
                        onPressed: () => controller.removeTeacher(
                          t['id'],
                        ), // Bu yerda t['id'] uzatiladi
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

  // So'nggi to'lovlar
  Widget _buildRecentPaymentsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'So\'nggi To\'lovlar',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2B3674),
            ),
          ),
          const SizedBox(height: 16),
          Obx(() {
            if (controller.recentPayments.isEmpty)
              return const Text(
                'To\'lovlar tarixi yo\'q',
                style: TextStyle(color: Colors.grey),
              );
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.recentPayments.length,
              itemBuilder: (context, index) {
                final p = controller.recentPayments[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.payment,
                          size: 14,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${p['student']['first_name']} ${p['student']['last_name']}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              DateFormat(
                                'dd.MM.yyyy',
                              ).format(DateTime.parse(p['payment_date'])),
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '+${currencyFormat.format(p['final_amount'])}',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
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

  // Yordamchi widget
  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[400]),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF2B3674),
            ),
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
          const Icon(Icons.error_outline, size: 60, color: Colors.red),
          const SizedBox(height: 16),
          const Text('Sinf ma\'lumotlari topilmadi'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Get.back(),
            child: const Text('Orqaga qaytish'),
          ),
        ],
      ),
    );
  }
}
