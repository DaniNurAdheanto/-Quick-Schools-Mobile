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

  factory GradeModel.fromJson(Map<String, dynamic> json) {
    return GradeModel(
      id: json['id'] ?? '',
      subjectName: json['subject']?['name'] ?? json['subjectName'] ?? 'Mata Pelajaran',
      subjectCode: json['subject']?['code'] ?? json['subjectCode'] ?? 'SUBJ',
      title: json['title'] ?? 'Tugas',
      type: json['type'] ?? 'DAILY_TASK',
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
      maxScore: (json['maxScore'] as num?)?.toDouble() ?? 100.0,
      remarks: json['remarks'],
      gradedAt: DateTime.tryParse(json['gradedAt'] ?? '') ?? DateTime.now(),
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
    return ScheduleModel(
      id: json['id'] ?? '',
      subjectName: json['subject']?['name'] ?? json['subjectName'] ?? 'Pelajaran',
      subjectCode: json['subject']?['code'] ?? json['subjectCode'] ?? '',
      teacherName: json['teacher']?['user'] != null
          ? '${json['teacher']['user']['firstName']} ${json['teacher']['user']['lastName']}'
          : json['teacherName'] ?? 'Guru',
      room: json['room'] ?? 'Kelas',
      dayOfWeek: json['dayOfWeek'] ?? 1,
      startTime: json['startTime'] ?? '07:30',
      endTime: json['endTime'] ?? '09:00',
    );
  }
}
