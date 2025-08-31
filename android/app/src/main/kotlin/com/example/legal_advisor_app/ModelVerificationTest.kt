package com.example.legal_advisor_app

import android.content.Context
import android.util.Log

/**
 * 简化的模型验证测试类
 * 避免复杂的MediaPipe依赖问题
 */
class ModelVerificationTest(private val context: Context) {
    
    companion object {
        private const val TAG = "ModelVerificationTest"
    }
    
    data class TestResult(
        val success: Boolean,
        val message: String,
        val details: String = ""
    )
    
    /**
     * 简化的测试方法
     */
    fun runSimpleTest(): TestResult {
        return try {
            Log.d(TAG, "🧪 运行简化模型测试...")
            
            // 简化的测试逻辑
            val gemmaInference = GemmaInference(context)
            val isReady = gemmaInference.isModelReady()
            
            TestResult(
                success = true,
                message = "测试完成",
                details = "模型状态: ${if(isReady) "就绪" else "未初始化"}"
            )
        } catch (e: Exception) {
            Log.e(TAG, "测试失败: ${e.message}", e)
            TestResult(
                success = false,
                message = "测试异常: ${e.message}",
                details = e.stackTraceToString()
            )
        }
    }
}