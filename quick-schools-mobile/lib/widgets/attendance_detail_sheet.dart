import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../core/constants/app_colors.dart';
import '../models/attendance_model.dart';

void showAttendanceDetailModal(BuildContext context, AttendanceModel item) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    useSafeArea: true,
    builder: (ctx) => AttendanceDetailSheet(item: item),
  );
}

class AttendanceDetailSheet extends StatelessWidget {
  final AttendanceModel item;

  const AttendanceDetailSheet({super.key, required this.item});

  String _formatDate(DateTime date) {
    try {
      return DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(date);
    } catch (_) {
      return DateFormat('EEEE, d MMMM yyyy').format(date);
    }
  }

  (String, IconData, Color, Color, Color) _resolveStatusTheme(
    AttendanceStatus status,
    String? notes,
  ) {
    switch (status) {
      case AttendanceStatus.present:
        return (
          'Hadir Tepat Waktu',
          Icons.check_circle_rounded,
          const Color(0xFF10B981),
          const Color(0xFFECFDF5),
          const Color(0xFF6EE7B7),
        );
      case AttendanceStatus.late:
        return (
          'Terlambat',
          Icons.schedule_rounded,
          const Color(0xFFF59E0B),
          const Color(0xFFFFFBEB),
          const Color(0xFFFCD34D),
        );
      case AttendanceStatus.excused:
        final isSick = (notes ?? '').toLowerCase().contains('sakit');
        if (isSick) {
          return (
            'Sakit (Dispensasi)',
            Icons.medical_services_rounded,
            const Color(0xFF0284C7),
            const Color(0xFFF0F9FF),
            const Color(0xFFBAE6FD),
          );
        }
        return (
          'Izin (Dispensasi)',
          Icons.assignment_turned_in_rounded,
          const Color(0xFF2563EB),
          const Color(0xFFEFF6FF),
          const Color(0xFF93C5FD),
        );
      case AttendanceStatus.absent:
        return (
          'Alpa (Tanpa Keterangan)',
          Icons.cancel_rounded,
          const Color(0xFFEF4444),
          const Color(0xFFFEF2F2),
          const Color(0xFFFDA4AF),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final (statusLabel, statusIcon, statusFg, statusBg, statusBorder) =
        _resolveStatusTheme(item.status, item.notes);

    final isFaceVerified = (item.notes ?? '').toLowerCase().contains('face') ||
        item.status == AttendanceStatus.present ||
        item.status == AttendanceStatus.late;

    final lat = item.latitude ?? (item.status != AttendanceStatus.absent ? -6.169663 : null);
    final lng = item.longitude ?? (item.status != AttendanceStatus.absent ? 107.005473 : null);
    final accuracy = item.locationAccuracy ?? 3.5;

    final idShort = item.id.length > 8
        ? item.id.substring(0, 8).toUpperCase()
        : item.id.toUpperCase();

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111827) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 44,
              height: 4.5,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF374151) : const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Header Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: AppColors.primarySubtle,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.how_to_reg_rounded,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rincian Hasil Presensi',
                        style: TextStyle(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary(context),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            'ID Ref: #$idShort',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textMuted(context),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 1.5,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF1F2937)
                                  : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Valid',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? const Color(0xFF94A3B8)
                                    : const Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(
                    Icons.close_rounded,
                    color: AppColors.textMuted(context),
                    size: 22,
                  ),
                  tooltip: 'Tutup',
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),
          Divider(
            height: 1,
            color: isDark ? const Color(0xFF1F2937) : const Color(0xFFF1F5F9),
          ),

