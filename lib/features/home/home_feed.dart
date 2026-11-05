import 'package:flutter/material.dart';

import '../../app/app_theme.dart';

class HomeFeed extends StatefulWidget {
  const HomeFeed({super.key, required this.onNavigate});

  final ValueChanged<int> onNavigate;

  @override
  State<HomeFeed> createState() => _HomeFeedState();
}

class _HomeFeedState extends State<HomeFeed> {
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
                _TopBar(onAction: _message),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(10, 2, 10, 20),
                    children: [
                      const _LiveBroadcast(),
                      const SizedBox(height: 20),
                      const _Highlights(),
                      const SizedBox(height: 16),
                      _Composer(onAction: _message),
                      const SizedBox(height: 12),
                      const _CodePost(),
                      const SizedBox(height: 12),
                      const _LearningCard(),
                      const SizedBox(height: 12),
                      const _ProjectPost(),
                      const SizedBox(height: 12),
                      _CommunityCard(
                          onJoin: () =>
                              _message('Pronto podrás unirte a comunidades.')),
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
          onPressed: () => _message(
              'El creador de publicaciones estará disponible próximamente.')),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: _BottomNavigation(onTap: (label) {
        if (label != 'Inicio') {
          widget.onNavigate(_BottomNavigation.labels.indexOf(label));
        }
      }),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onAction});

  final ValueChanged<String> onAction;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 54,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            children: [
              Container(
                width: 25,
                height: 25,
                decoration: BoxDecoration(
                  color: AppColors.field,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.cyan.withValues(alpha: .35)),
                ),
                child: const Icon(Icons.code_rounded,
                    color: AppColors.cyan, size: 16),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('DevShare',
                        style: TextStyle(
                            fontSize: 16,
                            height: 1,
                            fontWeight: FontWeight.w800)),
                    SizedBox(height: 3),
                    Text('INICIO',
                        style: TextStyle(
                            fontSize: 9,
                            height: 1,
                            letterSpacing: 1.1,
                            color: AppColors.cyan,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Buscar',
                onPressed: () => onAction('La búsqueda'),
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.search_rounded, size: 22),
              ),
              IconButton(
                tooltip: 'Notificaciones',
                onPressed: () => onAction('Las notificaciones'),
                visualDensity: VisualDensity.compact,
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.notifications_none_rounded, size: 22),
                    Positioned(
                        right: -1,
                        top: -1,
                        child: Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                                color: AppColors.cyan,
                                shape: BoxShape.circle))),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              const _Avatar(initials: 'A', size: 34, ring: true),
            ],
          ),
        ),
      );
}

class _LiveBroadcast extends StatelessWidget {
  const _LiveBroadcast();

  @override
  Widget build(BuildContext context) => Container(
        height: 28,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFF071C2C),
          borderRadius: BorderRadius.circular(9),
        ),
        child: const FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _LiveDot(),
              SizedBox(width: 6),
              Text('LIVE BROADCAST',
                  style: TextStyle(
                      color: AppColors.cyan,
                      fontSize: 9,
                      letterSpacing: .55,
                      fontWeight: FontWeight.w800)),
              Text(' · 428 devs en salas simultáneas',
                  style: TextStyle(fontSize: 9, color: Color(0xFFC2D1DF))),
              SizedBox(width: 5),
              Icon(Icons.graphic_eq_rounded, size: 13, color: AppColors.cyan),
            ],
          ),
        ),
      );
}

class _LiveDot extends StatelessWidget {
  const _LiveDot();

  @override
  Widget build(BuildContext context) => Container(
        width: 7,
        height: 7,
        decoration:
            const BoxDecoration(color: AppColors.cyan, shape: BoxShape.circle),
      );
}

class _Highlights extends StatelessWidget {
  const _Highlights();

