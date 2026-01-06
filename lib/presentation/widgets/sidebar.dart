// lib/presentation/widgets/role_based_sidebar.dart
// YAKUNIY - Staff va Teacher olib tashlandi

import 'package:flutter/material.dart';
import 'package:flutter_application_1/presentation/widgets/sidebars/director_sidebar.dart';
// StaffSidebar importi olib tashlandi
import 'package:get/get.dart';
import '../../config/constants.dart';
import '../../config/app_routes.dart';
import '../controllers/auth_controller.dart';

class Sidebar extends StatelessWidget {
  Sidebar({Key? key}) : super(key: key);

  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final userRole = authController.userRole;

      // Kichik harflarga o'tkazib tekshiramiz
      switch (userRole?.toLowerCase().trim()) {
        case 'owner':
          return _OwnerSidebar();
        case 'admin':
          return _AdminSidebar(); // Qabulxona
        case 'manager':
          return _ManagerSidebar(); // Kassir
        case 'director':
          return DirectorSidebar();
        // Staff va Teacher olib tashlandi.
        // Ular kirsa _DefaultSidebar ga tushadi.
        default:
          return _DefaultSidebar();
      }
    });
  }
}

// ========== DEFAULT SIDEBAR (Rol topilmasa) ==========
class _DefaultSidebar extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(AppConstants.paddingLarge),
            child: const Column(
              children: [
                Icon(Icons.person_outline, size: 50, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Rol aniqlanmadi',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          const Expanded(child: Center(child: Text('Sidebar mavjud emas'))),
          const Divider(height: 1),
          _buildLogoutButton(),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      padding: EdgeInsets.all(AppConstants.paddingMedium),
      child: ListTile(
        leading: Icon(Icons.logout, color: AppConstants.errorColor),
        title: Text(
          'Chiqish',
          style: TextStyle(
            fontSize: AppConstants.fontSizeMedium,
            color: AppConstants.errorColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        onTap: () {
          authController.logout();
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        ),
      ),
    );
  }
}

// ========== MANAGER SIDEBAR (KASSIR) ==========
class _ManagerSidebar extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(
                vertical: AppConstants.paddingSmall,
              ),
              children: [
                // Kassir uchun asosiy bo'lim - Moliya
                _buildMenuSection('MOLIYA VA KASSA'),

                _buildMenuItem(
                  icon: Icons.account_balance_wallet_outlined,
                  activeIcon: Icons.account_balance_wallet,
                  title: 'Moliya paneli',
                  route: AppRoutes.finance,
                ),
                _buildMenuItem(
                  icon: Icons.point_of_sale_outlined,
                  activeIcon: Icons.point_of_sale,
                  title: 'Kassa operatsiyalari',
                  route: AppRoutes.cashRegister,
                ),
                _buildMenuItem(
                  icon: Icons.payment_outlined,
                  activeIcon: Icons.payment,
                  title: 'To\'lovlar tarixi',
                  route: AppRoutes.payments,
                ),
                _buildMenuItem(
                  icon: Icons.receipt_long_outlined,
                  activeIcon: Icons.receipt_long,
                  title: 'Xarajatlar',
                  route: AppRoutes.expenses,
                ),

                _buildMenuSection('QARZDORLIKLAR'),
                _buildMenuItem(
                  icon: Icons.money_off_csred_outlined,
                  activeIcon: Icons.money_off,
                  title: 'O\'quvchilar qarzlari',
                  route: AppRoutes.studentDebts,
                ),

                _buildMenuSection('ISH HAQI'),
                _buildMenuItem(
                  icon: Icons.attach_money_outlined,
                  activeIcon: Icons.attach_money,
                  title: 'Xodimlar maoshi',
                  route: AppRoutes.salary,
                ),
                _buildMenuSection('HODIMLAR'),

                _buildMenuItem(
                  icon: Icons.person_add_outlined,
                  activeIcon: Icons.person_add,
                  title: 'Yangi xodim',
                  route: AppRoutes.addStaff,
                ),
                _buildMenuItem(
                  icon: Icons.badge_outlined,
                  activeIcon: Icons.badge,
                  title: 'Xodimlar ro\'yxati',
                  route: AppRoutes.staff,
                ),
                _buildMenuSection('O\'QUVCHILAR'),
                _buildMenuItem(
                  icon: Icons.school_outlined,
                  activeIcon: Icons.school,
                  title: 'O\'quvchilar',
                  route: AppRoutes.students,
                ),
                _buildMenuItem(
                  icon: Icons.person_add_outlined,
                  activeIcon: Icons.person_add,
                  title: 'Yangi o\'quvchi',
                  route: AppRoutes.addStudent,
                ),
                _buildMenuItem(
                  icon: Icons.people_outline,
                  activeIcon: Icons.people,
                  title: 'Tashrif buyuruvchilar',
                  route: AppRoutes.visitors,
                ),
                _buildMenuSection('DAVOMAT'),
                _buildMenuItem(
                  icon: Icons.how_to_reg_outlined,
                  activeIcon: Icons.how_to_reg,
                  title: 'O\'quvchilar davomadi',
                  route: AppRoutes.studentAttendance,
                ),
                _buildMenuItem(
                  icon: Icons.verified_user_outlined,
                  activeIcon: Icons.verified_user,
                  title: 'Xodimlar davomadi',
                  route: AppRoutes.staffAttendance,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          _buildLogoutButton(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return InkWell(
      onTap: () => Get.toNamed(AppRoutes.profile),
      child: Container(
        padding: EdgeInsets.all(AppConstants.paddingLarge),
        child: Obx(() {
          final user = authController.currentUser.value;
          if (user == null) return const SizedBox.shrink();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(
                radius: 30,
                backgroundColor: Colors.orange,
                child: Icon(Icons.point_of_sale, size: 30, color: Colors.white),
              ),
              SizedBox(height: AppConstants.paddingMedium),
              Text(
                user.shortName,
                style: TextStyle(
                  fontSize: AppConstants.fontSizeLarge,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.textPrimaryColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                'Kassir',
                style: TextStyle(
                  fontSize: AppConstants.fontSizeMedium,
                  color: AppConstants.textSecondaryColor,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildMenuSection(String title) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppConstants.paddingLarge,
        AppConstants.paddingLarge,
        AppConstants.paddingLarge,
        AppConstants.paddingSmall,
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: AppConstants.fontSizeSmall,
          fontWeight: FontWeight.bold,
          color: AppConstants.textLightColor,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required IconData activeIcon,
    required String title,
    required String route,
  }) {
    final isActive = Get.currentRoute == route;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMedium,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: isActive ? Colors.orange.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
      ),
      child: ListTile(
        leading: Icon(
          isActive ? activeIcon : icon,
          color: isActive ? Colors.orange : AppConstants.textSecondaryColor,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: AppConstants.fontSizeMedium,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            color: isActive ? Colors.orange : AppConstants.textPrimaryColor,
          ),
        ),
        onTap: () {
          if (!isActive) {
            Get.toNamed(route);
          }
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppConstants.paddingMedium,
          vertical: 4,
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      padding: EdgeInsets.all(AppConstants.paddingMedium),
      child: ListTile(
        leading: Icon(Icons.logout, color: AppConstants.errorColor),
        title: Text(
          'Chiqish',
          style: TextStyle(
            fontSize: AppConstants.fontSizeMedium,
            color: AppConstants.errorColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        onTap: () {
          Get.dialog(
            AlertDialog(
              title: const Text('Chiqish'),
              content: const Text('Tizimdan chiqmoqchimisiz?'),
              actions: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('Yo\'q'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Get.back();
                    authController.logout();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.errorColor,
                  ),
                  child: const Text('Ha, chiqish'),
                ),
              ],
            ),
          );
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        ),
      ),
    );
  }
}

// ========== OWNER SIDEBAR (EGA) ==========
class _OwnerSidebar extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(
                vertical: AppConstants.paddingSmall,
              ),
              children: [
                _buildMenuItem(
                  icon: Icons.dashboard_outlined,
                  activeIcon: Icons.dashboard,
                  title: 'Dashboard',
                  route: AppRoutes.dashboard,
                ),

                _buildMenuSection('BOSHQARUV'),
                _buildMenuItem(
                  icon: Icons.business_outlined,
                  activeIcon: Icons.business,
                  title: 'Filiallar',
                  route: AppRoutes.branches,
                ),

                _buildMenuSection('MOLIYA'),
                _buildMenuItem(
                  icon: Icons.account_balance_wallet_outlined,
                  activeIcon: Icons.account_balance_wallet,
                  title: 'Moliya',
                  route: AppRoutes.finance,
                ),
                _buildMenuItem(
                  icon: Icons.point_of_sale_outlined,
                  activeIcon: Icons.point_of_sale,
                  title: 'Kassa',
                  route: AppRoutes.cashRegister,
                ),
                _buildMenuItem(
                  icon: Icons.payment_outlined,
                  activeIcon: Icons.payment,
                  title: 'To\'lovlar',
                  route: AppRoutes.payments,
                ),
                _buildMenuItem(
                  icon: Icons.receipt_long_outlined,
                  activeIcon: Icons.receipt_long,
                  title: 'Xarajatlar',
                  route: AppRoutes.expenses,
                ),
                _buildMenuItem(
                  icon: Icons.attach_money_outlined,
                  activeIcon: Icons.attach_money,
                  title: 'Maoshlar',
                  route: AppRoutes.salary,
                ),

                _buildMenuSection('O\'QUVCHILAR'),
                _buildMenuItem(
                  icon: Icons.school_outlined,
                  activeIcon: Icons.school,
                  title: 'O\'quvchilar',
                  route: AppRoutes.students,
                ),
                _buildMenuItem(
                  icon: Icons.person_add_outlined,
                  activeIcon: Icons.person_add,
                  title: 'Yangi o\'quvchi',
                  route: AppRoutes.addStudent,
                ),
                _buildMenuItem(
                  icon: Icons.people_outline,
                  activeIcon: Icons.people,
                  title: 'Tashrif buyuruvchilar',
                  route: AppRoutes.visitors,
                ),

                _buildMenuSection('XODIMLAR'),
                _buildMenuItem(
                  icon: Icons.badge_outlined,
                  activeIcon: Icons.badge,
                  title: 'Xodimlar',
                  route: AppRoutes.staff,
                ),
                _buildMenuItem(
                  icon: Icons.person_add_outlined,
                  activeIcon: Icons.person_add,
                  title: 'Yangi xodim',
                  route: AppRoutes.addStaff,
                ),

                _buildMenuSection('DAVOMAT'),
                _buildMenuItem(
                  icon: Icons.how_to_reg_outlined,
                  activeIcon: Icons.how_to_reg,
                  title: 'O\'quvchilar davomadi',
                  route: AppRoutes.studentAttendance,
                ),
                _buildMenuItem(
                  icon: Icons.verified_user_outlined,
                  activeIcon: Icons.verified_user,
                  title: 'Xodimlar davomadi',
                  route: AppRoutes.staffAttendance,
                ),

                _buildMenuSection('DARS JADVALI'),
                _buildMenuItem(
                  icon: Icons.calendar_today_outlined,
                  activeIcon: Icons.calendar_today,
                  title: 'Dars jadvali',
                  route: AppRoutes.schedule,
                ),

                _buildMenuSection('SINF VA XONALAR'),
                _buildMenuItem(
                  icon: Icons.meeting_room_outlined,
                  activeIcon: Icons.meeting_room,
                  title: 'Sinf va Xonalar',
                  route: AppRoutes.roomsAndClasses,
                ),
                _buildMenuItem(
                  icon: Icons.add_box_outlined,
                  activeIcon: Icons.add_box,
                  title: 'Yangi xona',
                  route: AppRoutes.addRoom,
                ),
                _buildMenuItem(
                  icon: Icons.add_box_outlined,
                  activeIcon: Icons.add_box,
                  title: 'Yangi sinf',
                  route: AppRoutes.addClass,
                ),

                _buildMenuSection('O\'QUV JARAYONI'),
                _buildMenuItem(
                  icon: Icons.book_outlined,
                  activeIcon: Icons.book,
                  title: 'Fanlar',
                  route: AppRoutes.subjects,
                ),
                _buildMenuItem(
                  icon: Icons.stairs_outlined,
                  activeIcon: Icons.stairs,
                  title: 'Sinf darajalari',
                  route: AppRoutes.classLevels,
                ),
                _buildMenuItem(
                  icon: Icons.school_outlined,
                  activeIcon: Icons.school,
                  title: 'O\'qituvchi fanlari',
                  route: AppRoutes.teacherSubjects,
                ),

                _buildMenuSection('SOZLAMALAR'),
                _buildMenuItem(
                  icon: Icons.school_outlined,
                  activeIcon: Icons.school,
                  title: 'O\'quv yillari',
                  route: AppRoutes.academicYears,
                ),
                _buildMenuItem(
                  icon: Icons.settings_outlined,
                  activeIcon: Icons.settings,
                  title: 'Tizim sozlamalari',
                  route: AppRoutes.systemSettings,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          _buildLogoutButton(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return InkWell(
      onTap: () => Get.toNamed(AppRoutes.profile),
      child: Container(
        padding: EdgeInsets.all(AppConstants.paddingLarge),
        child: Obx(() {
          final user = authController.currentUser.value;
          if (user == null) return const SizedBox.shrink();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: AppConstants.primaryColor,
                child: Text(
                  user.firstName[0].toUpperCase(),
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeXXLarge,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: AppConstants.paddingMedium),
              Text(
                user.shortName,
                style: TextStyle(
                  fontSize: AppConstants.fontSizeLarge,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.textPrimaryColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                user.roleInUzbek,
                style: TextStyle(
                  fontSize: AppConstants.fontSizeMedium,
                  color: AppConstants.textSecondaryColor,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildMenuSection(String title) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppConstants.paddingLarge,
        AppConstants.paddingLarge,
        AppConstants.paddingLarge,
        AppConstants.paddingSmall,
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: AppConstants.fontSizeSmall,
          fontWeight: FontWeight.bold,
          color: AppConstants.textLightColor,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required IconData activeIcon,
    required String title,
    required String route,
  }) {
    final isActive = Get.currentRoute == route;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMedium,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: isActive
            ? AppConstants.primaryColor.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
      ),
      child: ListTile(
        leading: Icon(
          isActive ? activeIcon : icon,
          color: isActive
              ? AppConstants.primaryColor
              : AppConstants.textSecondaryColor,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: AppConstants.fontSizeMedium,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            color: isActive
                ? AppConstants.primaryColor
                : AppConstants.textPrimaryColor,
          ),
        ),
        onTap: () {
          if (!isActive) {
            Get.toNamed(route);
          }
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppConstants.paddingMedium,
          vertical: 4,
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      padding: EdgeInsets.all(AppConstants.paddingMedium),
      child: ListTile(
        leading: Icon(Icons.logout, color: AppConstants.errorColor),
        title: Text(
          'Chiqish',
          style: TextStyle(
            fontSize: AppConstants.fontSizeMedium,
            color: AppConstants.errorColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        onTap: () {
          Get.dialog(
            AlertDialog(
              title: const Text('Chiqish'),
              content: const Text('Tizimdan chiqmoqchimisiz?'),
              actions: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('Yo\'q'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Get.back();
                    authController.logout();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.errorColor,
                  ),
                  child: const Text('Ha, chiqish'),
                ),
              ],
            ),
          );
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        ),
      ),
    );
  }
}

// ========== ADMIN SIDEBAR (RESEPTION) ==========
class _AdminSidebar extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(
                vertical: AppConstants.paddingSmall,
              ),
              children: [
                _buildMenuSection('QABULXONA'),

                _buildMenuItem(
                  icon: Icons.people_outline,
                  activeIcon: Icons.people,
                  title: 'Tashrif buyuruvchilar',
                  route: AppRoutes.visitors,
                ),

                _buildMenuItem(
                  icon: Icons.school_outlined,
                  activeIcon: Icons.school,
                  title: 'O\'quvchilar',
                  route: AppRoutes.students,
                ),

                _buildMenuItem(
                  icon: Icons.person_add_outlined,
                  activeIcon: Icons.person_add,
                  title: 'Yangi o\'quvchi',
                  route: AppRoutes.addStudent,
                ),

                _buildMenuSection('DARS JADVALI'),
                _buildMenuItem(
                  icon: Icons.calendar_today_outlined,
                  activeIcon: Icons.calendar_today,
                  title: 'Dars jadvali',
                  route: AppRoutes.schedule,
                ),

                _buildMenuSection('DAVOMAT'),
                _buildMenuItem(
                  icon: Icons.how_to_reg_outlined,
                  activeIcon: Icons.how_to_reg,
                  title: 'O\'quvchilar davomadi',
                  route: AppRoutes.studentAttendance,
                ),
                _buildMenuItem(
                  icon: Icons.verified_user_outlined,
                  activeIcon: Icons.verified_user,
                  title: 'Xodimlar davomadi',
                  route: AppRoutes.staffAttendance,
                ),

                _buildMenuSection('TO\'LOVLAR'),
                _buildMenuItem(
                  icon: Icons.payment_outlined,
                  activeIcon: Icons.payment,
                  title: 'To\'lovlar',
                  route: AppRoutes.payments,
                ),
                _buildMenuItem(
                  icon: Icons.account_balance_wallet_outlined,
                  activeIcon: Icons.account_balance_wallet,
                  title: 'Qarzlar',
                  route: AppRoutes.studentDebts,
                ),

                _buildMenuSection('MA\'LUMOTLAR'),
                _buildMenuItem(
                  icon: Icons.badge_outlined,
                  activeIcon: Icons.badge,
                  title: 'Xodimlar',
                  route: AppRoutes.staff,
                ),
                _buildMenuItem(
                  icon: Icons.meeting_room_outlined,
                  activeIcon: Icons.meeting_room,
                  title: 'Sinf va Xonalar',
                  route: AppRoutes.roomsAndClasses,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          _buildLogoutButton(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return InkWell(
      onTap: () => Get.toNamed(AppRoutes.profile),
      child: Container(
        padding: EdgeInsets.all(AppConstants.paddingLarge),
        child: Obx(() {
          final user = authController.currentUser.value;
          if (user == null) return const SizedBox.shrink();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(
                radius: 30,
                backgroundColor: Colors.teal,
                child: Icon(
                  Icons.admin_panel_settings,
                  size: 30,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: AppConstants.paddingMedium),
              Text(
                user.shortName,
                style: TextStyle(
                  fontSize: AppConstants.fontSizeLarge,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.textPrimaryColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                'Qabulxona',
                style: TextStyle(
                  fontSize: AppConstants.fontSizeMedium,
                  color: AppConstants.textSecondaryColor,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildMenuSection(String title) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppConstants.paddingLarge,
        AppConstants.paddingLarge,
        AppConstants.paddingLarge,
        AppConstants.paddingSmall,
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: AppConstants.fontSizeSmall,
          fontWeight: FontWeight.bold,
          color: AppConstants.textLightColor,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required IconData activeIcon,
    required String title,
    required String route,
  }) {
    final isActive = Get.currentRoute == route;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMedium,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: isActive ? Colors.teal.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
      ),
      child: ListTile(
        leading: Icon(
          isActive ? activeIcon : icon,
          color: isActive ? Colors.teal : AppConstants.textSecondaryColor,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: AppConstants.fontSizeMedium,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            color: isActive ? Colors.teal : AppConstants.textPrimaryColor,
          ),
        ),
        onTap: () {
          if (!isActive) {
            Get.toNamed(route);
          }
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppConstants.paddingMedium,
          vertical: 4,
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      padding: EdgeInsets.all(AppConstants.paddingMedium),
      child: ListTile(
        leading: Icon(Icons.logout, color: AppConstants.errorColor),
        title: Text(
          'Chiqish',
          style: TextStyle(
            fontSize: AppConstants.fontSizeMedium,
            color: AppConstants.errorColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        onTap: () {
          Get.dialog(
            AlertDialog(
              title: const Text('Chiqish'),
              content: const Text('Tizimdan chiqmoqchimisiz?'),
              actions: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('Yo\'q'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Get.back();
                    authController.logout();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.errorColor,
                  ),
                  child: const Text('Ha, chiqish'),
                ),
              ],
            ),
          );
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        ),
      ),
    );
  }
}
