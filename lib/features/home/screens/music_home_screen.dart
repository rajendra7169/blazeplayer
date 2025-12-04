import 'package:flutter/material.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import '../widgets/featured_album_card.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/section_header.dart';
import '../widgets/music_card.dart';
import '../widgets/category_grid.dart';
import '../../auth/providers/auth_provider.dart';
import '../../player/providers/music_player_provider.dart';
import '../../player/widgets/mini_player.dart';
import '../../music_library/screens/recently_played_screen.dart';
import '../../music_library/screens/recommended_songs_screen.dart';
import '../../music_library/screens/all_songs_screen.dart';
import '../../music_library/screens/albums_screen.dart';
import '../../music_library/screens/favorites_screen.dart';
import '../../music_library/screens/artists_screen.dart';
import '../../music_library/screens/playlist_screen.dart';
import '../../music_library/screens/folder_screen.dart';
import '../../music_library/screens/mood_playlists_screen.dart';
import '../../music_library/screens/song_list_screen.dart';
import '../../player/widgets/cached_artwork_widget.dart';
import '../../../main.dart' show themeNotifier;
import '../../search/music_search_delegate.dart';

class MusicHomeScreen extends StatefulWidget {
  const MusicHomeScreen({super.key});

  @override
  State<MusicHomeScreen> createState() => _MusicHomeScreenState();
}

class _MusicHomeScreenState extends State<MusicHomeScreen> {
  int _selectedTab = 0;

