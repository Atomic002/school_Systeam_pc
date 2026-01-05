// lib/presentation/screens/rooms_classes/rooms_classes_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_application_1/config/app_routes.dart';
import 'package:flutter_application_1/presentation/controllers/room_class_controller.dart';
import 'package:flutter_application_1/presentation/widgets/sidebar.dart';
import 'package:get/get.dart';

class RoomsAndClassesScreen extends StatelessWidget {
  RoomsAndClassesScreen({Key? key}) : super(key: key);

  final RoomsClassesController controller = Get.put(RoomsClassesController());

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
                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          _buildQuickStats(),
                          const SizedBox(height: 24),
                          _buildMainContent(),
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
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.meeting_room,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sinf va Xonalar',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Xonalar va sinflar boshqaruvi',
                      style: TextStyle(fontSize: 14, color: Colors.white70),
                    ),
                  ],
                ),
              ),
              
              // --- YANGI QO'SHILGAN QISM (REFRESH TUGMASI) ---
              _buildRefreshButton(),
              const SizedBox(width: 12),
              // ------------------------------------------------
              
              Obx(() => _buildViewToggle()),
            ],
          ),
        ),
      ),
    );
  }

    Widget _buildRefreshButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2), // Dizaynga moslashish uchun shaffof fon
        borderRadius: BorderRadius.circular(10),
      ),
      child: IconButton(
        icon: const Icon(Icons.refresh, color: Colors.white),
        tooltip: "Ma'lumotlarni yangilash",
        onPressed: () {
          // Controllerdagi ma'lumotlarni qayta yuklash funksiyasini chaqiramiz
          controller.loadInitialData(); 
        },
      ),
    );
  }
  Widget _buildViewToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          _buildToggleButton(
            icon: Icons.meeting_room,
            label: 'Xonalar',
            isActive: controller.currentView.value == 'rooms',
            onTap: () => controller.currentView.value = 'rooms',
          ),
          const SizedBox(width: 8),
          _buildToggleButton(
            icon: Icons.school,
            label: 'Sinflar',
            isActive: controller.currentView.value == 'classes',
            onTap: () => controller.currentView.value = 'classes',
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isActive ? const Color(0xFF2196F3) : Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isActive ? const Color(0xFF2196F3) : Colors.white,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return Obx(
      () => Row(
        children: [
          _buildStatCard(
            title: 'Jami xonalar',
            value: controller.totalRooms.value.toString(),
            icon: Icons.meeting_room,
            color: const Color(0xFF2196F3),
            subtitle: '${controller.availableRooms.value} ta bo\'sh',
          ),
          const SizedBox(width: 16),
          _buildStatCard(
            title: 'Jami sinflar',
            value: controller.totalClasses.value.toString(),
            icon: Icons.school,
            color: const Color(0xFF4CAF50),
            subtitle: '${controller.activeClasses.value} ta aktiv',
          ),
          const SizedBox(width: 16),
          _buildStatCard(
            title: 'Jami o\'quvchilar',
            value: controller.totalStudents.value.toString(),
            icon: Icons.people,
            color: const Color(0xFFFFA726),
            subtitle: 'Barcha sinflarda',
          ),
          const SizedBox(width: 16),
          _buildStatCard(
            title: 'O\'qituvchilar',
            value: controller.totalTeachers.value.toString(),
            icon: Icons.person,
            color: const Color(0xFF9C27B0),
            subtitle: 'Aktiv o\'qituvchilar',
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
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
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Obx(() {
      if (controller.currentView.value == 'rooms') {
        return _buildRoomsView();
      } else {
        return _buildClassesView();
      }
    });
  }

  Widget _buildRoomsView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: _buildSearchBar('Xona qidirish...')),
            const SizedBox(width: 16),
            _buildFilterButton(),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: () => Get.toNamed(AppRoutes.addRoom),
              icon: const Icon(Icons.add),
              label: const Text('Yangi xona'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Obx(() {
          final rooms = controller.filteredRooms;
          if (rooms.isEmpty) {
            return _buildEmptyState('Xonalar topilmadi');
          }
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
            ),
            itemCount: rooms.length,
            itemBuilder: (context, index) => _buildRoomCard(rooms[index]),
          );
        }),
      ],
    );
  }

  Widget _buildClassesView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: _buildSearchBar('Sinf qidirish...')),
            const SizedBox(width: 16),
            _buildFilterButton(),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: () => Get.toNamed(AppRoutes.addClass),
              icon: const Icon(Icons.add),
              label: const Text('Yangi sinf'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Obx(() {
          final classes = controller.filteredClasses;
          if (classes.isEmpty) {
            return _buildEmptyState('Sinflar topilmadi');
          }
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.3,
            ),
            itemCount: classes.length,
            itemBuilder: (context, index) => _buildClassCard(classes[index]),
          );
        }),
      ],
    );
  }

  Widget _buildSearchBar(String hint) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: TextField(
        onChanged: controller.onSearchChanged,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          icon: const Icon(Icons.search, color: Color(0xFF2196F3)),
        ),
      ),
    );
  }

  Widget _buildFilterButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: IconButton(
        onPressed: controller.showFilterDialog,
        icon: const Icon(Icons.filter_list, color: Color(0xFF2196F3)),
        padding: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildRoomCard(Map<String, dynamic> room) {
    final isOccupied = room['assigned_class'] != null;

    return InkWell(
      onTap: () =>
          Get.toNamed(AppRoutes.roomDetail, arguments: {'id': room['id']}),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isOccupied
                ? const Color(0xFF4CAF50).withOpacity(0.3)
                : Colors.grey.shade200,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
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
                    color: const Color(0xFF2196F3).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.meeting_room,
                    color: Color(0xFF2196F3),
                    size: 24,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isOccupied
                        ? const Color(0xFF4CAF50)
                        : Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isOccupied ? 'Band' : 'Bo\'sh',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              room['name'],
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.people, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Sig\'im: ${room['capacity']}',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
                const Spacer(),
                Icon(Icons.layers, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${room['floor']}-qavat',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ),
            if (isOccupied) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                room['assigned_class'],
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4CAF50),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildClassCard(Map<String, dynamic> cls) {
    return InkWell(
      onTap: () =>
          Get.toNamed(AppRoutes.classDetail, arguments: {'id': cls['id']}),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF4CAF50),
              const Color(0xFF4CAF50).withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4CAF50).withOpacity(0.3),
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
                const Icon(Icons.school, color: Colors.white, size: 28),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${cls['student_count']}/${cls['max_students']}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              cls['name'],
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            if (cls['teacher_name'] != null)
              Text(
                cls['teacher_name'],
                style: const TextStyle(fontSize: 13, color: Colors.white70),
              ),
            const SizedBox(height: 4),
            if (cls['room_name'] != null)
              Row(
                children: [
                  const Icon(
                    Icons.meeting_room,
                    size: 14,
                    color: Colors.white70,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    cls['room_name'],
                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
