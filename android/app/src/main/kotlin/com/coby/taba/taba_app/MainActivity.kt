package com.coby.taba

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.coby.taba/app_badge"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "updateBadge" -> {
                    // Android에서는 뱃지 지원이 제한적이므로
                    // 일단 성공으로 반환 (iOS에서만 실제로 동작)
                    result.success(null)
                }
                "removeBadge" -> {
                    // Android에서는 뱃지 지원이 제한적이므로
                    // 일단 성공으로 반환 (iOS에서만 실제로 동작)
                    result.success(null)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}
