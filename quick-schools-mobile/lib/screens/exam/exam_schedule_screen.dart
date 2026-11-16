import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/exam_model.dart';
import '../../providers/auth_provider.dart';

class ExamScheduleScreen extends StatefulWidget {
  const ExamScheduleScreen({super.key});

  @override
  State<ExamScheduleScreen> createState() => _ExamScheduleScreenState();
}

class _ExamScheduleScreenState extends State<ExamScheduleScreen> {
  String _selectedFilter = 'ALL';

  final List<ExamModel> _demoExams = [
    ExamModel(
      id: 'ex-1',
      subjectName: 'Matematika Peminatan',
      subjectCode: 'MTH-301',
      examType: 'UTS',
      date: DateTime.now().add(const Duration(days: 1)),
      startTime: '07:30',
      endTime: '09:30',
      room: 'Lab Komputer B',
      seatNumber: 'B-14',
      supervisorName: 'Budi Santoso, M.Pd.',
      instructions:
          '1. Wajib membawa kartu peserta ujian fisik/digital.\n2. Diperkenankan membawa kalkulator saintifik non-programmable.\n3. Masuk ruang ujian 15 menit sebelum waktu dimulai.',
      totalQuestions: 40,
      durationMinutes: 120,
    ),
    ExamModel(
      id: 'ex-2',
      subjectName: 'Fisika Kuantum & Mekanika',
      subjectCode: 'PHY-201',
      examType: 'UTS',
      date: DateTime.now().add(const Duration(days: 2)),
      startTime: '08:00',
      endTime: '09:30',
      room: 'Ruang Ujian 204',
      seatNumber: 'A-08',
      supervisorName: 'Ir. Dewi Sartika, M.T.',
      instructions:
          '1. Kerjakan di lembar jawaban komputer (LJK) yang disediakan.\n2. Gunakan pensil 2B asli.\n3. Dilarang bertukar alat tulis.',
      totalQuestions: 35,
      durationMinutes: 90,
    ),
    ExamModel(
      id: 'ex-3',
      subjectName: 'Bahasa Inggris (TOEFL Prep)',
      subjectCode: 'ENG-102',
      examType: 'UTS',
      date: DateTime.now().add(const Duration(days: 4)),
      startTime: '09:45',
      endTime: '11:15',
      room: 'Lab Bahasa Multimedia',
      seatNumber: 'L-22',
      supervisorName: 'Sarah Jenkins, B.Ed.',
      instructions:
          '1. Membawa earphone jack 3.5mm pribadi untuk sesi listening.\n2. Dilarang membawa kamus atau gawai selain kartu ujian.',
      totalQuestions: 50,
      durationMinutes: 90,
    ),
    ExamModel(
      id: 'ex-4',
      subjectName: 'Kimia Organik & Praktikum',
      subjectCode: 'CHM-201',
      examType: 'UTS',
      date: DateTime.now().add(const Duration(days: 6)),
      startTime: '07:30',
      endTime: '09:00',
      room: 'Lab Kimia Terpadu',
      seatNumber: 'K-05',
      supervisorName: 'Dr. Ahmad Fauzi',
      instructions:
          '1. Wajib mengenakan jas lab putih dan masker.\n2. Patuhi protokol keselamatan bahan kimia laboratorium.',
      totalQuestions: 30,
      durationMinutes: 90,
    ),
    ExamModel(
      id: 'ex-5',
      subjectName: 'Informatika & Pemrograman Flutter',
      subjectCode: 'INF-101',
      examType: 'PRAKTIKUM',
      date: DateTime.now().subtract(const Duration(days: 2)),
      startTime: '10:00',
      endTime: '12:00',
      room: 'Lab Komputer A',
      seatNumber: 'C-03',
      supervisorName: 'Doni Prasetyo, S.Kom.',
      instructions:
          '1. Implementasi arsitektur Clean & REST API.\n2. Push repo ke GitHub sebelum waktu habis.',
      totalQuestions: 5,
      durationMinutes: 120,
    ),
  ];

