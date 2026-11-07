import 'package:flutter/material.dart';

import '../../../app/app_theme.dart';
import '../data/youtube_link.dart';
import 'youtube_post_player.dart';

/// Shows the YouTube thumbnail and opens the embedded player when tapped.
class YoutubeVideoCard extends StatelessWidget {
  const YoutubeVideoCard({super.key, required this.url, this.isLive = false});

  final String url;
  final bool isLive;

  @override
  Widget build(BuildContext context) {
    final link = YoutubeLink.parse(url);
    if (link == null) {
      return const Text('Enlace de YouTube no válido.');
    }
    return Material(
      color: const Color(0xFF071522),
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => showDialog<void>(
          context: context,
          builder: (context) => Dialog(
            backgroundColor: const Color(0xFF071522),
            insetPadding: const EdgeInsets.all(18),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ),
                  YoutubePostPlayer(url: url, isLive: isLive),
                ],
              ),
            ),
          ),
        ),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Stack(
            fit: StackFit.expand,
            alignment: Alignment.center,
            children: [
              Image.network(
                link.thumbnailUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  color: const Color(0xFF10263A),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.ondemand_video,
                    size: 44,
                    color: AppColors.cyan,
                  ),
                ),
                loadingBuilder: (context, child, progress) => progress == null
                    ? child
                    : Container(
                        color: const Color(0xFF10263A),
                        alignment: Alignment.center,
                        child: const CircularProgressIndicator(),
                      ),
              ),
              Container(color: Colors.black.withValues(alpha: .22)),
              const Icon(
                Icons.play_circle_fill_rounded,
                size: 58,
                color: Colors.white,
              ),
              if (isLive)
                const Positioned(
                  left: 10,
                  top: 10,
                  child: Chip(
                    visualDensity: VisualDensity.compact,
                    avatar: Icon(Icons.circle, size: 9, color: Colors.red),
                    label: Text('EN VIVO'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
