// lib/presentation/screens/Schedule/schedule_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../widgets/sidebar.dart';
import '../../../config/constants.dart';

class ScheduleScreen extends StatefulWidget {
  @override
  _ScheduleScreenState createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen>
    with SingleTickerProviderStateMixin {
  final supabase = Supabase.instance.client;
  late TabController _tabController;

  // State
  String selectedView = 'weekly';
  DateTime selectedDate = DateTime.now();
  String? selectedClassId;
  String? selectedTeacherId;
  bool isLoading = true;
  bool showSidePanel = false;
  bool showStudentPanel = false;
  bool showHolidayDialog = false;
  dynamic selectedLesson;
  dynamic selectedStudent;
  List<dynamic> teacherSchedule = [];
  List<dynamic> classStudents = [];
  List<dynamic> studentAttendance = [];
  List<dynamic> holidays = [];
  bool isAddingLesson = false;
  bool isEditingLesson = false;

  // Data
  List<dynamic> classes = [];
  List<dynamic> teachers = [];
  List<dynamic> subjects = [];
  List<dynamic> rooms = [];
  List<dynamic> scheduleData = [];
  Map<String, List<dynamic>> groupedSchedule = {};
  Map<String, List<dynamic>> roomSchedule = {};

  // Form controllers
  final _formKey = GlobalKey<FormState>();
  String? formClassId;
  String? formSubjectId;
  String? formTeacherId;
  String? formRoomId;
  List<String> formDaysOfWeek = [];
  TimeOfDay? formStartTime;
  TimeOfDay? formEndTime;

  // Holiday form
  DateTime? holidayStartDate;
  DateTime? holidayEndDate;
  String? holidayClassId;
  String holidayReason = '';
  bool isSchoolWideHoliday = true;

  final List<String> weekDays = [
    'Dushanba',
    'Seshanba',
    'Chorshanba',
    'Payshanba',
    'Juma',
    'Shanba',
  ];

  final Map<String, String> dayMapping = {
    'monday': 'Dushanba',
    'tuesday': 'Seshanba',
    'wednesday': 'Chorshanba',
    'thursday': 'Payshanba',
    'friday': 'Juma',
    'saturday': 'Shanba',
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        if (_tabController.index == 0) selectedView = 'weekly';
        if (_tabController.index == 1) selectedView = 'daily';
        if (_tabController.index == 2) selectedView = 'teacher';
        showSidePanel = false;
        showStudentPanel = false;
      });
      _loadScheduleData();
    });
    _initialize();
  }

  Future<void> _initialize() async {
    await Future.wait([
      _loadClasses(),
      _loadTeachers(),
      _loadSubjects(),
      _loadRooms(),
      _loadHolidays(),
    ]);
    await _loadScheduleData();
  }

  Future<void> _loadClasses() async {
    try {
      final response = await supabase
          .from('classes')
          .select('*, class_levels(name)')
          .eq('is_active', true)
          .order('name');
      setState(() => classes = response);
    } catch (e) {
      print('Error loading classes: $e');
    }
  }

  Future<void> _loadTeachers() async {
    try {
      final response = await supabase
          .from('staff')
          .select('*')
          .eq('is_teacher', true)
          .eq('status', 'active')
          .order('first_name');
      setState(() => teachers = response);
    } catch (e) {
      print('Error loading teachers: $e');
    }
  }

  Future<void> _loadSubjects() async {
    try {
      final response = await supabase
          .from('subjects')
          .select('*')
          .eq('is_active', true)
          .order('name');
      setState(() => subjects = response);
    } catch (e) {
      print('Error loading subjects: $e');
    }
  }

  Future<void> _loadRooms() async {
    try {
      final response = await supabase
          .from('rooms')
          .select('*')
          .eq('is_active', true)
          .order('name');
      setState(() => rooms = response);
    } catch (e) {
      print('Error loading rooms: $e');
    }
  }

  Future<void> _loadHolidays() async {
    try {
      final response = await supabase
          .from('holidays')
          .select('*')
          .gte('end_date', DateTime.now().toIso8601String().split('T')[0])
          .order('start_date');
      setState(() => holidays = response);
    } catch (e) {
      print('Error loading holidays: $e');
    }
  }

  Future<void> _loadScheduleData() async {
    setState(() => isLoading = true);
    try {
      var query = supabase
          .from('schedule_templates')
          .select('''
        *,
        classes(id, name, code),
        subjects(id, name, code),
        staff(id, first_name, last_name, phone),
        rooms(id, name, capacity)
      ''')
          .eq('is_active', true);

      if (selectedView == 'weekly' && selectedClassId != null) {
        query = query.eq('class_id', selectedClassId!);
      } else if (selectedView == 'teacher' && selectedTeacherId != null) {
        query = query.eq('teacher_id', selectedTeacherId!);
      }

      final response = await query.order('start_time');

      setState(() {
        scheduleData = response;
        _groupScheduleData();
        _groupRoomSchedule();
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      print('Error loading schedule: $e');
    }
  }

  void _groupScheduleData() {
    groupedSchedule.clear();
    for (var item in scheduleData) {
      String day = item['day_of_week'];
      if (!groupedSchedule.containsKey(day)) {
        groupedSchedule[day] = [];
      }
      groupedSchedule[day]!.add(item);
    }
  }

  void _groupRoomSchedule() {
    roomSchedule.clear();
    for (var item in scheduleData) {
      String key =
          '${item['room_id']}_${item['day_of_week']}_${item['start_time']}';
      if (!roomSchedule.containsKey(key)) {
        roomSchedule[key] = [];
      }
      roomSchedule[key]!.add(item);
    }
  }

  Future<void> _loadTeacherSchedule(String teacherId) async {
    try {
      final response = await supabase
          .from('schedule_templates')
          .select('''
        *,
        classes(id, name, code),
        subjects(id, name, code),
        rooms(id, name)
      ''')
          .eq('teacher_id', teacherId)
          .eq('is_active', true)
          .order('start_time');

      setState(() => teacherSchedule = response);
    } catch (e) {
      print('Error loading teacher schedule: $e');
    }
  }

  Future<void> _loadClassStudents(String classId) async {
    try {
      final enrollment = await supabase
          .from('class_enrollments')
          .select('student_id')
          .eq('class_id', classId)
          .eq('is_active', true);

      final studentIds = enrollment.map((e) => e['student_id']).toList();

      if (studentIds.isNotEmpty) {
        final response = await supabase
            .from('students')
            .select('*')
            .any('id', studentIds)
            .eq('status', 'active')
            .order('first_name');

        setState(() => classStudents = response);
      }
    } catch (e) {
      print('Error loading students: $e');
    }
  }

  Future<void> _loadStudentAttendance(String studentId, String lessonId) async {
    try {
      final response = await supabase
          .from('attendance')
          .select('*')
          .eq('student_id', studentId)
          .order('date', ascending: false)
          .limit(30);

      setState(() => studentAttendance = response);
    } catch (e) {
      print('Error loading attendance: $e');
    }
  }

  bool _isRoomBusy(String? roomId, String dayOfWeek, String startTime) {
    if (roomId == null) return false;
    String key = '${roomId}_${dayOfWeek}_$startTime';
    return roomSchedule.containsKey(key) && roomSchedule[key]!.isNotEmpty;
  }

  bool _isDateHoliday(DateTime date, String? classId) {
    return holidays.any((h) {
      final start = DateTime.parse(h['start_date']);
      final end = DateTime.parse(h['end_date']);
      final isInRange =
          date.isAfter(start.subtract(Duration(days: 1))) &&
          date.isBefore(end.add(Duration(days: 1)));

      if (!isInRange) return false;

      if (h['is_school_wide'] == true) return true;
      if (classId != null && h['class_id'] == classId) return true;

      return false;
    });
  }

  String getUzbekDay(DateTime date) {
    const days = [
      'Dushanba',
      'Seshanba',
      'Chorshanba',
      'Payshanba',
      'Juma',
      'Shanba',
      'Yakshanba',
    ];
    return days[date.weekday - 1];
  }

  String getUzbekMonth(DateTime date) {
    const months = [
      'Yanvar',
      'Fevral',
      'Mart',
      'Aprel',
      'May',
      'Iyun',
      'Iyul',
      'Avgust',
      'Sentabr',
      'Oktabr',
      'Noyabr',
      'Dekabr',
    ];
    return months[date.month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Sidebar(),
          Expanded(
            child: Container(
              color: AppConstants.backgroundLight,
              child: Stack(
                children: [
                  Column(
                    children: [
                      _buildHeader(),
                      _buildFilters(),
                      Expanded(child: _buildContent()),
                    ],
                  ),
                  if (showSidePanel) _buildSidePanel(),
                  if (showStudentPanel) _buildStudentPanel(),
                  if (isAddingLesson || isEditingLesson) _buildFormPanel(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final isHoliday =
        selectedClassId != null &&
        _isDateHoliday(selectedDate, selectedClassId);

    return Container(
      padding: EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                color: AppConstants.primaryColor,
                size: 28,
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dars Jadvali',
                      style: TextStyle(
                        fontSize: AppConstants.fontSizeXXLarge,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.textPrimaryColor,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          '${selectedDate.day} ${getUzbekMonth(selectedDate)} ${selectedDate.year}, ${getUzbekDay(selectedDate)}',
                          style: TextStyle(
                            color: AppConstants.textSecondaryColor,
                            fontSize: AppConstants.fontSizeMedium,
                          ),
                        ),
                        if (isHoliday) ...[
                          SizedBox(width: 12),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppConstants.errorColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.celebration,
                                  size: 14,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Ta\'til',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => setState(() => showHolidayDialog = true),
                icon: Icon(Icons.event_busy),
                label: Text('Ta\'til belgilash'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.warningColor,
                ),
              ),
              SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () {
                  _resetForm();
                  setState(() => isAddingLesson = true);
                },
                icon: Icon(Icons.add),
                label: Text('Dars qo\'shish'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                ),
              ),
              SizedBox(width: 12),
              IconButton(
                onPressed: _loadScheduleData,
                icon: Icon(Icons.refresh),
                tooltip: 'Yangilash',
              ),
            ],
          ),
          SizedBox(height: 20),
          _buildTabBar(),
          if (holidays.isNotEmpty) ...[
            SizedBox(height: 12),
            _buildHolidayBanner(),
          ],
        ],
      ),
    );
  }

  Widget _buildHolidayBanner() {
    final upcomingHolidays = holidays.where((h) {
      final start = DateTime.parse(h['start_date']);
      return start.isAfter(DateTime.now()) &&
          start.isBefore(DateTime.now().add(Duration(days: 30)));
    }).toList();

    if (upcomingHolidays.isEmpty) return SizedBox();

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppConstants.warningColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppConstants.warningColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.celebration, color: AppConstants.warningColor, size: 20),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Yaqinlashayotgan ta\'tillar: ${upcomingHolidays.length} ta',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
          TextButton(
            onPressed: () => _showHolidaysDialog(),
            child: Text('Ko\'rish'),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppConstants.primaryColor,
          borderRadius: BorderRadius.circular(10),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: AppConstants.textSecondaryColor,
        labelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        tabs: [
          Tab(text: 'Haftalik'),
          Tab(text: 'Kunlik'),
          Tab(text: 'O\'qituvchi'),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: EdgeInsets.all(AppConstants.paddingLarge),
      color: Colors.white,
      child: Row(
        children: [
          if (selectedView == 'weekly' || selectedView == 'daily') ...[
            Expanded(child: _buildClassFilter()),
            SizedBox(width: 16),
          ],
          if (selectedView == 'teacher') ...[
            Expanded(child: _buildTeacherFilter()),
            SizedBox(width: 16),
          ],
          _buildDatePicker(),
        ],
      ),
    );
  }

  Widget _buildClassFilter() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedClassId,
          hint: Text('Sinf tanlang'),
          isExpanded: true,
          items: classes.map<DropdownMenuItem<String>>((c) {
            return DropdownMenuItem(
              value: c['id'],
              child: Text('${c['name']} - ${c['class_levels']['name']}'),
            );
          }).toList(),
          onChanged: (value) {
            setState(() => selectedClassId = value);
            _loadScheduleData();
          },
        ),
      ),
    );
  }

  Widget _buildTeacherFilter() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedTeacherId,
          hint: Text('O\'qituvchi tanlang'),
          isExpanded: true,
          items: teachers.map<DropdownMenuItem<String>>((t) {
            return DropdownMenuItem(
              value: t['id'],
              child: Text('${t['first_name']} ${t['last_name']}'),
            );
          }).toList(),
          onChanged: (value) {
            setState(() => selectedTeacherId = value);
            _loadScheduleData();
          },
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime(2024),
          lastDate: DateTime(2026),
        );
        if (date != null) {
          setState(() => selectedDate = date);
          _loadScheduleData();
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: AppConstants.primaryColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_month, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(
              DateFormat('dd.MM.yyyy').format(selectedDate),
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (scheduleData.isEmpty) {
      return _buildEmptyState();
    }

    if (showHolidayDialog) {
      return _buildHolidayForm();
    }

    return TabBarView(
      controller: _tabController,
      children: [_buildWeeklyView(), _buildDailyView(), _buildTeacherView()],
    );
  }

  Widget _buildWeeklyView() {
    if (selectedClassId == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.class_, size: 64, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              'Jadval ko\'rish uchun sinfni tanlang',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(AppConstants.paddingLarge),
      child: Column(
        children: weekDays.map((day) {
          final dayKey = dayMapping.entries
              .firstWhere((e) => e.value == day, orElse: () => MapEntry('', ''))
              .key;
          final lessons = groupedSchedule[dayKey] ?? [];
          return _buildDayCard(day, lessons, dayKey);
        }).toList(),
      ),
    );
  }

  Widget _buildDayCard(String day, List<dynamic> lessons, String dayKey) {
    // Check if this day is a holiday
    final today = DateTime.now();
    int daysToAdd =
        dayMapping.keys.toList().indexOf(dayKey) - (today.weekday - 1);
    final checkDate = today.add(Duration(days: daysToAdd));
    final isHoliday = _isDateHoliday(checkDate, selectedClassId);

    return Card(
      margin: EdgeInsets.only(bottom: AppConstants.paddingLarge),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(AppConstants.paddingLarge),
            decoration: BoxDecoration(
              color: isHoliday
                  ? AppConstants.errorColor
                  : AppConstants.primaryColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppConstants.borderRadiusMedium),
                topRight: Radius.circular(AppConstants.borderRadiusMedium),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isHoliday ? Icons.celebration : Icons.calendar_today,
                  color: Colors.white,
                  size: 20,
                ),
                SizedBox(width: 12),
                Text(
                  day,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: AppConstants.fontSizeLarge,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isHoliday) ...[
                  SizedBox(width: 8),
                  Text(
                    '(Ta\'til)',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
                Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${lessons.length} dars',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          if (isHoliday)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.beach_access, size: 48, color: Colors.grey[400]),
                    SizedBox(height: 8),
                    Text(
                      'Bu kunda ta\'til',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (lessons.isEmpty)
            Padding(
              padding: EdgeInsets.all(40),
              child: Center(
                child: Text(
                  'Bu kunda dars yo\'q',
                  style: TextStyle(color: Colors.grey[400], fontSize: 14),
                ),
              ),
            )
          else
            ...lessons.map((lesson) => _buildLessonCard(lesson)).toList(),
        ],
      ),
    );
  }

  Widget _buildLessonCard(dynamic lesson) {
    final subject = lesson['subjects'];
    final teacher = lesson['staff'];
    final room = lesson['rooms'];
    final classData = lesson['classes'];

    return InkWell(
      onTap: () {
        setState(() {
          selectedLesson = lesson;
          showSidePanel = true;
        });
        if (teacher != null) {
          _loadTeacherSchedule(teacher['id']);
        }
        if (classData != null) {
          _loadClassStudents(classData['id']);
        }
      },
      child: Container(
        padding: EdgeInsets.all(AppConstants.paddingLarge),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
        ),
        child: Row(
          children: [
            Container(
              width: 80,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson['start_time'].substring(0, 5),
                    style: TextStyle(
                      fontSize: AppConstants.fontSizeLarge,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.primaryColor,
                    ),
                  ),
                  Text(
                    lesson['end_time'].substring(0, 5),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Container(
              width: 4,
              height: 50,
              decoration: BoxDecoration(
                color: AppConstants.primaryColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppConstants.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          subject['code'] ?? '',
                          style: TextStyle(
                            color: AppConstants.primaryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          subject['name'] ?? '',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.person, size: 16, color: Colors.grey[600]),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          teacher != null
                              ? '${teacher['first_name']} ${teacher['last_name']}'
                              : 'O\'qituvchi tayinlanmagan',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Icon(Icons.room, size: 16, color: Colors.grey[600]),
                      SizedBox(width: 6),
                      Text(
                        room?['name'] ?? 'Xona yo\'q',
                        style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                  if (selectedView == 'teacher' && classData != null)
                    Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Row(
                        children: [
                          Icon(Icons.class_, size: 16, color: Colors.grey[600]),
                          SizedBox(width: 6),
                          Text(
                            classData['name'],
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyView() {
    final today = getUzbekDay(selectedDate).toLowerCase();
    final dayKey = {
      'dushanba': 'monday',
      'seshanba': 'tuesday',
      'chorshanba': 'wednesday',
      'payshanba': 'thursday',
      'juma': 'friday',
      'shanba': 'saturday',
    }[today];

    final lessons = groupedSchedule[dayKey] ?? [];

    return SingleChildScrollView(
      padding: EdgeInsets.all(AppConstants.paddingLarge),
      child: _buildDayCard(dayMapping[dayKey] ?? 'Kun', lessons, dayKey ?? ''),
    );
  }

  Widget _buildTeacherView() {
    if (selectedTeacherId == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person, size: 64, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              'Jadval ko\'rish uchun o\'qituvchini tanlang',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(AppConstants.paddingLarge),
      child: Column(
        children: weekDays.map((day) {
          final dayKey = dayMapping.entries
              .firstWhere((e) => e.value == day, orElse: () => MapEntry('', ''))
              .key;
          final lessons = groupedSchedule[dayKey] ?? [];
          if (lessons.isEmpty) return SizedBox.shrink();
          return _buildDayCard(day, lessons, dayKey);
        }).toList(),
      ),
    );
  }

  Widget _buildSidePanel() {
    return Positioned(
      right: 0,
      top: 0,
      bottom: 0,
      child: Container(
        width: 450,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: Offset(-5, 0),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(AppConstants.paddingLarge),
              decoration: BoxDecoration(color: AppConstants.primaryColor),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.white, size: 24),
                  SizedBox(width: 12),
                  Text(
                    'Dars tafsilotlari',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: AppConstants.fontSizeXLarge,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.white),
                    onPressed: () => setState(() => showSidePanel = false),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(AppConstants.paddingLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLessonInfo(),
                    SizedBox(height: AppConstants.paddingLarge),
                    _buildTeacherInfo(),
                    SizedBox(height: AppConstants.paddingLarge),
                    _buildStudentsList(),
                    SizedBox(height: AppConstants.paddingLarge),
                    _buildActionButtons(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentPanel() {
    if (selectedStudent == null) return SizedBox();

    return Positioned(
      right: 0,
      top: 0,
      bottom: 0,
      child: Container(
        width: 400,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: Offset(-5, 0),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(AppConstants.paddingLarge),
              decoration: BoxDecoration(color: AppConstants.infoColor),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      color: AppConstants.infoColor,
                      size: 28,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${selectedStudent['first_name']} ${selectedStudent['last_name']}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'O\'quvchi ma\'lumotlari',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.white),
                    onPressed: () => setState(() => showStudentPanel = false),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(AppConstants.paddingLarge),
                children: [
                  _buildStudentInfoCard(),
                  SizedBox(height: 16),
                  _buildStudentParentInfo(),
                  SizedBox(height: 16),
                  _buildStudentAttendanceCard(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentInfoCard() {
    return Card(
      elevation: 0,
      color: AppConstants.infoColor.withOpacity(0.1),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Shaxsiy ma\'lumotlar',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Divider(height: 20),
            _buildInfoRow(
              Icons.phone,
              'Telefon',
              selectedStudent['phone'] ?? 'Yo\'q',
            ),
            SizedBox(height: 12),
            _buildInfoRow(
              Icons.calendar_today,
              'Tug\'ilgan sana',
              selectedStudent['birth_date'] != null
                  ? DateFormat(
                      'dd.MM.yyyy',
                    ).format(DateTime.parse(selectedStudent['birth_date']))
                  : 'Yo\'q',
            ),
            SizedBox(height: 12),
            _buildInfoRow(
              Icons.location_on,
              'Manzil',
              selectedStudent['address'] ?? 'Kiritilmagan',
            ),
            SizedBox(height: 12),
            _buildInfoRow(
              Icons.monetization_on,
              'Oylik to\'lov',
              '${NumberFormat('#,###').format(selectedStudent['monthly_fee'] ?? 0)} so\'m',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentParentInfo() {
    return Card(
      elevation: 0,
      color: AppConstants.successColor.withOpacity(0.1),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ota-ona ma\'lumotlari',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Divider(height: 20),
            _buildInfoRow(
              Icons.person,
              'Ism',
              '${selectedStudent['parent_first_name'] ?? ''} ${selectedStudent['parent_last_name'] ?? ''}',
            ),
            SizedBox(height: 12),
            _buildInfoRow(
              Icons.phone,
              'Telefon',
              selectedStudent['parent_phone'] ?? 'Yo\'q',
            ),
            SizedBox(height: 12),
            _buildInfoRow(
              Icons.work,
              'Ish joyi',
              selectedStudent['parent_workplace'] ?? 'Kiritilmagan',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentAttendanceCard() {
    if (studentAttendance.isEmpty) return SizedBox();

    return Card(
      elevation: 0,
      color: AppConstants.warningColor.withOpacity(0.1),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Davomat tarixi',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Spacer(),
                Text(
                  'Oxirgi 30 kun',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            Divider(height: 20),
            ...studentAttendance.take(10).map((att) {
              final date = DateTime.parse(att['date']);
              final status = att['status'];
              final statusColor = status == 'present'
                  ? AppConstants.successColor
                  : status == 'late'
                  ? AppConstants.warningColor
                  : AppConstants.errorColor;
              final statusText = status == 'present'
                  ? 'Keldi'
                  : status == 'late'
                  ? 'Kechikdi'
                  : 'Kelmadi';

              return Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      DateFormat('dd.MM.yyyy').format(date),
                      style: TextStyle(fontSize: 13),
                    ),
                    SizedBox(width: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 11,
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildLessonInfo() {
    if (selectedLesson == null) return SizedBox();

    final subject = selectedLesson['subjects'];
    final room = selectedLesson['rooms'];
    final classData = selectedLesson['classes'];

    return Card(
      elevation: 0,
      color: AppConstants.primaryColor.withOpacity(0.1),
      child: Padding(
        padding: EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppConstants.primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.book, color: Colors.white, size: 24),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subject['name'],
                        style: TextStyle(
                          fontSize: AppConstants.fontSizeLarge,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${selectedLesson['start_time'].substring(0, 5)} - ${selectedLesson['end_time'].substring(0, 5)}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Divider(height: 24),
            _buildInfoRow(Icons.class_, 'Sinf', classData['name']),
            SizedBox(height: 12),
            _buildInfoRow(Icons.room, 'Xona', room?['name'] ?? 'Belgilanmagan'),
            if (room != null && room['capacity'] != null) ...[
              SizedBox(height: 8),
              Text(
                'Sig\'im: ${room['capacity']} o\'rin',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
            SizedBox(height: 12),
            _buildInfoRow(
              Icons.calendar_today,
              'Kun',
              dayMapping[selectedLesson['day_of_week']] ?? '',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeacherInfo() {
    if (selectedLesson == null) return SizedBox();
    final teacher = selectedLesson['staff'];
    if (teacher == null) return SizedBox();

    return Card(
      elevation: 0,
      color: AppConstants.successColor.withOpacity(0.1),
      child: Padding(
        padding: EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppConstants.successColor,
                  child: Icon(Icons.person, color: Colors.white, size: 30),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${teacher['first_name']} ${teacher['last_name']}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (teacher['phone'] != null)
                        Row(
                          children: [
                            Icon(
                              Icons.phone,
                              size: 14,
                              color: Colors.grey[600],
                            ),
                            SizedBox(width: 4),
                            Text(
                              teacher['phone'],
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
            if (teacherSchedule.isNotEmpty) ...[
              Divider(height: 24),
              Text(
                'Haftalik jadval (${teacherSchedule.length} dars)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 8),
              ...teacherSchedule.take(5).map((schedule) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppConstants.successColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          dayMapping[schedule['day_of_week']]?.substring(
                                0,
                                3,
                              ) ??
                              '',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        '${schedule['start_time'].substring(0, 5)} - ${schedule['end_time'].substring(0, 5)}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          schedule['subjects']['name'],
                          style: TextStyle(fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStudentsList() {
    if (classStudents.isEmpty) return SizedBox();

    return Card(
      elevation: 0,
      color: AppConstants.infoColor.withOpacity(0.1),
      child: Padding(
        padding: EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.people, color: AppConstants.infoColor, size: 20),
                SizedBox(width: 8),
                Text(
                  'O\'quvchilar (${classStudents.length})',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 12),
            Container(
              constraints: BoxConstraints(maxHeight: 300),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: classStudents.length,
                itemBuilder: (context, index) {
                  final student = classStudents[index];
                  return InkWell(
                    onTap: () {
                      setState(() {
                        selectedStudent = student;
                        showStudentPanel = true;
                      });
                      _loadStudentAttendance(
                        student['id'],
                        selectedLesson['id'],
                      );
                    },
                    child: Container(
                      margin: EdgeInsets.only(bottom: 8),
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: AppConstants.infoColor.withOpacity(
                              0.2,
                            ),
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppConstants.infoColor,
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${student['first_name']} ${student['last_name']}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (student['phone'] != null)
                                  Text(
                                    student['phone'],
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            size: 16,
                            color: Colors.grey[400],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              setState(() {
                showSidePanel = false;
                isEditingLesson = true;
                _fillFormWithLesson(selectedLesson);
              });
            },
            icon: Icon(Icons.edit),
            label: Text('Tahrirlash'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              padding: EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _deleteLesson(selectedLesson['id']),
            icon: Icon(Icons.delete, color: AppConstants.errorColor),
            label: Text(
              'O\'chirish',
              style: TextStyle(color: AppConstants.errorColor),
            ),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 14),
              side: BorderSide(color: AppConstants.errorColor),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormPanel() {
    return Positioned(
      right: 0,
      top: 0,
      bottom: 0,
      child: Container(
        width: 450,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: Offset(-5, 0),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(AppConstants.paddingLarge),
              decoration: BoxDecoration(color: AppConstants.primaryColor),
              child: Row(
                children: [
                  Icon(
                    isEditingLesson ? Icons.edit : Icons.add,
                    color: Colors.white,
                    size: 24,
                  ),
                  SizedBox(width: 12),
                  Text(
                    isEditingLesson
                        ? 'Darsni tahrirlash'
                        : 'Yangi dars qo\'shish',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: AppConstants.fontSizeXLarge,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.white),
                    onPressed: () => setState(() {
                      isAddingLesson = false;
                      isEditingLesson = false;
                    }),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: EdgeInsets.all(AppConstants.paddingLarge),
                  children: [
                    _buildFormDropdown(
                      label: 'Sinf',
                      value: formClassId,
                      items: classes,
                      onChanged: (value) => setState(() => formClassId = value),
                      displayText: (item) =>
                          '${item['name']} - ${item['class_levels']['name']}',
                    ),
                    SizedBox(height: 16),
                    _buildFormDropdown(
                      label: 'Fan',
                      value: formSubjectId,
                      items: subjects,
                      onChanged: (value) =>
                          setState(() => formSubjectId = value),
                      displayText: (item) => item['name'],
                    ),
                    SizedBox(height: 16),
                    _buildFormDropdown(
                      label: 'O\'qituvchi',
                      value: formTeacherId,
                      items: teachers,
                      onChanged: (value) =>
                          setState(() => formTeacherId = value),
                      displayText: (item) =>
                          '${item['first_name']} ${item['last_name']}',
                    ),
                    SizedBox(height: 16),
                    _buildFormDropdown(
                      label: 'Xona',
                      value: formRoomId,
                      items: rooms,
                      onChanged: (value) {
                        setState(() => formRoomId = value);
                        // Check if room is busy
                        if (value != null &&
                            formDaysOfWeek.isNotEmpty &&
                            formStartTime != null) {
                          for (var day in formDaysOfWeek) {
                            final startTimeStr =
                                '${formStartTime!.hour.toString().padLeft(2, '0')}:${formStartTime!.minute.toString().padLeft(2, '0')}:00';
                            if (_isRoomBusy(value, day, startTimeStr)) {
                              // Show warning
                            }
                          }
                        }
                      },
                      displayText: (item) =>
                          '${item['name']} (${item['capacity']} o\'rin)',
                      isRequired: false,
                    ),
                    SizedBox(height: 16),
                    _buildMultiDaySelector(),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTimeField(
                            'Boshlanish',
                            formStartTime,
                            true,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: _buildTimeField('Tugash', formEndTime, false),
                        ),
                      ],
                    ),
                    if (formRoomId != null &&
                        formDaysOfWeek.isNotEmpty &&
                        formStartTime != null)
                      _buildRoomConflictWarning(),
                    SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _saveLesson,
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          isEditingLesson
                              ? 'Saqlash'
                              : 'Qo\'shish (${formDaysOfWeek.length} kun)',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.primaryColor,
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMultiDaySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hafta kunlari (bir nechta tanlash mumkin)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppConstants.textPrimaryColor,
          ),
        ),
        SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: dayMapping.entries.map((entry) {
            final isSelected = formDaysOfWeek.contains(entry.key);
            return FilterChip(
              label: Text(entry.value),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    formDaysOfWeek.add(entry.key);
                  } else {
                    formDaysOfWeek.remove(entry.key);
                  }
                });
              },
              selectedColor: AppConstants.primaryColor.withOpacity(0.2),
              checkmarkColor: AppConstants.primaryColor,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRoomConflictWarning() {
    final conflicts = <String>[];
    for (var day in formDaysOfWeek) {
      final startTimeStr =
          '${formStartTime!.hour.toString().padLeft(2, '0')}:${formStartTime!.minute.toString().padLeft(2, '0')}:00';
      if (_isRoomBusy(formRoomId, day, startTimeStr)) {
        conflicts.add(dayMapping[day] ?? day);
      }
    }

    if (conflicts.isEmpty) return SizedBox();

    return Container(
      margin: EdgeInsets.only(top: 16),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppConstants.warningColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppConstants.warningColor),
      ),
      child: Row(
        children: [
          Icon(Icons.warning, color: AppConstants.warningColor, size: 20),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Diqqat! Xona band: ${conflicts.join(", ")}',
              style: TextStyle(fontSize: 13, color: AppConstants.warningColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHolidayForm() {
    return Container(
      padding: EdgeInsets.all(AppConstants.paddingLarge),
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(AppConstants.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.celebration,
                    color: AppConstants.warningColor,
                    size: 28,
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Ta\'til belgilash',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => setState(() => showHolidayDialog = false),
                  ),
                ],
              ),
              Divider(height: 32),
              Row(
                children: [
                  Checkbox(
                    value: isSchoolWideHoliday,
                    onChanged: (value) {
                      setState(() {
                        isSchoolWideHoliday = value ?? true;
                        if (isSchoolWideHoliday) {
                          holidayClassId = null;
                        }
                      });
                    },
                  ),
                  Text('Butun maktab uchun'),
                ],
              ),
              if (!isSchoolWideHoliday) ...[
                SizedBox(height: 16),
                _buildFormDropdown(
                  label: 'Sinf',
                  value: holidayClassId,
                  items: classes,
                  onChanged: (value) => setState(() => holidayClassId = value),
                  displayText: (item) =>
                      '${item['name']} - ${item['class_levels']['name']}',
                ),
              ],
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildDateField(
                      'Boshlanish sanasi',
                      holidayStartDate,
                      true,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildDateField(
                      'Tugash sanasi',
                      holidayEndDate,
                      false,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Sabab',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                onChanged: (value) => holidayReason = value,
              ),
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saveHoliday,
                  icon: Icon(Icons.save),
                  label: Text('Saqlash'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.warningColor,
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateField(String label, DateTime? date, bool isStart) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppConstants.textPrimaryColor,
          ),
        ),
        SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: date ?? DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime(2026),
            );
            if (picked != null) {
              setState(() {
                if (isStart) {
                  holidayStartDate = picked;
                } else {
                  holidayEndDate = picked;
                }
              });
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, size: 20, color: Colors.grey[600]),
                SizedBox(width: 8),
                Text(
                  date != null
                      ? DateFormat('dd.MM.yyyy').format(date)
                      : 'Tanlang',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showHolidaysDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: 500,
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.celebration, color: AppConstants.warningColor),
                  SizedBox(width: 12),
                  Text(
                    'Ta\'tillar ro\'yxati',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              Divider(height: 24),
              Container(
                constraints: BoxConstraints(maxHeight: 400),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: holidays.length,
                  itemBuilder: (context, index) {
                    final holiday = holidays[index];
                    final start = DateTime.parse(holiday['start_date']);
                    final end = DateTime.parse(holiday['end_date']);

                    return Card(
                      margin: EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: Icon(
                          (holiday['is_school_wide'] ?? false)
                              ? Icons.school
                              : Icons.class_,
                          color: AppConstants.warningColor,
                        ),
                        title: Text(
                          holiday['reason'] ?? 'Ta\'til',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          '${DateFormat('dd.MM.yyyy').format(start)} - ${DateFormat('dd.MM.yyyy').format(end)}\n${holiday['is_school_wide'] ? 'Butun maktab' : 'Sinf: ${holiday['class_id']}'}',
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            Icons.delete,
                            color: AppConstants.errorColor,
                          ),
                          onPressed: () => _deleteHoliday(holiday['id']),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormDropdown({
    required String label,
    required String? value,
    required List<dynamic> items,
    required Function(String?) onChanged,
    required String Function(dynamic) displayText,
    bool isRequired = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppConstants.textPrimaryColor,
          ),
        ),
        SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          hint: Text('$label tanlang'),
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item['id'],
              child: Text(displayText(item)),
            );
          }).toList(),
          onChanged: onChanged,
          validator: isRequired
              ? (value) => value == null ? '$label tanlanishi shart' : null
              : null,
        ),
      ],
    );
  }

  Widget _buildTimeField(String label, TimeOfDay? time, bool isStart) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppConstants.textPrimaryColor,
          ),
        ),
        SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final picked = await showTimePicker(
              context: context,
              initialTime: time ?? TimeOfDay.now(),
            );
            if (picked != null) {
              setState(() {
                if (isStart) {
                  formStartTime = picked;
                } else {
                  formEndTime = picked;
                }
              });
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.access_time, size: 20, color: Colors.grey[600]),
                SizedBox(width: 8),
                Text(
                  time != null ? time.format(context) : 'Tanlang',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        SizedBox(width: 8),
        Text(
          '$label:',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 80,
            color: Colors.grey[300],
          ),
          SizedBox(height: 20),
          Text(
            'Dars jadvali topilmadi',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Filtrlarni o\'zgartiring yoki yangi dars qo\'shing',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              _resetForm();
              setState(() => isAddingLesson = true);
            },
            icon: Icon(Icons.add),
            label: Text('Dars qo\'shish'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            ),
          ),
        ],
      ),
    );
  }

  void _resetForm() {
    formClassId = null;
    formSubjectId = null;
    formTeacherId = null;
    formRoomId = null;
    formDaysOfWeek.clear();
    formStartTime = null;
    formEndTime = null;
  }

  void _fillFormWithLesson(dynamic lesson) {
    formClassId = lesson['class_id'];
    formSubjectId = lesson['subject_id'];
    formTeacherId = lesson['teacher_id'];
    formRoomId = lesson['room_id'];
    formDaysOfWeek = [lesson['day_of_week']];

    final startParts = lesson['start_time'].split(':');
    formStartTime = TimeOfDay(
      hour: int.parse(startParts[0]),
      minute: int.parse(startParts[1]),
    );

    final endParts = lesson['end_time'].split(':');
    formEndTime = TimeOfDay(
      hour: int.parse(endParts[0]),
      minute: int.parse(endParts[1]),
    );
  }

  Future<void> _saveLesson() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (formStartTime == null || formEndTime == null) {
      return;
    }

    if (formDaysOfWeek.isEmpty) {
      return;
    }

    try {
      final startTimeStr =
          '${formStartTime!.hour.toString().padLeft(2, '0')}:${formStartTime!.minute.toString().padLeft(2, '0')}:00';
      final endTimeStr =
          '${formEndTime!.hour.toString().padLeft(2, '0')}:${formEndTime!.minute.toString().padLeft(2, '0')}:00';

      if (isEditingLesson && selectedLesson != null) {
        // Update existing lesson
        final data = {
          'class_id': formClassId,
          'subject_id': formSubjectId,
          'teacher_id': formTeacherId,
          'room_id': formRoomId,
          'day_of_week': formDaysOfWeek[0],
          'start_time': startTimeStr,
          'end_time': endTimeStr,
          'is_active': true,
        };

        await supabase
            .from('schedule_templates')
            .update(data)
            .eq('id', selectedLesson['id']);
      } else {
        // Create new lessons for each selected day
        for (var day in formDaysOfWeek) {
          final data = {
            'class_id': formClassId,
            'subject_id': formSubjectId,
            'teacher_id': formTeacherId,
            'room_id': formRoomId,
            'day_of_week': day,
            'start_time': startTimeStr,
            'end_time': endTimeStr,
            'is_active': true,
          };

          await supabase.from('schedule_templates').insert(data);
        }
      }

      setState(() {
        isAddingLesson = false;
        isEditingLesson = false;
      });

      await _loadScheduleData();
    } catch (e) {
      print('Error saving lesson: $e');
    }
  }

  Future<void> _saveHoliday() async {
    if (holidayStartDate == null || holidayEndDate == null) {
      return;
    }

    if (holidayReason.isEmpty) {
      return;
    }

    try {
      final data = {
        'start_date': holidayStartDate!.toIso8601String().split('T')[0],
        'end_date': holidayEndDate!.toIso8601String().split('T')[0],
        'reason': holidayReason,
        'is_school_wide': isSchoolWideHoliday,
        'class_id': isSchoolWideHoliday ? null : holidayClassId,
      };

      await supabase.from('holidays').insert(data);

      setState(() {
        showHolidayDialog = false;
        holidayStartDate = null;
        holidayEndDate = null;
        holidayReason = '';
        holidayClassId = null;
        isSchoolWideHoliday = true;
      });

      await _loadHolidays();
    } catch (e) {
      print('Error saving holiday: $e');
    }
  }

  Future<void> _deleteLesson(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('O\'chirish'),
        content: Text('Darsni o\'chirishni tasdiqlaysizmi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Bekor qilish'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.errorColor,
            ),
            child: Text('O\'chirish'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await supabase.from('schedule_templates').delete().eq('id', id);
        setState(() => showSidePanel = false);
        await _loadScheduleData();
      } catch (e) {
        print('Error deleting lesson: $e');
      }
    }
  }

  Future<void> _deleteHoliday(String id) async {
    try {
      await supabase.from('holidays').delete().eq('id', id);
      await _loadHolidays();
      Navigator.pop(context);
    } catch (e) {
      print('Error deleting holiday: $e');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

extension on PostgrestFilterBuilder<PostgrestList> {
  any(String s, List<dynamic> studentIds) {}
}
