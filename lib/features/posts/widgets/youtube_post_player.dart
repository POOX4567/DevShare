import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../data/youtube_link.dart';

class YoutubePostPlayer extends StatefulWidget {
  const YoutubePostPlayer({super.key, required this.url, this.isLive = false});
  final String url;
  final bool isLive;

  @override
  State<YoutubePostPlayer> createState() => _YoutubePostPlayerState();
}

class _YoutubePostPlayerState extends State<YoutubePostPlayer> {
  YoutubePlayerController? _controller;
  @override
  void initState() {
    super.initState();
    _createController();
  }

  @override
  void didUpdateWidget(covariant YoutubePostPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url || oldWidget.isLive != widget.isLive)
      _createController();
  }

  void _createController() {
    _controller?.close();
    final link = YoutubeLink.parse(widget.url);
    _controller = link == null
        ? null
        : YoutubePlayerController.fromVideoId(videoId: link.videoId);
  }

  @override
  void dispose() {
    _controller?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (controller == null)
      return const Center(child: Text('Enlace de YouTube no válido'));
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.isLive)
          const Align(
            alignment: Alignment.centerLeft,
            child: Chip(
              avatar: Icon(Icons.circle, size: 9, color: Colors.red),
              label: Text('EN VIVO'),
            ),
          ),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: YoutubePlayer(controller: controller),
        ),
      ],
    );
  }
}
