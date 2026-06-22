package com.neonlauncher.geode_mod_manager

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "com.neonlauncher.geode_mod_manager/app"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                if (call.method == "isAppInstalled") {
                    val packageName = call.argument<String>("packageName")
                    if (packageName.isNullOrBlank()) {
                        result.error("INVALID", "packageName required", null)
                    } else {
                        val installed =
                            packageManager.getLaunchIntentForPackage(packageName) != null
                        result.success(installed)
                    }
                } else {
                    result.notImplemented()
                }
            }
    }
}
