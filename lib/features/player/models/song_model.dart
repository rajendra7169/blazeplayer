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
}
