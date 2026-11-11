class AnnouncementModel {
  final String id;
  final String title;
  final String content;
  final String? targetRole;
  final String priority;
  final String authorName;
  final DateTime publishedAt;
  final bool isPinned;

  AnnouncementModel({
    required this.id,
    required this.title,
    required this.content,
    this.targetRole,
    this.priority = 'NORMAL',
    required this.authorName,
    required this.publishedAt,
    this.isPinned = false,
  });

  bool get isUrgent => priority == 'URGENT';

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      targetRole: json['targetRole'],
      priority: json['priority'] ?? 'NORMAL',
      authorName: json['author'] != null
          ? '${json['author']['firstName']} ${json['author']['lastName']}'
          : json['authorName'] ?? 'Tata Usaha / Kepala Sekolah',
      publishedAt: DateTime.tryParse(json['publishedAt'] ?? '') ?? DateTime.now(),
      isPinned: json['isPinned'] ?? false,
    );
  }
}
