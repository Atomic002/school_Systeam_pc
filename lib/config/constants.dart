// lib/config/constants.dart
// IZOH: Ilovada ishlatiladigan barcha konstantalar (o'zgarmas qiymatlar)
// bu faylda yig'ilgan. Bir joyda saqlash kodni boshqarishni osonlashtiradi.

import 'package:flutter/material.dart';

class AppConstants {
  // Ilova nomi
  static const String appName = 'School System';
  static const String appVersion = '1.0.0';

  // Rang paletkasi
  static const Color primaryColor = Color(0xFF667EEA);
  static const Color secondaryColor = Color(0xFF764BA2);
  static const Color accentColor = Color(0xFF10B981);
  static const Color errorColor = Color(0xFFEF4444);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color successColor = Color(0xFF10B981);
  static const Color infoColor = Color(0xFF3B82F6);

  // Text ranglari
  static const Color textPrimaryColor = Color(0xFF1F2937);
  static const Color textSecondaryColor = Color(0xFF6B7280);
  static const Color textLightColor = Color(0xFF9CA3AF);

  // Background ranglari
  static const Color backgroundLight = Color(0xFFF9FAFB);
  static const Color backgroundDark = Color(0xFF1F2937);
  static const Color cardColor = Colors.white;

  // Padding va Margin
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;

  // Border Radius
  static const double borderRadiusSmall = 4.0;
  static const double borderRadiusMedium = 8.0;
  static const double borderRadiusLarge = 12.0;
  static const double borderRadiusXLarge = 16.0;

  // Shriftlar (Font Sizes)
  static const double fontSizeSmall = 12.0;
  static const double fontSizeMedium = 14.0;
  static const double fontSizeLarge = 16.0;
  static const double fontSizeXLarge = 18.0;
  static const double fontSizeXXLarge = 24.0;
  static const double fontSizeTitle = 32.0;

  // Icon o'lchamlari
  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;

  // Animation durations (millisekundlarda)
  static const int animationDuration = 300;
  static const int animationDurationSlow = 500;

  // Valyuta
  static const String currency = "so'm";
  static const String currencySymbol = "UZS";

  // Sana formatlari
  static const String dateFormat = 'dd.MM.yyyy';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'dd.MM.yyyy HH:mm';

  // Pagination
  static const int itemsPerPage = 20;
  static const int searchDebounceMs = 500; // Qidiruv debounce vaqti

  // Foydalanuvchi rollari
  static const String roleOwner = 'owner';
  static const String roleManager = 'manager';
  static const String roleDirector = 'director';
  static const String roleAdmin = 'admin';
  static const String roleTeacher = 'teacher';
  static const String roleStaff = 'staff';

  // Status nomlari
  static const String statusActive = 'active';
  static const String statusInactive = 'inactive';
  static const String statusPaused = 'paused';
  static const String statusBlocked = 'blocked';

  // To'lov statuslari
  static const String paymentStatusPaid = 'paid';
  static const String paymentStatusPending = 'pending';
  static const String paymentStatusOverdue = 'overdue';

  // Davomat statuslari
  static const String attendancePresent = 'present';
  static const String attendanceAbsent = 'absent';
  static const String attendanceLate = 'late';
  static const String attendanceExcused = 'excused';

  // Xabar matnlari
  static const String errorGeneric =
      'Xatolik yuz berdi. Iltimos, qaytadan urinib ko\'ring.';
  static const String errorNetwork = 'Internet bilan bog\'lanishda xatolik.';
  static const String errorAuth = 'Avtorizatsiya xatosi. Qaytadan kiring.';
  static const String successSaved = 'Ma\'lumotlar muvaffaqiyatli saqlandi!';
  static const String successDeleted = 'Ma\'lumotlar o\'chirildi!';
  static const String successUpdated = 'Ma\'lumotlar yangilandi!';

