enum UserRole {
  admin,
  teacher,
  student,
  parent;

  static UserRole fromString(String role) {
    switch (role.toUpperCase()) {
      case 'ADMIN':
        return UserRole.admin;
      case 'TEACHER':
        return UserRole.teacher;
      case 'STUDENT':
        return UserRole.student;
      case 'PARENT':
        return UserRole.parent;
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
  });

  String get fullName => '$firstName $lastName'.trim();

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      role: UserRole.fromString(json['role'] ?? 'STUDENT'),
      phoneNumber: json['phoneNumber'],
      avatarUrl: json['avatarUrl'],
      schoolName: json['school']?['name'] ?? json['schoolName'] ?? 'SMA Quick Schools Unggulan',
      identifierNumber: json['identifierNumber'] ?? json['nisn'] ?? json['nip'],
      className: json['classRoom']?['name'] ?? json['className'],
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
    };
  }
}
