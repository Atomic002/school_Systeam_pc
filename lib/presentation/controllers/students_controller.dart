// lib/presentation/controllers/students_controller.dart
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/repositories/student_repositry.dart';
import 'package:get/get.dart';
import '../../data/models/student_model.dart';
import 'auth_controller.dart';

class StudentsController extends GetxController {
  final StudentRepository _repository = StudentRepository();
  final AuthController _authController = Get.find<AuthController>();

  final RxList<StudentModel> students = <StudentModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxInt totalCount = 0.obs;
  final RxInt currentPage = 1.obs;
  final RxString searchQuery = ''.obs;
  final Rx<String?> selectedStatus = Rx<String?>(null);

  final int itemsPerPage = 20;

  @override
  void onInit() {
    super.onInit();
    loadStudents();
  }

  Future<void> loadStudents() async {
    try {
      isLoading.value = true;

      final branchId = _authController.currentUser.value?.branchId;
      if (branchId == null) return;

      final offset = (currentPage.value - 1) * itemsPerPage;

      final result = await _repository.getStudents(
        branchId: branchId,
        status: selectedStatus.value,
        searchQuery: searchQuery.value.isEmpty ? null : searchQuery.value,
        limit: itemsPerPage,
        offset: offset,
      );

      students.value = result;

      final count = await _repository.getStudentsCount(
        branchId: branchId,
        status: selectedStatus.value,
      );
      totalCount.value = count;
    } catch (e) {
      print('Load students xatolik: $e');
      Get.snackbar(
        'Xatolik',
        'O\'quvchilarni yuklashda xatolik',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Color(0xFFFF6B6B).withOpacity(0.1),
        colorText: Color(0xFFFF6B6B),
      );
    } finally {
      isLoading.value = false;
    }
  }

  void searchStudents(String query) {
    searchQuery.value = query;
    currentPage.value = 1;
    loadStudents();
  }

  void setStatusFilter(String? status) {
    selectedStatus.value = status;
    currentPage.value = 1;
    loadStudents();
  }

  void clearStatusFilter() {
    selectedStatus.value = null;
    loadStudents();
  }

  void clearAllFilters() {
    selectedStatus.value = null;
    searchQuery.value = '';
    currentPage.value = 1;
    loadStudents();
  }

  bool get hasActiveFilters {
    return selectedStatus.value != null || searchQuery.value.isNotEmpty;
  }

  void nextPage() {
    if (hasNextPage) {
      currentPage.value++;
      loadStudents();
    }
  }

  void previousPage() {
    if (hasPreviousPage) {
      currentPage.value--;
      loadStudents();
    }
  }

  bool get hasNextPage {
    return currentPage.value * itemsPerPage < totalCount.value;
  }

  bool get hasPreviousPage {
    return currentPage.value > 1;
  }

  Future<void> deleteStudent(String studentId) async {
    try {
      final success = await _repository.deleteStudent(studentId);

      if (success) {
        Get.snackbar(
          'Muvaffaqiyatli',
          'O\'quvchi o\'chirildi',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Color(0xFF06D6A0).withOpacity(0.1),
          colorText: Color(0xFF06D6A0),
          icon: Icon(Icons.check_circle, color: Color(0xFF06D6A0)),
        );
        loadStudents();
      } else {
        Get.snackbar(
          'Xatolik',
          'O\'quvchini o\'chirishda xatolik',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Color(0xFFFF6B6B).withOpacity(0.1),
          colorText: Color(0xFFFF6B6B),
        );
      }
    } catch (e) {
      print('Delete student xatolik: $e');
      Get.snackbar(
        'Xatolik',
        'Xatolik yuz berdi',
        backgroundColor: Color(0xFFFF6B6B).withOpacity(0.1),
        colorText: Color(0xFFFF6B6B),
      );
    }
  }

  Future<void> refreshData() async {
    await loadStudents();
  }
}
