import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/music_player_provider.dart';
import '../widgets/cached_artwork_widget.dart';

class EditTagsPage extends StatefulWidget {
  final dynamic song;
  final bool isDark;
  const EditTagsPage({super.key, required this.song, required this.isDark});

  @override
  State<EditTagsPage> createState() => _EditTagsPageState();
}

class _EditTagsPageState extends State<EditTagsPage> {
  late TextEditingController titleController;
  late TextEditingController albumController;
  late TextEditingController artistController;
  late TextEditingController genreController;
  late TextEditingController trackController;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.song.title);
    albumController = TextEditingController(text: widget.song.album ?? '');
    artistController = TextEditingController(text: widget.song.artist ?? '');
    genreController = TextEditingController(text: widget.song.genre ?? '');
    trackController = TextEditingController(
      text: widget.song.trackNumber?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    albumController.dispose();
    artistController.dispose();
    genreController.dispose();
    trackController.dispose();
    super.dispose();
  }

  void _saveTags() {
    // Update song info in provider or model
    final provider = Provider.of<MusicPlayerProvider>(context, listen: false);
    provider.updateSongTags(
      widget.song.id,
      title: titleController.text,
      album: albumController.text,
      artist: artistController.text,
      genre: genreController.text,
      trackNumber: int.tryParse(trackController.text),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final song = widget.song;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF232323) : Colors.white,
      body: Column(
        children: [
          SafeArea(
            child: Container(
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              alignment: Alignment.center,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Spacer(),
                  const Text(
                    'Edit Tags',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                    onPressed: _saveTags,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child:
                            song.customArtPath != null &&
                                song.customArtPath.isNotEmpty
                            ? Image.file(
                                File(song.customArtPath),
                                width: 160,
                                height: 160,
                                fit: BoxFit.cover,
                              )
                            : (song.albumArt != null
                                  ? CachedArtworkWidget(
                                      songId: song.albumArt!,
                                      width: 160,
                                      height: 160,
                                      fit: BoxFit.cover,
                                      borderRadius: BorderRadius.circular(18),
                                      fallback: Container(
                                        width: 160,
                                        height: 160,
                                        color: Colors.grey[400],
                                        child: const Icon(
                                          Icons.music_note_rounded,
                                          color: Colors.white,
                                          size: 80,
                                        ),
                                      ),
                                    )
                                  : Container(
                                      width: 160,
                                      height: 160,
                                      color: Colors.grey[400],
                                      child: const Icon(
                                        Icons.music_note_rounded,
                                        color: Colors.white,
                                        size: 80,
                                      ),
                                    )),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Editable Fields
                    _buildEditableField('Title', titleController, isDark),
                    _buildEditableField('Album', albumController, isDark),
                    _buildEditableField('Artist', artistController, isDark),
                    _buildEditableField('Genre', genreController, isDark),
                    _buildEditableField(
                      'Track Number',
                      trackController,
                      isDark,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 32),
                    // Bottom Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDark
                                  ? Colors.white10
                                  : Colors.grey[200],
                              foregroundColor: isDark
                                  ? Colors.white
                                  : Colors.black87,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              elevation: 0,
                            ),
                            onPressed: () {
                              // Navigate to change cover page
                              Navigator.of(
                                context,
                              ).pushNamed('/changeCover', arguments: song);
                            },
                            child: const Text(
                              'Change Cover',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDark
                                  ? const Color(0xFFFFA726)
                                  : const Color(0xFFFF7043),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              elevation: 0,
                            ),
                            onPressed: () {
                              // Fetch info logic here
                              Provider.of<MusicPlayerProvider>(
                                context,
                                listen: false,
                              ).fetchSongInfo(song.id);
                            },
                            child: const Text(
                              'Fetch Info',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableField(
    String label,
    TextEditingController controller,
    bool isDark, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: isDark ? Colors.white70 : Colors.black54,
            fontWeight: FontWeight.w600,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(
              color: isDark ? Colors.white24 : Colors.black12,
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(
              color: isDark ? const Color(0xFFFFA726) : const Color(0xFFFF7043),
              width: 2,
            ),
          ),
          fillColor: isDark ? Colors.white10 : Colors.grey[100],
          filled: true,
        ),
      ),
    );
  }
}
