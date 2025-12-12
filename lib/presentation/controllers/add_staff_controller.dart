// lib/presentation/controllers/add_staff_controller.dart

import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/repositories/visitior_repitory.dart';
import 'package:get/get.dart';
import '../../data/repositories/staff_repository.dart';
import '../../config/app_routes.dart';
import 'auth_controller.dart';

class AddStaffController extends GetxController {
  final StaffRepository _staffRepo = StaffRepository();
  final _classRepo = ClassRepository();
  final VisitorRepository _visitorRepo = VisitorRepository();
  final AuthController _authController = Get.find<AuthController>();

  final formKey = GlobalKey<FormState>();

  // ==================== TEXT CONTROLLERS ====================
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final middleNameController = TextEditingController();
  final phoneController = TextEditingController();
  final phoneSecondaryController = TextEditingController();
  final regionController = TextEditingController();
  final districtController = TextEditingController();
  final addressController = TextEditingController();
  final positionController = TextEditingController();
  final departmentController = TextEditingController();
  final skillsController = TextEditingController();
  final educationController = TextEditingController();
  final experienceController = TextEditingController();
  final notesController = TextEditingController();
  final baseSalaryController = TextEditingController();
  final hourlyRateController = TextEditingController();
  final dailyRateController = TextEditingController();
  final expectedHoursController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // ==================== REACTIVE VARIABLES ====================
  final RxString selectedGender = 'male'.obs;
  final Rx<String?> selectedBranchId = Rx<String?>(null);
  final RxString selectedSalaryType = 'monthly'.obs;
  final RxBool isTeacher = false.obs;
  final Rx<DateTime?> birthDate = Rx<DateTime?>(null);
  final Rx<DateTime?> hireDate = Rx<DateTime?>(DateTime.now());
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxBool createUser = false.obs;
  final RxString selectedUserRole = 'teacher'.obs;
  final RxBool showPassword = false.obs;
  final RxBool showConfirmPassword = false.obs;
  final Rx<String?> selectedVisitorId = Rx<String?>(null);
  final RxBool isLoadingVisitors = false.obs;

  // Online ma'lumotlar
  final RxList<Map<String, dynamic>> branches = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> subjects = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> classes = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> rooms = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> visitors = <Map<String, dynamic>>[].obs;

  // O'qituvchi uchun tanlovlar
  final RxList<String> selectedSubjects = <String>[].obs;
  final RxList<String> selectedClasses = <String>[].obs;
  final RxList<String> selectedRooms = <String>[].obs;
  final RxString primarySubject = ''.obs;

  // Boshqa xodimlar uchun
  final RxList<String> selectedResponsibilities = <String>[].obs;
  final RxString workShift = 'day'.obs;

  String? get defaultRoomId {
    if (selectedRooms.isEmpty) return null;
    return selectedRooms.first;
  }

  @override
  void onInit() {
    super.onInit();
    _loadInitialData();
    _setupListeners();
  }

  @override
  void onClose() {
    _disposeControllers();
    super.onClose();
  }

  void _disposeControllers() {
    firstNameController.dispose();
    lastNameController.dispose();
    middleNameController.dispose();
    phoneController.dispose();
    phoneSecondaryController.dispose();
    regionController.dispose();
    districtController.dispose();
    addressController.dispose();
    positionController.dispose();
    departmentController.dispose();
    skillsController.dispose();
    educationController.dispose();
    experienceController.dispose();
    notesController.dispose();
    baseSalaryController.dispose();
    hourlyRateController.dispose();
    dailyRateController.dispose();
    expectedHoursController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
  }

  // ==================== LISTENERS ====================
  void _setupListeners() {
    firstNameController.addListener(_generateUsername);
    lastNameController.addListener(_generateUsername);

    ever(isTeacher, (isTeacherValue) {
      if (createUser.value) {
        selectedUserRole.value = isTeacherValue ? 'teacher' : 'staff';
      }
    });

    ever(createUser, (shouldCreateUser) {
      if (shouldCreateUser) {
        selectedUserRole.value = isTeacher.value ? 'teacher' : 'staff';
        _generateUsername();
        if (passwordController.text.isEmpty) {
          _generatePassword();
        }
      }
    });
  }

