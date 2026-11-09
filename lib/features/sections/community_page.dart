import 'package:flutter/material.dart';

import '../../app/app_theme.dart';
import '../../core/backend/backend_config.dart';
import '../../core/data/feature_repository.dart';
import 'section_components.dart';

class CommunityPage extends StatelessWidget {
  const CommunityPage({super.key, required this.onNavigate});

  final ValueChanged<int> onNavigate;

  @override
  Widget build(BuildContext context) => SectionFrame(
        title: 'Comunidades',
        selected: 1,
        onNavigate: onNavigate,
        children: [
          const _CommunityBrowser(),
          const SizedBox(height: 12),
          BackendCollection(
            title: 'Eventos y transmisiones',
            load: () => FeatureRepository().events(),
            icon: Icons.event_outlined,
          ),
        ],
      );
}

class _CommunitySummary {
  const _CommunitySummary({
    required this.row,
    required this.memberCount,
    required this.isMember,
  });

  final Map<String, dynamic> row;
  final int memberCount;
  final bool isMember;
}

class _CommunityBrowser extends StatefulWidget {
  const _CommunityBrowser();

  @override
  State<_CommunityBrowser> createState() => _CommunityBrowserState();
}

class _CommunityBrowserState extends State<_CommunityBrowser> {
  final _repository = FeatureRepository();
  final _search = TextEditingController();

  late Future<List<_CommunitySummary>> _communities;

  String _category = 'Todas';

  @override
  void initState() {
    super.initState();
    _communities = _loadCommunities();
  }

  Future<List<_CommunitySummary>> _loadCommunities() async {
    final results = await Future.wait([
      _repository.communities(),
      _repository.communityMembers(),
    ]);

    final communities = results[0];
    final memberships = results[1];

    final userId = BackendConfig.client.auth.currentUser?.id;

    return communities.map((community) {
      final id = community['id']?.toString();

      final members = memberships
          .where((member) => member['community_id']?.toString() == id)
          .toList();

      return _CommunitySummary(
        row: community,
        memberCount: members.length,
        isMember: userId != null &&
            members.any(
              (member) => member['user_id']?.toString() == userId,
            ),
      );
    }).toList();
  }

  void _reload() {
    if (!mounted) return;
    setState(() {
      _communities = _loadCommunities();
    });
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _createCommunity() async {
    final values = await _showCommunityForm(context);

    if (!mounted || values == null) return;

    try {
      await _repository.createCommunity(
        name: values['name']!,
        description: values['description']!,
        category: values['category']!,
      );

      if (!mounted) return;

      _reload();
      _message('Comunidad creada.');
    } catch (error) {
      if (mounted) {
        _message('No se pudo crear la comunidad: $error');
      }
    }
  }

  Future<void> _openCommunity(_CommunitySummary community) async {
    await showDialog<void>(
      context: context,
      builder: (_) => _CommunityDetailsDialog(
        community: community,
        repository: _repository,
        onChanged: _reload,
      ),
    );

    if (mounted) _reload();
  }

  void _message(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message)),
      );
  }

  @override
  Widget build(BuildContext context) {
    if (!BackendConfig.isConfigured) {
      return const SectionCard(
        title: 'Supabase no está conectado',
        subtitle: 'Conecta el backend para cargar comunidades.',
        icon: Icons.cloud_off_outlined,
      );
    }

    return FutureBuilder<List<_CommunitySummary>>(
      future: _communities,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return SectionCard(
            title: 'No se pudieron cargar las comunidades',
            subtitle: snapshot.error.toString(),
            icon: Icons.error_outline,
            trailing: IconButton(
              tooltip: 'Reintentar',
              onPressed: _reload,
              icon: const Icon(Icons.refresh),
            ),
          );
        }

        final all = snapshot.data ?? const <_CommunitySummary>[];

        final categories = all
            .map(
              (item) => item.row['category']?.toString().trim() ?? '',
            )
            .where((value) => value.isNotEmpty)
            .toSet()
            .toList()
          ..sort();

        final query = _search.text.trim().toLowerCase();

        final visible = all.where((community) {
          final row = community.row;

          final matchesCategory =
              _category == 'Todas' || row['category'] == _category;

          final searchText =
              '${row['name'] ?? ''} ${row['description'] ?? ''} ${row['category'] ?? ''}'
                  .toLowerCase();

          return matchesCategory && searchText.contains(query);
        }).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Expanded(
                  child: SectionHeading('Comunidades'),
                ),
                FilledButton.icon(
                  onPressed: _createCommunity,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Crear'),
                ),
              ],
            ),
            TextField(
              controller: _search,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Buscar por nombre, descripción o categoría',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _search.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Limpiar búsqueda',
                        onPressed: () {
                          _search.clear();
                          setState(() {});
                        },
                        icon: const Icon(Icons.close),
                      ),
              ),
            ),
            if (categories.isNotEmpty) ...[
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final category in ['Todas', ...categories])
                      Padding(
                        padding: const EdgeInsets.only(right: 7),
                        child: ChoiceChip(
                          label: Text(category),
                          selected: _category == category,
                          onSelected: (_) {
                            setState(() {
                              _category = category;
                            });
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 8),
            if (visible.isEmpty)
              SectionCard(
                title: all.isEmpty
                    ? 'Aún no hay comunidades'
                    : 'No hay coincidencias',
                subtitle: all.isEmpty
                    ? 'Crea una comunidad para empezar a reunir personas.'
                    : 'Prueba con otro nombre o categoría.',
                icon: Icons.groups_outlined,
              ),
            for (final community in visible)
              _CommunityTile(
                community: community,
                onTap: () => _openCommunity(community),
              ),
          ],
        );
      },
    );
  }
}

