// lib/presentation/screens/auth/login_screen.dart
// IZOH: Login sahifasi - username, parol va "Eslab qolish" checkbox

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../../config/constants.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({Key? key}) : super(key: key);

  // ✅ Get.find() ishlatish - AppBindings da yaratilgan
  final AuthController authController = Get.find<AuthController>();

  // Text controllers
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Reactive variables
  final RxBool obscurePassword = true.obs;
  final RxBool rememberMe = false.obs; // ← YANGI: Eslab qolish

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppConstants.primaryColor, AppConstants.secondaryColor],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(AppConstants.paddingXLarge),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  AppConstants.borderRadiusLarge,
                ),
              ),
              child: Container(
                width: 450,
                padding: EdgeInsets.all(AppConstants.paddingXLarge),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildHeader(),
                    SizedBox(height: AppConstants.paddingLarge),
                    _buildUsernameField(),
                    SizedBox(height: AppConstants.paddingMedium),
                    _buildPasswordField(),
                    SizedBox(height: AppConstants.paddingSmall),

                    // ✅ YANGI: Eslab qolish checkbox
                    _buildRememberMeCheckbox(),

                    SizedBox(height: AppConstants.paddingSmall),

                    // Xatolik xabari
                    Obx(
                      () => authController.errorMessage.value.isNotEmpty
                          ? _buildErrorMessage()
                          : SizedBox.shrink(),
                    ),

                    SizedBox(height: AppConstants.paddingLarge),
                    _buildLoginButton(),
                    SizedBox(height: AppConstants.paddingMedium),
                    _buildFooter(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ========== HEADER ==========
  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppConstants.primaryColor, AppConstants.secondaryColor],
            ),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.school, size: 40, color: Colors.white),
        ),
        SizedBox(height: AppConstants.paddingMedium),
        Text(
          'School System',
          style: TextStyle(
            fontSize: AppConstants.fontSizeTitle,
            fontWeight: FontWeight.bold,
            color: AppConstants.textPrimaryColor,
          ),
        ),
        SizedBox(height: AppConstants.paddingSmall),
        Text(
          'Maktab boshqaruv tizimi',
          style: TextStyle(
            fontSize: AppConstants.fontSizeMedium,
            color: AppConstants.textSecondaryColor,
          ),
        ),
      ],
    );
  }

  // ========== USERNAME FIELD ==========
  Widget _buildUsernameField() {
    return TextField(
      controller: usernameController,
      decoration: InputDecoration(
        labelText: 'Foydalanuvchi nomi',
        hintText: 'Username kiriting',
        prefixIcon: Icon(Icons.person_outline),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        ),
      ),
      textInputAction: TextInputAction.next,
      onSubmitted: (_) => _handleLogin(),
    );
  }

  // ========== PASSWORD FIELD ==========
  Widget _buildPasswordField() {
    return Obx(
      () => TextField(
        controller: passwordController,
        obscureText: obscurePassword.value,
        decoration: InputDecoration(
          labelText: 'Parol',
          hintText: 'Parolni kiriting',
          prefixIcon: Icon(Icons.lock_outline),
          suffixIcon: IconButton(
            icon: Icon(
              obscurePassword.value
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
            ),
            onPressed: () {
              obscurePassword.value = !obscurePassword.value;
            },
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              AppConstants.borderRadiusMedium,
            ),
          ),
        ),
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _handleLogin(),
      ),
    );
  }

  // ========== REMEMBER ME CHECKBOX ==========
  Widget _buildRememberMeCheckbox() {
    return Obx(
      () => Row(
        children: [
          Checkbox(
            value: rememberMe.value,
            onChanged: (value) {
              rememberMe.value = value ?? false;
            },
            activeColor: AppConstants.primaryColor,
          ),
          GestureDetector(
            onTap: () {
              rememberMe.value = !rememberMe.value;
            },
            child: Text(
              'Meni eslab qol',
              style: TextStyle(
                fontSize: AppConstants.fontSizeMedium,
                color: AppConstants.textPrimaryColor,
              ),
            ),
          ),
          Spacer(),
          // Opsional: "Parolni unutdingizmi?" tugmasi
          TextButton(
            onPressed: () {
              // TODO: Parolni tiklash sahifasi
              Get.snackbar(
                'Ma\'lumot',
                'Parolni tiklash funksiyasi hali qo\'shilmagan',
                snackPosition: SnackPosition.TOP,
              );
            },
            child: Text(
              'Parolni unutdingizmi?',
              style: TextStyle(
                fontSize: AppConstants.fontSizeSmall,
                color: AppConstants.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ========== ERROR MESSAGE ==========
  Widget _buildErrorMessage() {
    return Container(
      padding: EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppConstants.errorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        border: Border.all(color: AppConstants.errorColor),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: AppConstants.errorColor),
          SizedBox(width: AppConstants.paddingSmall),
          Expanded(
            child: Text(
              authController.errorMessage.value,
              style: TextStyle(
                color: AppConstants.errorColor,
                fontSize: AppConstants.fontSizeMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ========== LOGIN BUTTON ==========
  Widget _buildLoginButton() {
    return Obx(
      () => SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: authController.isLoading.value ? null : _handleLogin,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppConstants.primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                AppConstants.borderRadiusMedium,
              ),
            ),
          ),
          child: authController.isLoading.value
              ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  'Kirish',
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeLarge,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }

  // ========== FOOTER ==========
  Widget _buildFooter() {
    return Text(
      'Version ${AppConstants.appVersion}',
      style: TextStyle(
        fontSize: AppConstants.fontSizeSmall,
        color: AppConstants.textLightColor,
      ),
    );
  }

  // ========== LOGIN HANDLER ==========
  void _handleLogin() {
    // Keyboard ni yopish
    FocusScope.of(Get.context!).unfocus();

    // ✅ Login qilish - rememberMe parametri bilan
    authController.login(
      username: usernameController.text.trim(),
      password: passwordController.text,
      rememberMe: rememberMe.value, // ← Bu yerda checkbox qiymati uzatiladi
    );
  }
}

// ==================== QANDAY ISHLAYDI ====================
//
// 1. Foydalanuvchi username va parolni kiritadi
// 2. "Meni eslab qol" checkbox ni belgilaydi (yoki belgilamaydi)
// 3. "Kirish" tugmasini bosadi
// 4. _handleLogin() chaqiriladi
// 5. authController.login() ga rememberMe qiymati uzatiladi
// 6. Agar rememberMe = true:
//    → AuthRepository user ID ni SharedPreferences ga saqlaydi
//    → Keyingi safar avtomatik kiradi
// 7. Agar rememberMe = false:
//    → Hech narsa saqlanmaydi
//    → Keyingi safar qayta login qilish kerak
