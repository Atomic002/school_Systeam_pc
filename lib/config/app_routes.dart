// lib/config/app_routes.dart
// YANGILANGAN - Subjects, ClassLevels, TeacherSubjects route'lari qo'shildi

import 'package:flutter_application_1/presentation/screens/Branchs/add_branch_screen.dart';
import 'package:flutter_application_1/presentation/screens/Branchs/branch_detail_screen.dart';
import 'package:flutter_application_1/presentation/screens/Branchs/branch_list_screen.dart';
import 'package:flutter_application_1/presentation/screens/Expenses/expenses_screen.dart';
import 'package:flutter_application_1/presentation/screens/Salary/SalaryScreen.dart';
import 'package:flutter_application_1/presentation/screens/Schedule/schedule_screen.dart';
import 'package:flutter_application_1/presentation/screens/StaffAttendance/staff_attendance_screen.dart';
import 'package:flutter_application_1/presentation/screens/StaffDetail/staff_detail_screen.dart';
import 'package:flutter_application_1/presentation/screens/StaffList/staff_list_screen.dart';
import 'package:flutter_application_1/presentation/screens/StudentAttendance/student_attendance_screen.dart';
import 'package:flutter_application_1/presentation/screens/Visitors/visitors_screen.dart';
import 'package:flutter_application_1/presentation/screens/add_staff/add_staf_screen.dart';
import 'package:flutter_application_1/presentation/screens/class/Room_deteil/add_room_screen.dart';
import 'package:flutter_application_1/presentation/screens/class/Room_deteil/room_deteil_screen.dart';
import 'package:flutter_application_1/presentation/screens/class/add_class_screen/room_and_class_screen.dart';
import 'package:flutter_application_1/presentation/screens/class/class_screen/add_class_screen.dart';
import 'package:flutter_application_1/presentation/screens/class/class_screen/class_level_screen.dart';
import 'package:flutter_application_1/presentation/screens/class/class_screen/class_screen.dart';
import 'package:flutter_application_1/presentation/screens/class/subjacts/subjacts_screen.dart';
import 'package:flutter_application_1/presentation/screens/class/subjacts/teacher_subjckts_screens.dart';
import 'package:flutter_application_1/presentation/screens/finance/cash_register_screen.dart';
import 'package:flutter_application_1/presentation/screens/payment/Payments_screen.dart';
import 'package:flutter_application_1/presentation/screens/settings/academic_years_screen.dart';
import 'package:flutter_application_1/presentation/screens/settings/system_settings_screen.dart';

import 'package:get/get.dart';
import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/dashboard/dashboard_screen.dart';
import '../presentation/screens/finance/finance_screen.dart';
import '../presentation/screens/students/students_list_screen.dart';
import '../presentation/screens/students/student_detail_screen.dart';
import '../presentation/screens/students/add_student_screen.dart';

class AppRoutes {
  // ==================== MARSHRUT NOMLARI ====================

  // Autentifikatsiya
  static const String login = '/login';

  // Asosiy sahifalar
  static const String dashboard = '/dashboard';

  // Moliya bo'limi
  static const String finance = '/finance';
  static const String cashRegister = '/cash-register';
  static const String payments = '/payments';
  static const String expenses = '/expenses';
  static const String salary = '/salary';

  // O'quvchilar bo'limi
  static const String students = '/students';
  static const String studentDetail = '/student-detail';
  static const String addStudent = '/add-student';
  static const String visitors = '/visitors';

  // Sinflar bo'limi
  static const String addClass = '/add-class';
  static const String roomsAndClasses = '/rooms-classes';
  static const String roomDetail = '/room-detail';
  static const String addRoom = '/add-room';
  static const String classDetail = '/class-detail';

  // Xodimlar bo'limi
  static const String staff = '/staff';
  static const String staffDetail = '/staff-detail';
  static const String addStaff = '/add-staff';

  // Davomat bo'limi
  static const String studentAttendance = '/student-attendance';
  static const String staffAttendance = '/staff-attendance';

  // Dars jadvali
  static const String schedule = '/schedule';

  // Filiallar bo'limi
  static const String branches = '/branches';
  static const String addBranch = '/add-branch';
  static const String branchDetail = '/branch-detail';

  // YANGI: O'quv jarayoni boshqaruvi
  static const String subjects = '/subjects';
  static const String classLevels = '/class-levels';
  static const String teacherSubjects = '/teacher-subjects';

