// lib/presentation/controllers/system_settings_controller.dart

import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SystemSettingsController extends GetxController {
  final supabase = Supabase.instance.client;

  var isLoading = false.obs;
  var isSaving = false.obs;

  // Umumiy sozlamalar
  var schoolStartYear = 2020.obs;
  var schoolName = ''.obs;
  var schoolPhone = ''.obs;

  // O'quv jarayoni
  var academicYearStartMonth = 9.obs;
  var academicYearEndMonth = 6.obs;
  var lessonDuration = 45.obs;
  var breakDuration = 10.obs;

  // Moliya
  var paymentDeadlineDay = 10.obs;
  var lateFeePercent = 5.obs;
  var maxDiscountPercent = 50.obs;

  // Davomat
  var lateArrivalMinutes = 15.obs;
  var autoAttendance = false.obs;

  // Bildirishnomalar
  var smsNotifications = true.obs;
  var emailNotifications = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }

  Future<void> loadSettings() async {
    isLoading.value = true;
    try {
      final settings = await supabase
          .from('system_settings')
          .select()
;
      for (var setting in settings) {
        final key = setting['setting_key'] as String;
        final value = setting['setting_value'] as String?;
        
        if (value == null) continue;

        switch (key) {
          case 'school_start_year':
            schoolStartYear.value = int.tryParse(value) ?? 2020;
            break;
          case 'school_name':
            schoolName.value = value;
            break;
          case 'school_phone':
            schoolPhone.value = value;
            break;
          case 'academic_year_start_month':
            academicYearStartMonth.value = int.tryParse(value) ?? 9;
            break;
          case 'academic_year_end_month':
            academicYearEndMonth.value = int.tryParse(value) ?? 6;
            break;
          case 'lesson_duration':
            lessonDuration.value = int.tryParse(value) ?? 45;
            break;
          case 'break_duration':
            breakDuration.value = int.tryParse(value) ?? 10;
            break;
          case 'payment_deadline_day':
            paymentDeadlineDay.value = int.tryParse(value) ?? 10;
            break;
          case 'late_fee_percent':
            lateFeePercent.value = int.tryParse(value) ?? 5;
            break;
          case 'max_discount_percent':
            maxDiscountPercent.value = int.tryParse(value) ?? 50;
            break;
          case 'late_arrival_minutes':
            lateArrivalMinutes.value = int.tryParse(value) ?? 15;
            break;
          case 'auto_attendance':
            autoAttendance.value = value.toLowerCase() == 'true';
            break;
          case 'sms_notifications':
            smsNotifications.value = value.toLowerCase() == 'true';
            break;
          case 'email_notifications':
            emailNotifications.value = value.toLowerCase() == 'true';
            break;
        }
      }
      
      print('✅ Sozlamalar yuklandi');
    } catch (e) {
      print('❌ Load settings error: $e');
      Get.snackbar('Xato', 'Sozlamalar yuklanmadi');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveAllSettings() async {
    if (isSaving.value) return;
    isSaving.value = true;

    try {
      final settingsToSave = [
        {'key': 'school_start_year', 'value': schoolStartYear.value.toString(), 'type': 'number'},
        {'key': 'school_name', 'value': schoolName.value, 'type': 'string'},
        {'key': 'school_phone', 'value': schoolPhone.value, 'type': 'string'},
        {'key': 'academic_year_start_month', 'value': academicYearStartMonth.value.toString(), 'type': 'number'},
        {'key': 'academic_year_end_month', 'value': academicYearEndMonth.value.toString(), 'type': 'number'},
        {'key': 'lesson_duration', 'value': lessonDuration.value.toString(), 'type': 'number'},
        {'key': 'break_duration', 'value': breakDuration.value.toString(), 'type': 'number'},
        {'key': 'payment_deadline_day', 'value': paymentDeadlineDay.value.toString(), 'type': 'number'},
        {'key': 'late_fee_percent', 'value': lateFeePercent.value.toString(), 'type': 'number'},
        {'key': 'max_discount_percent', 'value': maxDiscountPercent.value.toString(), 'type': 'number'},
        {'key': 'late_arrival_minutes', 'value': lateArrivalMinutes.value.toString(), 'type': 'number'},
        {'key': 'auto_attendance', 'value': autoAttendance.value.toString(), 'type': 'boolean'},
        {'key': 'sms_notifications', 'value': smsNotifications.value.toString(), 'type': 'boolean'},
        {'key': 'email_notifications', 'value': emailNotifications.value.toString(), 'type': 'boolean'},
      ];

      for (var setting in settingsToSave) {
        await supabase.from('system_settings').upsert({
          'branch_id': null,
          'setting_key': setting['key'],
'setting_value': setting['value'],
'setting_type': setting['type'],
'updated_at': DateTime.now().toIso8601String(),
});
}  Get.snackbar(
    'Muvaffaqiyatli',
    'Barcha sozlamalar saqlandi',
    snackPosition: SnackPosition.BOTTOM,
  );
} catch (e) {
  print('❌ Save settings error: $e');
  Get.snackbar('Xato', 'Sozlamalar saqlanmadi');
} finally {
  isSaving.value = false;
}
}
Future<void> refreshSettings() async {
await loadSettings();
Get.snackbar(
'Yangilandi',
'Sozlamalar yangilandi',
snackPosition: SnackPosition.BOTTOM,
duration: Duration(seconds: 2),
);
}
}