import 'dart:io';
import 'dart:typed_data';
import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../../providers/music_player_provider.dart';

class CoverCropperScreen extends StatefulWidget {
  final String imageUrl;
  final String songId;
  final bool isDark;
  final Function(File croppedFile) onCropped;
  const CoverCropperScreen({
    super.key,
    required this.imageUrl,
    required this.songId,
    required this.isDark,
    required this.onCropped,
  });

  @override
  State<CoverCropperScreen> createState() => _CoverCropperScreenState();
}

class _CoverCropperScreenState extends State<CoverCropperScreen> {
  File? _croppedFile;
  bool _isCropping = false;
  Uint8List? _imageBytes;
  final CropController _cropController = CropController();
  bool _showCrop = false;

  @override
  void initState() {
    super.initState();
    _downloadImage();
  }

  Future<void> _downloadImage() async {
    setState(() => _isCropping = true);
    try {
      final response = await http.get(Uri.parse(widget.imageUrl));
      if (response.statusCode == 200) {
        setState(() {
          _imageBytes = response.bodyBytes;
          _showCrop = true;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to download image: ${response.statusCode}'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
    setState(() => _isCropping = false);
  }

  Future<void> _onCropped(Uint8List croppedData) async {
    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/cropped_cover.png');
    await tempFile.writeAsBytes(croppedData);
    setState(() {
      _croppedFile = tempFile;
      _showCrop = false;
    });
    // Update provider with new art
    Provider.of<MusicPlayerProvider>(
      context,
      listen: false,
    ).setCustomArtForSong(widget.songId, tempFile.path);
    widget.onCropped(tempFile);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF232323) : Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            if (_isCropping) const Center(child: CircularProgressIndicator()),
            if (_showCrop && _imageBytes != null)
              Crop(
                image: _imageBytes!,
                controller: _cropController,
                aspectRatio: 1,
                onCropped: _onCropped,
                withCircleUi: false,
                baseColor: isDark ? const Color(0xFF232323) : Colors.white,
                maskColor: Colors.black.withOpacity(0.4),
                cornerDotBuilder: (size, index) => Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white : Colors.orange,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            if (_croppedFile != null)
              Center(child: Image.file(_croppedFile!, fit: BoxFit.contain)),
            Positioned(
              left: 0,
              top: 0,
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                color: isDark ? Colors.white : Colors.black,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            if (_showCrop)
              Positioned(
                right: 0,
                top: 0,
                child: IconButton(
                  icon: const Icon(Icons.check),
                  color: isDark ? Colors.white : Colors.black,
                  onPressed: () => _cropController.crop(),
                ),
              ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      isDark
                          ? 'assets/logo/logo_white.png'
                          : 'assets/logo/logo.png',
                      width: 36,
                      height: 36,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 8),
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
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
