// lib/presentation/screens/reports/reports_screen.dart
// HISOBOTLAR EKRANI - To'liq versiya

import 'package:flutter/material.dart';
import 'package:flutter_application_1/config/constants.dart';
import 'package:flutter_application_1/presentation/widgets/sidebar.dart';
import 'package:get/get.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({Key? key}) : super(key: key);

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String selectedPeriod = 'month';
  String selectedReportType = 'financial';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundLight,
      body: Row(
        children: [
          // SIDEBAR
          Sidebar(),
          
          // ASOSIY KONTENT
          Expanded(
            child: Column(
              children: [
                // APP BAR
                _buildAppBar(),
                
                // KONTENT
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(AppConstants.paddingLarge),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Filtrlar
                        _buildFilters(),
                        SizedBox(height: AppConstants.paddingLarge),
                        
                        // Hisobot kartochkalari
                        _buildReportCards(),
                        SizedBox(height: AppConstants.paddingLarge),
                        
                        // Jadval
                        _buildReportsTable(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            'Hisobotlar',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimaryColor,
            ),
          ),
          Spacer(),
          // Export tugmasi
          ElevatedButton.icon(
            onPressed: () {
              // Export funksiyasi
            },
            icon: Icon(Icons.download),
            label: Text('Export'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepOrange,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Davr tanlash
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Davr',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppConstants.textSecondaryColor,
                  ),
                ),
                SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedPeriod,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: [
                    DropdownMenuItem(value: 'today', child: Text('Bugun')),
                    DropdownMenuItem(value: 'week', child: Text('Bu hafta')),
                    DropdownMenuItem(value: 'month', child: Text('Bu oy')),
                    DropdownMenuItem(value: 'year', child: Text('Bu yil')),
                    DropdownMenuItem(value: 'custom', child: Text('Maxsus')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedPeriod = value!;
                    });
                  },
                ),
              ],
            ),
          ),
          SizedBox(width: 16),
          
          // Hisobot turi
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hisobot turi',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppConstants.textSecondaryColor,
                  ),
                ),
                SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedReportType,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: [
                    DropdownMenuItem(value: 'financial', child: Text('Moliyaviy')),
                    DropdownMenuItem(value: 'students', child: Text('O\'quvchilar')),
                    DropdownMenuItem(value: 'staff', child: Text('Xodimlar')),
                    DropdownMenuItem(value: 'attendance', child: Text('Davomat')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedReportType = value!;
                    });
                  },
                ),
              ],
            ),
          ),
          SizedBox(width: 16),
          
          // Filtr tugmasi
          Padding(
            padding: EdgeInsets.only(top: 24),
            child: ElevatedButton.icon(
              onPressed: () {
                // Filtr qo'llash
              },
              icon: Icon(Icons.filter_list),
              label: Text('Filtr'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCards() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'Jami daromad',
            value: '25,500,000',
            subtitle: 'so\'m',
            icon: Icons.attach_money,
            color: Colors.green,
            trend: '+12.5%',
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            title: 'Jami xarajat',
            value: '8,200,000',
            subtitle: 'so\'m',
            icon: Icons.money_off,
            color: Colors.red,
            trend: '+5.2%',
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            title: 'Sof foyda',
            value: '17,300,000',
            subtitle: 'so\'m',
            icon: Icons.trending_up,
            color: Colors.blue,
            trend: '+18.3%',
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            title: 'O\'quvchilar',
            value: '342',
            subtitle: 'aktiv',
            icon: Icons.school,
            color: Colors.orange,
            trend: '+8.1%',
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String trend,
  }) {
    return Container(
      padding: EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  trend,
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: AppConstants.textSecondaryColor,
            ),
          ),
          SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.textPrimaryColor,
                ),
              ),
              SizedBox(width: 4),
              Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppConstants.textSecondaryColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReportsTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(AppConstants.paddingLarge),
            child: Text(
              'Oxirgi hisobotlar',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppConstants.textPrimaryColor,
              ),
            ),
          ),
          Divider(height: 1),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: [
                DataColumn(label: Text('Sana')),
                DataColumn(label: Text('Hisobot turi')),
                DataColumn(label: Text('Davr')),
                DataColumn(label: Text('Yaratuvchi')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Amallar')),
              ],
              rows: [
                _buildTableRow(
                  date: '15.12.2024',
                  type: 'Moliyaviy',
                  period: 'Dekabr 2024',
                  creator: 'Admin',
                  status: 'Tayyor',
                ),
                _buildTableRow(
                  date: '10.12.2024',
                  type: 'O\'quvchilar',
                  period: 'Noyabr 2024',
                  creator: 'Direktor',
                  status: 'Tayyor',
                ),
                _buildTableRow(
                  date: '05.12.2024',
                  type: 'Xodimlar',
                  period: 'Noyabr 2024',
                  creator: 'HR',
                  status: 'Kutilmoqda',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  DataRow _buildTableRow({
    required String date,
    required String type,
    required String period,
    required String creator,
    required String status,
  }) {
    return DataRow(
      cells: [
        DataCell(Text(date)),
        DataCell(Text(type)),
        DataCell(Text(period)),
        DataCell(Text(creator)),
        DataCell(
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: status == 'Tayyor' 
                  ? Colors.green.withOpacity(0.1) 
                  : Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: status == 'Tayyor' ? Colors.green : Colors.orange,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        DataCell(
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.visibility, size: 20),
                onPressed: () {},
                tooltip: 'Ko\'rish',
              ),
              IconButton(
                icon: Icon(Icons.download, size: 20),
                onPressed: () {},
                tooltip: 'Yuklab olish',
              ),
            ],
          ),
        ),
      ],
    );
  }
}