  static const items = <(String, IconData, Color)>[
    ('React 19', Icons.bubble_chart_rounded, Color(0xFF42D8F5)),
    ('IA Python', Icons.auto_awesome_rounded, Color(0xFF8B70FF)),
    ('Portfolio', Icons.work_outline_rounded, Color(0xFFF58BCA)),
    ('DevTips', Icons.lightbulb_outline_rounded, Color(0xFFE9C65B)),
    ('Hackathon', Icons.terminal_rounded, Color(0xFF8E7BFF)),
  ];

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Row(
            children: [
              const Expanded(
                  child: Text('Destacados',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -.2))),
              TextButton(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'El radar de DevShare estará disponible próximamente.'),
                        behavior: SnackBarBehavior.floating)),
                style: TextButton.styleFrom(
                    foregroundColor: AppColors.cyan,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    visualDensity: VisualDensity.compact),
                child: const Text('EXPLORAR RADAR',
                    style: TextStyle(
                        fontSize: 9,
                        letterSpacing: .45,
                        fontWeight: FontWeight.w800)),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final item in items)
                _StoryBadge(label: item.$1, icon: item.$2, color: item.$3)
            ],
          ),
        ],
      );
}

class _StoryBadge extends StatelessWidget {
  const _StoryBadge(
      {required this.label, required this.icon, required this.color});

  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 57,
        child: Column(
          children: [
            Container(
              width: 51,
              height: 51,
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                    colors: [color, AppColors.violet, const Color(0xFF24C7E8)]),
              ),
              child: Container(
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.field,
                    border: Border.all(color: AppColors.navy, width: 2)),
                child: Icon(icon, size: 22, color: color),
              ),
            ),
            const SizedBox(height: 4),
            Text(label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    const TextStyle(fontSize: 9, fontWeight: FontWeight.w600)),
          ],
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
    ('Encuesta', Icons.poll_outlined, Color(0xFF9CDAFF)),
  ];

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
            color: AppColors.panel,
            borderRadius: BorderRadius.circular(15),
            boxShadow: const [
              BoxShadow(
                  color: Colors.black26, blurRadius: 9, offset: Offset(0, 3))
            ]),
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
                    borderRadius: BorderRadius.circular(11)),
                child: const Row(
                  children: [
                    _Avatar(initials: 'A', size: 29),
                    SizedBox(width: 10),
                    Expanded(
                        child: Text('¿En qué estás programando hoy, Alex?',
                            maxLines: 2,
                            style: TextStyle(
                                fontSize: 11,
                                height: 1.3,
                                color: Color(0xFFD8E2ED)))),
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
                          onTap: () => onAction(item.$1)))
              ],
            ),
          ],
        ),
      );
}

class _ComposerAction extends StatelessWidget {
  const _ComposerAction(
      {required this.label,
      required this.icon,
      required this.color,
      required this.onTap});

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
              Text(label,
                  style: const TextStyle(
                      fontSize: 8.5, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      );
}

class _CodePost extends StatefulWidget {
  const _CodePost();

  @override
  State<_CodePost> createState() => _CodePostState();
}

class _CodePostState extends State<_CodePost> {
  bool _liked = false;
  bool _saved = false;

  @override
  Widget build(BuildContext context) => _PostCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _PostHeader(
              initials: 'CD',
              name: 'Carlos Dev',
              handle: '@carl0sm',
              subtitle: 'Fullstack · React & Node',
              time: 'Hace 2 horas',
              online: true,
            ),
            const SizedBox(height: 9),
            const Text.rich(
              TextSpan(
                style: TextStyle(
                    fontSize: 12, height: 1.45, color: Color(0xFFE0E8F0)),
                children: [
                  TextSpan(
                      text:
                          'Optimicé los Server Components reduciendo las cascadas de renderizado con streaming incremental en Next.js. El tiempo hasta el primer byte (TTFB) bajó de '),
                  TextSpan(
                      text: '480ms',
                      style: TextStyle(
                          color: AppColors.cyan, fontWeight: FontWeight.w800)),
                  TextSpan(text: ' a '),
                  TextSpan(
                      text: '115ms',
                      style: TextStyle(
                          color: AppColors.cyan, fontWeight: FontWeight.w800)),
                  TextSpan(text: ' 🔥 Les comparto la estructura:'),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const _CodeBlock(),
            const SizedBox(height: 7),
            _PostActions(
              liked: _liked,
              saved: _saved,
              likes: _liked ? '143' : '142',
              comments: '19',
              onLike: () => setState(() => _liked = !_liked),
              onSave: () => setState(() => _saved = !_saved),
            ),
          ],
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
              BoxShadow(
                  color: Colors.black26, blurRadius: 10, offset: Offset(0, 3))
            ]),
        child: child,
      );
}