  void _showSettingsDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(
                Icons.settings_outlined,
                color: isDark
                    ? const Color(0xFFFFA726)
                    : const Color(0xFFFF7043),
              ),
              const SizedBox(width: 12),
              Text(
                'Settings',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Theme Mode Section
              ListTile(
                leading: Icon(
                  Icons.brightness_6_rounded,
                  color: isDark
                      ? const Color(0xFFFFA726)
                      : const Color(0xFFFF7043),
                ),
                title: Text(
                  'Theme Mode',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ValueListenableBuilder<ThemeMode>(
                  valueListenable: themeNotifier,
                  builder: (context, currentTheme, _) {
                    return Column(
                      children: [
                        _buildThemeModeOption(
                          context,
                          'Light Mode',
                          Icons.light_mode_rounded,
                          ThemeMode.light,
                          currentTheme,
                          isDark,
                        ),
                        _buildThemeModeOption(
                          context,
                          'Dark Mode',
                          Icons.dark_mode_rounded,
                          ThemeMode.dark,
                          currentTheme,
                          isDark,
                        ),
                        _buildThemeModeOption(
                          context,
                          'System Default',
                          Icons.brightness_auto_rounded,
                          ThemeMode.system,
                          currentTheme,
                          isDark,
                        ),
                      ],
                    );
                  },
                ),
              ),
              const Divider(height: 24),
              // Logout Option
              ListTile(
                leading: Icon(
                  Icons.logout_rounded,
                  color: isDark ? Colors.redAccent : Colors.red,
                ),
                title: Text(
                  'Logout',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () async {
                  Navigator.of(context).pop(); // Close dialog
                  _showLogoutConfirmation(context);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Close',
                style: TextStyle(
                  color: isDark
                      ? const Color(0xFFFFA726)
                      : const Color(0xFFFF7043),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildThemeModeOption(
    BuildContext context,
    String title,
    IconData icon,
    ThemeMode mode,
    ThemeMode currentMode,
    bool isDark,
  ) {
    final isSelected = currentMode == mode;
    return InkWell(
      onTap: () {
        themeNotifier.value = mode;
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? (isDark
                    ? const Color(0xFFFFA726).withOpacity(0.2)
                    : const Color(0xFFFF7043).withOpacity(0.1))
              : Colors.transparent,
          border: Border.all(
            color: isSelected
                ? (isDark ? const Color(0xFFFFA726) : const Color(0xFFFF7043))
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? (isDark ? const Color(0xFFFFA726) : const Color(0xFFFF7043))
                  : (isDark ? Colors.white70 : Colors.black54),
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                color: isSelected
                    ? (isDark ? Colors.white : Colors.black87)
                    : (isDark ? Colors.white70 : Colors.black54),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            const Spacer(),
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                color: isDark
                    ? const Color(0xFFFFA726)
                    : const Color(0xFFFF7043),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning_rounded,
                color: isDark ? Colors.orangeAccent : Colors.orange,
              ),
              const SizedBox(width: 12),
              Text(
                'Logout',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final authProvider = context.read<AuthProvider>();
                await authProvider.signOut();
                if (context.mounted) {
                  Navigator.of(context).pop(); // Close confirmation dialog
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/modern-onboarding',
                    (route) => false,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final provider = Provider.of<MusicPlayerProvider>(context, listen: false);
      await provider.fetchLocalSongs();
      await provider.restoreLastPlayedSong();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;
    final playerProvider = context.watch<MusicPlayerProvider>();

    // Get user's display name or email
    String userName = 'Music Lover';
    if (user != null) {
      if (user.displayName != null && user.displayName!.isNotEmpty) {
        userName = user.displayName!;
      } else if (user.email != null && user.email!.isNotEmpty) {
        // Extract name from email (before @)
        userName = user.email!.split('@')[0];
      }
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: CustomScrollView(
              slivers: [
                // Combined Header and Featured Card for 3D overlay effect
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      // Header with Logo and App Name
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Row(
                          children: [
                            // User Profile Icon on the left (matching style)
                            IconButton(
                              onPressed: () {
                                // Navigate to profile
                              },
                              icon: Icon(
                                Icons.person_outline,
                                color: isDark ? Colors.white : Colors.black87,
                                size: 28,
                              ),
                            ),
                            // Centered Logo and App Name
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Logo (increased size)
                                  Image.asset(
                                    isDark
                                        ? 'assets/logo/logo_white.png'
                                        : 'assets/logo/logo.png',
                                    width: 42,
                                    height: 42,
                                    fit: BoxFit.contain,
                                  ),
                                  const SizedBox(width: 10),
                                  // App Name (increased size)
                                  ShaderMask(
                                    shaderCallback: (Rect bounds) {
                                      return LinearGradient(
                                        colors: isDark
                                            ? [Colors.white, Colors.white]
                                            : [
                                                const Color(0xFFFFA726),
                                                const Color(0xFFFF7043),
                                              ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ).createShader(bounds);
                                    },
                                    child: const Text(
                                      'Blaze Player',
                                      style: TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Settings Icon on the right (matching style)
                            IconButton(
                              onPressed: () {
                                _showSettingsDialog(context);
                              },
                              icon: Icon(
                                Icons.settings_outlined,
                                color: isDark ? Colors.white : Colors.black87,
                                size: 28,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Featured Album Card with image that overlays header
                      FeaturedAlbumCard(
                        userName: userName,
                        backgroundColor: const Color(0xFF1DB954),
                        darkImagePath: 'assets/images/home_dark.png',
                        lightImagePath: 'assets/images/home_light.png',
                      ),
                      const SizedBox(height: 16),
                      // Search Bar
                      SearchBarWidget(
                        onTap: () async {
                          final result = await showSearch(
                            context: context,
                            delegate: MusicSearchDelegate(),
                          );
                          // Optionally handle result
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),

                // Tab Bar (News, Video, Artist, Podcast)
                SliverToBoxAdapter(child: _buildTabBar()),

                // Recently Played Section
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      SectionHeader(
                        title: 'Recently Played',
                        onSeeAllTap: () {
                          Navigator.of(context).push(
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      RecentlyPlayedScreen(),
                              transitionsBuilder:
                                  (
                                    context,
                                    animation,
                                    secondaryAnimation,
                                    child,
                                  ) {
                                    const begin = Offset(1.0, 0.0);
                                    const end = Offset.zero;
                                    const curve = Curves.easeInOut;
                                    var slideTween = Tween(
                                      begin: begin,
                                      end: end,
                                    ).chain(CurveTween(curve: curve));
                                    var fadeTween = Tween<double>(
                                      begin: 0.0,
                                      end: 1.0,
                                    ).chain(CurveTween(curve: curve));
                                    return SlideTransition(
                                      position: animation.drive(slideTween),
                                      child: FadeTransition(
                                        opacity: animation.drive(fadeTween),
                                        child: child,
                                      ),
                                    );
                                  },
                              transitionDuration: const Duration(
                                milliseconds: 300,
                              ),
                              reverseTransitionDuration: const Duration(
                                milliseconds: 300,
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(
                        height: 200,
                        child: Consumer<MusicPlayerProvider>(
                          builder: (context, playerProvider, _) {
                            final songs = playerProvider.recentlyPlayedSongs;
                            if (songs.isEmpty) {
                              return Center(
                                child: Text(
                                  'No recently played songs yet.',
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.white70
                                        : Colors.black54,
                                  ),
                                ),
                              );
                            }
                            return ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              itemCount: songs.length > 10 ? 10 : songs.length,
                              itemBuilder: (context, index) {
                                final song = songs[index];
                                return RepaintBoundary(
                                  child: MusicCard(
                                    title: song.title,
                                    subtitle: song.artist,
                                    songId: int.tryParse(song.id),
                                    onTap: () {
                                      playerProvider.playWithContext(
                                        song,
                                        songs,
                                      );
                                    },
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // Recommended for You
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      SectionHeader(
                        title: 'Recommended for You',
                        onSeeAllTap: () {
                          Navigator.of(context).push(
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      RecommendedSongsScreen(),
                              transitionsBuilder:
                                  (
                                    context,
                                    animation,
                                    secondaryAnimation,
                                    child,
                                  ) {
                                    const begin = Offset(1.0, 0.0);
                                    const end = Offset.zero;
                                    const curve = Curves.easeInOut;
                                    var slideTween = Tween(
                                      begin: begin,
                                      end: end,
                                    ).chain(CurveTween(curve: curve));
                                    var fadeTween = Tween<double>(
                                      begin: 0.0,
                                      end: 1.0,
                                    ).chain(CurveTween(curve: curve));
                                    return SlideTransition(
                                      position: animation.drive(slideTween),
                                      child: FadeTransition(
                                        opacity: animation.drive(fadeTween),
                                        child: child,
                                      ),
                                    );
                                  },
                              transitionDuration: const Duration(
                                milliseconds: 300,
                              ),
                              reverseTransitionDuration: const Duration(
                                milliseconds: 300,
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(
                        height: 200,
                        child: Consumer<MusicPlayerProvider>(
                          builder: (context, playerProvider, _) {
                            final songs = playerProvider.recommendedSongs;
                            if (songs.isEmpty) {
                              return Center(
                                child: Text(
                                  'No recommendations yet.',
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.white70
                                        : Colors.black54,
                                  ),
                                ),
                              );
                            }
                            return ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              itemCount: songs.length > 10 ? 10 : songs.length,
                              itemBuilder: (context, index) {
                                final song = songs[index];
                                return MusicCard(
                                  title: song.title,
                                  subtitle: song.artist,
                                  songId: int.tryParse(song.id),
                                  onTap: () {
                                    playerProvider.playWithContext(song, songs);
                                  },
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // Categories Grid
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      SectionHeader(
                        title: 'Browse Categories',
                        onSeeAllTap: null,
                      ),
                      CategoryGrid(
                        onSongsTap: () {
                          Navigator.of(context).push(
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      const AllSongsScreen(),
                              transitionsBuilder:
                                  (
                                    context,
                                    animation,
                                    secondaryAnimation,
                                    child,
                                  ) {
                                    const begin = Offset(1.0, 0.0);
                                    const end = Offset.zero;
                                    const curve = Curves.easeInOut;
                                    var slideTween = Tween(
                                      begin: begin,
                                      end: end,
                                    ).chain(CurveTween(curve: curve));
                                    var fadeTween = Tween<double>(
                                      begin: 0.0,
                                      end: 1.0,
                                    ).chain(CurveTween(curve: curve));
                                    return SlideTransition(
                                      position: animation.drive(slideTween),
                                      child: FadeTransition(
                                        opacity: animation.drive(fadeTween),
                                        child: child,
                                      ),
                                    );
                                  },
                              transitionDuration: const Duration(
                                milliseconds: 300,
                              ),
                              reverseTransitionDuration: const Duration(
                                milliseconds: 300,
                              ),
                            ),
                          );
                        },
                        onAlbumsTap: () {
                          Navigator.of(context).push(
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      const AlbumsScreen(),
                              transitionsBuilder:
                                  (
                                    context,
                                    animation,
                                    secondaryAnimation,
                                    child,
                                  ) {
                                    const begin = Offset(1.0, 0.0);
                                    const end = Offset.zero;
                                    const curve = Curves.easeInOut;
                                    var slideTween = Tween(
                                      begin: begin,
                                      end: end,
                                    ).chain(CurveTween(curve: curve));
                                    var fadeTween = Tween<double>(
                                      begin: 0.0,
                                      end: 1.0,
                                    ).chain(CurveTween(curve: curve));
                                    return SlideTransition(
                                      position: animation.drive(slideTween),
                                      child: FadeTransition(
                                        opacity: animation.drive(fadeTween),
                                        child: child,
                                      ),
                                    );
                                  },
                              transitionDuration: const Duration(
                                milliseconds: 300,
                              ),
                              reverseTransitionDuration: const Duration(
                                milliseconds: 300,
                              ),
                            ),
                          );
                        },
                        onArtistsTap: () {
                          Navigator.of(context).push(
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      const ArtistsScreen(),
                              transitionsBuilder:
                                  (
                                    context,
                                    animation,
                                    secondaryAnimation,
                                    child,
                                  ) {
                                    const begin = Offset(1.0, 0.0);
                                    const end = Offset.zero;
                                    const curve = Curves.easeInOut;
                                    var slideTween = Tween(
                                      begin: begin,
                                      end: end,
                                    ).chain(CurveTween(curve: curve));
                                    var fadeTween = Tween<double>(
                                      begin: 0.0,
                                      end: 1.0,
                                    ).chain(CurveTween(curve: curve));
                                    return SlideTransition(
                                      position: animation.drive(slideTween),
                                      child: FadeTransition(
                                        opacity: animation.drive(fadeTween),
                                        child: child,
                                      ),
                                    );
                                  },
                              transitionDuration: const Duration(
                                milliseconds: 300,
                              ),
                              reverseTransitionDuration: const Duration(
                                milliseconds: 300,
                              ),
                            ),
                          );
                        },
                        onFavoritesTap: () {
                          Navigator.of(context).push(
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      const FavoritesScreen(),
                              transitionsBuilder:
                                  (
                                    context,
                                    animation,
                                    secondaryAnimation,
                                    child,
                                  ) {
                                    const begin = Offset(1.0, 0.0);
                                    const end = Offset.zero;
                                    const curve = Curves.easeInOut;
                                    var slideTween = Tween(
                                      begin: begin,
                                      end: end,
                                    ).chain(CurveTween(curve: curve));
                                    var fadeTween = Tween<double>(
                                      begin: 0.0,
                                      end: 1.0,
                                    ).chain(CurveTween(curve: curve));
                                    return SlideTransition(
                                      position: animation.drive(slideTween),
                                      child: FadeTransition(
                                        opacity: animation.drive(fadeTween),
                                        child: child,
                                      ),
                                    );
                                  },
                              transitionDuration: const Duration(
                                milliseconds: 300,
                              ),
                              reverseTransitionDuration: const Duration(
                                milliseconds: 300,
                              ),
                            ),
                          );
                        },
                        onPlaylistsTap: () {
                          Navigator.of(context).push(
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      const PlaylistScreen(),
                              transitionsBuilder:
                                  (
                                    context,
                                    animation,
                                    secondaryAnimation,
                                    child,
                                  ) {
                                    const begin = Offset(1.0, 0.0);
                                    const end = Offset.zero;
                                    const curve = Curves.easeInOut;
                                    var slideTween = Tween(
                                      begin: begin,
                                      end: end,
                                    ).chain(CurveTween(curve: curve));
                                    var fadeTween = Tween<double>(
                                      begin: 0.0,
                                      end: 1.0,
                                    ).chain(CurveTween(curve: curve));
                                    return SlideTransition(
                                      position: animation.drive(slideTween),
                                      child: FadeTransition(
                                        opacity: animation.drive(fadeTween),
                                        child: child,
                                      ),
                                    );
                                  },
                              transitionDuration: const Duration(
                                milliseconds: 300,
                              ),
                              reverseTransitionDuration: const Duration(
                                milliseconds: 300,
                              ),
                            ),
                          );
                        },
                        onFoldersTap: () {
                          Navigator.of(context).push(
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      const FolderScreen(),
                              transitionsBuilder:
                                  (
                                    context,
                                    animation,
                                    secondaryAnimation,
                                    child,
                                  ) {
                                    const begin = Offset(1.0, 0.0);
                                    const end = Offset.zero;
                                    const curve = Curves.easeInOut;
                                    var slideTween = Tween(
                                      begin: begin,
                                      end: end,
                                    ).chain(CurveTween(curve: curve));
                                    var fadeTween = Tween<double>(
                                      begin: 0.0,
                                      end: 1.0,
                                    ).chain(CurveTween(curve: curve));
                                    return SlideTransition(
                                      position: animation.drive(slideTween),
                                      child: FadeTransition(
                                        opacity: animation.drive(fadeTween),
                                        child: child,
                                      ),
                                    );
                                  },
                              transitionDuration: const Duration(
                                milliseconds: 300,
                              ),
                              reverseTransitionDuration: const Duration(
                                milliseconds: 300,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),

                // Mood Playlists
                SliverToBoxAdapter(
                  child: Consumer<MusicPlayerProvider>(
                    builder: (context, playerProvider, _) {
                      final moodPlaylists = playerProvider.moodPlaylists;
                      final moodNames = [
                        'Happy',
                        'Workout',
                        'Party',
                        'Chill',
                        'Sad',
                        'Focus',
                      ];
                      final moodIcons = [
                        Icons.sentiment_very_satisfied_rounded,
                        Icons.fitness_center_rounded,
                        Icons.celebration_rounded,
                        Icons.self_improvement_rounded,
                        Icons.sentiment_dissatisfied_rounded,
                        Icons.psychology_rounded,
                      ];

                      return Column(
                        children: [
                          const SizedBox(height: 8),
                          SectionHeader(
                            title: 'Mood Playlists',
                            onSeeAllTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const MoodPlaylistsScreen(),
                                ),
                              );
                            },
                          ),
                          SizedBox(
                            height: 200,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              itemCount: 6,
                              itemBuilder: (context, index) {
                                final moodName = moodNames[index];
                                final songs = moodPlaylists[moodName] ?? [];

                                // Get artwork - check custom art first, then albumArt
                                String artImage = '';
                                String? customArtPath;
                                if (songs.isNotEmpty) {
                                  customArtPath = playerProvider
                                      .getCustomArtForSong(songs.first.id);
                                  if (customArtPath != null &&
                                      customArtPath.isNotEmpty) {
                                    artImage = customArtPath;
                                  } else if (songs.first.albumArt != null) {
                                    artImage = songs.first.albumArt!;
                                  }
                                }

                                return MoodMusicCard(
                                  title: moodName,
                                  subtitle: '${songs.length} songs',
                                  artImage: artImage,
                                  isCustomArt:
                                      customArtPath != null &&
                                      customArtPath.isNotEmpty,
                                  icon: moodIcons[index],
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => SongListScreen(
                                          title: moodName,
                                          songs: songs,
                                          showSearch: true,
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                // Favorite Artists
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      SectionHeader(
                        title: 'Favorite Artists',
                        onSeeAllTap: () {},
                      ),
                      SizedBox(
                        height: 200,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: 10,
                          itemBuilder: (context, index) {
                            return MusicCard(
                              title: 'Artist ${index + 1}',
                              subtitle: '${index + 10} songs',
                              isCircular: true,
                              onTap: () {},
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // Recently Added
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      SectionHeader(
                        title: 'Recently Added',
                        onSeeAllTap: () {},
                      ),
                      SizedBox(
                        height: 200,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: 10,
                          itemBuilder: (context, index) {
                            return MusicCard(
                              title: 'New Song ${index + 1}',
                              subtitle: 'Added today',
                              onTap: () {},
                            );
                          },
                        ),
                      ),
                      // Space for mini player and bottom nav
                      SizedBox(
                        height: playerProvider.currentSong != null ? 170 : 100,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Mini Player (shown when a song is playing)
          if (playerProvider.currentSong != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0, // Attached to bottom navigation
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [const MiniPlayer(), _buildBottomNavBar(isDark)],
              ),
            )
          else
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildBottomNavBar(isDark),
            ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tabs = ['Home', 'Quick Pick', 'Favorites', 'Mood'];

    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedTab == index;
          return GestureDetector(
            onTap: () {
              setState(() => _selectedTab = index);
            },
            child: Container(
              margin: EdgeInsets.only(left: index == 0 ? 20 : 0, right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
              decoration: BoxDecoration(
                color: isSelected
                    ? (isDark ? Colors.white : Colors.black87)
                    : (isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.grey[200]),
                borderRadius: BorderRadius.circular(18),
                border: isSelected
                    ? null
                    : Border.all(
                        color: isDark ? Colors.white24 : Colors.grey[300]!,
                      ),
              ),
              child: Center(
                child: Text(
                  tabs[index],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? (isDark ? Colors.black : Colors.white)
                        : (isDark ? Colors.white70 : Colors.black54),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomNavBar(bool isDark) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home_rounded, 'Home', true, isDark),
          _buildNavItem(Icons.explore_rounded, 'Explore', false, isDark),
          _buildNavItem(Icons.favorite_rounded, 'Favorites', false, isDark),
          _buildNavItem(Icons.person_rounded, 'Profile', false, isDark),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String label,
    bool isActive,
    bool isDark,
  ) {
    final activeColor = isDark
        ? const Color(0xFFFFA726)
        : const Color(0xFFFF7043);
    final inactiveColor = isDark ? Colors.white54 : Colors.black54;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: isActive ? activeColor : inactiveColor, size: 28),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            color: isActive ? activeColor : inactiveColor,
          ),
        ),
      ],
    );
  }
}

class MoodMusicCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String artImage;
  final bool isCustomArt;
  final IconData icon;
  final VoidCallback onTap;

  const MoodMusicCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.artImage,
    this.isCustomArt = false,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final moodColors = {
      'Happy': isDark ? const Color(0xFFFFA726) : const Color(0xFFFFB74D),
      'Workout': isDark ? const Color(0xFFEF5350) : const Color(0xFFE57373),
      'Party': isDark ? const Color(0xFFAB47BC) : const Color(0xFFBA68C8),
      'Chill': isDark ? const Color(0xFF26C6DA) : const Color(0xFF4DD0E1),
      'Sad': isDark ? const Color(0xFF5C6BC0) : const Color(0xFF7986CB),
      'Focus': isDark ? const Color(0xFF66BB6A) : const Color(0xFF81C784),
    };

    final cardColor =
        moodColors[title] ??
        (isDark ? const Color(0xFFFFA726) : const Color(0xFFFF7043));

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              color: cardColor,
              boxShadow: [
                BoxShadow(
                  color: cardColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Background artwork with gradient overlay (60% from top)
                if (artImage.isNotEmpty)
                  Positioned.fill(
                    child: Stack(
                      children: [
                        isCustomArt
                            ? Image.file(
                                File(artImage),
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const SizedBox.shrink(),
                              )
                            : CachedArtworkWidget(
                                songId: artImage,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                                fallback: const SizedBox.shrink(),
                              ),
                        // Gradient overlay - clear at top 30%, darker at bottom
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                stops: const [0.0, 0.3, 0.6, 1.0],
                                colors: [
                                  Colors.transparent,
                                  Colors.transparent,
                                  cardColor.withOpacity(0.75),
                                  cardColor.withOpacity(0.95),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                // Content with shadow for better visibility
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black54,
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.95),
                          shadows: const [
                            Shadow(
                              color: Colors.black54,
                              blurRadius: 6,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Icon in bottom right corner
                Positioned(
                  bottom: 18,
                  right: 16,
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 36,
                    shadows: const [
                      Shadow(
                        color: Colors.black87,
                        blurRadius: 12,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
