import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/report_card_model.dart';
import '../../providers/auth_provider.dart';

class ReportCardScreen extends StatefulWidget {
  const ReportCardScreen({super.key});

  @override
  State<ReportCardScreen> createState() => _ReportCardScreenState();
}

class _ReportCardScreenState extends State<ReportCardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedSemester = 'Semester Ganjil 2026/2027';

  final List<String> _availableSemesters = [
    'Semester Ganjil 2026/2027',
    'Semester Genap 2025/2026',
    'Semester Ganjil 2025/2026',
  ];

  final ReportCardModel _demoReportCard = const ReportCardModel(
    id: 'rep-2026-1',
    semester: 'Semester 1 (Ganjil)',
    academicYear: '2026/2027',
    studentName: 'Rizky Pratama',
    nisn: '0068472910',
    className: 'XII-IPA 1',
    homeroomTeacher: 'Budi Santoso, M.Pd.',
    gpa: 3.78,
    classRank: 3,
    totalStudentsInClass: 36,
    presentDays: 88,
    sickDays: 2,
    permissionDays: 1,
    unexcusedDays: 0,
    headmasterName: 'Dr. Hendra Gunawan, M.Si.',
    headmasterNip: '19750812 199903 1 002',
    teacherNotes:
        'Rizky menunjukkan integritas dan prestasi akademik yang sangat membanggakan di bidang sains dan teknologi. Pertahankan semangat belajar, kolaborasi tim, dan kedisiplinan menjelang ujian masuk perguruan tinggi negeri.',
    subjectGrades: [
      SubjectGrade(
        subjectName: 'Matematika Peminatan',
        subjectCode: 'MTH-301',
        category: 'Kelompok C (Peminatan MIPA)',
        kkm: 75.0,
        knowledgeScore: 92.0,
        knowledgeLetter: 'A',
        skillScore: 94.0,
        skillLetter: 'A',
        competencyDescription:
            'Sangat cakap dalam menganalisis kalkulus diferensial dan matriks lanjut.',
      ),
      SubjectGrade(
        subjectName: 'Fisika Terapan & Kuantum',
        subjectCode: 'PHY-201',
        category: 'Kelompok C (Peminatan MIPA)',
        kkm: 75.0,
        knowledgeScore: 88.0,
        knowledgeLetter: 'B+',
        skillScore: 90.0,
        skillLetter: 'A',
        competencyDescription:
            'Menguasai konsep mekanika fluida dan eksperimen laboratorium fisika.',
      ),
      SubjectGrade(
        subjectName: 'Informatika & Pemrograman',
        subjectCode: 'INF-101',
        category: 'Kelompok C (Peminatan MIPA)',
        kkm: 78.0,
        knowledgeScore: 96.0,
        knowledgeLetter: 'A',
        skillScore: 98.0,
        skillLetter: 'A',
        competencyDescription:
            'Luar biasa dalam merancang arsitektur aplikasi mobile dan problem solving algoritmik.',
      ),
      SubjectGrade(
        subjectName: 'Kimia Analitik',
        subjectCode: 'CHM-201',
        category: 'Kelompok C (Peminatan MIPA)',
        kkm: 75.0,
        knowledgeScore: 85.0,
        knowledgeLetter: 'B',
        skillScore: 87.0,
        skillLetter: 'B+',
        competencyDescription:
            'Mampu melakukan titrasi asam basa dan reaksi redoks secara tepat.',
      ),
      SubjectGrade(
        subjectName: 'Bahasa Indonesia',
        subjectCode: 'IND-101',
        category: 'Kelompok A (Wajib Umum)',
        kkm: 75.0,
        knowledgeScore: 89.0,
        knowledgeLetter: 'A',
        skillScore: 91.0,
        skillLetter: 'A',
        competencyDescription:
            'Mahir menyusun artikel ilmiah populer dan berargumentasi secara kritis.',
      ),
      SubjectGrade(
        subjectName: 'Bahasa Inggris Akademik',
        subjectCode: 'ENG-102',
        category: 'Kelompok A (Wajib Umum)',
        kkm: 75.0,
        knowledgeScore: 92.0,
        knowledgeLetter: 'A',
        skillScore: 90.0,
        skillLetter: 'A',
        competencyDescription:
            'Sangat fasih dalam presentasi akademik dan penulisan esai bahasa Inggris.',
      ),
      SubjectGrade(
        subjectName: 'Pendidikan Agama & Budi Pekerti',
        subjectCode: 'PAI-101',
        category: 'Kelompok A (Wajib Umum)',
        kkm: 78.0,
        knowledgeScore: 90.0,
        knowledgeLetter: 'A',
        skillScore: 92.0,
        skillLetter: 'A',
        competencyDescription:
            'Menunjukkan sikap toleransi, ibadah konsisten, dan akhlak mulia.',
      ),
      SubjectGrade(
        subjectName: 'Pendidikan Pancasila & Kewarganegaraan',
        subjectCode: 'PPKN-101',
        category: 'Kelompok A (Wajib Umum)',
        kkm: 75.0,
        knowledgeScore: 88.0,
        knowledgeLetter: 'B+',
        skillScore: 89.0,
        skillLetter: 'A',
        competencyDescription:
            'Memahami sistem hukum dan tata kelola berbangsa secara komprehensif.',
      ),
    ],
    extracurriculars: [
      ExtracurricularScore(
        name: 'Pramuka Penegak Garuda (Wajib)',
        grade: 'A',
        description:
            'Sangat aktif memimpin regu perkemahan dan disiplin baris berbaris.',
      ),
      ExtracurricularScore(
        name: 'Klub Robotika & IoT',
        grade: 'A',
        description:
            'Juara 2 Lomba Inovasi Teknologi Siswa Tingkat Provinsi 2026.',
      ),
      ExtracurricularScore(
        name: 'Karya Ilmiah Remaja (KIR)',
        grade: 'A',
        description:
            'Mempublikasikan riset purwarupa sistem absensi biometrik sekolah.',
      ),
    ],
  );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleDownloadPdf() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'E-Rapor Digital berhasil diunduh ke format PDF resmi.',
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.success,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.currentUser;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceLight,
        elevation: 0,
        title: const Text(
          'Rapot Digital Siswa',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimaryLight,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _handleDownloadPdf,
            icon: const Icon(
              Icons.download_rounded,
              color: AppColors.primary,
            ),
            tooltip: 'Unduh E-Rapor PDF',
          ),
        ],
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
                child: Column(
                  children: [
                    // Semester Selector Card
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedSemester,
                          isExpanded: true,
                          icon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: AppColors.primary,
                          ),
                          items: _availableSemesters.map((sem) {
                            return DropdownMenuItem<String>(
                              value: sem,
                              child: Text(
                                sem,
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimaryLight,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _selectedSemester = val);
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Overall Achievement Summary Banner
                    _buildOverviewBanner(user),
                    const SizedBox(height: 14),

                    // Quick Stats Bento
                    _buildQuickStatsBento(),
                    const SizedBox(height: 14),
                  ],
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                TabBar(
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
                    Tab(text: 'Nilai Akademik'),
                    Tab(text: 'Ekstrakurikuler'),
                    Tab(text: 'Catatan & Sikap'),
                  ],
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildAcademicGradesTab(),
            _buildExtracurricularTab(),
            _buildNotesAndAttitudeTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewBanner(dynamic user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.28),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.fullName ?? _demoReportCard.studentName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'NISN: ${_demoReportCard.nisn} • ${user?.className ?? _demoReportCard.className}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
                child: const Text(
                  'TUNTAS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 28, color: Colors.white24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _metricColumn(
                label: 'Rata-Rata Rapor',
                value: _demoReportCard.overallAverage.toStringAsFixed(1),
                sub: 'Skala 100',
              ),
              Container(width: 1, height: 36, color: Colors.white24),
              _metricColumn(
                label: 'Peringkat Kelas',
                value: '#${_demoReportCard.classRank}',
                sub: 'dari ${_demoReportCard.totalStudentsInClass} Siswa',
              ),
              Container(width: 1, height: 36, color: Colors.white24),
              _metricColumn(
                label: 'Indeks Prestasi',
                value: _demoReportCard.gpa.toStringAsFixed(2),
                sub: 'Predikat A',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metricColumn({
    required String label,
    required String value,
    required String sub,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          sub,
          style: TextStyle(
            fontSize: 10,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStatsBento() {
    return Row(
      children: [
        Expanded(
          child: _bentoTile(
            title: 'Kehadiran',
            value: '${_demoReportCard.presentDays} Hari',
            caption:
                'Sakit: ${_demoReportCard.sickDays} • Izin: ${_demoReportCard.permissionDays} • Alpa: ${_demoReportCard.unexcusedDays}',
            icon: Icons.check_circle_outline_rounded,
            color: AppColors.success,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _bentoTile(
            title: 'Wali Kelas',
            value: _demoReportCard.homeroomTeacher.split(',').first,
            caption: 'NIP. 19820415...',
            icon: Icons.person_pin_rounded,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _bentoTile({
    required String title,
    required String value,
    required String caption,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            caption,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10.5,
              color: AppColors.textMutedLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAcademicGradesTab() {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      itemCount: _demoReportCard.subjectGrades.length,
      itemBuilder: (context, index) {
        final subject = _demoReportCard.subjectGrades[index];
        return _buildSubjectGradeCard(subject);
      },
    );
  }

  Widget _buildSubjectGradeCard(SubjectGrade subject) {
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subject.category,
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subject.subjectName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                    Text(
                      'KKM: ${subject.kkm.toInt()}',
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppColors.textMutedLight,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primarySubtle,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    Text(
                      subject.finalScore.toStringAsFixed(0),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      'Predikat ${subject.knowledgeLetter}',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 22, color: AppColors.borderLight),
          Row(
            children: [
              Expanded(
                child: _scorePill(
                  label: 'Pengetahuan (KD 3)',
                  score: subject.knowledgeScore.toStringAsFixed(0),
                  grade: subject.knowledgeLetter,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _scorePill(
                  label: 'Keterampilan (KD 4)',
                  score: subject.skillScore.toStringAsFixed(0),
                  grade: subject.skillLetter,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.lightbulb_outline_rounded,
                  size: 15,
                  color: AppColors.warning,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    subject.competencyDescription,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.4,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _scorePill({
    required String label,
    required String score,
    required String grade,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.textMutedLight,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '$score ($grade)',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExtracurricularTab() {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        ..._demoReportCard.extracurriculars.map((extra) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.successLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      'A',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.success,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        extra.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        extra.description,
                        style: const TextStyle(
                          fontSize: 12.5,
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
        }),
      ],
    );
  }

  Widget _buildNotesAndAttitudeTab() {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        // Homeroom teacher note card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.rate_review_outlined,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Catatan Wali Kelas',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _demoReportCard.homeroomTeacher,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMutedLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  _demoReportCard.teacherNotes,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    fontStyle: FontStyle.italic,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Spiritual & Social Attitudes Card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Penilaian Sikap & Karakter',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 14),
              _attitudeRow(
                title: 'Sikap Spiritual (Ketaatan Beribadah)',
                grade: 'Sangat Baik (A)',
                desc:
                    'Selalu taat beribadah, berdoa sebelum dan sesudah kegiatan, serta bertoleransi antarumat beragama.',
              ),
              const Divider(height: 24, color: AppColors.borderLight),
              _attitudeRow(
                title: 'Sikap Sosial (Integritas & Gotong Royong)',
                grade: 'Sangat Baik (A)',
                desc:
                    'Memiliki kejujuran tinggi, sopan santun kepada guru dan teman, serta aktif dalam kegiatan kepedulian sosial.',
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Action download button
        ElevatedButton.icon(
          onPressed: _handleDownloadPdf,
          icon: const Icon(Icons.picture_as_pdf_rounded),
          label: const Text('Unduh Salinan Rapot PDF'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _attitudeRow({
    required String title,
    required String grade,
    required String desc,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimaryLight,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.successLight,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                grade,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.success,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          desc,
          style: const TextStyle(
            fontSize: 12,
            height: 1.4,
            color: AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);
  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: AppColors.surfaceLight,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

