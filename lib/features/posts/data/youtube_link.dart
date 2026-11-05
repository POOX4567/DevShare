class YoutubeLink {
  const YoutubeLink._(this.videoId);
  final String videoId;
  static YoutubeLink? parse(String raw) {
    final uri = Uri.tryParse(raw.trim());
    if (uri == null) return null;
    String? id;
    if (uri.host == 'youtu.be') id = uri.pathSegments.firstOrNull;
    if (uri.host.endsWith('youtube.com')) {
      id = uri.queryParameters['v'];
      if (id == null && uri.pathSegments.length >= 2 &&
          ['shorts','live','embed'].contains(uri.pathSegments.first)) id = uri.pathSegments[1];
    }
    if (id == null || !RegExp(r'^[A-Za-z0-9_-]{11}$').hasMatch(id)) return null;
    return YoutubeLink._(id);
  }
  String get embedUrl => 'https://www.youtube.com/embed/$videoId';
  String get thumbnailUrl => 'https://img.youtube.com/vi/$videoId/hqdefault.jpg';
}
