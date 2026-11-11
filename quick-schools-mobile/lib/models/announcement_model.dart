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
    final authorMap = json['author'] is Map ? json['author'] as Map : null;
    String author = 'Tata Usaha / Kepala Sekolah';
    if (authorMap != null) {
      if (authorMap['name'] != null) {
        author = authorMap['name'].toString();
      } else {
        author =
            '${authorMap['firstName'] ?? ''} ${authorMap['lastName'] ?? ''}'
                .trim();
      }
    } else if (json['authorName'] != null) {
      author = json['authorName'].toString();
    }

    final isPinned = json['isPinned'] == true;
    final priority =
        (json['priority'] ?? (isPinned ? 'URGENT' : 'NORMAL')).toString();

    return AnnouncementModel(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      content: (json['content'] ?? '').toString(),
      targetRole: json['targetRole']?.toString(),
      priority: priority,
      authorName: author.isEmpty ? 'Administrator Sekolah' : author,
      publishedAt: DateTime.tryParse(
            (json['publishedAt'] ?? json['createdAt'] ?? '').toString(),
          ) ??
          DateTime.now(),
      isPinned: isPinned,
    );
  }
}
