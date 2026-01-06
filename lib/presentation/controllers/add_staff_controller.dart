// lib/presentation/controllers/add_staff_controller.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/repositories/staff_repository.dart';
import '../../data/repositories/visitior_repitory.dart'; // Asl kodingizdagi nom
import '../../data/repositories/class_repository.dart' hide ClassRepository; // Asl kodingizdagi nom
import '../../config/app_routes.dart';
import 'auth_controller.dart';

class AddStaffController extends GetxController {
  final StaffRepository _staffRepo = StaffRepository();
  final _classRepo = ClassRepository();
  final VisitorRepository _visitorRepo = VisitorRepository();
  final AuthController _authController = Get.find<AuthController>();

  final formKey = GlobalKey<FormState>();

  // ==================== YANGI QO'SHILGAN: ROLLAR RO'YXATI ====================
  // Database qiymati -> UI da ko'rinadigan nom
  final Map<String, String> userRoles = {
    'teacher': "O'qituvchi",
    'admin': "Qabulxona", // Aslida admin, lekin UI da Qabulxona
    'manager': "Kassir", // Aslida manager, lekin UI da Kassir
    'director': "Direktor",
    'owner': "Ta'sischi (Rahbar)",
    'staff': "Xodim",
  };
  // =========================================================================

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

  final Rx<File?> profileImage = Rx<File?>(null);
  final ImagePicker _picker = ImagePicker();

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

  // Default rol - O'qituvchi
  final RxString selectedUserRole = 'teacher'.obs;

  final RxBool showPassword = false.obs;
  final RxBool showConfirmPassword = false.obs;
  final Rx<String?> selectedVisitorId = Rx<String?>(null);
  final RxBool isLoadingVisitors = false.obs;

  // --- TAHRIRLASH UCHUN ---
  final RxBool isEditMode = false.obs;
  String? editingStaffId;
  final _supabase = Supabase.instance.client;

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

    if (Get.arguments != null && Get.arguments['isEdit'] == true) {
      isEditMode.value = true;
      editingStaffId = Get.arguments['staffId'];
      createUser.value = false;

      Future.delayed(const Duration(seconds: 1), () {
        if (editingStaffId != null) {
          _loadStaffForEditing(editingStaffId!);
        }
      });
    }
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

