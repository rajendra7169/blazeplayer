# Music Home Screen - Component Architecture

## 📁 File Structure

```
lib/features/home/
├── models/
│   └── music_models.dart          # Data models (Song, Album, Artist, Playlist)
├── screens/
│   ├── home_screen.dart           # Old home screen (Firebase integrated)
│   └── music_home_screen.dart     # New offline music player home
└── widgets/
    ├── featured_album_card.dart   # Spotify-style featured card
    ├── greeting_header.dart       # Dynamic greeting (Good Morning/Evening)
    ├── search_bar_widget.dart     # Search bar UI
    ├── section_header.dart        # Reusable section header
    ├── music_card.dart            # Album/Song card component
    └── category_grid.dart         # 6-category grid layout
```

## 🎨 Home Screen Sections (in order)

### 1. **Greeting Header**

- Dynamic greeting based on time of day
- User name display
- Settings icon

### 2. **Search Bar**

- Search songs, albums, artists
- Tappable → navigates to search screen

### 3. **Featured Album Card** 🌟

- Large green card (Spotify-style)
- Image pops out from top-right
- "NEW ALBUM" badge
- Play button overlay
- Hero animation ready

### 4. **Tab Bar**

- News / Video / Artist / Podcast
- Horizontal scrollable tabs

### 5. **Recently Played**

- Horizontal scrollable list
- Shows last played songs
- Album art + title + artist

### 6. **Recommended for You**

- Auto-generated recommendations
- Based on listening history

### 7. **Browse Categories Grid**

- Songs (Red)
- Albums (Teal)
- Artists (Yellow)
- Playlists (Purple)
- Folders (Pink)
- Favorites (Red)

### 8. **Mood Playlists**

- Happy Vibes
- Chill
- Workout
- Party
- Sad
- Focus

### 9. **Favorite Artists**

- Circular artist images
- Song count display

### 10. **Recently Added**

- Shows newly added songs
- Helps discover new content

### 11. **Bottom Navigation Bar**

- Home (active)
- Explore
- Favorites
- Profile

## 🚀 Usage

### Navigate to Music Home Screen:

```dart
Navigator.of(context).pushNamed('/music-home');
```

### Or replace current route:

```dart
Navigator.of(context).pushReplacementNamed('/music-home');
```

## 🎯 Features Implemented

✅ **Component-Based Architecture** - Easy to maintain and extend
✅ **Theme Support** - Adapts to light/dark mode automatically
✅ **Spotify-Style Design** - Modern, beautiful UI
✅ **Modular Widgets** - Reusable across the app
✅ **Hero Animations** - Ready for page transitions
✅ **Responsive Layout** - Works on all screen sizes
✅ **Offline-First** - No internet required

## 📝 Next Steps

### To Make it Fully Functional:

1. **Add Music Library Service**

   - Scan device for music files
   - Parse metadata (artist, album, duration)
   - Generate thumbnails from embedded art

2. **Implement Data Providers**

   - MusicProvider (using ChangeNotifier)
   - Manage playlists, favorites, play counts

3. **Connect Real Data**

   - Replace dummy data with actual songs
   - Implement search functionality
   - Add filtering and sorting

4. **Add Music Player**

   - Bottom mini-player widget
   - Full-screen player
   - Playback controls

5. **Implement Smart Features**
   - Most played tracking
   - Auto-generate mood playlists
   - Recommendation algorithm

## 🎨 Color Scheme

- **Primary Accent (Orange)**: `#FFA726` / `#FF7043`
- **Spotify Green**: `#1DB954`
- **Background Dark**: `#121212`
- **Background Light**: `#FFFFFF`
- **Card Dark**: `#1E1E1E`

## 📦 Required Packages (Future)

```yaml
dependencies:
  # Audio playback
  just_audio: ^latest
  audio_service: ^latest

  # File scanning
  permission_handler: ^latest
  path_provider: ^latest

  # Metadata parsing
  flutter_audio_query: ^latest
  # or
  on_audio_query: ^latest

  # State management (already have)
  provider: ^latest
```

## 🔧 Customization

### Change Featured Card Color:

```dart
FeaturedAlbumCard(
  backgroundColor: Color(0xFFE91E63), // Pink
  // ...
)
```

### Add Custom Categories:

Edit `category_grid.dart`:

```dart
final categories = [
  {'title': 'Your Title', 'icon': Icons.your_icon, 'color': Color(0xFFYourColor)},
  // ...
];
```

### Modify Greeting:

Edit `greeting_header.dart` `_getGreeting()` method

---

## 🎉 Current Status

✅ UI Components Created
✅ Home Screen Layout Complete
✅ Theme Integration
✅ Navigation Routes Added
⏳ Music Library Integration (Next)
⏳ Audio Player Integration (Next)
⏳ Data Persistence (Next)

---

**Created by:** Copilot for Raja
**Date:** November 26, 2025
**App:** Blaze Player - Offline Music Player
