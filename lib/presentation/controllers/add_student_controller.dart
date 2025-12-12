// lib/controllers/add_student_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

import '../../data/repositories/student_repositry.dart';
import '../../data/repositories/visitior_repitory.dart';
import '../../data/repositories/branch_repository.dart';
import '../../config/app_routes.dart';
import 'auth_controller.dart';

class AddStudentController extends GetxController {
  final StudentRepository _studentRepo = StudentRepository();
  final VisitorRepository _visitorRepo = VisitorRepository();
  final ClassRepository _classRepo = ClassRepository();
  final BranchRepository _branchRepo = BranchRepository();
  final AuthController _authController = Get.find<AuthController>();
  final ImagePicker _imagePicker = ImagePicker();

  final formKey = GlobalKey<FormState>();

  // O'QUVCHI MA'LUMOTLARI
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final middleNameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final regionController = TextEditingController();
  final districtController = TextEditingController();
  final RxString selectedGender = 'male'.obs;
  final Rx<DateTime?> birthDate = Rx<DateTime?>(null);

  // RASM
  final Rx<File?> selectedImage = Rx<File?>(null);
  final RxString photoUrl = ''.obs;

  // OTA-ONA MA'LUMOTLARI
  final parentFirstNameController = TextEditingController();
  final parentLastNameController = TextEditingController();
  final parentMiddleNameController = TextEditingController();
  final parentPhoneController = TextEditingController();
  final parentPhone2Controller = TextEditingController();
  final parentWorkplaceController = TextEditingController();
  final RxString parentRelation = 'Otasi'.obs;

  // MOLIYAVIY
  final monthlyFeeController = TextEditingController(text: '900000');
  final discountPercentController = TextEditingController(text: '0');
  final discountAmountController = TextEditingController(text: '0');
  final discountReasonController = TextEditingController();
  final RxDouble finalMonthlyFee = 900000.0.obs;

  // QO'SHIMCHA
  final notesController = TextEditingController();
  final medicalNotesController = TextEditingController();

  // FILIAL
  final RxList<Map<String, dynamic>> branches = <Map<String, dynamic>>[].obs;
  final RxnString selectedBranchId = RxnString(null);
  final RxString selectedBranchName = ''.obs;
  final RxBool showBranchSelector = true.obs;

  // VISITOR
  final RxList<dynamic> visitors = <dynamic>[].obs;
  final Rx<String?> selectedVisitorId = Rx<String?>(null);

  // SINF MA'LUMOTLARI
  final RxList<Map<String, dynamic>> classLevels = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> classes = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> filteredClasses =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> teachers = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> rooms = <Map<String, dynamic>>[].obs;

  // TANLANGAN QIYMATLAR
  final Rx<String?> selectedClassLevelId = Rx<String?>(null);
  final Rx<String?> selectedClassId = Rx<String?>(null);
  final Rx<String?> selectedTeacherId = Rx<String?>(null);
  final Rx<String?> selectedRoomId = Rx<String?>(null);

  // KO'RINADIGAN MA'LUMOTLAR
  final RxString selectedClassRoom = ''.obs;
  final RxString selectedTeacherName = ''.obs;
  final RxString selectedClassName = ''.obs;

  final RxString selectionMode = 'class'.obs; // 'class', 'teacher', 'room'

  // HOLATLAR
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxBool isUploadingImage = false.obs;

  get selectedMainTeacherName => null;

  @override
  void onInit() {
    super.onInit();
    _initialize();
  }

  @override
  void onClose() {
    _disposeControllers();
    super.onClose();
  }

