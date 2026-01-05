import 'package:flutter/material.dart';
import 'package:flutter_application_1/config/app_routes.dart';
import 'package:flutter_application_1/config/constants.dart';
import 'package:flutter_application_1/data/models/staff.dart';
import 'package:flutter_application_1/presentation/controllers/auth_controller.dart';
import 'package:flutter_application_1/data/repositories/staff_repository.dart';
import 'package:get/get.dart';

class DirectorSidebar extends StatefulWidget {
  DirectorSidebar({Key? key}) : super(key: key);

  @override
  State<DirectorSidebar> createState() => _DirectorSidebarState();
}

class _DirectorSidebarState extends State<DirectorSidebar> {
  final AuthController authController = Get.find<AuthController>();
  final StaffRepository _staffRepository = StaffRepository();

  StaffEnhanced? _staffInfo;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStaffInfo();

    // --- MUHIM QISM: BIRINCHI KIRIShDA MOLIYAGA O'TKAZISH ---
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Agar hozirgi sahifa bosh sahifa (Dashboard) bo'lsa
      if (Get.currentRoute == AppRoutes.dashboard || Get.currentRoute == '/') {
        // Moliya sahifasiga yo'naltirish (Sahifa almashtirish emas, shunchaki ustiga ochish)
        // offNamed ishlatmang, chunki bu Sidebar ichida turibdi
        Get.toNamed(AppRoutes.finance);
      }
    });
    // --------------------------------------------------------
  }

  Future<void> _loadStaffInfo() async {
    try {
      final user = authController.currentUser.value;
      if (user != null && user.id != null) {
        final staffList = await _staffRepository.getStaffByUserId(user.id);
        if (staffList.isNotEmpty) {
          if (mounted) {
            setState(() {
              _staffInfo = staffList.first;
              _isLoading = false;
            });
          }
        } else {
          if (mounted) setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      print('Staff ma\'lumotlarini olishda xato: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

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
                _buildMenuSection('BOSHQARUV'),

                _buildMenuItem(
                  icon: Icons.account_balance_wallet_outlined,
                  activeIcon: Icons.account_balance_wallet,
                  title: 'Moliya',
                  route: AppRoutes.finance,
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

          String displayName = 'Direktor';
          String? branchInfo;
          String? photoUrl;

          if (_staffInfo != null) {
            displayName = _staffInfo!.fullName;
            branchInfo = _staffInfo!.branchName;
            photoUrl = _staffInfo!.photoUrl;
          }

          String avatarLetter = 'D';
          if (_staffInfo != null && _staffInfo!.firstName.isNotEmpty) {
            avatarLetter = _staffInfo!.firstName[0].toUpperCase();
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.deepOrange,
                backgroundImage: (photoUrl != null && photoUrl.isNotEmpty)
                    ? NetworkImage(photoUrl)
                    : null,
                child: _isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : (photoUrl != null && photoUrl.isNotEmpty)
                        ? null
                        : Text(
                            avatarLetter,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
              ),
              SizedBox(height: AppConstants.paddingMedium),
              Text(
                displayName,
                style: TextStyle(
                  fontSize: AppConstants.fontSizeLarge,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.textPrimaryColor,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4),
              Text(
                _staffInfo?.position ?? 'Direktor',
                style: TextStyle(
                  fontSize: AppConstants.fontSizeMedium,
                  color: AppConstants.textSecondaryColor,
                ),
              ),
              if (branchInfo != null && branchInfo.isNotEmpty) ...[
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.deepOrange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.business, size: 14, color: Colors.deepOrange),
                      SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          branchInfo,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.deepOrange,
                            fontWeight: FontWeight.w500,
                          ),
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
        color: isActive
            ? Colors.deepOrange.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
      ),
      child: ListTile(
        leading: Icon(
          isActive ? activeIcon : icon,
          color: isActive ? Colors.deepOrange : AppConstants.textSecondaryColor,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: AppConstants.fontSizeMedium,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            color: isActive ? Colors.deepOrange : AppConstants.textPrimaryColor,
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