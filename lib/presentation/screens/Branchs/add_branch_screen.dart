// lib/presentation/screens/branches/add_branch_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/presentation/controllers/add_branch_controller.dart';
import 'package:get/get.dart';
import '../../widgets/sidebar.dart';

class AddBranchScreen extends StatelessWidget {
  AddBranchScreen({Key? key}) : super(key: key);

  final AddBranchController controller = Get.put(AddBranchController());

  @override
  Widget build(BuildContext context) {
    final isEditMode = controller.editingBranch != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Row(
        children: [
          Sidebar(),
          Expanded(
            child: Column(
              children: [
                _buildHeader(isEditMode),
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

  Widget _buildHeader(bool isEditMode) {
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEditMode
                        ? 'Filialni tahrirlash'
                        : 'Yangi filial qo\'shish',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isEditMode
                        ? 'Filial ma\'lumotlarini yangilang'
                        : 'Barcha ma\'lumotlarni to\'ldiring',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBasicInfo(),
          const SizedBox(height: 24),
          _buildContactInfo(),
          const SizedBox(height: 24),
          _buildWorkingHours(),
          const SizedBox(height: 24),
          _buildSettings(),
          const SizedBox(height: 32),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildBasicInfo() {
    return _buildCard(
      title: 'Asosiy ma\'lumotlar',
      icon: Icons.business,
      child: Column(
        children: [
          TextFormField(
            controller: controller.nameController,
            decoration: const InputDecoration(
              labelText: 'Filial nomi *',
              prefixIcon: Icon(Icons.business, color: Color(0xFF2196F3)),
              border: OutlineInputBorder(),
              hintText: 'Masalan: Chilonzor filiali',
            ),
            validator: (v) => v?.isEmpty ?? true ? 'Majburiy' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: controller.addressController,
            decoration: const InputDecoration(
              labelText: 'Manzil',
              prefixIcon: Icon(Icons.location_on, color: Color(0xFF2196F3)),
              border: OutlineInputBorder(),
              hintText: 'To\'liq manzil',
            ),
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo() {
    return _buildCard(
      title: 'Aloqa ma\'lumotlari',
      icon: Icons.contacts,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: controller.phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Telefon 1',
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
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: controller.phoneSecondaryController,
                  decoration: const InputDecoration(
                    labelText: 'Telefon 2',
                    prefixIcon: Icon(
                      Icons.phone_android,
                      color: Color(0xFF2196F3),
                    ),
                    border: OutlineInputBorder(),
                    hintText: '+998 91 123 45 67',
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
          TextFormField(
            controller: controller.emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email, color: Color(0xFF2196F3)),
              border: OutlineInputBorder(),
              hintText: 'example@school.uz',
            ),
            keyboardType: TextInputType.emailAddress,
          ),
        ],
      ),
    );
  }

  Widget _buildWorkingHours() {
    return _buildCard(
      title: 'Ish vaqti',
      icon: Icons.access_time,
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => controller.selectTime(true),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Boshlanish vaqti',
                  prefixIcon: Icon(Icons.schedule, color: Color(0xFF2196F3)),
                  border: OutlineInputBorder(),
                ),
                child: Obx(
                  () => Text(
                    controller.workingHoursStart.value,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: InkWell(
              onTap: () => controller.selectTime(false),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Tugash vaqti',
                  prefixIcon: Icon(Icons.schedule, color: Color(0xFF2196F3)),
                  border: OutlineInputBorder(),
                ),
                child: Obx(
                  () => Text(
                    controller.workingHoursEnd.value,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettings() {
    return _buildCard(
      title: 'Sozlamalar',
      icon: Icons.settings,
      child: Column(
        children: [
          Obx(
            () => SwitchListTile(
              value: controller.isMain.value,
              onChanged: (value) => controller.isMain.value = value,
              title: const Text('Asosiy filial'),
              subtitle: const Text(
                'Bu filial asosiy filial sifatida belgilanadi',
              ),
              secondary: const Icon(Icons.home_work, color: Color(0xFF2196F3)),
              activeColor: const Color(0xFF2196F3),
            ),
          ),
          const Divider(),
          Obx(
            () => SwitchListTile(
              value: controller.isActive.value,
              onChanged: (value) => controller.isActive.value = value,
              title: const Text('Faol holat'),
              subtitle: const Text('Faol filiallar tizimda ishlaydi'),
              secondary: const Icon(
                Icons.check_circle,
                color: Color(0xFF4CAF50),
              ),
              activeColor: const Color(0xFF4CAF50),
            ),
          ),
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
            onPressed: controller.isSaving.value
                ? null
                : () => controller.saveBranch(),
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
        borderRadius: BorderRadius.circular(16),
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