class _PostHeader extends StatelessWidget {
  const _PostHeader(
      {required this.initials,
      required this.name,
      required this.handle,
      required this.subtitle,
      required this.time,
      this.online = false});

  final String initials;
  final String name;
  final String handle;
  final String subtitle;
  final String time;
  final bool online;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              _Avatar(initials: initials, size: 34),
              if (online)
                Positioned(
                    right: -1,
                    bottom: 0,
                    child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                            color: AppColors.cyan,
                            shape: BoxShape.circle,
                            border:
                                Border.all(color: AppColors.panel, width: 2)))),
            ],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Flexible(
                      child: Text(name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w800))),
                  const SizedBox(width: 4),
                  Flexible(
                      child: Text(handle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 9, color: Color(0xFFA9BDCF))))
                ]),
                const SizedBox(height: 3),
                Row(children: [
                  const _LiveDot(),
                  const SizedBox(width: 4),
                  Flexible(
                      child: Text(subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: AppColors.cyan,
                              fontSize: 9,
                              fontWeight: FontWeight.w600))),
                  const SizedBox(width: 5),
                  Text(time,
                      style: const TextStyle(
                          fontSize: 9, color: Color(0xFF9AAFC3)))
                ]),
              ],
            ),
          ),
          IconButton(
              tooltip: 'Más opciones',
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Más opciones de publicación'))),
              icon: const Icon(Icons.more_horiz_rounded, size: 18),
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 26, minHeight: 30)),
        ],
      );
}

class _CodeBlock extends StatelessWidget {
  const _CodeBlock();

  static const code = '''export async function CatalogStream() {
  const [products, metrics] = await
    Promise.all([
      fetchProducts({ cache: 'force-cache' }),
      getRealtimeVitals()
    ]);
  return (
    <Suspense fallback={<SkeletonGrid />}>
      <CatalogView data={products} vitals={metrics} />
    </Suspense>
  );
}''';

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
            color: const Color(0xFF061321),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withValues(alpha: .05))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 28,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: const BoxDecoration(
                  color: Color(0xFF11243A),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(8))),
              child: Row(
                children: [
                  const _TrafficLight(color: Color(0xFFFF5C57)),
                  const SizedBox(width: 4),
                  const _TrafficLight(color: Color(0xFFFEBB2E)),
                  const SizedBox(width: 4),
                  const _TrafficLight(color: Color(0xFF28C840)),
                  const SizedBox(width: 8),
                  const Icon(Icons.data_object_rounded,
                      color: Color(0xFF9CB1C5), size: 11),
                  const SizedBox(width: 4),
                  const Expanded(
                      child: Text('ProductCatalog.server.tsx',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 8, color: Color(0xFFB9C9D9)))),
                  TextButton.icon(
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Código copiado'))),
                    style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFFC1D2E2),
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        minimumSize: const Size(0, 22),
                        visualDensity: VisualDensity.compact),
                    icon: const Icon(Icons.copy_rounded, size: 10),
                    label: const Text('Copiar', style: TextStyle(fontSize: 8)),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 7, 5, 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('1\n2\n3\n4\n5\n6\n7\n8\n9\n10\n11',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 8.3,
                          height: 1.48,
                          color: Color(0xFF586D81))),
                  const SizedBox(width: 8),
                  const Expanded(
                      child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Text(code,
                              softWrap: false,
                              style: TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 8.3,
                                  height: 1.48,
                                  color: Color(0xFFE2C5FF))))),
                ],
              ),
            ),
          ],
        ),
      );
}

class _TrafficLight extends StatelessWidget {
  const _TrafficLight({required this.color});
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle));
}

class _PostActions extends StatelessWidget {
  const _PostActions(
      {required this.liked,
      required this.saved,
      required this.likes,
      required this.comments,
      required this.onLike,
      required this.onSave});

