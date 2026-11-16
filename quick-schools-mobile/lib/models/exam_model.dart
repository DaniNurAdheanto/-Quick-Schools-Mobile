class ExamModel {
  final String id;
  final String subjectName;
  final String subjectCode;
  final String examType; // UTS, UAS, QUIZ, PRAKTIKUM
  final DateTime date;
  final String startTime;
  final String endTime;
  final String room;
  final String seatNumber;
  final String supervisorName;
  final String instructions;
  final int totalQuestions;
  final int durationMinutes;

  const ExamModel({
    required this.id,
    required this.subjectName,
    required this.subjectCode,
    required this.examType,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.room,
    required this.seatNumber,
    required this.supervisorName,
    required this.instructions,
    required this.totalQuestions,
    required this.durationMinutes,
  });

  bool get isPast => DateTime.now().isAfter(
        DateTime(
          date.year,
          date.month,
          date.day,
          int.tryParse(endTime.split(':').first) ?? 23,
          int.tryParse(endTime.split(':').last) ?? 59,
        ),
      );

  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  factory ExamModel.fromJson(Map<String, dynamic> json) {
    return ExamModel(
      id: json['id'] as String? ?? '',
      subjectName: json['subjectName'] as String? ?? '',
      subjectCode: json['subjectCode'] as String? ?? '',
      examType: json['examType'] as String? ?? 'UTS',
      date: json['date'] != null
          ? DateTime.parse(json['date'] as String)
          : DateTime.now(),
      startTime: json['startTime'] as String? ?? '08:00',
      endTime: json['endTime'] as String? ?? '09:30',
      room: json['room'] as String? ?? 'Ruang Ujian',
      seatNumber: json['seatNumber'] as String? ?? '01',
      supervisorName: json['supervisorName'] as String? ?? 'Pengawas Ujian',
      instructions: json['instructions'] as String? ?? 'Bawa alat tulis dan kartu ujian.',
      totalQuestions: json['totalQuestions'] as int? ?? 40,
      durationMinutes: json['durationMinutes'] as int? ?? 90,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subjectName': subjectName,
      'subjectCode': subjectCode,
      'examType': examType,
      'date': date.toIso8601String(),
      'startTime': startTime,
      'endTime': endTime,
      'room': room,
      'seatNumber': seatNumber,
      'supervisorName': supervisorName,
      'instructions': instructions,
      'totalQuestions': totalQuestions,
      'durationMinutes': durationMinutes,
    };
  }
}

