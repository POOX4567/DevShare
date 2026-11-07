import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/app_theme.dart';
import '../../core/backend/backend_config.dart';
import '../posts/data/post.dart';
import '../posts/data/posts_repository.dart';
import '../posts/widgets/post_composer_dialog.dart';
import '../posts/widgets/youtube_video_card.dart';

class HomeFeed extends StatefulWidget {
  const HomeFeed({super.key, required this.onNavigate});

  final ValueChanged<int> onNavigate;

  @override
  State<HomeFeed> createState() => _HomeFeedState();
}

class _HomeFeedState extends State<HomeFeed> {
  final _posts = PostsRepository();
  int _refresh = 0;
  void _message(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(text),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF1C344B),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  Future<void> _composePost() async {
    final draft = await showPostComposer(context);
    if (draft == null) return;
    String? uploadedPath;
    try {
      if (draft.imageBytes != null) {
        final user = BackendConfig.client.auth.currentUser;
        if (user == null) throw StateError('Inicia sesión para publicar.');
        uploadedPath = await _posts.uploadMedia(
          draft.imageBytes!,
          fileName: draft.imageName ?? 'post.jpg',
          userId: user.id,
        );
      }
      await _posts.create(
        body: draft.body,
        youtubeUrl: draft.youtubeUrl,
        isLive: draft.isLive,
        mediaPath: uploadedPath,
        projectTitle: draft.projectTitle,
        projectUrl: draft.projectUrl,
      );
      if (mounted) {
        setState(() => _refresh++);
        _message('Publicación guardada.');
      }
    } catch (error) {
      if (uploadedPath != null) {
        try {
          await _posts.removeMedia(uploadedPath);
        } catch (_) {}
      }
      if (mounted) _message('No se pudo publicar: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Column(
              children: [
                const _TopBar(),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(10, 2, 10, 20),
                    children: [
                      _Composer(
                        onAction: (_) => BackendConfig.isConfigured
                            ? _composePost()
                            : _message('Conecta Supabase para publicar.'),
                      ),
                      const SizedBox(height: 12),
                      if (BackendConfig.isConfigured)
                        _BackendPosts(
                          key: ValueKey(_refresh),
                          repository: _posts,
                          currentUserId:
                              BackendConfig.client.auth.currentUser?.id,
                        ),
                      if (BackendConfig.isConfigured)
                        const SizedBox(height: 12),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _GlowFab(
        onPressed: BackendConfig.isConfigured
            ? _composePost
            : () => _message('Conecta Supabase para publicar.'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: _BottomNavigation(
        onTap: (label) {
          if (label != 'Inicio') {
            widget.onNavigate(_BottomNavigation.labels.indexOf(label));
          }
        },
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 54,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              'DevShare.png',
              width: 28,
              height: 28,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DevShare',
                  style: TextStyle(
                    fontSize: 16,
                    height: 1,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'INICIO',
                  style: TextStyle(
                    fontSize: 9,
                    height: 1,
                    letterSpacing: 1.1,
                    color: AppColors.cyan,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _Composer extends StatelessWidget {
  const _Composer({required this.onAction});

  final ValueChanged<String> onAction;

  static const actions = <(String, IconData, Color)>[
    ('Código', Icons.code_rounded, Color(0xFFD7A6FF)),
    ('Imagen', Icons.image_outlined, AppColors.cyan),
    ('Proyecto', Icons.view_in_ar_outlined, Color(0xFFB6C8FF)),
  ];

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(11),
    decoration: BoxDecoration(
      color: AppColors.panel,
      borderRadius: BorderRadius.circular(15),
      boxShadow: const [
        BoxShadow(color: Colors.black26, blurRadius: 9, offset: Offset(0, 3)),
      ],
    ),
    child: Column(
      children: [
        InkWell(
          onTap: () => onAction('El compositor de publicaciones'),
          borderRadius: BorderRadius.circular(11),
          child: Container(
            height: 49,
            padding: const EdgeInsets.symmetric(horizontal: 11),
            decoration: BoxDecoration(
              color: const Color(0xFF13283D),
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Row(
              children: [
                _Avatar(initials: '', size: 29),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Comparte una idea, imagen, video o proyecto…',
                    maxLines: 2,
                    style: TextStyle(
                      fontSize: 11,
                      height: 1.3,
                      color: Color(0xFFD8E2ED),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            for (final item in actions)
              Expanded(
                child: _ComposerAction(
                  label: item.$1,
                  icon: item.$2,
                  color: item.$3,
                  onTap: () => onAction(item.$1),
                ),
              ),
          ],
        ),
      ],
    ),
  );
}

class _ComposerAction extends StatelessWidget {
  const _ComposerAction({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(8),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        children: [
          Icon(icon, size: 17, color: color),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    ),
  );
}

class _PostCard extends StatelessWidget {
  const _PostCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppColors.panel,
      borderRadius: BorderRadius.circular(16),
      boxShadow: const [
        BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 3)),
      ],
    ),
    child: child,
  );
}

class _ProjectAttachment extends StatelessWidget {
  const _ProjectAttachment({required this.title, required this.url});
  final String title;
  final String url;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 9),
    child: Material(
      color: const Color(0xFF10263A),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          final uri = Uri.tryParse(url);
          if (uri == null ||
              !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('No se pudo abrir el enlace del proyecto.'),
                ),
              );
            }
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              const Icon(Icons.developer_mode, color: AppColors.cyan),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      url,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFFB9C7D6),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.open_in_new, size: 17, color: AppColors.cyan),
            ],
          ),
        ),
      ),
    ),
  );
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.initials, required this.size});
  final String initials;
  final double size;
  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: const Color(0xFF1D4160),
      border: Border.all(color: const Color(0xFF6E9BB7).withValues(alpha: .45)),
    ),
    child: Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF345675), Color(0xFF101E32)],
        ),
      ),
      alignment: Alignment.center,
      child: initials.isEmpty
          ? const Icon(Icons.person_outline, size: 18, color: Colors.white)
          : Text(
              initials,
              maxLines: 1,
              style: TextStyle(
                fontSize: size * (initials.length > 2 ? .27 : .32),
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
    ),
  );
}

