enum UserRole {
  admin,
  teacher,
  student,
  parent;

  static UserRole fromString(String role) {
    final normalized = role.toUpperCase().replaceAll('-', '_');
    switch (normalized) {
      case 'ADMIN':
      case 'SUPER_ADMIN':
      case 'SAAS_ADMIN':
        return UserRole.admin;
      case 'TEACHER':
      case 'GURU':
      case 'KEPALA_SEKOLAH':
        return UserRole.teacher;
      case 'PARENT':
      case 'ORANG_TUA':
        return UserRole.parent;
      case 'STUDENT':
      case 'SISWA':
      default:
        return UserRole.student;
    }
  }

  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'Administrator';
      case UserRole.teacher:
        return 'Guru / Tenaga Pengajar';
      case UserRole.student:
        return 'Siswa';
      case UserRole.parent:
        return 'Orang Tua / Wali';
    }
  }

  String toPrismaString() {
    switch (this) {
      case UserRole.admin:
        return 'ADMIN';
      case UserRole.teacher:
        return 'TEACHER';
      case UserRole.student:
        return 'STUDENT';
      case UserRole.parent:
        return 'PARENT';
    }
  }

  String toIndonesianApiRole() {
    switch (this) {
      case UserRole.admin:
        return 'admin';
      case UserRole.teacher:
        return 'guru';
      case UserRole.student:
        return 'siswa';
      case UserRole.parent:
        return 'orang-tua';
    }
  }
}

class UserModel {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final UserRole role;
  final String? phoneNumber;
  final String? avatarUrl;
  final String? schoolName;
  final String? identifierNumber; // NISN for student, NIP for teacher
  final String? className;
  final String? studentId;
  final String? teacherId;
  final String? parentId;
  final String? classId;

  UserModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    this.phoneNumber,
    this.avatarUrl,
    this.schoolName,
    this.identifierNumber,
    this.className,
    this.studentId,
    this.teacherId,
    this.parentId,
    this.classId,
  });

  String get fullName => '$firstName $lastName'.trim();

  factory UserModel.fromJson(Map<String, dynamic> json) {
    String first = (json['firstName'] ?? '').toString().trim();
    String last = (json['lastName'] ?? '').toString().trim();

    if (first.isEmpty) {
      final rawName =
          (json['fullName'] ?? json['name'] ?? 'Pengguna').toString().trim();
      final parts = rawName.split(RegExp(r'\s+'));
      first = parts.isNotEmpty ? parts.first : rawName;
      last = parts.length > 1 ? parts.sublist(1).join(' ') : '';
    }

    final schoolMap = json['school'] is Map ? json['school'] as Map : null;
    final classMap =
        json['classRoom'] is Map ? json['classRoom'] as Map : null;
    final rawPhone = json['phoneNumber'] ?? json['phone'];
    final cleanPhone =
        (rawPhone != null && rawPhone.toString().trim() != '-')
            ? rawPhone.toString().trim()
            : null;

    return UserModel(
      id: (json['id'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      firstName: first,
      lastName: last,
      role: UserRole.fromString((json['rawRole'] ?? json['role'] ?? 'STUDENT').toString()),
      phoneNumber: cleanPhone,
      avatarUrl: json['avatarUrl']?.toString(),
      schoolName: (schoolMap?['name'] ??
              json['schoolName'] ??
              'SMA Quick Schools Unggulan')
          .toString(),
      identifierNumber:
          (json['identifierNumber'] ?? json['nisn'] ?? json['nip'] ?? json['nis'])
              ?.toString(),
      className: (classMap?['name'] ??
              json['className'] ??
              json['homeroomClass'] ??
              json['childClass'])
          ?.toString(),
      studentId: json['studentId']?.toString(),
      teacherId: json['teacherId']?.toString(),
      parentId: json['parentId']?.toString(),
      classId: json['classId']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'role': role.toPrismaString(),
      'phoneNumber': phoneNumber,
      'avatarUrl': avatarUrl,
      'schoolName': schoolName,
      'identifierNumber': identifierNumber,
      'className': className,
      'studentId': studentId,
      'teacherId': teacherId,
      'parentId': parentId,
      'classId': classId,
    };
  }
}
