// lib/controllers/add_student_controller.dart
// BRANCH ACCESS CONTROL BILAN MUKAMMAL HOLATDA

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

  // --- ACCESS CONTROL ---
  final RxBool canChangeBranch = true.obs;

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

  // VISITOR (YANGILANGAN)
  final RxList<Map<String, dynamic>> visitors = <Map<String, dynamic>>[].obs;
  final Rx<String?> selectedVisitorId = Rx<String?>(null);
  final RxBool isLoadingVisitors = false.obs;

  // SINF MA'LUMOTLARI
  final RxList<Map<String, dynamic>> classLevels = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> classes = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> filteredClasses =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> teachers = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> rooms = <Map<String, dynamic>>[].obs;
  final RxBool isEditMode = false.obs;
  String? editingStudentId;
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

    // YANGI: Argumentlarni to'g'ri tekshirish
    if (Get.arguments != null && Get.arguments is Map) {
      final args = Get.arguments as Map;

      // EDIT REJIMI
      if (args['isEdit'] == true && args['studentId'] != null) {
        isEditMode.value = true;
        editingStudentId = args['studentId'];
        print('🔄 Edit rejimi faollashtirildi: $editingStudentId');
      }
      // VISITOR dan kelgan
      else if (args['visitor'] != null) {
        final visitor = args['visitor'];
        if (visitor['branch_id'] != null) {
          selectBranch(visitor['branch_id'], showMessage: false).then((_) {
            onVisitorSelected(visitor['id']);
          });
        }
      }
    }
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
    
    // EDIT REJIMI uchun ma'lumotlarni yuklash
    if (isEditMode.value && editingStudentId != null) {
      print('📥 Edit uchun ma\'lumotlar yuklanmoqda...');
      // Biroz kutamiz, filiallar to'liq yuklanishi uchun
      await Future.delayed(const Duration(milliseconds: 500));
      await _loadStudentForEditing(editingStudentId!);
    }
  } catch (e) {
    _showError('Boshlash xatosi', e.toString());
  } finally {
    isLoading.value = false;
  }
}

  void _disposeControllers() {
    // ... (eski kod bilan bir xil)
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

  // ... (fetchBranches, selectBranch va boshqa funksiyalar eski kod bilan bir xil) ...
  // Qisqartirish uchun faqat o'zgargan va kerakli joylarni yozaman.
  // Asl kodingizdagi fetchBranches, selectBranch, _loadBranchData va boshqalarni joyida qoldiring.

  Future<void> fetchBranches() async {
    // ... (Asl kodingiz)
    try {
      final currentUser = _authController.currentUser.value;
      if (currentUser == null) {
        _showError('Xatolik', 'Foydalanuvchi ma\'lumotlari topilmadi');
        return;
      }

      List<Map<String, dynamic>> branchesList = [];

      if (currentUser.branchId != null) {
        canChangeBranch.value = false;
        showBranchSelector.value = false;
        final branchData = await Supabase.instance.client
            .from('branches')
            .select()
            .eq('id', currentUser.branchId!)
            .single();
        branchesList = [branchData];
        await selectBranch(currentUser.branchId!, showMessage: false);
      } else {
        canChangeBranch.value = true;
        showBranchSelector.value = true;
        branchesList = await _branchRepo.getAllBranches();
        await _loadSavedBranch();
      }
      branches.value = branchesList;
      if (branches.length == 1 && selectedBranchId.value == null) {
        await selectBranch(branches.first['id'], showMessage: false);
      }
    } catch (e) {
      _showError('Xatolik', 'Filiallarni yuklashda xatolik: ${e.toString()}');
    }
  }

  Future<void> _loadStudentForEditing(String studentId) async {
  try {
    print('🔄 Tahrirlash uchun yuklanmoqda: $studentId');
    isLoading.value = true;
    
    final student = await _studentRepo.getStudentById(studentId);
    
    if (student == null) {
      _showError('Xatolik', 'O\'quvchi topilmadi');
      isLoading.value = false;
      return;
    }

    print('✅ Student topildi: ${student.firstName} ${student.lastName}');

    // 1. FILIAL - Avval filialni yuklash (bu boshqa ma'lumotlarni ham yuklaydi)
    if (student.branchId != null) {
      await selectBranch(student.branchId, showMessage: false);
      print('✅ Filial yuklandi');
    }

    // 2. ASOSIY MA'LUMOTLAR
    firstNameController.text = student.firstName;
    lastNameController.text = student.lastName;
    middleNameController.text = student.middleName ?? '';
    phoneController.text = student.phone ?? '';
    addressController.text = student.address ?? '';
    regionController.text = student.region ?? '';
    districtController.text = student.district ?? '';
    
    if (student.gender != null) selectedGender.value = student.gender!;
    birthDate.value = student.birthDate;
    
    // 3. OTA-ONA MA'LUMOTLARI
    parentFirstNameController.text = student.parentFirstName ?? '';
    parentLastNameController.text = student.parentLastName ?? '';
    parentMiddleNameController.text = student.parentMiddleName ?? '';
    parentPhoneController.text = student.parentPhone ?? '';
    parentPhone2Controller.text = student.parentPhone ?? ''; // To'g'ri nom
    parentWorkplaceController.text = student.parentWorkplace ?? '';
    if (student.parentRelation != null) {
      parentRelation.value = student.parentRelation!;
    }
    
    // 4. MOLIYAVIY
    monthlyFeeController.text = student.monthlyFee.toStringAsFixed(0);
    discountPercentController.text = student.discountPercent.toStringAsFixed(0);
    discountAmountController.text = student.discountAmount.toStringAsFixed(0);
    discountReasonController.text = student.discountReason ?? '';
    updateDiscountAmount();
    
    // 5. QO'SHIMCHA
    notesController.text = student.notes ?? '';
    medicalNotesController.text = student.medicalNotes ?? '';
    
    // 6. RASM
    if (student.photoUrl != null && student.photoUrl!.isNotEmpty) {
      photoUrl.value = student.photoUrl!;
    }

    // 7. SINF - Oxirida, chunki classes yuklangan bo'lishi kerak
    if (student.classId != null) {
      // classes ro'yxatida borligini tekshirish
      await Future.delayed(const Duration(milliseconds: 300));
      
      final targetClass = classes.firstWhereOrNull((c) => c['id'] == student.classId);
      if (targetClass != null) {
        print('✅ Sinf topildi: ${targetClass['name']}');
        
        // Avval class_level_id ni tanlash
        if (targetClass['class_level_id'] != null) {
          selectedClassLevelId.value = targetClass['class_level_id'];
          filteredClasses.value = classes
              .where((c) => c['class_level_id'] == targetClass['class_level_id'])
              .toList();
        }
        
        // Keyin sinfni tanlash
        selectClass(targetClass['id']);
      } else {
        print('⚠️ Sinf topilmadi: ${student.classId}');
      }
    }

    print('✅ Barcha ma\'lumotlar yuklandi');
    
  } catch (e) {
    print('❌ Load for editing error: $e');
    _showError('Xatolik', 'Ma\'lumotlarni yuklashda xatolik: $e');
  } finally {
    isLoading.value = false;
  }
}
  Future<void> _loadSavedBranch() async {
    // ... (Asl kodingiz)
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
    // ... (Asl kodingiz)
    if (branchId == null || branchId.isEmpty) return;

    final currentUser = _authController.currentUser.value;
    if (currentUser?.branchId != null && branchId != currentUser!.branchId) {
      _showError(
        'Taqiqlandi',
        'Siz faqat o\'z filialingizga ma\'lumot qo\'sha olasiz.',
      );
      return;
    }

    try {
      isLoading.value = true;
      showBranchSelector.value = false;

      selectedBranchId.value = branchId;
      selectedBranchName.value = _getBranchName(branchId);

      if (canChangeBranch.value) {
        await _saveBranch(branchId);
      }

      await _loadBranchData(branchId); // <--- BU YERDA VISITORS HAM YUKLANADI

      if (showMessage) {
        Get.snackbar(
          'Filial tanlandi',
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
    // ... (Asl kodingiz)
    if (!canChangeBranch.value) {
      Get.snackbar(
        'Cheklov',
        'Siz faqat o\'zingizga biriktirilgan filialga o\'quvchi qo\'sha olasiz.',
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.orange.shade900,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    showBranchSelector.value = true;
    _clearForm();
  }

  String _getBranchName(String? branchId) {
    // ... (Asl kodingiz)
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
    // ... (Asl kodingiz)
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selected_branch_id', branchId);
    } catch (e) {
      print('Saqlash filiali xatosi: $e');
    }
  }

  // =========== FILIAL MA'LUMOTLARINI YUKLASH =========
  Future<void> _loadBranchData(String branchId) async {
    try {
      print('🔄 ========== FILIAL MA\'LUMOTLARI YUKLANMOQDA ==========');

      classLevels.clear();
      classes.clear();
      teachers.clear();
      rooms.clear();
      visitors.clear();
      _clearSelection();

      await Future.wait([
        _loadVisitors(branchId), // <--- BU QATOR BORLIGIGA ISHONCH HOSIL QILING
        _loadClassLevels(),
        _loadClasses(branchId),
        _loadTeachers(branchId),
        _loadRooms(branchId),
      ]);

      print('✅ ========== FILIAL MA\'LUMOTLARI YUKLANDI ===========');
    } catch (e) {
      print('❌ _loadBranchData xatosi: $e');
      _showError('Xatolik', 'Filial ma\'lumotlarini yuklashda xatolik');
    }
  }

  // ... (boshqa yuklash funksiyalari: _loadClassLevels, _loadClasses va h.k. O'ZGARISHLARSIZ) ...
  Future<void> _loadClassLevels() async {
    try {
      final result = await _classRepo.getClassLevels();
      classLevels.value = result;
    } catch (e) {
      print('❌ Sinf darajalarini yuklashda xato: $e');
      classLevels.value = [];
    }
  }

  Future<void> _loadClasses(String branchId) async {
    try {
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
          teacherName =
              "${item['staff']['first_name']} ${item['staff']['last_name']}";
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
          'academic_year_id': item['academic_year_id'],
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

  Future<void> _loadTeachers(String branchId) async {
    try {
      final response = await Supabase.instance.client
          .from('staff')
          .select('''
            id, first_name, last_name,
            classes!main_teacher_id(id, name, default_room_id, rooms(name))
          ''')
          .eq('branch_id', branchId)
          .eq('role', 'teacher')
          .eq('status', 'active');

      List<Map<String, dynamic>> loadedTeachers = [];

      for (var item in response) {
        String fullName = "${item['first_name']} ${item['last_name']}";

        String? classId;
        String? className;
        String? roomId;
        String? roomName;

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
    } catch (e) {
      print('❌ Teachers yuklashda xato: $e');
      teachers.value = [];
    }
  }

  Future<void> _loadRooms(String branchId) async {
    try {
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
    } catch (e) {
      print('❌ Xonalarni yuklashda xato: $e');
      rooms.value = [];
    }
  }

  // ... (Select class/teacher/room logic - O'ZGARISHLARSIZ) ...
  void selectClass(String? classId) {
    // ... (Asl kodingiz)
    if (classId == null) {
      selectedClassId.value = null;
      _clearClassInfo();
      return;
    }

    final selectedClass = classes.firstWhereOrNull((c) => c['id'] == classId);

    if (selectedClass != null) {
      selectedClassId.value = selectedClass['id'];

      if (selectedClass['class_level_id'] != null) {
        selectedClassLevelId.value = selectedClass['class_level_id'];
        selectedClassLevelName.value = selectedClass['class_level_name'] ?? '';
        filteredClasses.value = classes
            .where(
              (c) => c['class_level_id'] == selectedClass['class_level_id'],
            )
            .toList();
      }

      if (selectedClass['main_teacher_id'] != null) {
        selectedTeacherId.value = selectedClass['main_teacher_id'];
        selectedTeacherName.value = selectedClass['teacher'] ?? 'Noma\'lum';
      } else {
        selectedTeacherId.value = null;
        selectedTeacherName.value = 'Tayinlanmagan';
      }

      if (selectedClass['default_room_id'] != null) {
        selectedRoomId.value = selectedClass['default_room_id'];
        selectedClassRoom.value = selectedClass['room'] ?? 'Noma\'lum';
      } else {
        selectedRoomId.value = null;
        selectedClassRoom.value = 'Tayinlanmagan';
      }

      if (selectedClass['monthly_fee'] != null) {
        final classFee =
            double.tryParse(selectedClass['monthly_fee'].toString()) ?? 900000;
        monthlyFeeController.text = classFee.toStringAsFixed(0);
        updateDiscountAmount();
      }

      selectedClassName.value = selectedClass['name'] ?? '';
    }
  }

  void selectTeacher(String? teacherId) {
    // ... (Asl kodingiz)
    selectedTeacherId.value = teacherId;

    if (teacherId == null) {
      _clearClassInfo();
      return;
    }

    final teacher = teachers.firstWhereOrNull((t) => t['id'] == teacherId);

    if (teacher != null) {
      selectedTeacherName.value = teacher['full_name'] ?? '';

      if (teacher['class_id'] != null) {
        selectClass(teacher['class_id']);
        selectionMode.value = 'class';
      } else {
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

  void selectRoom(String? roomId) {
    // ... (Asl kodingiz)
    selectedRoomId.value = roomId;

    if (roomId == null) {
      _clearClassInfo();
      return;
    }

    final room = rooms.firstWhereOrNull((r) => r['id'] == roomId);

    if (room != null) {
      selectedClassRoom.value = room['name'] ?? '';

      if (room['class_id'] != null) {
        selectClass(room['class_id']);
        selectionMode.value = 'class';
      } else {
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
    // ... (Asl kodingiz)
    selectedClassName.value = '';
    selectedTeacherName.value = '';
    selectedClassRoom.value = '';
    selectedClassLevelName.value = '';
    monthlyFeeController.text = '900000';
    updateDiscountAmount();
  }

  // =========== MEHMONLAR (VISITORS) - YANGILANGAN =========
  Future<void> _loadVisitors(String branchId) async {
    try {
      isLoadingVisitors.value = true;
      // VisitorRepository dan olinayotgan ma'lumotni Map listiga o'tkazamiz
      // Agar repoda getUnconvertedVisitors bo'lmasa, getPotentialStudents ni ishlating va map qiling:

      final response = await Supabase.instance.client
          .from('visitors')
          .select()
          .eq('branch_id', branchId)
          .eq('is_converted', false) // Faqat hali o'quvchi bo'lmaganlar
          .eq(
            'visitor_type',
            'student',
          ); // Faqat o'quvchi bo'lmoqchi bo'lganlar

      visitors.value = List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Mehmonlarni yuklashda xato: $e');
      visitors.value = [];
    } finally {
      isLoadingVisitors.value = false;
    }
  }

  // YANGI: Visitor tanlanganda ishlaydigan funksiya
  void onVisitorSelected(String? visitorId) {
    selectedVisitorId.value = visitorId;

    if (visitorId != null) {
      final visitor = visitors.firstWhereOrNull((v) => v['id'] == visitorId);
      if (visitor != null) {
        _fillFromVisitor(visitor);
      }
    } else {
      // Agar "Yangi o'quvchi" tanlansa, formani tozalaymiz (lekin filial qoladi)
      _clearStudentInfo();
    }
  }

  // YANGI: Formani visitordan to'ldirish
  void _fillFromVisitor(Map<String, dynamic> visitor) {
    firstNameController.text = visitor['first_name'] ?? '';
    lastNameController.text = visitor['last_name'] ?? '';
    middleNameController.text = visitor['middle_name'] ?? '';
    phoneController.text = visitor['phone'] ?? '';
    parentPhoneController.text =
        visitor['phone_secondary'] ?? ''; // Ota-ona telefoni sifatida
    addressController.text = visitor['address'] ?? '';
    regionController.text = visitor['region'] ?? '';
    districtController.text = visitor['district'] ?? '';

    if (visitor['gender'] != null) {
      selectedGender.value = visitor['gender'];
    }

    if (visitor['birth_date'] != null) {
      try {
        birthDate.value = DateTime.parse(visitor['birth_date'].toString());
      } catch (_) {}
    }

    notesController.text = visitor['notes'] ?? '';
  }

  void clearVisitorSelection() {
    selectedVisitorId.value = null;
    _clearStudentInfo();
  }

  // --- XATO TUZATILDI: _clearStudentInfo funksiyasi qo'shildi ---
  // --- YANGI QO'SHILGAN QISM ---
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
    // selectedVisitorId.value = null; // Buni tozalash shart emas
  }

  void _clearSelection() {
    // ... (eski kod bilan bir xil)
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

  // ... (Sana tanlash, Rasm yuklash va Saqlash funksiyalari O'ZGARISHLARSIZ) ...
  Future<void> selectBirthDate(BuildContext context) async {
    // ...
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

  Future<void> pickImage() async {
    // ...
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
    // ...
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
    // ...
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

  void updateDiscountAmount() {
    // ...
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

  // Xodim qo'shish bilan bir xil mantiq, oxirida result: true qaytarish

  // ==================== SAQLASH (CREATE / UPDATE) ====================
  Future<void> saveStudent() async {
    // 1. Validatsiya
    if (!_validateForm()) return;

    try {
      isSaving.value = true;
      final currentUser = _authController.currentUser.value;

      // Xavfsizlik: Filial tekshiruvi
      if (currentUser?.branchId != null &&
          selectedBranchId.value != currentUser!.branchId) {
        _showError('Xatolik', 'Siz faqat o\'z filialingizga qo\'sha olasiz!');
        return;
      }

      // Sinf ma'lumotlarini olish
      final selectedClass = classes.firstWhereOrNull(
        (c) => c['id'] == selectedClassId.value,
      );

      if (selectedClass == null) {
        _showError('Xatolik', 'Sinf ma\'lumotlari topilmadi');
        return;
      }

      // Rasm yuklash logikasi
      String? uploadedPhotoUrl;
      // Agar yangi rasm tanlangan bo'lsa
      if (selectedImage.value != null) {
        // ID hali yo'q bo'lsa (Create), vaqtincha nom beramiz, keyin o'zgartirish shart emas
        // Yoki tahrirlash bo'lsa o'z ID si bilan
        uploadedPhotoUrl = await _uploadImage(
          editingStudentId ?? 'temp_${DateTime.now().millisecondsSinceEpoch}',
        );
      }
      // Agar tahrirlash bo'lsa va rasm o'zgarmagan bo'lsa, eskisini saqlaymiz
      else if (isEditMode.value && photoUrl.value.isNotEmpty) {
        uploadedPhotoUrl = photoUrl.value;
      }

      // ---------------------------------------------------------
      // A. TAHRIRLASH REJIMI (UPDATE)
      // ---------------------------------------------------------
    // A. TAHRIRLASH REJIMI (UPDATE)
if (isEditMode.value && editingStudentId != null) {
  print('💾 Tahrirlanmoqda: $editingStudentId');
  
  final success = await _studentRepo.updateStudent(
    studentId: editingStudentId!,
    // Asosiy
    firstName: firstNameController.text.trim(),
    lastName: lastNameController.text.trim(),
    middleName: middleNameController.text.trim(),
    phone: phoneController.text.trim(),
    address: addressController.text.trim(),
    region: regionController.text.trim(),
    district: districtController.text.trim(),
    gender: selectedGender.value, // Gender ham qo'shing
    birthDate: birthDate.value, // Tug'ilgan sana ham qo'shing
    // Ota-ona
    parentFirstName: parentFirstNameController.text.trim(),
    parentLastName: parentLastNameController.text.trim(),
    parentMiddleName: parentMiddleNameController.text.trim(),
    parentPhone: parentPhoneController.text.trim(),
    parentPhone2: parentPhone2Controller.text.trim(),
    parentWorkplace: parentWorkplaceController.text.trim(),
    parentRelation: parentRelation.value,
    // Moliyaviy
    monthlyFee: double.tryParse(monthlyFeeController.text.replaceAll(',', '')) ?? 0.0,
    discountPercent: double.tryParse(discountPercentController.text) ?? 0.0,
    discountAmount: double.tryParse(discountAmountController.text) ?? 0.0,
    discountReason: discountReasonController.text.trim(),
    // Qo'shimcha
    notes: notesController.text.trim(),
    medicalNotes: medicalNotesController.text.trim(),
    photoUrl: uploadedPhotoUrl,
    // Sinf
    classId: selectedClass['id'],
    classLevelId: selectedClass['class_level_id'],
    classLevelName: selectedClass['class_level_name'],
    className: selectedClass['name'],
    roomId: selectedClass['default_room_id'],
    roomName: selectedClass['room'],
    mainTeacherId: selectedClass['main_teacher_id'],
    mainTeacherName: selectedClass['teacher'],
  );

  if (success) {
    // Enrollment ni ham yangilash
    try {
      await Supabase.instance.client
          .from('enrollments')
          .update({'class_id': selectedClass['id']})
          .eq('student_id', editingStudentId!)
          .eq('is_active', true);
    } catch (e) {
      print('⚠️ Enrollment yangilanmadi: $e');
    }

    Get.snackbar(
      'Muvaffaqiyatli',
      'O\'quvchi ma\'lumotlari yangilandi',
      backgroundColor: Colors.green.shade100,
      colorText: Colors.green.shade900,
    );
    Get.back(result: true);
  } else {
    _showError('Xatolik', 'Yangilashda xatolik yuz berdi');
  }
  return; // MUHIM: Keyingi create kodiga o'tmasligi uchun
}
      // ---------------------------------------------------------
      // B. YANGI QO'SHISH REJIMI (CREATE)
      // ---------------------------------------------------------
      else {
        print('💾 Yangi qo\'shilmoqda...');

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
          monthlyFee:
              double.tryParse(monthlyFeeController.text.replaceAll(',', '')) ??
              0.0,
          discountPercent:
              double.tryParse(discountPercentController.text) ?? 0.0,
          discountAmount: double.tryParse(discountAmountController.text) ?? 0.0,
          discountReason: discountReasonController.text.trim(),
          notes: notesController.text.trim(),
          medicalNotes: medicalNotesController.text.trim(),
          visitorId: selectedVisitorId.value,
          createdBy: currentUser!.id,

          // Sinf ma'lumotlari
          classId: selectedClass['id'],
          classLevelId: selectedClass['class_level_id'],
          classLevelName: selectedClass['class_level_name'],
          className: selectedClass['name'],
          mainTeacherId: selectedClass['main_teacher_id'],
          mainTeacherName: selectedClass['teacher'],
          roomId: selectedClass['default_room_id'],
          roomName: selectedClass['room'],
        );

        if (student != null) {
          print('✅ Student ID: ${student.id}');

          // Enrollment yaratish
          try {
            await Supabase.instance.client.from('enrollments').insert({
              'student_id': student.id,
              'class_id': selectedClass['id'],
              'enrolled_at': DateTime.now().toIso8601String(),
              'is_active': true,
              'academic_year_id': selectedClass['academic_year_id'],
              'created_by': currentUser.id,
              'custom_monthly_fee':
                  double.tryParse(
                    monthlyFeeController.text.replaceAll(',', ''),
                  ) ??
                  0.0,
              'custom_discount_percent':
                  double.tryParse(discountPercentController.text) ?? 0.0,
            });
          } catch (e) {
            print('❌ Enrollment yozishda xato: $e');
          }

          // Rasmni yangilash (agar yuklangan bo'lsa va createStudent da ketmagan bo'lsa)
          if (uploadedPhotoUrl != null) {
            await _studentRepo.updateStudent(
              studentId: student.id,
              photoUrl: uploadedPhotoUrl,
            );
          }

          Get.snackbar(
            'Muvaffaqiyatli',
            'O\'quvchi ${selectedClassName.value} sinfiga qabul qilindi',
            backgroundColor: Colors.green.shade100,
            colorText: Colors.green.shade900,
          );

          // Visitor dan kelgan bo'lsa
          if (selectedVisitorId.value != null) {
            Get.back(result: true);
          } else {
            Get.offNamed(AppRoutes.studentDetail, arguments: student.id);
          }
        }
      }
    } catch (e) {
      print('❌ Umumiy xatolik: $e');
      _showError('Xatolik', 'Saqlashda xatolik: $e');
    } finally {
      isSaving.value = false;
    }
  }

  bool _validateForm() {
    // ... (Asl kodingiz)
    final currentUser = _authController.currentUser.value;

    if (currentUser?.branchId != null) {
      if (selectedBranchId.value != currentUser!.branchId) {
        _showError('Xatolik', 'Filial noto\'g\'ri tanlangan!');
        selectedBranchId.value = currentUser.branchId;
        return false;
      }
    }

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
    _clearStudentInfo(); // Endi bu yerda ham ishlatsa bo'ladi
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

  void changeSelectionMode(String mode) {
    selectionMode.value = mode;
    _clearSelection();
  }
}
