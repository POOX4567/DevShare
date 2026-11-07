import '../backend/backend_config.dart';

/// Supabase CRUD entry points for the app's social, learning and messaging flows.
/// All inserts rely on auth.uid() and the matching RLS policies in the migration.
class FeatureRepository {
  dynamic get _db => BackendConfig.client;

  Future<List<Map<String, dynamic>>> communities({String? category}) async {
    var query = _db.from('communities').select();
    if (category != null && category != 'Todas')
      query = query.eq('category', category);
    return query.order('created_at', ascending: false);
  }

  Future<List<Map<String, dynamic>>> communityMembers({
    String? communityId,
  }) async {
    var query = _db
        .from('community_members')
        .select(
          'community_id, user_id, role, created_at, '
          'profiles!community_members_user_id_fkey(display_name, avatar_path)',
        );
    if (communityId != null) {
      query = query.eq('community_id', communityId);
    }
    return query.order('created_at', ascending: true);
  }

  Future<void> createCommunity({
    required String name,
    required String description,
    required String category,
  }) async => _db.from('communities').insert({
    'name': name,
    'description': description,
    'category': category,
    'owner_id': _db.auth.currentUser!.id,
  });
  Future<void> updateCommunity(String id, Map<String, dynamic> values) async =>
      _db.from('communities').update(values).eq('id', id);
  Future<void> deleteCommunity(String id) async =>
      _db.from('communities').delete().eq('id', id);
  Future<void> joinCommunity(String id) async => _db
      .from('community_members')
      .upsert({'community_id': id, 'user_id': _db.auth.currentUser!.id});
  Future<void> leaveCommunity(String id) async => _db
      .from('community_members')
      .delete()
      .eq('community_id', id)
      .eq('user_id', _db.auth.currentUser!.id);

  Future<List<Map<String, dynamic>>> courses({
    bool publishedOnly = true,
  }) async {
    var query = _db.from('courses').select();
    if (publishedOnly) query = query.eq('is_published', true);
    return query.order('created_at', ascending: false);
  }

  Future<void> createCourse(Map<String, dynamic> values) async => _db
      .from('courses')
      .insert({...values, 'instructor_id': _db.auth.currentUser!.id});
  Future<void> updateCourse(String id, Map<String, dynamic> values) async =>
      _db.from('courses').update(values).eq('id', id);
  Future<void> deleteCourse(String id) async =>
      _db.from('courses').delete().eq('id', id);
  Future<void> setCourseProgress(String courseId, double progress) async =>
      _db.from('course_progress').upsert({
        'course_id': courseId,
        'user_id': _db.auth.currentUser!.id,
        'progress': progress.clamp(0, 1),
      });
  Future<List<Map<String, dynamic>>> myCourseProgress() async => _db
      .from('course_progress')
      .select('*, courses(*)')
      .eq('user_id', _db.auth.currentUser!.id);

  Future<Map<String, dynamic>> myProfile() async {
    final user = _db.auth.currentUser!;
    final existing = await _db
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();
    if (existing != null) return existing;
    final displayName = user.userMetadata?['display_name']?.toString() ?? '';
    return _db
        .from('profiles')
        .upsert({
          'id': user.id,
          'display_name': displayName.isNotEmpty
              ? displayName
              : (user.email ?? 'DevShare'),
        })
        .select()
        .single();
  }

  Future<void> updateProfile(Map<String, dynamic> values) async => _db
      .from('profiles')
      .update({
        ...values,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      })
      .eq('id', _db.auth.currentUser!.id);
  Future<List<Map<String, dynamic>>> friends() async => _db
      .from('friendships')
      .select('*, profiles!friendships_friend_id_fkey(*)')
      .eq('user_id', _db.auth.currentUser!.id);
  Future<void> addFriend(String friendId) async => _db
      .from('friendships')
      .upsert({'user_id': _db.auth.currentUser!.id, 'friend_id': friendId});
  Future<void> removeFriend(String friendId) async => _db
      .from('friendships')
      .delete()
      .eq('user_id', _db.auth.currentUser!.id)
      .eq('friend_id', friendId);

  Future<List<Map<String, dynamic>>> myConversations() async => _db
      .from('conversation_members')
      .select(
        'conversation_id, conversations(*, messages(*, profiles(display_name, avatar_path)))',
      )
      .eq('user_id', _db.auth.currentUser!.id);
  Future<String> startConversation(String otherUserId) async {
    return (await _db.rpc(
          'create_conversation',
          params: {'other_user': otherUserId},
        ))
        as String;
  }

  Future<List<Map<String, dynamic>>> messages(String conversationId) async =>
      _db
          .from('messages')
          .select('*, profiles(display_name, avatar_path)')
          .eq('conversation_id', conversationId)
          .order('created_at');
  Future<void> sendMessage(String conversationId, String body) async =>
      _db.from('messages').insert({
        'conversation_id': conversationId,
        'sender_id': _db.auth.currentUser!.id,
        'body': body.trim(),
      });
  Future<void> deleteMessage(String id) async =>
      _db.from('messages').delete().eq('id', id);
  Stream<List<Map<String, dynamic>>> watchMessages(String conversationId) => _db
      .from('messages')
      .stream(primaryKey: ['id'])
      .eq('conversation_id', conversationId)
      .order('created_at');
  Future<List<Map<String, dynamic>>> events() async =>
      _db.from('events').select().order('starts_at');
  Future<void> rsvp(String eventId) async => _db.from('event_attendees').upsert(
    {'event_id': eventId, 'user_id': _db.auth.currentUser!.id},
  );
  Future<List<Map<String, dynamic>>> activity({int limit = 40}) async => _db
      .from('activities')
      .select()
      .eq('user_id', _db.auth.currentUser!.id)
      .order('created_at', ascending: false)
      .limit(limit);
  Future<void> recordActivity(
    String type, {
    String? entityId,
    Map<String, dynamic> payload = const {},
  }) async => _db.from('activities').insert({
    'user_id': _db.auth.currentUser!.id,
    'type': type,
    'entity_id': entityId,
    'payload': payload,
  });
}
