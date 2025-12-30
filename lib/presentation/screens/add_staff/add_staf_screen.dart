// lib/presentation/screens/staff/add_staff_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/presentation/controllers/add_staff_controller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../widgets/sidebar.dart';

class AddStaffScreen extends StatelessWidget {
  AddStaffScreen({Key? key}) : super(key: key);

  final AddStaffController controller = Get.put(AddStaffController());

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
                    if (controller.isLoading.value) {
                      return const Center(child: CircularProgressIndicator());
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
              ),
              const SizedBox(width: 16),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Yangi xodim qo\'shish',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Barcha ma\'lumotlarni to\'ldiring',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
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
_buildAvatarPicker(), // <--- 1. MANA SHU YERGA QO'SHILDI
          const SizedBox(height: 24),
          _buildVisitorSelection(),
          const SizedBox(height: 24),
          _buildPersonalInfo(),
          const SizedBox(height: 24),
          _buildJobInfo(),
          const SizedBox(height: 24),
          Obx(() {
            if (controller.isTeacher.value) {
              return Column(
                children: [_buildTeacherInfo(), const SizedBox(height: 24)],
              );
            } else {
              return Column(
                children: [_buildStaffInfo(), const SizedBox(height: 24)],
              );
            }
          }),
          _buildSalaryInfo(),
          const SizedBox(height: 24),
          _buildUserCreation(),
          const SizedBox(height: 24),
          _buildAdditionalInfo(),
          const SizedBox(height: 32),
          _buildActionButtons(),
        ],
      ),
    );
  }
 Widget _buildAvatarPicker() {
    return Center(
      child: Stack(
        children: [
          Obx(() {
            return Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: controller.profileImage.value != null
                  ? ClipOval(
                      child: Image.file(
                        controller.profileImage.value!,
                        fit: BoxFit.cover,
                        width: 120,
                        height: 120,
                      ),
                    )
                  : const Icon(
                      Icons.person,
                      size: 60,
                      color: Colors.grey,
                    ),
            );
          }),
          Positioned(
            bottom: 0,
            right: 0,
            child: Material(
              color: const Color(0xFF2196F3),
              shape: const CircleBorder(),
              elevation: 4,
              child: InkWell(
                onTap: controller.pickImage,
                customBorder: const CircleBorder(),
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildVisitorSelection() {
    return _buildCard(
      title: 'Tashrif buyuruvchidan tanlash',
      icon: Icons.person_search,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Agar xodim avval tashrif buyurgan bo\'lsa, uni tanlang',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 16),
          Obx(() {
            if (controller.isLoadingVisitors.value) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (controller.visitors.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.grey),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Hozircha tashrif buyuruvchilar mavjud emas',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                DropdownButtonFormField<String?>(
                  value: controller.selectedVisitorId.value,
                  decoration: const InputDecoration(
                    labelText: 'Tashrif buyuruvchi',
                    prefixIcon: Icon(Icons.people, color: Color(0xFF2196F3)),
                    border: OutlineInputBorder(),
                    hintText: 'Tanlang...',
                  ),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('Yangi xodim'),
                    ),
                    ...controller.visitors.map((visitor) {
                      return DropdownMenuItem<String?>(
                        value: visitor['id'],
                        child: Text(
                          '${visitor['first_name']} ${visitor['last_name']} - ${visitor['phone']}',
                        ),
                      );
                    }).toList(),
                  ],
                  onChanged: controller.onVisitorSelected,
                ),
                Obx(() {
                  if (controller.selectedVisitorId.value != null) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Ma\'lumotlar avtomatik to\'ldirildi',
                              style: TextStyle(color: Colors.green),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: controller.clearVisitorSelection,
                            icon: const Icon(Icons.clear),
                            label: const Text('Tozalash'),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPersonalInfo() {
    return _buildCard(
      title: 'Shaxsiy ma\'lumotlar',
      icon: Icons.person,
      child: Column(
        children: [
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
                  validator: (v) => v?.isEmpty ?? true ? 'Majburiy' : null,
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
                  validator: (v) => v?.isEmpty ?? true ? 'Majburiy' : null,
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
                      DropdownMenuItem(value: 'male', child: Text('Erkak')),
                      DropdownMenuItem(value: 'female', child: Text('Ayol')),
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
                  onTap: controller.selectBirthDate,
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
                    labelText: 'Telefon *',
                    prefixIcon: Icon(Icons.phone, color: Color(0xFF2196F3)),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (v) => v?.isEmpty ?? true ? 'Majburiy' : null,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: controller.phoneSecondaryController,
                  decoration: const InputDecoration(
                    labelText: 'Qo\'shimcha telefon',
                    prefixIcon: Icon(
                      Icons.phone_android,
                      color: Color(0xFF2196F3),
                    ),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
                  ],
                ),
              ),
              const SizedBox(width: 16),
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
                    prefixIcon: Icon(Icons.map, color: Color(0xFF2196F3)),
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

  Widget _buildJobInfo() {
    return _buildCard(
      title: 'Lavozim va bo\'lim',
      icon: Icons.work,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Obx(
                  () => DropdownButtonFormField<String?>(
                    value: controller.selectedBranchId.value,
                    decoration: const InputDecoration(
                      labelText: 'Filial *',
                      prefixIcon: Icon(
                        Icons.business,
                        color: Color(0xFF2196F3),
                      ),
                      border: OutlineInputBorder(),
                    ),
                    items: controller.branches.map((branch) {
                      return DropdownMenuItem<String?>(
                        value: branch['id'],
                        child: Text(branch['name'] ?? ''),
                      );
                    }).toList(),
                    onChanged: controller.onBranchChanged,
                    validator: (v) => v == null ? 'Majburiy' : null,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: controller.positionController,
                  decoration: const InputDecoration(
                    labelText: 'Lavozim *',
                    prefixIcon: Icon(Icons.badge, color: Color(0xFF2196F3)),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v?.isEmpty ?? true ? 'Majburiy' : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: controller.departmentController,
                  decoration: const InputDecoration(
                    labelText: 'Bo\'lim',
                    prefixIcon: Icon(Icons.category, color: Color(0xFF2196F3)),
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
                child: Obx(
                  () => SwitchListTile(
                    title: const Text('O\'qituvchimi?'),
                    subtitle: const Text(
                      'Agar xodim o\'qituvchi bo\'lsa belgilang',
                    ),
                    value: controller.isTeacher.value,
                    onChanged: (value) => controller.isTeacher.value = value,
                    activeColor: const Color(0xFF2196F3),
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: controller.selectHireDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Ishga qabul qilish sanasi *',
                      prefixIcon: Icon(Icons.event, color: Color(0xFF2196F3)),
                      border: OutlineInputBorder(),
                    ),
                    child: Obx(() {
                      final date = controller.hireDate.value;
                      return Text(
                        date != null
                            ? DateFormat('dd.MM.yyyy').format(date)
                            : 'Sanani tanlang',
                      );
                    }),
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
                  controller: controller.skillsController,
                  decoration: const InputDecoration(
                    labelText: 'Ko\'nikmalar',
                    prefixIcon: Icon(Icons.stars, color: Color(0xFF2196F3)),
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: controller.educationController,
                  decoration: const InputDecoration(
                    labelText: 'Ma\'lumoti',
                    prefixIcon: Icon(Icons.school, color: Color(0xFF2196F3)),
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: controller.experienceController,
                  decoration: const InputDecoration(
                    labelText: 'Tajriba',
                    prefixIcon: Icon(
                      Icons.work_history,
                      color: Color(0xFF2196F3),
                    ),
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTeacherInfo() {
    return _buildCard(
      title: 'O\'qituvchi ma\'lumotlari',
      icon: Icons.school,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'O\'qitiladigan fanlar *',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Obx(
            () => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: controller.subjects.map((subject) {
                final id = subject['id'] as String;
                final name = subject['name'] as String;
                final isSelected = controller.selectedSubjects.contains(id);
                return FilterChip(
                  label: Text(name),
                  selected: isSelected,
                  onSelected: (_) => controller.toggleSubject(id),
                  selectedColor: const Color(0xFF2196F3).withOpacity(0.2),
                  checkmarkColor: const Color(0xFF2196F3),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          Obx(() {
            if (controller.selectedSubjects.isNotEmpty) {
              return DropdownButtonFormField<String>(
                value: controller.primarySubject.value.isEmpty
                    ? null
                    : controller.primarySubject.value,
                decoration: const InputDecoration(
                  labelText: 'Asosiy fan *',
                  prefixIcon: Icon(Icons.star, color: Color(0xFF2196F3)),
                  border: OutlineInputBorder(),
                ),
                items: controller.selectedSubjects.map((subjectId) {
                  return DropdownMenuItem(
                    value: subjectId,
                    child: Text(controller.getSubjectName(subjectId)),
                  );
                }).toList(),
                onChanged: controller.setPrimarySubject,
              );
            }
            return const SizedBox.shrink();
          }),
          const SizedBox(height: 24),
          const Text(
            'Biriktirilgan sinflar',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Obx(() {
            final filteredClasses = controller.filteredClasses;
            if (filteredClasses.isEmpty) {
              return const Text(
                'Avval filialni tanlang',
                style: TextStyle(color: Colors.grey),
              );
            }
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: filteredClasses.map((cls) {
                final id = cls['id'] as String;
                final name = cls['name'] as String;
                final isSelected = controller.selectedClasses.contains(id);
                return FilterChip(
                  label: Text(name),
                  selected: isSelected,
                  onSelected: (_) => controller.toggleClass(id),
                  selectedColor: Colors.green.withOpacity(0.2),
                  checkmarkColor: Colors.green,
                );
              }).toList(),
            );
          }),
          const SizedBox(height: 24),
          const Text(
            'Biriktirilgan xonalar',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Obx(() {
            final filteredRooms = controller.filteredRooms;
            if (filteredRooms.isEmpty) {
              return const Text(
                'Avval filialni tanlang',
                style: TextStyle(color: Colors.grey),
              );
            }
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: filteredRooms.map((room) {
                final id = room['id'] as String;
                final name = room['name'] as String;
                final isSelected = controller.selectedRooms.contains(id);
                return FilterChip(
                  label: Text(name),
                  selected: isSelected,
                  onSelected: (_) => controller.toggleRoom(id),
                  selectedColor: Colors.orange.withOpacity(0.2),
                  checkmarkColor: Colors.orange,
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStaffInfo() {
    return _buildCard(
      title: 'Xodim ma\'lumotlari',
      icon: Icons.business_center,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ish smena *',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Obx(
            () => Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Kunduzgi'),
                    subtitle: const Text('08:00 - 17:00'),
                    value: 'day',
                    groupValue: controller.workShift.value,
                    onChanged: (v) {
                      if (v != null) controller.workShift.value = v;
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Tungi'),
                    subtitle: const Text('20:00 - 08:00'),
                    value: 'night',
                    groupValue: controller.workShift.value,
                    onChanged: (v) {
                      if (v != null) controller.workShift.value = v;
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Moslashuvchan'),
                    subtitle: const Text('Erkin grafik'),
                    value: 'flexible',
                    groupValue: controller.workShift.value,
                    onChanged: (v) {
                      if (v != null) controller.workShift.value = v;
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Mas\'uliyat sohalari',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Obx(
            () => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildResponsibilityChip('Xavfsizlik', 'security'),
                _buildResponsibilityChip('Tozalash', 'cleaning'),
                _buildResponsibilityChip('Oziq-ovqat', 'food'),
                _buildResponsibilityChip('Transport', 'transport'),
                _buildResponsibilityChip('Ta\'mirlash', 'maintenance'),
                _buildResponsibilityChip('Bog\'bon', 'gardening'),
                _buildResponsibilityChip('IT texnik', 'it_support'),
                _buildResponsibilityChip('Buxgalteriya', 'accounting'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponsibilityChip(String label, String id) {
    final isSelected = controller.selectedResponsibilities.contains(id);
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => controller.toggleResponsibility(id),
      selectedColor: Colors.blue.withOpacity(0.2),
      checkmarkColor: Colors.blue,
    );
  }

  Widget _buildSalaryInfo() {
    return _buildCard(
      title: 'Maosh ma\'lumotlari',
      icon: Icons.attach_money,
      child: Column(
        children: [
          Obx(
            () => DropdownButtonFormField<String>(
              value: controller.selectedSalaryType.value,
              decoration: const InputDecoration(
                labelText: 'Maosh turi *',
                prefixIcon: Icon(Icons.payment, color: Color(0xFF2196F3)),
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'monthly', child: Text('Oylik')),
                DropdownMenuItem(value: 'hourly', child: Text('Soatbay')),
                DropdownMenuItem(value: 'daily', child: Text('Kunlik')),
              ],
              onChanged: (v) {
                if (v != null) controller.selectedSalaryType.value = v;
              },
            ),
          ),
          const SizedBox(height: 16),
          Obx(() {
            if (controller.selectedSalaryType.value == 'monthly') {
              return TextFormField(
                controller: controller.baseSalaryController,
                decoration: const InputDecoration(
                  labelText: 'Oylik maosh (so\'m) *',
                  prefixIcon: Icon(Icons.money, color: Color(0xFF2196F3)),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) => v?.isEmpty ?? true ? 'Majburiy' : null,
              );
            } else if (controller.selectedSalaryType.value == 'hourly') {
              return Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: controller.hourlyRateController,
                      decoration: const InputDecoration(
                        labelText: 'Soat haqi (so\'m) *',
                        prefixIcon: Icon(Icons.timer, color: Color(0xFF2196F3)),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (v) => v?.isEmpty ?? true ? 'Majburiy' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: controller.expectedHoursController,
                      decoration: const InputDecoration(
                        labelText: 'Oylik soatlar',
                        prefixIcon: Icon(
                          Icons.access_time,
                          color: Color(0xFF2196F3),
                        ),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                ],
              );
            } else {
              return TextFormField(
                controller: controller.dailyRateController,
                decoration: const InputDecoration(
                  labelText: 'Kunlik maosh (so\'m) *',
                  prefixIcon: Icon(Icons.today, color: Color(0xFF2196F3)),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) => v?.isEmpty ?? true ? 'Majburiy' : null,
              );
            }
          }),
        ],
      ),
    );
  }

  Widget _buildUserCreation() {
    return _buildCard(
      title: 'Tizimga kirish ma\'lumotlari',
      icon: Icons.account_circle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(
            () => SwitchListTile(
              title: const Text(
                'Xodim uchun tizim hisobi yaratish',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: const Text(
                'Agar belgilasangiz, xodim tizimga kirish imkoniyatiga ega bo\'ladi',
              ),
              value: controller.createUser.value,
              onChanged: (value) => controller.createUser.value = value,
              activeColor: const Color(0xFF2196F3),
            ),
          ),
          Obx(() {
            if (!controller.createUser.value) {
              return const SizedBox.shrink();
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(height: 32),
                const Text(
                  'Foydalanuvchi roli *',
                  style: TextStyle(
                    fontSize: 16,

                    // _buildUserCreation metodining davomi
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Obx(
                  () => Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _buildRoleChip(
                        'Administrator',
                        'administrator',
                        Icons.admin_panel_settings,
                        Colors.red,
                      ),
                      _buildRoleChip(
                        'Direktor',
                        'director',
                        Icons.business_center,
                        Colors.purple,
                      ),
                      _buildRoleChip(
                        'O\'qituvchi',
                        'teacher',
                        Icons.school,
                        Colors.blue,
                      ),
                      _buildRoleChip(
                        'Xodim',
                        'staff',
                        Icons.person,
                        Colors.green,
                      ),
                      _buildRoleChip(
                        'Kassa',
                        'cashier',
                        Icons.point_of_sale,
                        Colors.orange,
                      ),
                      _buildRoleChip(
                        'Qabul',
                        'reception',
                        Icons.desk,
                        Colors.teal,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: controller.usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Username *',
                          prefixIcon: Icon(
                            Icons.person_outline,
                            color: Color(0xFF2196F3),
                          ),
                          border: OutlineInputBorder(),
                          hintText: 'firstname.lastname',
                          helperText: 'Avtomatik yaratiladi',
                        ),
                        validator: (v) =>
                            v?.isEmpty ?? true ? 'Majburiy' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Obx(
                        () => TextFormField(
                          controller: controller.passwordController,
                          obscureText: !controller.showPassword.value,
                          decoration: InputDecoration(
                            labelText: 'Parol *',
                            prefixIcon: const Icon(
                              Icons.lock_outline,
                              color: Color(0xFF2196F3),
                            ),
                            border: const OutlineInputBorder(),
                            helperText: 'Kamida 6 ta belgi',
                            suffixIcon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    controller.showPassword.value
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                  onPressed: () =>
                                      controller.showPassword.value =
                                          !controller.showPassword.value,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.refresh),
                                  tooltip: 'Yangi parol yaratish',
                                  onPressed: () {
                                    // Generate password metodi
                                    const chars =
                                        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
                                    final random =
                                        DateTime.now().millisecondsSinceEpoch;
                                    String password = '';
                                    for (int i = 0; i < 8; i++) {
                                      password +=
                                          chars[(random + i) % chars.length];
                                    }
                                    controller.passwordController.text =
                                        password;
                                    controller.confirmPasswordController.text =
                                        password;
                                  },
                                ),
                              ],
                            ),
                          ),
                          validator: (v) {
                            if (v?.isEmpty ?? true) return 'Majburiy';
                            if (v!.length < 6) {
                              return 'Kamida 6 ta belgi';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Obx(
                        () => TextFormField(
                          controller: controller.confirmPasswordController,
                          obscureText: !controller.showConfirmPassword.value,
                          decoration: InputDecoration(
                            labelText: 'Parolni tasdiqlash *',
                            prefixIcon: const Icon(
                              Icons.lock_outline,
                              color: Color(0xFF2196F3),
                            ),
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: Icon(
                                controller.showConfirmPassword.value
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () =>
                                  controller.showConfirmPassword.value =
                                      !controller.showConfirmPassword.value,
                            ),
                          ),
                          validator: (v) {
                            if (v?.isEmpty ?? true) return 'Majburiy';
                            if (v != controller.passwordController.text) {
                              return 'Parollar mos kelmaydi';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    border: Border.all(color: Colors.amber.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.amber),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Xodim saqlangandan so\'ng, kirish ma\'lumotlari ko\'rsatiladi. Ularni xavfsiz joyda saqlang!',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRoleChip(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final isSelected = controller.selectedUserRole.value == value;
    return InkWell(
      onTap: () => controller.selectedUserRole.value = value,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.grey.shade100,
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? color : Colors.grey, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : Colors.grey.shade700,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Icon(Icons.check_circle, color: color, size: 18),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalInfo() {
    return _buildCard(
      title: 'Qo\'shimcha ma\'lumotlar',
      icon: Icons.notes,
      child: TextFormField(
        controller: controller.notesController,
        decoration: const InputDecoration(
          labelText: 'Izohlar',
          prefixIcon: Icon(Icons.note, color: Color(0xFF2196F3)),
          border: OutlineInputBorder(),
        ),
        maxLines: 3,
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton(
          onPressed: () => Get.back(),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            side: const BorderSide(color: Color(0xFF2196F3)),
          ),
          child: const Text('Bekor qilish'),
        ),
        const SizedBox(width: 16),
        Obx(
          () => ElevatedButton(
            onPressed: controller.isSaving.value ? null : controller.saveStaff,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: controller.isSaving.value
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text('Saqlash'),
          ),
        ),
      ],
    );
  }

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
}
