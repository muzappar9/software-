package com.example.legal_advisor_app

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
  private val CHANNEL = "llama_runner"

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
      when (call.method) {
        "init" -> result.success(null)
        "generate" -> {
          val prompt = call.argument<String>("prompt") ?: ""
          val text = if (prompt.contains("提问意图"))
            "请问你们结婚几年了？目前是否分居？"
          else
            "【基本判断】根据已知情况建议先行调解并准备证据。\n【下一步建议】1) 准备分居与照料证据；2) 整理房产与流水；3) 协商不成再起诉。\n【免责声明】此为一般性信息，非正式法律意见。"
          result.success(text)
        }
        "unload" -> result.success(null)
        else -> result.notImplemented()
      }
    }
  }
}
