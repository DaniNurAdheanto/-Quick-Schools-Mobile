class GradeModel {
  final String id;
  final String subjectName;
  final String subjectCode;
  final String title;
  final String type;
  final double score;
  final double maxScore;
  final String? remarks;
  final DateTime gradedAt;

  GradeModel({
    required this.id,
    required this.subjectName,
    required this.subjectCode,
    required this.title,
    required this.type,
    required this.score,
    this.maxScore = 100.0,
    this.remarks,
    required this.gradedAt,
  });

  double get percentage => (score / maxScore) * 100;

  String get letterGrade {
    final p = percentage;
    if (p >= 90) return 'A';
    if (p >= 80) return 'B';
    if (p >= 70) return 'C';
    if (p >= 60) return 'D';
    return 'E';
  }

  static String _normalizeType(String rawType) {
    switch (rawType.toUpperCase().trim()) {
      case 'TUGAS':
      case 'DAILY_TASK':
        return 'DAILY_TASK';
      case 'UTS':
      case 'MIDTERM_EXAM':
        return 'MIDTERM_EXAM';
      case 'UAS':
      case 'PROYEK':
      case 'PROJECT':
        return 'PROJECT';
      case 'ULANGAN':
      case 'KUIS':
      case 'QUIZ':
        return 'QUIZ';
      default:
        return rawType;
    }
  }

  factory GradeModel.fromJson(Map<String, dynamic> json) {
    final subjectMap = json['subject'] is Map ? json['subject'] as Map : null;
    final subjectName = (subjectMap?['name'] ??
            json['subjectName'] ??
            (json['subject'] is String ? json['subject'] : null) ??
            'Mata Pelajaran')
        .toString();
    final subjectCode =
        (subjectMap?['code'] ?? json['subjectCode'] ?? 'MAPEL').toString();
    final rawType = (json['type'] ?? 'DAILY_TASK').toString();
    final rawNotes = json['remarks'] ?? json['notes'];
    final cleanNotes =
        (rawNotes != null && rawNotes.toString().trim() != '-')
            ? rawNotes.toString().trim()
            : null;

    return GradeModel(
      id: (json['id'] ?? '').toString(),
      subjectName: subjectName,
      subjectCode: subjectCode,
      title: (json['title'] ?? '$rawType • $subjectName').toString(),
      type: _normalizeType(rawType),
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
      maxScore: (json['maxScore'] as num?)?.toDouble() ?? 100.0,
      remarks: cleanNotes,
      gradedAt: DateTime.tryParse(
            (json['gradedAt'] ?? json['createdAt'] ?? '').toString(),
          ) ??
          DateTime.now(),
    );
  }
}

class ScheduleModel {
  final String id;
  final String subjectName;
  final String subjectCode;
  final String teacherName;
  final String room;
  final int dayOfWeek; // 1 = Monday ... 6 = Saturday
  final String startTime;
  final String endTime;

  ScheduleModel({
    required this.id,
    required this.subjectName,
    required this.subjectCode,
    required this.teacherName,
    required this.room,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
  });

  String get dayName {
    switch (dayOfWeek) {
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
      default:
        return 'Minggu';
    }
  }

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    final subjectMap = json['subject'] is Map ? json['subject'] as Map : null;
    final teacherMap = json['teacher'] is Map ? json['teacher'] as Map : null;
    final teacherUser =
        teacherMap?['user'] is Map ? teacherMap!['user'] as Map : null;

    final resolvedTeacher = teacherUser != null
        ? '${teacherUser['firstName'] ?? ''} ${teacherUser['lastName'] ?? ''}'.trim()
        : (json['teacherName'] ??
                (json['teacher'] is String ? json['teacher'] : null) ??
                'Guru')
            .toString();

    return ScheduleModel(
      id: (json['id'] ?? '').toString(),
      subjectName: (subjectMap?['name'] ??
              json['subjectName'] ??
              (json['subject'] is String ? json['subject'] : null) ??
              'Pelajaran')
          .toString(),
      subjectCode:
          (subjectMap?['code'] ?? json['subjectCode'] ?? '').toString(),
      teacherName: resolvedTeacher.isEmpty ? 'Guru' : resolvedTeacher,
      room: (json['room'] ?? 'Kelas').toString(),
      dayOfWeek: (json['dayOfWeek'] as num?)?.toInt() ?? 1,
      startTime: (json['startTime'] ?? '07:30').toString(),
      endTime: (json['endTime'] ?? '09:00').toString(),
    );
  }
}
