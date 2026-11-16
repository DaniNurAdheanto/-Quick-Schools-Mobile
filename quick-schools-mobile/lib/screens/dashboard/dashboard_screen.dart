import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/academic_provider.dart';
import '../../models/user_model.dart';
import '../../models/attendance_model.dart';
import '../../models/grade_model.dart';
import '../../models/announcement_model.dart';
import '../../core/constants/app_colors.dart';
import '../attendance/attendance_screen.dart';
import '../attendance/face_attendance_screen.dart';
import '../attendance/leave_request_screen.dart';
import '../exam/exam_schedule_screen.dart';
import '../report_card/report_card_screen.dart';
import '../academic_calendar/academic_calendar_screen.dart';
import '../schedule/schedule_screen.dart';
import '../grades/grades_screen.dart';
import '../announcements/announcements_screen.dart';
import '../profile/profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  int _selectedScheduleDay =
      DateTime.now().weekday > 5 ? 1 : DateTime.now().weekday;
  Timer? _clockTimer;

  @override
  void initState() {
    super.initState();
    _clockTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  String get _timeGreeting {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat Pagi';
    if (hour < 15) return 'Selamat Siang';
    if (hour < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.currentUser;

    if (user == null) {
      return const Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    final pages = [
      _buildHomeTab(context, user),
      const AttendanceScreen(),
      const ScheduleScreen(),
      const GradesScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: _buildModernBottomNav(),
    );
  }

  Widget _buildModernBottomNav() {
    const items = [
      (Icons.home_outlined, Icons.home_rounded, 'Beranda'),
      (Icons.how_to_reg_outlined, Icons.how_to_reg_rounded, 'Presensi'),
      (Icons.calendar_today_outlined, Icons.calendar_month_rounded, 'Jadwal'),
      (Icons.bar_chart_outlined, Icons.bar_chart_rounded, 'Nilai'),
      (Icons.person_outline_rounded, Icons.person_rounded, 'Profil'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        border: const Border(
          top: BorderSide(color: AppColors.borderLight, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: List.generate(items.length, (index) {
              final (inactiveIcon, activeIcon, label) = items[index];
              final isSelected = _currentIndex == index;

              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => setState(() => _currentIndex = index),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOutCubic,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primarySubtle
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          isSelected ? activeIcon : inactiveIcon,
                          size: 22,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textMutedLight,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textMutedLight,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildHomeTab(BuildContext context, UserModel user) {
    final attendance = Provider.of<AttendanceProvider>(context);
    final academic = Provider.of<AcademicProvider>(context);

    final selectedDaySchedules = academic.schedules
        .where((s) => s.dayOfWeek == _selectedScheduleDay)
        .toList();

    final ScheduleModel? ongoingClass = academic.schedules
        .cast<ScheduleModel?>()
        .firstWhere((s) => s != null && s.isOngoing, orElse: () => null);

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            attendance.fetchAttendance(),
            academic.fetchAllAcademicData(),
          ]);
        },
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top App Bar Greeting
              _buildTopHeader(context, user, academic.announcements.length),
              const SizedBox(height: 18),

              // Unified Smart Student & Attendance Card
              _buildStudentActionCard(context, user, attendance),
              const SizedBox(height: 18),

              // Presensi Kehadiran Siswa Section
              _buildAttendanceDetailCard(context, attendance),
              const SizedBox(height: 22),

              // Menu Layanan Siswa Header & Grid
              _buildSectionHeader(
                title: 'Layanan Siswa',
              ),
              const SizedBox(height: 12),
              _buildQuickActions(context),
              const SizedBox(height: 22),

              // Bento Quick Stats Grid
              _buildQuickStatsRow(attendance, academic),
              const SizedBox(height: 24),

              // Schedule Section with Day Selector
              _buildSectionHeader(
                title: 'Jadwal Pelajaran',
                actionLabel: 'Jadwal Lengkap',
                onTap: () => setState(() => _currentIndex = 2),
              ),
              const SizedBox(height: 10),
              if (ongoingClass != null) ...[
                _buildOngoingClassLiveBanner(context, ongoingClass),
                const SizedBox(height: 12),
              ],
              _buildScheduleDaySelector(),
              const SizedBox(height: 12),
              if (selectedDaySchedules.isNotEmpty)
                _buildTodayScheduleCarousel(context, selectedDaySchedules)
              else
                _buildEmptyStateCard(
                  icon: Icons.event_available_rounded,
                  message:
                      'Belum ada jadwal kelas pada hari ${_dayName(_selectedScheduleDay)}.',
                ),
              const SizedBox(height: 22),

              // Announcements Section
              _buildSectionHeader(
                title: 'Pengumuman Sekolah',
                actionLabel: 'Lihat Semua',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const AnnouncementsScreen(),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (academic.announcements.isNotEmpty)
                _buildAnnouncementCarousel(context, academic.announcements)
              else
                _buildEmptyStateCard(
                  icon: Icons.campaign_outlined,
                  message: 'Belum ada pengumuman terbaru.',
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopHeader(
    BuildContext context,
    UserModel user,
    int announcementCount,
  ) {
    final initials = [
      if (user.firstName.isNotEmpty) user.firstName[0],
      if (user.lastName.isNotEmpty) user.lastName[0],
    ].join().toUpperCase();

    return Row(
      children: [
        // User Initials Avatar
        GestureDetector(
          onTap: () => setState(() => _currentIndex = 4),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, AppColors.primaryLight],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.22),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                initials.isEmpty ? 'QS' : initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Greeting & Class Tag
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$_timeGreeting,',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 1),
              Row(
                children: [
                  Flexible(
                    child: Text(
                      user.fullName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primarySubtle,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      user.className ?? 'XII-IPA 1',
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Digital ID Shortcut
        Material(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: () => _showDigitalIdModal(context, user),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: const Icon(
                Icons.qr_code_2_rounded,
                size: 21,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Notification Button
        Material(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const AnnouncementsScreen(),
                ),
              );
            },
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(
                    Icons.notifications_none_rounded,
                    size: 21,
                    color: AppColors.textPrimaryLight,
                  ),
                  if (announcementCount > 0)
                    Positioned(
                      right: 10,
                      top: 10,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppColors.danger,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.4),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showDigitalIdModal(BuildContext context, UserModel user) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'KARTU PELAJAR DIGITAL',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user.schoolName ?? 'SMA Quick Schools Unggulan',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.borderLight),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.05),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.qr_code_2_rounded,
                      size: 140,
                      color: AppColors.textPrimaryLight,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'NISN: ${user.identifierNumber ?? "0068472910"}',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Text(
                user.fullName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              Text(
                'Kelas: ${user.className ?? "XII-IPA 1"} • Tahun 2026/2027',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Tutup'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStudentActionCard(
    BuildContext context,
    UserModel user,
    AttendanceProvider attendance,
  ) {
    final todayRecord = attendance.todayAttendance;
    final hasCheckedIn = todayRecord != null;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: hasCheckedIn
              ? [const Color(0xFF0F172A), const Color(0xFF1E293B)]
              : [AppColors.primaryDark, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: (hasCheckedIn ? const Color(0xFF0F172A) : AppColors.primary)
                .withValues(alpha: 0.28),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background ambient circle
          Positioned(
            top: -24,
            right: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Meta Badge Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.25),
                              ),
                            ),
                            child: Text(
                              user.className ?? 'XII-IPA 1',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'Sem. Ganjil',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: hasCheckedIn
                            ? AppColors.success.withValues(alpha: 0.25)
                            : Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            hasCheckedIn
                                ? Icons.verified_rounded
                                : Icons.schedule_rounded,
                            color: hasCheckedIn
                                ? AppColors.successLight
                                : Colors.white,
                            size: 13,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            hasCheckedIn ? 'Hadir' : 'Presensi Dibuka',
                            style: TextStyle(
                              color: hasCheckedIn
                                  ? AppColors.successLight
                                  : Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Student Full Name & School
                Text(
                  user.fullName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user.schoolName ?? 'SMA Quick Schools Unggulan',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),

                // Dynamic Action / Verified Status Area
                if (hasCheckedIn)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.22),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Absensi Hari Ini Selesai',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Tercatat pukul ${todayRecord.checkInTime ?? "07:15 WIB"} • GPS Terverifikasi',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  fontSize: 11.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            '1x/Hari',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const FaceAttendanceScreen(),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.face_retouching_natural_rounded,
                            size: 19,
                          ),
                          label: const Text(
                            'Scan Wajah Sekarang',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.primary,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const LeaveRequestScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.edit_note_rounded, size: 18),
                        label: const Text(
                          'Izin',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: BorderSide(
                            color: Colors.white.withValues(alpha: 0.4),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 13,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Section Presensi Kehadiran Siswa
  /// Menampilkan status presensi hari ini dan rekapitulasi kehadiran (Hadir, Terlambat, Izin, Sakit, Alpa)
  Widget _buildAttendanceDetailCard(
    BuildContext context,
    AttendanceProvider attendance,
  ) {
    final isDark = AppColors.isDark(context);
    final today = DateTime.now();
    final dateStr = DateFormat('d MMMM yyyy', 'id_ID').format(today);
    final todayRecord = attendance.todayAttendance;

    final (
      statusLabel,
      statusIcon,
      statusBg,
      statusBorder,
      statusFg,
    ) = _resolveTodayAttendanceStatus(todayRecord, isDark);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border(context)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Icon + Title on Left, Date on Right
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(
                      Icons.event_available_rounded,
                      color: Color(0xFF6366F1),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Presensi Kehadiran Siswa',
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                            color: AppColors.textPrimary(context),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                dateStr,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary(context),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          Divider(
            height: 1,
            thickness: 1,
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
          ),
          const SizedBox(height: 14),

          // Status Hari Ini Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Status Hari Ini:',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? const Color(0xFFCBD5E1)
                        : const Color(0xFF334155),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: statusBorder),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 15, color: statusFg),
                      const SizedBox(width: 6),
                      Text(
                        statusLabel,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: statusFg,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // 5 Metric Boxes in a Row: Hadir, Terlambat, Izin, Sakit, Alpa
          Row(
            children: [
              Expanded(
                child: _buildAttendanceMetricBox(
                  count: attendance.presentCount,
                  label: 'Hadir',
                  numberColor: const Color(0xFF6366F1),
                  bgColor: isDark
                      ? const Color(0xFF1E1B4B).withValues(alpha: 0.5)
                      : const Color(0xFFFAF9FF),
                  borderColor: isDark
                      ? const Color(0xFF3730A3).withValues(alpha: 0.5)
                      : const Color(0xFFEDE9FE),
                  isDark: isDark,
                  onTap: () => setState(() => _currentIndex = 1),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildAttendanceMetricBox(
                  count: attendance.lateCount,
                  label: 'Terlambat',
                  numberColor: const Color(0xFF3B82F6),
                  bgColor: isDark
                      ? const Color(0xFF172554).withValues(alpha: 0.5)
                      : const Color(0xFFF5F8FF),
                  borderColor: isDark
                      ? const Color(0xFF1E40AF).withValues(alpha: 0.5)
                      : const Color(0xFFDBEAFE),
                  isDark: isDark,
                  onTap: () => setState(() => _currentIndex = 1),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildAttendanceMetricBox(
                  count: attendance.permissionCount,
                  label: 'Izin',
                  numberColor: const Color(0xFFD97706),
                  bgColor: isDark
                      ? const Color(0xFF451A03).withValues(alpha: 0.4)
                      : const Color(0xFFFFFDF5),
                  borderColor: isDark
                      ? const Color(0xFF78350F).withValues(alpha: 0.4)
                      : const Color(0xFFFEF08A),
                  isDark: isDark,
                  onTap: () => setState(() => _currentIndex = 1),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildAttendanceMetricBox(
                  count: attendance.sickCount,
                  label: 'Sakit',
                  numberColor: const Color(0xFF0284C7),
                  bgColor: isDark
                      ? const Color(0xFF082F49).withValues(alpha: 0.5)
                      : const Color(0xFFF0F9FF),
                  borderColor: isDark
                      ? const Color(0xFF075985).withValues(alpha: 0.5)
                      : const Color(0xFFBAE6FD),
                  isDark: isDark,
                  onTap: () => setState(() => _currentIndex = 1),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildAttendanceMetricBox(
                  count: attendance.absentCount,
                  label: 'Alpa',
                  numberColor: const Color(0xFFE11D48),
                  bgColor: isDark
                      ? const Color(0xFF4C0519).withValues(alpha: 0.4)
                      : const Color(0xFFFFF1F2),
                  borderColor: isDark
                      ? const Color(0xFF9F1239).withValues(alpha: 0.4)
                      : const Color(0xFFFECDD3),
                  isDark: isDark,
                  onTap: () => setState(() => _currentIndex = 1),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  (String, IconData, Color, Color, Color) _resolveTodayAttendanceStatus(
    AttendanceModel? todayRecord,
    bool isDark,
  ) {
    if (todayRecord == null) {
      return (
        'Alpa (- WIB)',
        Icons.warning_amber_rounded,
        isDark ? const Color(0xFF3F0B18) : const Color(0xFFFFF1F2),
        isDark ? const Color(0xFF9F1239) : const Color(0xFFFDA4AF),
        const Color(0xFFBE123C),
      );
    }

    final time = todayRecord.checkInTime ?? '- WIB';

    switch (todayRecord.status) {
      case AttendanceStatus.present:
        return (
          'Hadir ($time)',
          Icons.check_circle_outline_rounded,
          isDark ? const Color(0xFF052E16) : const Color(0xFFF0FDF4),
          isDark ? const Color(0xFF166534) : const Color(0xFF86EFAC),
          const Color(0xFF15803D),
        );
      case AttendanceStatus.late:
        return (
          'Terlambat ($time)',
          Icons.schedule_rounded,
          isDark ? const Color(0xFF451A03) : const Color(0xFFFFFBEB),
          isDark ? const Color(0xFF92400E) : const Color(0xFFFCD34D),
          const Color(0xFFB45309),
        );
      case AttendanceStatus.excused:
        final isSick =
            todayRecord.notes?.toLowerCase().contains('sakit') == true;
        if (isSick) {
          return (
            'Sakit ($time)',
            Icons.medical_services_outlined,
            isDark ? const Color(0xFF082F49) : const Color(0xFFF0F9FF),
            isDark ? const Color(0xFF075985) : const Color(0xFFBAE6FD),
            const Color(0xFF0284C7),
          );
        }
        return (
          'Izin ($time)',
          Icons.info_outline_rounded,
          isDark ? const Color(0xFF172554) : const Color(0xFFEFF6FF),
          isDark ? const Color(0xFF1E40AF) : const Color(0xFF93C5FD),
          const Color(0xFF1D4ED8),
        );
      case AttendanceStatus.absent:
        return (
          'Alpa ($time)',
          Icons.warning_amber_rounded,
          isDark ? const Color(0xFF3F0B18) : const Color(0xFFFFF1F2),
          isDark ? const Color(0xFF9F1239) : const Color(0xFFFDA4AF),
          const Color(0xFFBE123C),
        );
    }
  }

  Widget _buildAttendanceMetricBox({
    required int count,
    required String label,
    required Color numberColor,
    required Color bgColor,
    required Color borderColor,
    required bool isDark,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 2),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 1.2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: numberColor,
                    height: 1.1,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF475569),
                    height: 1.1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final services = [
      (
        'Absensi Wajah',
        Icons.face_retouching_natural_rounded,
        AppColors.primary,
        const Color(0xFFF2EEFF),
        () {
          final attendance =
              Provider.of<AttendanceProvider>(context, listen: false);
          if (attendance.hasCheckedInToday) {
            setState(() => _currentIndex = 1);
            return;
          }
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const FaceAttendanceScreen(),
            ),
          );
        },
      ),
      (
        'Izin & Sakit',
        Icons.medical_services_outlined,
        const Color(0xFFEA580C),
        const Color(0xFFFFF7ED),
        () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const LeaveRequestScreen(),
          ),
        ),
      ),
      (
        'Jadwal Ujian',
        Icons.assignment_turned_in_outlined,
        const Color(0xFF6366F1),
        const Color(0xFFEEF2FF),
        () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const ExamScheduleScreen(),
          ),
        ),
      ),
      (
        'Rapot Digital',
        Icons.military_tech_outlined,
        const Color(0xFFD97706),
        const Color(0xFFFEF3C7),
        () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const ReportCardScreen(),
          ),
        ),
      ),
      (
        'Penilaian',
        Icons.auto_graph_rounded,
        const Color(0xFF0D9488),
        const Color(0xFFF0FDFA),
        () => setState(() => _currentIndex = 3),
      ),
      (
        'Jadwal Kelas',
        Icons.calendar_month_rounded,
        const Color(0xFF0284C7),
        const Color(0xFFF0F9FF),
        () => setState(() => _currentIndex = 2),
      ),
      (
        'Kalender',
        Icons.date_range_rounded,
        const Color(0xFF16A34A),
        const Color(0xFFF0FDF4),
        () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const AcademicCalendarScreen(),
          ),
        ),
      ),
      (
        'Pengumuman',
        Icons.campaign_outlined,
        const Color(0xFFE11D48),
        const Color(0xFFFFF1F2),
        () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const AnnouncementsScreen(),
          ),
        ),
      ),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: services.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 14,
          crossAxisSpacing: 8,
          childAspectRatio: 0.8,
        ),
        itemBuilder: (context, index) {
          final (label, icon, color, bg, onTap) = services[index];
          return InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: color.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Icon(icon, color: color, size: 23),
                ),
                const SizedBox(height: 7),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickStatsRow(
    AttendanceProvider attendance,
    AcademicProvider academic,
  ) {
    final avg = academic.averageGrade;
    final predicate = avg >= 90
        ? 'Predikat A'
        : avg >= 80
            ? 'Predikat B'
            : 'Predikat C';

    return Row(
      children: [
        Expanded(
          child: _buildBentoStatCard(
            label: 'Kehadiran',
            value: '${attendance.attendancePercentage.toStringAsFixed(1)}%',
            subtitle: '${attendance.presentCount}x Hadir Semester Ini',
            icon: Icons.check_circle_rounded,
            color: AppColors.success,
            progress: (attendance.attendancePercentage / 100).clamp(0.0, 1.0),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildBentoStatCard(
            label: 'Rata-rata Nilai',
            value: avg.toStringAsFixed(1),
            subtitle: '$predicate • ${academic.grades.length} Penilaian',
            icon: Icons.workspace_premium_rounded,
            color: AppColors.primary,
            progress: (avg / 100).clamp(0.0, 1.0),
          ),
        ),
      ],
    );
  }

  Widget _buildBentoStatCard({
    required String label,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required double progress,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 12,
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
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 17),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 5,
              backgroundColor: color.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textMutedLight,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    String? actionLabel,
    VoidCallback? onTap,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16.5,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
            color: AppColors.textPrimaryLight,
          ),
        ),
        if (actionLabel != null && onTap != null)
          TextButton(
            onPressed: onTap,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Row(
              children: [
                Text(
                  actionLabel,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 2),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 16,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildScheduleDaySelector() {
    final currentWeekday = DateTime.now().weekday;
    final days = [
      (1, 'Senin', 'Sen'),
      (2, 'Selasa', 'Sel'),
      (3, 'Rabu', 'Rab'),
      (4, 'Kamis', 'Kam'),
      (5, 'Jumat', 'Jum'),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: days.map((d) {
          final (dayIndex, _, shortName) = d;
          final isSelected = _selectedScheduleDay == dayIndex;
          final isToday = currentWeekday == dayIndex;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () => setState(() => _selectedScheduleDay = dayIndex),
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color:
                      isSelected ? AppColors.primary : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color:
                        isSelected ? AppColors.primary : AppColors.borderLight,
                    width: 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.22),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isToday)
                      Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.only(right: 6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? Colors.white : AppColors.success,
                        ),
                      ),
                    Text(
                      shortName,
                      style: TextStyle(
                        fontFamily: 'Geist',
                        fontSize: 12,
                        fontWeight:
                            isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildOngoingClassLiveBanner(
    BuildContext context,
    ScheduleModel ongoing,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF0FDF4),
            Color(0xFFDCFCE7),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF86EFAC),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF16A34A).withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: () => setState(() => _currentIndex = 2),
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF16A34A),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          const Text(
                            'KELAS AKTIF SAAT INI',
                            style: TextStyle(
                              fontFamily: 'Geist',
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3.5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFF86EFAC),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.timer_outlined,
                            size: 13,
                            color: Color(0xFF15803D),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Sisa ${ongoing.remainingMinutes} Menit',
                            style: const TextStyle(
                              fontFamily: 'Geist',
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF15803D),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  ongoing.subjectName,
                  style: const TextStyle(
                    fontFamily: 'Geist',
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF14532D),
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.room_outlined,
                      size: 13.5,
                      color: Color(0xFF16A34A),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      ongoing.room,
                      style: const TextStyle(
                        fontFamily: 'Geist',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF166534),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      '•',
                      style: TextStyle(
                        color: Color(0xFF86EFAC),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.person_outline_rounded,
                      size: 13.5,
                      color: Color(0xFF16A34A),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        ongoing.teacherName,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Geist',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF166534),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${ongoing.startTime} - ${ongoing.endTime}',
                      style: const TextStyle(
                        fontFamily: 'Geist',
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF15803D),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTodayScheduleCarousel(
    BuildContext context,
    List<ScheduleModel> schedules,
  ) {
    return SizedBox(
      height: 172,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: schedules.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final item = schedules[index];
          final isOngoing = item.isOngoing;
          final isCompleted = item.isCompleted;
          final isUpcoming = item.isUpcoming;

          final subLower = item.subjectName.toLowerCase();
          final IconData subjectIcon = subLower.contains('matematika')
              ? Icons.calculate_outlined
              : subLower.contains('fisika')
                  ? Icons.science_outlined
                  : subLower.contains('inggris')
                      ? Icons.language_rounded
                      : subLower.contains('kimia')
                          ? Icons.biotech_outlined
                          : subLower.contains('informatika')
                              ? Icons.terminal_rounded
                              : Icons.menu_book_rounded;

          final Color subjectColor = subLower.contains('matematika')
              ? const Color(0xFF6366F1)
              : subLower.contains('fisika')
                  ? const Color(0xFF0284C7)
                  : subLower.contains('inggris')
                      ? const Color(0xFFD97706)
                      : subLower.contains('kimia')
                          ? const Color(0xFF16A34A)
                          : subLower.contains('informatika')
                              ? AppColors.primary
                              : AppColors.info;

          return Container(
            width: MediaQuery.of(context).size.width * 0.84,
            decoration: BoxDecoration(
              color: isOngoing
                  ? const Color(0xFFF0FDF4)
                  : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isOngoing
                    ? const Color(0xFF16A34A)
                    : isCompleted
                        ? AppColors.borderLight.withValues(alpha: 0.6)
                        : AppColors.borderLight,
                width: isOngoing ? 1.8 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: isOngoing
                      ? const Color(0xFF16A34A).withValues(alpha: 0.12)
                      : const Color(0xFF0F172A).withValues(alpha: 0.03),
                  blurRadius: isOngoing ? 14 : 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                onTap: () => setState(() => _currentIndex = 2),
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: isOngoing
                                  ? const Color(0xFF16A34A).withValues(alpha: 0.15)
                                  : subjectColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              isOngoing
                                  ? Icons.radio_button_checked_rounded
                                  : subjectIcon,
                              size: 16,
                              color: isOngoing
                                  ? const Color(0xFF16A34A)
                                  : subjectColor,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            item.subjectCode.isNotEmpty
                                ? item.subjectCode
                                : 'KELAS',
                            style: TextStyle(
                              fontFamily: 'Geist',
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: isOngoing
                                  ? const Color(0xFF15803D)
                                  : subjectColor,
                            ),
                          ),
                          const Spacer(),

                          // Status Statement Badge
                          if (isOngoing)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 4,
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
                                  Text(
                                    'AKTIF • Sisa ${item.remainingMinutes}m',
                                    style: const TextStyle(
                                      fontFamily: 'Geist',
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF15803D),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else if (isCompleted)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3.5,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.backgroundLight,
                                borderRadius: BorderRadius.circular(8),
                                border:
                                    Border.all(color: AppColors.borderLight),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.check_circle_outline_rounded,
                                    size: 12,
                                    color: AppColors.textMutedLight,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Selesai',
                                    style: TextStyle(
                                      fontFamily: 'Geist',
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textMutedLight,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else if (isUpcoming && item.minutesUntilStart <= 45)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3.5,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF3C7),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xFFFDE68A),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.alarm_rounded,
                                    size: 12,
                                    color: Color(0xFFD97706),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Mulai dlm ${item.minutesUntilStart}m',
                                    style: const TextStyle(
                                      fontFamily: 'Geist',
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFFB45309),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3.5,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.backgroundLight,
                                borderRadius: BorderRadius.circular(8),
                                border:
                                    Border.all(color: AppColors.borderLight),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.schedule_rounded,
                                    size: 12,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${item.startTime} - ${item.endTime}',
                                    style: const TextStyle(
                                      fontFamily: 'Geist',
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimaryLight,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Subject Title
                      Text(
                        item.subjectName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Geist',
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: isOngoing
                              ? const Color(0xFF14532D)
                              : isCompleted
                                  ? AppColors.textSecondaryLight
                                  : AppColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Room Location & Time
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 13,
                            color: isOngoing
                                ? const Color(0xFF16A34A)
                                : AppColors.textMutedLight,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            item.room,
                            style: TextStyle(
                              fontFamily: 'Geist',
                              fontSize: 12,
                              color: isOngoing
                                  ? const Color(0xFF166534)
                                  : AppColors.textSecondaryLight,
                              fontWeight: isOngoing
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                          if (isOngoing ||
                              isCompleted ||
                              (isUpcoming && item.minutesUntilStart <= 45)) ...[
                            const SizedBox(width: 8),
                            Text(
                              '•',
                              style: TextStyle(
                                color: isOngoing
                                    ? const Color(0xFF86EFAC)
                                    : AppColors.textMutedLight,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${item.startTime} - ${item.endTime}',
                              style: TextStyle(
                                fontFamily: 'Geist',
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: isOngoing
                                    ? const Color(0xFF15803D)
                                    : AppColors.textMutedLight,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const Spacer(),
                      Divider(
                        height: 1,
                        color: isOngoing
                            ? const Color(0xFF86EFAC).withValues(alpha: 0.7)
                            : AppColors.borderLight,
                      ),
                      const SizedBox(height: 8),

                      // Teacher row
                      Row(
                        children: [
                          Icon(
                            Icons.person_pin_rounded,
                            size: 14,
                            color: isOngoing
                                ? const Color(0xFF16A34A)
                                : AppColors.primary,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              item.teacherName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'Geist',
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: isOngoing
                                    ? const Color(0xFF166534)
                                    : AppColors.textSecondaryLight,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 16,
                            color: isOngoing
                                ? const Color(0xFF16A34A)
                                : AppColors.textMutedLight,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _dayName(int day) {
    switch (day) {
      case 1:
        return 'Senin';
      case 2:
        return 'Selasa';
      case 3:
        return 'Rabu';
      case 4:
        return 'Kamis';
      case 5:
        return 'Jumat';
      case 6:
        return 'Sabtu';
      case 7:
        return 'Minggu';
      default:
        return '';
    }
  }

  Widget _buildAnnouncementCarousel(
    BuildContext context,
    List<AnnouncementModel> announcements,
  ) {
    return SizedBox(
      height: 178,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: announcements.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final ann = announcements[index];
          final isUrgent = ann.isUrgent;

          Color themeColor = isUrgent
              ? AppColors.danger
              : (ann.title.toLowerCase().contains('ujian') ||
                      ann.title.toLowerCase().contains('pas'))
                  ? const Color(0xFF6366F1)
                  : (ann.title.toLowerCase().contains('rapor') ||
                          ann.title.toLowerCase().contains('rapot'))
                      ? const Color(0xFFD97706)
                      : (ann.title.toLowerCase().contains('libur'))
                          ? const Color(0xFF16A34A)
                          : AppColors.primary;

          String category = isUrgent
              ? 'Penting'
              : (ann.title.toLowerCase().contains('ujian') ||
                      ann.title.toLowerCase().contains('pas'))
                  ? 'Ujian'
                  : (ann.title.toLowerCase().contains('rapor') ||
                          ann.title.toLowerCase().contains('rapot'))
                      ? 'Rapor'
                      : (ann.title.toLowerCase().contains('libur'))
                          ? 'Libur'
                          : 'Akademik';

          return Container(
            width: MediaQuery.of(context).size.width * 0.82,
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isUrgent
                    ? themeColor.withValues(alpha: 0.35)
                    : AppColors.borderLight,
                width: isUrgent ? 1.5 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                onTap: () => _showAnnouncementDetail(context, ann),
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header tag & date
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: themeColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isUrgent) ...[
                                  Icon(
                                    Icons.error_outline_rounded,
                                    size: 11,
                                    color: themeColor,
                                  ),
                                  const SizedBox(width: 4),
                                ],
                                Text(
                                  category.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                    color: themeColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              const Icon(
                                Icons.access_time_rounded,
                                size: 12,
                                color: AppColors.textMutedLight,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _formatRelativeTime(ann.publishedAt),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textMutedLight,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Title
                      Text(
                        ann.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          height: 1.25,
                          color: AppColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Snippet
                      Expanded(
                        child: Text(
                          ann.content,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11.5,
                            height: 1.4,
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                      ),

                      // Footer
                      const Divider(height: 14, color: AppColors.borderLight),
                      Row(
                        children: [
                          Icon(
                            Icons.person_pin_rounded,
                            size: 14,
                            color: themeColor,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              ann.authorName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textMutedLight,
                              ),
                            ),
                          ),
                          Text(
                            'Baca',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: themeColor,
                            ),
                          ),
                          const SizedBox(width: 2),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 13,
                            color: themeColor,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showAnnouncementDetail(BuildContext context, AnnouncementModel ann) {
    final isUrgent = ann.isUrgent;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.borderLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  if (isUrgent)
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.dangerLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'PENTING',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppColors.danger,
                        ),
                      ),
                    ),
                  Text(
                    DateFormat('EEEE, d MMMM yyyy • HH:mm', 'id_ID')
                        .format(ann.publishedAt),
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppColors.textMutedLight,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                ann.title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  height: 1.3,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.account_circle_outlined,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    ann.authorName,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const Divider(height: 24, color: AppColors.borderLight),
              Text(
                ann.content,
                style: const TextStyle(
                  fontSize: 13.5,
                  height: 1.6,
                  color: AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Tutup',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatRelativeTime(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m lalu';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}j lalu';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}h lalu';
    } else {
      return DateFormat('d MMM', 'id_ID').format(dateTime);
    }
  }

  Widget _buildEmptyStateCard({
    required IconData icon,
    required String message,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: AppColors.textMutedLight),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(
              fontSize: 12.5,
              color: AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}