  final bool liked;
  final bool saved;
  final String likes;
  final String comments;
  final VoidCallback onLike;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          _Reaction(
              label: likes,
              icon: liked
                  ? Icons.local_fire_department_rounded
                  : Icons.local_fire_department_outlined,
              color: liked ? const Color(0xFFFF9A48) : Colors.white70,
              onTap: onLike),
          const SizedBox(width: 5),
          const _Reaction(
              label: '38',
              icon: Icons.auto_awesome_rounded,
              color: Color(0xFFBDA2FF)),
          const SizedBox(width: 5),
          _Reaction(
              label: comments,
              icon: Icons.chat_bubble_outline_rounded,
              color: const Color(0xFFB9C7D6)),
          const Spacer(),
          IconButton(
              tooltip: 'Compartir',
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Compartir publicación'))),
              visualDensity: VisualDensity.compact,
              constraints: const BoxConstraints(minWidth: 32),
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.share_outlined,
                  size: 16, color: Color(0xFFB9C7D6))),
          IconButton(
              tooltip: saved ? 'Quitar de guardados' : 'Guardar',
              onPressed: onSave,
              visualDensity: VisualDensity.compact,
              constraints: const BoxConstraints(minWidth: 30),
              padding: EdgeInsets.zero,
              icon: Icon(
                  saved
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  size: 17,
                  color: saved ? AppColors.cyan : const Color(0xFFB9C7D6))),
        ],
      );
}

class _Reaction extends StatelessWidget {
  const _Reaction(
      {required this.label,
      required this.icon,
      required this.color,
      this.onTap});
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
          decoration: BoxDecoration(
              color: const Color(0xFF0D1E2E),
              borderRadius: BorderRadius.circular(8)),
          child: Row(children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
            Text(label,
                style:
                    const TextStyle(fontSize: 9, fontWeight: FontWeight.w700))
          ]),
        ),
      );
}

class _LearningCard extends StatelessWidget {
  const _LearningCard();

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: AppColors.panel,
            borderRadius: BorderRadius.circular(15),
            boxShadow: const [
              BoxShadow(
                  color: Colors.black26, blurRadius: 9, offset: Offset(0, 3))
            ]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                        color: const Color(0xFF38296B),
                        borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.school_outlined,
                        color: Color(0xFFD1B7FF), size: 17)),
                const SizedBox(width: 7),
                const Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text('TU RUTA DE APRENDIZAJE',
                          style: TextStyle(
                              fontSize: 8,
                              color: AppColors.cyan,
                              letterSpacing: .45,
                              fontWeight: FontWeight.w800)),
                      SizedBox(height: 2),
                      Text('Next.js 15 & Tailwind CSS',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w800))
                    ])),
                const SizedBox(width: 4),
                const Text('Continuar',
                    style: TextStyle(
                        color: Color(0xFFD0B8FF),
                        fontSize: 8,
                        fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 10),
            Row(children: [
              const Expanded(
                  child: Text('Módulo 4: Server Actions & Cache Tags',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 9, color: Color(0xFFCFD9E4)))),
              const SizedBox(width: 8),
              Text('68%',
                  style: TextStyle(
                      fontSize: 9,
                      color: AppColors.cyan.withValues(alpha: .9),
                      fontWeight: FontWeight.w800))
            ]),
            const SizedBox(height: 5),
            ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: const LinearProgressIndicator(
                    value: .68,
                    minHeight: 5,
                    backgroundColor: Color(0xFF26394D),
                    valueColor: AlwaysStoppedAnimation(AppColors.cyan))),
            const SizedBox(height: 8),
            Row(children: [
              const Icon(Icons.schedule_rounded,
                  size: 13, color: Color(0xFFB9C7D6)),
              const SizedBox(width: 4),
              const Expanded(
                  child: Text('1h 25m restantes para completar tu certificado',
                      style:
                          TextStyle(fontSize: 8.5, color: Color(0xFFC4D0DC)))),
              TextButton(
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              'El módulo estará disponible próximamente.'))),
                  style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: const Color(0xFF20344A),
                      padding: const EdgeInsets.symmetric(horizontal: 11),
                      minimumSize: const Size(0, 29),
                      visualDensity: VisualDensity.compact),
                  child: const Text('Ver módulo',
                      style:
                          TextStyle(fontSize: 8, fontWeight: FontWeight.w700)))
            ]),
          ],
        ),
      );
}

