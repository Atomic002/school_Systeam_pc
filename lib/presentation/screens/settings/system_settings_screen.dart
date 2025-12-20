// lib/presentation/screens/settings/system_settings_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../config/constants.dart';
import '../../controllers/system_settings_controller.dart';
import '../../widgets/sidebar.dart';

class SystemSettingsScreen extends StatelessWidget {
  SystemSettingsScreen({Key? key}) : super(key: key);

  final controller = Get.put(SystemSettingsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundLight,
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
                      return Center(child: CircularProgressIndicator());
                    }
                    return _buildContent(context);
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
      padding: EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppConstants.primaryColor, AppConstants.secondaryColor],
        ),
        boxShadow: [
          BoxShadow(
            color: AppConstants.primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.settings, color: Colors.white, size: 32),
          SizedBox(width: 16),
          Text(
            'Tizim Sozlamalari',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Spacer(),
          ElevatedButton.icon(
            onPressed: controller.saveAllSettings,
            icon: Icon(Icons.save),
            label: Text('Barchasini Saqlash'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppConstants.primaryColor,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
          SizedBox(width: 12),
          IconButton(
            onPressed: controller.refreshSettings,
            icon: Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Yangilash',
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppConstants.paddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGeneralSettings(),
          SizedBox(height: 24),
          _buildAcademicSettings(),
          SizedBox(height: 24),
          _buildFinanceSettings(),
          SizedBox(height: 24),
          _buildAttendanceSettings(),
          SizedBox(height: 24),
          _buildNotificationSettings(),
        ],
      ),
    );
  }

  Widget _buildGeneralSettings() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: AppConstants.primaryColor, size: 28),
                SizedBox(width: 12),
                Text(
                  'Umumiy Sozlamalar',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 24),
            
            // Maktab ochilgan yil
            Obx(() => _buildNumberSetting(
              title: 'Maktab Ochilgan Yil',
              subtitle: 'Tizimda ko\'rsatiladigan eng qadimgi yil',
              value: controller.schoolStartYear.value,
              icon: Icons.calendar_today,
              onChanged: (value) => controller.schoolStartYear.value = value,
              min: 2000,
              max: DateTime.now().year,
            )),
            
            Divider(height: 32),
            
            // Maktab nomi
            Obx(() => _buildTextSetting(
              title: 'Maktab Nomi',
              subtitle: 'Rasmiy tashkilot nomi',
              value: controller.schoolName.value,
              icon: Icons.business,
              onChanged: (value) => controller.schoolName.value = value,
            )),
            
            Divider(height: 32),
            
            // Telefon raqam
            Obx(() => _buildTextSetting(
              title: 'Telefon Raqam',
              subtitle: 'Asosiy aloqa telefoni',
              value: controller.schoolPhone.value,
              icon: Icons.phone,
              onChanged: (value) => controller.schoolPhone.value = value,
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildAcademicSettings() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.school, color: AppConstants.primaryColor, size: 28),
                SizedBox(width: 12),
                Text(
                  'O\'quv Jarayoni Sozlamalari',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 24),
            
            // O'quv yili boshlanish oyi
            Obx(() => _buildDropdownSetting(
              title: 'O\'quv Yili Boshlanish Oyi',
              subtitle: 'Har yili o\'quv yili qaysi oyda boshlanadi',
              value: controller.academicYearStartMonth.value,
              icon: Icons.event_available,
              items: _getMonthItems(),
              onChanged: (value) => controller.academicYearStartMonth.value = value!,
            )),
            
            Divider(height: 32),
            
            // O'quv yili tugash oyi
            Obx(() => _buildDropdownSetting(
              title: 'O\'quv Yili Tugash Oyi',
              subtitle: 'Har yili o\'quv yili qaysi oyda tugaydi',
              value: controller.academicYearEndMonth.value,
              icon: Icons.event_busy,
              items: _getMonthItems(),
              onChanged: (value) => controller.academicYearEndMonth.value = value!,
            )),
            
            Divider(height: 32),
            
            // Dars davomiyligi (daqiqa)
            Obx(() => _buildNumberSetting(
              title: 'Dars Davomiyligi',
              subtitle: 'Bir dars necha daqiqa davom etadi',
              value: controller.lessonDuration.value,
              icon: Icons.timer,
              onChanged: (value) => controller.lessonDuration.value = value,
              min: 30,
              max: 120,
              suffix: 'daqiqa',
            )),
            
            Divider(height: 32),
            
            // Tanaffus davomiyligi
            Obx(() => _buildNumberSetting(
              title: 'Tanaffus Davomiyligi',
              subtitle: 'Darslar orasidagi tanaffus',
              value: controller.breakDuration.value,
              icon: Icons.free_breakfast,
              onChanged: (value) => controller.breakDuration.value = value,
              min: 5,
              max: 30,
              suffix: 'daqiqa',
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildFinanceSettings() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.account_balance_wallet, 
                    color: AppConstants.primaryColor, size: 28),
                SizedBox(width: 12),
                Text(
                  'Moliya Sozlamalari',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 24),
            
            // To'lov muddati (kun)
            Obx(() => _buildNumberSetting(
              title: 'To\'lov Muddati',
              subtitle: 'Oylik to\'lovni qaysi kungacha to\'lash kerak',
              value: controller.paymentDeadlineDay.value,
              icon: Icons.event,
              onChanged: (value) => controller.paymentDeadlineDay.value = value,
              min: 1,
              max: 31,
              suffix: '-kun',
            )),
            
            Divider(height: 32),
            
            // Kechikish jarima foizi
            Obx(() => _buildNumberSetting(
              title: 'Kechikish Jarima Foizi',
              subtitle: 'To\'lov kechiksa qo\'llaniladigan jarima',
              value: controller.lateFeePercent.value,
              icon: Icons.percent,
              onChanged: (value) => controller.lateFeePercent.value = value,
              min: 0,
              max: 50,
              suffix: '%',
              isDecimal: true,
            )),
            
            Divider(height: 32),
            
            // Chegirma maksimal foizi
            Obx(() => _buildNumberSetting(
              title: 'Maksimal Chegirma',
              subtitle: 'O\'quvchiga beriladigan maksimal chegirma foizi',
              value: controller.maxDiscountPercent.value,
              icon: Icons.discount,
              onChanged: (value) => controller.maxDiscountPercent.value = value,
              min: 0,
              max: 100,
              suffix: '%',
              isDecimal: true,
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceSettings() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.how_to_reg, color: AppConstants.primaryColor, size: 28),
                SizedBox(width: 12),
                Text(
                  'Davomat Sozlamalari',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 24),
            
            // Kechikish vaqti (daqiqa)
            Obx(() => _buildNumberSetting(
              title: 'Kechikish Vaqti',
              subtitle: 'Necha daqiqadan keyin kechikish hisoblanadi',
              value: controller.lateArrivalMinutes.value,
              icon: Icons.schedule,
              onChanged: (value) => controller.lateArrivalMinutes.value = value,
              min: 5,
              max: 60,
              suffix: 'daqiqa',
            )),
            
            Divider(height: 32),
            
            // Avtomatik davomat
            Obx(() => _buildSwitchSetting(
              title: 'Avtomatik Davomat',
              subtitle: 'Biometrik yoki QR kod orqali avtomatik belgilash',
              value: controller.autoAttendance.value,
              icon: Icons.fingerprint,
              onChanged: (value) => controller.autoAttendance.value = value,
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSettings() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.notifications, 
                    color: AppConstants.primaryColor, size: 28),
                SizedBox(width: 12),
                Text(
                  'Bildirishnomalar',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 24),
            
            // SMS bildirishnomalar
            Obx(() => _buildSwitchSetting(
              title: 'SMS Bildirishnomalar',
              subtitle: 'To\'lovlar va davomatlar haqida SMS yuborish',
              value: controller.smsNotifications.value,
              icon: Icons.sms,
              onChanged: (value) => controller.smsNotifications.value = value,
            )),
            
            Divider(height: 32),
            
            // Email bildirishnomalar
            Obx(() => _buildSwitchSetting(
              title: 'Email Bildirishnomalar',
              subtitle: 'Ota-onalarga email yuborish',
              value: controller.emailNotifications.value,
              icon: Icons.email,
              onChanged: (value) => controller.emailNotifications.value = value,
            )),
          ],
        ),
      ),
    );
  }

  // ==================== YORDAMCHI WIDGET'LAR ====================
  
  Widget _buildNumberSetting({
    required String title,
    required String subtitle,
    required int value,
    required IconData icon,
    required Function(int) onChanged,
    required int min,
    required int max,
    String? suffix,
    bool isDecimal = false,
  }) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppConstants.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppConstants.primaryColor),
      ),
      title: Text(
        title,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 13)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: value > min ? () => onChanged(value - 1) : null,
            icon: Icon(Icons.remove_circle_outline),
            color: AppConstants.primaryColor,
          ),
          Container(
            constraints: BoxConstraints(minWidth: 80),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: AppConstants.primaryColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$value${suffix ?? ''}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppConstants.primaryColor,
              ),
            ),
          ),
          IconButton(
            onPressed: value < max ? () => onChanged(value + 1) : null,
            icon: Icon(Icons.add_circle_outline),
            color: AppConstants.primaryColor,
          ),
          IconButton(
            onPressed: () => _showNumberEditDialog(
              title, value, min, max, suffix, onChanged,
            ),
            icon: Icon(Icons.edit),
            color: Colors.grey,
          ),
        ],
      ),
    );
  }

  Widget _buildTextSetting({
    required String title,
    required String subtitle,
    required String value,
    required IconData icon,
    required Function(String) onChanged,
  }) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppConstants.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppConstants.primaryColor),
      ),
      title: Text(
        title,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 13)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: 200),
            child: Text(
              value.isEmpty ? 'Belgilanmagan' : value,
              style: TextStyle(
                fontSize: 14,
                color: value.isEmpty ? Colors.grey : Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: 8),
          IconButton(
            onPressed: () => _showTextEditDialog(title, value, onChanged),
            icon: Icon(Icons.edit),
            color: AppConstants.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownSetting({
    required String title,
    required String subtitle,
    required int value,
    required IconData icon,
    required List<DropdownMenuItem<int>> items,
    required Function(int?) onChanged,
  }) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppConstants.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppConstants.primaryColor),
      ),
      title: Text(
        title,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 13)),
      trailing: Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: AppConstants.primaryColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: DropdownButton<int>(
          value: value,
          underline: SizedBox(),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildSwitchSetting({
    required String title,
    required String subtitle,
    required bool value,
    required IconData icon,
    required Function(bool) onChanged,
  }) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: value 
              ? AppConstants.successColor.withOpacity(0.1)
              : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: value ? AppConstants.successColor : Colors.grey,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 13)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppConstants.successColor,
      ),
    );
  }

  List<DropdownMenuItem<int>> _getMonthItems() {
    final months = [
      'Yanvar', 'Fevral', 'Mart', 'Aprel', 'May', 'Iyun',
      'Iyul', 'Avgust', 'Sentabr', 'Oktabr', 'Noyabr', 'Dekabr',
    ];
    return List.generate(12, (index) {
      return DropdownMenuItem(
        value: index + 1,
        child: Text(months[index]),
      );
    });
  }

  void _showNumberEditDialog(
    String title,
    int currentValue,
    int min,
    int max,
    String? suffix,
    Function(int) onSave,
  ) {
    final controller = TextEditingController(text: currentValue.toString());
    
    Get.dialog(
      AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Qiymat',
            suffixText: suffix,
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Bekor qilish'),
          ),
          ElevatedButton(
            onPressed: () {
              final value = int.tryParse(controller.text);
              if (value != null && value >= min && value <= max) {
                onSave(value);
                Get.back();
              } else {
                Get.snackbar(
                  'Xato',
                  'Qiymat $min va $max oralig\'ida bo\'lishi kerak',
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
            child: Text('Saqlash'),
          ),
        ],
      ),
    );
  }

  void _showTextEditDialog(
    String title,
    String currentValue,
    Function(String) onSave,
  ) {
    final controller = TextEditingController(text: currentValue);
    
    Get.dialog(
      AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: 'Qiymat',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Bekor qilish'),
          ),
          ElevatedButton(
            onPressed: () {
              onSave(controller.text);
              Get.back();
            },
            child: Text('Saqlash'),
          ),
        ],
      ),
    );
  }
}