import 'package:flutter/material.dart';
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
import '../../../main.dart' show themeNotifier;

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
                        onTap: () {
                          // Navigate to search screen
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
                            MaterialPageRoute(
                              builder: (context) => RecentlyPlayedScreen(),
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
                                      playerProvider.playSong(song);
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
                            MaterialPageRoute(
                              builder: (context) => RecommendedSongsScreen(),
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
                                    playerProvider.playSong(song);
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
                            MaterialPageRoute(
                              builder: (context) => const AllSongsScreen(),
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
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      SectionHeader(
                        title: 'Mood Playlists',
                        onSeeAllTap: () {},
                      ),
                      SizedBox(
                        height: 200,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: 6,
                          itemBuilder: (context, index) {
                            final moods = [
                              'Happy Vibes',
                              'Chill',
                              'Workout',
                              'Party',
                              'Sad',
                              'Focus',
                            ];
                            return MusicCard(
                              title: moods[index],
                              subtitle: 'Auto-generated',
                              onTap: () {},
                            );
                          },
                        ),
                      ),
                    ],
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