class _ProjectPost extends StatefulWidget {
  const _ProjectPost();

  @override
  State<_ProjectPost> createState() => _ProjectPostState();
}

class _ProjectPostState extends State<_ProjectPost> {
  bool _starred = false;

  @override
  Widget build(BuildContext context) => _PostCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _PostHeader(
                initials: 'ET',
                name: 'Elena Torres',
                handle: '@elenacodes',
                subtitle: 'Open Source',
                time: 'Hace 4 horas',
                online: true),
            const SizedBox(height: 9),
            const Text('DevPulse: Monitor de APIs y Webhooks en tiempo real',
                style: TextStyle(
                    fontSize: 15, height: 1.25, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            const Text(
                'Construí una herramienta ultraligera para visualizar latencia y caídas de microservicios con soporte para gRPC y REST. ¡Lista para deploy en un contenedor Docker!',
                style: TextStyle(
                    fontSize: 11, height: 1.4, color: Color(0xFFD5E0EA))),
            const SizedBox(height: 7),
            const Wrap(spacing: 10, runSpacing: 4, children: [
              Text('• #Flutter',
                  style: TextStyle(
                      color: AppColors.cyan,
                      fontSize: 9,
                      fontWeight: FontWeight.w600)),
              Text('• #Python',
                  style: TextStyle(
                      color: AppColors.cyan,
                      fontSize: 9,
                      fontWeight: FontWeight.w600)),
              Text('• #Docker',
                  style: TextStyle(
                      color: AppColors.cyan,
                      fontSize: 9,
                      fontWeight: FontWeight.w600)),
              Text('• #WebSockets',
                  style: TextStyle(
                      color: AppColors.cyan,
                      fontSize: 9,
                      fontWeight: FontWeight.w600))
            ]),
            const SizedBox(height: 8),
            const _DashboardPreview(),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                    child: _GradientButton(
                        label: 'Ver Demo en Vivo',
                        icon: Icons.rocket_launch_rounded,
                        onPressed: () => ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                                content: Text(
                                    'La demo estará disponible próximamente.'))))),
                const SizedBox(width: 6),
                OutlinedButton.icon(
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'GitHub estará disponible próximamente.'))),
                    icon: const Icon(Icons.code_rounded, size: 14),
                    label: const Text('GitHub', style: TextStyle(fontSize: 9)),
                    style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(color: Colors.white.withValues(alpha: .12)),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        minimumSize: const Size(0, 34),
                        visualDensity: VisualDensity.compact)),
              ],
            ),
            const SizedBox(height: 7),
            Row(
              children: [
                InkWell(
                    onTap: () => setState(() => _starred = !_starred),
                    child: Row(children: [
                      Icon(
                          _starred
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          size: 13,
                          color: const Color(0xFFFFD466)),
                      const SizedBox(width: 3),
                      Text(_starred ? '249 stars' : '248 stars',
                          style: const TextStyle(fontSize: 9))
                    ])),
                const SizedBox(width: 12),
                const Icon(Icons.call_split_rounded,
                    size: 12, color: Color(0xFFB9C7D6)),
                const SizedBox(width: 3),
                const Text('43 forks', style: TextStyle(fontSize: 9)),
                const Spacer(),
                const Icon(Icons.chat_bubble_outline_rounded,
                    size: 12, color: Color(0xFFB9C7D6)),
                const SizedBox(width: 4),
                const Text('27 comentarios', style: TextStyle(fontSize: 9)),
              ],
            ),
          ],
        ),
      );
}

class _DashboardPreview extends StatelessWidget {
  const _DashboardPreview();

