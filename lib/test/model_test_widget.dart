import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 模型测试Widget - 用于验证AI模型集成
class ModelTestWidget extends StatefulWidget {
  @override
  _ModelTestWidgetState createState() => _ModelTestWidgetState();
}

class _ModelTestWidgetState extends State<ModelTestWidget> {
  static const platform = MethodChannel('legal_advisor_channel');
  
  String _testResult = '点击按钮开始测试...';
  bool _isLoading = false;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AI模型验证测试'),
        backgroundColor: Colors.blue[800],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🧪 模型状态检测',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '此测试将验证Gemma3 270M模型集成是否正常工作',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            
            ElevatedButton(
              onPressed: _isLoading ? null : _runModelTest,
              child: _isLoading 
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 8),
                      Text('测试中...'),
                    ],
                  )
                : Text('🚀 开始模型验证测试'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            
            SizedBox(height: 16),
            
            Expanded(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '📋 测试结果',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Text(
                            _testResult,
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            SizedBox(height: 16),
            
            ElevatedButton(
              onPressed: _isLoading ? null : _testAIGeneration,
              child: Text('💬 测试AI对话生成'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _runModelTest() async {
    setState(() {
      _isLoading = true;
      _testResult = '🔄 正在执行模型验证测试...\n';
    });
    
    try {
      final result = await platform.invokeMethod('test_model');
      
      setState(() {
        _testResult = '''
🧪 模型验证测试完成

📊 测试状态: ${result['success'] ? '✅ 成功' : '❌ 失败'}

📝 详细结果:
${result['message']}

⏰ 测试时间: ${DateTime.now().toString().substring(0, 19)}
        ''';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _testResult = '''
❌ 测试执行失败

错误信息: $e

⏰ 失败时间: ${DateTime.now().toString().substring(0, 19)}
        ''';
        _isLoading = false;
      });
    }
  }
  
  Future<void> _testAIGeneration() async {
    setState(() {
      _isLoading = true;
      _testResult = '🤖 正在测试AI对话生成...\n';
    });
    
    try {
      // 初始化模型
      await platform.invokeMethod('init', {'modelPath': 'assets/models/gemma-3-270m.task'});
      
      // 测试AI生成
      final response = await platform.invokeMethod('generate', {
        'prompt': '我想咨询离婚相关的法律问题，请给我一些建议。',
        'maxTokens': 200
      });
      
      setState(() {
        _testResult = '''
💬 AI对话生成测试完成

🤖 输入问题: "我想咨询离婚相关的法律问题，请给我一些建议。"

📝 AI回复:
$response

📊 回复长度: ${response.toString().length} 字符

⏰ 生成时间: ${DateTime.now().toString().substring(0, 19)}

${response.toString().contains('智能回退模式') ? 
  '⚠️ 当前使用智能回退模式，如需真实AI推理请替换模型文件' : 
  '✅ AI推理正常工作'}
        ''';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _testResult = '''
❌ AI生成测试失败

错误信息: $e

⏰ 失败时间: ${DateTime.now().toString().substring(0, 19)}
        ''';
        _isLoading = false;
      });
    }
  }
}
