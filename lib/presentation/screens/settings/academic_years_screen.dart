

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../config/constants.dart';
import '../../controllers/academic_years_controller.dart';
import '../../widgets/sidebar.dart';

class AcademicYearsScreen extends StatelessWidget {
  AcademicYearsScreen({Key? key}) : super(key: key);

  final controller = Get.put(AcademicYearsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundLight,
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
                      return Center(child: CircularProgressIndicator());
                    }
                    return _buildContent(context);
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
      padding: EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppConstants.primaryColor, AppConstants.secondaryColor],
        ),
        boxShadow: [
          BoxShadow(
            color: AppConstants.primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.school, color: Colors.white, size: 32),
          SizedBox(width: 16),
          Text(
            'O\'quv Yillari',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Spacer(),
          ElevatedButton.icon(
            onPressed: controller.showAddDialog,
            icon: Icon(Icons.add),
            label: Text('Yangi O\'quv Yili'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppConstants.primaryColor,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
          SizedBox(width: 12),
          IconButton(
            onPressed: controller.refreshData,
            icon: Icon(Icons.refresh, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Obx(() {
      if (controller.academicYears.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.school, size: 100, color: Colors.grey[300]),
              SizedBox(height: 16),
              Text(
                'O\'quv yillari mavjud emas',
                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
              ),
              SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: controller.showAddDialog,
                icon: Icon(Icons.add),
                label: Text('Birinchi O\'quv Yilini Qo\'shish'),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: EdgeInsets.all(AppConstants.paddingLarge),
        itemCount: controller.academicYears.length,
        itemBuilder: (context, index) {
          final year = controller.academicYears[index];
          return _buildYearCard(year);
        },
      );
    });
  }

  Widget _buildYearCard(Map<String, dynamic> year) {
    final name = year['name'] ?? '';
    final startDate = DateTime.parse(year['start_date']);
    final endDate = DateTime.parse(year['end_date']);
    final isCurrent = year['is_current'] ?? false;
    final isActive = year['is_active'] ?? true;

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: isCurrent ? 8 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isCurrent 
            ? BorderSide(color: AppConstants.primaryColor, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: isCurrent 
                    ? AppConstants.primaryColor 
                    : Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isCurrent ? Icons.star : Icons.calendar_today,
                color: isCurrent ? Colors.white : Colors.grey[600],
                size: 30,
              ),
            ),
            SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 12),
                      if (isCurrent)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppConstants.successColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'JORIY',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      if (!isActive)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'NOFAOL',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.event, size: 16, color: Colors.grey[600]),
                      SizedBox(width: 4),
                      Text(
                        '${DateFormat('dd.MM.yyyy').format(startDate)} - ${DateFormat('dd.MM.yyyy').format(endDate)}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            PopupMenuButton(
              icon: Icon(Icons.more_vert),
              itemBuilder: (context) => [
                if (!isCurrent)
                  PopupMenuItem(
                    child: ListTile(
                      leading: Icon(Icons.star, color: AppConstants.primaryColor),
                      title: Text('Joriy qilish'),
                      contentPadding: EdgeInsets.zero,
                    ),
                    onTap: () => controller.setAsCurrent(year['id']),
                  ),
                PopupMenuItem(
                  child: ListTile(
                    leading: Icon(Icons.edit, color: AppConstants.infoColor),
                    title: Text('Tahrirlash'),
                    contentPadding: EdgeInsets.zero,
                  ),
                  onTap: () => controller.showEditDialog(year),
                ),
                PopupMenuItem(
                  child: ListTile(
                    leading: Icon(
                      isActive ? Icons.block : Icons.check_circle,
                      color: isActive ? Colors.orange : AppConstants.successColor,
                    ),
                    title: Text(isActive ? 'Nofaol qilish' : 'Faollashtirish'),
                    contentPadding: EdgeInsets.zero,
                  ),
                  onTap: () => controller.toggleActive(year['id'], !isActive),
                ),
                PopupMenuItem(
                  child: ListTile(
                    leading: Icon(Icons.delete, color: AppConstants.errorColor),
                    title: Text('O\'chirish'),
                    contentPadding: EdgeInsets.zero,
                  ),
                  onTap: () => controller.showDeleteDialog(year['id']),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