    // Sozlamalar bo'limi
  static const String settings = '/settings';
  static const String systemSettings = '/system-settings';
  static const String academicYears = '/academic-years';

  // ==================== BARCHA MARSHRУТLAR RO'YXATI ====================
  static final routes = [
    // ------ AUTHENTICATION ------
    GetPage(
      name: login,
      page: () => LoginScreen(),
      transition: Transition.fadeIn,
      transitionDuration: Duration(milliseconds: 300),
    ),

    // ------ DASHBOARD ------
    GetPage(
      name: dashboard,
      page: () => DashboardScreen(),
      transition: Transition.fade,
      transitionDuration: Duration(milliseconds: 200),
    ),

    // ------ FINANCE ------
    GetPage(
      name: finance,
      page: () => AdvancedFinanceScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: Duration(milliseconds: 300),
    ),
    GetPage(
      name: cashRegister,
      page: () => AdvancedCashRegisterScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: Duration(milliseconds: 300),
    ),
    GetPage(
      name: payments,
      page: () => NewPaymentScreenV4(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: expenses,
      page: () => ExpensesScreenV2(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: salary,
      page: () => SalaryScreen(),
      transition: Transition.rightToLeft,
    ),

    // ------ STUDENTS ------
    GetPage(
      name: students,
      page: () => StudentsListScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: Duration(milliseconds: 300),
    ),
    GetPage(
      name: studentDetail,
      page: () => StudentDetailScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: Duration(milliseconds: 300),
    ),
    GetPage(
      name: addStudent,
      page: () => AddStudentScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: Duration(milliseconds: 300),
    ),
    GetPage(
      name: visitors,
      page: () => VisitorsScreen(),
      transition: Transition.rightToLeft,
    ),

    // ------ CLASSES ------
    GetPage(
      name: addClass,
      page: () => AddClassScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: Duration(milliseconds: 300),
    ),
    GetPage(
      name: roomsAndClasses,
      page: () => RoomsAndClassesScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: Duration(milliseconds: 300),
    ),
    GetPage(
      name: roomDetail,
      page: () => RoomDetailScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: Duration(milliseconds: 300),
    ),
    GetPage(
      name: addRoom,
      page: () => AddRoomScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: Duration(milliseconds: 300),
    ),
    GetPage(
      name: classDetail,
      page: () => ClassDetailScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: Duration(milliseconds: 300),
    ),

    // ------ STAFF ------
    GetPage(
      name: addStaff,
      page: () => AddStaffScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: staff,
      page: () => ModernStaffScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: staffDetail,
      page: () => StaffDashboardScreen(),
      transition: Transition.rightToLeft,
    ),

    // ------ ATTENDANCE ------
    GetPage(
      name: studentAttendance,
      page: () => StudentAttendanceScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: staffAttendance,
      page: () => StaffAttendanceScreen(),
      transition: Transition.rightToLeft,
    ),

    // ------ SCHEDULE ------
    GetPage(
      name: schedule,
      page: () => ScheduleScreen(),
      transition: Transition.rightToLeft,
    ),

    // ------ BRANCHES ------
    GetPage(
      name: branches,
      page: () => BranchesListScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: Duration(milliseconds: 300),
    ),
    GetPage(
      name: addBranch,
      page: () => AddBranchScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: Duration(milliseconds: 300),
    ),
    GetPage(
      name: branchDetail,
      page: () => BranchDetailScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: Duration(milliseconds: 300),
    ),

    // ------ ACADEMIC MANAGEMENT (YANGI) ------
    GetPage(
      name: subjects,
      page: () => SubjectsScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: Duration(milliseconds: 300),
    ),
    GetPage(
      name: classLevels,
      page: () => ClassLevelsScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: Duration(milliseconds: 300),
    ),
    GetPage(
      name: teacherSubjects,
      page: () => TeacherSubjectsScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: Duration(milliseconds: 300),
    ),
     // ------ SETTINGS ------


    GetPage(
      name: systemSettings,
      page: () => SystemSettingsScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: Duration(milliseconds: 300),
    ),
    GetPage(
      name: academicYears,
      page: () => AcademicYearsScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: Duration(milliseconds: 300),
    ),
  ];
}
