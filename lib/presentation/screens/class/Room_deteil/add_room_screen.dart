// lib/presentation/screens/rooms_classes/add_room_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/presentation/controllers/add_room_controller.dart';
import 'package:flutter_application_1/presentation/widgets/sidebar.dart';
import 'package:get/get.dart';

class AddRoomScreen extends StatelessWidget {
  AddRoomScreen({Key? key}) : super(key: key);

  final AddRoomController controller = Get.put(AddRoomController());

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
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: _buildForm(),
                  ),
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
                icon: const Icon(Icons.arrow_back, color: Color(0xFF2196F3)),
                onPressed: () => Get.back(),
              ),
              const SizedBox(width: 16),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Yangi xona qo\'shish',
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
          _buildEquipmentSection(),
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
                        color: Color(0xFF2196F3),
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
                    labelText: 'Xona nomi *',
                    prefixIcon: Icon(
                      Icons.meeting_room,
                      color: Color(0xFF2196F3),
                    ),
                    border: OutlineInputBorder(),
                    hintText: 'Masalan: 101-xona',
                  ),
                  validator: (v) =>
                      v?.isEmpty ?? true ? 'Xona nomini kiriting' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: controller.capacityController,
                  decoration: const InputDecoration(
                    labelText: 'Sig\'im (kishi) *',
                    prefixIcon: Icon(Icons.people, color: Color(0xFF2196F3)),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (v) =>
                      v?.isEmpty ?? true ? 'Sig\'imni kiriting' : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: controller.floorController,
                  decoration: const InputDecoration(
                    labelText: 'Qavat *',
                    prefixIcon: Icon(Icons.layers, color: Color(0xFF2196F3)),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (v) =>
                      v?.isEmpty ?? true ? 'Qavatni kiriting' : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Obx(
                  () => DropdownButtonFormField<String>(
                    value: controller.selectedRoomType.value,
                    decoration: const InputDecoration(
                      labelText: 'Xona turi',
                      prefixIcon: Icon(
                        Icons.category,
                        color: Color(0xFF2196F3),
                      ),
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'classroom',
                        child: Text('Dars xonasi'),
                      ),
                      DropdownMenuItem(
                        value: 'lab',
                        child: Text('Laboratoriya'),
                      ),
                      DropdownMenuItem(value: 'gym', child: Text('Sport zali')),
                      DropdownMenuItem(
                        value: 'library',
                        child: Text('Kutubxona'),
                      ),
                      DropdownMenuItem(value: 'office', child: Text('Ofis')),
                      DropdownMenuItem(value: 'other', child: Text('Boshqa')),
                    ],
                    onChanged: (v) =>
                        controller.selectedRoomType.value = v ?? 'classroom',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEquipmentSection() {
    return _buildCard(
      title: 'Jihozlar',
      icon: Icons.devices,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: controller.equipmentController,
            decoration: const InputDecoration(
              labelText: 'Jihozlar',
              prefixIcon: Icon(Icons.devices_other, color: Color(0xFF2196F3)),
              border: OutlineInputBorder(),
              hintText: 'Masalan: Doska, proyektor, kompyuter',
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          const Text(
            'Tez tanlash:',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Obx(
            () => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildEquipmentChip('Doska'),
                _buildEquipmentChip('Proyektor'),
                _buildEquipmentChip('Kompyuter'),
                _buildEquipmentChip('Televizor'),
                _buildEquipmentChip('Konditsioner'),
                _buildEquipmentChip('Wi-Fi'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEquipmentChip(String label) {
    final isSelected = controller.selectedEquipment.contains(label);
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => controller.toggleEquipment(label),
      selectedColor: const Color(0xFF2196F3).withOpacity(0.2),
      checkmarkColor: const Color(0xFF2196F3),
    );
  }

  Widget _buildAssignSection() {
    return _buildCard(
      title: 'Biriktirish',
      icon: Icons.link,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sinflarni biriktirish',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Obx(() {
            final classes = controller.availableClasses;
            if (classes.isEmpty) {
              return const Text(
                'Avval filialni tanlang',
                style: TextStyle(color: Colors.grey),
              );
            }
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: classes.map((cls) {
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
                return FilterChip(
                  label: Text(name),
                  selected: isSelected,
                  onSelected: (_) => controller.toggleTeacher(id),
                  selectedColor: Colors.blue.withOpacity(0.2),
                  checkmarkColor: Colors.blue,
                );
              }).toList(),
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
            side: const BorderSide(color: Color(0xFF2196F3)),
          ),
          child: const Text('Bekor qilish'),
        ),
        const SizedBox(width: 16),
        Obx(
          () => ElevatedButton(
            onPressed: controller.isSaving.value ? null : controller.saveRoom,
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
