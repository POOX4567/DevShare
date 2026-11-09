
import 'package:flutter/material.dart';

import '../../app/app_theme.dart';
import '../../core/backend/backend_config.dart';

const sectionNames = [
  'Inicio',
  'Comunidades',
  'Cursos',
  'Mensajes',
  'Perfil',
];

class SectionFrame extends StatelessWidget {
  const SectionFrame({
    super.key,
    required this.title,
    required this.selected,
    required this.onNavigate,
    required this.children,
  });

  final String title;
  final int selected;
  final ValueChanged<int> onNavigate;
  final List<Widget> children;

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
                SizedBox(
                  height: 54,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(7),
                          child: Image.asset(
                            'DevShare.png',
                            width: 28,
                            height: 28,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'DevShare',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                title.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 9,
                                  color: AppColors.cyan,
                                  letterSpacing: 1.1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // CONTENIDO PRINCIPAL
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(12),
                    children: children,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      // BARRA DE NAVEGACIÓN ADAPTABLE
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          height: 62,
          color: const Color(0xFF071422),
          child: Row(
            children: [
              for (var i = 0; i < sectionNames.length; i++)
                Expanded(
                  child: InkWell(
                    onTap: () => onNavigate(i),
                    child: SizedBox(
                      height: 62,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            [
                              Icons.terminal,
                              Icons.forum_outlined,
                              Icons.play_circle_outline,
                              Icons.chat_bubble_outline,
                              Icons.code,
                            ][i],
                            size: 18,
                            color: i == selected
                                ? const Color(0xFFD9B7FF)
                                : Colors.blueGrey,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            sectionNames[i],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 8,
                              color: i == selected
                                  ? const Color(0xFFE0C8FF)
                                  : Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// TARJETA GENERAL DE SECCIÓN
// ============================================================

class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon = Icons.code,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.field,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
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
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFFB9C7D6),
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

// ============================================================
// ENCABEZADO DE SECCIÓN
// ============================================================

class SectionHeading extends StatelessWidget {
  const SectionHeading(
    this.title, {
    super.key,
    this.action,
  });

  final String title;
  final String? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
          ),
          if (action != null)
            Text(
              action!,
              style: const TextStyle(
                color: AppColors.cyan,
                fontSize: 9,
              ),
            ),
        ],
      ),
    );
  }
}

// ============================================================
// TARJETAS HORIZONTALES
// ============================================================

class HorizontalCards extends StatelessWidget {
  const HorizontalCards({
    super.key,
    required this.items,
  });

  final List<(String, String, String, String)> items;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 112,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          for (final item in items)
            Container(
              width: 205,
              margin: const EdgeInsets.only(right: 9),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.panel,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.$1,
                    style: const TextStyle(
                      color: AppColors.cyan,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    item.$2,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    item.$3,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFFB9C7D6),
                    ),
                  ),
                  Text(
                    item.$4,
                    style: const TextStyle(
                      fontSize: 9,
                      color: AppColors.cyan,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ============================================================
// CATEGORÍAS
// ============================================================

class CategoryChips extends StatelessWidget {
  const CategoryChips(
    this.items, {
    super.key,
  });

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < items.length; i++)
            Container(
              margin: const EdgeInsets.only(right: 7),
              padding: const EdgeInsets.symmetric(
                horizontal: 13,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: i == 0
                    ? AppColors.violet
                    : AppColors.panel,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                items[i],
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ============================================================
// COLECCIÓN DE DATOS DESDE SUPABASE
// ============================================================

class BackendCollection extends StatelessWidget {
  const BackendCollection({
    super.key,
    required this.title,
    required this.load,
    this.icon = Icons.cloud_done_outlined,
    this.itemBuilder,
  });

  final String title;
  final Future<List<Map<String, dynamic>>> Function() load;
  final IconData icon;

  final Widget Function(
    BuildContext,
    Map<String, dynamic>,
  )? itemBuilder;

  @override
  Widget build(BuildContext context) {
    if (!BackendConfig.isConfigured) {
      return const SizedBox.shrink();
    }

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: load(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Padding(
            padding: EdgeInsets.all(12),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return SectionCard(
            title: '$title: error de carga',
            subtitle: snapshot.error.toString(),
            icon: Icons.error_outline,
          );
        }

        final rows = snapshot.data ?? [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeading('$title (${rows.length})'),

            if (rows.isEmpty)
              SectionCard(
                title: 'Sin datos todavía',
                subtitle:
                    'Cuando agregues información en Supabase aparecerá aquí.',
                icon: icon,
              ),

            for (final row in rows)
              if (itemBuilder case final buildItem?)
                buildItem(context, row)
              else
                SectionCard(
                  title: (
                    row['title'] ??
                    row['name'] ??
                    row['display_name'] ??
                    row['body'] ??
                    row['id'] ??
                    title
                  ).toString(),
                  subtitle: (
                    row['description'] ??
                    row['category'] ??
                    row['created_at'] ??
                    ''
                  ).toString(),
                  icon: icon,
                ),
          ],
        );
      },
    );
  }
}
