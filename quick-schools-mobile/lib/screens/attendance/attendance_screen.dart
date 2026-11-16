import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/attendance_model.dart';
import '../../providers/attendance_provider.dart';
import '../../widgets/attendance_detail_sheet.dart';
import '../../widgets/status_badge.dart';
import 'face_attendance_screen.dart';
import 'leave_request_screen.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  String? _selectedCategory; // 'HADIR', 'TERLAMBAT', 'IZIN', 'SAKIT', 'ALPA'

  Future<void> _openFaceScanner() async {
    final attendance = Provider.of<AttendanceProvider>(context, listen: false);
    if (attendance.hasCheckedInToday) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Anda sudah melakukan absensi hari ini. Absensi hanya 1x per hari.',
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => const FaceAttendanceScreen(),
      ),
    );
  }

  void _toggleCategory(String cat) {
    setState(() {
      _selectedCategory = _selectedCategory == cat ? null : cat;
    });
  }

  String _filterCategoryLabel(String cat) {
    switch (cat) {
      case 'HADIR':
        return 'Hadir';
      case 'TERLAMBAT':
        return 'Terlambat';
      case 'IZIN':
        return 'Izin';
      case 'SAKIT':
        return 'Sakit';
      case 'ALPA':
        return 'Alpa';
      default:
        return cat;
    }
  }

  @override
  Widget build(BuildContext context) {
    final attendance = Provider.of<AttendanceProvider>(context);
    final todayRecord = attendance.todayAttendance;

    final filteredList = attendance.attendances.where((a) {
      if (_selectedCategory == null) return true;
      final isSick = (a.notes ?? '').toLowerCase().contains('sakit') ||
          (a.notes ?? '').toLowerCase().contains('dokter');
      switch (_selectedCategory) {
        case 'HADIR':
          return a.status == AttendanceStatus.present;
        case 'TERLAMBAT':
          return a.status == AttendanceStatus.late;
        case 'IZIN':
          return a.status == AttendanceStatus.excused && !isSick;
        case 'SAKIT':
          return a.status == AttendanceStatus.excused && isSick;
        case 'ALPA':
          return a.status == AttendanceStatus.absent;
        default:
          return true;
      }
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => attendance.fetchAttendance(),
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Screen Title Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Absensi Siswa',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.4,
                            color: AppColors.textPrimary(context),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          DateFormat('EEEE, d MMMM yyyy', 'id_ID')
                              .format(DateTime.now()),
                          style: TextStyle(
                            fontSize: 12.5,
                            color: AppColors.textSecondary(context),
                          ),
                        ),
                      ],
                    ),
                    Material(
                      color: AppColors.surface(context),
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: () => attendance.fetchAttendance(),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border:
                                Border.all(color: AppColors.border(context)),
                          ),
                          child: Icon(
                            Icons.refresh_rounded,
                            size: 20,
                            color: AppColors.textPrimary(context),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // Face Recognition Check-In Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        AppColors.primaryDark,
                        AppColors.primary,
                        AppColors.primaryLight,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.28),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.28),
                              ),
                            ),
                            child: const Icon(
                              Icons.face_retouching_natural_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    todayRecord != null
                                        ? 'STATUS HARI INI: ${todayRecord.status.label.toUpperCase()}'
                                        : 'BELUM ABSEN HARI INI',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.6,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                const Text(
                                  'Absensi Face Recognition',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  todayRecord?.checkInTime != null
                                      ? 'Tercatat pukul ${todayRecord!.checkInTime}'
                                      : 'Absen harian 1x per hari via kamera depan',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.85),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      if (todayRecord != null)
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () => showAttendanceDetailModal(
                              context,
                              todayRecord,
                            ),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                vertical: 13,
                                horizontal: 14,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.16),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.28),
                                ),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.check_circle_rounded,
                                    color: Colors.white,
                                    size: 19,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Absensi Selesai • Lihat Rincian',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13.5,
                                    ),
                                  ),
                                  SizedBox(width: 6),
                                  Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    color: Colors.white,
                                    size: 13,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      else
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _openFaceScanner,
                                icon: const Icon(
                                  Icons.center_focus_strong_rounded,
                                  size: 20,
                                ),
                                label: const Text(
                                  'Scan Wajah Sekarang',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13.5,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: AppColors.primary,
                                  elevation: 0,
                                  minimumSize: const Size(0, 48),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const LeaveRequestScreen(),
                                  ),
                                );
                              },
                              icon:
                                  const Icon(Icons.edit_note_rounded, size: 20),
                              label: const Text(
                                'Izin / Sakit',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Colors.white.withValues(alpha: 0.18),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                minimumSize: const Size(0, 48),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  side: BorderSide(
                                    color: Colors.white.withValues(alpha: 0.3),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Presensi Kehadiran Siswa Card
                _buildAttendanceDetailCard(context, attendance, todayRecord),

                const SizedBox(height: 22),

                // History Section Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedCategory == null
                          ? 'Riwayat Absensi'
                          : 'Filter: ${_filterCategoryLabel(_selectedCategory!)}',
                      style: TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                    if (_selectedCategory != null)
                      TextButton(
                        onPressed: () => setState(() => _selectedCategory = null),
                        child: const Text(
                          'Tampilkan Semua',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),

                if (filteredList.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    decoration: BoxDecoration(
                      color: AppColors.surface(context),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.border(context)),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.event_note_outlined,
                          size: 36,
                          color: AppColors.textMuted(context),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tidak ada riwayat absensi pada kategori ini.',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary(context),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ...filteredList.map((item) => _buildAttendanceRow(item)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAttendanceDetailCard(
    BuildContext context,
    AttendanceProvider attendance,
    AttendanceModel? todayRecord,
  ) {
    final isDark = AppColors.isDark(context);
    final today = DateTime.now();
    final dateStr = DateFormat('d MMMM yyyy', 'id_ID').format(today);

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
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                if (todayRecord != null) {
                  showAttendanceDetailModal(context, todayRecord);
                } else {
                  _openFaceScanner();
                }
              },
              child: Container(
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
                          if (todayRecord != null) ...[
                            const SizedBox(width: 4),
                            Icon(
                              Icons.chevron_right_rounded,
                              size: 16,
                              color: statusFg,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 14),

          // 5 Metric Boxes in a Row: Hadir, Terlambat, Izin, Sakit, Alpa (Interactive filter)
          Row(
            children: [
              Expanded(
                child: _buildAttendanceMetricBox(
                  count: attendance.presentCount,
                  label: 'Hadir',
                  category: 'HADIR',
                  numberColor: const Color(0xFF6366F1),
                  bgColor: isDark
                      ? const Color(0xFF1E1B4B).withValues(alpha: 0.5)
                      : const Color(0xFFFAF9FF),
                  borderColor: isDark
                      ? const Color(0xFF3730A3).withValues(alpha: 0.5)
                      : const Color(0xFFEDE9FE),
                  isDark: isDark,
                  isSelected: _selectedCategory == 'HADIR',
                  onTap: () => _toggleCategory('HADIR'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildAttendanceMetricBox(
                  count: attendance.lateCount,
                  label: 'Terlambat',
                  category: 'TERLAMBAT',
                  numberColor: const Color(0xFF3B82F6),
                  bgColor: isDark
                      ? const Color(0xFF172554).withValues(alpha: 0.5)
                      : const Color(0xFFF5F8FF),
                  borderColor: isDark
                      ? const Color(0xFF1E40AF).withValues(alpha: 0.5)
                      : const Color(0xFFDBEAFE),
                  isDark: isDark,
                  isSelected: _selectedCategory == 'TERLAMBAT',
                  onTap: () => _toggleCategory('TERLAMBAT'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildAttendanceMetricBox(
                  count: attendance.permissionCount,
                  label: 'Izin',
                  category: 'IZIN',
                  numberColor: const Color(0xFFD97706),
                  bgColor: isDark
                      ? const Color(0xFF451A03).withValues(alpha: 0.4)
                      : const Color(0xFFFFFDF5),
                  borderColor: isDark
                      ? const Color(0xFF78350F).withValues(alpha: 0.4)
                      : const Color(0xFFFEF08A),
                  isDark: isDark,
                  isSelected: _selectedCategory == 'IZIN',
                  onTap: () => _toggleCategory('IZIN'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildAttendanceMetricBox(
                  count: attendance.sickCount,
                  label: 'Sakit',
                  category: 'SAKIT',
                  numberColor: const Color(0xFF0284C7),
                  bgColor: isDark
                      ? const Color(0xFF082F49).withValues(alpha: 0.5)
                      : const Color(0xFFF0F9FF),
                  borderColor: isDark
                      ? const Color(0xFF075985).withValues(alpha: 0.5)
                      : const Color(0xFFBAE6FD),
                  isDark: isDark,
                  isSelected: _selectedCategory == 'SAKIT',
                  onTap: () => _toggleCategory('SAKIT'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildAttendanceMetricBox(
                  count: attendance.absentCount,
                  label: 'Alpa',
                  category: 'ALPA',
                  numberColor: const Color(0xFFE11D48),
                  bgColor: isDark
                      ? const Color(0xFF4C0519).withValues(alpha: 0.4)
                      : const Color(0xFFFFF1F2),
                  borderColor: isDark
                      ? const Color(0xFF9F1239).withValues(alpha: 0.4)
                      : const Color(0xFFFECDD3),
                  isDark: isDark,
                  isSelected: _selectedCategory == 'ALPA',
                  onTap: () => _toggleCategory('ALPA'),
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
          isDark ? const Color(0xFF381E04) : const Color(0xFFFFFBEB),
          isDark ? const Color(0xFF854D0E) : const Color(0xFFFDE68A),
          const Color(0xFFB45309),
        );
      case AttendanceStatus.excused:
        final isSick =
            (todayRecord.notes ?? '').toLowerCase().contains('sakit');
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
          Icons.assignment_turned_in_outlined,
          isDark ? const Color(0xFF172554) : const Color(0xFFEFF6FF),
          isDark ? const Color(0xFF1E40AF) : const Color(0xFFBFDBFE),
          const Color(0xFF2563EB),
        );
      case AttendanceStatus.absent:
        return (
          'Alpa (- WIB)',
          Icons.cancel_outlined,
          isDark ? const Color(0xFF3F0B18) : const Color(0xFFFFF1F2),
          isDark ? const Color(0xFF9F1239) : const Color(0xFFFDA4AF),
          const Color(0xFFBE123C),
        );
    }
  }

  Widget _buildAttendanceMetricBox({
    required int count,
    required String label,
    required String category,
    required Color numberColor,
    required Color bgColor,
    required Color borderColor,
    required bool isDark,
    required bool isSelected,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 2),
          decoration: BoxDecoration(
            color: isSelected
                ? numberColor.withValues(alpha: isDark ? 0.25 : 0.15)
                : bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? numberColor : borderColor,
              width: isSelected ? 2.0 : 1.2,
            ),
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
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected
                        ? numberColor
                        : (isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF475569)),
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

  Widget _buildAttendanceRow(AttendanceModel item) {
    final isFaceVerified =
        (item.notes ?? '').toLowerCase().contains('face');

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => showAttendanceDetailModal(context, item),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 50,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.bg(context),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border(context)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        DateFormat('dd').format(item.date),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary(context),
                        ),
                      ),
                      Text(
                        DateFormat('MMM', 'id_ID').format(item.date),
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMuted(context),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              item.studentName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary(context),
                              ),
                            ),
                          ),
                          if (isFaceVerified) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primarySubtle,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.face_rounded,
                                    size: 11,
                                    color: AppColors.primary,
                                  ),
                                  SizedBox(width: 3),
                                  Text(
                                    'Face ID',
                                    style: TextStyle(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.notes ?? 'Presensi terverifikasi',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary(context),
                        ),
                      ),
                      if (item.checkInTime != null ||
                          (item.latitude != null && item.longitude != null)) ...[
                        const SizedBox(height: 5),
                        Wrap(
                          spacing: 10,
                          runSpacing: 4,
                          children: [
                            if (item.checkInTime != null)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.schedule_rounded,
                                    size: 12,
                                    color: AppColors.textMuted(context),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    item.checkInTime!,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textMuted(context),
                                    ),
                                  ),
                                ],
                              ),
                            if (item.latitude != null && item.longitude != null)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.location_on_rounded,
                                    size: 12,
                                    color: AppColors.success,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    '${item.latitude!.toStringAsFixed(4)}, ${item.longitude!.toStringAsFixed(4)}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textSecondary(context),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                StatusBadge(status: item.status),
                const SizedBox(width: 4),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 19,
                  color: AppColors.textMuted(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
