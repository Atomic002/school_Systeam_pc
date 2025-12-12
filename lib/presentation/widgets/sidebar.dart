// lib/presentation/widgets/sidebar.dart
// YANGILANGAN - Fanlar, Sinf darajalari, O'qituvchi fanlari qo'shildi

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/constants.dart';
import '../../config/app_routes.dart';
import '../controllers/auth_controller.dart';

class Sidebar extends StatelessWidget {
  Sidebar({Key? key}) : super(key: key);

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
            offset: Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(),
          Divider(height: 1),
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

                // Boshqaruv bo'limi
                _buildMenuSection('Boshqaruv'),
                _buildMenuItem(
                  icon: Icons.business_outlined,
                  activeIcon: Icons.business,
                  title: 'Filiallar',
                  route: AppRoutes.branches,
                ),

                // YANGI: O'quv jarayoni
                _buildMenuSection('O\'quv jarayoni'),
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

                // Moliya bo'limi
                _buildMenuSection('Moliya'),
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

                // O'quvchilar bo'limi
                _buildMenuSection('O\'quvchilar'),
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

                // Xodimlar bo'limi
                _buildMenuSection('Xodimlar'),
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

                // Davomat bo'limi
                _buildMenuSection('Davomat'),
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

                // Dars jadvali va sinflar
                _buildMenuSection('Dars jadvali'),
                _buildMenuItem(
                  icon: Icons.calendar_today_outlined,
                  activeIcon: Icons.calendar_today,
                  title: 'Dars jadvali',
                  route: AppRoutes.schedule,
                ),

                _buildMenuSection('Sinf va Xonalar'),
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
              ],
            ),
          ),
          Divider(height: 1),
          _buildLogoutButton(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(AppConstants.paddingLarge),
      child: Obx(() {
        final user = authController.currentUser.value;
        if (user == null) return SizedBox.shrink();

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
            SizedBox(height: 4),
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
        title.toUpperCase(),
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
              title: Text('Chiqish'),
              content: Text('Tizimdan chiqmoqchimisiz?'),
              actions: [
                TextButton(onPressed: () => Get.back(), child: Text('Yo\'q')),
                ElevatedButton(
                  onPressed: () {
                    Get.back();
                    authController.logout();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.errorColor,
                  ),
                  child: Text('Ha, chiqish'),
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