class _GlowFab extends StatelessWidget {
  const _GlowFab({required this.onPressed});
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) => Container(
    width: 54,
    height: 54,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF7867FF), AppColors.violet, AppColors.blue],
      ),
      boxShadow: [
        BoxShadow(
          color: AppColors.violet.withValues(alpha: .55),
          blurRadius: 20,
          spreadRadius: 1,
        ),
      ],
    ),
    child: IconButton(
      tooltip: 'Crear publicación',
      onPressed: onPressed,
      icon: const Icon(Icons.add_rounded, size: 30, color: Colors.white),
    ),
  );
}

class _BottomNavigation extends StatelessWidget {
  const _BottomNavigation({required this.onTap});
  final ValueChanged<String> onTap;

  static const labels = [
    'Inicio',
    'Comunidades',
    'Cursos',
    'Mensajes',
    'Perfil',
  ];
  static const items = <(String, IconData)>[
    ('Inicio', Icons.terminal_rounded),
    ('Comunidades', Icons.forum_outlined),
    ('Cursos', Icons.play_circle_outline_rounded),
    ('Mensajes', Icons.chat_bubble_outline_rounded),
    ('Perfil', Icons.code_rounded),
  ];

  @override
  Widget build(BuildContext context) => Container(
    height: 61,
    decoration: const BoxDecoration(
      color: Color(0xFF071422),
      border: Border(top: BorderSide(color: Color(0xFF14283B))),
    ),
    child: SafeArea(
      top: false,
      child: Row(
        children: [
          for (var i = 0; i < items.length; i++)
            Expanded(
              child: InkWell(
                onTap: () => onTap(items[i].$1),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      items[i].$2,
                      size: 18,
                      color: i == 0
                          ? const Color(0xFFD9B7FF)
                          : const Color(0xFFA7B7C8),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      items[i].$1,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 8,
                        color: i == 0
                            ? const Color(0xFFE0C8FF)
                            : const Color(0xFFC0CCDA),
                        fontWeight: i == 0 ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    ),
  );
}

class _BackendPosts extends StatefulWidget {
  const _BackendPosts({
    super.key,
    required this.repository,
    required this.currentUserId,
  });
  final PostsRepository repository;
  final String? currentUserId;
  @override
  State<_BackendPosts> createState() => _BackendPostsState();
}

class _BackendPostsState extends State<_BackendPosts> {
  late Future<List<Post>> _items;
  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() => _items = widget.repository.list();
  Future<void> _comment(Post post) async {
    final controller = TextEditingController();
    final save = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Comentar'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Escribe un comentario'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
    if (save == true && controller.text.trim().isNotEmpty) {
      try {
        await widget.repository.comment(post.id, controller.text);
        if (mounted) _notify('Comentario enviado.');
      } catch (error) {
        if (mounted) _notify('No se pudo comentar: $error');
      }
    }
    controller.dispose();
  }

  Future<void> _editPost(Post post) async {
    final draft = await showPostComposer(context, post: post);
    if (draft == null) return;
    String? uploadedPath;
    try {
      if (draft.imageBytes != null) {
        final user = BackendConfig.client.auth.currentUser;
        if (user == null) throw StateError('Inicia sesión para editar.');
        uploadedPath = await widget.repository.uploadMedia(
          draft.imageBytes!,
          fileName: draft.imageName ?? 'post.jpg',
          userId: user.id,
        );
      }
      final nextPath = draft.imageBytes != null
          ? uploadedPath
          : (draft.keepExistingImage ? post.mediaPath : null);
      await widget.repository.update(
        post.id,
        body: draft.body,
        youtubeUrl: draft.youtubeUrl,
        isLive: draft.isLive,
        mediaPath: nextPath,
        projectTitle: draft.projectTitle,
        projectUrl: draft.projectUrl,
        clearProject: post.projectTitle != null || post.projectUrl != null,
      );
      if (post.mediaPath != null && post.mediaPath != nextPath) {
        try {
          await widget.repository.removeMedia(post.mediaPath!);
        } catch (_) {}
      }
      if (mounted) {
        final edited = Post(
          id: post.id,
          authorId: post.authorId,
          body: draft.body,
          mediaPath: nextPath,
          youtubeUrl: draft.youtubeUrl,
          projectTitle: draft.projectTitle.isEmpty ? null : draft.projectTitle,
          projectUrl: draft.projectUrl,
          isLive: draft.isLive,
          createdAt: post.createdAt,
          authorName: post.authorName,
          authorAvatar: post.authorAvatar,
        );
        setState(() {
          _items = _items.then(
            (posts) => posts
                .map((item) => item.id == post.id ? edited : item)
                .toList(),
          );
        });
        _notify('Cambios guardados.');
      }
    } catch (error) {
      if (uploadedPath != null) {
        try {
          await widget.repository.removeMedia(uploadedPath);
        } catch (_) {}
      }
      if (mounted) _notify('No se pudo guardar la publicación: $error');
    }
  }

  Future<void> _deletePost(Post post) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar publicación'),
        content: const Text('Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await widget.repository.delete(post.id, mediaPath: post.mediaPath);
      if (mounted) {
        setState(() {
          _items = _items.then(
            (posts) => posts.where((item) => item.id != post.id).toList(),
          );
        });
        _notify('Publicación eliminada.');
      }
    } catch (error) {
      if (mounted) _notify('No se pudo eliminar: $error');
    }
  }

  void _notify(String message) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message)));
  @override
  Widget build(BuildContext context) => FutureBuilder<List<Post>>(
    future: _items,
    builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done)
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(15),
            child: CircularProgressIndicator(),
          ),
        );
      if (snapshot.hasError)
        return _PostCard(
          child: Text('No se pudieron cargar publicaciones: ${snapshot.error}'),
        );
      final posts = snapshot.data ?? [];
      if (posts.isEmpty) {
        return _PostCard(
          child: Column(
            children: [
              const Icon(
                Icons.dynamic_feed_outlined,
                size: 34,
                color: AppColors.cyan,
              ),
              const SizedBox(height: 9),
              const Text(
                'Aún no hay publicaciones',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              const Text(
                'Cuando compartas algo, aparecerá aquí.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFFB9C7D6)),
              ),
            ],
          ),
        );
      }
      return Column(
        children: [
          for (final post in posts)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _PostCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            post.authorName ?? 'DevShare',
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                        if (post.isLive) const Chip(label: Text('EN VIVO')),
                        if (post.authorId == widget.currentUserId)
                          PopupMenuButton<String>(
                            onSelected: (v) async {
                              if (v == 'delete') {
                                await _deletePost(post);
                              } else if (v == 'edit') {
                                await _editPost(post);
                              }
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(
                                value: 'edit',
                                child: Text('Editar'),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text('Eliminar'),
                              ),
                            ],
                          ),
                      ],
                    ),
                    if (post.body.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(post.body),
                      ),
                    if (post.youtubeUrl != null && post.youtubeUrl!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: YoutubeVideoCard(
                          url: post.youtubeUrl!,
                          isLive: post.isLive,
                        ),
                      ),
                    if (post.projectUrl != null && post.projectUrl!.isNotEmpty)
                      _ProjectAttachment(
                        title: post.projectTitle?.isNotEmpty == true
                            ? post.projectTitle!
                            : 'Ver proyecto',
                        url: post.projectUrl!,
                      ),
                    if (post.mediaPath != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            widget.repository.mediaUrl(post.mediaPath!),
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => const Padding(
                              padding: EdgeInsets.all(18),
                              child: Text(
                                'No se pudo cargar la imagen adjunta.',
                              ),
                            ),
                            loadingBuilder: (context, child, progress) =>
                                progress == null
                                ? child
                                : const SizedBox(
                                    height: 180,
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    _PostEngagement(
                      post: post,
                      repository: widget.repository,
                      onComment: () => _comment(post),
                    ),
                  ],
                ),
              ),
            ),
        ],
      );
    },
  );
}

