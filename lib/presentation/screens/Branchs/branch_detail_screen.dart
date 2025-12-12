// lib/presentation/screens/branches/branch_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/branch_controller.dart';
import '../../widgets/sidebar.dart';
import '../../../config/app_routes.dart';

class BranchDetailScreen extends StatefulWidget {
  const BranchDetailScreen({Key? key}) : super(key: key);

  @override
  State<BranchDetailScreen> createState() => _BranchDetailScreenState();
}

class _BranchDetailScreenState extends State<BranchDetailScreen> {
  final BranchController controller = Get.find<BranchController>();

  @override
  void initState() {
    super.initState();
    // Bu yerda yuklaymiz - build paytida emas!
    final branch = Get.arguments;
    if (branch != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.loadBranchDetails(branch.id);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final branch = Get.arguments;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Row(
        children: [
          Sidebar(),
          Expanded(
            child: Column(
              children: [
                _buildHeader(branch),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        _buildMainStats(branch),
                        const SizedBox(height: 24),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Column(
                                children: [
                                  _buildStudentStats(branch),
                                  const SizedBox(height: 24),
                                  _buildFinancialStats(branch),
                                  const SizedBox(height: 24),
                                  _buildStaffStats(branch),
                                ],
                              ),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              child: Column(
                                children: [
                                  _buildBranchInfo(branch),
                                  const SizedBox(height: 24),
                                  _buildQuickActions(branch),
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(branch) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF2196F3)),
                onPressed: () => Get.back(),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2196F3).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  branch.isMain ? Icons.home_work : Icons.business,
                  color: const Color(0xFF2196F3),
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          branch.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 12),
                        if (branch.isMain)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF9800),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Asosiy filial',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: branch.isActive
                                ? const Color(0xFF4CAF50)
                                : Colors.grey,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            branch.statusText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (branch.address != null)
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            branch.address!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Get.toNamed(AppRoutes.addBranch, arguments: branch);
                },
                icon: const Icon(Icons.edit),
                label: const Text('Tahrirlash'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainStats(branch) {
    return Obx(() {
      final details = controller.selectedBranch.value ?? branch;
      return Row(
        children: [
          _buildStatCard(
            'O\'quvchilar',
            '${details.activeStudents ?? 0}',
            '${details.totalStudents ?? 0} dan',
            Icons.school,
            const Color(0xFF2196F3),
            (details.activeStudents ?? 0) / (details.totalStudents ?? 1),
          ),
          const SizedBox(width: 16),
          _buildStatCard(
            'O\'qituvchilar',
            '${details.totalTeachers ?? 0}',
            '${details.totalStaff ?? 0} xodimdan',
            Icons.person,
            const Color(0xFF4CAF50),
            (details.totalTeachers ?? 0) / (details.totalStaff ?? 1),
          ),
          const SizedBox(width: 16),
          _buildStatCard(
            'Sinflar',
            '${details.totalClasses ?? 0}',
            '${details.totalRooms ?? 0} xonada',
            Icons.class_,
            const Color(0xFFFF9800),
            (details.totalClasses ?? 0) / (details.totalRooms ?? 1),
          ),
          const SizedBox(width: 16),
          _buildStatCard(
            'To\'ldirish',
            '${details.studentOccupancyRate.toStringAsFixed(0)}%',
            'Sig\'im',
            Icons.trending_up,
            const Color(0xFF9C27B0),
            details.studentOccupancyRate / 100,
          ),
        ],
      );
    });
  }

  Widget _buildStatCard(
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color color,
    double progress,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
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
                const Spacer(),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                backgroundColor: color.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentStats(branch) {
    return Obx(() {
      final details = controller.selectedBranch.value ?? branch;
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2196F3).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.school, color: Color(0xFF2196F3)),
                ),
                const SizedBox(width: 12),
                const Text(
                  'O\'quvchilar statistikasi',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildSmallStat(
                    'Faol',
                    '${details.activeStudents ?? 0}',
                    Icons.check_circle,
                    const Color(0xFF4CAF50),
                  ),
                ),
                Expanded(
                  child: _buildSmallStat(
                    'Jami',
                    '${details.totalStudents ?? 0}',
                    Icons.people,
                    const Color(0xFF2196F3),
                  ),
                ),
                Expanded(
                  child: _buildSmallStat(
                    'To\'xtatilgan',
                    '${details.pausedStudents ?? 0}',
                    Icons.pause_circle,
                    const Color(0xFFFF9800),
                  ),
                ),
                Expanded(
                  child: _buildSmallStat(
                    'Bitirgan',
                    '${details.graduatedStudents ?? 0}',
                    Icons.school,
                    const Color(0xFF9C27B0),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'O\'rtacha oylik to\'lov:',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                Text(
                  '${_formatCurrency(details.averageMonthlyFee ?? 0)} so\'m',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildFinancialStats(branch) {
    return Obx(() {
      final details = controller.selectedBranch.value ?? branch;
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.attach_money,
                    color: Color(0xFF4CAF50),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Moliyaviy ko\'rsatkichlar',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildFinancialItem(
              'Oylik daromad',
              '${_formatCurrency(details.monthlyRevenue ?? 0)} so\'m',
              Icons.calendar_month,
              const Color(0xFF2196F3),
            ),
            const SizedBox(height: 12),
            _buildFinancialItem(
              'Yillik daromad',
              '${_formatCurrency(details.yearlyRevenue ?? 0)} so\'m',
              Icons.calendar_today,
              const Color(0xFF4CAF50),
            ),
            const SizedBox(height: 12),
            _buildFinancialItem(
              'Xarajatlar',
              '${_formatCurrency(details.totalExpenses ?? 0)} so\'m',
              Icons.money_off,
              const Color(0xFFF44336),
            ),
            const SizedBox(height: 12),
            _buildFinancialItem(
              'Sof foyda',
              '${_formatCurrency(details.netProfit ?? 0)} so\'m',
              Icons.trending_up,
              const Color(0xFF9C27B0),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Foyda darajasi:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4CAF50),
                    ),
                  ),
                  Text(
                    '${details.profitMargin.toStringAsFixed(1)}%',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4CAF50),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildDebtInfo(details),
          ],
        ),
      );
    });
  }

  Widget _buildFinancialItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildDebtInfo(details) {
    final hasDebts = (details.totalDebts ?? 0) > 0;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: hasDebts
            ? const Color(0xFFF44336).withOpacity(0.1)
            : const Color(0xFF4CAF50).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasDebts
              ? const Color(0xFFF44336).withOpacity(0.3)
              : const Color(0xFF4CAF50).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            hasDebts ? Icons.warning : Icons.check_circle,
            color: hasDebts ? const Color(0xFFF44336) : const Color(0xFF4CAF50),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasDebts ? 'Qarzlar mavjud' : 'Qarzlar yo\'q',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: hasDebts
                        ? const Color(0xFFF44336)
                        : const Color(0xFF4CAF50),
                  ),
                ),
                if (hasDebts) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${details.totalDebts} ta o\'quvchi - ${_formatCurrency(details.totalDebtAmount ?? 0)} so\'m',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaffStats(branch) {
    return Obx(() {
      final details = controller.selectedBranch.value ?? branch;
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF9800).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.people, color: Color(0xFFFF9800)),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Xodimlar',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildSmallStat(
                    'Jami xodimlar',
                    '${details.totalStaff ?? 0}',
                    Icons.people,
                    const Color(0xFF2196F3),
                  ),
                ),
                Expanded(
                  child: _buildSmallStat(
                    'O\'qituvchilar',
                    '${details.totalTeachers ?? 0}',
                    Icons.school,
                    const Color(0xFF4CAF50),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSmallStat(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBranchInfo(branch) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filial ma\'lumotlari',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          if (branch.phone != null)
            _buildInfoRow(Icons.phone, 'Telefon', branch.phone!),
          if (branch.phoneSecondary != null)
            _buildInfoRow(
              Icons.phone_android,
              'Telefon 2',
              branch.phoneSecondary!,
            ),
          if (branch.email != null)
            _buildInfoRow(Icons.email, 'Email', branch.email!),
          _buildInfoRow(
            Icons.access_time,
            'Ish vaqti',
            branch.workingHoursFormatted,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF2196F3)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(branch) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tez amallar',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          _buildActionButton(
            'O\'quvchilar',
            Icons.school,
            const Color(0xFF2196F3),
            () => Get.toNamed(
              AppRoutes.students,
              arguments: {'branchId': branch.id},
            ),
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            'Xodimlar',
            Icons.people,
            const Color(0xFF4CAF50),
            () => Get.toNamed(
              AppRoutes.staff,
              arguments: {'branchId': branch.id},
            ),
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            'Moliya',
            Icons.attach_money,
            const Color(0xFFFF9800),
            () => Get.toNamed(
              AppRoutes.finance,
              arguments: {'branchId': branch.id},
            ),
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            'Sinflar',
            Icons.class_,
            const Color(0xFF9C27B0),
            () => Get.toNamed(
              AppRoutes.roomsAndClasses,
              arguments: {'branchId': branch.id},
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: color),
          ],
        ),
      ),
    );
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