  void _generateUsername() {
    if (!createUser.value) return;

    final firstName = firstNameController.text.trim().toLowerCase();
    final lastName = lastNameController.text.trim().toLowerCase();

    if (firstName.isNotEmpty && lastName.isNotEmpty) {
      usernameController.text = '$firstName.$lastName';
    }
  }

  void _generatePassword() {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    String password = '';

    for (int i = 0; i < 8; i++) {
      password += chars[(random + i) % chars.length];
    }

    passwordController.text = password;
    confirmPasswordController.text = password;
  }

  // ==================== MA'LUMOTLARNI YUKLASH ====================
  Future<void> _loadInitialData() async {
    try {
      isLoading.value = true;

      await Future.wait([
        _loadBranches(),
        _loadSubjects(),
        _loadClasses(),
        _loadRooms(),
        _loadVisitors(),
      ]);

      final currentBranchId = _authController.currentUser.value?.branchId;
      if (currentBranchId != null &&
          branches.any((b) => b['id'] == currentBranchId)) {
        selectedBranchId.value = currentBranchId;
      }
    } catch (e) {
      print('Load initial data error: $e');
      Get.snackbar(
        'Xatolik',
        'Ma\'lumotlar yuklanmadi: ${e.toString()}',
        backgroundColor: Colors.red.shade100,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadBranches() async {
    try {
      final result = await _staffRepo.getBranches();
      branches.value = result;
    } catch (e) {
      print('Load branches error: $e');
    }
  }

  Future<void> _loadSubjects() async {
    try {
      final result = await _staffRepo.getSubjects();
      subjects.value = result;
    } catch (e) {
      print('Load subjects error: $e');
    }
  }

  Future<void> _loadClasses() async {
    try {
      final result = await _classRepo.getClassesWithDetails;
      classes.value = result as List<Map<String, dynamic>>;
    } catch (e) {
      print('Load classes error: $e');
    }
  }

  Future<void> _loadRooms() async {
    try {
      final result = await _staffRepo.getRooms();
      rooms.value = result;
    } catch (e) {
      print('Load rooms error: $e');
    }
  }

  Future<void> _loadVisitors() async {
    try {
      isLoadingVisitors.value = true;
      final result = await _visitorRepo.getUnconvertedVisitors();
      visitors.value = result;
    } catch (e) {
      print('Load visitors error: $e');
    } finally {
      isLoadingVisitors.value = false;
    }
  }

  // ==================== TASHRIF BUYURUVCHI TANLASH ====================
  void onVisitorSelected(String? visitorId) {
    selectedVisitorId.value = visitorId;

    if (visitorId != null) {
      final visitor = visitors.firstWhereOrNull((v) => v['id'] == visitorId);
      if (visitor != null) {
        _fillFromVisitor(visitor);
      }
    }
  }

  void _fillFromVisitor(Map<String, dynamic> visitor) {
    firstNameController.text = visitor['first_name'] ?? '';
    lastNameController.text = visitor['last_name'] ?? '';
    middleNameController.text = visitor['middle_name'] ?? '';
    phoneController.text = visitor['phone'] ?? '';
    phoneSecondaryController.text = visitor['phone_secondary'] ?? '';
    regionController.text = visitor['region'] ?? '';
    districtController.text = visitor['district'] ?? '';
    addressController.text = visitor['address'] ?? '';

    if (visitor['gender'] != null) {
      selectedGender.value = visitor['gender'];
    }

    if (visitor['birth_date'] != null) {
      try {
        birthDate.value = DateTime.parse(visitor['birth_date']);
      } catch (e) {
        print('Birth date parse error: $e');
      }
    }

    if (visitor['visitor_type'] == 'employee') {
      positionController.text = visitor['desired_position'] ?? '';
      skillsController.text = visitor['skills'] ?? '';
      educationController.text = visitor['education'] ?? '';
      experienceController.text = visitor['experience'] ?? '';

      if (visitor['desired_salary_min'] != null) {
        baseSalaryController.text = visitor['desired_salary_min'].toString();
      }
    }

    notesController.text = visitor['notes'] ?? '';
  }

  void clearVisitorSelection() {
    selectedVisitorId.value = null;
    _clearForm();
  }

  void _clearForm() {
    firstNameController.clear();
    lastNameController.clear();
    middleNameController.clear();
    phoneController.clear();
    phoneSecondaryController.clear();
    regionController.clear();
    districtController.clear();
    addressController.clear();
    positionController.clear();
    departmentController.clear();
    skillsController.clear();
    educationController.clear();
    experienceController.clear();
    notesController.clear();
    baseSalaryController.clear();
    hourlyRateController.clear();
    dailyRateController.clear();
    expectedHoursController.clear();
    usernameController.clear();
    passwordController.clear();
    confirmPasswordController.clear();

    selectedGender.value = 'male';
    birthDate.value = null;
    hireDate.value = DateTime.now();
    selectedSubjects.clear();
    selectedClasses.clear();
    selectedRooms.clear();
    primarySubject.value = '';
    selectedResponsibilities.clear();
  }

  // ==================== FILIAL O'ZGARGANDA ====================
  void onBranchChanged(String? branchId) {
    selectedBranchId.value = branchId;
    _filterClassesAndRooms();
  }

  void _filterClassesAndRooms() {
    if (selectedBranchId.value != null) {
      selectedClasses.removeWhere((classId) {
        final cls = classes.firstWhereOrNull((c) => c['id'] == classId);
        return cls == null || cls['branch_id'] != selectedBranchId.value;
      });

      selectedRooms.removeWhere((roomId) {
        final room = rooms.firstWhereOrNull((r) => r['id'] == roomId);
        return room == null || room['branch_id'] != selectedBranchId.value;
      });
    }
  }

  List<Map<String, dynamic>> get filteredClasses {
    if (selectedBranchId.value == null) return [];
    return classes
        .where((c) => c['branch_id'] == selectedBranchId.value)
        .toList();
  }

  List<Map<String, dynamic>> get filteredRooms {
    if (selectedBranchId.value == null) return [];
    return rooms
        .where((r) => r['branch_id'] == selectedBranchId.value)
        .toList();
  }

  // ==================== FAN, SINF, XONA TANLASH ====================
  void toggleSubject(String subjectId) {
    if (selectedSubjects.contains(subjectId)) {
      selectedSubjects.remove(subjectId);
      if (primarySubject.value == subjectId) {
        primarySubject.value = '';
      }
    } else {
      selectedSubjects.add(subjectId);
      if (selectedSubjects.length == 1) {
        primarySubject.value = subjectId;
      }
    }
  }

  void setPrimarySubject(String? subjectId) {
    if (subjectId != null && selectedSubjects.contains(subjectId)) {
      primarySubject.value = subjectId;
    }
  }

  void toggleClass(String classId) {
    if (selectedClasses.contains(classId)) {
      selectedClasses.remove(classId);
    } else {
      selectedClasses.add(classId);
    }
  }

  void toggleRoom(String roomId) {
    if (selectedRooms.contains(roomId)) {
      selectedRooms.remove(roomId);
    } else {
      selectedRooms.add(roomId);
    }
  }

  void toggleResponsibility(String responsibility) {
    if (selectedResponsibilities.contains(responsibility)) {
      selectedResponsibilities.remove(responsibility);
    } else {
      selectedResponsibilities.add(responsibility);
    }
  }

  // ==================== SANALARNI TANLASH ====================
  Future<void> selectBirthDate() async {
    final picked = await showDatePicker(
      context: Get.context!,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 25)),
      firstDate: DateTime(1960),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      birthDate.value = picked;
    }
  }

  Future<void> selectHireDate() async {
    final picked = await showDatePicker(
      context: Get.context!,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) {
      hireDate.value = picked;
    }
  }

  // ==================== VALIDATION ====================
  bool _validateForm() {
    if (!formKey.currentState!.validate()) {
      Get.snackbar(
        'Xatolik',
        'Iltimos, barcha majburiy maydonlarni to\'ldiring',
        backgroundColor: Colors.red.shade100,
        snackPosition: SnackPosition.TOP,
      );
      return false;
    }

    if (birthDate.value == null) {
      Get.snackbar(
        'Xatolik',
        'Tug\'ilgan sanani tanlang',
        backgroundColor: Colors.red.shade100,
        snackPosition: SnackPosition.TOP,
      );
      return false;
    }

    if (selectedBranchId.value == null) {
      Get.snackbar(
        'Xatolik',
        'Filialni tanlang',
        backgroundColor: Colors.red.shade100,
        snackPosition: SnackPosition.TOP,
      );
      return false;
    }

    if (isTeacher.value) {
      if (selectedSubjects.isEmpty) {
        Get.snackbar(
          'Xatolik',
          'Kamida bitta fanni tanlang',
          backgroundColor: Colors.red.shade100,
          snackPosition: SnackPosition.TOP,
        );
        return false;
      }
      if (primarySubject.value.isEmpty) {
        Get.snackbar(
          'Xatolik',
          'Asosiy fanni tanlang',
          backgroundColor: Colors.red.shade100,
          snackPosition: SnackPosition.TOP,
        );
        return false;
      }
    }

    if (createUser.value) {
      if (usernameController.text.trim().isEmpty) {
        Get.snackbar(
          'Xatolik',
          'Username kiriting',
          backgroundColor: Colors.red.shade100,
          snackPosition: SnackPosition.TOP,
        );
        return false;
      }

      if (passwordController.text.isEmpty) {
        Get.snackbar(
          'Xatolik',
          'Parol kiriting',
          backgroundColor: Colors.red.shade100,
          snackPosition: SnackPosition.TOP,
        );
        return false;
      }

      if (passwordController.text.length < 6) {
        Get.snackbar(
          'Xatolik',
          'Parol kamida 6 ta belgidan iborat bo\'lishi kerak',
          backgroundColor: Colors.red.shade100,
          snackPosition: SnackPosition.TOP,
        );
        return false;
      }

      if (passwordController.text != confirmPasswordController.text) {
        Get.snackbar(
          'Xatolik',
          'Parollar mos kelmaydi',
          backgroundColor: Colors.red.shade100,
          snackPosition: SnackPosition.TOP,
        );
        return false;
      }
    }

    return true;
  }

  // ==================== XODIMNI SAQLASH ====================
  Future<void> saveStaff() async {
    if (!_validateForm()) return;

    final currentUserId = _authController.currentUser.value?.id;
    if (currentUserId == null) {
      Get.snackbar(
        'Xatolik',
        'Foydalanuvchi ma\'lumotlari aniqlanmadi',
        backgroundColor: Colors.red.shade100,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    try {
      isSaving.value = true;

      final salaryData = _calculateSalary();
      String? userId;

      if (createUser.value) {
        userId = await _createUser();
        if (userId == null) {
          throw Exception('User yaratishda xatolik yuz berdi');
        }
      }

      final staff = await _staffRepo.createStaff(
        userId: userId,
        branchId: selectedBranchId.value!,
        visitorId: selectedVisitorId.value,
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        middleName: middleNameController.text.trim(),
        gender: selectedGender.value,
        birthDate: birthDate.value!,
        phone: phoneController.text.trim(),
        phoneSecondary: phoneSecondaryController.text.trim(),
        region: regionController.text.trim(),
        district: districtController.text.trim(),
        address: addressController.text.trim(),
        position: positionController.text.trim(),
        department: departmentController.text.trim(),
        isTeacher: isTeacher.value,
        salaryType: selectedSalaryType.value,
        baseSalary: salaryData['baseSalary'],
        hourlyRate: salaryData['hourlyRate'],
        dailyRate: salaryData['dailyRate'],
        expectedHoursPerMonth: salaryData['expectedHours'],
        hireDate: hireDate.value!,
        skills: skillsController.text.trim(),
        education: educationController.text.trim(),
        experience: experienceController.text.trim(),
        notes: notesController.text.trim(),
        createdBy: currentUserId,
        defaultRoomId: defaultRoomId,
      );

      if (staff == null) {
        throw Exception('Xodim yaratishda xatolik');
      }

      if (isTeacher.value) {
        await _assignTeacherData(staff.id);
      }

      if (selectedVisitorId.value != null) {
        await _visitorRepo.convertVisitorToStaff(
          visitorId: selectedVisitorId.value!,
          staffId: staff.id,
        );
      }

      _showSuccessMessage(userId);
      Get.offNamed(AppRoutes.staff);
    } catch (e) {
      print('Save staff error: $e');
      Get.snackbar(
        'Xatolik',
        'Xodimni saqlashda xatolik: ${e.toString()}',
        backgroundColor: Colors.red.shade100,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 5),
      );
    } finally {
      isSaving.value = false;
    }
  }

  Map<String, dynamic> _calculateSalary() {
    double? baseSalary;
    double? hourlyRate;
    double? dailyRate;
    int? expectedHours;

    if (selectedSalaryType.value == 'monthly') {
      baseSalary = double.tryParse(
        baseSalaryController.text.replaceAll(',', ''),
      );
      if (baseSalary == null) {
        throw Exception('Noto\'g\'ri oylik maosh miqdori');
      }
    } else if (selectedSalaryType.value == 'hourly') {
      hourlyRate = double.tryParse(
        hourlyRateController.text.replaceAll(',', ''),
      );
      if (hourlyRate == null) {
        throw Exception('Noto\'g\'ri soatlik maosh miqdori');
      }
      if (expectedHoursController.text.isNotEmpty) {
        expectedHours = int.tryParse(expectedHoursController.text);
      }
    } else {
      dailyRate = double.tryParse(dailyRateController.text.replaceAll(',', ''));
      if (dailyRate == null) {
        throw Exception('Noto\'g\'ri kunlik maosh miqdori');
      }
    }

    return {
      'baseSalary': baseSalary,
      'hourlyRate': hourlyRate,
      'dailyRate': dailyRate,
      'expectedHours': expectedHours,
    };
  }

  Future<String?> _createUser() async {
    try {
      final userId = await _staffRepo.createUser(
        branchId: selectedBranchId.value!,
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        middleName: middleNameController.text.trim(),
        gender: selectedGender.value,
        birthDate: birthDate.value!,
        phone: phoneController.text.trim(),
        phoneSecondary: phoneSecondaryController.text.trim(),
        region: regionController.text.trim(),
        district: districtController.text.trim(),
        address: addressController.text.trim(),
        username: usernameController.text.trim(),
        password: passwordController.text,
        role: selectedUserRole.value,
      );

      return userId;
    } catch (e) {
      print('Create user error: $e');
      rethrow;
    }
  }

  Future<void> _assignTeacherData(String staffId) async {
    for (var subjectId in selectedSubjects) {
      await _staffRepo.assignSubjectToTeacher(
        staffId: staffId,
        subjectId: subjectId,
        isPrimary: subjectId == primarySubject.value,
      );
    }

    for (var classId in selectedClasses) {
      final subjectId = primarySubject.value.isNotEmpty
          ? primarySubject.value
          : selectedSubjects.first;

      await _staffRepo.assignTeacherToClass(
        staffId: staffId,
        classId: classId,
        subjectId: subjectId,
      );
    }
  }

  void _showSuccessMessage(String? userId) {
    String message = 'Xodim muvaffaqiyatli qo\'shildi';

    if (userId != null) {
      message += '\n\nKirish ma\'lumotlari:';
      message += '\nUsername: ${usernameController.text}';
      message += '\nParol: ${passwordController.text}';
      message += '\n\nIltimos, bu ma\'lumotlarni xavfsiz saqlang!';
    }

    Get.snackbar(
      'Muvaffaqiyatli',
      message,
      backgroundColor: const Color(0xFF2196F3).withOpacity(0.1),
      colorText: const Color(0xFF2196F3),
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 8),
      icon: const Icon(Icons.check_circle, color: Color(0xFF2196F3)),
    );
  }

  // ==================== YORDAMCHI FUNKSIYALAR ====================
  String getSubjectName(String id) {
    final subject = subjects.firstWhereOrNull((s) => s['id'] == id);
    return subject?['name'] ?? 'Noma\'lum fan';
  }

  String getClassName(String id) {
    final cls = classes.firstWhereOrNull((c) => c['id'] == id);
    return cls?['name'] ?? 'Noma\'lum sinf';
  }

  String getRoomName(String id) {
    final room = rooms.firstWhereOrNull((r) => r['id'] == id);
    return room?['name'] ?? 'Noma\'lum xona';
  }

  String getBranchName(String id) {
    final branch = branches.firstWhereOrNull((b) => b['id'] == id);
    return branch?['name'] ?? 'Noma\'lum filial';
  }

  String getVisitorName(String id) {
    final visitor = visitors.firstWhereOrNull((v) => v['id'] == id);
    if (visitor == null) return 'Noma\'lum';
    return '${visitor['first_name']} ${visitor['last_name']}';
  }
}