  Future<void> _initialize() async {
    try {
      isLoading.value = true;
      await fetchBranches();

      if (branches.length == 1) {
        await selectBranch(branches.first['id']);
      }
    } catch (e) {
      _showError('Initialization error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void _disposeControllers() {
    firstNameController.dispose();
    lastNameController.dispose();
    middleNameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    regionController.dispose();
    districtController.dispose();
    parentFirstNameController.dispose();
    parentLastNameController.dispose();
    parentMiddleNameController.dispose();
    parentPhoneController.dispose();
    parentPhone2Controller.dispose();
    parentWorkplaceController.dispose();
    monthlyFeeController.dispose();
    discountPercentController.dispose();
    discountAmountController.dispose();
    discountReasonController.dispose();
    notesController.dispose();
    medicalNotesController.dispose();
  }

  // ========== FILIAL ==========
  Future<void> fetchBranches() async {
    try {
      final currentUser = _authController.currentUser.value;
      if (currentUser == null) {
        _showError('Xatolik', 'Foydalanuvchi ma\'lumotlari topilmadi');
        return;
      }

      final role = currentUser.role;
      List<Map<String, dynamic>> branchesList;

      if (role == 'owner' || role == 'admin') {
        branchesList = await _branchRepo.getAllBranches();
      } else {
        branchesList = await _branchRepo.getUserBranches(currentUser.id);
      }

      branches.value = branchesList;
      await _loadSavedBranch();
    } catch (e) {
      _showError('Xatolik', 'Filiallarni yuklashda xatolik: ${e.toString()}');
    }
  }

  Future<void> _loadSavedBranch() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedBranchId = prefs.getString('selected_branch_id');

      if (savedBranchId != null &&
          branches.any((b) => b['id'] == savedBranchId)) {
        await selectBranch(savedBranchId, showMessage: false);
      } else if (branches.isNotEmpty) {
        showBranchSelector.value = true;
      }
    } catch (e) {
      print('Load saved branch error: $e');
    }
  }

