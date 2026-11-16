import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../models/academic_calendar_model.dart';

class AcademicCalendarScreen extends StatefulWidget {
  const AcademicCalendarScreen({super.key});

  @override
  State<AcademicCalendarScreen> createState() => _AcademicCalendarScreenState();
}

class _AcademicCalendarScreenState extends State<AcademicCalendarScreen> {
  DateTime _currentMonth = DateTime(2026, 11, 1);
  DateTime? _selectedDate;
  CalendarEventType? _selectedFilter;

  final List<AcademicCalendarEvent> _allEvents = [
    AcademicCalendarEvent(
      id: 'cal-1',
      title: 'Ujian Tengah Semester (UTS) Ganjil',
      description:
          'Pelaksanaan UTS berbasis komputer untuk seluruh jenjang kelas X, XI, dan XII.',
      type: CalendarEventType.exam,
      startDate: DateTime(2026, 11, 16),
      endDate: DateTime(2026, 11, 21),
    ),
    AcademicCalendarEvent(
      id: 'cal-2',
      title: 'Hari Guru Nasional & Porseni Siswa',
      description:
          'Upacara bendera peringatan Hari Guru serta perlombaan seni dan olahraga antarkelas.',
      type: CalendarEventType.extracurricular,
      startDate: DateTime(2026, 11, 25),
      endDate: DateTime(2026, 11, 25),
    ),
    AcademicCalendarEvent(
      id: 'cal-3',
      title: 'Pekan Remedial & Pengayaan Akademik',
      description:
          'Bimbingan belajar khusus dan ujian perbaikan nilai capaian kompetensi dasar.',
      type: CalendarEventType.academic,
      startDate: DateTime(2026, 11, 26),
      endDate: DateTime(2026, 11, 28),
    ),
    AcademicCalendarEvent(
      id: 'cal-4',
      title: 'Penilaian Akhir Semester (PAS) Ganjil',
      description:
          'Ujian akhir semester ganjil seluruh mata pelajaran wajib dan peminatan.',
      type: CalendarEventType.exam,
      startDate: DateTime(2026, 12, 1),
      endDate: DateTime(2026, 12, 11),
    ),
    AcademicCalendarEvent(
      id: 'cal-5',
      title: 'Class Meeting & Expo Inovasi Siswa',
      description:
          'Turnamen e-sport, basket, futsal, dan pameran karya ilmiah teknologi siswa.',
      type: CalendarEventType.extracurricular,
      startDate: DateTime(2026, 12, 14),
      endDate: DateTime(2026, 12, 17),
    ),
    AcademicCalendarEvent(
      id: 'cal-6',
      title: 'Pembagian Rapot Digital Semester Ganjil',
      description:
          'Penyerahan E-Rapor kepada orang tua/wali siswa dan penerimaan konsultasi prestasi.',
      type: CalendarEventType.report,
      startDate: DateTime(2026, 12, 18),
      endDate: DateTime(2026, 12, 18),
    ),
    AcademicCalendarEvent(
      id: 'cal-7',
      title: 'Libur Akhir Semester Ganjil & Natal',
      description:
          'Libur semester ganjil tahun ajaran 2026/2027 dan libur bersama nasional.',
      type: CalendarEventType.holiday,
      startDate: DateTime(2026, 12, 21),
      endDate: DateTime(2027, 1, 2),
      isNationalHoliday: true,
    ),
    AcademicCalendarEvent(
      id: 'cal-8',
      title: 'Hari Pertama Masuk Semester Genap 2026/2027',
      description:
          'Awal perkuliahan dan belajar mengajar semester genap seluruh jenjang.',
      type: CalendarEventType.academic,
      startDate: DateTime(2027, 1, 4),
      endDate: DateTime(2027, 1, 4),
    ),
  ];

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
      _selectedDate = null;
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
      _selectedDate = null;
    });
  }

  List<AcademicCalendarEvent> get _filteredEvents {
    return _allEvents.where((e) {
      if (_selectedFilter != null && e.type != _selectedFilter) {
        return false;
      }

      if (_selectedDate != null) {
        return e.occursOn(_selectedDate!);
      }

      // Show events occurring within this month
      final monthStart = DateTime(_currentMonth.year, _currentMonth.month, 1);
      final monthEnd =
          DateTime(_currentMonth.year, _currentMonth.month + 1, 0, 23, 59, 59);

      return !(e.endDate.isBefore(monthStart) || e.startDate.isAfter(monthEnd));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceLight,
        elevation: 0,
        title: const Text(
          'Kalender Akademik',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimaryLight,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Calendar Container Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppColors.borderLight),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Month navigation
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: _previousMonth,
                        icon: const Icon(Icons.chevron_left_rounded),
                        color: AppColors.textPrimaryLight,
                      ),
                      Text(
                        DateFormat('MMMM yyyy', 'id_ID').format(_currentMonth),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimaryLight,
                        ),
                      ),
                      IconButton(
                        onPressed: _nextMonth,
                        icon: const Icon(Icons.chevron_right_rounded),
                        color: AppColors.textPrimaryLight,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Days of week header
                  Row(
                    children: ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab']
                        .map((day) => Expanded(
                              child: Center(
                                child: Text(
                                  day,
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    color: day == 'Min'
                                        ? AppColors.danger
                                        : AppColors.textMutedLight,
                                  ),
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 8),
                  const Divider(height: 1, color: AppColors.borderLight),
                  const SizedBox(height: 8),

                  // Calendar Grid
                  _buildCalendarDaysGrid(),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Event Type Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _filterChip(null, 'Semua Agenda'),
                  ...CalendarEventType.values.map(
                    (type) => _filterChip(type, type.label),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Section Header
            Row(
              children: [
                Text(
                  _selectedDate != null
                      ? 'Agenda: ${DateFormat("d MMMM yyyy", "id_ID").format(_selectedDate!)}'
                      : 'Agenda ${DateFormat("MMMM yyyy", "id_ID").format(_currentMonth)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
                const Spacer(),
                if (_selectedDate != null)
                  GestureDetector(
                    onTap: () => setState(() => _selectedDate = null),
                    child: const Text(
                      'Tampilkan Sebulan',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // List of Events
            if (_filteredEvents.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.event_available_rounded,
                      size: 40,
                      color: AppColors.textMutedLight,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Tidak ada agenda khusus pada tanggal/kategori ini.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondaryLight,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )
            else
              ..._filteredEvents.map((e) => _buildEventCard(e)),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarDaysGrid() {
    final firstDayOfMonth =
        DateTime(_currentMonth.year, _currentMonth.month, 1);
    final daysInMonth =
        DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    // DateTime weekday: Monday=1, Sunday=7. Our grid starts on Sunday (weekday % 7)
    final startingWeekday = firstDayOfMonth.weekday % 7;

    final totalCells = startingWeekday + daysInMonth;
    final rowCount = (totalCells / 7).ceil();

    return Column(
      children: List.generate(rowCount, (rowIndex) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: List.generate(7, (colIndex) {
              final cellIndex = rowIndex * 7 + colIndex;
              final dayNumber = cellIndex - startingWeekday + 1;

              if (dayNumber < 1 || dayNumber > daysInMonth) {
                return const Expanded(child: SizedBox(height: 36));
              }

              final cellDate = DateTime(
                  _currentMonth.year, _currentMonth.month, dayNumber);
              final isToday = DateTime.now().year == cellDate.year &&
                  DateTime.now().month == cellDate.month &&
                  DateTime.now().day == cellDate.day;
              final isSelected = _selectedDate != null &&
                  _selectedDate!.year == cellDate.year &&
                  _selectedDate!.month == cellDate.month &&
                  _selectedDate!.day == cellDate.day;

              // Check events on this day
              final dayEvents =
                  _allEvents.where((e) => e.occursOn(cellDate)).toList();

              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedDate = null;
                      } else {
                        _selectedDate = cellDate;
                      }
                    });
                  },
                  child: Container(
                    height: 42,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : isToday
                              ? AppColors.primarySubtle
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$dayNumber',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: isSelected || isToday
                                ? FontWeight.w800
                                : FontWeight.w500,
                            color: isSelected
                                ? Colors.white
                                : colIndex == 0
                                    ? AppColors.danger
                                    : AppColors.textPrimaryLight,
                          ),
                        ),
                        if (dayEvents.isNotEmpty)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: dayEvents.take(3).map((e) {
                              return Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 1),
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected
                                      ? Colors.white
                                      : Color(e.type.colorHex),
                                ),
                              );
                            }).toList(),
                          )
                        else
                          const SizedBox(height: 4),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      }),
    );
  }

  Widget _filterChip(CalendarEventType? type, String label) {
    final isSelected = _selectedFilter == type;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Text(label),
        labelStyle: TextStyle(
          fontSize: 11.5,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          color: isSelected ? Colors.white : AppColors.textSecondaryLight,
        ),
        backgroundColor: AppColors.surfaceLight,
        selectedColor: AppColors.primary,
        checkmarkColor: Colors.white,
        showCheckmark: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isSelected ? AppColors.primary : AppColors.borderLight,
          ),
        ),
        onSelected: (_) => setState(() => _selectedFilter = type),
      ),
    );
  }

  Widget _buildEventCard(AcademicCalendarEvent event) {
    final isSingleDay = event.startDate.year == event.endDate.year &&
        event.startDate.month == event.endDate.month &&
        event.startDate.day == event.endDate.day;

    final dateFormatted = isSingleDay
        ? DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(event.startDate)
        : '${DateFormat("d MMM", "id_ID").format(event.startDate)} - ${DateFormat("d MMMM yyyy", "id_ID").format(event.endDate)}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Color(event.type.colorHex).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              event.type == CalendarEventType.exam
                  ? Icons.edit_calendar_rounded
                  : event.type == CalendarEventType.holiday
                      ? Icons.beach_access_rounded
                      : event.type == CalendarEventType.report
                          ? Icons.military_tech_rounded
                          : Icons.event_note_rounded,
              color: Color(event.type.colorHex),
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Color(event.type.colorHex).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        event.type.label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Color(event.type.colorHex),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      dateFormatted,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMutedLight,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  event.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  event.description,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
