import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/models/expenses_model.dart';
import 'package:get/get.dart';

class ExpensesController extends GetxController {
  var isLoading = false.obs;
  var expenses = <Expense>[].obs;
  var filteredExpenses = <Expense>[].obs;
  var selectedCategory = Rx<String?>('all');
  var selectedDateRange = Rxn<DateTimeRange>();
  var searchQuery = ''.obs;
  var currentPage = 1.obs;
  var itemsPerPage = 12;
  var showGridView = true.obs;

  final categories = <ExpenseCategory>[
    ExpenseCategory(
      id: 'all',
      name: 'Barchasi',
      icon: Icons.apps_rounded,
      color: Colors.grey,
      subCategories: [],
    ),
    ExpenseCategory(
      id: 'salary',
      name: 'Maoshlar',
      icon: Icons.payments_rounded,
      color: const Color(0xFF667eea),
      subCategories: [
        'O\'qituvchi maoshi',
        'Ma\'muriyat maoshi',
        'Xizmatchi maoshi',
        'Qo\'shimcha to\'lov',
      ],
    ),
    ExpenseCategory(
      id: 'utilities',
      name: 'Kommunal',
      icon: Icons.bolt_rounded,
      color: const Color(0xFFf093fb),
      subCategories: [
        'Elektr energiya',
        'Suv',
        'Gaz',
        'Internet',
        'Telefon',
        'Axlat',
      ],
    ),
    ExpenseCategory(
      id: 'kitchen',
      name: 'Oshxona',
      icon: Icons.restaurant_rounded,
      color: const Color(0xFF06D6A0),
      subCategories: [
        'Oziq-ovqat',
        'Go\'sht mahsulotlari',
        'Sabzavot-mevalar',
        'Ichimliklar',
        'Shirinliklar',
      ],
    ),
    ExpenseCategory(
      id: 'marketing',
      name: 'Marketing',
      icon: Icons.campaign_rounded,
      color: const Color(0xFFffa726),
      subCategories: [
        'SMM reklama',
        'Banner/bosma',
        'TV reklama',
        'Radio reklama',
        'Brendlash',
      ],
    ),
    ExpenseCategory(
      id: 'repair',
      name: 'Ta\'mirlash',
      icon: Icons.build_rounded,
      color: const Color(0xFFef5350),
      subCategories: [
        'Santexnika',
        'Elektr',
        'Bo\'yoq',
        'Mebel ta\'miri',
        'Bino ta\'miri',
      ],
    ),
    ExpenseCategory(
      id: 'equipment',
      name: 'Jihozlar',
      icon: Icons.devices_rounded,
      color: const Color(0xFF42a5f5),
      subCategories: [
        'Kompyuter',
        'Proyektor',
        'Printer',
        'Mebel',
        'Dars jihozlari',
      ],
    ),
    ExpenseCategory(
      id: 'stationery',
      name: 'Kantselyariya',
      icon: Icons.edit_note_rounded,
      color: const Color(0xFF26a69a),
      subCategories: [
        'Qog\'oz',
        'Ruchka/qalamlar',
        'Daftar',
        'Marker',
        'Boshqa',
      ],
    ),
    ExpenseCategory(
      id: 'transport',
      name: 'Transport',
      icon: Icons.directions_car_rounded,
      color: const Color(0xFF5c6bc0),
      subCategories: ['Benzin', 'TA', 'Yo\'l haqi', 'Taksi', 'Ta\'mirlash'],
    ),
    ExpenseCategory(
      id: 'other',
      name: 'Boshqa',
      icon: Icons.more_horiz_rounded,
      color: const Color(0xFF78909c),
      subCategories: ['Soliq', 'Jarima', 'Sovg\'alar', 'Xayriya', 'Boshqa'],
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    loadExpenses();
  }

  Future<void> loadExpenses() async {
    try {
      isLoading.value = true;
      await Future.delayed(const Duration(seconds: 1));
      expenses.value = _getDemoExpenses();
      applyFilters();
    } catch (e) {
      Get.snackbar(
        'Xato',
        'Ma\'lumotlarni yuklashda xatolik: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: const Icon(Icons.error_outline, color: Colors.white),
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void applyFilters() {
    var result = expenses.toList();

    // Category filter
    if (selectedCategory.value != null && selectedCategory.value != 'all') {
      result = result
          .where((expense) => expense.category == selectedCategory.value)
          .toList();
    }

    // Date range filter
    if (selectedDateRange.value != null) {
      result = result.where((expense) {
        return expense.expenseDate.isAfter(
              selectedDateRange.value!.start.subtract(const Duration(days: 1)),
            ) &&
            expense.expenseDate.isBefore(
              selectedDateRange.value!.end.add(const Duration(days: 1)),
            );
      }).toList();
    }

    // Search filter
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      result = result.where((expense) {
        return expense.title.toLowerCase().contains(query) ||
            expense.description.toLowerCase().contains(query) ||
            expense.responsiblePerson.toLowerCase().contains(query) ||
            (expense.staffName?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    // Sort by date (newest first)
    result.sort((a, b) => b.expenseDate.compareTo(a.expenseDate));

    filteredExpenses.value = result;
  }

  Future<void> selectDateRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: selectedDateRange.value,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF667eea)),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      selectedDateRange.value = picked;
      applyFilters();
    }
  }

  void clearFilters() {
    selectedCategory.value = 'all';
    selectedDateRange.value = null;
    searchQuery.value = '';
    applyFilters();
  }

  double getTotalAmount() {
    return filteredExpenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  Map<String, double> getExpensesByCategory() {
    Map<String, double> result = {};
    for (var expense in filteredExpenses) {
      result[expense.category] =
          (result[expense.category] ?? 0) + expense.amount;
    }
    return result;
  }

  Color getCategoryColor(String categoryId) {
    try {
      return categories.firstWhere((cat) => cat.id == categoryId).color;
    } catch (e) {
      return Colors.grey;
    }
  }

  String getCategoryName(String categoryId) {
    try {
      return categories.firstWhere((cat) => cat.id == categoryId).name;
    } catch (e) {
      return categoryId;
    }
  }

  IconData getCategoryIcon(String categoryId) {
    try {
      return categories.firstWhere((cat) => cat.id == categoryId).icon;
    } catch (e) {
      return Icons.help_outline;
    }
  }

  // Pagination
  List<Expense> getPaginatedExpenses() {
    final startIndex = (currentPage.value - 1) * itemsPerPage;
    final endIndex = startIndex + itemsPerPage;

    if (startIndex >= filteredExpenses.length) {
      return [];
    }

    return filteredExpenses.sublist(
      startIndex,
      endIndex > filteredExpenses.length ? filteredExpenses.length : endIndex,
    );
  }

  int getTotalPages() {
    return (filteredExpenses.length / itemsPerPage).ceil();
  }

  void nextPage() {
    if (currentPage.value < getTotalPages()) {
      currentPage.value++;
    }
  }

  void previousPage() {
    if (currentPage.value > 1) {
      currentPage.value--;
    }
  }

  void goToPage(int page) {
    if (page >= 1 && page <= getTotalPages()) {
      currentPage.value = page;
    }
  }

  List<Expense> _getDemoExpenses() {
    return [
      Expense(
        id: '1',
        category: 'salary',
        subCategory: 'O\'qituvchi maoshi',
        title: 'Aziza Murodova - Noyabr oyi maoshi',
        description: 'Matematika o\'qituvchisi oylik maoshi',
        amount: 5000000,
        staffName: 'Aziza Murodova',
        expenseDate: DateTime(2024, 12, 5),
        responsiblePerson: 'Sardor Alimov',
        receiptNumber: 'SAL-2024-001',
        recordedBy: 'Sardor Alimov',
      ),
      Expense(
        id: '2',
        category: 'utilities',
        subCategory: 'Elektr energiya',
        title: 'Noyabr oyi elektr energiya to\'lovi',
        description: 'Bosh filial elektr to\'lovi',
        amount: 3500000,
        expenseDate: DateTime(2024, 12, 3),
        responsiblePerson: 'Malika Rahimova',
        notes: 'Hisoblagich: 15420 kWt',
        receiptNumber: 'UTIL-2024-045',
        recordedBy: 'Malika Rahimova',
      ),
      Expense(
        id: '3',
        category: 'kitchen',
        subCategory: 'Oziq-ovqat',
        title: 'Haftalik oziq-ovqat xaridi',
        description: 'Go\'sht, sabzavotlar, mevalar',
        amount: 4500000,
        expenseDate: DateTime(2024, 12, 4),
        responsiblePerson: 'Shuhrat Tojiboyev',
        notes: 'Mirzo bozori',
        receiptNumber: 'KITCH-2024-023',
        recordedBy: 'Malika Rahimova',
      ),
      Expense(
        id: '4',
        category: 'marketing',
        subCategory: 'SMM reklama',
        title: 'Instagram reklama kampaniyasi',
        description: 'Dekabr oyi uchun targetting reklama',
        amount: 2000000,
        expenseDate: DateTime(2024, 12, 1),
        responsiblePerson: 'Akmal Toshmatov',
        notes: 'SMM agentlik - 30 kun',
        receiptNumber: 'MARK-2024-012',
        recordedBy: 'Akmal Toshmatov',
      ),
      Expense(
        id: '5',
        category: 'repair',
        subCategory: 'Santexnika',
        title: '201-xona sanitariya ta\'miri',
        description: 'Kran va truba almashtirish',
        amount: 350000,
        expenseDate: DateTime(2024, 12, 2),
        responsiblePerson: 'Anvar Sultonov',
        notes: 'Usta: Shavkat',
        receiptNumber: 'REP-2024-008',
        recordedBy: 'Malika Rahimova',
      ),
      Expense(
        id: '6',
        category: 'equipment',
        subCategory: 'Kompyuter',
        title: 'Yangi kompyuter sotib olish',
        description: 'O\'qituvchilar uchun Dell Latitude 5420',
        amount: 8500000,
        expenseDate: DateTime(2024, 11, 28),
        responsiblePerson: 'IT bo\'lim',
        notes: 'Uzum Tashkent',
        receiptNumber: 'EQUIP-2024-015',
        recordedBy: 'Sardor Alimov',
      ),
      Expense(
        id: '7',
        category: 'stationery',
        subCategory: 'Qog\'oz',
        title: 'A4 qog\'oz sotib olish',
        description: '50 paket A4 qog\'oz',
        amount: 750000,
        expenseDate: DateTime(2024, 12, 4),
        responsiblePerson: 'Malika Rahimova',
        receiptNumber: 'STAT-2024-032',
        recordedBy: 'Malika Rahimova',
      ),
      Expense(
        id: '8',
        category: 'transport',
        subCategory: 'Benzin',
        title: 'Xizmat mashinasi uchun benzin',
        description: 'AI-95 100L',
        amount: 1200000,
        expenseDate: DateTime(2024, 12, 5),
        responsiblePerson: 'Haydovchi',
        notes: 'AGZS №12',
        receiptNumber: 'TRANS-2024-019',
        recordedBy: 'Sardor Alimov',
      ),
      Expense(
        id: '9',
        category: 'utilities',
        subCategory: 'Internet',
        title: 'Internet to\'lovi',
        description: 'Uztelecom 100 Mbit/s',
        amount: 500000,
        expenseDate: DateTime(2024, 12, 1),
        responsiblePerson: 'Malika Rahimova',
        notes: 'Shartnoma: 12345',
        receiptNumber: 'UTIL-2024-046',
        recordedBy: 'Malika Rahimova',
      ),
      Expense(
        id: '10',
        category: 'other',
        subCategory: 'Xayriya',
        title: 'Mehribonlik uyi uchun yordam',
        description: 'Oziq-ovqat mahsulotlari',
        amount: 1500000,
        expenseDate: DateTime(2024, 12, 3),
        responsiblePerson: 'Sardor Alimov',
        notes: 'Ijtimoiy mas\'uliyat',
        receiptNumber: 'OTHER-2024-007',
        recordedBy: 'Sardor Alimov',
      ),
      // Qo'shimcha demo ma'lumotlar
      Expense(
        id: '11',
        category: 'salary',
        subCategory: 'Ma\'muriyat maoshi',
        title: 'Malika Rahimova - Noyabr oyi maoshi',
        description: 'Bosh hisobchi oylik maoshi',
        amount: 4500000,
        staffName: 'Malika Rahimova',
        expenseDate: DateTime(2024, 11, 30),
        responsiblePerson: 'Sardor Alimov',
        receiptNumber: 'SAL-2024-002',
        recordedBy: 'Sardor Alimov',
      ),
      Expense(
        id: '12',
        category: 'utilities',
        subCategory: 'Suv',
        title: 'Noyabr oyi suv to\'lovi',
        description: 'Suv ta\'minoti to\'lovi',
        amount: 850000,
        expenseDate: DateTime(2024, 12, 2),
        responsiblePerson: 'Malika Rahimova',
        notes: 'Hisoblagich: 3250 m³',
        receiptNumber: 'UTIL-2024-047',
        recordedBy: 'Malika Rahimova',
      ),
    ];
  }

  // Export funksiyasi
  String getExportData() {
    StringBuffer csv = StringBuffer();
    csv.writeln('ID,Kategoriya,Turi,Sarlavha,Tavsif,Summa,Sana,Mas\'ul');

    for (var expense in filteredExpenses) {
      csv.writeln(
        '${expense.id},'
        '${getCategoryName(expense.category)},'
        '${expense.subCategory},'
        '${expense.title},'
        '${expense.description},'
        '${expense.amount},'
        '${expense.expenseDate.toString().split(' ')[0]},'
        '${expense.responsiblePerson}',
      );
    }

    return csv.toString();
  }
}
