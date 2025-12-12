// lib/presentation/screens/branches/branches_list_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/branch_controller.dart';
import '../../widgets/sidebar.dart';
import '../../../config/app_routes.dart';

class BranchesListScreen extends StatelessWidget {
  BranchesListScreen({Key? key}) : super(key: key);

  final BranchController controller = Get.put(BranchController());

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
                _buildStatistics(),
                Expanded(child: _buildBranchesList()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
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
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filiallar',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Barcha filiallar va ularning statistikasi',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
              const Spacer(),
              // Qidiruv
              Container(
                width: 300,
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  onChanged: (value) => controller.searchBranches(value),
                  decoration: InputDecoration(
                    hintText: 'Filial qidirish...',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Yangi filial qo'shish
              ElevatedButton.icon(
                onPressed: () {
                  Get.toNamed(AppRoutes.addBranch);
                },
                icon: const Icon(Icons.add),
                label: const Text('Yangi filial'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatistics() {
    return Obx(() {
      return Container(
        margin: const EdgeInsets.all(24),
        child: Row(
          children: [
            _buildStatCard(
              'Jami filiallar',
              controller.totalBranches.value.toString(),
              Icons.business,
              const Color(0xFF2196F3),
            ),
            const SizedBox(width: 16),
            _buildStatCard(
              'Faol filiallar',
              controller.activeBranches.value.toString(),
              Icons.check_circle,
              const Color(0xFF4CAF50),
            ),
            const SizedBox(width: 16),
            _buildStatCard(
              'Jami o\'quvchilar',
              controller.totalStudentsAllBranches.value.toString(),
              Icons.people,
              const Color(0xFFFF9800),
            ),
            const SizedBox(width: 16),
            _buildStatCard(
              'Yillik daromad',
              '${_formatCurrency(controller.totalRevenueAllBranches.value)} so\'m',
              Icons.trending_up,
              const Color(0xFF9C27B0),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
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
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBranchesList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.filteredBranches.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.business_outlined, size: 80, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Text(
                controller.searchQuery.value.isEmpty
                    ? 'Hali filiallar yo\'q'
                    : 'Filial topilmadi',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () => controller.loadBranches(),
        child: ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: controller.filteredBranches.length,
          itemBuilder: (context, index) {
            final branch = controller.filteredBranches[index];
            return _buildBranchCard(branch);
          },
        ),
      );
    });
  }

  Widget _buildBranchCard(branch) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Get.toNamed(AppRoutes.branchDetail, arguments: branch);
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Icon va asosiy ma'lumot
                Container(
                  padding: const EdgeInsets.all(16),
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
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            branch.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (branch.isMain)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF9800),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'Asosiy',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: branch.isActive
                                  ? const Color(0xFF4CAF50).withOpacity(0.1)
                                  : Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              branch.statusText,
                              style: TextStyle(
                                color: branch.isActive
                                    ? const Color(0xFF4CAF50)
                                    : Colors.grey,
                                fontSize: 11,
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
                            Expanded(
                              child: Text(
                                branch.address!,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (branch.phone != null) ...[
                            const Icon(
                              Icons.phone,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              branch.phone!,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(width: 16),
                          ],
                          const Icon(
                            Icons.access_time,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            branch.workingHoursFormatted,
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
                // Statistika
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _buildStatItem(
                        'O\'quvchilar',
                        '${branch.activeStudents ?? 0}/${branch.totalStudents ?? 0}',
                        Icons.school,
                      ),
                      const SizedBox(height: 12),
                      _buildStatItem(
                        'O\'qituvchilar',
                        '${branch.totalTeachers ?? 0}',
                        Icons.person,
                      ),
                      const SizedBox(height: 12),
                      _buildStatItem(
                        'Sinflar',
                        '${branch.totalClasses ?? 0}',
                        Icons.class_,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Amallar
                PopupMenuButton(
                  icon: const Icon(Icons.more_vert),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: Row(
                        children: [
                          const Icon(Icons.visibility, size: 20),
                          const SizedBox(width: 12),
                          const Text('Batafsil'),
                        ],
                      ),
                      onTap: () {
                        Future.delayed(Duration.zero, () {
                          Get.toNamed(
                            AppRoutes.branchDetail,
                            arguments: branch,
                          );
                        });
                      },
                    ),
                    PopupMenuItem(
                      child: Row(
                        children: [
                          const Icon(Icons.edit, size: 20),
                          const SizedBox(width: 12),
                          const Text('Tahrirlash'),
                        ],
                      ),
                      onTap: () {
                        Future.delayed(Duration.zero, () {
                          Get.toNamed(AppRoutes.addBranch, arguments: branch);
                        });
                      },
                    ),
                    PopupMenuItem(
                      child: Row(
                        children: [
                          Icon(
                            branch.isActive
                                ? Icons.pause_circle
                                : Icons.play_circle,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            branch.isActive ? 'To\'xtatish' : 'Faollashtirish',
                          ),
                        ],
                      ),
                      onTap: () {
                        controller.toggleBranchStatus(branch.id);
                      },
                    ),
                    PopupMenuItem(
                      child: Row(
                        children: [
                          const Icon(Icons.delete, size: 20, color: Colors.red),
                          const SizedBox(width: 12),
                          const Text(
                            'O\'chirish',
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                      onTap: () {
                        Future.delayed(Duration.zero, () {
                          _showDeleteDialog(branch);
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: const Color(0xFF2196F3)),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showDeleteDialog(branch) {
    Get.dialog(
      AlertDialog(
        title: const Text('Filialni o\'chirish'),
        content: Text(
          '${branch.name} filialini o\'chirmoqchimisiz? Bu amalni qaytarib bo\'lmaydi.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Bekor qilish'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.deleteBranch(branch.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('O\'chirish'),
          ),
        ],
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
