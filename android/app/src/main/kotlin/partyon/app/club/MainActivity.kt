package hashtag.partyonDemo.partner

import android.content.Intent
import android.net.Uri
import androidx.core.content.FileProvider
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    private val WHATSAPP_CHANNEL = "custom.whatsapp.share"
    private val INSTAGRAM_CHANNEL = "instagramshare"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // WhatsApp Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, WHATSAPP_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "shareToWhatsApp") {
                val text = call.argument<String>("text") ?: ""
                val imagePath = call.argument<String>("imagePath") ?: ""
                val isBusiness = call.argument<Boolean>("isBusiness") ?: false
                val file = File(imagePath)

                val uri = FileProvider.getUriForFile(this, "$packageName.fileprovider", file)

                val sendIntent = Intent().apply {
                    action = Intent.ACTION_SEND
                    putExtra(Intent.EXTRA_TEXT, text)
                    putExtra(Intent.EXTRA_STREAM, uri)
                    type = "image/*"
                    `package` = if (isBusiness) "com.whatsapp.w4b" else "com.whatsapp"
                    addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                }

                if (sendIntent.resolveActivity(packageManager) != null) {
                    startActivity(sendIntent)
                    result.success("Success")
                } else {
                    result.error("UNAVAILABLE", "WhatsApp not installed", null)
                }
            }
        }

        // Instagram Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, INSTAGRAM_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "shareMultiple" -> {
                    val filePaths = call.argument<List<String>>("filePaths")
                    if (filePaths != null) {
                        shareMultipleToInstagram(filePaths)
                        result.success("Success")
                    } else {
                        result.error("ERROR", "File paths are null", null)
                    }
                }
                "share" -> {
                    val filePath = call.argument<String>("filePath")
                    val fileType = call.argument<String>("fileType")
                    if (filePath != null && fileType != null) {
                        shareToInstagram(filePath, fileType)
                        result.success("Success")
                    } else {
                        result.error("ERROR", "File path or type is null", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun shareMultipleToInstagram(filePaths: List<String>) {
        val uris = ArrayList<Uri>()
        for (path in filePaths) {
            val file = File(path)
            val uri = FileProvider.getUriForFile(this, "$packageName.fileprovider", file)
            uris.add(uri)
        }

        val intent = Intent(Intent.ACTION_SEND_MULTIPLE).apply {
            type = "*/*"
            putParcelableArrayListExtra(Intent.EXTRA_STREAM, uris)
            setPackage("com.instagram.android")
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        }

        try {
            startActivity(intent)
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun shareToInstagram(filePath: String, fileType: String) {
        val file = File(filePath)
        val uri = FileProvider.getUriForFile(this, "$packageName.fileprovider", file)

        val intent = Intent(Intent.ACTION_SEND).apply {
            type = when (fileType) {
                "video" -> "video/*"
                "image" -> "image/*"
                else -> "*/*"
            }
            putExtra(Intent.EXTRA_STREAM, uri)
            setPackage("com.instagram.android")
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        }

        startActivity(intent)
    }
}
