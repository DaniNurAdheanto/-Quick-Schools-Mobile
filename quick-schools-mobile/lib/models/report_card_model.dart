class SubjectGrade {
  final String subjectName;
  final String subjectCode;
  final String category; // Kelompok A (Wajib), Kelompok B (Umum), Kelompok C (Peminatan)
  final double kkm;
  final double knowledgeScore;
  final String knowledgeLetter;
  final double skillScore;
  final String skillLetter;
  final String competencyDescription;

  const SubjectGrade({
    required this.subjectName,
    required this.subjectCode,
    required this.category,
    required this.kkm,
    required this.knowledgeScore,
    required this.knowledgeLetter,
    required this.skillScore,
    required this.skillLetter,
    required this.competencyDescription,
  });

  double get finalScore => (knowledgeScore + skillScore) / 2.0;
  bool get isPassed => finalScore >= kkm;
}

class ExtracurricularScore {
  final String name;
  final String grade; // A, B, C
  final String description;

  const ExtracurricularScore({
    required this.name,
    required this.grade,
    required this.description,
  });
}

class ReportCardModel {
  final String id;
  final String semester; // Semester 1 (Ganjil) / Semester 2 (Genap)
  final String academicYear; // 2026/2027
  final String studentName;
  final String nisn;
  final String className;
  final String homeroomTeacher;
  final double gpa;
  final int classRank;
  final int totalStudentsInClass;
  final List<SubjectGrade> subjectGrades;
  final List<ExtracurricularScore> extracurriculars;
  final int presentDays;
  final int sickDays;
  final int permissionDays;
  final int unexcusedDays;
  final String teacherNotes;
  final String headmasterName;
  final String headmasterNip;

  const ReportCardModel({
    required this.id,
    required this.semester,
    required this.academicYear,
    required this.studentName,
    required this.nisn,
    required this.className,
    required this.homeroomTeacher,
    required this.gpa,
    required this.classRank,
    required this.totalStudentsInClass,
    required this.subjectGrades,
    required this.extracurriculars,
    required this.presentDays,
    required this.sickDays,
    required this.permissionDays,
    required this.unexcusedDays,
    required this.teacherNotes,
    required this.headmasterName,
    required this.headmasterNip,
  });

  double get overallAverage {
    if (subjectGrades.isEmpty) return 0.0;
    final total = subjectGrades.fold<double>(
      0.0,
      (sum, s) => sum + s.finalScore,
    );
    return total / subjectGrades.length;
  }
}

