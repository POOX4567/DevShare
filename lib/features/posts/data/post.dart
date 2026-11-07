class Post {
  const Post({
    required this.id,
    required this.authorId,
    required this.body,
    this.mediaPath,
    this.youtubeUrl,
    this.projectTitle,
    this.projectUrl,
    this.isLive = false,
    this.createdAt,
    this.authorName,
    this.authorAvatar,
  });
  final String id, authorId, body;
  final String? mediaPath,
      youtubeUrl,
      projectTitle,
      projectUrl,
      authorName,
      authorAvatar;
  final bool isLive;
  final DateTime? createdAt;
  factory Post.fromMap(Map<String, dynamic> row) => Post(
    id: row['id'] as String,
    authorId: row['author_id'] as String,
    body: row['body'] as String? ?? '',
    mediaPath: row['media_path'] as String?,
    youtubeUrl: row['youtube_url'] as String?,
    projectTitle: row['project_title'] as String?,
    projectUrl: row['project_url'] as String?,
    isLive: row['is_live'] as bool? ?? false,
    createdAt: DateTime.tryParse(row['created_at'] as String? ?? ''),
    authorName: row['author_name'] as String?,
    authorAvatar: row['author_avatar'] as String?,
  );
  Map<String, dynamic> toInsertMap() => {
    'body': body,
    'media_path': mediaPath,
    'youtube_url': youtubeUrl,
    'project_title': projectTitle,
    'project_url': projectUrl,
    'is_live': isLive,
  };
  Map<String, dynamic> toUpdateMap() => {
    'body': body,
    'media_path': mediaPath,
    'youtube_url': youtubeUrl,
    'project_title': projectTitle,
    'project_url': projectUrl,
    'is_live': isLive,
  };
}
