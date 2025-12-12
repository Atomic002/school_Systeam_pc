// lib/presentation/screens/class/add_class_screen/add_class_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../widgets/sidebar.dart';
import '../../../controllers/add_class_controller.dart';

class AddClassScreen extends StatelessWidget {
  AddClassScreen({Key? key}) : super(key: key);

  final AddClassController controller = Get.put(AddClassController());

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
                      child: _buildForm(),
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
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF4CAF50)),
                onPressed: () => Get.back(),
              ),
              const SizedBox(width: 16),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Yangi sinf qo\'shish',
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

  Widget _buildForm() {
    return Form(
      key: controller.formKey,
      child: Column(
        children: [
          _buildBasicInfo(),
          const SizedBox(height: 24),
          _buildAcademicInfo(),
          const SizedBox(height: 24),
          _buildRoomAndTeacher(),
          const SizedBox(height: 24),
          _buildFinancialInfo(),
          const SizedBox(height: 24),
          _buildAssignSection(),
          const SizedBox(height: 32),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildBasicInfo() {
    return _buildCard(
      title: 'Asosiy ma\'lumotlar',
      icon: Icons.info,
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
                        color: Color(0xFF4CAF50),
                      ),
                      border: OutlineInputBorder(),
                    ),
                    items: controller.branches.map((branch) {
                      return DropdownMenuItem<String?>(
                        value: branch['id'],
                        child: Text(branch['name']),
                      );
                    }).toList(),
                    onChanged: (value) =>
                        controller.selectedBranchId.value = value,
                    validator: (v) => v == null ? 'Filialni tanlang' : null,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: controller.nameController,
                  decoration: const InputDecoration(
                    labelText: 'Sinf nomi *',
                    prefixIcon: Icon(Icons.school, color: Color(0xFF4CAF50)),
                    border: OutlineInputBorder(),
                    hintText: 'Masalan: 1-A',
                  ),
                  validator: (v) =>
                      v?.isEmpty ?? true ? 'Sinf nomini kiriting' : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: controller.codeController,
                  decoration: const InputDecoration(
                    labelText: 'Kod',
                    prefixIcon: Icon(Icons.qr_code, color: Color(0xFF4CAF50)),
                    border: OutlineInputBorder(),
                    hintText: 'Masalan: 1-A-2024',
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
                  () => DropdownButtonFormField<String?>(
                    value: controller.selectedClassLevelId.value,
                    decoration: const InputDecoration(
                      labelText: 'Sinf darajasi *',
                      prefixIcon: Icon(Icons.stairs, color: Color(0xFF4CAF50)),
                      border: OutlineInputBorder(),
                    ),
                    items: controller.classLevels.map((level) {
                      return DropdownMenuItem<String?>(
                        value: level['id'],
                        child: Text(level['name']),
                      );
                    }).toList(),
                    onChanged: (value) =>
                        controller.selectedClassLevelId.value = value,
                    validator: (v) =>
                        v == null ? 'Sinf darajasini tanlang' : null,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: controller.maxStudentsController,
                  decoration: const InputDecoration(
                    labelText: 'Maksimal o\'quvchilar *',
                    prefixIcon: Icon(Icons.people, color: Color(0xFF4CAF50)),
                    border: OutlineInputBorder(),
                    hintText: '30',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (v) => v?.isEmpty ?? true ? 'Soni kiriting' : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: controller.specializationController,
                  decoration: const InputDecoration(
                    labelText: 'Mutaxassislik',
                    prefixIcon: Icon(Icons.stars, color: Color(0xFF4CAF50)),
                    border: OutlineInputBorder(),
                    hintText: 'Masalan: Matematika chuqurlashtirilgan',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAcademicInfo() {
    return _buildCard(
      title: 'O\'quv yili',
      icon: Icons.calendar_today,
      child: Row(
        children: [
          Expanded(
            child: Obx(
              () => DropdownButtonFormField<String?>(
                value: controller.selectedAcademicYearId.value,
                decoration: const InputDecoration(
                  labelText: 'O\'quv yili *',
                  prefixIcon: Icon(
                    Icons.calendar_month,
                    color: Color(0xFF4CAF50),
                  ),
                  border: OutlineInputBorder(),
                ),
                items: controller.academicYears.map((year) {
                  return DropdownMenuItem<String?>(
                    value: year['id'],
                    child: Row(
                      children: [
                        Text(year['name']),
                        if (year['is_current'] == true) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4CAF50),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Joriy',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) =>
                    controller.selectedAcademicYearId.value = value,
                validator: (v) => v == null ? 'O\'quv yilini tanlang' : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomAndTeacher() {
    return _buildCard(
      title: 'Xona va sinf rahbari',
      icon: Icons.meeting_room,
      child: Row(
        children: [
          Expanded(
            child: Obx(() {
              final rooms = controller.availableRooms;
              return DropdownButtonFormField<String?>(
                value: controller.selectedRoomId.value,
                decoration: const InputDecoration(
                  labelText: 'Asosiy xona',
                  prefixIcon: Icon(
                    Icons.meeting_room,
                    color: Color(0xFF4CAF50),
                  ),
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('Xona tanlanmagan'),
                  ),
                  ...rooms.map((room) {
                    return DropdownMenuItem<String?>(
                      value: room['id'],
                      child: Text(
                        '${room['name']} (${room['capacity']} kishi)',
                      ),
                    );
                  }).toList(),
                ],
                onChanged: (value) => controller.selectedRoomId.value = value,
              );
            }),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Obx(() {
              final teachers = controller.availableTeachers;
              return DropdownButtonFormField<String?>(
                value: controller.selectedMainTeacherId.value,
                decoration: const InputDecoration(
                  labelText: 'Sinf rahbari',
                  prefixIcon: Icon(Icons.person, color: Color(0xFF4CAF50)),
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('O\'qituvchi tanlanmagan'),
                  ),
                  ...teachers.map((teacher) {
                    return DropdownMenuItem<String?>(
                      value: teacher['id'],
                      child: Text(
                        '${teacher['first_name']} ${teacher['last_name']}',
                      ),
                    );
                  }).toList(),
                ],
                onChanged: (value) =>
                    controller.selectedMainTeacherId.value = value,
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialInfo() {
    return _buildCard(
      title: 'Moliyaviy ma\'lumotlar',
      icon: Icons.attach_money,
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: controller.monthlyFeeController,
              decoration: const InputDecoration(
                labelText: 'Oylik to\'lov (so\'m) *',
                prefixIcon: Icon(Icons.money, color: Color(0xFF4CAF50)),
                border: OutlineInputBorder(),
                hintText: '900000',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (v) =>
                  v?.isEmpty ?? true ? 'To\'lovni kiriting' : null,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFF4CAF50).withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Potensial oylik daromad:',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Obx(() {
                    final total =
                        controller.monthlyFee.value *
                        controller.maxStudents.value;
                    return Text(
                      '${_formatCurrency(total)} so\'m',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4CAF50),
                      ),
                    );
                  }),
                  const SizedBox(height: 4),
                  const Text(
                    '(Oylik to\'lov × Maksimal o\'quvchilar)',
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssignSection() {
    return _buildCard(
      title: 'O\'qituvchilar va o\'quvchilarni biriktirish',
      icon: Icons.link,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // O'qituvchilar
          const Text(
            'O\'qituvchilarni biriktirish',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Obx(() {
            final teachers = controller.availableTeachers;
            if (teachers.isEmpty) {
              return const Text(
                'Avval filialni tanlang',
                style: TextStyle(color: Colors.grey),
              );
            }
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: teachers.map((teacher) {
                final id = teacher['id'] as String;
                final name = '${teacher['first_name']} ${teacher['last_name']}';
                final isSelected = controller.selectedTeachers.contains(id);
                final isMainTeacher =
                    controller.selectedMainTeacherId.value == id;
                return FilterChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(name),
                      if (isMainTeacher) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.star, size: 14, color: Colors.amber),
                      ],
                    ],
                  ),
                  selected: isSelected,
                  onSelected: (_) => controller.toggleTeacher(id),
                  selectedColor: Colors.blue.withOpacity(0.2),
                  checkmarkColor: Colors.blue,
                );
              }).toList(),
            );
          }),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 24),

          // O'quvchilar
          Row(
            children: [
              const Expanded(
                child: Text(
                  'O\'quvchilarni biriktirish',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              OutlinedButton.icon(
                onPressed: controller.showStudentSelectionDialog,
                icon: const Icon(Icons.person_search, size: 18),
                label: const Text('O\'quvchi qidirish'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF4CAF50),
                  side: const BorderSide(color: Color(0xFF4CAF50)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Obx(() {
            final students = controller.selectedStudentsData;
            if (students.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: const Center(
                  child: Text(
                    'Hali o\'quvchilar tanlanmagan\nYuqoridagi tugma orqali o\'quvchi qo\'shing',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              );
            }
            return Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: students.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final student = students[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF4CAF50),
                      child: Text(
                        student['first_name'][0],
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(
                      '${student['first_name']} ${student['last_name']}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    subtitle: Text(
                      student['phone'] ?? '',
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () => controller.removeStudent(student['id']),
                    ),
                  );
                },
              ),
            );
          }),
        ],
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
            side: const BorderSide(color: Color(0xFF4CAF50)),
          ),
          child: const Text('Bekor qilish'),
        ),
        const SizedBox(width: 16),
        Obx(
          () => ElevatedButton(
            onPressed: controller.isSaving.value ? null : controller.saveClass,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
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
                  color: const Color(0xFF4CAF50).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: const Color(0xFF4CAF50)),
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

  String _formatCurrency(double amount) {
    return amount
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
  }
}