  Future<void> selectBranch(String? branchId, {bool showMessage = true}) async {
    if (branchId == null || branchId.isEmpty) return;

    try {
      isLoading.value = true;
      showBranchSelector.value = false;

      selectedBranchId.value = branchId;
      selectedBranchName.value = _getBranchName(branchId);

      await _saveBranch(branchId);
      await _loadBranchData(branchId);

      if (showMessage) {
        Get.snackbar(
          'Muvaffaqiyatli',
          '${selectedBranchName.value} fililiga o\'tildi',
          backgroundColor: const Color(0xFF2196F3).withOpacity(0.1),
          colorText: const Color(0xFF2196F3),
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      _showError('Xatolik', 'Filialni tanlashda xatolik: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  void changeBranch() {
    showBranchSelector.value = true;
    _clearForm();
  }

  String _getBranchName(String? branchId) {
    if (branchId == null) return '';
    try {
      final branch = branches.firstWhere(
        (b) => b['id'] == branchId,
        orElse: () => <String, dynamic>{},
      );
      return branch['name'] ?? '';
    } catch (e) {
      return '';
    }
  }

  Future<void> _saveBranch(String branchId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selected_branch_id', branchId);
    } catch (e) {
      print('Save branch error: $e');
    }
  }

  // AddStudentController ichidagi load metodlarini to'g'rilang:

  Future<void> _loadBranchData(String branchId) async {
    try {
      print('🔄 ========== LOADING BRANCH DATA ==========');
      print('Branch ID: $branchId');

      await Future.wait([
        _loadVisitors(branchId),
        _loadClassLevels(),
        _loadClasses(branchId),
        _loadTeachers(branchId),
        _loadRooms(branchId),
      ]);

      print('✅ ========== BRANCH DATA LOADED ==========');
      print('📊 Class Levels: ${classLevels.length}');
      print('📊 Classes: ${classes.length}');
      print('📊 Teachers: ${teachers.length}');
      print('📊 Rooms: ${rooms.length}');
      print('📊 Visitors: ${visitors.length}');
      print('============================================');
    } catch (e) {
      print('❌ _loadBranchData error: $e');
      _showError('Xatolik', 'Filial ma\'lumotlarini yuklashda xatolik');
    }
  }

  Future<void> _loadClassLevels() async {
    try {
      print('🔄 Loading class levels...');
      final result = await _classRepo.getClassLevels();
      classLevels.value = result;
      print('✅ Loaded ${result.length} class levels');
    } catch (e) {
      print('❌ Load class levels error: $e');
      classLevels.value = [];
    }
  }

  Future<void> _loadClasses(String branchId) async {
    try {
      print('🔄 Loading classes...');
      final result = await _classRepo.getClassesWithDetails(branchId);
      classes.value = result;
      print('✅ Loaded ${result.length} classes');
    } catch (e) {
      print('❌ Load classes error: $e');
      classes.value = [];
    }
  }

  Future<void> _loadTeachers(String branchId) async {
    try {
      print('🔄 Loading teachers...');
      final result = await _classRepo.getTeachers(branchId);
      teachers.value = result;
      print('✅ Loaded ${result.length} teachers');
    } catch (e) {
      print('❌ Load teachers error: $e');
      teachers.value = [];
    }
  }

  Future<void> _loadRooms(String branchId) async {
    try {
      print('🔄 Loading rooms...');
      final result = await _classRepo.getRooms(branchId);
      rooms.value = result;
      print('✅ Loaded ${result.length} rooms');
    } catch (e) {
      print('❌ Load rooms error: $e');
      rooms.value = [];
    }
  }

  // SINF ORQALI TANLASH
  void selectClassLevel(String? levelId) {
    print('🎯 ========== SELECT CLASS LEVEL ==========');
    print('Selected Level ID: $levelId');

    selectedClassLevelId.value = levelId;
    selectedClassId.value = null;

    if (levelId == null) {
      filteredClasses.value = [];
      _clearClassInfo();
      print('⚠️ Level is null, cleared');
      return;
    }

    filteredClasses.value = classes
        .where((c) => c['class_level_id'] == levelId)
        .toList();

    print('📋 Filtered ${filteredClasses.length} classes');
    for (var cls in filteredClasses) {
      print(
        '  - ${cls['name']}: Teacher=${cls['teacher']}, Room=${cls['room']}',
      );
    }
    print('==========================================');
  }

  void selectClass(String? classId) {
    print('🎯 ========== SELECT CLASS ==========');
    print('Selected Class ID: $classId');

    selectedClassId.value = classId;

    if (classId == null) {
      _clearClassInfo();
      print('⚠️ Class is null, cleared');
      return;
    }

    final selectedClass = classes.firstWhereOrNull((c) => c['id'] == classId);

    if (selectedClass != null) {
      print('📦 Class found:');
      print('  - Name: ${selectedClass['name']}');
      print('  - Teacher ID: ${selectedClass['main_teacher_id']}');
      print('  - Teacher Name: ${selectedClass['teacher']}');
      print('  - Room ID: ${selectedClass['default_room_id']}');
      print('  - Room Name: ${selectedClass['room']}');
      print('  - Monthly Fee: ${selectedClass['monthly_fee']}');

      selectedClassName.value = selectedClass['name'] ?? '';
      selectedTeacherId.value = selectedClass['main_teacher_id'];
      selectedTeacherName.value = selectedClass['teacher'] ?? '';
      selectedRoomId.value = selectedClass['default_room_id'];
      selectedClassRoom.value = selectedClass['room'] ?? '';

      if (selectedClass['monthly_fee'] != null) {
        final classFee =
            double.tryParse(selectedClass['monthly_fee'].toString()) ?? 900000;
        monthlyFeeController.text = classFee.toStringAsFixed(0);
        updateDiscountAmount();
        print('  - Fee set to: $classFee');
      }

      print('✅ Updated UI values:');
      print('  - selectedClassName: ${selectedClassName.value}');
      print('  - selectedTeacherName: ${selectedTeacherName.value}');
      print('  - selectedClassRoom: ${selectedClassRoom.value}');
    } else {
      print('❌ Class not found in list!');
      print('Available classes: ${classes.map((c) => c['id']).toList()}');
    }
    print('====================================');
  }

  // O'QITUVCHI ORQALI TANLASH
  void selectTeacher(String? teacherId) {
    print('🎯 ========== SELECT TEACHER ==========');
    print('Selected Teacher ID: $teacherId');

    selectedTeacherId.value = teacherId;

    if (teacherId == null) {
      _clearClassInfo();
      print('⚠️ Teacher is null, cleared');
      return;
    }

    final teacher = teachers.firstWhereOrNull((t) => t['id'] == teacherId);

    if (teacher != null) {
      print('📦 Teacher found:');
      print('  - Name: ${teacher['full_name']}');
      print('  - Class ID: ${teacher['class_id']}');
      print('  - Class Name: ${teacher['class_name']}');
      print('  - Room ID: ${teacher['room_id']}');
      print('  - Room Name: ${teacher['room_name']}');

      selectedTeacherName.value = teacher['full_name'] ?? '';

      if (teacher['class_id'] != null) {
        selectedClassId.value = teacher['class_id'];
        selectedClassName.value = teacher['class_name'] ?? '';

        final selectedClass = classes.firstWhereOrNull(
          (c) => c['id'] == teacher['class_id'],
        );
        if (selectedClass != null) {
          selectedClassLevelId.value = selectedClass['class_level_id'];
          print(
            '  - Class Level ID set to: ${selectedClass['class_level_id']}',
          );
        }
      }

      if (teacher['room_id'] != null) {
        selectedRoomId.value = teacher['room_id'];
        selectedClassRoom.value = teacher['room_name'] ?? '';
      }

      print('✅ Updated UI values:');
      print('  - selectedTeacherName: ${selectedTeacherName.value}');
      print('  - selectedClassName: ${selectedClassName.value}');
      print('  - selectedClassRoom: ${selectedClassRoom.value}');
    } else {
      print('❌ Teacher not found in list!');
      print('Available teachers: ${teachers.map((t) => t['id']).toList()}');
    }
    print('======================================');
  }

  // XONA ORQALI TANLASH
  void selectRoom(String? roomId) {
    print('🎯 ========== SELECT ROOM ==========');
    print('Selected Room ID: $roomId');

    selectedRoomId.value = roomId;

    if (roomId == null) {
      _clearClassInfo();
      print('⚠️ Room is null, cleared');
      return;
    }

    final room = rooms.firstWhereOrNull((r) => r['id'] == roomId);

    if (room != null) {
      print('📦 Room found:');
      print('  - Name: ${room['name']}');
      print('  - Class ID: ${room['class_id']}');
      print('  - Class Name: ${room['class_name']}');
      print('  - Teacher ID: ${room['teacher_id']}');
      print('  - Teacher Name: ${room['teacher_name']}');

      selectedClassRoom.value = room['name'] ?? '';

      if (room['class_id'] != null) {
        selectedClassId.value = room['class_id'];
        selectedClassName.value = room['class_name'] ?? '';

        final selectedClass = classes.firstWhereOrNull(
          (c) => c['id'] == room['class_id'],
        );
        if (selectedClass != null) {
          selectedClassLevelId.value = selectedClass['class_level_id'];
          print(
            '  - Class Level ID set to: ${selectedClass['class_level_id']}',
          );
        }
      }

      if (room['teacher_id'] != null) {
        selectedTeacherId.value = room['teacher_id'];
        selectedTeacherName.value = room['teacher_name'] ?? '';
      }

      print('✅ Updated UI values:');
      print('  - selectedClassRoom: ${selectedClassRoom.value}');
      print('  - selectedClassName: ${selectedClassName.value}');
      print('  - selectedTeacherName: ${selectedTeacherName.value}');
    } else {
      print('❌ Room not found in list!');
      print('Available rooms: ${rooms.map((r) => r['id']).toList()}');
    }
    print('===================================');
  }

  void _clearClassInfo() {
    selectedClassName.value = '';
    selectedTeacherName.value = '';
    selectedClassRoom.value = '';
    print('🧹 Cleared class info');
  }

  // ========== VISITOR ==========
  Future<void> _loadVisitors(String branchId) async {
    try {
      final result = await _visitorRepo.getPotentialStudents(branchId);
      visitors.value = result;
    } catch (e) {
      print('Load visitors error: $e');
      visitors.value = [];
    }
  }

  void selectVisitor(String? visitorId) {
    selectedVisitorId.value = visitorId;

    if (visitorId == null) {
      _clearStudentInfo();
      return;
    }

    final visitor = visitors.firstWhereOrNull((v) => v.id == visitorId);
    if (visitor == null) return;

    firstNameController.text = visitor.firstName ?? '';
    lastNameController.text = visitor.lastName ?? '';
    middleNameController.text = visitor.middleName ?? '';
    phoneController.text = visitor.phone ?? '';
    addressController.text = visitor.address ?? '';
    regionController.text = visitor.region ?? '';
    districtController.text = visitor.district ?? '';
    selectedGender.value = visitor.gender ?? 'male';
    birthDate.value = visitor.birthDate;
    parentPhoneController.text = visitor.phone ?? '';
    notesController.text = visitor.notes ?? '';
  }

  void _clearStudentInfo() {
    firstNameController.clear();
    lastNameController.clear();
    middleNameController.clear();
    phoneController.clear();
    addressController.clear();
    regionController.clear();
    districtController.clear();
    selectedGender.value = 'male';
    birthDate.value = null;
    selectedImage.value = null;
    photoUrl.value = '';
  }

  // ========== SINF BOSHQARUVI ==========

  void changeSelectionMode(String mode) {
    selectionMode.value = mode;
    _clearSelection();
  }

  void _clearSelection() {
    selectedClassId.value = null;
    selectedTeacherId.value = null;
    selectedRoomId.value = null;
    selectedClassLevelId.value = null;
    filteredClasses.value = [];
    selectedClassName.value = '';
    selectedTeacherName.value = '';
    selectedClassRoom.value = '';
  }

  // SINF ORQALI TANLASH

  // ========== TUG'ILGAN SANA ==========
  Future<void> selectBirthDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          birthDate.value ??
          DateTime.now().subtract(const Duration(days: 365 * 7)),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF2196F3)),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      birthDate.value = picked;
    }
  }

  // ========== RASM YUKLASH ==========
  Future<void> pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        selectedImage.value = File(image.path);
        Get.snackbar(
          'Muvaffaqiyatli',
          'Rasm tanlandi',
          backgroundColor: const Color(0xFF2196F3).withOpacity(0.1),
          colorText: const Color(0xFF2196F3),
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      _showError('Xatolik', 'Rasm tanlashda xatolik: ${e.toString()}');
    }
  }

  Future<void> takePicture() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        selectedImage.value = File(image.path);
        Get.snackbar(
          'Muvaffaqiyatli',
          'Rasm olindi',
          backgroundColor: const Color(0xFF2196F3).withOpacity(0.1),
          colorText: const Color(0xFF2196F3),
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      _showError('Xatolik', 'Rasm olishda xatolik: ${e.toString()}');
    }
  }

  void removeImage() {
    selectedImage.value = null;
    photoUrl.value = '';
  }

  Future<String?> _uploadImage(String studentId) async {
    if (selectedImage.value == null) return null;

    try {
      isUploadingImage.value = true;

      final fileName =
          'student_${studentId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = 'students/$fileName';

      final bytes = await selectedImage.value!.readAsBytes();

      await Supabase.instance.client.storage
          .from('student-photos')
          .uploadBinary(filePath, bytes);

      final url = Supabase.instance.client.storage
          .from('student-photos')
          .getPublicUrl(filePath);

      return url;
    } catch (e) {
      print('Upload image error: $e');
      _showError('Ogohlantirish', 'Rasmni yuklashda xatolik');
      return null;
    } finally {
      isUploadingImage.value = false;
    }
  }

  // ========== MOLIYAVIY ==========
  void updateDiscountAmount() {
    final fee =
        double.tryParse(
          monthlyFeeController.text.replaceAll(',', '').replaceAll(' ', ''),
        ) ??
        0;
    final percent = double.tryParse(discountPercentController.text) ?? 0;

    final discount = fee * (percent / 100);
    discountAmountController.text = discount.toStringAsFixed(0);

    finalMonthlyFee.value = fee - discount;
  }

  // ========== SAQLASH ==========
  Future<void> saveStudent() async {
    if (!_validateForm()) return;

    try {
      isSaving.value = true;

      final currentUser = _authController.currentUser.value;
      if (currentUser == null) {
        _showError('Xatolik', 'Foydalanuvchi ma\'lumotlari aniqlanmadi');
        return;
      }

      final student = await _studentRepo.createStudent(
        branchId: selectedBranchId.value!,
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        middleName: middleNameController.text.trim(),
        gender: selectedGender.value,
        birthDate: birthDate.value!,
        phone: phoneController.text.trim(),
        address: addressController.text.trim(),
        region: regionController.text.trim(),
        district: districtController.text.trim(),
        parentFirstName: parentFirstNameController.text.trim(),
        parentLastName: parentLastNameController.text.trim(),
        parentMiddleName: parentMiddleNameController.text.trim(),
        parentPhone: parentPhoneController.text.trim(),
        parentPhoneSecondary: parentPhone2Controller.text.trim(),
        parentWorkplace: parentWorkplaceController.text.trim(),
        parentRelation: parentRelation.value,
        monthlyFee:
            double.tryParse(monthlyFeeController.text.replaceAll(',', '')) ??
            0.0,
        discountPercent: double.tryParse(discountPercentController.text) ?? 0.0,
        discountAmount: double.tryParse(discountAmountController.text) ?? 0.0,
        discountReason: discountReasonController.text.trim(),
        notes: notesController.text.trim(),
        medicalNotes: medicalNotesController.text.trim(),
        visitorId: selectedVisitorId.value,
        createdBy: currentUser.id,
        classId: selectedClassId.value,
      );

      if (student != null) {
        // Rasmni yuklash
        if (selectedImage.value != null) {
          final imageUrl = await _uploadImage(student.id);
          if (imageUrl != null) {
            await _studentRepo.updateStudent(studentId: student.id);
          }
        }

        Get.snackbar(
          'Muvaffaqiyatli',
          'O\'quvchi ${selectedBranchName.value} filialiga qo\'shildi',
          backgroundColor: const Color(0xFF2196F3).withOpacity(0.1),
          colorText: const Color(0xFF2196F3),
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
        );

        Get.offNamed(AppRoutes.studentDetail, arguments: student.id);
      } else {
        throw Exception('O\'quvchi ma\'lumotlari qaytarilmadi');
      }
    } catch (e) {
      _showError('Xatolik', 'O\'quvchini saqlashda xatolik: ${e.toString()}');
    } finally {
      isSaving.value = false;
    }
  }

  bool _validateForm() {
    if (selectedBranchId.value == null || selectedBranchId.value!.isEmpty) {
      _showError('Xatolik', 'Iltimos, filialni tanlang');
      return false;
    }

    if (!formKey.currentState!.validate()) {
      _showError('Xatolik', 'Iltimos, barcha majburiy maydonlarni to\'ldiring');
      return false;
    }

    if (birthDate.value == null) {
      _showError('Xatolik', 'Tug\'ilgan sanani tanlang');
      return false;
    }

    if (selectedClassId.value == null) {
      _showError('Xatolik', 'Sinf tanlang');
      return false;
    }

    return true;
  }

  void _clearForm() {
    firstNameController.clear();
    lastNameController.clear();
    middleNameController.clear();
    phoneController.clear();
    addressController.clear();
    regionController.clear();
    districtController.clear();
    selectedGender.value = 'male';
    birthDate.value = null;
    selectedImage.value = null;
    photoUrl.value = '';
    parentFirstNameController.clear();
    parentLastNameController.clear();
    parentMiddleNameController.clear();
    parentPhoneController.clear();
    parentPhone2Controller.clear();
    parentWorkplaceController.clear();
    parentRelation.value = 'Otasi';
    monthlyFeeController.text = '900000';
    discountPercentController.text = '0';
    discountAmountController.text = '0';
    discountReasonController.clear();
    finalMonthlyFee.value = 900000.0;
    notesController.clear();
    medicalNotesController.clear();
    _clearSelection();
    selectedVisitorId.value = null;
    filteredClasses.value = [];
  }

  void _showError(String title, String message) {
    Get.snackbar(
      title,
      message,
      backgroundColor: Colors.red.shade100,
      colorText: Colors.red.shade900,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
    );
  }
}
