enum CalendarEventType {
  exam('Ujian & Evaluasi', 0xFF4F46E5),
  holiday('Libur & Cuti', 0xFFDC2626),
  academic('Kegiatan Akademik', 0xFF0284C7),
  extracurricular('Kesiswaan & Lomba', 0xFF16A34A),
  report('Rapor & Kelulusan', 0xFFD97706);

  final String label;
  final int colorHex;
  const CalendarEventType(this.label, this.colorHex);
}

class AcademicCalendarEvent {
  final String id;
  final String title;
  final String description;
  final CalendarEventType type;
  final DateTime startDate;
  final DateTime endDate;
  final bool isNationalHoliday;

  const AcademicCalendarEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.startDate,
    required this.endDate,
    this.isNationalHoliday = false,
  });

  bool occursOn(DateTime date) {
    final target = DateTime(date.year, date.month, date.day);
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day);
    return (target.isAtSameMomentAs(start) || target.isAfter(start)) &&
        (target.isAtSameMomentAs(end) || target.isBefore(end));
  }
}