  // ==================== LISTENERS (O'ZGARTIRILGAN QISM) ====================
  void _setupListeners() {
    firstNameController.addListener(_generateUsername);
    lastNameController.addListener(_generateUsername);

    ever(isTeacher, (isTeacherValue) {
      if (createUser.value) {
        // Agar o'qituvchi bo'lsa 'teacher', bo'lmasa 'admin' (Qabulxona)
        // 'staff' olib tashlandi
        selectedUserRole.value = isTeacherValue ? 'teacher' : 'admin';
      }
    });

    // Agar User Roli dropdown orqali o'zgarsa, isTeacher ni moslash
    ever(selectedUserRole, (String role) {
      if (role == 'teacher') {
        isTeacher.value = true;
      } else {
        isTeacher.value = false;
      }
    });

    ever(createUser, (shouldCreateUser) {
      if (shouldCreateUser) {
        selectedUserRole.value = isTeacher.value ? 'teacher' : 'admin';
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
  Future<void> _loadStaffForEditing(String id) async {
    try {
      isLoading.value = true;
      print("Tahrirlash uchun yuklanmoqda: $id");

      final data = await _supabase.from('staff').select().eq('id', id).single();

      firstNameController.text = data['first_name'] ?? '';
      lastNameController.text = data['last_name'] ?? '';
      middleNameController.text = data['middle_name'] ?? '';
      phoneController.text = data['phone'] ?? '';
      phoneSecondaryController.text = data['phone_secondary'] ?? '';
      regionController.text = data['region'] ?? '';
      districtController.text = data['district'] ?? '';
      addressController.text = data['address'] ?? '';
      positionController.text = data['position'] ?? '';
      departmentController.text = data['department'] ?? '';
      skillsController.text = data['skills'] ?? '';
      educationController.text = data['education'] ?? '';
      experienceController.text = data['experience'] ?? '';
      notesController.text = data['notes'] ?? '';

      if (data['branch_id'] != null) {
        selectedBranchId.value = data['branch_id'];
        _filterClassesAndRooms();
      }

      selectedGender.value = data['gender'] ?? 'male';

      if (data['birth_date'] != null) {
        birthDate.value = DateTime.parse(data['birth_date']);
      }
      if (data['hire_date'] != null) {
        hireDate.value = DateTime.parse(data['hire_date']);
      }

      selectedSalaryType.value = data['salary_type'] ?? 'monthly';
      if (data['base_salary'] != null)
        baseSalaryController.text = data['base_salary'].toString();
      if (data['hourly_rate'] != null)
        hourlyRateController.text = data['hourly_rate'].toString();
      if (data['daily_rate'] != null)
        dailyRateController.text = data['daily_rate'].toString();
      if (data['expected_hours_per_month'] != null)
        expectedHoursController.text = data['expected_hours_per_month']
            .toString();

      isTeacher.value = data['is_teacher'] ?? false;
    } catch (e) {
      print("Tahrirlash xatosi: $e");
      Get.snackbar('Xatolik', 'Ma\'lumotlarni yuklab bo\'lmadi');
    } finally {
      isLoading.value = false;
    }
  }

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
      if (selectedBranchId.value == null) {
        classes.value = [];
        return;
      }
      final result = await _classRepo.getClassesWithDetails(
        selectedBranchId.value!,
      );
      classes.value = List<Map<String, dynamic>>.from(result);
    } catch (e) {
      print('Load classes error: $e');
      classes.value = [];
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

  Future<void> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );
      if (image != null) {
        profileImage.value = File(image.path);
      }
    } catch (e) {
      Get.snackbar('Xatolik', 'Rasm tanlashda xatolik: $e');
    }
  }

  Future<void> _loadVisitors() async {
    try {
      isLoadingVisitors.value = true;
      final result = await _visitorRepo.getUnconvertedVisitors();
      visitors.value = result ?? [];
    } catch (e) {
      print('Load visitors error: $e');
      visitors.value = [];
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
   // ==================== XODIMNI SAQLASH ====================
  Future<void> saveStaff() async {
    // 1. Validatsiya
    if (!_validateForm()) return;

    final currentUserId = _authController.currentUser.value?.id;
    if (currentUserId == null) {
      Get.snackbar('Xatolik', 'Tizimga qayta kiring');
      return;
    }

    try {
      isSaving.value = true;

      // 2. Rasm yuklash (agar yangi rasm tanlangan bo'lsa)
      String? uploadedPhotoUrl;
      if (profileImage.value != null) {
        uploadedPhotoUrl = await _staffRepo.uploadProfileImage(
          profileImage.value!,
        );
      }

      // 3. Maosh ma'lumotlarini hisoblash
      final salaryData = _calculateSalary();

      // ---------------------------------------------------------
      // A. TAHRIRLASH REJIMI (UPDATE)
      // ---------------------------------------------------------
      if (isEditMode.value && editingStaffId != null) {
        
        String? newUserId;
        
        // --- MUHIM TUZATISH: Tahrirlash paytida User yaratish ---
        if (createUser.value) {
          // Yangi user yaratamiz (Login/Parol bilan)
          newUserId = await _createUser(); 
          if (newUserId == null) throw Exception('Foydalanuvchi yaratilmadi');
          
          // Muvaffaqiyatli xabar ko'rsatamiz (Login/Parolni eslab qolish uchun)
          _showSuccessMessage(newUserId);
        }

        // Update uchun ma'lumotlarni yig'amiz
        final updateData = {
          'branch_id': selectedBranchId.value,
          'first_name': firstNameController.text.trim(),
          'last_name': lastNameController.text.trim(),
          'middle_name': middleNameController.text.trim(),
          'gender': selectedGender.value,
          'birth_date': birthDate.value!.toIso8601String(),
          'phone': phoneController.text.trim(),
          'phone_secondary': phoneSecondaryController.text.trim(),
          'region': regionController.text.trim(),
          'district': districtController.text.trim(),
          'address': addressController.text.trim(),
          'position': positionController.text.trim(),
          'department': departmentController.text.trim(),
          'is_teacher': isTeacher.value,
          'salary_type': selectedSalaryType.value,
          'base_salary': salaryData['baseSalary'],
          'hourly_rate': salaryData['hourlyRate'],
          'daily_rate': salaryData['dailyRate'],
          'expected_hours_per_month': salaryData['expectedHours'],
          'hire_date': hireDate.value!.toIso8601String(),
          'skills': skillsController.text.trim(),
          'education': educationController.text.trim(),
          'experience': experienceController.text.trim(),
          'notes': notesController.text.trim(),
          'updated_at': DateTime.now().toIso8601String(),
        };

        // Agar yangi User yaratilgan bo'lsa, uni staffga bog'laymiz
        if (newUserId != null) {
          updateData['user_id'] = newUserId;
        }

        // Agar rasm yangilangan bo'lsa, uni ham qo'shamiz
        if (uploadedPhotoUrl != null) {
          updateData['photo_url'] = uploadedPhotoUrl;
        }

        // Bazani yangilash
        await _supabase
            .from('staff')
            .update(updateData)
            .eq('id', editingStaffId!);

        // Agar o'qituvchi bo'lsa, fanlarni qayta biriktirish mantig'ini
        // shu yerga qo'shish mumkin (hozircha shart emas deb hisoblaymiz)

        Get.snackbar(
          'Muvaffaqiyat',
          'Xodim ma\'lumotlari yangilandi',
          backgroundColor: Colors.green.shade100,
        );

        // Ortga qaytish va yangilanganligini bildirish
        Get.back(result: true);
      }
      
      // ---------------------------------------------------------
      // B. YANGI QO'SHISH REJIMI (CREATE)
      // ---------------------------------------------------------
      else {
        String? userId;
        // Agar foydalanuvchi yaratish kerak bo'lsa
        if (createUser.value) {
          userId = await _createUser();
          if (userId == null) throw Exception('User yaratilmadi');
        }

        // Staff yaratish (Repository orqali)
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
          photoUrl: uploadedPhotoUrl,
        );

        // Agar o'qituvchi bo'lsa, fanlar va sinflarni biriktirish
        if (staff != null && isTeacher.value) {
          await _assignTeacherData(staff.id);
        }

        // Muvaffaqiyat xabari
        _showSuccessMessage(userId);
        
        // Ro'yxat sahifasiga qaytish
        Get.offNamed(AppRoutes.staff);
      }
    } catch (e) {
      print('Save staff error: $e');
      Get.snackbar(
        'Xatolik',
        'Saqlashda xatolik yuz berdi: ${e.toString()}',
        backgroundColor: Colors.red.shade100,
        duration: const Duration(seconds: 4),
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

  // ==================== USER YARATISH (O'ZGARTIRILGAN QISM) ====================
  Future<String?> _createUser() async {
    try {
      print('🚀 User yaratish boshlandi...');
      print('Username: ${usernameController.text}');
      print('Role: ${selectedUserRole.value}');

      // Validatsiya: Rol ro'yxatda bormi?
      if (!userRoles.containsKey(selectedUserRole.value)) {
        throw Exception("Noto'g'ri rol tanlandi");
      }

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

      print('✅ User muvaffaqiyatli yaratildi: $userId');
      return userId;
    } catch (e) {
      print('❌ USER YARATISHDA XATO: $e');

      final errorMsg = e.toString().toLowerCase();

      // 1. Username band bo'lsa
      if (errorMsg.contains('users_username_key') ||
          errorMsg.contains('duplicate key')) {
        throw Exception(
          "Bunday username ('${usernameController.text}') band! Iltimos, username oxiriga raqam qo'shing.",
        );
      }

      // 2. Telefon raqam uzun bo'lsa
      if (errorMsg.contains('value too long') ||
          errorMsg.contains('string data right truncation')) {
        throw Exception(
          "Telefon raqam yoki boshqa ma'lumot juda uzun (limit 20 ta). SQL dan limitni oshiring!",
        );
      }

      // 3. Rol xato bo'lsa (enum type mismatch)
      if (errorMsg.contains('invalid input value for enum')) {
        throw Exception("Rol noto'g'ri tanlandi: ${selectedUserRole.value}");
      }

      // Boshqa xatolar
      throw Exception('Tizim xatosi: $errorMsg');
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