class _CommunityTile extends StatelessWidget {
  const _CommunityTile({
    required this.community,
    required this.onTap,
  });

  final _CommunitySummary community;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final row = community.row;

    final name = row['name']?.toString() ?? 'Comunidad';
    final description = row['description']?.toString().trim() ?? '';
    final category = row['category']?.toString() ?? 'General';

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: AppColors.panel,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.field,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.groups_outlined,
                  color: AppColors.cyan,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFFB9C7D6),
                        ),
                      ),
                    ],
                    const SizedBox(height: 7),
                    Wrap(
                      spacing: 10,
                      children: [
                        _MetaLabel(
                          icon: Icons.sell_outlined,
                          text: category,
                        ),
                        _MetaLabel(
                          icon: Icons.people_outline,
                          text: '${community.memberCount} miembros',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (community.isMember)
                const Padding(
                  padding: EdgeInsets.only(left: 6),
                  child: Icon(
                    Icons.check_circle,
                    color: AppColors.cyan,
                  ),
                )
              else
                const Padding(
                  padding: EdgeInsets.only(left: 6),
                  child: Icon(
                    Icons.chevron_right,
                    color: Colors.white70,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaLabel extends StatelessWidget {
  const _MetaLabel({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 13,
          color: AppColors.cyan,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(fontSize: 10),
        ),
      ],
    );
  }
}

class _CommunityDetailsDialog extends StatefulWidget {
  const _CommunityDetailsDialog({
    required this.community,
    required this.repository,
    required this.onChanged,
  });

  final _CommunitySummary community;
  final FeatureRepository repository;
  final VoidCallback onChanged;

  @override
  State<_CommunityDetailsDialog> createState() =>
      _CommunityDetailsDialogState();
}

class _CommunityDetailsDialogState
    extends State<_CommunityDetailsDialog> {
  late Map<String, dynamic> _community =
      Map<String, dynamic>.from(widget.community.row);

  late Future<List<Map<String, dynamic>>> _members;

  late bool _joined = widget.community.isMember;

  bool _busy = false;

  String get _id => _community['id'].toString();

  String? get _userId =>
      BackendConfig.client.auth.currentUser?.id;

  bool get _isOwner =>
      _userId != null &&
      _community['owner_id']?.toString() == _userId;

  @override
  void initState() {
    super.initState();
    _members = widget.repository.communityMembers(
      communityId: _id,
    );
  }

  Future<void> _toggleMembership() async {
    if (_busy) return;

    setState(() => _busy = true);

    try {
      if (_joined) {
        await widget.repository.leaveCommunity(_id);
      } else {
        await widget.repository.joinCommunity(_id);
      }

      if (!mounted) return;

      setState(() {
        _joined = !_joined;
        _members = widget.repository.communityMembers(
          communityId: _id,
        );
      });

      widget.onChanged();
    } catch (error) {
      if (mounted) {
        _message('No se pudo actualizar tu membresía: $error');
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _edit() async {
    if (_busy) return;

    final values = await _showCommunityForm(
      context,
      community: _community,
    );

    if (!mounted || values == null) return;

    setState(() => _busy = true);

    try {
      await widget.repository.updateCommunity(_id, values);

      if (!mounted) return;

      setState(() {
        _community = {..._community, ...values};
      });

      widget.onChanged();
      _message('Comunidad actualizada.');
    } catch (error) {
      if (mounted) {
        _message('No se pudo editar la comunidad: $error');
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _delete() async {
    if (_busy) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar comunidad'),
        content: const Text(
          'Se eliminará la comunidad y sus membresías. '
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(false);
            },
            child: const Text('Cancelar'),
          ),
          FilledButton.tonal(
            onPressed: () {
              Navigator.of(dialogContext).pop(true);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (!mounted || confirmed != true) return;

    setState(() => _busy = true);

    try {
      await widget.repository.deleteCommunity(_id);

      widget.onChanged();

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (error) {
      if (mounted) {
        _message('No se pudo eliminar la comunidad: $error');
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  void _message(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(text)),
      );
  }

  @override
  Widget build(BuildContext context) {
    final createdAt = DateTime.tryParse(
      _community['created_at']?.toString() ?? '',
    );

    return AlertDialog(
      titlePadding: const EdgeInsets.fromLTRB(20, 18, 8, 0),
      title: Row(
        children: [
          Expanded(
            child: Text(
              _community['name']?.toString() ?? 'Comunidad',
            ),
          ),
          if (_isOwner)
            PopupMenuButton<String>(
              enabled: !_busy,
              onSelected: (value) {
                if (value == 'edit') {
                  _edit();
                }

                if (value == 'delete') {
                  _delete();
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
      content: SizedBox(
        width: 460,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Chip(
                    avatar: const Icon(
                      Icons.sell_outlined,
                      size: 16,
                    ),
                    label: Text(
                      _community['category']?.toString() ?? 'General',
                    ),
                  ),
                  if (createdAt != null)
                    Chip(
                      avatar: const Icon(
                        Icons.calendar_today_outlined,
                        size: 15,
                      ),
                      label: Text('Creada ${_date(createdAt)}'),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                (_community['description']?.toString().trim().isNotEmpty ??
                        false)
                    ? _community['description'].toString()
                    : 'Esta comunidad aún no tiene descripción.',
                style: const TextStyle(height: 1.45),
              ),
              const SizedBox(height: 18),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _members,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const LinearProgressIndicator();
                  }

                  if (snapshot.hasError) {
                    return Text(
                      'No se pudieron cargar los miembros: '
                      '${snapshot.error}',
                    );
                  }

                  final members = snapshot.data ?? [];

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SectionHeading(
                        'Miembros (${members.length})',
                      ),
                      if (members.isEmpty)
                        const SectionCard(
                          title: 'Todavía no hay miembros',
                          subtitle:
                              'Puedes ser la primera persona en unirte.',
                          icon: Icons.people_outline,
                        ),
                      for (final member in members)
                        _MemberTile(
                          member: member,
                          isOwner:
                              member['user_id']?.toString() ==
                                  _community['owner_id']?.toString(),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy
              ? null
              : () => Navigator.of(context).pop(),
          child: const Text('Cerrar'),
        ),
        FilledButton.icon(
          onPressed: _busy ? null : _toggleMembership,
          icon: _busy
              ? const SizedBox.square(
                  dimension: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : Icon(
                  _joined
                      ? Icons.logout
                      : Icons.group_add_outlined,
                ),
          label: Text(_joined ? 'Salir' : 'Unirme'),
        ),
      ],
    );
  }
}

class _MemberTile extends StatelessWidget {
  const _MemberTile({
    required this.member,
    required this.isOwner,
  });

  final Map<String, dynamic> member;
  final bool isOwner;

  @override
  Widget build(BuildContext context) {
    final profile =
        member['profiles'] as Map<String, dynamic>? ?? {};

    final userId = member['user_id']?.toString() ?? '';

    final name = profile['display_name']?.toString().trim();

    final label = name?.isNotEmpty == true
        ? name!
        : (userId.length > 12
            ? userId.substring(0, 12)
            : userId);

    final role = member['role']?.toString() ?? 'member';

    final avatarPath = profile['avatar_path']?.toString() ?? '';

    final hasAvatar = avatarPath.startsWith('http');

    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        radius: 17,
        backgroundImage: hasAvatar
            ? NetworkImage(avatarPath)
            : null,
        child: hasAvatar
            ? null
            : const Icon(
                Icons.person_outline,
                size: 18,
              ),
      ),
      title: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: isOwner
          ? const Text(
              'Propietario',
              style: TextStyle(
                color: AppColors.cyan,
                fontSize: 11,
              ),
            )
          : Text(
              role,
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 11,
              ),
            ),
    );
  }
}

/// Abre el formulario de creación o edición.
/// Los controladores pertenecen al State del diálogo y se liberan
/// cuando Flutter desmonta el formulario.
Future<Map<String, String>?> _showCommunityForm(
  BuildContext context, {
  Map<String, dynamic>? community,
}) {
  return showDialog<Map<String, String>>(
    context: context,
    builder: (_) => _CommunityFormDialog(
      community: community,
    ),
  );
}

class _CommunityFormDialog extends StatefulWidget {
  const _CommunityFormDialog({
    this.community,
  });

  final Map<String, dynamic>? community;

  @override
  State<_CommunityFormDialog> createState() =>
      _CommunityFormDialogState();
}

class _CommunityFormDialogState
    extends State<_CommunityFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _name;
  late final TextEditingController _description;
  late final TextEditingController _category;

  @override
  void initState() {
    super.initState();

    _name = TextEditingController(
      text: widget.community?['name']?.toString() ?? '',
    );

    _description = TextEditingController(
      text: widget.community?['description']?.toString() ?? '',
    );

    _category = TextEditingController(
      text: widget.community?['category']?.toString() ?? 'General',
    );
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _category.dispose();

    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.of(context).pop({
      'name': _name.text.trim(),
      'category': _category.text.trim(),
      'description': _description.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.community != null;

    return AlertDialog(
      title: Text(
        editing ? 'Editar comunidad' : 'Crear comunidad',
      ),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 420,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _name,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Nombre',
                  ),
                  validator: (value) =>
                      value == null || value.trim().isEmpty
                          ? 'Escribe un nombre.'
                          : null,
                ),
                TextFormField(
                  controller: _category,
                  decoration: const InputDecoration(
                    labelText: 'Categoría',
                  ),
                  validator: (value) =>
                      value == null || value.trim().isEmpty
                          ? 'Escribe una categoría.'
                          : null,
                ),
                TextFormField(
                  controller: _description,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                    alignLabelWithHint: true,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _save,
          child: Text(editing ? 'Guardar' : 'Crear'),
        ),
      ],
    );
  }
}

String _date(DateTime value) =>
    '${value.toLocal().year}-'
    '${value.toLocal().month.toString().padLeft(2, '0')}-'
    '${value.toLocal().day.toString().padLeft(2, '0')}';