  @override
  Widget build(BuildContext context) => Container(
        height: 125,
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1B3653),
                Color(0xFF061321),
                Color(0xFF102B41)
              ]),
          border: Border.all(color: AppColors.cyan.withValues(alpha: .15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(children: [
              Icon(Icons.monitor_heart_outlined,
                  size: 12, color: AppColors.cyan),
              SizedBox(width: 4),
              Text('DEVPULSE  /  API HEALTH',
                  style: TextStyle(
                      fontSize: 7,
                      letterSpacing: .7,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFD8E8F5))),
              Spacer(),
              Icon(Icons.circle, size: 6, color: Color(0xFF3CE1B0)),
              SizedBox(width: 3),
              Text('LIVE',
                  style: TextStyle(fontSize: 7, color: Color(0xFF3CE1B0)))
            ]),
            const SizedBox(height: 7),
            Expanded(
              child: Row(
                children: [
                  Expanded(flex: 4, child: _MiniChart()),
                  const SizedBox(width: 7),
                  Expanded(
                      flex: 3,
                      child: Column(children: const [
                        Expanded(
                            child: _MetricTile(
                                label: 'LATENCIA',
                                value: '42 ms',
                                color: AppColors.cyan)),
                        SizedBox(height: 5),
                        Expanded(
                            child: _MetricTile(
                                label: 'UPTIME',
                                value: '99.98%',
                                color: Color(0xFF4BE2AC)))
                      ])),
                ],
              ),
            ),
            const SizedBox(height: 5),
            const Row(children: [
              Text('v1.2.0-beta',
                  style: TextStyle(fontSize: 7, color: Color(0xFF98CFFF))),
              Spacer(),
              Text('99.98% SLA',
                  style: TextStyle(fontSize: 7, color: Color(0xFFC7D7E5)))
            ]),
          ],
        ),
      );
}

class _MiniChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
            color: const Color(0xFF071522).withValues(alpha: .85),
            borderRadius: BorderRadius.circular(7)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('REQUESTS / SEC',
              style: TextStyle(fontSize: 6, color: Color(0xFF93AFC5))),
          const SizedBox(height: 2),
          Expanded(
              child: CustomPaint(
                  painter: _ChartPainter(), child: const SizedBox.expand()))
        ]),
      );
}

class _ChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = Colors.white.withValues(alpha: .09)
      ..strokeWidth = .5;
    for (var i = 1; i < 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    const points = <double>[
      .73,
      .67,
      .72,
      .45,
      .51,
      .34,
      .47,
      .30,
      .41,
      .23,
      .35,
      .17,
      .24,
      .12
    ];
    final path = Path();
    for (var i = 0; i < points.length; i++) {
      final p =
          Offset(size.width * i / (points.length - 1), size.height * points[i]);
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    final line = Paint()
      ..color = AppColors.cyan
      ..strokeWidth = 1.7
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, line);
    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
        fillPath,
        Paint()
          ..shader = LinearGradient(colors: [
            AppColors.cyan.withValues(alpha: .23),
            AppColors.cyan.withValues(alpha: 0)
          ], begin: Alignment.topCenter, end: Alignment.bottomCenter)
              .createShader(Offset.zero & size));
    canvas.drawPath(path, line);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MetricTile extends StatelessWidget {
  const _MetricTile(
      {required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
          color: const Color(0xFF071522).withValues(alpha: .85),
          borderRadius: BorderRadius.circular(7)),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label,
                style: const TextStyle(fontSize: 6, color: Color(0xFF93AFC5))),
            const SizedBox(height: 3),
            Text(value,
                style: TextStyle(
                    fontSize: 10, color: color, fontWeight: FontWeight.w800))
          ]));
}

class _GradientButton extends StatelessWidget {
  const _GradientButton(
      {required this.label, required this.icon, required this.onPressed});
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) => SizedBox(
      height: 34,
      child: DecoratedBox(
          decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [AppColors.violet, AppColors.blue]),
              borderRadius: BorderRadius.circular(9)),
          child: FilledButton.icon(
              onPressed: onPressed,
              icon: Icon(icon, size: 13),
              label: Text(label,
                  style: const TextStyle(
                      fontSize: 9, fontWeight: FontWeight.w700)),
              style: FilledButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9)),
                  padding: const EdgeInsets.symmetric(horizontal: 7)))));
}

