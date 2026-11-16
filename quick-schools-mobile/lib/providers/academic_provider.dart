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
      // Senin (Day 1)
      ScheduleModel(
        id: 'sch-1',
        subjectName: 'Matematika Peminatan',
        subjectCode: 'MTH-301',
        teacherName: 'Budi Santoso, M.Pd.',
        room: 'Ruang 101',
        dayOfWeek: 1, // Senin
        startTime: '07:15',
        endTime: '08:45',
      ),
      ScheduleModel(
        id: 'sch-2',
        subjectName: 'Fisika Kuantum Dasar',
        subjectCode: 'PHY-201',
        teacherName: 'Ir. Dewi Sartika, M.T.',
        room: 'Lab Fisika Lt. 2',
        dayOfWeek: 1, // Senin
        startTime: '08:45',
        endTime: '10:30',
      ),
      ScheduleModel(
        id: 'sch-3',
        subjectName: 'Bahasa Indonesia & Literasi',
        subjectCode: 'IND-201',
        teacherName: 'Dra. Endang Sulastri',
        room: 'Ruang 101',
        dayOfWeek: 1, // Senin
        startTime: '10:45',
        endTime: '12:15',
      ),
      ScheduleModel(
        id: 'sch-4',
        subjectName: 'Kimia Terapan',
        subjectCode: 'CHM-301',
        teacherName: 'Dr. Ahmad Fauzi',
        room: 'Lab Kimia',
        dayOfWeek: 1, // Senin
        startTime: '13:00',
        endTime: '14:30',
      ),
      ScheduleModel(
        id: 'sch-5',
        subjectName: 'Pendidikan Jasmani & Olahraga',
        subjectCode: 'PJO-101',
        teacherName: 'Coach Hadi Wijaya, S.Pd.',
        room: 'Gelanggang Olahraga',
        dayOfWeek: 1, // Senin
        startTime: '14:30',
        endTime: '15:45',
      ),

      // Selasa (Day 2)
      ScheduleModel(
        id: 'sch-6',
        subjectName: 'Bahasa Inggris Lanjutan',
        subjectCode: 'ENG-102',
        teacherName: 'Sarah Jenkins, B.Ed.',
        room: 'Lab Bahasa',
        dayOfWeek: 2, // Selasa
        startTime: '07:15',
        endTime: '08:45',
      ),
      ScheduleModel(
        id: 'sch-7',
        subjectName: 'Biologi Molekuler',
        subjectCode: 'BIO-201',
        teacherName: 'Siti Rahmawati, M.Si.',
        room: 'Lab Biologi',
        dayOfWeek: 2, // Selasa
        startTime: '09:00',
        endTime: '10:30',
      ),
      ScheduleModel(
        id: 'sch-8',
        subjectName: 'Kimia Organik',
        subjectCode: 'CHM-201',
        teacherName: 'Dr. Ahmad Fauzi',
        room: 'Lab Kimia',
        dayOfWeek: 2, // Selasa
        startTime: '10:45',
        endTime: '12:15',
      ),
      ScheduleModel(
        id: 'sch-9',
        subjectName: 'Sejarah Indonesia',
        subjectCode: 'HIS-101',
        teacherName: 'Bambang Sudibyo, S.Pd.',
        room: 'Ruang 102',
        dayOfWeek: 2, // Selasa
        startTime: '13:00',
        endTime: '14:30',
      ),

      // Rabu (Day 3)
      ScheduleModel(
        id: 'sch-10',
        subjectName: 'Informatika & Pemrograman',
        subjectCode: 'INF-101',
        teacherName: 'Doni Prasetyo, S.Kom.',
        room: 'Lab Komputer A',
        dayOfWeek: 3, // Rabu
        startTime: '07:30',
        endTime: '09:45',
      ),
      ScheduleModel(
        id: 'sch-11',
        subjectName: 'Seni Budaya & Desain',
        subjectCode: 'ART-101',
        teacherName: 'Maya Kusuma, S.Sn.',
        room: 'Studio Seni',
        dayOfWeek: 3, // Rabu
        startTime: '10:00',
        endTime: '11:30',
      ),
      ScheduleModel(
        id: 'sch-12',
        subjectName: 'Pendidikan Agama & Budi Pekerti',
        subjectCode: 'REL-101',
        teacherName: 'Ust. H. Ridwan Kamil, M.Ag.',
        room: 'Masjid Kampus',
        dayOfWeek: 3, // Rabu
        startTime: '12:45',
        endTime: '14:15',
      ),

      // Kamis (Day 4)
      ScheduleModel(
        id: 'sch-13',
        subjectName: 'Geografi & Kebumian',
        subjectCode: 'GEO-201',
        teacherName: 'Drs. Yulianto, M.Pd.',
        room: 'Ruang 103',
        dayOfWeek: 4, // Kamis
        startTime: '07:15',
        endTime: '09:00',
      ),
      ScheduleModel(
        id: 'sch-14',
        subjectName: 'Ekonomi & Akuntansi',
        subjectCode: 'ECO-201',
        teacherName: 'Sri Wahyuni, S.E., M.M.',
        room: 'Ruang 103',
        dayOfWeek: 4, // Kamis
        startTime: '09:15',
        endTime: '11:00',
      ),
      ScheduleModel(
        id: 'sch-15',
        subjectName: 'Sosiologi Terapan',
        subjectCode: 'SOC-101',
        teacherName: 'Rina Kuswardani, M.Sos.',
        room: 'Ruang 103',
        dayOfWeek: 4, // Kamis
        startTime: '11:15',
        endTime: '12:45',
      ),

      // Jumat (Day 5)
      ScheduleModel(
        id: 'sch-16',
        subjectName: 'Pendidikan Pancasila & PPKn',
        subjectCode: 'PPKN-101',
        teacherName: 'Supriyanto, S.Pd., M.H.',
        room: 'Ruang 101',
        dayOfWeek: 5, // Jumat
        startTime: '07:00',
        endTime: '08:30',
      ),
      ScheduleModel(
        id: 'sch-17',
        subjectName: 'Matematika Terapan & Statistika',
        subjectCode: 'MTH-302',
        teacherName: 'Budi Santoso, M.Pd.',
        room: 'Ruang 101',
        dayOfWeek: 5, // Jumat
        startTime: '08:45',
        endTime: '10:15',
      ),
      ScheduleModel(
        id: 'sch-18',
        subjectName: 'Proyek Penguatan Karakter P5',
        subjectCode: 'P5-101',
        teacherName: 'Tim Fasilitator P5',
        room: 'Aula Serbaguna',
        dayOfWeek: 5, // Jumat
        startTime: '10:30',
        endTime: '11:30',
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
      AnnouncementModel(
        id: 'ann-4',
        title: 'Penyerahan E-Rapor Digital Semester Ganjil',
        content: 'E-Rapor hasil belajar semester ganjil dapat diakses secara digital melalui menu Rapot Digital pada aplikasi mulai Jumat, 18 Desember 2026.',
        priority: 'URGENT',
        authorName: 'Wali Kelas & Bagian Kurikulum',
        publishedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      AnnouncementModel(
        id: 'ann-5',
        title: 'Kalender Libur Semester Ganjil & Masuk Semester Genap',
        content: 'Libur semester ganjil berlangsung tanggal 21 Desember 2026 s/d 2 Januari 2027. Pembelajaran semester genap aktif kembali hari Senin, 4 Januari 2027.',
        priority: 'NORMAL',
        authorName: 'Tata Usaha Sekolah',
        publishedAt: DateTime.now().subtract(const Duration(days: 6)),
      ),
    ];
  }
}
