import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/leave_request_model.dart';
import '../../providers/auth_provider.dart';

class LeaveRequestScreen extends StatefulWidget {
  const LeaveRequestScreen({super.key});

  @override
  State<LeaveRequestScreen> createState() => _LeaveRequestScreenState();
}

class _LeaveRequestScreenState extends State<LeaveRequestScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Form State
  LeaveType _selectedType = LeaveType.sick;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();
  final TextEditingController _reasonController = TextEditingController();
  bool _hasAttachment = false;
  bool _isSubmitting = false;

  final List<LeaveRequestModel> _requests = [
    LeaveRequestModel(
      id: 'lvr-1',
      studentId: 's-202',
      studentName: 'Rizky Pratama',
      className: 'XII-IPA 1',
      type: LeaveType.sick,
      startDate: DateTime.now().subtract(const Duration(days: 12)),
      endDate: DateTime.now().subtract(const Duration(days: 11)),
      reason:
          'Demam tinggi dan flu berat, disarankan istirahat oleh dr. Hendri Sp.A.',
      attachmentUrl: 'surat_keterangan_dokter_klinik_sehat.jpg',
      status: LeaveStatus.approved,
      approvedBy: 'Budi Santoso, M.Pd. (Wali Kelas)',
      teacherNotes:
          'Pengajuan disetujui. Cepat pulih Rizky, materi ulangan bisa disusul pekan depan.',
      createdAt: DateTime.now().subtract(const Duration(days: 12)),
    ),
    LeaveRequestModel(
      id: 'lvr-2',
      studentId: 's-202',
      studentName: 'Rizky Pratama',
      className: 'XII-IPA 1',
      type: LeaveType.schoolActivity,
      startDate: DateTime.now().subtract(const Duration(days: 25)),
      endDate: DateTime.now().subtract(const Duration(days: 25)),
      reason:
          'Mewakili sekolah dalam Olimpiade Sains Nasional (OSN) Bidang Informatika Tingkat Kota.',
      attachmentUrl: 'surat_tugas_kepsek_osn.pdf',
      status: LeaveStatus.approved,
      approvedBy: 'Wakasek Kesiswaan',
      teacherNotes:
          'Dispensasi resmi diberikan. Selamat bertanding dan harumkan nama sekolah!',
      createdAt: DateTime.now().subtract(const Duration(days: 26)),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime.now().subtract(const Duration(days: 7)),
      lastDate: DateTime.now().add(const Duration(days: 60)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimaryLight,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate;
          }
        } else {
          _endDate = picked;
          if (_startDate.isAfter(_endDate)) {
            _startDate = _endDate;
          }
        }
      });
    }
  }

  void _handleSubmit() {
    if (_reasonController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Silakan masukkan alasan izin/sakit.'),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    Future.delayed(const Duration(milliseconds: 600), () {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final user = auth.currentUser;

      final newReq = LeaveRequestModel(
        id: 'lvr-${DateTime.now().millisecondsSinceEpoch}',
        studentId: user?.studentId ?? 's-202',
        studentName: user?.fullName ?? 'Rizky Pratama',
        className: user?.className ?? 'XII-IPA 1',
        type: _selectedType,
        startDate: _startDate,
        endDate: _endDate,
        reason: _reasonController.text.trim(),
        attachmentUrl: _hasAttachment ? 'lampiran_surat_${_startDate.day}.jpg' : null,
        status: LeaveStatus.pending,
        createdAt: DateTime.now(),
      );

      setState(() {
        _requests.insert(0, newReq);
        _isSubmitting = false;
        _reasonController.clear();
        _hasAttachment = false;
      });

      _tabController.animateTo(1);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Pengajuan izin/sakit berhasil dikirim ke Wali Kelas!',
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceLight,
        elevation: 0,
        title: const Text(
          'Izin & Sakit Siswa',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimaryLight,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textMutedLight,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          tabs: const [
            Tab(text: 'Ajukan Izin Baru'),
            Tab(text: 'Riwayat Pengajuan'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFormTab(),
          _buildHistoryTab(),
        ],
      ),
    );
  }

  Widget _buildFormTab() {
    final daysCount = _endDate.difference(_startDate).inDays + 1;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner info
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primarySubtle,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline_rounded,
                    color: AppColors.primary, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Pengajuan izin akan diteruskan otomatis ke Wali Kelas & Guru BK untuk verifikasi kehadiran resmi.',
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.4,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Tipe Izin
          const Text(
            'Kategori Izin',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: LeaveType.values.map((type) {
              final isSelected = _selectedType == type;
              return ChoiceChip(
                selected: isSelected,
                label: Text(type.label),
                labelStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? Colors.white : AppColors.textSecondaryLight,
                ),
                backgroundColor: AppColors.surfaceLight,
                selectedColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.borderLight,
                  ),
                ),
                onSelected: (_) => setState(() => _selectedType = type),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Rentang Tanggal
          const Text(
            'Rentang Tanggal',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _datePickerCard(
                  title: 'Dari Tanggal',
                  date: _startDate,
                  onTap: () => _pickDate(isStart: true),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _datePickerCard(
                  title: 'Sampai Tanggal',
                  date: _endDate,
                  onTap: () => _pickDate(isStart: false),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Durasi: $daysCount Hari kerja',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 20),

          // Alasan
          const Text(
            'Alasan / Keterangan Lengkap',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _reasonController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText:
                  'Tuliskan alasan tidak hadir secara jelas (misal: Sakit demam berdarah dan harus opname, dsb)...',
              hintStyle: const TextStyle(
                fontSize: 12.5,
                color: AppColors.textMutedLight,
              ),
              filled: true,
              fillColor: AppColors.surfaceLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.borderLight),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.borderLight),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Lampiran Bukti
          const Text(
            'Lampiran Surat Dokter / Bukti (Opsional)',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () {
              setState(() => _hasAttachment = !_hasAttachment);
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _hasAttachment
                    ? AppColors.successLight
                    : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _hasAttachment
                      ? AppColors.success
                      : AppColors.borderLight,
                  style: BorderStyle.solid,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _hasAttachment
                          ? AppColors.success.withValues(alpha: 0.15)
                          : AppColors.backgroundLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _hasAttachment
                          ? Icons.attachment_rounded
                          : Icons.camera_alt_outlined,
                      color: _hasAttachment
                          ? AppColors.success
                          : AppColors.textMutedLight,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _hasAttachment
                              ? 'Surat_Keterangan_Dokter.jpg'
                              : 'Ambil Foto / Unggah Surat',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _hasAttachment
                                ? AppColors.success
                                : AppColors.textPrimaryLight,
                          ),
                        ),
                        Text(
                          _hasAttachment
                              ? '1.2 MB • Siap dilampirkan (Klik untuk lepas)'
                              : 'Format JPG, PNG, atau PDF (Maks. 5 MB)',
                          style: TextStyle(
                            fontSize: 11,
                            color: _hasAttachment
                                ? AppColors.success
                                : AppColors.textMutedLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _hasAttachment
                        ? Icons.check_circle_rounded
                        : Icons.add_photo_alternate_outlined,
                    color: _hasAttachment
                        ? AppColors.success
                        : AppColors.primary,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),

          // Submit button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Kirim Pengajuan Izin',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _datePickerCard({
    required String title,
    required DateTime date,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textMutedLight,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(
                  Icons.calendar_month_rounded,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    DateFormat('d MMM yyyy', 'id_ID').format(date),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTab() {
    if (_requests.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.assignment_outlined,
                size: 52,
                color: AppColors.textMutedLight,
              ),
              SizedBox(height: 12),
              Text(
                'Belum ada riwayat pengajuan izin.',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      itemCount: _requests.length,
      itemBuilder: (context, index) {
        final req = _requests[index];
        return _buildRequestCard(req);
      },
    );
  }

  Widget _buildRequestCard(LeaveRequestModel req) {
    Color statusColor;
    Color statusBg;
    switch (req.status) {
      case LeaveStatus.approved:
        statusColor = AppColors.success;
        statusBg = AppColors.successLight;
        break;
      case LeaveStatus.rejected:
        statusColor = AppColors.danger;
        statusBg = AppColors.dangerLight;
        break;
      case LeaveStatus.pending:
        statusColor = AppColors.warning;
        statusBg = AppColors.warningLight;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primarySubtle,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  req.type.label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  req.status.label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.date_range_rounded,
                size: 15,
                color: AppColors.primary,
              ),
              const SizedBox(width: 6),
              Text(
                '${DateFormat("d MMM yyyy", "id_ID").format(req.startDate)} - ${DateFormat("d MMM yyyy", "id_ID").format(req.endDate)} (${req.durationDays} Hari)',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            req.reason,
            style: const TextStyle(
              fontSize: 12.5,
              height: 1.4,
              color: AppColors.textSecondaryLight,
            ),
          ),
          if (req.attachmentUrl != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.attachment_rounded,
                  size: 14,
                  color: AppColors.textMutedLight,
                ),
                const SizedBox(width: 4),
                Text(
                  req.attachmentUrl!,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontStyle: FontStyle.italic,
                    color: AppColors.textMutedLight,
                  ),
                ),
              ],
            ),
          ],
          if (req.teacherNotes != null) ...[
            const Divider(height: 20, color: AppColors.borderLight),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.verified_user_outlined,
                        size: 14,
                        color: AppColors.success,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        req.approvedBy ?? 'Wali Kelas',
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimaryLight,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    req.teacherNotes!,
                    style: const TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
