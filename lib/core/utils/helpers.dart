// lib/core/utils/helpers.dart
// IZOH: Umumiy yordamchi funksiyalar.

import 'package:intl/intl.dart';

class Helpers {
  // Summani formatlash (123456789 -> 123,456,789)
  static String formatCurrency(double amount, {bool showDecimals = false}) {
    final formatter = NumberFormat('#,###', 'en_US');
    if (showDecimals) {
      return formatter.format(amount.toStringAsFixed(2));
    }
    return formatter.format(amount.toInt());
  }

  // Sanani formatlash
  static String formatDate(DateTime date, {String format = 'dd.MM.yyyy'}) {
    final formatter = DateFormat(format);
    return formatter.format(date);
  }

  // Vaqtni formatlash
  static String formatTime(DateTime time) {
    final formatter = DateFormat('HH:mm');
    return formatter.format(time);
  }

  // Sana va vaqtni formatlash
  static String formatDateTime(DateTime dateTime) {
    final formatter = DateFormat('dd.MM.yyyy HH:mm');
    return formatter.format(dateTime);
  }

  // Telefon raqamni formatlash
  static String formatPhone(String phone) {
    // +998901234567 -> +998 90 123 45 67
    if (phone.startsWith('+998') && phone.length == 13) {
      return '${phone.substring(0, 4)} ${phone.substring(4, 6)} ${phone.substring(6, 9)} ${phone.substring(9, 11)} ${phone.substring(11)}';
    }
    return phone;
  }

  // Foizni hisoblash
  static double calculatePercentage(double value, double total) {
    if (total == 0) return 0;
    return (value / total) * 100;
  }

  // Chegirmani hisoblash
  static double calculateDiscount(double amount, double percent) {
    return amount * (percent / 100);
  }

  // Yakuniy summani hisoblash (chegirma bilan)
  static double calculateFinalAmount(double amount, double discount) {
    return amount - discount;
  }

  // Yoshni hisoblash
  static int calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  // Oy nomini olish
  static String getMonthName(int month) {
    const months = [
      'Yanvar',
      'Fevral',
      'Mart',
      'Aprel',
      'May',
      'Iyun',
      'Iyul',
      'Avgust',
      'Sentabr',
      'Oktabr',
      'Noyabr',
      'Dekabr',
    ];
    return months[month - 1];
  }

  // Hafta kuni nomini olish
  static String getWeekdayName(int weekday) {
    const weekdays = [
      'Dushanba',
      'Seshanba',
      'Chorshanba',
      'Payshanba',
      'Juma',
      'Shanba',
      'Yakshanba',
    ];
    return weekdays[weekday - 1];
  }

  // String'ni capitalize qilish
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  // UUID generatsiya qilish
  static String generateUUID() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}
