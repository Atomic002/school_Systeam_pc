// lib/presentation/controllers/visitors_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VisitorsController extends GetxController {
  final supabase = Supabase.instance.client;

  // Observable lists
  final RxList<Map<String, dynamic>> visitors = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> filteredVisitors =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> branches = <Map<String, dynamic>>[].obs;

  // Loading states
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;

  // Form controllers
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final middleNameController = TextEditingController();
  final phoneController = TextEditingController();
  final phoneSecondaryController = TextEditingController();
  final addressController = TextEditingController();
  final regionController = TextEditingController();
  final districtController = TextEditingController();
  final interestedCourseController = TextEditingController();
  final desiredPositionController = TextEditingController();
  final skillsController = TextEditingController();
  final experienceController = TextEditingController();
  final educationController = TextEditingController();
  final notesController = TextEditingController();

  // Form fields
  final RxString visitorType = 'student'.obs;
  final RxString gender = 'male'.obs;
  final Rx<DateTime?> birthDate = Rx<DateTime?>(null);
  final RxString source = 'walk_in'.obs;
  final RxnString selectedBranchId = RxnString(null);

  // Filter fields
  final RxString selectedTypeFilter = 'all'.obs;
  final RxString selectedStatusFilter = 'all'.obs;
  final RxString searchQuery = ''.obs;

  // Edit mode
  String? editingVisitorId;
  String _getVisitorTypeEnum(String value) {
    return value; // lowercase uchun
  }

  String _getGenderEnum(String value) {
    return value; // lowercase uchun
  }

  // Statistics
  int get convertedCount =>
      visitors.where((v) => v['is_converted'] == true).length;
  int get pendingCount =>
      visitors.where((v) => v['is_converted'] != true).length;

  @override
  void onInit() {
    super.onInit();
    _initialize();
  }

  Future<void> _initialize() async {
    await fetchBranches();
    await fetchVisitors();
  }

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    middleNameController.dispose();
    phoneController.dispose();
    phoneSecondaryController.dispose();
    addressController.dispose();
    regionController.dispose();
    districtController.dispose();
    interestedCourseController.dispose();
    desiredPositionController.dispose();
    skillsController.dispose();
    experienceController.dispose();
    educationController.dispose();
    notesController.dispose();
    super.onClose();
  }

  // Fetch branches
  Future<void> fetchBranches() async {
    try {
      final response = await supabase
          .from('branches')
          .select()
          .eq('is_active', true)
          .order('is_main', ascending: false);

      branches.value = List<Map<String, dynamic>>.from(response);

      // Auto-select first branch if available and none selected
      if (branches.isNotEmpty &&
          (selectedBranchId.value == null || selectedBranchId.value!.isEmpty)) {
        selectedBranchId.value = branches.first['id'];
      }
    } catch (e) {
      print('Error fetching branches: $e');
      Get.snackbar(
        'Xatolik',
        'Filiallarni yuklashda xatolik: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Fetch all visitors
  Future<void> fetchVisitors() async {
    try {
      isLoading.value = true;

      final response = await supabase
          .from('visitors')
          .select()
          .order('created_at', ascending: false);

      visitors.value = List<Map<String, dynamic>>.from(response);
      applyFilters();
    } catch (e) {
      Get.snackbar(
        'Xatolik',
        'Ma\'lumotlarni yuklashda xatolik: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Apply filters
  void applyFilters() {
    var filtered = visitors.toList();

    // Type filter
    if (selectedTypeFilter.value != 'all') {
      filtered = filtered
          .where((v) => v['visitor_type'] == selectedTypeFilter.value)
          .toList();
    }

    // Status filter
    if (selectedStatusFilter.value == 'converted') {
      filtered = filtered.where((v) => v['is_converted'] == true).toList();
    } else if (selectedStatusFilter.value == 'pending') {
      filtered = filtered.where((v) => v['is_converted'] != true).toList();
    }

    // Search filter
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filtered = filtered.where((v) {
        final firstName = (v['first_name'] ?? '').toString().toLowerCase();
        final lastName = (v['last_name'] ?? '').toString().toLowerCase();
        final phone = (v['phone'] ?? '').toString().toLowerCase();
        return firstName.contains(query) ||
            lastName.contains(query) ||
            phone.contains(query);
      }).toList();
    }

    filteredVisitors.value = filtered;
  }

  // Search
  void searchVisitors(String query) {
    searchQuery.value = query;
    applyFilters();
  }

  // Filter by type
  void filterByType(String? type) {
    if (type != null) {
      selectedTypeFilter.value = type;
      applyFilters();
    }
  }

  // Filter by status
  void filterByStatus(String? status) {
    if (status != null) {
      selectedStatusFilter.value = status;
      applyFilters();
    }
  }

  // Update branch
  void updateBranch(String? branchId) {
    selectedBranchId.value = branchId;
  }

  // Get branch name by ID
  String getBranchName(String? branchId) {
    if (branchId == null) return 'N/A';
    try {
      final branch = branches.firstWhere(
        (b) => b['id'] == branchId,
        orElse: () => <String, dynamic>{},
      );
      return branch['name'] ?? 'N/A';
    } catch (e) {
      return 'N/A';
    }
  }

  // Add new visitor
  // Visitors Controller - addVisitor metodini tuzatish

  // Visitors Controller - addVisitor metodini tuzatish

  Future<void> addVisitor() async {
    if (!_validateForm()) return;

    try {
      isSaving.value = true;

      // TUZATISH: created_by ni butunlay olib tashlaymiz
      final visitorData = {
        'branch_id': selectedBranchId.value,
        'visitor_type': visitorType.value,
        'first_name': firstNameController.text.trim(),
        'last_name': lastNameController.text.trim(),
        'middle_name': middleNameController.text.trim().isEmpty
            ? null
            : middleNameController.text.trim(),
        'gender': gender.value,
        'birth_date': birthDate.value?.toIso8601String().split('T')[0],
        'phone': phoneController.text.trim(),
        'phone_secondary': phoneSecondaryController.text.trim().isEmpty
            ? null
            : phoneSecondaryController.text.trim(),
        'region': regionController.text.trim().isEmpty
            ? null
            : regionController.text.trim(),
        'district': districtController.text.trim().isEmpty
            ? null
            : districtController.text.trim(),
        'address': addressController.text.trim().isEmpty
            ? null
            : addressController.text.trim(),
        'interested_course': visitorType.value == 'student'
            ? interestedCourseController.text.trim().isEmpty
                  ? null
                  : interestedCourseController.text.trim()
            : null,
        'desired_position': visitorType.value != 'student'
            ? desiredPositionController.text.trim().isEmpty
                  ? null
                  : desiredPositionController.text.trim()
            : null,
        'skills': skillsController.text.trim().isEmpty
            ? null
            : skillsController.text.trim(),
        'experience': experienceController.text.trim().isEmpty
            ? null
            : experienceController.text.trim(),
        'education': educationController.text.trim().isEmpty
            ? null
            : educationController.text.trim(),
        // 'source': source.value, // Vaqtincha o'chirib qo'yamiz - enum muammosi
        'notes': notesController.text.trim().isEmpty
            ? null
            : notesController.text.trim(),
        'visit_date': DateTime.now().toIso8601String().split('T')[0],
        'is_converted': false,
        // created_by ni o'chirdik - database-da nullable
      };

      await supabase.from('visitors').insert(visitorData);

      Get.back();
      _clearForm();
      await fetchVisitors();

      Get.snackbar(
        'Muvaffaqiyat',
        'Tashrif buyuruvchi muvaffaqiyatli qo\'shildi',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Xatolik tafsiloti: $e');
      Get.snackbar(
        'Xatolik',
        'Saqlashda xatolik: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    } finally {
      isSaving.value = false;
    }
  }

  // QOSHIMCHA: updateVisitor metodini ham tuzatish
  Future<void> updateVisitor() async {
    if (!_validateForm() || editingVisitorId == null) return;

    try {
      isSaving.value = true;

      final visitorData = {
        'branch_id': selectedBranchId.value,
        'visitor_type': _getVisitorTypeEnum(visitorType.value),
        'first_name': firstNameController.text.trim(),
        'last_name': lastNameController.text.trim(),
        'middle_name': middleNameController.text.trim().isEmpty
            ? null
            : middleNameController.text.trim(),
        'gender': _getGenderEnum(gender.value),
        'birth_date': birthDate.value?.toIso8601String().split('T')[0],
        'phone': phoneController.text.trim(),
        'phone_secondary': phoneSecondaryController.text.trim().isEmpty
            ? null
            : phoneSecondaryController.text.trim(),
        'region': regionController.text.trim().isEmpty
            ? null
            : regionController.text.trim(),
        'district': districtController.text.trim().isEmpty
            ? null
            : districtController.text.trim(),
        'address': addressController.text.trim().isEmpty
            ? null
            : addressController.text.trim(),
        'interested_course': visitorType.value == 'student'
            ? interestedCourseController.text.trim().isEmpty
                  ? null
                  : interestedCourseController.text.trim()
            : null,
        'desired_position': visitorType.value != 'student'
            ? desiredPositionController.text.trim().isEmpty
                  ? null
                  : desiredPositionController.text.trim()
            : null,
        'skills': skillsController.text.trim().isEmpty
            ? null
            : skillsController.text.trim(),
        'experience': experienceController.text.trim().isEmpty
            ? null
            : experienceController.text.trim(),
        'education': educationController.text.trim().isEmpty
            ? null
            : educationController.text.trim(),
        'notes': notesController.text.trim().isEmpty
            ? null
            : notesController.text.trim(),
      };

      await supabase
          .from('visitors')
          .update(visitorData)
          .eq('id', editingVisitorId!);

      Get.back();
      _clearForm();
      await fetchVisitors();

      Get.snackbar(
        'Muvaffaqiyat',
        'Ma\'lumotlar muvaffaqiyatli yangilandi',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Xatolik tafsiloti: $e');
      Get.snackbar(
        'Xatolik',
        'Yangilashda xatolik: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    } finally {
      isSaving.value = false;
    }
  }

  // Delete visitor
  Future<void> deleteVisitor(String id) async {
    try {
      await supabase.from('visitors').delete().eq('id', id);

      await fetchVisitors();

      Get.snackbar(
        'Muvaffaqiyat',
        'Tashrif buyuruvchi o\'chirildi',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Xatolik',
        'O\'chirishda xatolik: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Convert visitor to student/staff
  Future<void> convertVisitor(Map<String, dynamic> visitor) async {
    try {
      if (visitor['visitor_type'] == 'student') {
        // Navigate to add student screen with visitor data
        Get.toNamed('/add-student', arguments: {'visitor': visitor});
      } else {
        // Navigate to add staff screen with visitor data
        Get.toNamed('/add-staff', arguments: {'visitor': visitor});
      }

      // Mark as converted
      await supabase
          .from('visitors')
          .update({
            'is_converted': true,
            'converted_at': DateTime.now().toIso8601String(),
          })
          .eq('id', visitor['id']);

      await fetchVisitors();
    } catch (e) {
      Get.snackbar(
        'Xatolik',
        'Konvertatsiya qilishda xatolik: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Prepare for editing
  void prepareEdit(Map<String, dynamic> visitor) {
    editingVisitorId = visitor['id'];
    selectedBranchId.value = visitor['branch_id'];
    visitorType.value = visitor['visitor_type'] ?? 'student';
    firstNameController.text = visitor['first_name'] ?? '';
    lastNameController.text = visitor['last_name'] ?? '';
    middleNameController.text = visitor['middle_name'] ?? '';
    phoneController.text = visitor['phone'] ?? '';
    phoneSecondaryController.text = visitor['phone_secondary'] ?? '';
    addressController.text = visitor['address'] ?? '';
    regionController.text = visitor['region'] ?? '';
    districtController.text = visitor['district'] ?? '';
    interestedCourseController.text = visitor['interested_course'] ?? '';
    desiredPositionController.text = visitor['desired_position'] ?? '';
    skillsController.text = visitor['skills'] ?? '';
    experienceController.text = visitor['experience'] ?? '';
    educationController.text = visitor['education'] ?? '';
    notesController.text = visitor['notes'] ?? '';
    gender.value = visitor['gender'] ?? 'male';

    if (visitor['birth_date'] != null) {
      try {
        birthDate.value = DateTime.parse(visitor['birth_date'].toString());
      } catch (e) {
        birthDate.value = null;
      }
    }
  }

  // Select birth date
  Future<void> selectBirthDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          birthDate.value ??
          DateTime.now().subtract(const Duration(days: 7300)),
      firstDate: DateTime(1950),
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

  // Validate form
  bool _validateForm() {
    if (firstNameController.text.trim().isEmpty) {
      Get.snackbar(
        'Xatolik',
        'Ism majburiy',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return false;
    }

    if (lastNameController.text.trim().isEmpty) {
      Get.snackbar(
        'Xatolik',
        'Familiya majburiy',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return false;
    }

    if (phoneController.text.trim().isEmpty) {
      Get.snackbar(
        'Xatolik',
        'Telefon majburiy',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return false;
    }

    return true;
  }

  // Clear form
  void _clearForm() {
    editingVisitorId = null;
    firstNameController.clear();
    lastNameController.clear();
    middleNameController.clear();
    phoneController.clear();
    phoneSecondaryController.clear();
    addressController.clear();
    regionController.clear();
    districtController.clear();
    interestedCourseController.clear();
    desiredPositionController.clear();
    skillsController.clear();
    experienceController.clear();
    educationController.clear();
    notesController.clear();
    visitorType.value = 'student';
    gender.value = 'male';
    birthDate.value = null;
    source.value = 'walk_in';
    // Keep the last used branch selected
  }
}
