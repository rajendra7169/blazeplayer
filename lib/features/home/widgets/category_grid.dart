import 'package:flutter/material.dart';

class CategoryCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const CategoryCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withOpacity(0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Colors.white),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryGrid extends StatelessWidget {
  final VoidCallback? onSongsTap;
  const CategoryGrid({super.key, this.onSongsTap});

  @override
  Widget build(BuildContext context) {
    final categories = [
      {
        'title': 'Songs',
        'icon': Icons.music_note_rounded,
        'color': const Color(0xFFFF6B6B),
      },
      {
        'title': 'Albums',
        'icon': Icons.album_rounded,
        'color': const Color(0xFF4ECDC4),
      },
      {
        'title': 'Artists',
        'icon': Icons.person_rounded,
        'color': const Color(0xFFFFBE0B),
      },
      {
        'title': 'Playlists',
        'icon': Icons.playlist_play_rounded,
        'color': const Color(0xFF8B5CF6),
      },
      {
        'title': 'Folders',
        'icon': Icons.folder_rounded,
        'color': const Color(0xFFEC4899),
      },
      {
        'title': 'Favorites',
        'icon': Icons.favorite_rounded,
        'color': const Color(0xFFEF4444),
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return CategoryCard(
            title: category['title'] as String,
            icon: category['icon'] as IconData,
            color: category['color'] as Color,
            onTap: category['title'] == 'Songs' ? onSongsTap : null,
          );
        },
      ),
    );
  }
}