  // Validatsiya xabarlari
  static const String validationRequired = 'Bu maydon to\'ldirilishi shart';
  static const String validationEmail = 'Noto\'g\'ri email format';
  static const String validationPhone = 'Noto\'g\'ri telefon raqam format';
  static const String validationPassword =
      'Parol kamida 6 ta belgidan iborat bo\'lishi kerak';

  static const double paddingXXLarge = 48.0;

  // ============================================================================
  // BORDER RADIUS
  // ============================================================================

  // ============================================================================
  // FONT SIZE
  // ============================================================================

  static const double fontSizeXXXLarge = 32.0;

  // ============================================================================
  // ICON SIZE
  // ============================================================================

  static const double iconSizeXLarge = 48.0;

  // ============================================================================
  // ELEVATION
  // ============================================================================

  static const double elevationLow = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationHigh = 8.0;

  // ============================================================================
  // ANIMATION DURATION
  // ============================================================================

  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // ============================================================================
  // VALYUTA
  // ============================================================================

  // ============================================================================
  // BREAKPOINTS (Responsive)
  // ============================================================================

  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  // ============================================================================
  // SIDEBAR
  // ============================================================================

  static const double sidebarWidth = 250;
  static const double sidebarCollapsedWidth = 70;

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  /// Responsive padding
  static double getResponsivePadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) return paddingSmall;
    if (width < tabletBreakpoint) return paddingMedium;
    return paddingLarge;
  }

  /// Responsive font size
  static double getResponsiveFontSize(BuildContext context, double baseSize) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) return baseSize * 0.9;
    if (width < tabletBreakpoint) return baseSize;
    return baseSize * 1.1;
  }

  /// Format currency
  static String formatCurrency(double amount) {
    return amount
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]} ',
        )
        .trim();
  }

  /// Format phone number
  static String formatPhoneNumber(String phone) {
    // +998 90 123 45 67
    if (phone.length == 12 && phone.startsWith('+998')) {
      return '${phone.substring(0, 4)} ${phone.substring(4, 6)} ${phone.substring(6, 9)} ${phone.substring(9, 11)} ${phone.substring(11)}';
    }
    return phone;
  }

  /// Get status color
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'paid':
      case 'completed':
        return successColor;
      case 'pending':
      case 'partial':
        return warningColor;
      case 'cancelled':
      case 'expired':
      case 'failed':
        return errorColor;
      default:
        return textSecondaryColor;
    }
  }

  /// Get payment method icon
  static IconData getPaymentMethodIcon(String method) {
    switch (method.toLowerCase()) {
      case 'cash':
        return Icons.money;
      case 'click':
        return Icons.phone_android;
      case 'terminal':
      case 'card':
        return Icons.credit_card;
      case 'owner_fund':
        return Icons.account_balance_wallet;
      case 'bank':
        return Icons.account_balance;
      default:
        return Icons.payment;
    }
  }

  /// Get payment method color
  static Color getPaymentMethodColor(String method) {
    switch (method.toLowerCase()) {
      case 'cash':
        return Colors.green;
      case 'click':
        return Colors.blue;
      case 'terminal':
      case 'card':
        return Colors.purple;
      case 'owner_fund':
        return Colors.orange;
      case 'bank':
        return Colors.indigo;
      default:
        return primaryColor;
    }
  }

  /// Show snackbar
  static void showSnackbar(
    BuildContext context,
    String message, {
    Color? backgroundColor,
    Duration? duration,
    IconData? icon,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white),
              SizedBox(width: paddingSmall),
            ],
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: backgroundColor ?? primaryColor,
        duration: duration ?? Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusSmall),
        ),
      ),
    );
  }

  /// Show error dialog
  static Future<void> showErrorDialog(
    BuildContext context,
    String title,
    String message,
  ) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
        ),
        title: Row(
          children: [
            Icon(Icons.error, color: errorColor),
            SizedBox(width: paddingSmall),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Show success dialog
  static Future<void> showSuccessDialog(
    BuildContext context,
    String title,
    String message,
  ) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
        ),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: successColor),
            SizedBox(width: paddingSmall),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}
