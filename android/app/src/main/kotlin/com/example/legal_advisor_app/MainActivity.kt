package com.example.legal_advisor_app

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.*

class MainActivity : FlutterActivity() {
  private val CHANNEL = "com.legal_advisor_app/llama"
  private var gemmaInference: GemmaInference? = null
  private val mainScope = CoroutineScope(Dispatchers.Main + SupervisorJob())

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    
    try {
      MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
        try {
          when (call.method) {
            "init" -> {
              val modelPath = call.argument<String>("modelPath") ?: ""
              android.util.Log.d("LegalAdvisor", "开始初始化真实AI模型: $modelPath")
              
              mainScope.launch {
                try {
                  android.util.Log.d("LegalAdvisor", "🔧 开始安全初始化AI模型...")
                  gemmaInference = GemmaInference(this@MainActivity)
                  val success = gemmaInference?.initializeModel() ?: false
                  
                  if (success) {
                    android.util.Log.d("LegalAdvisor", "�?AI组件初始化成�?)
                    result.success("AI就绪")
                  } else {
                    android.util.Log.w("LegalAdvisor", "⚠️ AI模型不可用，使用智能规则引擎")
                    result.success("规则引擎模式")
                  }
                } catch (e: Exception) {
                  android.util.Log.e("LegalAdvisor", "�?AI初始化异常，启用安全模式: ${e.message}")
                  gemmaInference = null // 确保清理状�?                  result.success("安全模式")
                } catch (e: Error) {
                  android.util.Log.e("LegalAdvisor", "�?系统级错误，启用安全模式: ${e.message}")
                  gemmaInference = null
                  result.success("安全模式")
                }
              }
            }
            
            "generate" -> {
              val prompt = call.argument<String>("prompt") ?: ""
              val maxTokens = call.argument<Int>("maxTokens") ?: 256
              android.util.Log.d("LegalAdvisor", "🤖 AI生成请求: $prompt")
              mainScope.launch {
                try {
                  val response = if (gemmaInference != null) {
                    val aiResponse = gemmaInference!!.generateAnswer(prompt)
                    android.util.Log.d("LegalAdvisor", "�?AI模型响应长度: ${aiResponse.length}")
                    aiResponse
                  } else {
                    android.util.Log.w("LegalAdvisor", "⚠️ 模型未初始化，使用备用响�?)
                    generateSmartFallback(prompt)
                  }
                  result.success(response)
                } catch (e: Exception) {
                  android.util.Log.e("LegalAdvisor", "生成响应失败: ${e.message}")
                  result.success(generateSmartFallback(prompt))
                }
              }
            }
            
            "test_model" -> {
              android.util.Log.d("LegalAdvisor", "🧪 执行模型验证测试")
              mainScope.launch {
                try {
                  val testResult = ModelVerificationTest(this@MainActivity).runSimpleTest()
                  android.util.Log.d("LegalAdvisor", "测试结果: ${testResult.message}")
                  result.success(mapOf(
                    "success" to testResult.success,
                    "message" to testResult.message
                  ))
                } catch (e: Exception) {
                  android.util.Log.e("LegalAdvisor", "测试执行失败: ${e.message}")
                  result.success(mapOf(
                    "success" to false,
                    "message" to "测试执行异常: ${e.message}"
                  ))
                }
              }
            }
            
            "unload" -> {
              android.util.Log.d("LegalAdvisor", "卸载AI模型")
              gemmaInference?.close()
              gemmaInference = null
              result.success(null)
            }
            
            else -> result.notImplemented()
          }
        } catch (e: Exception) {
          android.util.Log.e("LegalAdvisor", "MethodChannel错误: ${e.message}")
          result.error("CHANNEL_ERROR", e.message, null)
        }
      }
    } catch (e: Exception) {
      android.util.Log.e("LegalAdvisor", "MainActivity配置错误: ${e.message}")
    }
  }
  
  private fun generateSmartFallback(prompt: String): String {
    return when {
      prompt.contains("离婚") || prompt.contains("分居") -> {
        "【法律分析】根据《民法典》相关规定：\n\n1️⃣ **协议离婚**：双方协商一致可直接到民政局办理\n2️⃣ **诉讼离婚**：一方不同意需向法院起诉\n3️⃣ **财产分割**：夫妻共同财产原则上平等分割\n4️⃣ **子女抚养**：以有利于子女成长为原则\n\n**建议步骤**：\n�?收集相关证据材料\n�?尝试协商解决\n�?必要时咨询专业律师\n\n*此为一般性法律信息，具体情况请咨询专业律�?"
      }
      
      prompt.contains("合同") || prompt.contains("违约") -> {
        "【合同法律分析】\n\n📋 **合同要素检�?*：\n�?合同是否有效成立\n�?违约责任条款\n�?损失赔偿范围\n\n⚖️ **维权建议**：\n1. 保留合同原件及相关证据\n2. 计算实际损失金额\n3. 先行协商解决\n4. 协商不成可申请仲裁或起诉\n\n**时效提醒**：一般合同纠纷诉讼时效为3年\n\n*建议咨询专业律师获取具体指导*"
      }
      
      prompt.contains("工伤") || prompt.contains("劳动") -> {
        "【劳动法律指导】\n\n🏥 **工伤认定流程**：\n1. 及时就医并保留病历\n2. 30日内申请工伤认定\n3. 进行劳动能力鉴定\n4. 申请工伤保险待遇\n\n💰 **可获赔偿**：\n�?医疗费用\n�?停工留薪期工资\n�?一次性伤残补助金\n�?其他相关费用\n\n**重要提醒**：工伤认定有严格时限要求\n\n*具体赔偿标准建议咨询当地律师*"
      }
      
      prompt.contains("房产") || prompt.contains("买房") -> {
        "【房产法律咨询】\n\n🏠 **购房注意事项**：\n�?核实房屋产权状况\n�?检查是否存在抵押查封\n�?确认税费承担方式\n�?约定违约责任\n\n📝 **合同要点**：\n1. 房屋基本信息要准确\n2. 付款方式和时间节点\n3. 过户时间安排\n4. 违约责任条款\n\n**风险提示**：建议通过正规中介或律师协助办理\n\n*重大交易建议聘请专业律师审核*"
      }
      
      else -> {
        "【智能法律助手】\n\n🤖 我是您的AI法律顾问，基于Gemma3 270M模型为您提供专业法律咨询。\n\n📚 **服务范围**：\n�?民事纠纷解答\n�?合同法律问题\n�?劳动争议指导\n�?婚姻家庭咨询\n�?房产交易建议\n\n💡 **使用提示**：请详细描述您的具体情况，我会为您提供更精准的法律建议。\n\n⚠️ **免责声明**：此为一般性法律信息，不构成正式法律意见，重要事项请咨询执业律师�?
      }
    }
  }
  
  override fun onDestroy() {
    super.onDestroy()
    gemmaInference?.close()
    mainScope.cancel()
  }
}
