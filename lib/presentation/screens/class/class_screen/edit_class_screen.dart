// lib/presentation/screens/edit_class_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/presentation/controllers/edit_class_controller.dart';
import 'package:flutter_application_1/presentation/widgets/sidebar.dart';
import 'package:get/get.dart';

class EditClassScreen extends StatelessWidget {
  EditClassScreen({Key? key}) : super(key: key);

  final EditClassController controller = Get.put(EditClassController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),
      body: Row(
        children: [
          Sidebar(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              return Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 900),
                        child: Form(
                          key: controller.formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildBasicInfoSection(),
                              const SizedBox(height: 24),
                              _buildLocationSection(),
                              const SizedBox(height: 24),
                              _buildFinanceSection(),
                              const SizedBox(height: 24),
                              _buildStatusSection(),
                              const SizedBox(height: 32),
                              _buildActionButtons(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      color: Colors.white,
      child: Row(
        children: [
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back_ios, size: 20),
            color: Colors.grey[700],
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sinfni Tahrirlash',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2B3674),
                ),
              ),
              Text(
                'Sinf ma\'lumotlarini yangilang',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return _buildSection(
      title: 'Asosiy Ma\'lumotlar',
      icon: Icons.info_outline,
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: controller.nameController,
                decoration: const InputDecoration(
                  labelText: 'Sinf nomi *',
                  hintText: 'Masalan: 10-A',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.class_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Sinf nomini kiriting';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: controller.codeController,
                decoration: const InputDecoration(
                  labelText: 'Sinf kodi',
                  hintText: 'Masalan: 10A-2024',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.qr_code),
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
                  value: controller.selectedClassLevelId.value,
                  decoration: const InputDecoration(
                    labelText: 'Sinf darajasi *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.layers_outlined),
                  ),
                  // ESKI (XATO):
                  // items: controller.classLevels.map((level) { ... }).toList(),

                  // YANGI (TO'G'RI):
                  items: controller.classLevels.map<DropdownMenuItem<String>>((
                    level,
                  ) {
                    return DropdownMenuItem<String>(
                      value: level['id']
                          .toString(), // ID ni String ga o'tkazish
                      child: Text(level['name'] ?? ''),
                    );
                  }).toList(),
                  onChanged: (value) {
                    controller.selectedClassLevelId.value = value;
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Sinf darajasini tanlang';
                    }
                    return null;
                  },
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: controller.maxStudentsController,
                decoration: const InputDecoration(
                  labelText: 'Maksimal o\'quvchilar soni *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.groups),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Maksimal sonni kiriting';
                  }
                  if (int.tryParse(value) == null || int.parse(value) < 1) {
                    return 'Noto\'g\'ri son';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: controller.specializationController,
          decoration: const InputDecoration(
            labelText: 'Mutaxassislik (ixtiyoriy)',
            hintText: 'Masalan: Matematika yo\'nalishi',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.star_border),
          ),
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    return _buildSection(
      title: 'Joylashuv Ma\'lumotlari',
      icon: Icons.location_on_outlined,
      children: [
        Row(
          children: [
            Expanded(
              child: Obx(
                () => DropdownButtonFormField<String>(
                  value: controller.selectedBranchId.value,
                  decoration: const InputDecoration(
                    labelText: 'Filial *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.business),
                  ),
                  // .map dan keyin <DropdownMenuItem<String>> deb yozish SHART
                  items: controller.branches.map<DropdownMenuItem<String>>((
                    branch,
                  ) {
                    return DropdownMenuItem<String>(
                      // Bu yerda ham <String> bo'lishi kerak
                      value: branch['id']
                          .toString(), // ID ni String ga aylantiramiz
                      child: Text(
                        branch['name'] ?? '',
                      ), // Null bo'lsa bo'sh tekst
                    );
                  }).toList(),
                  onChanged: (value) {
                    controller.selectedBranchId.value = value;
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Filialni tanlang';
                    }
                    return null;
                  },
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Obx(
                () => DropdownButtonFormField<String>(
                  value: controller.selectedRoomId.value,
                  decoration: const InputDecoration(
                    labelText: 'Asosiy xona',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.meeting_room),
                  ),
                  // ESKI (XATO):
                  // items: controller.availableRooms.map((room) { ... }).toList(),

                  // YANGI (TO'G'RI):
                  items: controller.availableRooms
                      .map<DropdownMenuItem<String>>((room) {
                        return DropdownMenuItem<String>(
                          value: room['id'].toString(),
                          child: Text(
                            '${room['name']} (${room['capacity']} o\'rin)',
                            overflow:
                                TextOverflow.ellipsis, // Uzun nomlar uchun
                          ),
                        );
                      })
                      .toList(),
                  onChanged: (value) {
                    controller.selectedRoomId.value = value;
                  },
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
                  value: controller.selectedAcademicYearId.value,
                  decoration: const InputDecoration(
                    labelText: 'O\'quv yili *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  // ESKI (XATO):
                  // items: controller.academicYears.map((year) { ... }).toList(),

                  // YANGI (TO'G'RI):
                  items: controller.academicYears.map<DropdownMenuItem<String>>(
                    (year) {
                      return DropdownMenuItem<String>(
                        value: year['id'].toString(),
                        child: Text(year['name'] ?? ''),
                      );
                    },
                  ).toList(),
                  onChanged: (value) {
                    controller.selectedAcademicYearId.value = value;
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'O\'quv yilini tanlang';
                    }
                    return null;
                  },
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Obx(
                () => DropdownButtonFormField<String>(
                  value: controller.selectedMainTeacherId.value,
                  decoration: const InputDecoration(
                    labelText: 'Sinf rahbari',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  // ESKI (XATO):
                  // items: controller.availableTeachers.map((teacher) { ... }).toList(),

                  // YANGI (TO'G'RI):
                  items: controller.availableTeachers
                      .map<DropdownMenuItem<String>>((teacher) {
                        return DropdownMenuItem<String>(
                          value: teacher['id'].toString(),
                          child: Text(
                            '${teacher['first_name']} ${teacher['last_name']}',
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      })
                      .toList(),
                  onChanged: (value) {
                    controller.selectedMainTeacherId.value = value;
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFinanceSection() {
    return _buildSection(
      title: 'Moliyaviy Ma\'lumotlar',
      icon: Icons.attach_money,
      children: [
        TextFormField(
          controller: controller.monthlyFeeController,
          decoration: const InputDecoration(
            labelText: 'Oylik to\'lov (so\'m) *',
            hintText: 'Masalan: 500000',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.monetization_on),
            suffixText: 'so\'m',
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Oylik to\'lovni kiriting';
            }
            if (double.tryParse(value) == null || double.parse(value) < 0) {
              return 'Noto\'g\'ri summa';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildStatusSection() {
    return _buildSection(
      title: 'Holat',
      icon: Icons.toggle_on_outlined,
      children: [
        Obx(
          () => RadioListTile<String>(
            title: const Text('Faol'),
            subtitle: const Text('Sinf hozirda faol'),
            value: 'active',
            groupValue: controller.selectedStatus.value,
            onChanged: (value) {
              if (value != null) {
                controller.selectedStatus.value = value;
              }
            },
          ),
        ),
        Obx(
          () => RadioListTile<String>(
            title: const Text('Nofaol'),
            subtitle: const Text('Sinf vaqtincha to\'xtatilgan'),
            value: 'inactive',
            groupValue: controller.selectedStatus.value,
            onChanged: (value) {
              if (value != null) {
                controller.selectedStatus.value = value;
              }
            },
          ),
        ),
      ],
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
          ),
          child: const Text('Bekor qilish'),
        ),
        const SizedBox(width: 16),
        Obx(
          () => ElevatedButton(
            onPressed: controller.isSaving.value
                ? null
                : controller.updateClass,
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

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
                  color: Color(0xFF2B3674),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }
}
