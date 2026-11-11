import 'package:flutter/foundation.dart';
import '../models/grade_model.dart';
import '../models/announcement_model.dart';
import '../core/network/api_client.dart';
import '../core/constants/api_endpoints.dart';

class AcademicProvider with ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  List<ScheduleModel> _schedules = [];
  List<GradeModel> _grades = [];
  List<AnnouncementModel> _announcements = [];
  bool _isLoading = false;

  List<ScheduleModel> get schedules => _schedules;
  List<GradeModel> get grades => _grades;
  List<AnnouncementModel> get announcements => _announcements;
  bool get isLoading => _isLoading;

  double get averageGrade {
    if (_grades.isEmpty) return 88.5;
    final total = _grades.fold<double>(0.0, (sum, item) => sum + item.score);
    return total / _grades.length;
  }

  Future<void> fetchAllAcademicData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final futures = await Future.wait([
        _apiClient.dio.get(ApiEndpoints.schedules),
        _apiClient.dio.get(ApiEndpoints.grades),
        _apiClient.dio.get(ApiEndpoints.announcements),
      ]);

      if (futures[0].statusCode == 200 && futures[0].data['data'] != null) {
        final List list = futures[0].data['data'];
        _schedules = list.map((item) => ScheduleModel.fromJson(item)).toList();
      } else {
        _loadDemoSchedules();
      }

      if (futures[1].statusCode == 200 && futures[1].data['data'] != null) {
        final List list = futures[1].data['data'];
        _grades = list.map((item) => GradeModel.fromJson(item)).toList();
      } else {
        _loadDemoGrades();
      }

      if (futures[2].statusCode == 200 && futures[2].data['data'] != null) {
        final List list = futures[2].data['data'];
        _announcements = list.map((item) => AnnouncementModel.fromJson(item)).toList();
      } else {
        _loadDemoAnnouncements();
      }
    } catch (_) {
      _loadDemoSchedules();
      _loadDemoGrades();
      _loadDemoAnnouncements();
    }

    _isLoading = false;
    notifyListeners();
  }

  void _loadDemoSchedules() {
    _schedules = [
      ScheduleModel(
        id: 'sch-1',
        subjectName: 'Matematika Peminatan',
        subjectCode: 'MTH-301',
        teacherName: 'Budi Santoso, M.Pd.',
        room: 'Ruang 101',
        dayOfWeek: 1, // Senin
        startTime: '07:30',
        endTime: '09:00',
      ),
      ScheduleModel(
        id: 'sch-2',
        subjectName: 'Fisika Kuantum Dasar',
        subjectCode: 'PHY-201',
        teacherName: 'Ir. Dewi Sartika, M.T.',
        room: 'Lab Fisika Lt. 2',
        dayOfWeek: 1, // Senin
        startTime: '09:15',
        endTime: '11:00',
      ),
      ScheduleModel(
        id: 'sch-3',
        subjectName: 'Bahasa Inggris Lanjutan',
        subjectCode: 'ENG-102',
        teacherName: 'Sarah Jenkins, B.Ed.',
        room: 'Lab Bahasa',
        dayOfWeek: 2, // Selasa
        startTime: '07:30',
        endTime: '09:00',
      ),
      ScheduleModel(
        id: 'sch-4',
        subjectName: 'Kimia Organik',
        subjectCode: 'CHM-201',
        teacherName: 'Dr. Ahmad Fauzi',
        room: 'Lab Kimia',
        dayOfWeek: 2, // Selasa
        startTime: '10:00',
        endTime: '11:45',
      ),
      ScheduleModel(
        id: 'sch-5',
        subjectName: 'Informatika & Pemrograman',
        subjectCode: 'INF-101',
        teacherName: 'Doni Prasetyo, S.Kom.',
        room: 'Lab Komputer A',
        dayOfWeek: 3, // Rabu
        startTime: '08:00',
        endTime: '10:15',
      ),
    ];
  }

  void _loadDemoGrades() {
    _grades = [
      GradeModel(
        id: 'grd-1',
        subjectName: 'Matematika Peminatan',
        subjectCode: 'MTH-301',
        title: 'Penilaian Harian: Vektor & Matriks',
        type: 'DAILY_TASK',
        score: 94.0,
        remarks: 'Pemahaman konsep dan aljabar sangat baik.',
        gradedAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      GradeModel(
        id: 'grd-2',
        subjectName: 'Fisika Terapan',
        subjectCode: 'PHY-201',
        title: 'Ujian Tengah Semester Ganjil',
        type: 'MIDTERM_EXAM',
        score: 88.5,
        remarks: 'Tingkatkan ketelitian rumus kinetika.',
        gradedAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
      GradeModel(
        id: 'grd-3',
        subjectName: 'Informatika & Algoritma',
        subjectCode: 'INF-101',
        title: 'Praktikum Proyek Mobile Flutter',
        type: 'PROJECT',
        score: 98.0,
        remarks: 'Integrasi REST API dan arsitektur MVVM sempurna.',
        gradedAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
      GradeModel(
        id: 'grd-4',
        subjectName: 'Bahasa Inggris',
        subjectCode: 'ENG-102',
        title: 'Academic Speech & Presentation',
        type: 'QUIZ',
        score: 91.0,
        remarks: 'Pronunciation and vocabulary fluent.',
        gradedAt: DateTime.now().subtract(const Duration(days: 14)),
      ),
    ];
  }

  void _loadDemoAnnouncements() {
    _announcements = [
      AnnouncementModel(
        id: 'ann-1',
        title: 'Jadwal Penilaian Akhir Semester (PAS) Ganjil 2026/2027',
        content: 'Diberitahukan kepada seluruh siswa, guru, dan wali murid bahwa pelaksanaan PAS Ganjil akan dimulai pada hari Senin, 1 Desember 2026. Kartu ujian digital dapat diakses melalui menu Profil aplikasi.',
        priority: 'URGENT',
        authorName: 'Wakil Kepala Sekolah Bidang Kurikulum',
        publishedAt: DateTime.now().subtract(const Duration(hours: 4)),
        isPinned: true,
      ),
      AnnouncementModel(
        id: 'ann-2',
        title: 'Pembaruan Fasilitas Laboratorium Komputer dan Wi-Fi Kampus',
        content: 'Quick Schools telah merampungkan peningkatan bandwidth 1 Gbps serta penambahan perangkat iMac di Lab Komputer B untuk menunjang pembelajaran mobile app & robotic.',
        priority: 'NORMAL',
        authorName: 'Kepala Bagian IT & Sarana',
        publishedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      AnnouncementModel(
        id: 'ann-3',
        title: 'Rapat Koordinasi Orang Tua & Wali Siswa Kelas X',
        content: 'Undangan rapat komite sekolah mengenai sosialisasi program magang industri dan kurikulum Merdeka Berkarakter.',
        targetRole: 'PARENT',
        priority: 'NORMAL',
        authorName: 'Hubungan Masyarakat (Humas)',
        publishedAt: DateTime.now().subtract(const Duration(days: 4)),
      ),
    ];
  }
}
