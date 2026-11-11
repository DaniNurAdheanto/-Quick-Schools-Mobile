enum AttendanceStatus {
  present,
  absent,
  late,
  excused;

  static AttendanceStatus fromString(String status) {
    switch (status.toUpperCase()) {
      case 'PRESENT':
        return AttendanceStatus.present;
      case 'LATE':
        return AttendanceStatus.late;
      case 'EXCUSED':
        return AttendanceStatus.excused;
      case 'ABSENT':
      default:
        return AttendanceStatus.absent;
    }
  }

  String toPrismaString() {
    switch (this) {
      case AttendanceStatus.present:
        return 'PRESENT';
      case AttendanceStatus.late:
        return 'LATE';
      case AttendanceStatus.excused:
        return 'EXCUSED';
      case AttendanceStatus.absent:
        return 'ABSENT';
    }
  }

  String get label {
    switch (this) {
      case AttendanceStatus.present:
        return 'Hadir';
      case AttendanceStatus.late:
        return 'Terlambat';
      case AttendanceStatus.excused:
        return 'Izin / Sakit';
      case AttendanceStatus.absent:
        return 'Alpa';
    }
  }
}

class AttendanceModel {
  final String id;
  final String studentId;
  final String studentName;
  final String? className;
  final DateTime date;
  final AttendanceStatus status;
  final String? checkInTime;
  final String? notes;

  AttendanceModel({
    required this.id,
    required this.studentId,
    required this.studentName,
    this.className,
    required this.date,
    required this.status,
    this.checkInTime,
    this.notes,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id'] ?? '',
      studentId: json['studentId'] ?? '',
      studentName: json['student']?['user'] != null 
          ? '${json['student']['user']['firstName']} ${json['student']['user']['lastName']}'
          : json['studentName'] ?? 'Siswa',
      className: json['classRoom']?['name'] ?? json['className'],
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      status: AttendanceStatus.fromString(json['status'] ?? 'PRESENT'),
      checkInTime: json['checkInTime'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'studentName': studentName,
      'className': className,
      'date': date.toIso8601String(),
      'status': status.toPrismaString(),
      'checkInTime': checkInTime,
      'notes': notes,
    };
  }
}
