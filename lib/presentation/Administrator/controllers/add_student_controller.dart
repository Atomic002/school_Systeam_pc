// lib/controllers/add_student_controller.dart - TO'LIQ TUZATILGAN
// BARCHA SINF MA'LUMOTLARI BILAN

import 'package:flutter/material.dart';
import 'package:flutter_application_1/config/app_routes.dart';
import 'package:flutter_application_1/data/repositories/branch_repository.dart';
import 'package:flutter_application_1/data/repositories/student_repositry.dart';
import 'package:flutter_application_1/data/repositories/visitior_repitory.dart';
import 'package:flutter_application_1/presentation/controllers/auth_controller.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';



class AddStudentControlleradmin extends GetxController {
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
  final RxString selectedClassLevelName = ''.obs;

  final RxString selectionMode = 'class'.obs;

  // HOLATLAR
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxBool isUploadingImage = false.obs;

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
      _showError('Boshlash xatosi', e.toString());
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
      print('Saqlangan filialni yuklashda xato: $e');
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
          '${selectedBranchName.value} filialiga o\'tildi',
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
      print('Saqlash filiali xatosi: $e');
    }
  }

  // =========== FILIAL MA'LUMOTLARINI YUKLASH - TO'LIQ TUZATILGAN =========
  Future<void> _loadBranchData(String branchId) async {
    try {
      print('🔄 ========== FILIAL MA\'LUMOTLARI YUKLANMOQDA ==========');
      print('Filial identifikatori: $branchId');

      await Future.wait([
        _loadVisitors(branchId),
        _loadClassLevels(),
        _loadClasses(branchId),
        _loadTeachers(branchId),
        _loadRooms(branchId),
      ]);

      print('✅ ========== FILIAL MA\'LUMOTLARI YUKLANDI ===========');
      print('📊 Sinf darajalari: ${classLevels.length}');
      print('📊 Sinflar: ${classes.length}');
      print('📊 O\'qituvchilar: ${teachers.length}');
      print('📊 Xonalar: ${rooms.length}');
      print('📊 Mehmonlar: ${visitors.length}');
      print(
        '===================================================================\n',
      );
    } catch (e) {
      print('❌ _loadBranchData xatosi: $e');
      _showError('Xatolik', 'Filial ma\'lumotlarini yuklashda xatolik');
    }
  }

  Future<void> _loadClassLevels() async {
    try {
      print('🔄 Sinf darajalari yuklanmoqda...');
      final result = await _classRepo.getClassLevels();
      classLevels.value = result;
      print('✅ ${result.length} sinf darajalari yuklandi');
    } catch (e) {
      print('❌ Sinf darajalarini yuklashda xato: $e');
      classLevels.value = [];
    }
  }

  // =========== YANGILANGAN LOAD CLASSES ===========
    // =========== YANGILANGAN LOAD CLASSES (Academic Year bilan) ===========
  Future<void> _loadClasses(String branchId) async {
    try {
      print('🔄 Filial uchun sinflar yuklanmoqda...');

      final response = await Supabase.instance.client
          .from('classes')
          .select('''
            *,
            academic_year_id, 
            class_levels(id, name),
            staff:main_teacher_id(id, first_name, last_name),
            rooms:default_room_id(id, name)
          ''')
          .eq('branch_id', branchId)
          .eq('is_active', true);

      List<Map<String, dynamic>> loadedClasses = [];

      for (var item in response) {
        String teacherName = 'Tayinlanmagan';
        if (item['staff'] != null) {
          teacherName = "${item['staff']['first_name']} ${item['staff']['last_name']}";
        }

        String roomName = 'Tayinlanmagan';
        if (item['rooms'] != null) {
          roomName = item['rooms']['name'];
        }

        String levelName = '';
        if (item['class_levels'] != null) {
          levelName = item['class_levels']['name'];
        }

        loadedClasses.add({
          'id': item['id'],
          'name': item['name'],
          'class_level_id': item['class_level_id'],
          'class_level_name': levelName,
          'main_teacher_id': item['main_teacher_id'],
          'teacher': teacherName,
          'default_room_id': item['default_room_id'],
          'room': roomName,
          'monthly_fee': item['monthly_fee'],
          'academic_year_id': item['academic_year_id'], // MUHIM: Bu qator qo'shildi
        });
      }

      classes.value = loadedClasses;
      
      if (selectedClassLevelId.value == null) {
        filteredClasses.value = loadedClasses;
      } else {
        filteredClasses.value = loadedClasses
            .where((c) => c['class_level_id'] == selectedClassLevelId.value)
            .toList();
      }
    } catch (e) {
      print('❌ Sinflarni yuklashda xato: $e');
    }
  }

  // =========== YANGILANGAN LOAD TEACHERS ===========
  Future<void> _loadTeachers(String branchId) async {
    try {
      print('🔄 O\'qituvchilar yuklanmoqda...');

      // O'qituvchilar (staff) va ularning sinflarini (classes) olamiz
      final response = await Supabase.instance.client
          .from('staff')
          .select('''
            id, first_name, last_name,
            classes!main_teacher_id(id, name, default_room_id, rooms(name))
          ''')
          .eq('branch_id', branchId)
          .eq('role', 'teacher') // Faqat o'qituvchilarni
          .eq('status', 'active');

      List<Map<String, dynamic>> loadedTeachers = [];

      for (var item in response) {
        String fullName = "${item['first_name']} ${item['last_name']}";

        String? classId;
        String? className;
        String? roomId;
        String? roomName;

        // Agar o'qituvchining sinfi bo'lsa (List qaytadi, shuning uchun birinchisini olamiz)
        if (item['classes'] != null && (item['classes'] as List).isNotEmpty) {
          final cls = (item['classes'] as List).first;
          classId = cls['id'];
          className = cls['name'];
          roomId = cls['default_room_id'];
          if (cls['rooms'] != null) {
            roomName = cls['rooms']['name'];
          }
        }

        loadedTeachers.add({
          'id': item['id'],
          'full_name': fullName,
          'class_id': classId,
          'class_name': className ?? 'Sinf yo\'q',
          'room_id': roomId,
          'room_name': roomName ?? 'Xona yo\'q',
        });
      }

      teachers.value = loadedTeachers;
      print('✅ ${loadedTeachers.length} o\'qituvchilar yuklandi');
    } catch (e) {
      print('❌ Teachers yuklashda xato: $e');
      teachers.value = [];
    }
  }

  // =========== YANGILANGAN LOAD ROOMS ===========
  Future<void> _loadRooms(String branchId) async {
    try {
      print('🔄 Xonalar yuklanmoqda...');

      final response = await Supabase.instance.client
          .from('rooms')
          .select('''
            id, name, capacity,
            classes!default_room_id(id, name, main_teacher_id, staff(first_name, last_name))
          ''')
          .eq('branch_id', branchId);

      List<Map<String, dynamic>> loadedRooms = [];

      for (var item in response) {
        String? classId;
        String? className;
        String? teacherId;
        String? teacherName;

        // Agar xonaga sinf biriktirilgan bo'lsa
        if (item['classes'] != null && (item['classes'] as List).isNotEmpty) {
          final cls = (item['classes'] as List).first;
          classId = cls['id'];
          className = cls['name'];
          teacherId = cls['main_teacher_id'];
          if (cls['staff'] != null) {
            teacherName =
                "${cls['staff']['first_name']} ${cls['staff']['last_name']}";
          }
        }

        loadedRooms.add({
          'id': item['id'],
          'name': item['name'],
          'class_id': classId,
          'class_name': className,
          'teacher_id': teacherId,
          'teacher_name': teacherName,
        });
      }

      rooms.value = loadedRooms;
      print('✅ ${loadedRooms.length} xonalar yuklandi');
    } catch (e) {
      print('❌ Xonalarni yuklashda xato: $e');
      rooms.value = [];
    }
  }

  // =========== SINF ORQALI TANLASH ==========
  // =========== 100% AVTOMATIK SELECT CLASS ===========
  void selectClass(String? classId) {
    print('🎯 SELECT CLASS: $classId');

    // 1. Agar bo'shatilsa, hammasini tozalaymiz
    if (classId == null) {
      selectedClassId.value = null;
      _clearClassInfo();
      return;
    }

    // 2. Sinfni ro'yxatdan topamiz
    final selectedClass = classes.firstWhereOrNull((c) => c['id'] == classId);

    if (selectedClass != null) {
      // A. ID larni o'rnatamiz
      selectedClassId.value = selectedClass['id'];

      // B. Sinf darajasini avtomatik qo'yamiz
      if (selectedClass['class_level_id'] != null) {
        selectedClassLevelId.value = selectedClass['class_level_id'];
        selectedClassLevelName.value = selectedClass['class_level_name'] ?? '';

        // Daraja tanlanganda ro'yxatni filtrlaymiz, lekin tanlangan sinf qolishini ta'minlaymiz
        filteredClasses.value = classes
            .where(
              (c) => c['class_level_id'] == selectedClass['class_level_id'],
            )
            .toList();
      }

      // C. O'qituvchini avtomatik tanlaymiz
      if (selectedClass['main_teacher_id'] != null) {
        selectedTeacherId.value = selectedClass['main_teacher_id'];
        selectedTeacherName.value = selectedClass['teacher'] ?? 'Noma\'lum';
      } else {
        selectedTeacherId.value = null;
        selectedTeacherName.value = 'Tayinlanmagan';
      }

      // D. Xonani avtomatik tanlaymiz
      if (selectedClass['default_room_id'] != null) {
        selectedRoomId.value = selectedClass['default_room_id'];
        selectedClassRoom.value = selectedClass['room'] ?? 'Noma\'lum';
      } else {
        selectedRoomId.value = null;
        selectedClassRoom.value = 'Tayinlanmagan';
      }

      // E. Narxni avtomatik qo'yamiz
      if (selectedClass['monthly_fee'] != null) {
        final classFee =
            double.tryParse(selectedClass['monthly_fee'].toString()) ?? 900000;
        monthlyFeeController.text = classFee.toStringAsFixed(0);
        updateDiscountAmount(); // Chegirma hisobini yangilash
      }

      // F. Nomini qo'yamiz
      selectedClassName.value = selectedClass['name'] ?? '';

      print('✅ AVTO TO\'LDIRILDI:');
      print('   Sinf: ${selectedClassName.value}');
      print('   O\'qituvchi: ${selectedTeacherName.value}');
      print('   Xona: ${selectedClassRoom.value}');
      print('   Narx: ${monthlyFeeController.text}');
    }
  }

  // =========== O'QITUVCHI ORQALI TANLASH ==========
  // =========== 100% AVTOMATIK SELECT TEACHER ===========
  void selectTeacher(String? teacherId) {
    print('🎯 SELECT TEACHER: $teacherId');
    selectedTeacherId.value = teacherId;

    if (teacherId == null) {
      _clearClassInfo();
      return;
    }

    final teacher = teachers.firstWhereOrNull((t) => t['id'] == teacherId);

    if (teacher != null) {
      selectedTeacherName.value = teacher['full_name'] ?? '';

      // ⚠️ MUHIM: Agar o'qituvchining sinfi bo'lsa, SINFNING o'zini tanlaymiz
      // Bu esa o'z navbatida xona va narxlarni ham avtomatik to'ldiradi (Chain Reaction)
      if (teacher['class_id'] != null) {
        print('🔗 O\'qituvchi orqali sinf tanlanmoqda: ${teacher['class_id']}');

        // Bu yerda selectClass funksiyasini chaqiramiz, u qolgan ishni qiladi
        selectClass(teacher['class_id']);

        // Mode ni o'zgartiramizki, foydalanuvchi to'ldirilgan ma'lumotni ko'rsin
        selectionMode.value = 'class';
      } else {
        // Agar sinfi yo'q bo'lsa, faqat xonasini qo'yamiz
        if (teacher['room_id'] != null) {
          selectedRoomId.value = teacher['room_id'];
          selectedClassRoom.value = teacher['room_name'] ?? '';
        }
        selectedClassId.value = null;
        selectedClassName.value = '';
        Get.snackbar(
          'Eslatma',
          'Bu o\'qituvchiga hozircha sinf biriktirilmagan',
        );
      }
    }
  }

  // =========== XONA ORQALI TANLASH ==========
  // =========== 100% AVTOMATIK SELECT ROOM ===========
  void selectRoom(String? roomId) {
    print('🎯 SELECT ROOM: $roomId');
    selectedRoomId.value = roomId;

    if (roomId == null) {
      _clearClassInfo();
      return;
    }

    final room = rooms.firstWhereOrNull((r) => r['id'] == roomId);

    if (room != null) {
      selectedClassRoom.value = room['name'] ?? '';

      // ⚠️ MUHIM: Agar xonada sinf o'tirsa, SINFNING o'zini tanlaymiz
      if (room['class_id'] != null) {
        print('🔗 Xona orqali sinf tanlanmoqda: ${room['class_id']}');

        // selectClass ni chaqiramiz, u o'qituvchi va narxlarni to'ldiradi
        selectClass(room['class_id']);

        selectionMode.value = 'class';
      } else {
        // Agar xona bo'sh bo'lsa yoki sinf yo'q bo'lsa
        if (room['teacher_id'] != null) {
          selectedTeacherId.value = room['teacher_id'];
          selectedTeacherName.value = room['teacher_name'] ?? '';
        }
        selectedClassId.value = null;
        selectedClassName.value = '';
        Get.snackbar('Eslatma', 'Bu xonaga hozircha sinf biriktirilmagan');
      }
    }
  }

  void _clearClassInfo() {
    selectedClassName.value = '';
    selectedTeacherName.value = '';
    selectedClassRoom.value = '';
    selectedClassLevelName.value = '';
    monthlyFeeController.text = '900000'; // Default narxga qaytarish
    updateDiscountAmount();
  }

  // =========== MEHMON =========
  Future<void> _loadVisitors(String branchId) async {
    try {
      final result = await _visitorRepo.getPotentialStudents(branchId);
      visitors.value = result;
    } catch (e) {
      print('Mehmonlarni yuklashda xato: $e');
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

  // =========== SINF BOSHQARUVI ==========
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
    selectedClassLevelName.value = '';
  }

  // ==================== SANA TANLASH ====================
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

  // =========== RASM YUKLASH =========
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
      _showError('Xatolik', 'Rasm belgilashda xatolik: ${e.toString()}');
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
          'Rasm oldi',
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

  // =========== MOLIYAVIY ==========
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

  // ========== SAQLASH - TO'LIQ TUZATILGAN ==========
  // ========== SAQLASH (TUZATILGAN) ==========
    // ========== SAQLASH (TUZATILGAN SQL GA MOS) ==========
  Future<void> saveStudent() async {
    if (!_validateForm()) return;

    try {
      isSaving.value = true;
      final currentUser = _authController.currentUser.value;

      // Tanlangan sinfni topamiz
      final selectedClass = classes.firstWhereOrNull((c) => c['id'] == selectedClassId.value);
      if (selectedClass == null) {
        _showError('Xatolik', 'Sinf ma\'lumotlari topilmadi');
        return;
      }

      print('💾 1. Students jadvaliga yozilmoqda...');

      // 1. O'quvchi profilini yaratamiz (STUDENTS jadvali)
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
        parentPhone2: parentPhone2Controller.text.trim(),
        parentWorkplace: parentWorkplaceController.text.trim(),
        parentRelation: parentRelation.value,
        monthlyFee: double.tryParse(monthlyFeeController.text.replaceAll(',', '')) ?? 0.0,
        discountPercent: double.tryParse(discountPercentController.text) ?? 0.0,
        discountAmount: double.tryParse(discountAmountController.text) ?? 0.0,
        discountReason: discountReasonController.text.trim(),
        notes: notesController.text.trim(),
        medicalNotes: medicalNotesController.text.trim(),
        visitorId: selectedVisitorId.value,
        createdBy: currentUser!.id,
        
        // Students jadvalidagi qo'shimcha ustunlar
        classId: selectedClass['id'],
        mainTeacherId: selectedClass['main_teacher_id'],
        roomId: selectedClass['default_room_id'],
      );

      if (student != null) {
        print('✅ Student ID: ${student.id}');

        // 2. ENROLLMENTS jadvaliga yozish (SIZNING JADVALINGIZGA MOSLANDI)
        print('💾 2. Enrollments jadvaliga yozilmoqda...');
        
        try {
          await Supabase.instance.client.from('enrollments').insert({
            'student_id': student.id,
            'class_id': selectedClass['id'],
            
            // XATO TUZATILDI: 'branch_id' olib tashlandi (Sizning jadvalda bu yo'q)
            // XATO TUZATILDI: 'status' olib tashlandi (Sizning jadvalda bu yo'q)
            
            // 'start_date' EMAS -> 'enrolled_at'
            'enrolled_at': DateTime.now().toIso8601String(),
            
            'is_active': true,
            'academic_year_id': selectedClass['academic_year_id'], // Agar bo'lsa yozadi
            'created_by': currentUser?.id,
            
            // Moliyaviy kelishuv (ixtiyoriy)
            'custom_monthly_fee': double.tryParse(monthlyFeeController.text.replaceAll(',', '')) ?? 0.0,
            'custom_discount_percent': double.tryParse(discountPercentController.text) ?? 0.0,
          });
          print('✅ Enrollment muvaffaqiyatli yaratildi');
        } catch (e) {
          print('❌ Enrollment yozishda xato: $e');
          // Bu xato student yaratilgan bo'lsa ham foydalanuvchini to'xtatmasligi kerak
        }

        // 3. Rasm yuklash
        if (selectedImage.value != null) {
          final imageUrl = await _uploadImage(student.id);
          if (imageUrl != null) {
            await _studentRepo.updateStudent(
              studentId: student.id,
              photoUrl: imageUrl,
            );
          }
        }

        Get.snackbar(
          'Muvaffaqiyatli', 
          'O\'quvchi ${selectedClassName.value} sinfiga qabul qilindi',
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade900
        );
        Get.offNamed(AppRoutes.studentDetail, arguments: student.id);
      }
    } catch (e) {
      print('❌ Umumiy xatolik: $e');
      _showError('Xatolik', 'Saqlashda xatolik: $e');
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
