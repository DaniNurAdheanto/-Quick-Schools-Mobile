enum AttendanceStatus {
  present,
  absent,
  late,
  excused;

  static AttendanceStatus fromString(String status) {
    switch (status.toUpperCase().trim()) {
      case 'PRESENT':
      case 'HADIR':
        return AttendanceStatus.present;
      case 'LATE':
      case 'TERLAMBAT':
        return AttendanceStatus.late;
      case 'EXCUSED':
      case 'IZIN':
      case 'SAKIT':
        return AttendanceStatus.excused;
      case 'ABSENT':
      case 'ALPA':
      case 'TIDAK HADIR':
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

  String toIndonesianApiStatus() {
    switch (this) {
      case AttendanceStatus.present:
        return 'Hadir';
      case AttendanceStatus.late:
        return 'Terlambat';
      case AttendanceStatus.excused:
        return 'Izin';
      case AttendanceStatus.absent:
        return 'Alpa';
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
  final double? latitude;
  final double? longitude;
  final double? locationAccuracy;

  AttendanceModel({
    required this.id,
    required this.studentId,
    required this.studentName,
    this.className,
    required this.date,
    required this.status,
    this.checkInTime,
    this.notes,
    this.latitude,
    this.longitude,
    this.locationAccuracy,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    final studentMap = json['student'] is Map ? json['student'] as Map : null;
    final studentUser =
        studentMap?['user'] is Map ? studentMap!['user'] as Map : null;
    final classMap =
        json['classRoom'] is Map ? json['classRoom'] as Map : null;

    final resolvedName = studentUser != null
        ? '${studentUser['firstName'] ?? ''} ${studentUser['lastName'] ?? ''}'.trim()
        : (json['fullName'] ?? json['studentName'] ?? json['name'] ?? 'Siswa')
            .toString();

    final rawTime = json['checkInTime'] ?? json['time'];
    final cleanTime =
        (rawTime != null && rawTime.toString().trim() != '-' && rawTime.toString().trim().isNotEmpty)
            ? rawTime.toString().trim()
            : null;

    return AttendanceModel(
      id: (json['id'] ?? '').toString(),
      studentId: (json['studentId'] ?? '').toString(),
      studentName: resolvedName.isEmpty ? 'Siswa' : resolvedName,
      className: (classMap?['name'] ?? json['className'])?.toString(),
      date: DateTime.tryParse((json['date'] ?? '').toString()) ?? DateTime.now(),
      status: AttendanceStatus.fromString((json['status'] ?? 'PRESENT').toString()),
      checkInTime: cleanTime,
      notes: json['notes']?.toString(),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      locationAccuracy: (json['locationAccuracy'] as num?)?.toDouble(),
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
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (locationAccuracy != null) 'locationAccuracy': locationAccuracy,
    };
  }
}
