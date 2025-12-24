// lib/screens/students/add_student_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/add_student_controller.dart';
import '../../widgets/sidebar.dart';

class AddStudentScreen extends StatelessWidget {
  AddStudentScreen({Key? key}) : super(key: key);

  final AddStudentController controller = Get.put(AddStudentController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Row(
        children: [
          Sidebar(),
          Expanded(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: Obx(() {
                    if (controller.showBranchSelector.value) {
                      return _buildBranchSelector();
                    }
                    if (controller.isLoading.value) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF2196F3),
                        ),
                      );
                    }
                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: _buildFormContent(),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF2196F3)),
                onPressed: () => Get.back(),
                tooltip: 'Orqaga',
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Yangi o\'quvchi qo\'shish',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Obx(() {
                      if (controller.selectedBranchName.value.isNotEmpty) {
                        return Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 16,
                              color: Color(0xFF2196F3),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Filial: ${controller.selectedBranchName.value}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF2196F3),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () => controller.changeBranch(),
                              child: const Text(
                                'O\'zgartirish',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF2196F3),
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        );
                      }
                      return const Text(
                        'Filialni tanlang',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBranchSelector() {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        padding: const EdgeInsets.all(24),
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2196F3).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.business,
                    size: 48,
                    color: Color(0xFF2196F3),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Filialni tanlang',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'O\'quvchi qaysi filialga tegishli bo\'lishini tanlang',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 32),
                Obx(() {
                  if (controller.branches.isEmpty) {
                    return Column(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 48,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Filiallar topilmadi',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ],
                    );
                  }
                  return Column(
                    children: controller.branches.map((branch) {
                      return _buildBranchCard(branch);
                    }).toList(),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBranchCard(Map<String, dynamic> branch) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => controller.selectBranch(branch['id']),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF2196F3).withOpacity(0.3)),
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2196F3).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.location_city,
                  color: Color(0xFF2196F3),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      branch['name'] ?? '',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    if (branch['address'] != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        branch['address'],
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Color(0xFF2196F3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormContent() {
    return Form(
      key: controller.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (controller.visitors.isNotEmpty) ...[
            _buildVisitorSelection(),
            const SizedBox(height: 24),
          ],
          _buildStudentInfo(),
          const SizedBox(height: 24),
          _buildParentInfo(),
          const SizedBox(height: 24),
          _buildAcademicInfo(),
          const SizedBox(height: 24),
          _buildFinancialInfo(),
          const SizedBox(height: 24),
          _buildAdditionalInfo(),
          const SizedBox(height: 32),
          _buildActionButtons(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildVisitorSelection() {
    return _buildCard(
      title: 'Tashrif buyuruvchilardan tanlash',
      icon: Icons.people_outline,
      child: Obx(() {
        if (controller.visitors.isEmpty) return const SizedBox.shrink();

        return Column(
          children: [
            DropdownButtonFormField<String?>(
              decoration: const InputDecoration(
                labelText: 'Tashrif buyuruvchini tanlang',
                prefixIcon: Icon(Icons.person_search, color: Color(0xFF2196F3)),
                border: OutlineInputBorder(),
              ),
              value: controller.selectedVisitorId.value,
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('Yangi o\'quvchi (visitor\'dan emas)'),
                ),
                ...controller.visitors.map((visitor) {
                  return DropdownMenuItem<String?>(
                    value: visitor.id,
                    child: Text(
                      '${visitor.firstName} ${visitor.lastName} - ${visitor.phone}',
                    ),
                  );
                }),
              ],
              onChanged: (value) => controller.selectVisitor(value),
            ),
            if (controller.selectedVisitorId.value != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2196F3).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Color(0xFF2196F3)),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Visitor ma\'lumotlari avtomatik to\'ldirildi',
                        style: TextStyle(color: Color(0xFF2196F3)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      }),
    );
  }

  // Keyingi qism...
  Widget _buildCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2196F3).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: const Color(0xFF2196F3)),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  // Bu kod add_student_screen.dart faylining davomi

  // _buildStudentInfo metodini qo'shing:
  Widget _buildStudentInfo() {
    return _buildCard(
      title: 'O\'quvchi ma\'lumotlari',
      icon: Icons.person,
      child: Column(
        children: [
          // Rasm yuklash
          Center(
            child: Stack(
              children: [
                Obx(() {
                  if (controller.selectedImage.value != null) {
                    return CircleAvatar(
                      radius: 60,
                      backgroundImage: FileImage(
                        controller.selectedImage.value!,
                      ),
                    );
                  }
                  return CircleAvatar(
                    radius: 60,
                    backgroundColor: const Color(0xFF2196F3).withOpacity(0.1),
                    child: const Icon(
                      Icons.person,
                      size: 60,
                      color: Color(0xFF2196F3),
                    ),
                  );
                }),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF2196F3),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: PopupMenuButton<String>(
                      icon: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                      onSelected: (value) {
                        if (value == 'gallery') {
                          controller.pickImage();
                        } else if (value == 'camera') {
                          controller.takePicture();
                        } else if (value == 'remove') {
                          controller.removeImage();
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'gallery',
                          child: Row(
                            children: [
                              Icon(
                                Icons.photo_library,
                                color: Color(0xFF2196F3),
                              ),
                              SizedBox(width: 12),
                              Text('Galereyadan tanlash'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'camera',
                          child: Row(
                            children: [
                              Icon(Icons.camera, color: Color(0xFF2196F3)),
                              SizedBox(width: 12),
                              Text('Kamera'),
                            ],
                          ),
                        ),
                        if (controller.selectedImage.value != null)
                          const PopupMenuItem(
                            value: 'remove',
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: Colors.red),
                                SizedBox(width: 12),
                                Text('O\'chirish'),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // F.I.O
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: controller.lastNameController,
                  decoration: const InputDecoration(
                    labelText: 'Familiya *',
                    prefixIcon: Icon(Icons.person, color: Color(0xFF2196F3)),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      v?.isEmpty ?? true ? 'Familiyani kiriting' : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: controller.firstNameController,
                  decoration: const InputDecoration(
                    labelText: 'Ism *',
                    prefixIcon: Icon(
                      Icons.person_outline,
                      color: Color(0xFF2196F3),
                    ),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      v?.isEmpty ?? true ? 'Ismni kiriting' : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: controller.middleNameController,
                  decoration: const InputDecoration(
                    labelText: 'Otasining ismi',
                    prefixIcon: Icon(
                      Icons.people_outline,
                      color: Color(0xFF2196F3),
                    ),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Jinsi, Tug'ilgan sana, Telefon
          Row(
            children: [
              Expanded(
                child: Obx(
                  () => DropdownButtonFormField<String>(
                    value: controller.selectedGender.value,
                    decoration: const InputDecoration(
                      labelText: 'Jinsi *',
                      prefixIcon: Icon(Icons.wc, color: Color(0xFF2196F3)),
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'male', child: Text('O\'g\'il')),
                      DropdownMenuItem(value: 'female', child: Text('Qiz')),
                    ],
                    onChanged: (v) {
                      if (v != null) controller.selectedGender.value = v;
                    },
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: InkWell(
                  onTap: () => controller.selectBirthDate(Get.context!),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Tug\'ilgan sana *',
                      prefixIcon: Icon(Icons.cake, color: Color(0xFF2196F3)),
                      border: OutlineInputBorder(),
                    ),
                    child: Obx(() {
                      final date = controller.birthDate.value;
                      return Text(
                        date != null
                            ? DateFormat('dd.MM.yyyy').format(date)
                            : 'Sanani tanlang',
                        style: TextStyle(
                          color: date != null ? Colors.black87 : Colors.grey,
                        ),
                      );
                    }),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: controller.phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Telefon',
                    prefixIcon: Icon(Icons.phone, color: Color(0xFF2196F3)),
                    border: OutlineInputBorder(),
                    hintText: '+998 90 123 45 67',
                  ),
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s]')),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Manzil
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: controller.regionController,
                  decoration: const InputDecoration(
                    labelText: 'Viloyat/Shahar',
                    prefixIcon: Icon(
                      Icons.location_city,
                      color: Color(0xFF2196F3),
                    ),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: controller.districtController,
                  decoration: const InputDecoration(
                    labelText: 'Tuman',
                    prefixIcon: Icon(
                      Icons.location_on,
                      color: Color(0xFF2196F3),
                    ),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: controller.addressController,
            decoration: const InputDecoration(
              labelText: 'To\'liq manzil',
              prefixIcon: Icon(Icons.home, color: Color(0xFF2196F3)),
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  // Ota-ona ma'lumotlari
  Widget _buildParentInfo() {
    return _buildCard(
      title: 'Ota-ona ma\'lumotlari',
      icon: Icons.family_restroom,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: controller.parentLastNameController,
                  decoration: const InputDecoration(
                    labelText: 'Familiya *',
                    prefixIcon: Icon(Icons.person, color: Color(0xFF2196F3)),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      v?.isEmpty ?? true ? 'Familiyani kiriting' : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: controller.parentFirstNameController,
                  decoration: const InputDecoration(
                    labelText: 'Ism *',
                    prefixIcon: Icon(
                      Icons.person_outline,
                      color: Color(0xFF2196F3),
                    ),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      v?.isEmpty ?? true ? 'Ismni kiriting' : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: controller.parentMiddleNameController,
                  decoration: const InputDecoration(
                    labelText: 'Otasining ismi',
                    prefixIcon: Icon(
                      Icons.people_outline,
                      color: Color(0xFF2196F3),
                    ),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: controller.parentPhoneController,
                  decoration: const InputDecoration(
                    labelText: 'Telefon 1 *',
                    prefixIcon: Icon(Icons.phone, color: Color(0xFF2196F3)),
                    border: OutlineInputBorder(),
                    hintText: '+998 90 123 45 67',
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (v) =>
                      v?.isEmpty ?? true ? 'Telefon raqamini kiriting' : null,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s]')),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: controller.parentPhone2Controller,
                  decoration: const InputDecoration(
                    labelText: "Ota-onasining 2-raqami",
                    counterText: "", // Pastdagi sanagich yozuvini yashirish
                    prefixIcon: Icon(
                      Icons.phone_android,
                      color: Color(0xFF2196F3),
                    ),
                    border: OutlineInputBorder(),
                    hintText: '+998 90 123 45 67',
                  ),
                  keyboardType: TextInputType.phone,
                    maxLength: 19, // Maksimum 19 ta belgi

                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s]')),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Obx(
                  () => DropdownButtonFormField<String>(
                    value: controller.parentRelation.value,
                    decoration: const InputDecoration(
                      labelText: 'Kim hisoblanadi',
                      prefixIcon: Icon(
                        Icons.family_restroom,
                        color: Color(0xFF2196F3),
                      ),
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Otasi', child: Text('Otasi')),
                      DropdownMenuItem(value: 'Onasi', child: Text('Onasi')),
                      DropdownMenuItem(value: 'Buvisi', child: Text('Buvisi')),
                      DropdownMenuItem(value: 'Bobosi', child: Text('Bobosi')),
                      DropdownMenuItem(
                        value: 'Amakisi',
                        child: Text('Amakisi'),
                      ),
                      DropdownMenuItem(value: 'Xolasi', child: Text('Xolasi')),
                    ],
                    onChanged: (v) {
                      if (v != null) controller.parentRelation.value = v;
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: controller.parentWorkplaceController,
            decoration: const InputDecoration(
              labelText: 'Ish joyi',
              prefixIcon: Icon(Icons.work, color: Color(0xFF2196F3)),
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }

  // Bu kod add_student_screen.dart faylining davomi

  Widget _buildAcademicInfo() {
    return _buildCard(
      title: 'Sinf va o\'quv ma\'lumotlari',
      icon: Icons.school,
      child: Column(
        children: [
          // Tanlash usulini tanlash
          Obx(
            () => Row(
              children: [
                Expanded(
                  child: _buildSelectionModeButton(
                    icon: Icons.class_,
                    label: 'Sinf orqali',
                    mode: 'class',
                    isSelected: controller.selectionMode.value == 'class',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSelectionModeButton(
                    icon: Icons.person,
                    label: 'O\'qituvchi orqali',
                    mode: 'teacher',
                    isSelected: controller.selectionMode.value == 'teacher',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSelectionModeButton(
                    icon: Icons.meeting_room,
                    label: 'Xona orqali',
                    mode: 'room',
                    isSelected: controller.selectionMode.value == 'room',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Tanlash bo'limi
          Obx(() {
            switch (controller.selectionMode.value) {
              case 'class':
                return _buildClassSelection();
              case 'teacher':
                return _buildTeacherSelection();
              case 'room':
                return _buildRoomSelection();
              default:
                return _buildClassSelection();
            }
          }),

          const SizedBox(height: 20),

          // Tanlangan ma'lumotlarni ko'rsatish
          Obx(() {
            if (controller.selectedClassId.value == null) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Iltimos, sinf ma\'lumotlarini tanlang',
                        style: TextStyle(color: Colors.orange),
                      ),
                    ),
                  ],
                ),
              );
            }

            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF2196F3).withOpacity(0.1),
                    const Color(0xFF2196F3).withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF2196F3).withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2196F3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.check_circle,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Text(
                          'Tanlangan ma\'lumotlar',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2196F3),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (controller.selectedClassName.value.isNotEmpty)
                    _buildSelectedInfoRow(
                      icon: Icons.class_,
                      label: 'Sinf:',
                      value: controller.selectedClassName.value,
                    ),
                  if (controller.selectedTeacherName.value.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildSelectedInfoRow(
                      icon: Icons.person,
                      label: 'Sinf rahbari:',
                      value: controller.selectedTeacherName.value,
                    ),
                  ],
                  if (controller.selectedClassRoom.value.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildSelectedInfoRow(
                      icon: Icons.meeting_room,
                      label: 'Xona:',
                      value: controller.selectedClassRoom.value,
                    ),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSelectionModeButton({
    required IconData icon,
    required String label,
    required String mode,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () => controller.changeSelectionMode(mode),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF2196F3)
              : const Color(0xFF2196F3).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF2196F3)
                : const Color(0xFF2196F3).withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : const Color(0xFF2196F3),
              size: 20,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF2196F3),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 13,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassSelection() {
    return Obx(
      () => Column(
        children: [
          DropdownButtonFormField<String?>(
            value: controller.selectedClassLevelId.value,
            decoration: const InputDecoration(
              labelText: 'Sinf darajasi *',
              prefixIcon: Icon(Icons.stairs, color: Color(0xFF2196F3)),
              border: OutlineInputBorder(),
            ),
            items: controller.classLevels.map((level) {
              return DropdownMenuItem<String?>(
                value: level['id'],
                child: Text(level['name']!),
              );
            }).toList(),
            onChanged: (v) => controller.selectClass(v),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String?>(
            value: controller.selectedClassId.value,
            decoration: const InputDecoration(
              labelText: 'Sinf *',
              prefixIcon: Icon(Icons.class_, color: Color(0xFF2196F3)),
              border: OutlineInputBorder(),
            ),
            items: controller.filteredClasses.map((cls) {
              return DropdownMenuItem<String?>(
                value: cls['id'],
                child: Text('${cls['name']} (${cls['teacher']})'),
              );
            }).toList(),
            onChanged: (v) => controller.selectClass(v),
            validator: (v) => v == null ? 'Sinf tanlang' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildTeacherSelection() {
    return Obx(
      () => DropdownButtonFormField<String?>(
        value: controller.selectedTeacherId.value,
        decoration: const InputDecoration(
          labelText: 'Sinf rahbarini tanlang *',
          prefixIcon: Icon(Icons.person, color: Color(0xFF2196F3)),
          border: OutlineInputBorder(),
          helperText:
              'O\'qituvchini tanlaganda uning sinfi va xonasi avtomatik tanlanadi',
        ),
        items: controller.teachers.map((teacher) {
          return DropdownMenuItem<String?>(
            value: teacher['id'],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  teacher['full_name']!,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                if (teacher['class_name'] != null)
                  Text(
                    'Sinf: ${teacher['class_name']} | Xona: ${teacher['room_name'] ?? "Yo\'q"}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
              ],
            ),
          );
        }).toList(),
        onChanged: (v) => controller.selectTeacher(v),
        validator: (v) => v == null ? 'O\'qituvchini tanlang' : null,
      ),
    );
  }

  Widget _buildRoomSelection() {
    return Obx(
      () => DropdownButtonFormField<String?>(
        value: controller.selectedRoomId.value,
        decoration: const InputDecoration(
          labelText: 'Xonani tanlang *',
          prefixIcon: Icon(Icons.meeting_room, color: Color(0xFF2196F3)),
          border: OutlineInputBorder(),
          helperText:
              'Xonani tanlaganda shu xonadagi sinf va o\'qituvchi avtomatik tanlanadi',
        ),
        items: controller.rooms.map((room) {
          return DropdownMenuItem<String?>(
            value: room['id'],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  room['name']!,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                if (room['class_name'] != null)
                  Text(
                    'Sinf: ${room['class_name']} | O\'qituvchi: ${room['teacher_name'] ?? "Yo\'q"}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
              ],
            ),
          );
        }).toList(),
        onChanged: (v) => controller.selectRoom(v),
        validator: (v) => v == null ? 'Xonani tanlang' : null,
      ),
    );
  }

  Widget _buildSelectedInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF2196F3), size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xFF2196F3),
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  // Bu kod add_student_screen.dart faylining davomi

  Widget _buildFinancialInfo() {
    return _buildCard(
      title: 'Moliyaviy ma\'lumotlar',
      icon: Icons.attach_money,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: controller.monthlyFeeController,
                  decoration: const InputDecoration(
                    labelText: 'Oylik to\'lov (so\'m) *',
                    prefixIcon: Icon(Icons.payments, color: Color(0xFF2196F3)),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (v) =>
                      v?.isEmpty ?? true ? 'To\'lovni kiriting' : null,
                  onChanged: (_) => controller.updateDiscountAmount(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: controller.discountPercentController,
                  decoration: const InputDecoration(
                    labelText: 'Chegirma (%)',
                    prefixIcon: Icon(Icons.percent, color: Color(0xFF2196F3)),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (_) => controller.updateDiscountAmount(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: controller.discountAmountController,
                  decoration: const InputDecoration(
                    labelText: 'Chegirma miqdori',
                    prefixIcon: Icon(Icons.money_off, color: Color(0xFF2196F3)),
                    border: OutlineInputBorder(),
                  ),
                  readOnly: true,
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: controller.discountReasonController,
            decoration: const InputDecoration(
              labelText: 'Chegirma sababi',
              prefixIcon: Icon(Icons.description, color: Color(0xFF2196F3)),
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          Obx(() {
            final finalAmount = controller.finalMonthlyFee.value;
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF2196F3).withOpacity(0.2),
                    const Color(0xFF2196F3).withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Yakuniy oylik to\'lov:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2196F3),
                    ),
                  ),
                  Text(
                    '${NumberFormat('#,###').format(finalAmount)} so\'m',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2196F3),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAdditionalInfo() {
    return _buildCard(
      title: 'Qo\'shimcha ma\'lumotlar',
      icon: Icons.notes,
      child: Column(
        children: [
          TextFormField(
            controller: controller.medicalNotesController,
            decoration: const InputDecoration(
              labelText: 'Tibbiy ma\'lumotlar',
              prefixIcon: Icon(
                Icons.medical_services,
                color: Color(0xFF2196F3),
              ),
              border: OutlineInputBorder(),
              hintText: 'Allergiyalar, xronik kasalliklar va h.k.',
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: controller.notesController,
            decoration: const InputDecoration(
              labelText: 'Izohlar',
              prefixIcon: Icon(Icons.note, color: Color(0xFF2196F3)),
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          OutlinedButton.icon(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.close),
            label: const Text('Bekor qilish'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              side: const BorderSide(color: Color(0xFF2196F3)),
              foregroundColor: const Color(0xFF2196F3),
            ),
          ),
          const SizedBox(width: 16),
          Obx(
            () => ElevatedButton.icon(
              onPressed: controller.isSaving.value
                  ? null
                  : () => controller.saveStudent(),
              icon: controller.isSaving.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.save),
              label: Text(
                controller.isSaving.value ? 'Saqlanmoqda...' : 'Saqlash',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                disabledBackgroundColor: const Color(
                  0xFF2196F3,
                ).withOpacity(0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
