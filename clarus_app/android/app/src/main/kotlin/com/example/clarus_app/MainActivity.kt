package com.example.clarus_app

import android.content.ContentValues
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
	private val storageChannel = "clarus/storage"

	override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
		super.configureFlutterEngine(flutterEngine)

		MethodChannel(flutterEngine.dartExecutor.binaryMessenger, storageChannel)
			.setMethodCallHandler { call, result ->
				if (call.method != "savePdfToDownloads") {
					result.notImplemented()
					return@setMethodCallHandler
				}

				val name = call.argument<String>("name")
				val bytes = call.argument<ByteArray>("bytes")
				if (name == null || bytes == null) {
					result.error("INVALID_FILE", "A file name and bytes are required.", null)
					return@setMethodCallHandler
				}

				try {
					if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
						val values = ContentValues().apply {
							put(MediaStore.Downloads.DISPLAY_NAME, name)
							put(MediaStore.Downloads.MIME_TYPE, "application/pdf")
							put(
								MediaStore.Downloads.RELATIVE_PATH,
								Environment.DIRECTORY_DOWNLOADS
							)
						}
						val uri = contentResolver.insert(
							MediaStore.Downloads.EXTERNAL_CONTENT_URI,
							values
						)
						if (uri == null) {
							result.error("SAVE_FAILED", "Could not create the Downloads file.", null)
							return@setMethodCallHandler
						}
						contentResolver.openOutputStream(uri)?.use { it.write(bytes) }
						result.success(uri.toString())
					} else {
						val directory = Environment.getExternalStoragePublicDirectory(
							Environment.DIRECTORY_DOWNLOADS
						)
						if (!directory.exists()) directory.mkdirs()
						val file = java.io.File(directory, name)
						file.writeBytes(bytes)
						result.success(file.absolutePath)
					}
				} catch (error: Exception) {
					result.error("SAVE_FAILED", error.message, null)
				}
			}
	}
}
