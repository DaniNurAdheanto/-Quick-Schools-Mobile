import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/grade_model.dart';
import '../../providers/academic_provider.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  late int _selectedDay;
  Timer? _tickerTimer;

  final List<({int day, String shortName, String fullName})> _days = const [
    (day: 1, shortName: 'Sen', fullName: 'Senin'),
    (day: 2, shortName: 'Sel', fullName: 'Selasa'),
    (day: 3, shortName: 'Rab', fullName: 'Rabu'),
    (day: 4, shortName: 'Kam', fullName: 'Kamis'),
    (day: 5, shortName: 'Jum', fullName: 'Jumat'),
  ];

  @override
  void initState() {
    super.initState();
    final weekday = DateTime.now().weekday;
    _selectedDay = (weekday >= 1 && weekday <= 5) ? weekday : 1;
    _tickerTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tickerTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final academic = Provider.of<AcademicProvider>(context);
    final daySchedules = academic.schedules
        .where((s) => s.dayOfWeek == _selectedDay)
        .toList();
    final activeDayName =
        _days.firstWhere((d) => d.day == _selectedDay).fullName;
    final isToday = DateTime.now().weekday == _selectedDay;
    final ongoingSchedule = daySchedules
        .cast<ScheduleModel?>()
        .firstWhere((s) => s != null && s.isOngoing, orElse: () => null);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header + Day Selector Card
            Container(
              color: AppColors.surfaceLight,
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Jadwal Pelajaran',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.4,
                          color: AppColors.textPrimaryLight,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primarySubtle,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${daySchedules.length} Kelas • $activeDayName',
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: _days.map((item) {
                      final isSelected = item.day == _selectedDay;
                      final hasClasses = academic.schedules
                          .any((s) => s.dayOfWeek == item.day);
                      final isToday = DateTime.now().weekday == item.day;

                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedDay = item.day),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.backgroundLight,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : isToday
                                        ? AppColors.primaryLight
                                            .withValues(alpha: 0.45)
                                        : AppColors.borderLight,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: AppColors.primary
                                            .withValues(alpha: 0.25),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Column(
                              children: [
                                Text(
                                  item.shortName,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.textPrimaryLight,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  width: 5,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: hasClasses
                                        ? (isSelected
                                            ? Colors.white
                                            : AppColors.primary)
                                        : Colors.transparent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.borderLight),

            // Live Alert Banner if today has ongoing class
            if (isToday && ongoingSchedule != null)
              Container(
                margin: const EdgeInsets.fromLTRB(20, 14, 20, 4),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFF0FDF4),
                      Color(0xFFDCFCE7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFF86EFAC),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF16A34A).withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF16A34A),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Jam Aktif: ${ongoingSchedule.subjectName} (${ongoingSchedule.room})',
                        style: const TextStyle(
                          fontFamily: 'Geist',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF15803D),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: const Color(0xFF86EFAC),
                        ),
                      ),
                      child: Text(
                        'Sisa ${ongoingSchedule.remainingMinutes}m',
                        style: const TextStyle(
                          fontFamily: 'Geist',
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF15803D),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Timeline List
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => academic.fetchAllAcademicData(),
                color: AppColors.primary,
                child: daySchedules.isEmpty
                    ? ListView(
                        padding: const EdgeInsets.all(24),
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 42,
                              horizontal: 20,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceLight,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.borderLight),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: AppColors.primarySubtle,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Icon(
                                    Icons.event_available_rounded,
                                    size: 28,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  'Tidak Ada Kelas di Hari $activeDayName',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimaryLight,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Pilih hari lain di atas untuk melihat jadwal mata pelajaran.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: AppColors.textSecondaryLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                        itemCount: daySchedules.length,
                        itemBuilder: (context, index) {
                          final item = daySchedules[index];
                          final isLast = index == daySchedules.length - 1;
                          return _buildTimelineItem(item, isLast);
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(ScheduleModel item, bool isLast) {
    final isNow = item.isOngoing;
    final isCompleted = item.isCompleted;
    final isUpcoming = item.isUpcoming;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline Rail
          SizedBox(
            width: 58,
            child: Column(
              children: [
                Text(
                  item.startTime,
                  style: TextStyle(
                    fontFamily: 'Geist',
                    fontSize: 13,
                    fontWeight: isNow ? FontWeight.w900 : FontWeight.w700,
                    color: isNow
                        ? const Color(0xFF15803D)
                        : isCompleted
                            ? AppColors.textMutedLight
                            : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 6),
                if (isNow)
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF16A34A).withValues(alpha: 0.25),
                        ),
                      ),
                      Container(
                        width: 9,
                        height: 9,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF16A34A),
                        ),
                      ),
                    ],
                  )
                else if (isCompleted)
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.backgroundLight,
                      border: Border.all(
                        color: AppColors.borderLight,
                        width: 2,
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.check,
                        size: 8,
                        color: AppColors.textMutedLight,
                      ),
                    ),
                  )
                else
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: (isUpcoming && item.minutesUntilStart <= 45)
                          ? const Color(0xFFD97706)
                          : AppColors.surfaceLight,
                      border: Border.all(
                        color: (isUpcoming && item.minutesUntilStart <= 45)
                            ? const Color(0xFFD97706)
                            : AppColors.primaryLight,
                        width: 2.5,
                      ),
                    ),
                  ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: isNow
                          ? const Color(0xFF86EFAC)
                          : AppColors.borderLight,
                    ),
                  ),
              ],
            ),
          ),

          // Schedule Card
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isNow
                    ? const Color(0xFFF0FDF4)
                    : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isNow
                      ? const Color(0xFF16A34A)
                      : isCompleted
                          ? AppColors.borderLight.withValues(alpha: 0.6)
                          : AppColors.borderLight,
                  width: isNow ? 1.8 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isNow
                        ? const Color(0xFF16A34A).withValues(alpha: 0.12)
                        : const Color(0xFF0F172A).withValues(alpha: 0.03),
                    blurRadius: isNow ? 14 : 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Card Header Row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isNow
                              ? const Color(0xFF16A34A).withValues(alpha: 0.12)
                              : AppColors.primarySubtle,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item.subjectCode,
                          style: TextStyle(
                            fontFamily: 'Geist',
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: isNow
                                ? const Color(0xFF15803D)
                                : AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Status Badge Statement
                      if (isNow)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3.5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFF86EFAC),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF16A34A),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 5),
                              const Text(
                                'AKTIF',
                                style: TextStyle(
                                  fontFamily: 'Geist',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF15803D),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        )
                      else if (isCompleted)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundLight,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.borderLight),
                          ),
                          child: const Text(
                            'SELESAI',
                            style: TextStyle(
                              fontFamily: 'Geist',
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textMutedLight,
                            ),
                          ),
                        )
                      else if (isUpcoming && item.minutesUntilStart <= 45)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: const Color(0xFFFDE68A),
                            ),
                          ),
                          child: Text(
                            'MULAI DLM ${item.minutesUntilStart}M',
                            style: const TextStyle(
                              fontFamily: 'Geist',
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFB45309),
                            ),
                          ),
                        ),

                      const Spacer(),
                      Text(
                        '${item.startTime} - ${item.endTime}',
                        style: TextStyle(
                          fontFamily: 'Geist',
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: isNow
                              ? const Color(0xFF15803D)
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Subject Title
                  Text(
                    item.subjectName,
                    style: TextStyle(
                      fontFamily: 'Geist',
                      fontSize: 15.5,
                      fontWeight: FontWeight.w800,
                      color: isNow
                          ? const Color(0xFF14532D)
                          : isCompleted
                              ? AppColors.textSecondaryLight
                              : AppColors.textPrimaryLight,
                    ),
                  ),

                  // Live Class Statement Bar
                  if (isNow) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF16A34A).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.radio_button_checked_rounded,
                            size: 13,
                            color: Color(0xFF16A34A),
                          ),
                          const SizedBox(width: 6),
                          const Expanded(
                            child: Text(
                              'Kelas sedang berlangsung saat ini',
                              style: TextStyle(
                                fontFamily: 'Geist',
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF15803D),
                              ),
                            ),
                          ),
                          Text(
                            'Sisa ${item.remainingMinutes} mnt',
                            style: const TextStyle(
                              fontFamily: 'Geist',
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF15803D),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 8),

                  // Teacher and Room info
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline_rounded,
                        size: 15,
                        color: isNow
                            ? const Color(0xFF16A34A)
                            : AppColors.textMutedLight,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          item.teacherName,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Geist',
                            fontSize: 12.5,
                            fontWeight: isNow
                                ? FontWeight.w600
                                : FontWeight.normal,
                            color: isNow
                                ? const Color(0xFF166534)
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isNow
                              ? Colors.white
                              : AppColors.backgroundLight,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isNow
                                ? const Color(0xFF86EFAC)
                                : AppColors.borderLight,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.room_outlined,
                              size: 12,
                              color: isNow
                                  ? const Color(0xFF16A34A)
                                  : AppColors.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              item.room,
                              style: TextStyle(
                                fontFamily: 'Geist',
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: isNow
                                    ? const Color(0xFF15803D)
                                    : AppColors.textPrimaryLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
