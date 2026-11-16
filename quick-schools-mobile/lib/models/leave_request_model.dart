enum LeaveType {
  sick('Sakit', 'S'),
  permission('Izin Keperluan', 'I'),
  familyEmergency('Keperluan Keluarga', 'K'),
  schoolActivity('Dispensasi Lomba / Tugas', 'D');

  final String label;
  final String shortCode;
  const LeaveType(this.label, this.shortCode);
}

enum LeaveStatus {
  pending('Menunggu Verifikasi', 'PENDING'),
  approved('Disetujui', 'APPROVED'),
  rejected('Ditolak', 'REJECTED');

  final String label;
  final String code;
  const LeaveStatus(this.label, this.code);
}

class LeaveRequestModel {
  final String id;
  final String studentId;
  final String studentName;
  final String className;
  final LeaveType type;
  final DateTime startDate;
  final DateTime endDate;
  final String reason;
  final String? attachmentUrl;
  final LeaveStatus status;
  final String? approvedBy;
  final String? teacherNotes;
  final DateTime createdAt;

  const LeaveRequestModel({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.className,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.reason,
    this.attachmentUrl,
    required this.status,
    this.approvedBy,
    this.teacherNotes,
    required this.createdAt,
  });

  int get durationDays {
    final diff = endDate.difference(startDate).inDays;
    return diff < 0 ? 1 : diff + 1;
  }

  factory LeaveRequestModel.fromJson(Map<String, dynamic> json) {
    LeaveType parseType(String? val) {
      return LeaveType.values.firstWhere(
        (e) => e.name == val || e.shortCode == val || e.label == val,
        orElse: () => LeaveType.sick,
      );
    }

    LeaveStatus parseStatus(String? val) {
      return LeaveStatus.values.firstWhere(
        (e) => e.code == val || e.name == val,
        orElse: () => LeaveStatus.pending,
      );
    }

    return LeaveRequestModel(
      id: json['id'] as String? ?? '',
      studentId: json['studentId'] as String? ?? '',
      studentName: json['studentName'] as String? ?? 'Siswa',
      className: json['className'] as String? ?? 'Kelas XII',
      type: parseType(json['type'] as String?),
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'] as String)
          : DateTime.now(),
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'] as String)
          : DateTime.now(),
      reason: json['reason'] as String? ?? '',
      attachmentUrl: json['attachmentUrl'] as String?,
      status: parseStatus(json['status'] as String?),
      approvedBy: json['approvedBy'] as String?,
      teacherNotes: json['teacherNotes'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'studentName': studentName,
      'className': className,
      'type': type.name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'reason': reason,
      'attachmentUrl': attachmentUrl,
      'status': status.code,
      'approvedBy': approvedBy,
      'teacherNotes': teacherNotes,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

