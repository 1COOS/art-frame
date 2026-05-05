package com.example.art_frame

import android.content.Intent
import android.net.Uri
import android.os.Environment
import android.provider.DocumentsContract
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private companion object {
        const val CHANNEL = "art_frame/folder_opener"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "openFolder" -> {
                        val path = call.argument<String>("path")
                        if (path != null) {
                            result.success(openFolder(path))
                        } else {
                            result.error("INVALID_ARGUMENT", "path is required", null)
                        }
                    }
                    "openGallery" -> result.success(openGallery())
                    else -> result.notImplemented()
                }
            }
    }

    private fun openFolder(path: String): Boolean {
        val externalRoot = Environment.getExternalStorageDirectory().absolutePath
        if (path.startsWith(externalRoot)) {
            val relative = path.removePrefix(externalRoot).removePrefix("/")
            val docId = "primary:$relative"
            val uri = DocumentsContract.buildDocumentUri(
                "com.android.externalstorage.documents", docId
            )
            if (launchViewIntent(uri, "vnd.android.document/directory")) return true
        }

        // Fallback: open the root of external storage.
        val rootUri = DocumentsContract.buildRootUri(
            "com.android.externalstorage.documents", "primary"
        )
        return launchViewIntent(rootUri, "vnd.android.document/root")
    }

    private fun openGallery(): Boolean {
        return try {
            val intent = Intent(Intent.ACTION_MAIN).apply {
                addCategory(Intent.CATEGORY_APP_GALLERY)
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            startActivity(intent)
            true
        } catch (_: Exception) {
            false
        }
    }

    private fun launchViewIntent(uri: Uri, mimeType: String): Boolean {
        return try {
            val intent = Intent(Intent.ACTION_VIEW).apply {
                setDataAndType(uri, mimeType)
                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            }
            startActivity(intent)
            true
        } catch (_: Exception) {
            false
        }
    }
}
