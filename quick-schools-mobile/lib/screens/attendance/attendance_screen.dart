import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/attendance_provider.dart';
import '../../models/attendance_model.dart';
import '../../models/user_model.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/custom_button.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  bool _isMarking = false;

  Future<void> _handleQuickCheckIn() async {
    setState(() => _isMarking = true);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final attendance = Provider.of<AttendanceProvider>(context, listen: false);

    await attendance.markQuickAttendance(
      studentId: auth.currentUser?.id ?? 's-202',
      status: AttendanceStatus.present,
      notes: 'Presensi Mandiri GPS/Geofence Sekolah (06:58 WIB)',
    );

    setState(() => _isMarking = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Presensi berhasil dicatat! Status: Hadir'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final attendance = Provider.of<AttendanceProvider>(context);
    final isTeacherOrAdmin = auth.currentRole == UserRole.teacher || auth.currentRole == UserRole.admin;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Presensi Sekolah'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => attendance.fetchAttendance(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Check-in Action Box
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primarySubtle,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.touch_app_rounded, color: AppColors.primary, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isTeacherOrAdmin
                                  ? 'Input Presensi Kelas X MIPA 1'
                                  : 'Presensi Masuk Hari Ini',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimaryLight,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(DateTime.now()),
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  CustomButton(
                    text: isTeacherOrAdmin ? 'Rekap Kehadiran Kelas' : 'Tap Presensi Masuk (Hadir)',
                    isLoading: _isMarking,
                    icon: const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
                    onPressed: _handleQuickCheckIn,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Summary Breakdown
            Row(
              children: [
                Expanded(
                  child: _buildMetricMini(
                    label: 'Hadir',
                    count: attendance.presentCount,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMetricMini(
                    label: 'Terlambat',
                    count: attendance.lateCount,
                    color: AppColors.warning,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMetricMini(
                    label: 'Izin/Sakit',
                    count: attendance.excusedCount,
                    color: AppColors.info,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMetricMini(
                    label: 'Alpa',
                    count: attendance.absentCount,
                    color: AppColors.danger,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // History Log
            const Text(
              'Riwayat Kehadiran Terkini',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 12),

            if (attendance.attendances.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('Belum ada data presensi.'),
                ),
              )
            else
              ...attendance.attendances.map((item) => _buildAttendanceRow(item)),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricMini({required String label, required int count, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceRow(AttendanceModel item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Text(
                  DateFormat('dd').format(item.date),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
                Text(
                  DateFormat('MMM').format(item.date),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMutedLight,
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
                Text(
                  item.studentName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  item.notes ?? 'Presensi terverifikasi',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
                if (item.checkInTime != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Waktu: ${item.checkInTime}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMutedLight,
                    ),
                  ),
                ],
              ],
            ),
          ),
          StatusBadge(status: item.status),
        ],
      ),
    );
  }
}
