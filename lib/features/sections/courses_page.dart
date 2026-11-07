import 'package:flutter/material.dart';

import '../../app/app_theme.dart';
import '../../core/data/feature_repository.dart';
import '../posts/widgets/youtube_video_card.dart';
import 'section_components.dart';

class CoursesPage extends StatelessWidget {
  const CoursesPage({super.key, required this.onNavigate});
  final ValueChanged<int> onNavigate;

  @override
  Widget build(BuildContext context) => SectionFrame(
    title: 'Cursos',
    selected: 2,
    onNavigate: onNavigate,
    children: [
      BackendCollection(
        title: 'Cursos disponibles',
        load: () => FeatureRepository().courses(),
        icon: Icons.play_circle_outline,
        itemBuilder: (context, course) {
          final title = (course['title'] ?? 'Curso').toString();
          final description = (course['description'] ?? '').toString();
          final videoUrl =
              (course['youtube_url'] ??
                      course['video_url'] ??
                      course['video_link'] ??
                      course['url'])
                  ?.toString()
                  .trim();

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.panel,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.field,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.play_circle_outline,
                        color: AppColors.cyan,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                          if (description.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              description,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFFB9C7D6),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                if (videoUrl != null && videoUrl.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  YoutubeVideoCard(url: videoUrl),
                ],
              ],
            ),
          );
        },
      ),
    ],
  );
}