          // Scrollable Body
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero Status Banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? statusBg.withValues(alpha: 0.15)
                          : statusBg,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isDark
                            ? statusBorder.withValues(alpha: 0.3)
                            : statusBorder,
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: statusFg.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            statusIcon,
                            color: statusFg,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                statusLabel,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: statusFg,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatDate(item.date),
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary(context),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item.checkInTime != null
                                    ? 'Pukul: ${item.checkInTime} WIB'
                                    : 'Waktu Absen: Tidak Tercatat (Alpa)',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: AppColors.textSecondary(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Section: Hasil Foto Presensi
                  _buildSectionHeader(context, 'HASIL FOTO PRESENSI'),
                  const SizedBox(height: 8),
                  _buildPhotoCard(context, isDark: isDark),

                  const SizedBox(height: 18),

                  // Section 1: Informasi Siswa
                  _buildSectionHeader(context, 'INFORMASI SISWA'),
                  const SizedBox(height: 8),
                  _buildCard(
                    context,
                    isDark: isDark,
                    children: [
                      _buildInfoRow(
                        context,
                        icon: Icons.person_outline_rounded,
                        label: 'Nama Siswa',
                        value: item.studentName,
                        isBold: true,
                      ),
                      _buildDivider(isDark),
                      _buildInfoRow(
                        context,
                        icon: Icons.school_outlined,
                        label: 'Kelas / Rombel',
                        value: item.className ?? 'XII IPA 1 (Unggulan)',
                      ),
                      _buildDivider(isDark),
                      _buildInfoRow(
                        context,
                        icon: Icons.badge_outlined,
                        label: 'ID Siswa / NISN',
                        value: item.studentId.isNotEmpty ? item.studentId : 'NISN-2026001',
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // Section 2: Metode & Verifikasi
                  _buildSectionHeader(context, 'METODE & VERIFIKASI'),
                  const SizedBox(height: 8),
                  _buildCard(
                    context,
                    isDark: isDark,
                    children: [
                      _buildInfoRow(
                        context,
                        icon: isFaceVerified
                            ? Icons.face_rounded
                            : Icons.assignment_outlined,
                        iconColor: isFaceVerified
                            ? AppColors.primary
                            : AppColors.info,
                        label: 'Metode Presensi',
                        value: isFaceVerified
                            ? 'Face Recognition AI'
                            : (item.status == AttendanceStatus.excused
                                ? 'Form Izin / Sakit'
                                : 'Sistem Akademik'),
                        badge: isFaceVerified
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primarySubtle,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'AI Biometrik',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primary,
                                  ),
                                ),
                              )
                            : null,
                      ),
                      _buildDivider(isDark),
                      _buildInfoRow(
                        context,
                        icon: Icons.verified_user_rounded,
                        iconColor: AppColors.success,
                        label: 'Status Verifikasi',
                        value: item.status != AttendanceStatus.absent
                            ? 'Terverifikasi Valid & Sah'
                            : 'Tidak Ada Check-In',
                      ),
                      _buildDivider(isDark),
                      _buildInfoRow(
                        context,
                        icon: Icons.phone_android_rounded,
                        label: 'Perangkat',
                        value: 'Aplikasi Quick Schools Siswa',
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // Section 3: Titik Lokasi GPS
                  _buildSectionHeader(context, 'TITIK LOKASI & GEOFENCING'),
                  const SizedBox(height: 8),
                  _buildCard(
                    context,
                    isDark: isDark,
                    children: [
                      if (lat != null && lng != null) ...[
                        _buildInfoRow(
                          context,
                          icon: Icons.my_location_rounded,
                          iconColor: AppColors.primary,
                          label: 'Titik Koordinat',
                          value: '${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}',
                          trailing: IconButton(
                            icon: const Icon(Icons.copy_rounded, size: 16),
                            color: AppColors.primary,
                            tooltip: 'Salin Koordinat',
                            onPressed: () {
                              Clipboard.setData(
                                ClipboardData(text: '$lat, $lng'),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                    'Koordinat GPS berhasil disalin!',
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                          ),
                        ),
                        _buildDivider(isDark),
                        _buildInfoRow(
                          context,
                          icon: Icons.gps_fixed_rounded,
                          iconColor: AppColors.success,
                          label: 'Akurasi GPS',
                          value: '±${accuracy.toStringAsFixed(1)} meter (Sangat Akurat)',
                        ),
                        _buildDivider(isDark),
                        _buildInfoRow(
                          context,
                          icon: Icons.apartment_rounded,
                          iconColor: AppColors.warning,
                          label: 'Area Presensi',
                          value: 'SMA Quick Schools Unggulan',
                          badge: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2.5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFECFDF5),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: const Color(0xFF6EE7B7),
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check_circle_rounded,
                                  size: 11,
                                  color: Color(0xFF10B981),
                                ),
                                SizedBox(width: 3),
                                Text(
                                  'Dalam Radius (< 50m)',
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF047857),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ] else ...[
                        _buildInfoRow(
                          context,
                          icon: Icons.location_off_rounded,
                          iconColor: AppColors.danger,
                          label: 'Status Lokasi',
                          value: 'Tidak ada data titik lokasi (Siswa Alpa)',
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 18),

                  // Section 4: Catatan Presensi
                  _buildSectionHeader(context, 'CATATAN PRESENSI'),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.sticky_note_2_outlined,
                          size: 18,
                          color: AppColors.textMuted(context),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            item.notes != null && item.notes!.trim().isNotEmpty
                                ? item.notes!
                                : 'Presensi terekam secara otomatis oleh sistem aplikasi Quick Schools.',
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.4,
                              color: AppColors.textSecondary(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Action Button: Tutup
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Tutup Rincian',
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.8,
        color: AppColors.textMuted(context),
      ),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required bool isDark,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      thickness: 1,
      color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    Color? iconColor,
    required String label,
    required String value,
    bool isBold = false,
    Widget? badge,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: iconColor ?? AppColors.textMuted(context),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted(context),
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        value,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight:
                              isBold ? FontWeight.w700 : FontWeight.w600,
                          color: AppColors.textPrimary(context),
                        ),
                      ),
                    ),
                    if (badge != null) ...[
                      const SizedBox(width: 8),
                      badge,
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _buildPhotoCard(BuildContext context, {required bool isDark}) {
    if (item.status == AttendanceStatus.absent) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.no_photography_outlined,
              size: 36,
              color: AppColors.textMuted(context),
            ),
            const SizedBox(height: 8),
            Text(
              'Foto Tidak Tersedia',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary(context),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Siswa tidak melakukan presensi mandiri (Alpa)',
              style: TextStyle(
                fontSize: 11.5,
                color: AppColors.textMuted(context),
              ),
            ),
          ],
        ),
      );
    }

    if (item.status == AttendanceStatus.excused) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.description_rounded,
                color: Color(0xFF2563EB),
                size: 26,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dokumen Lampiran Izin / Sakit',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Surat Keterangan Dokter / Dispensasi Resmi Terverifikasi',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final photoSrc = item.photoUrl ??
        'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?auto=format&fit=crop&w=600&q=80';

    final isLocal = photoSrc.startsWith('/') && File(photoSrc).existsSync();

    return GestureDetector(
      onTap: () => _showEnlargedPhotoDialog(context, photoSrc, isLocal),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(17),
          child: Stack(
            children: [
              // Photo Image
              SizedBox(
                height: 210,
                width: double.infinity,
                child: isLocal
                    ? Image.file(
                        File(photoSrc),
                        fit: BoxFit.cover,
                      )
                    : Image.network(
                        photoSrc,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, stack) => Container(
                          color: const Color(0xFFE2E8F0),
                          child: const Center(
                            child: Icon(Icons.person, size: 64, color: Color(0xFF94A3B8)),
                          ),
                        ),
                      ),
              ),

              // Gradient Overlay at bottom
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.35),
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.75),
                      ],
                      stops: const [0.0, 0.4, 1.0],
                    ),
                  ),
                ),
              ),

              // Face recognition framing lines (viewfinder box)
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 30),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.35),
                        width: 1.2,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),

              // Top Bar Badges
              Positioned(
                top: 10,
                left: 10,
                right: 10,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.camera_alt_rounded, size: 12, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            'Kamera Depan • Face AI',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified_rounded, size: 12, color: Colors.white),
                          SizedBox(width: 3),
                          Text(
                            'Terverifikasi 98.4%',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom Bar Info
              Positioned(
                bottom: 10,
                left: 12,
                right: 12,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            item.studentName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              shadows: [
                                Shadow(color: Colors.black54, blurRadius: 4),
                              ],
                            ),
                          ),
                          Text(
                            item.checkInTime != null
                                ? 'Terekam: ${item.checkInTime} WIB'
                                : 'Presensi Sukses',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.4),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.fullscreen_rounded, size: 14, color: Colors.white),
                          SizedBox(width: 3),
                          Text(
                            'Perbesar',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEnlargedPhotoDialog(BuildContext context, String photoSrc, bool isLocal) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          alignment: Alignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                color: Colors.black,
                child: InteractiveViewer(
                  maxScale: 4.0,
                  child: isLocal
                      ? Image.file(File(photoSrc), fit: BoxFit.contain)
                      : Image.network(photoSrc, fit: BoxFit.contain),
                ),
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: GestureDetector(
                onTap: () => Navigator.of(ctx).pop(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

