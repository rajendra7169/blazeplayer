import 'package:flutter/material.dart';

class FeaturedAlbumCard extends StatelessWidget {
  final String userName;
  final String? imagePath;
  final String? darkImagePath;
  final String? lightImagePath;
  final Color backgroundColor;
  final VoidCallback? onTap;

  const FeaturedAlbumCard({
    super.key,
    this.userName = 'Music Lover',
    this.imagePath,
    this.darkImagePath,
    this.lightImagePath,
    this.backgroundColor = const Color(0xFF1DB954), // Spotify green
    this.onTap,
  });

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'Good Morning 🌅'; // 5:00 AM - 11:59 AM
    if (hour >= 12 && hour < 17) {
      return 'Good Afternoon ☀️'; // 12:00 PM - 4:59 PM
    }
    if (hour >= 17 && hour < 21) return 'Good Evening 🌆'; // 5:00 PM - 8:59 PM
    return 'Good Night 🌙'; // 9:00 PM - 4:59 AM
  }

  List<TextSpan> _getGreetingSpans() {
    final greeting = _getGreeting();
    final parts = greeting.split(
      ' ',
    ); // Split "Good Morning 🌅" into ["Good", "Morning", "🌅"]

    if (parts.length >= 2) {
      // Join all parts after "Good" (e.g., "Morning 🌅" or "Night 🌙")
      final restOfGreeting = parts.sublist(1).join(' ');
      return [
        TextSpan(text: '${parts[0]}\n'), // "Good\n"
        TextSpan(text: restOfGreeting), // "Morning 🌅" or "Night 🌙"
      ];
    }
    return [TextSpan(text: greeting)];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Theme-specific colors matching app branding
    final cardGradientColors = isDark
        ? [
            const Color(
              0xFFFFA726,
            ), // Yellow/Orange (matching onboarding buttons in dark mode)
            const Color(0xFFFF8F00), // Darker Orange
          ]
        : [
            const Color(0xFFFFA726), // Orange
            const Color(0xFFFF7043), // Deep Orange
          ];

    // Determine which image to use
    String? imageToShow;
    if (isDark && darkImagePath != null) {
      imageToShow = darkImagePath;
    } else if (!isDark && lightImagePath != null) {
      imageToShow = lightImagePath;
    } else if (imagePath != null) {
      imageToShow = imagePath;
    }
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 160,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final textAreaWidth =
                constraints.maxWidth * 0.65; // 65% of card width

            return Stack(
              clipBehavior: Clip.none, // Allow children to overflow
              children: [
                // Background card with theme colors
                Container(
                  height: 160,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: cardGradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Content on the left
                      Positioned(
                        left: 20,
                        top: 20,
                        bottom: 20,
                        width: textAreaWidth - 20, // 65% minus left padding
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Good Morning (split into two lines)
                            RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.3,
                                  height: 1.1,
                                ),
                                children: _getGreetingSpans(),
                              ),
                            ),
                            const SizedBox(height: 6),
                            // Name
                            Text(
                              userName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.95),
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.3,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.2),
                                    offset: const Offset(0, 1),
                                    blurRadius: 3,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 6),
                            // Subtitle
                            Text(
                              'Enjoy the music 🎵',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.85),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Image on the right (starting from bottom, extending upward)
                Positioned(
                  right: 0,
                  bottom: 0, // Align with bottom of card
                  child: Hero(
                    tag: 'featured_$userName',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        width: 200,
                        height: 240, // Taller image that extends beyond card
                        child: imageToShow != null
                            ? Image.asset(imageToShow, fit: BoxFit.cover)
                            : Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.orange.withOpacity(0.3),
                                      Colors.deepOrange.withOpacity(0.3),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.music_note_rounded,
                                  size: 80,
                                  color: Colors.white54,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
