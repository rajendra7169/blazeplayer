import 'package:flutter/material.dart';

class MusicCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? imagePath;
  final VoidCallback? onTap;
  final bool isCircular;

  const MusicCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.imagePath,
    this.onTap,
    this.isCircular = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Album Art
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                borderRadius: isCircular
                    ? BorderRadius.circular(70)
                    : BorderRadius.circular(12),
                color: isDark
                    ? Colors.white.withOpacity(0.05)
                    : Colors.grey[300],
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: isCircular
                    ? BorderRadius.circular(70)
                    : BorderRadius.circular(12),
                child: imagePath != null
                    ? Image.asset(imagePath!, fit: BoxFit.cover)
                    : Icon(
                        isCircular ? Icons.person : Icons.album,
                        size: 60,
                        color: isDark ? Colors.white30 : Colors.grey[600],
                      ),
              ),
            ),
            const SizedBox(height: 8),
            // Title
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 2),
            // Subtitle
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
