// lib/presentation/controllers/branch_controller.dart

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/branch_model.dart';
import '../../data/repositories/branch_repository.dart';

class BranchController extends GetxController {
  final BranchRepository _repository = BranchRepository();

  // Observable ro'yxatlar
  final RxList<BranchModel> branches = <BranchModel>[].obs;
  final RxList<BranchModel> filteredBranches = <BranchModel>[].obs;
  final Rx<BranchModel?> selectedBranch = Rx<BranchModel?>(null);

  // Loading va qidiruv
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;

  // Statistika
  final RxInt totalBranches = 0.obs;
  final RxInt activeBranches = 0.obs;
  final RxInt totalStudentsAllBranches = 0.obs;
  final RxDouble totalRevenueAllBranches = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    loadBranches();
  }

  // Barcha filiallarni yuklash
  Future<void> loadBranches() async {
    try {
      isLoading.value = true;

      // Repository'dan to'liq statistika bilan filiallarni olamiz
      final result = await _repository.getAllBranchesWithStats();

      branches.value = result;
      filteredBranches.value = result;

      _calculateStatistics();
    } catch (e) {
      print('❌ loadBranches error: $e');
      Get.snackbar(
        'Xatolik',
        'Filiallarni yuklashda xatolik: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Filial qidirish
  void searchBranches(String query) {
    searchQuery.value = query;

    if (query.isEmpty) {
      filteredBranches.value = branches;
    } else {
      filteredBranches.value = branches.where((branch) {
        final nameLower = branch.name.toLowerCase();
        final addressLower = branch.address?.toLowerCase() ?? '';
        final phoneLower = branch.phone?.toLowerCase() ?? '';
        final queryLower = query.toLowerCase();

        return nameLower.contains(queryLower) ||
            addressLower.contains(queryLower) ||
            phoneLower.contains(queryLower);
      }).toList();
    }
  }

  // Bitta filial ma'lumotlarini yuklash
  Future<void> loadBranchDetails(String branchId) async {
    try {
      isLoading.value = true;

      final branch = await _repository.getBranchById(branchId);

      if (branch != null) {
        selectedBranch.value = branch;
      }
    } catch (e) {
      print('❌ loadBranchDetails error: $e');
      Get.snackbar(
        'Xatolik',
        'Filial ma\'lumotlarini yuklashda xatolik: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Yangi filial qo'shish
  Future<void> addBranch(BranchModel branch) async {
    try {
      isLoading.value = true;

      final result = await _repository.createBranch(branch);

      if (result != null) {
        // Yangi filial qo'shilgandan keyin barcha filiallarni qayta yuklash
        await loadBranches();

        Get.back();
        Get.snackbar(
          'Muvaffaqiyat',
          'Filial muvaffaqiyatli qo\'shildi',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF4CAF50),
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      print('❌ addBranch error: $e');
      Get.snackbar(
        'Xatolik',
        'Filial qo\'shishda xatolik: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFF44336),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Filialni tahrirlash
  Future<void> updateBranch(String id, BranchModel branch) async {
    try {
      isLoading.value = true;

      final result = await _repository.updateBranch(id, branch);

      if (result != null) {
        // Yangilangandan keyin barcha filiallarni qayta yuklash
        await loadBranches();

        Get.back();
        Get.snackbar(
          'Muvaffaqiyat',
          'Filial muvaffaqiyatli yangilandi',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF4CAF50),
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      print('❌ updateBranch error: $e');
      Get.snackbar(
        'Xatolik',
        'Filialni yangilashda xatolik: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFF44336),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Filial statusini o'zgartirish
  Future<void> toggleBranchStatus(String id) async {
    try {
      final branch = branches.firstWhere((b) => b.id == id);
      final newStatus = !branch.isActive;

      final result = await _repository.updateBranchStatus(id, newStatus);

      if (result != null) {
        final index = branches.indexWhere((b) => b.id == id);
        if (index != -1) {
          branches[index] = result;

          final filteredIndex = filteredBranches.indexWhere((b) => b.id == id);
          if (filteredIndex != -1) {
            filteredBranches[filteredIndex] = result;
          }
        }

        if (selectedBranch.value?.id == id) {
          selectedBranch.value = result;
        }

        _calculateStatistics();

        Get.snackbar(
          'Muvaffaqiyat',
          newStatus ? 'Filial faollashtirildi' : 'Filial to\'xtatildi',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF4CAF50),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('❌ toggleBranchStatus error: $e');
      Get.snackbar(
        'Xatolik',
        'Statusni o\'zgartirishda xatolik: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFF44336),
        colorText: Colors.white,
      );
    }
  }

  // Filialni o'chirish
  Future<void> deleteBranch(String id) async {
    try {
      final branch = branches.firstWhere((b) => b.id == id);

      // Asosiy filialni o'chirish mumkin emas
      if (branch.isMain) {
        Get.back();
        Get.snackbar(
          'Ogohlantirish',
          'Asosiy filialni o\'chirish mumkin emas',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFFF9800),
          colorText: Colors.white,
        );
        return;
      }

      isLoading.value = true;

      final success = await _repository.deleteBranch(id);

      if (success) {
        branches.removeWhere((b) => b.id == id);
        filteredBranches.removeWhere((b) => b.id == id);

        if (selectedBranch.value?.id == id) {
          selectedBranch.value = null;
        }

        _calculateStatistics();

        Get.back();
        Get.snackbar(
          'Muvaffaqiyat',
          'Filial muvaffaqiyatli o\'chirildi',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF4CAF50),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('❌ deleteBranch error: $e');
      Get.back();
      Get.snackbar(
        'Xatolik',
        'Filialni o\'chirishda xatolik: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFF44336),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Umumiy statistikani hisoblash
  void _calculateStatistics() {
    totalBranches.value = branches.length;
    activeBranches.value = branches.where((b) => b.isActive).length;

    totalStudentsAllBranches.value = branches.fold(
      0,
      (sum, branch) => sum + (branch.totalStudents ?? 0),
    );

    totalRevenueAllBranches.value = branches.fold(
      0.0,
      (sum, branch) => sum + (branch.yearlyRevenue ?? 0.0),
    );
  }

  // Filiallar bo'yicha filter
  List<BranchModel> getBranchesByStatus(bool isActive) {
    return branches.where((b) => b.isActive == isActive).toList();
  }

  // Asosiy filialni topish
  BranchModel? getMainBranch() {
    try {
      return branches.firstWhere((b) => b.isMain);
    } catch (e) {
      return null;
    }
  }

  // Eng ko'p o'quvchili filial
  BranchModel? getBranchWithMostStudents() {
    if (branches.isEmpty) return null;

    return branches.reduce(
      (current, next) =>
          (current.totalStudents ?? 0) > (next.totalStudents ?? 0)
              ? current
              : next,
    );
  }

  // Eng yuqori daromadli filial
  BranchModel? getBranchWithHighestRevenue() {
    if (branches.isEmpty) return null;

    return branches.reduce(
      (current, next) =>
          (current.yearlyRevenue ?? 0) > (next.yearlyRevenue ?? 0)
              ? current
              : next,
    );
  }

  // Validatsiya funksiyalari
  String? validateBranchName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Filial nomini kiriting';
    }
    if (value.length < 3) {
      return 'Filial nomi kamida 3 ta belgidan iborat bo\'lishi kerak';
    }
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Telefon ixtiyoriy
    }

    // O'zbekiston telefon raqami formati
    final phoneRegex = RegExp(r'^\+998[0-9]{9}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Noto\'g\'ri telefon format (+998XXXXXXXXX)';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Email ixtiyoriy
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Noto\'g\'ri email format';
    }
    return null;
  }

  // Saralash
  void sortBranches(String sortBy) {
    switch (sortBy) {
      case 'name':
        filteredBranches.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'students':
        filteredBranches.sort(
          (a, b) => (b.totalStudents ?? 0).compareTo(a.totalStudents ?? 0),
        );
        break;
      case 'revenue':
        filteredBranches.sort(
          (a, b) => (b.yearlyRevenue ?? 0).compareTo(a.yearlyRevenue ?? 0),
        );
        break;
      case 'created':
        filteredBranches.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      default:
        filteredBranches.sort((a, b) => a.name.compareTo(b.name));
    }
  }

  // Refresh
  Future<void> refresh() async {
    await loadBranches();
  }

  @override
  void onClose() {
    // Cleanup
    super.onClose();
  }
}