class _CommunityCard extends StatelessWidget {
  const _CommunityCard({required this.onJoin});
  final VoidCallback onJoin;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF172B44),
                  Color(0xFF102337),
                  Color(0xFF22214C)
                ]),
            borderRadius: BorderRadius.circular(15),
            boxShadow: const [
              BoxShadow(
                  color: Colors.black26, blurRadius: 9, offset: Offset(0, 3))
            ]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                    color: const Color(0xFF071927),
                    borderRadius: BorderRadius.circular(9)),
                child: const Icon(Icons.terminal_rounded,
                    color: AppColors.cyan, size: 21)),
            const Spacer(),
            Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                decoration: BoxDecoration(
                    color: const Color(0xFF164C68),
                    borderRadius: BorderRadius.circular(20)),
                child: const Text('+1,840 miembros',
                    style: TextStyle(
                        fontSize: 8,
                        color: AppColors.cyan,
                        fontWeight: FontWeight.w700)))
          ]),
          const SizedBox(height: 8),
          const Text('Comunidad: Python & Inteligencia Artificial',
              style: TextStyle(
                  fontSize: 15, height: 1.2, fontWeight: FontWeight.w800)),
          const SizedBox(height: 5),
          const Text(
              'Discute papers, agentes autónomos con LangChain y optimización de LLMs locales con colegas hispanohablantes.',
              style: TextStyle(
                  fontSize: 10, height: 1.35, color: Color(0xFFD0DCE7))),
          const SizedBox(height: 9),
          Row(children: [
            const _Avatar(initials: 'M', size: 22),
            Transform.translate(
                offset: const Offset(-5, 0),
                child: const _Avatar(initials: 'S', size: 22)),
            Transform.translate(
                offset: const Offset(-10, 0),
                child: const _Avatar(initials: 'D', size: 22)),
            Transform.translate(
                offset: const Offset(-15, 0),
                child: const _Avatar(initials: '+40', size: 22)),
            const Spacer(),
            FilledButton.icon(
                onPressed: onJoin,
                icon: const Icon(Icons.group_add_outlined, size: 13),
                label: const Text('Unirme',
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700)),
                style: FilledButton.styleFrom(
                    backgroundColor: AppColors.violet,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 11),
                    minimumSize: const Size(0, 30),
                    visualDensity: VisualDensity.compact))
          ]),
        ]),
      );
}

class _Avatar extends StatelessWidget {
  const _Avatar(
      {required this.initials, required this.size, this.ring = false});
  final String initials;
  final double size;
  final bool ring;
  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        padding: EdgeInsets.all(ring ? 2 : 0),
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: ring
                ? const LinearGradient(
                    colors: [AppColors.cyan, AppColors.violet])
                : null,
            color: ring ? null : const Color(0xFF1D4160),
            border: ring
                ? null
                : Border.all(color: const Color(0xFF6E9BB7).withValues(alpha: .45))),
        child: Container(
          decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF345675), Color(0xFF101E32)])),
          alignment: Alignment.center,
          child: Text(initials,
              maxLines: 1,
              style: TextStyle(
                  fontSize: size * (initials.length > 2 ? .27 : .32),
                  fontWeight: FontWeight.w800,
                  color: Colors.white)),
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
                colors: [Color(0xFF7867FF), AppColors.violet, AppColors.blue]),
            boxShadow: [
              BoxShadow(
                  color: AppColors.violet.withValues(alpha: .55),
                  blurRadius: 20,
                  spreadRadius: 1)
            ]),
        child: IconButton(
            tooltip: 'Crear publicación',
            onPressed: onPressed,
            icon: const Icon(Icons.add_rounded, size: 30, color: Colors.white)),
      );
}

class _BottomNavigation extends StatelessWidget {
  const _BottomNavigation({required this.onTap});
  final ValueChanged<String> onTap;

  static const labels = ['Inicio', 'Comunidades', 'Cursos', 'Mensajes', 'Perfil'];
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
            border: Border(top: BorderSide(color: Color(0xFF14283B)))),
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
                        Icon(items[i].$2,
                            size: 18,
                            color: i == 0
                                ? const Color(0xFFD9B7FF)
                                : const Color(0xFFA7B7C8)),
                        const SizedBox(height: 3),
                        Text(items[i].$1,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 8,
                                color: i == 0
                                    ? const Color(0xFFE0C8FF)
                                    : const Color(0xFFC0CCDA),
                                fontWeight: i == 0
                                    ? FontWeight.w700
                                    : FontWeight.w500)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
}
