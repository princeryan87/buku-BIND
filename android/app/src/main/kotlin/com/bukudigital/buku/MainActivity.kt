package com.bukudigital.buku

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.bukudigital/assets"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "readString" -> {
                        val path = call.argument<String>("path") ?: ""
                        try {
                            val text = assets.open(path).bufferedReader().use { it.readText() }
                            result.success(text)
                        } catch (e: Exception) { result.error("READ_ERROR", e.message, null) }
                    }
                    "readBytes" -> {
                        val path = call.argument<String>("path") ?: ""
                        try {
                            val bytes = assets.open(path).use { it.readBytes() }
                            result.success(bytes)
                        } catch (e: Exception) { result.error("READ_ERROR", e.message, null) }
                    }
                    "listFiles" -> {
                        val path = call.argument<String>("path") ?: ""
                        try {
                            val files = assets.list(path)?.toList() ?: emptyList<String>()
                            result.success(files)
                        } catch (e: Exception) { result.error("LIST_ERROR", e.message, null) }
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
