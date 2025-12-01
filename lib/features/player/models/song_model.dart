class Song {
  final String id;
  final String title;
  final String artist;
  final String album;
  final String? albumArt;
  final Duration duration;
  final String filePath;
  final int playCount;
  final String? genre;
  final int dateAdded;
  final int? trackNumber;
  final String? customArtPath;

  Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    this.albumArt,
    required this.duration,
    required this.filePath,
    this.playCount = 0,
    this.genre,
    this.dateAdded = 0,
    this.trackNumber,
    this.customArtPath,
  });

  // Dummy songs for testing
  static List<Song> getDummySongs() {
    return [
      Song(
        id: '1',
        title: 'All Of Me',
        artist: 'Nao',
        album: 'Saturn',
        albumArt: null,
        duration: const Duration(minutes: 3, seconds: 45),
        filePath: '',
        playCount: 10,
        genre: 'Soul',
      ),
      Song(
        id: '2',
        title: 'Blinding Lights',
        artist: 'The Weeknd',
        album: 'After Hours',
        albumArt: null,
        duration: const Duration(minutes: 3, seconds: 20),
        filePath: '',
        playCount: 25,
        genre: 'Pop',
      ),
      Song(
        id: '3',
        title: 'Levitating',
        artist: 'Dua Lipa',
        album: 'Future Nostalgia',
        albumArt: null,
        duration: const Duration(minutes: 3, seconds: 23),
        filePath: '',
        playCount: 15,
        genre: 'Pop',
      ),
    ];
  }

  Song copyWith({
    String? id,
    String? title,
    String? artist,
    String? album,
    String? albumArt,
    Duration? duration,
    String? filePath,
    int? playCount,
    String? genre,
    int? dateAdded,
    int? trackNumber,
    String? customArtPath,
  }) {
    return Song(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      albumArt: albumArt ?? this.albumArt,
      duration: duration ?? this.duration,
      filePath: filePath ?? this.filePath,
      playCount: playCount ?? this.playCount,
      genre: genre ?? this.genre,
      dateAdded: dateAdded ?? this.dateAdded,
      trackNumber: trackNumber ?? this.trackNumber,
      customArtPath: customArtPath ?? this.customArtPath,
    );
  }
}
