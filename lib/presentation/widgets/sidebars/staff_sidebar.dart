// lib/presentation/widgets/staff_sidebar.dart
// STAFF/TEACHER SIDEBAR - To'liq versiya

import 'package:flutter/material.dart';
import 'package:flutter_application_1/config/app_routes.dart';
import 'package:flutter_application_1/config/constants.dart';
import 'package:flutter_application_1/presentation/controllers/auth_controller.dart';
import 'package:get/get.dart';


class StaffSidebar extends StatelessWidget {
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
              padding: EdgeInsets.symmetric(vertical: AppConstants.paddingSmall),
              children: [
                _buildMenuSection('MENING SAHIFAM'),
                
                _buildMenuItem(
                  icon: Icons.calendar_today_outlined,
                  activeIcon: Icons.calendar_today,
                  title: 'Mening jadvalim',
                  route: AppRoutes.mySchedule,
                ),
                
                _buildMenuItem(
                  icon: Icons.how_to_reg_outlined,
                  activeIcon: Icons.how_to_reg,
                  title: 'Mening davomatim',
                  route: AppRoutes.myAttendance,
                ),

                _buildMenuSection('O\'QUVCHILAR'),
                _buildMenuItem(
                  icon: Icons.school_outlined,
                  activeIcon: Icons.school,
                  title: 'Mening o\'quvchilarim',
                  route: AppRoutes.myStudents,
                ),
                
                _buildMenuItem(
                  icon: Icons.how_to_reg_outlined,
                  activeIcon: Icons.how_to_reg,
                  title: 'O\'quvchilar davomadi',
                  route: AppRoutes.studentAttendance,
                ),

                _buildMenuSection('MOLIYA'),
                _buildMenuItem(
                  icon: Icons.attach_money_outlined,
                  activeIcon: Icons.attach_money,
                  title: 'Mening maoshim',
                  route: AppRoutes.mySalary,
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
    return InkWell(
      onTap: () => Get.toNamed(AppRoutes.profile),
      child: Container(
        padding: EdgeInsets.all(AppConstants.paddingLarge),
        child: Obx(() {
          final user = authController.currentUser.value;
          if (user == null) return SizedBox.shrink();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.green,
                child: Icon(Icons.person, size: 30, color: Colors.white),
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
              // Filial ma'lumoti
              if (user.branchId != null) ...[
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.business, size: 14, color: Colors.green),
                      SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          'Filial: ${user.branchName ?? "Ma\'lumot yo\'q"}',
                          style: TextStyle(fontSize: 12, color: Colors.green),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
        color: isActive ? Colors.green.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
      ),
      child: ListTile(
        leading: Icon(
          isActive ? activeIcon : icon,
          color: isActive ? Colors.green : AppConstants.textSecondaryColor,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: AppConstants.fontSizeMedium,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            color: isActive ? Colors.green : AppConstants.textPrimaryColor,
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
                TextButton(
                  onPressed: () => Get.back(),
                  child: Text('Yo\'q'),
                ),
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