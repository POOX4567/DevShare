import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../app/app_theme.dart';
import '../../core/backend/backend_config.dart';
import '../../core/data/feature_repository.dart';
import '../auth/data/auth_repository.dart';
import 'section_components.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.onNavigate});
  final ValueChanged<int> onNavigate;
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _repo = FeatureRepository();
  late Future<Map<String, dynamic>> _profile;
  @override
  void initState() {
    super.initState();
    _profile = _repo.myProfile();
  }

  void _reload() => setState(() => _profile = _repo.myProfile());

  @override
  Widget build(BuildContext context) {
    if (!BackendConfig.isConfigured) {
      return SectionFrame(
        title: 'Perfil',
        selected: 4,
        onNavigate: widget.onNavigate,
        children: const [
          Center(child: Text('Conecta Supabase para cargar tu perfil.')),
        ],
      );
    }
    return FutureBuilder<Map<String, dynamic>>(
      future: _profile,
      builder: (context, snapshot) => SectionFrame(
        title: 'Perfil',
        selected: 4,
        onNavigate: widget.onNavigate,
        children: snapshot.hasError
            ? [
                Text('No se pudo cargar el perfil: ${snapshot.error}'),
                TextButton(onPressed: _reload, child: const Text('Reintentar')),
              ]
            : snapshot.connectionState != ConnectionState.done
            ? const [
                Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(),
                  ),
                ),
              ]
            : _profileContent(context, snapshot.data ?? {}),
      ),
    );
  }

  List<Widget> _profileContent(
    BuildContext context,
    Map<String, dynamic> profile,
  ) => [
    _ProfileHero(
      profile: profile,
      onEdit: () => _editProfile(context, profile),
    ),
    const SizedBox(height: 12),
    const SectionHeading('Actividad reciente'),
    FutureBuilder<List<Map<String, dynamic>>>(
      future: _repo.activity(),
      builder: (context, result) {
        if (result.connectionState != ConnectionState.done)
          return const LinearProgressIndicator();
        if (result.hasError)
          return Text('No se pudo cargar actividad: ${result.error}');
        final activities = result.data ?? [];
        if (activities.isEmpty)
          return const SectionCard(
            title: 'Aún no hay actividad',
            subtitle: 'Tus publicaciones, cursos y acciones aparecerán aquí.',
            icon: Icons.insights,
          );
        return Column(
          children: [
            for (final item in activities)
              SectionCard(
                title: item['type']?.toString() ?? 'Actividad',
                subtitle: item['created_at']?.toString() ?? '',
                icon: Icons.bolt,
              ),
          ],
        );
      },
    ),
    const SizedBox(height: 8),
    FutureBuilder<List<Map<String, dynamic>>>(
      future: _repo.friends(),
      builder: (context, result) {
        if (result.connectionState != ConnectionState.done)
          return const LinearProgressIndicator();
        if (result.hasError)
          return Text('No se pudieron cargar amistades: ${result.error}');
        final friends = result.data ?? [];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeading('Amigos (${friends.length})'),
            if (friends.isEmpty) const Text('Todavía no sigues a nadie.'),
            for (final friend in friends)
              SectionCard(
                title:
                    (friend['profiles'] as Map?)?['display_name']?.toString() ??
                    'Desarrollador',
                subtitle: 'Amistad en DevShare',
                icon: Icons.person,
              ),
          ],
        );
      },
    ),
    const SizedBox(height: 14),
    OutlinedButton.icon(
      onPressed: () async {
        await AuthRepository().signOut();
        if (context.mounted)
          Navigator.of(context).popUntil((route) => route.isFirst);
      },
      icon: const Icon(Icons.logout),
      label: const Text('Cerrar sesión'),
    ),
  ];

  Future<void> _editProfile(
    BuildContext context,
    Map<String, dynamic> current,
  ) async {
    final name = TextEditingController(
      text: current['display_name']?.toString() ?? '',
    );
    final username = TextEditingController(
      text: current['username']?.toString() ?? '',
    );
    final bio = TextEditingController(text: current['bio']?.toString() ?? '');
    final form = GlobalKey<FormState>();
    final save = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar perfil'),
        content: Form(
          key: form,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: name,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Escribe tu nombre'
                      : null,
                ),
                TextFormField(
                  controller: username,
                  decoration: const InputDecoration(labelText: 'Usuario'),
                ),
                TextFormField(
                  controller: bio,
                  decoration: const InputDecoration(labelText: 'Descripción'),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              if (form.currentState!.validate()) Navigator.pop(context, true);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    if (save == true) {
      try {
        await _repo.updateProfile({
          'display_name': name.text.trim(),
          'username': username.text.trim().replaceFirst(RegExp(r'^@'), ''),
          'bio': bio.text.trim(),
        });
        _reload();
      } catch (error) {
        if (context.mounted)
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('No se pudo guardar: $error')));
      }
    }
    name.dispose();
    username.dispose();
    bio.dispose();
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({required this.profile, required this.onEdit});
  final Map<String, dynamic> profile;
  final VoidCallback onEdit;
  @override
  Widget build(BuildContext context) {
    final name = profile['display_name']?.toString().trim().isNotEmpty == true
        ? profile['display_name'].toString()
        : 'DevShare';
    final username = profile['username']?.toString();
    final avatar = profile['avatar_path']?.toString();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFF132945), Color(0xFF0A1B2C)],
        ),
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Editar perfil',
            ),
          ),
          CircleAvatar(
            radius: 42,
            backgroundColor: AppColors.violet,
            backgroundImage: avatar == null || avatar.isEmpty
                ? null
                : NetworkImage(avatar),
            child: avatar == null || avatar.isEmpty
                ? Text(
                    name.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w900,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 21),
          ),
          Text(
            username == null || username.isEmpty
                ? Supabase.instance.client.auth.currentUser?.email ?? ''
                : '@$username',
            style: const TextStyle(color: Colors.blueGrey, fontSize: 11),
          ),
          const SizedBox(height: 12),
          Text(
            profile['bio']?.toString() ?? 'Cuéntale a la comunidad quién eres.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, height: 1.4),
          ),
          if ((profile['website']?.toString() ?? '').isNotEmpty)
            Text(
              profile['website'].toString(),
              style: const TextStyle(color: AppColors.cyan, fontSize: 10),
            ),
        ],
      ),
    );
  }
}
