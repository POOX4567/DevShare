import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/backend/backend_config.dart';
import 'post.dart';
import 'youtube_link.dart';

class PostsRepository {
  SupabaseClient get _db => BackendConfig.client;
  Future<List<Post>> list({int limit = 30, int offset = 0}) async {
    final rows = await _db
        .from('posts')
        .select('*, profiles!posts_author_id_fkey(display_name, avatar_path)')
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);
    return rows.map((row) {
      final p = row['profiles'] as Map<String, dynamic>?;
      return Post.fromMap({
        ...row,
        'author_name': p?['display_name'],
        'author_avatar': p?['avatar_path'],
      });
    }).toList();
  }

  Stream<List<Map<String, dynamic>>> watch() => _db
      .from('posts')
      .stream(primaryKey: ['id'])
      .order('created_at', ascending: false);
  Future<Post> create({
    required String body,
    String? youtubeUrl,
    bool isLive = false,
    String? mediaPath,
    String? projectTitle,
    String? projectUrl,
  }) async {
    final url = youtubeUrl?.trim();
    if (url != null && url.isNotEmpty && YoutubeLink.parse(url) == null)
      throw ArgumentError('El enlace de YouTube no es válido.');
    _validateProjectUrl(projectUrl);
    final user = _db.auth.currentUser;
    if (user == null) throw StateError('Inicia sesión para publicar.');
    final values = <String, dynamic>{
      'author_id': user.id,
      'body': body.trim(),
      'youtube_url': url,
      'is_live': isLive,
      'media_path': mediaPath,
    };
    if (_emptyToNull(projectTitle) != null ||
        _emptyToNull(projectUrl) != null) {
      values['project_title'] = _emptyToNull(projectTitle);
      values['project_url'] = _emptyToNull(projectUrl);
    }
    final row = await _db.from('posts').insert(values).select().single();
    return Post.fromMap(row);
  }

  Future<void> update(
    String id, {
    required String body,
    String? youtubeUrl,
    bool isLive = false,
    String? mediaPath,
    String? projectTitle,
    String? projectUrl,
    bool clearProject = false,
  }) async {
    final url = youtubeUrl?.trim();
    if (url != null && url.isNotEmpty && YoutubeLink.parse(url) == null)
      throw ArgumentError('El enlace de YouTube no es válido.');
    _validateProjectUrl(projectUrl);
    final values = <String, dynamic>{
      'body': body.trim(),
      'youtube_url': url,
      'is_live': isLive,
      'media_path': mediaPath,
    };
    if (clearProject ||
        _emptyToNull(projectTitle) != null ||
        _emptyToNull(projectUrl) != null) {
      values['project_title'] = _emptyToNull(projectTitle);
      values['project_url'] = _emptyToNull(projectUrl);
    }
    await _db.from('posts').update(values).eq('id', id);
    final saved = await _db
        .from('posts')
        .select('id, body, youtube_url, is_live, media_path')
        .eq('id', id)
        .maybeSingle();
    if (saved == null ||
        saved['body'] != values['body'] ||
        saved['youtube_url'] != values['youtube_url'] ||
        saved['is_live'] != values['is_live'] ||
        saved['media_path'] != values['media_path']) {
      throw StateError(
        'Supabase no confirmó los cambios. Revisa las políticas RLS de posts.',
      );
    }
    if (values.containsKey('project_url') &&
        (saved['project_url'] != values['project_url'] ||
            saved['project_title'] != values['project_title'])) {
      final project = await _db
          .from('posts')
          .select('project_title, project_url')
          .eq('id', id)
          .single();
      if (project['project_url'] != values['project_url'] ||
          project['project_title'] != values['project_title']) {
        throw StateError('Supabase no confirmó los datos del proyecto.');
      }
    }
  }

  Future<void> delete(String id, {String? mediaPath}) async {
    await _db.from('posts').delete().eq('id', id);
    final remaining = await _db
        .from('posts')
        .select('id')
        .eq('id', id)
        .maybeSingle();
    if (remaining != null) {
      throw StateError(
        'Supabase no eliminó la publicación. Revisa las políticas RLS de posts.',
      );
    }
    if (mediaPath != null && mediaPath.isNotEmpty) {
      try {
        await _db.storage.from('post-media').remove([mediaPath]);
      } catch (_) {
        // El post ya se eliminó; un fallo de limpieza no debe deshacerlo.
      }
    }
  }

  Future<String> uploadMedia(
    Uint8List bytes, {
    required String fileName,
    required String userId,
  }) async {
    final safeName = fileName.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
    final name = '${DateTime.now().toUtc().microsecondsSinceEpoch}_$safeName';
    final path = '$userId/$name';
    final extension = safeName.contains('.') ? safeName.split('.').last : '';
    final contentType = switch (extension.toLowerCase()) {
      'png' => 'image/png',
      'webp' => 'image/webp',
      'gif' => 'image/gif',
      _ => 'image/jpeg',
    };
    await _db.storage
        .from('post-media')
        .uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(contentType: contentType, upsert: false),
        );
    return path;
  }

  Future<void> removeMedia(String path) async =>
      _db.storage.from('post-media').remove([path]);

  static String? _emptyToNull(String? value) {
    final clean = value?.trim();
    return clean == null || clean.isEmpty ? null : clean;
  }

  static void _validateProjectUrl(String? value) {
    final clean = _emptyToNull(value);
    if (clean == null) return;
    final uri = Uri.tryParse(clean);
    if (uri == null ||
        !const ['http', 'https'].contains(uri.scheme) ||
        !uri.host.contains('.')) {
      throw ArgumentError('El enlace del proyecto debe ser una URL completa.');
    }
  }

  String mediaUrl(String path) =>
      _db.storage.from('post-media').getPublicUrl(path);
  Future<void> setLiked(String postId, bool liked) async {
    final uid = _db.auth.currentUser!.id;
    if (liked) {
      await _db.from('post_likes').upsert({'post_id': postId, 'user_id': uid});
    } else {
      await _db
          .from('post_likes')
          .delete()
          .eq('post_id', postId)
          .eq('user_id', uid);
    }
  }

  Future<void> comment(String postId, String body) async =>
      _db.from('comments').insert({'post_id': postId, 'body': body.trim()});
  Future<List<Map<String, dynamic>>> comments(String postId) async => _db
      .from('comments')
      .select('*, profiles(display_name,avatar_path)')
      .eq('post_id', postId)
      .order('created_at', ascending: false);
  Future<void> deleteComment(String id) async =>
      _db.from('comments').delete().eq('id', id);
  Future<int> likeCount(String postId) async =>
      (await _db.from('post_likes').select('user_id').eq('post_id', postId))
          .length;
  Future<bool> isLikedByMe(String postId) async =>
      (await _db
          .from('post_likes')
          .select('user_id')
          .eq('post_id', postId)
          .eq('user_id', _db.auth.currentUser!.id)
          .maybeSingle()) !=
      null;
}
