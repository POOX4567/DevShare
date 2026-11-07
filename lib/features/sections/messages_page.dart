import 'package:flutter/material.dart';
import 'section_components.dart';
import '../../core/data/feature_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key, required this.onNavigate});
  final ValueChanged<int> onNavigate;
  @override
  Widget build(BuildContext context) => SectionFrame(
    title: 'Mensajes',
    selected: 3,
    onNavigate: onNavigate,
    children: const [_ConversationsPanel()],
  );
}

class _ConversationsPanel extends StatefulWidget {
  const _ConversationsPanel();
  @override
  State<_ConversationsPanel> createState() => _ConversationsPanelState();
}

class _ConversationsPanelState extends State<_ConversationsPanel> {
  final _repo = FeatureRepository();
  late Future<List<Map<String, dynamic>>> _future;
  @override
  void initState() {
    super.initState();
    _future = _repo.myConversations();
  }

  void _reload() => setState(() => _future = _repo.myConversations());
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          const Expanded(child: SectionHeading('Tus conversaciones')),
          IconButton(
            onPressed: _newChat,
            icon: const Icon(Icons.add_comment_outlined),
          ),
        ],
      ),
      FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, s) {
          if (s.connectionState != ConnectionState.done)
            return const LinearProgressIndicator();
          if (s.hasError) return Text('Error de conversaciones: ${s.error}');
          final rows = s.data ?? [];
          if (rows.isEmpty)
            return const SectionCard(
              title: 'Aún no tienes mensajes',
              subtitle: 'Inicia un chat con alguien de la comunidad.',
              icon: Icons.chat_bubble_outline,
            );
          return Column(
            children: [
              for (final row in rows)
                _ConversationTile(row: row, onTap: () => _chat(row)),
            ],
          );
        },
      ),
    ],
  );
  Future<void> _newChat() async {
    final id = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Nueva conversación'),
        content: TextField(
          controller: id,
          decoration: const InputDecoration(labelText: 'UUID del usuario'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Crear'),
          ),
        ],
      ),
    );
    if (ok == true) {
      try {
        final conversationId = await _repo.startConversation(id.text.trim());
        _reload();
        await _chat({'conversation_id': conversationId});
      } catch (e) {
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No se pudo iniciar el chat: $e')),
          );
      }
    }
    id.dispose();
  }

  Future<void> _chat(Map<String, dynamic> row) async {
    final id = row['conversation_id']?.toString();
    if (id == null) return;
    final input = TextEditingController();
    var refresh = 0;
    await showDialog<void>(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (c, update) => AlertDialog(
          title: const Text('Mensajes'),
          content: SizedBox(
            width: 440,
            height: 400,
            child: Column(
              children: [
                Expanded(
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    key: ValueKey(refresh),
                    future: _repo.messages(id),
                    builder: (c, s) {
                      if (s.connectionState != ConnectionState.done)
                        return const Center(child: CircularProgressIndicator());
                      if (s.hasError) return Text('Error: ${s.error}');
                      return ListView(
                        children: [
                          for (final m in s.data ?? [])
                            Align(
                              alignment:
                                  m['sender_id'] ==
                                      Supabase
                                          .instance
                                          .client
                                          .auth
                                          .currentUser
                                          ?.id
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                margin: const EdgeInsets.all(4),
                                padding: const EdgeInsets.all(9),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF102337),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(m['body']?.toString() ?? ''),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: input,
                        decoration: const InputDecoration(
                          hintText: 'Escribe un mensaje',
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        if (input.text.trim().isEmpty) return;
                        try {
                          await _repo.sendMessage(id, input.text);
                          if (!mounted) return;
                          input.clear();
                          update(() => refresh++);
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error al enviar: $e')),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.send),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c),
              child: const Text('Cerrar'),
            ),
          ],
        ),
      ),
    );
    input.dispose();
  }
}

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({required this.row, required this.onTap});
  final Map<String, dynamic> row;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final id = row['conversation_id']?.toString() ?? '';
    final nested = row['conversations'] as Map<String, dynamic>?;
    final messages = nested?['messages'] as List?;
    final last = messages?.isNotEmpty == true
        ? messages!.last as Map<String, dynamic>
        : null;
    return InkWell(
      onTap: onTap,
      child: SectionCard(
        title: 'Chat ${id.length > 8 ? id.substring(0, 8) : id}',
        subtitle: last?['body']?.toString() ?? 'Abrir conversación',
        icon: Icons.forum,
      ),
    );
  }
}