  void _showExamRules(ExamModel exam) {
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
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primarySubtle,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.rule_rounded,
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
                          exam.subjectName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimaryLight,
                          ),
                        ),
                        const Text(
                          'Tata Tertib & Petunjuk Ujian',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _infoRow(Icons.meeting_room_outlined, 'Lokasi',
                        '${exam.room} (Nomor Meja: ${exam.seatNumber})'),
                    const SizedBox(height: 10),
                    _infoRow(Icons.person_outline_rounded, 'Pengawas',
                        exam.supervisorName),
                    const SizedBox(height: 10),
                    _infoRow(Icons.timer_outlined, 'Alokasi Waktu',
                        '${exam.durationMinutes} Menit (${exam.totalQuestions} Soal)'),
                    const Divider(height: 24, color: AppColors.borderLight),
                    const Text(
                      'Instruksi Peserta:',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      exam.instructions,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
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
                    'Saya Mengerti',
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

  Widget _infoRow(IconData icon, String title, String val) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          '$title: ',
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: AppColors.textMutedLight,
          ),
        ),
        Expanded(
          child: Text(
            val,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimaryLight,
            ),
          ),
        ),
      ],
    );
  }

  void _showDigitalExamCard() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final user = auth.currentUser;

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
                'KARTU PESERTA UJIAN DIGITAL',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Asesmen Sumatif & Penilaian Tengah Semester',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryDark, AppColors.primary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.school_rounded,
                            color: AppColors.primary,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user?.fullName ?? 'Rizky Pratama',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'NISN: 0068472910 • ${user?.className ?? "XII-IPA 1"}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withValues(alpha: 0.85),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Column(
                        children: [
                          Icon(
                            Icons.qr_code_2_rounded,
                            size: 140,
                            color: AppColors.textPrimaryLight,
                          ),
                          SizedBox(height: 6),
                          Text(
                            'EXAM-2026-XII-00684',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.5,
                              color: AppColors.textPrimaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Tunjukkan QR Code ini kepada pengawas saat memasuki ruang ujian.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pop(ctx),
                  icon: const Icon(Icons.close_rounded),
                  label: const Text('Tutup Kartu'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredExams = _selectedFilter == 'ALL'
        ? _demoExams
        : _demoExams.where((e) => e.examType == _selectedFilter).toList();

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceLight,
        elevation: 0,
        title: const Text(
          'Jadwal Ujian',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimaryLight,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _showDigitalExamCard,
            icon: const Icon(
              Icons.badge_outlined,
              color: AppColors.primary,
            ),
            tooltip: 'Kartu Peserta Ujian',
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Exam Banner
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, Color(0xFF6366F1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.assignment_turned_in_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'UTS Semester Ganjil 2026',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Sisa 4 mata pelajaran mendatang',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _showDigitalExamCard,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Kartu Ujian',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _filterChip('ALL', 'Semua'),
                  _filterChip('UTS', 'UTS Ganjil'),
                  _filterChip('PRAKTIKUM', 'Praktikum'),
                  _filterChip('UAS', 'UAS'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Exam Schedule List
            if (filteredExams.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.event_busy_rounded,
                        size: 48,
                        color: AppColors.textMutedLight,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Tidak ada jadwal ujian pada kategori ini.',
                        style: TextStyle(
                          color: AppColors.textSecondaryLight,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...filteredExams.map((exam) => _buildExamCard(exam)),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String key, String label) {
    final isSelected = _selectedFilter == key;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Text(label),
        labelStyle: TextStyle(
          fontSize: 12,
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
        onSelected: (_) => setState(() => _selectedFilter = key),
      ),
    );
  }

  Widget _buildExamCard(ExamModel exam) {
    final isPast = exam.isPast;
    final isToday = exam.isToday;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isToday
              ? AppColors.primary
              : isPast
                  ? AppColors.borderLight
                  : AppColors.borderLight,
          width: isToday ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                    color: isPast
                        ? AppColors.textMutedLight.withValues(alpha: 0.15)
                        : isToday
                            ? AppColors.primarySubtle
                            : AppColors.infoLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    exam.examType,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: isPast
                          ? AppColors.textMutedLight
                          : isToday
                              ? AppColors.primary
                              : AppColors.info,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  exam.subjectCode,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMutedLight,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: isPast
                        ? AppColors.successLight
                        : isToday
                            ? AppColors.warningLight
                            : AppColors.primarySubtle,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    isPast
                        ? 'Selesai'
                        : isToday
                            ? 'Hari Ini'
                            : 'Mendatang',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: isPast
                          ? AppColors.success
                          : isToday
                              ? AppColors.warning
                              : AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              exam.subjectName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today_rounded,
                  size: 14,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(exam.date),
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.access_time_rounded,
                  size: 14,
                  color: AppColors.textMutedLight,
                ),
                const SizedBox(width: 4),
                Text(
                  '${exam.startTime} - ${exam.endTime} WIB',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.meeting_room_outlined,
                    size: 15,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${exam.room} • Meja ${exam.seatNumber}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => _showExamRules(exam),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Petunjuk',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(width: 2),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 16,
                          color: AppColors.primary,
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
    );
  }
}
