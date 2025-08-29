package com.example.legal_advisor_app

import android.util.Log
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class LlamaRunner(flutterEngine: FlutterEngine) {
  private val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "llama_runner")

  init {
    channel.setMethodCallHandler { call, result ->
      when (call.method) {
        "init" -> {
          // 占位实现
          result.success(true)
        }
        "generate" -> {
          val prompt = call.argument<String>("prompt") ?: ""
          result.success("[占位回复] 我已收到提示：${prompt.take(80)}")
        }
        "unload" -> {
          result.success(null)
        }
        else -> result.notImplemented()
      }
    }
  }
}

