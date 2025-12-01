package com.example.blazeplayer_master

import android.media.MediaScannerConnection
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.jaudiotagger.audio.AudioFileIO
import org.jaudiotagger.tag.FieldKey

class MainActivity : FlutterActivity() {
	private val CHANNEL = "blazeplayer/tag_editor"

	override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
		super.configureFlutterEngine(flutterEngine)

		MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
			if (call.method == "saveTags") {
				val filePath = call.argument<String>("filePath")
				val title = call.argument<String>("title")
				val album = call.argument<String>("album")
				val artist = call.argument<String>("artist")
				val genre = call.argument<String>("genre")
				val trackNumber = call.argument<String>("trackNumber")
				try {
					val file = java.io.File(filePath)
					val audioFile = AudioFileIO.read(file)
					val tag = audioFile.tagOrCreateAndSetDefault
					if (title != null) tag.setField(FieldKey.TITLE, title)
					if (album != null) tag.setField(FieldKey.ALBUM, album)
					if (artist != null) tag.setField(FieldKey.ARTIST, artist)
					if (genre != null) tag.setField(FieldKey.GENRE, genre)
					if (trackNumber != null) tag.setField(FieldKey.TRACK, trackNumber)
					audioFile.commit()
					
					// Trigger media scan to update Android's MediaStore database
					MediaScannerConnection.scanFile(
						applicationContext,
						arrayOf(file.absolutePath),
						null
					) { path, uri ->
						android.util.Log.d("TAG_EDITOR", "Media scan completed for: $path")
					}
					
					result.success(true)
				} catch (e: Exception) {
					result.error("TAG_ERROR", "Failed to save tags: ${e.message}", null)
				}
			} else {
				result.notImplemented()
			}
		}
	}
}
