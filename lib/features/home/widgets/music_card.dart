import 'package:flutter/material.dart';
import '../../player/widgets/cached_artwork_widget.dart';

class MusicCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String? imagePath;
  final int? songId;
  final String? albumArt; // <-- Add this line
  final VoidCallback? onTap;
  final bool isCircular;

  const MusicCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.imagePath,
    this.songId,
    this.albumArt, // <-- Add this line
    this.onTap,
    this.isCircular = false,
  });

  @override
  State<MusicCard> createState() => _MusicCardState();
}

class _MusicCardState extends State<MusicCard>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: widget.onTap,
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
                borderRadius: widget.isCircular
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
                borderRadius: widget.isCircular
                    ? BorderRadius.circular(70)
                    : BorderRadius.circular(12),
                child: widget.albumArt != null && widget.albumArt!.isNotEmpty
                    ? CachedArtworkWidget(
                        albumArt: widget.albumArt!,
                        width: 140,
                        height: 140,
                        fit: BoxFit.cover,
                        fallback: Icon(
                          widget.isCircular ? Icons.person : Icons.album,
                          size: 60,
                          color: isDark ? Colors.white30 : Colors.grey[600],
                        ),
                      )
                    : (widget.songId != null
                          ? CachedArtworkWidget(
                              albumArt: widget.songId!.toString(),
                              width: 140,
                              height: 140,
                              fit: BoxFit.cover,
                              fallback: Icon(
                                widget.isCircular ? Icons.person : Icons.album,
                                size: 60,
                                color: isDark
                                    ? Colors.white30
                                    : Colors.grey[600],
                              ),
                            )
                          : (widget.imagePath != null
                                ? Image.asset(
                                    widget.imagePath!,
                                    fit: BoxFit.cover,
                                  )
                                : Icon(
                                    widget.isCircular
                                        ? Icons.person
                                        : Icons.album,
                                    size: 60,
                                    color: isDark
                                        ? Colors.white30
                                        : Colors.grey[600],
                                  ))),
              ),
            ),
            const SizedBox(height: 8),
            // Title
            Text(
              widget.title,
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
              widget.subtitle,
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