class _PostEngagement extends StatefulWidget {
  const _PostEngagement({
    required this.post,
    required this.repository,
    required this.onComment,
  });
  final Post post;
  final PostsRepository repository;
  final Future<void> Function() onComment;
  @override
  State<_PostEngagement> createState() => _PostEngagementState();
}

class _PostEngagementState extends State<_PostEngagement> {
  int _likes = 0;
  bool _liked = false;
  List<Map<String, dynamic>> _comments = [];
  bool _loading = true;
  bool _liking = false;
  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    try {
      final results = await Future.wait<dynamic>([
        widget.repository.likeCount(widget.post.id),
        widget.repository.isLikedByMe(widget.post.id),
        widget.repository.comments(widget.post.id),
      ]);
      if (!mounted) return;
      setState(() {
        _likes = results[0] as int;
        _liked = results[1] as bool;
        _comments = results[2] as List<Map<String, dynamic>>;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _toggleLike() async {
    if (_liking) return;
    final previous = _liked;
    setState(() {
      _liking = true;
      _liked = !previous;
      _likes += previous ? -1 : 1;
    });
    try {
      await widget.repository.setLiked(widget.post.id, !previous);
    } catch (error) {
      if (mounted) {
        setState(() {
          _liked = previous;
          _likes += previous ? 1 : -1;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se guardó la reacción: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _liking = false);
    }
  }

  Future<void> _deleteComment(Map<String, dynamic> comment) async {
    final id = comment['id']?.toString();
    if (id == null) return;
    setState(() => _comments.removeWhere((item) => item['id'] == id));
    try {
      await widget.repository.deleteComment(id);
    } catch (error) {
      await _refresh();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo eliminar el comentario: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          _EngagementButton(
            icon: _liked ? Icons.favorite : Icons.favorite_border,
            color: _liked ? Colors.pinkAccent : Colors.white70,
            label: '$_likes',
            onTap: _liking ? () {} : _toggleLike,
          ),
          const SizedBox(width: 8),
          _EngagementButton(
            icon: Icons.mode_comment_outlined,
            color: AppColors.cyan,
            label: '${_comments.length}',
            onTap: () async {
              await widget.onComment();
              await _refresh();
            },
          ),
          const Spacer(),
          if (_loading)
            const SizedBox(
              width: 15,
              height: 15,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
        ],
      ),
      if (_comments.isNotEmpty) ...[
        const Divider(height: 14),
        for (final comment in _comments.take(3))
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 12,
                  child: Icon(Icons.person, size: 14),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0B1B2B),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (comment['profiles'] as Map?)?['display_name']
                                  ?.toString() ??
                              'Usuario',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          comment['body']?.toString() ?? '',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
                if (comment['author_id'] ==
                    BackendConfig.client.auth.currentUser?.id)
                  PopupMenuButton<String>(
                    tooltip: 'Opciones del comentario',
                    onSelected: (value) {
                      if (value == 'delete') _deleteComment(comment);
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'delete', child: Text('Eliminar')),
                    ],
                  ),
              ],
            ),
          ),
        if (_comments.length > 3)
          Text(
            'y ${_comments.length - 3} comentarios más',
            style: const TextStyle(fontSize: 10, color: AppColors.cyan),
          ),
      ],
    ],
  );
}

class _EngagementButton extends StatelessWidget {
  const _EngagementButton({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(24),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 19, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
          ),
        ],
      ),
    ),
  );
}
