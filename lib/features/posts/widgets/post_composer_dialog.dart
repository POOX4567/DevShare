import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../data/post.dart';
import '../data/youtube_link.dart';

class PostDraft {
  const PostDraft({
    required this.body,
    required this.youtubeUrl,
    required this.isLive,
    required this.projectTitle,
    required this.projectUrl,
    this.imageBytes,
    this.imageName,
    this.keepExistingImage = true,
  });

  final String body;
  final String? youtubeUrl;
  final bool isLive;
  final String projectTitle;
  final String? projectUrl;
  final Uint8List? imageBytes;
  final String? imageName;
  final bool keepExistingImage;
}

Future<PostDraft?> showPostComposer(BuildContext context, {Post? post}) =>
    showDialog<PostDraft>(
      context: context,
      builder: (_) => _PostComposerDialog(post: post),
    );

class _PostComposerDialog extends StatefulWidget {
  const _PostComposerDialog({this.post});
  final Post? post;

  @override
  State<_PostComposerDialog> createState() => _PostComposerDialogState();
}

class _PostComposerDialogState extends State<_PostComposerDialog> {
  late final _body = TextEditingController(text: widget.post?.body ?? '');
  late final _youtube = TextEditingController(
    text: widget.post?.youtubeUrl ?? '',
  );
  late final _projectTitle = TextEditingController(
    text: widget.post?.projectTitle ?? '',
  );
  late final _projectUrl = TextEditingController(
    text: widget.post?.projectUrl ?? '',
  );
  bool _live = false;
  bool _keepImage = true;
  bool _selectingImage = false;
  Uint8List? _imageBytes;
  String? _imageName;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _live = widget.post?.isLive ?? false;
  }

  Future<void> _pickImage() async {
    setState(() => _selectingImage = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;
      final file = result.files.single;
      final bytes = file.bytes;
      if (bytes == null || bytes.isEmpty) {
        _showError('No se pudo leer la imagen seleccionada.');
        return;
      }
      if (bytes.length > 12 * 1024 * 1024) {
        _showError('La imagen debe pesar menos de 12 MB.');
        return;
      }
      setState(() {
        _imageBytes = bytes;
        _imageName = file.name;
        _keepImage = false;
      });
    } catch (error) {
      _showError('No se pudo abrir el selector de imágenes: $error');
    } finally {
      if (mounted) setState(() => _selectingImage = false);
    }
  }

  void _showError(String text) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text)));

  bool _validUrl(String value) {
    final uri = Uri.tryParse(value.trim());
    return uri != null &&
        (uri.scheme == 'https' || uri.scheme == 'http') &&
        uri.host.contains('.');
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      PostDraft(
        body: _body.text.trim(),
        youtubeUrl: _youtube.text.trim().isEmpty ? null : _youtube.text.trim(),
        isLive: _live && _youtube.text.trim().isNotEmpty,
        projectTitle: _projectTitle.text.trim(),
        projectUrl: _projectUrl.text.trim().isEmpty
            ? null
            : _projectUrl.text.trim(),
        imageBytes: _imageBytes,
        imageName: _imageName,
        keepExistingImage: _keepImage,
      ),
    );
  }

  @override
  void dispose() {
    _body.dispose();
    _youtube.dispose();
    _projectTitle.dispose();
    _projectUrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(
      widget.post == null ? 'Nueva publicación' : 'Editar publicación',
    ),
    content: SizedBox(
      width: 460,
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _body,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: '¿Qué quieres compartir?',
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if ((value == null || value.trim().isEmpty) &&
                      _imageBytes == null &&
                      (widget.post?.mediaPath == null || !_keepImage) &&
                      _youtube.text.trim().isEmpty &&
                      _projectUrl.text.trim().isEmpty) {
                    return 'Agrega texto, imagen, video o proyecto.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _youtube,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  labelText: 'Enlace de YouTube',
                  prefixIcon: Icon(Icons.ondemand_video_outlined),
                ),
                validator: (value) {
                  if (value != null &&
                      value.trim().isNotEmpty &&
                      YoutubeLink.parse(value) == null) {
                    return 'Enlace de YouTube no válido.';
                  }
                  return null;
                },
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _live && _youtube.text.trim().isNotEmpty,
                onChanged: _youtube.text.trim().isEmpty
                    ? null
                    : (value) => setState(() => _live = value ?? false),
                title: const Text('Es una transmisión en vivo'),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Imagen',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              const SizedBox(height: 6),
              if (_imageBytes != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.memory(
                    _imageBytes!,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                )
              else if (widget.post?.mediaPath != null && _keepImage)
                Row(
                  children: [
                    const Icon(Icons.image_outlined),
                    const SizedBox(width: 8),
                    const Expanded(child: Text('Imagen actual adjunta')),
                    IconButton(
                      tooltip: 'Quitar imagen',
                      onPressed: () => setState(() => _keepImage = false),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: _selectingImage ? null : _pickImage,
                    icon: _selectingImage
                        ? const SizedBox.square(
                            dimension: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.add_photo_alternate_outlined),
                    label: Text(_imageName ?? 'Elegir imagen'),
                  ),
                  if (_imageBytes != null)
                    IconButton(
                      tooltip: 'Quitar imagen seleccionada',
                      onPressed: () => setState(() {
                        _imageBytes = null;
                        _imageName = null;
                        _keepImage = widget.post?.mediaPath != null;
                      }),
                      icon: const Icon(Icons.close),
                    ),
                ],
              ),
              const Divider(height: 24),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Proyecto',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _projectTitle,
                decoration: const InputDecoration(
                  labelText: 'Nombre del proyecto',
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _projectUrl,
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(
                  labelText: 'URL del proyecto o repositorio',
                  prefixIcon: Icon(Icons.link),
                ),
                validator: (value) {
                  if (value != null &&
                      value.trim().isNotEmpty &&
                      !_validUrl(value)) {
                    return 'Usa una URL completa, por ejemplo https://...';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancelar'),
      ),
      FilledButton.icon(
        onPressed: _submit,
        icon: Icon(widget.post == null ? Icons.publish : Icons.save_outlined),
        label: Text(widget.post == null ? 'Publicar' : 'Guardar cambios'),
      ),
    ],
  );
}
