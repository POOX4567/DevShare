import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/backend/backend_config.dart';
import 'post.dart';
import 'youtube_link.dart';

class PostsRepository {
  SupabaseClient get _db => BackendConfig.client;
  Future<List<Post>> list({int limit=30,int offset=0}) async {
    final rows=await _db.from('posts').select('*, profiles!posts_author_id_fkey(display_name, avatar_path)').order('created_at',ascending:false).range(offset,offset+limit-1);
    return rows.map((row){final p=row['profiles'] as Map<String,dynamic>?;return Post.fromMap({...row,'author_name':p?['display_name'],'author_avatar':p?['avatar_path']});}).toList();
  }
  Stream<List<Map<String,dynamic>>> watch() => _db.from('posts').stream(primaryKey:['id']).order('created_at',ascending:false);
  Future<Post> create({required String body,String? youtubeUrl,bool isLive=false,String? mediaPath}) async {
    final url=youtubeUrl?.trim();
    if(url!=null && url.isNotEmpty && YoutubeLink.parse(url)==null) throw ArgumentError('El enlace de YouTube no es válido.');
    final row=await _db.from('posts').insert({'author_id':_db.auth.currentUser!.id,'body':body.trim(),'youtube_url':url,'is_live':isLive,'media_path':mediaPath}).select().single();
    return Post.fromMap(row);
  }
  Future<Post> update(String id,{required String body,String? youtubeUrl,bool isLive=false,String? mediaPath}) async {
    final url=youtubeUrl?.trim();
    if(url!=null && url.isNotEmpty && YoutubeLink.parse(url)==null) throw ArgumentError('El enlace de YouTube no es válido.');
    final row=await _db.from('posts').update({'body':body.trim(),'youtube_url':url,'is_live':isLive,'media_path':mediaPath}).eq('id',id).select().single();
    return Post.fromMap(row);
  }
  Future<void> delete(String id) async => _db.from('posts').delete().eq('id',id);
  Future<String> uploadMedia(Uint8List bytes,{required String fileName,required String userId}) async {
    final name='${DateTime.now().toUtc().millisecondsSinceEpoch}_$fileName';
    final path='$userId/$name';
    await _db.storage.from('post-media').uploadBinary(path,bytes);
    return path;
  }
  String mediaUrl(String path)=>_db.storage.from('post-media').getPublicUrl(path);
  Future<void> setLiked(String postId,bool liked) async {
    final uid=_db.auth.currentUser!.id;
    if(liked){await _db.from('post_likes').upsert({'post_id':postId,'user_id':uid});}
    else {await _db.from('post_likes').delete().eq('post_id',postId).eq('user_id',uid);}
  }
  Future<void> comment(String postId,String body) async => _db.from('comments').insert({'post_id':postId,'body':body.trim()});
  Future<List<Map<String,dynamic>>> comments(String postId) async => _db.from('comments').select('*, profiles(display_name,avatar_path)').eq('post_id',postId).order('created_at');
  Future<void> deleteComment(String id) async => _db.from('comments').delete().eq('id',id);
  Future<int> likeCount(String postId) async => (await _db.from('post_likes').select('user_id').eq('post_id',postId)).length;
  Future<bool> isLikedByMe(String postId) async => (await _db.from('post_likes').select('user_id').eq('post_id',postId).eq('user_id',_db.auth.currentUser!.id).maybeSingle()) != null;
}
