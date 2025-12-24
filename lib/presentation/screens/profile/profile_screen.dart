// lib/presentation/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_1/config/constants.dart';
import 'package:flutter_application_1/data/models/user_model.dart';
import 'package:flutter_application_1/presentation/controllers/auth_controller.dart';
import 'package:flutter_application_1/presentation/widgets/sidebar.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthController authController = Get.find<AuthController>();
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController middleNameController;
  late TextEditingController phoneController;
  late TextEditingController phoneSecondaryController;
  late TextEditingController regionController;
  late TextEditingController districtController;
  late TextEditingController addressController;
  late TextEditingController usernameController;
  
  // Password controllers
  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  
  bool isEditing = false;
  bool isChangingPassword = false;
  bool showOldPassword = false;
  bool showNewPassword = false;
  bool showConfirmPassword = false;
  File? selectedImage;
  final ImagePicker _picker = ImagePicker();
  String? selectedGender;
  DateTime? selectedBirthDate;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final user = authController.currentUser.value;
    firstNameController = TextEditingController(text: user?.firstName ?? '');
    lastNameController = TextEditingController(text: user?.lastName ?? '');
    middleNameController = TextEditingController(text: user?.middleName ?? '');
    phoneController = TextEditingController(text: user?.phone ?? '');
    phoneSecondaryController = TextEditingController(text: user?.phoneSecondary ?? '');
    regionController = TextEditingController(text: user?.region ?? '');
    districtController = TextEditingController(text: user?.district ?? '');
    addressController = TextEditingController(text: user?.address ?? '');
    usernameController = TextEditingController(text: user?.username ?? '');
    selectedGender = user?.gender;
    selectedBirthDate = user?.birthDate;
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    middleNameController.dispose();
    phoneController.dispose();
    phoneSecondaryController.dispose();
    regionController.dispose();
    districtController.dispose();
    addressController.dispose();
    usernameController.dispose();
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 500,
      maxHeight: 500,
      imageQuality: 85,
    );
    
    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
      });
    }
  }

  Future<void> _selectBirthDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedBirthDate ?? DateTime.now().subtract(Duration(days: 6570)),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: AppConstants.primaryColor),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != selectedBirthDate) {
      setState(() => selectedBirthDate = picked);
    }
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final user = authController.currentUser.value;
      if (user == null) return;

      final updatedUser = user.copyWith(
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        middleName: middleNameController.text.trim().isEmpty ? null : middleNameController.text.trim(),
        phone: phoneController.text.trim().isEmpty ? null : phoneController.text.trim(),
        phoneSecondary: phoneSecondaryController.text.trim().isEmpty ? null : phoneSecondaryController.text.trim(),
        region: regionController.text.trim().isEmpty ? null : regionController.text.trim(),
        district: districtController.text.trim().isEmpty ? null : districtController.text.trim(),
        address: addressController.text.trim().isEmpty ? null : addressController.text.trim(),
        username: usernameController.text.trim(),
        gender: selectedGender,
        birthDate: selectedBirthDate,
        updatedAt: DateTime.now(),
      );

      final success = await authController.updateProfile(updatedUser);
      if (success) {
        setState(() => isEditing = false);
      }
    }
  }

  void _changePassword() async {
    if (oldPasswordController.text.isEmpty || newPasswordController.text.isEmpty || confirmPasswordController.text.isEmpty) {
      Get.snackbar('Xatolik', 'Barcha maydonlarni to\'ldiring',
        backgroundColor: AppConstants.errorColor.withOpacity(0.1),
        colorText: AppConstants.errorColor, snackPosition: SnackPosition.TOP);
      return;
    }

    if (newPasswordController.text != confirmPasswordController.text) {
      Get.snackbar('Xatolik', 'Yangi parollar mos kelmaydi',
        backgroundColor: AppConstants.errorColor.withOpacity(0.1),
        colorText: AppConstants.errorColor, snackPosition: SnackPosition.TOP);
      return;
    }

    if (newPasswordController.text.length < 6) {
      Get.snackbar('Xatolik', 'Yangi parol kamida 6 ta belgidan iborat bo\'lishi kerak',
        backgroundColor: AppConstants.errorColor.withOpacity(0.1),
        colorText: AppConstants.errorColor, snackPosition: SnackPosition.TOP);
      return;
    }

    final success = await authController.updatePassword(
      oldPassword: oldPasswordController.text,
      newPassword: newPasswordController.text,
    );

    if (success) {
      setState(() {
        isChangingPassword = false;
        oldPasswordController.clear();
        newPasswordController.clear();
        confirmPasswordController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      body: Row(
        children: [
          Sidebar(),
          Expanded(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(AppConstants.paddingLarge),
                    child: Obx(() {
                      final user = authController.currentUser.value;
                      if (user == null) {
                        return Center(child: CircularProgressIndicator(color: AppConstants.primaryColor));
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildProfileCard(user),
                          SizedBox(height: AppConstants.paddingLarge),
                          _buildPersonalInfoCard(user),
                          SizedBox(height: AppConstants.paddingLarge),
                          _buildAccountInfoCard(user),
                          SizedBox(height: AppConstants.paddingLarge),
                          _buildPermissionsCard(user),
                          SizedBox(height: AppConstants.paddingLarge),
                          _buildPasswordCard(),
                          SizedBox(height: AppConstants.paddingXLarge),
                        ],
                      );
                    }),
                  ),
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
      padding: EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppConstants.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.person, size: 28, color: AppConstants.primaryColor),
          ),
          SizedBox(width: AppConstants.paddingMedium),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Profil', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppConstants.textPrimaryColor)),
              Text('Shaxsiy ma\'lumotlar va sozlamalar', style: TextStyle(fontSize: 14, color: AppConstants.textSecondaryColor)),
            ],
          ),
          Spacer(),
          if (!isEditing)
            ElevatedButton.icon(
              onPressed: () => setState(() => isEditing = true),
              icon: Icon(Icons.edit, size: 20),
              label: Text('Tahrirlash'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            )
          else
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      isEditing = false;
                      selectedImage = null;
                      _initializeControllers();
                    });
                  },
                  icon: Icon(Icons.close, size: 20),
                  label: Text('Bekor qilish'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppConstants.errorColor,
                    side: BorderSide(color: AppConstants.errorColor),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _saveProfile,
                  icon: Icon(Icons.check, size: 20),
                  label: Text('Saqlash'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.successColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(UserModel user) {
    return Container(
      padding: EdgeInsets.all(AppConstants.paddingXLarge),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppConstants.primaryColor, AppConstants.primaryColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
        boxShadow: [BoxShadow(color: AppConstants.primaryColor.withOpacity(0.3), blurRadius: 20, offset: Offset(0, 8))],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: Offset(0, 4))],
                ),
                child: CircleAvatar(
                  radius: 65,
                  backgroundColor: Colors.white,
                  backgroundImage: selectedImage != null ? FileImage(selectedImage!) : null,
                  child: selectedImage == null
                      ? Text(
                          (user.firstName.isNotEmpty ? user.firstName[0].toUpperCase() : '') + 
                          (user.lastName.isNotEmpty ? user.lastName[0].toUpperCase() : ''),
                          style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: AppConstants.primaryColor),
                        )
                      : null,
                ),
              ),
              if (isEditing)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: InkWell(
                    onTap: _pickImage,
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8)],
                      ),
                      child: Icon(Icons.camera_alt, color: AppConstants.primaryColor, size: 22),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(width: AppConstants.paddingXLarge + 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.fullName, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5)),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.workspace_premium, color: Colors.white, size: 18),
                      SizedBox(width: 8),
                      Text(user.roleInUzbek, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                Wrap(
                  spacing: 20,
                  runSpacing: 10,
                  children: [
                    _buildWhiteInfoChip(icon: Icons.phone, text: user.phone ?? 'Telefon kiritilmagan'),
                    _buildWhiteInfoChip(icon: Icons.account_circle, text: user.username),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    _buildStatusBadgeWhite(user.status),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWhiteInfoChip({required IconData icon, required String text}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: Colors.white70),
        SizedBox(width: 6),
        Text(text, style: TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildStatusBadgeWhite(String status) {
    final isActive = status == 'active';
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: isActive ? Colors.greenAccent : Colors.redAccent, shape: BoxShape.circle)),
          SizedBox(width: 6),
          Text(isActive ? 'Aktiv' : 'Nofaol', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoCard(UserModel user) {
    return Container(
      padding: EdgeInsets.all(AppConstants.paddingXLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(color: AppConstants.primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                  child: Icon(Icons.person_outline, color: AppConstants.primaryColor, size: 24),
                ),
                SizedBox(width: 12),
                Text('Shaxsiy ma\'lumotlar', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppConstants.textPrimaryColor)),
              ],
            ),
            SizedBox(height: AppConstants.paddingLarge),
            Row(
              children: [
                Expanded(child: _buildTextField(controller: firstNameController, label: 'Ism', icon: Icons.person, enabled: isEditing, isRequired: true)),
                SizedBox(width: 16),
                Expanded(child: _buildTextField(controller: lastNameController, label: 'Familiya', icon: Icons.person, enabled: isEditing, isRequired: true)),
              ],
            ),
            SizedBox(height: 16),
            _buildTextField(controller: middleNameController, label: 'Otasining ismi', icon: Icons.person_outline, enabled: isEditing),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildGenderDropdown()),
                SizedBox(width: 16),
                Expanded(child: _buildBirthDateField()),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildTextField(controller: phoneController, label: 'Telefon', icon: Icons.phone, enabled: isEditing, keyboardType: TextInputType.phone)),
                SizedBox(width: 16),
                Expanded(child: _buildTextField(controller: phoneSecondaryController, label: 'Qo\'shimcha telefon', icon: Icons.phone_android, enabled: isEditing, keyboardType: TextInputType.phone)),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildTextField(controller: regionController, label: 'Viloyat', icon: Icons.location_city, enabled: isEditing)),
                SizedBox(width: 16),
                Expanded(child: _buildTextField(controller: districtController, label: 'Tuman', icon: Icons.location_on, enabled: isEditing)),
              ],
            ),
            SizedBox(height: 16),
            _buildTextField(controller: addressController, label: 'To\'liq manzil', icon: Icons.home, enabled: isEditing, maxLines: 3),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: isEditing ? Colors.white : Colors.grey[50],
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButtonFormField<String>(
        value: selectedGender,
        decoration: InputDecoration(
          labelText: 'Jinsi',
          prefixIcon: Icon(Icons.wc),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        items: [
          DropdownMenuItem(value: 'male', child: Text('Erkak')),
          DropdownMenuItem(value: 'female', child: Text('Ayol')),
        ],
        onChanged: isEditing ? (value) => setState(() => selectedGender = value) : null,
      ),
    );
  }

  Widget _buildBirthDateField() {
    return InkWell(
      onTap: isEditing ? _selectBirthDate : null,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isEditing ? Colors.white : Colors.grey[50],
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Icon(Icons.cake, color: AppConstants.textSecondaryColor),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tug\'ilgan sana', style: TextStyle(fontSize: 12, color: AppConstants.textSecondaryColor)),
                  SizedBox(height: 4),
                  Text(selectedBirthDate != null ? _formatDate(selectedBirthDate!) : 'Tanlang',
                    style: TextStyle(fontSize: 16, color: AppConstants.textPrimaryColor)),
                ],
              ),
            ),
            if (isEditing) Icon(Icons.calendar_today, size: 18, color: AppConstants.primaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountInfoCard(UserModel user) {
    return Container(
      padding: EdgeInsets.all(AppConstants.paddingXLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(Icons.admin_panel_settings, color: Colors.blue, size: 24),
              ),
              SizedBox(width: 12),
              Text('Hisob ma\'lumotlari', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppConstants.textPrimaryColor)),
            ],
          ),
          SizedBox(height: AppConstants.paddingLarge),
          _buildTextField(controller: usernameController, label: 'Foydalanuvchi nomi (Login)', icon: Icons.account_circle, enabled: isEditing, isRequired: true),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildInfoCard(icon: Icons.badge, label: 'Hisob turi', value: user.roleInUzbek, color: _getRoleColor(user.role))),
              SizedBox(width: 16),
              Expanded(child: _buildInfoCard(icon: Icons.info, label: 'Holat', value: user.status == 'active' ? 'Aktiv' : 'Nofaol',
                color: user.status == 'active' ? AppConstants.successColor : AppConstants.errorColor)),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildInfoCard(icon: Icons.calendar_today, label: 'Yaratilgan sana', value: _formatDateTime(user.createdAt), color: AppConstants.primaryColor)),
              SizedBox(width: 16),
              Expanded(child: _buildInfoCard(icon: Icons.update, label: 'Oxirgi yangilanish', value: _formatDateTime(user.updatedAt), color: Colors.orange)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({required IconData icon, required String label, required String value, required Color color}) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 20),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: AppConstants.textSecondaryColor)),
                SizedBox(height: 4),
                Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionsCard(UserModel user) {
    final permissions = _getRolePermissions(user.role);
    
    return Container(
      padding: EdgeInsets.all(AppConstants.paddingXLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(Icons.security, color: Colors.green, size: 24),
              ),
              SizedBox(width: 12),
              Text('Ruxsatlar va imkoniyatlar', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppConstants.textPrimaryColor)),
            ],
          ),
          SizedBox(height: AppConstants.paddingLarge),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: permissions.map((perm) => _buildPermissionChip(perm)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionChip(String permission) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppConstants.primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppConstants.primaryColor.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, size: 18, color: AppConstants.primaryColor),
          SizedBox(width: 8),
          Text(permission, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppConstants.primaryColor)),
        ],
      ),
    );
  }

  Widget _buildPasswordCard() {
    return Container(
      padding: EdgeInsets.all(AppConstants.paddingXLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(Icons.lock_outline, color: Colors.red, size: 24),
              ),
              SizedBox(width: 12),
              Text('Parolni o\'zgartirish', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppConstants.textPrimaryColor)),
              Spacer(),
              if (!isChangingPassword)
                TextButton.icon(
                  onPressed: () => setState(() => isChangingPassword = true),
                  icon: Icon(Icons.edit),
                  label: Text('O\'zgartirish'),
                )
              else
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      isChangingPassword = false;
                      oldPasswordController.clear();
                      newPasswordController.clear();
                      confirmPasswordController.clear();
                    });
                  },
                  icon: Icon(Icons.close),
                  label: Text('Bekor qilish'),
                  style: TextButton.styleFrom(foregroundColor: AppConstants.errorColor),
                ),
            ],
          ),
          if (isChangingPassword) ...[
            SizedBox(height: AppConstants.paddingLarge),
            _buildPasswordField(controller: oldPasswordController, label: 'Joriy parol', icon: Icons.lock, showPassword: showOldPassword,
              onToggle: () => setState(() => showOldPassword = !showOldPassword)),
            SizedBox(height: 16),
            _buildPasswordField(controller: newPasswordController, label: 'Yangi parol (kamida 6 ta belgi)', icon: Icons.lock_open, showPassword: showNewPassword,
              onToggle: () => setState(() => showNewPassword = !showNewPassword)),
            SizedBox(height: 16),
            _buildPasswordField(controller: confirmPasswordController, label: 'Parolni tasdiqlash', icon: Icons.lock_open, showPassword: showConfirmPassword,
              onToggle: () => setState(() => showConfirmPassword = !showConfirmPassword)),
            SizedBox(height: AppConstants.paddingLarge),
            ElevatedButton.icon(
              onPressed: _changePassword,
              icon: Icon(Icons.check),
              label: Text('Parolni yangilash'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.successColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ] else ...[
            SizedBox(height: AppConstants.paddingMedium),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppConstants.textSecondaryColor),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Xavfsizlik uchun parolingizni muntazam ravishda yangilang',
                      style: TextStyle(fontSize: 14, color: AppConstants.textSecondaryColor),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool enabled,
    bool isRequired = false,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium)),
        filled: !enabled,
        fillColor: enabled ? null : Colors.grey[50],
      ),
      validator: isRequired ? (value) {
        if (value == null || value.isEmpty) {
          return '$label ni kiriting';
        }
        return null;
      } : null,
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool showPassword,
    required VoidCallback onToggle,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: !showPassword,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: IconButton(
          icon: Icon(showPassword ? Icons.visibility_off : Icons.visibility),
          onPressed: onToggle,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium)),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'owner':
        return Colors.purple;
      case 'manager':
        return Colors.blue;
      case 'director':
        return Colors.indigo;
      case 'admin':
        return Colors.orange;
      case 'teacher':
        return Colors.green;
      case 'staff':
        return Colors.teal;
      default:
        return AppConstants.primaryColor;
    }
  }

  List<String> _getRolePermissions(String role) {
    switch (role) {
      case 'owner':
        return [
          '🎯 Barcha imkoniyatlar',
          '⚙️ Tizim sozlamalari',
          '🏢 Filiallar boshqaruvi',
          '👥 Barcha xodimlar boshqaruvi',
          '💰 To\'liq moliya nazorati',
          '📊 Barcha hisobotlar',
          '🔐 Xavfsizlik sozlamalari',
          '📈 Statistika va tahlil',
        ];
      case 'manager':
        return [
          '🏢 Filial boshqaruvi',
          '👥 Xodimlar boshqaruvi',
          '👨‍🎓 O\'quvchilar boshqaruvi',
          '💰 Moliya ko\'rish va boshqarish',
          '📊 Hisobotlar yaratish',
          '📅 Dars jadvali tuzish',
          '✅ Davomat nazorati',
          '💳 To\'lovlar boshqaruvi',
        ];
      case 'director':
        return [
          '🏢 Maktab boshqaruvi',
          '👥 Xodimlar nazorati',
          '👨‍🎓 O\'quvchilar nazorati',
          '📊 Hisobotlar ko\'rish',
          '📅 Dars jadvali tasdiqlash',
          '💰 Moliya ko\'rish',
        ];
      case 'admin':
        return [
          '👨‍🎓 O\'quvchilar boshqaruvi',
          '➕ Yangi o\'quvchi qo\'shish',
          '📅 Dars jadvali ko\'rish',
          '✅ Davomat belgilash',
          '💳 To\'lovlar qayd qilish',
          '📞 Tashrif buyuruvchilar',
          '🏫 Sinflar boshqaruvi',
        ];
      case 'teacher':
        return [
          '📚 Dars jadvali ko\'rish',
          '👨‍🎓 O\'quvchilar ro\'yxati',
          '✅ Davomat belgilash',
          '📝 Baholar qo\'yish',
          '📖 O\'quv materiallari',
          '💬 O\'quvchilar bilan aloqa',
        ];
      case 'staff':
        return [
          '📋 Asosiy imkoniyatlar',
          '👀 Ma\'lumotlarni ko\'rish',
          '📞 Aloqa imkoniyatlari',
        ];
      default:
        return ['📋 Asosiy imkoniyatlar'];
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year;
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$day.$month.$year $hour:$minute';
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    return '$day.$month.$year';
  }
}