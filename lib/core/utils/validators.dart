// lib/core/utils/validators.dart
// IZOH: Form validatsiyalari uchun funksiyalar.

class Validators {
  // Bo'sh maydon tekshiruvi
  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return fieldName != null
          ? '$fieldName to\'ldirilishi shart'
          : 'Bu maydon to\'ldirilishi shart';
    }
    return null;
  }

  // Email validatsiyasi
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email manzil kiriting';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Noto\'g\'ri email format';
    }
    return null;
  }

  // Telefon raqam validatsiyasi
  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Telefon raqam kiriting';
    }

    // O'zbekiston telefon formati: +998XXXXXXXXX
    final phoneRegex = RegExp(r'^\+998\d{9}$');

    if (!phoneRegex.hasMatch(value.replaceAll(' ', ''))) {
      return 'Noto\'g\'ri telefon format (+998 XX XXX XX XX)';
    }
    return null;
  }

  // Parol validatsiyasi
  static String? password(String? value, {int minLength = 6}) {
    if (value == null || value.isEmpty) {
      return 'Parol kiriting';
    }

    if (value.length < minLength) {
      return 'Parol kamida $minLength ta belgidan iborat bo\'lishi kerak';
    }
    return null;
  }

  // Parolni tasdiqlash
  static String? confirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Parolni takrorlang';
    }

    if (value != password) {
      return 'Parollar mos emas';
    }
    return null;
  }

  // Raqam validatsiyasi
  static String? number(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return fieldName != null ? '$fieldName kiriting' : 'Raqam kiriting';
    }

    final number = double.tryParse(value);
    if (number == null) {
      return 'Faqat raqam kiriting';
    }
    return null;
  }

  // Musbat raqam validatsiyasi
  static String? positiveNumber(String? value, {String? fieldName}) {
    final numberError = number(value, fieldName: fieldName);
    if (numberError != null) return numberError;

    final num = double.parse(value!);
    if (num <= 0) {
      return 'Musbat raqam kiriting';
    }
    return null;
  }

  // Minimum qiymat validatsiyasi
  static String? minValue(String? value, double min, {String? fieldName}) {
    final numberError = number(value, fieldName: fieldName);
    if (numberError != null) return numberError;

    final num = double.parse(value!);
    if (num < min) {
      return 'Qiymat $min dan kichik bo\'lmasligi kerak';
    }
    return null;
  }

  // Maksimal qiymat validatsiyasi
  static String? maxValue(String? value, double max, {String? fieldName}) {
    final numberError = number(value, fieldName: fieldName);
    if (numberError != null) return numberError;

    final num = double.parse(value!);
    if (num > max) {
      return 'Qiymat $max dan katta bo\'lmasligi kerak';
    }
    return null;
  }

  // Minimum uzunlik validatsiyasi
  static String? minLength(String? value, int min, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return fieldName != null
          ? '$fieldName kiriting'
          : 'Bu maydon to\'ldirilishi shart';
    }

    if (value.length < min) {
      return 'Kamida $min ta belgi bo\'lishi kerak';
    }
    return null;
  }

  // Maksimal uzunlik validatsiyasi
  static String? maxLength(String? value, int max, {String? fieldName}) {
    if (value != null && value.length > max) {
      return 'Ko\'pi bilan $max ta belgi bo\'lishi mumkin';
    }
    return null;
  }

  // Faqat harflar validatsiyasi
  static String? alphabetic(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return fieldName != null
          ? '$fieldName kiriting'
          : 'Bu maydon to\'ldirilishi shart';
    }

    final alphabeticRegex = RegExp(r'^[a-zA-Zа-яА-ЯёЁўЎқҚғҒҳҲ\s]+$');

    if (!alphabeticRegex.hasMatch(value)) {
      return 'Faqat harflar kiriting';
    }
    return null;
  }

  // Faqat raqamlar validatsiyasi
  static String? numeric(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return fieldName != null
          ? '$fieldName kiriting'
          : 'Bu maydon to\'ldirilishi shart';
    }

    final numericRegex = RegExp(r'^[0-9]+$');

    if (!numericRegex.hasMatch(value)) {
      return 'Faqat raqamlar kiriting';
    }
    return null;
  }

  // URL validatsiyasi
  static String? url(String? value) {
    if (value == null || value.isEmpty) {
      return 'URL kiriting';
    }

    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );

    if (!urlRegex.hasMatch(value)) {
      return 'Noto\'g\'ri URL format';
    }
    return null;
  }

  // Sana validatsiyasi (kelajakda bo'lmasligi kerak)
  static String? pastDate(DateTime? value, {String? fieldName}) {
    if (value == null) {
      return fieldName != null ? '$fieldName tanlang' : 'Sana tanlang';
    }

    if (value.isAfter(DateTime.now())) {
      return 'Sana kelajakda bo\'lmasligi kerak';
    }
    return null;
  }

  // Sana validatsiyasi (o'tmishda bo'lmasligi kerak)
  static String? futureDate(DateTime? value, {String? fieldName}) {
    if (value == null) {
      return fieldName != null ? '$fieldName tanlang' : 'Sana tanlang';
    }

    if (value.isBefore(DateTime.now())) {
      return 'Sana o\'tmishda bo\'lmasligi kerak';
    }
    return null;
  }

  // Yosh validatsiyasi
  static String? age(DateTime? birthDate, {int minAge = 0, int maxAge = 150}) {
    if (birthDate == null) {
      return 'Tug\'ilgan sanani tanlang';
    }

    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }

    if (age < minAge) {
      return 'Yosh $minAge dan kichik bo\'lmasligi kerak';
    }

    if (age > maxAge) {
      return 'Yosh $maxAge dan katta bo\'lmasligi kerak';
    }

    return null;
  }

  // JSHSHIR validatsiyasi (14 raqamli)
  static String? jshshir(String? value) {
    if (value == null || value.isEmpty) {
      return 'JSHSHIR kiriting';
    }

    if (value.length != 14) {
      return 'JSHSHIR 14 ta raqamdan iborat bo\'lishi kerak';
    }

    final numericRegex = RegExp(r'^[0-9]{14}$');
    if (!numericRegex.hasMatch(value)) {
      return 'JSHSHIR faqat raqamlardan iborat bo\'lishi kerak';
    }

    return null;
  }
}
