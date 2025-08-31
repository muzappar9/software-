import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 测试AI集成的独立应用
void main() {
  runApp(AITestApp());
}

class AITestApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI集成测试',
      home: AITestScreen(),
    );
  }
}

class AITestScreen extends StatefulWidget {
  @override
  _AITestScreenState createState() => _AITestScreenState();
}

class _AITestScreenState extends State<AITestScreen> {
  static const platform = MethodChannel('legal_advisor_channel');
  
  String _result = '准备测试...';
  bool _isLoading = false;
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AI模型集成测试'),
        backgroundColor: Colors.blue[800],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: '输入测试问题',
                hintText: '例如：我想咨询离婚相关问题',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _testInitialization,
                    child: Text('测试初始化'),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _testGeneration,
                    child: Text('测试AI生成'),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 16),
            
            if (_isLoading)
              CircularProgressIndicator(),
            
            SizedBox(height: 16),
            
            Expanded(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _result,
                    style: TextStyle(fontFamily: 'monospace'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _testInitialization() async {
    setState(() {
      _isLoading = true;
      _result = '🔄 测试模型初始化...\n';
    });

    try {
      final initResult = await platform.invokeMethod('init', {
        'modelPath': 'assets/models/gemma-3-270m.task'
      });
      
      setState(() {
        _result += '✅ 初始化结果: $initResult\n';
        _result += '⏰ 时间: ${DateTime.now()}\n\n';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _result += '❌ 初始化失败: $e\n';
        _result += '⏰ 时间: ${DateTime.now()}\n\n';
        _isLoading = false;
      });
    }
  }

  Future<void> _testGeneration() async {
    final prompt = _controller.text.trim();
    if (prompt.isEmpty) {
      setState(() {
        _result = '❌ 请输入测试问题';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _result = '🤖 测试AI生成...\n';
      _result += '📝 输入: $prompt\n\n';
    });

    try {
      // 先初始化
      await platform.invokeMethod('init', {
        'modelPath': 'assets/models/gemma-3-270m.task'
      });
      
      // 然后生成
      final response = await platform.invokeMethod('generate', {
        'prompt': prompt,
        'maxTokens': 300
      });
      
      setState(() {
        _result += '✅ AI回复:\n$response\n\n';
        _result += '📊 回复长度: ${response.toString().length} 字符\n';
        _result += '⏰ 完成时间: ${DateTime.now()}\n\n';
        
        if (response.toString().contains('智能回退模式')) {
          _result += '⚠️ 当前使用智能回退模式\n';
          _result += '💡 要使用真实AI，请替换模型文件\n';
        } else {
          _result += '🎯 AI推理正常工作\n';
        }
        
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _result += '❌ 生成失败: $e\n';
        _result += '⏰ 失败时间: ${DateTime.now()}\n\n';
        _isLoading = false;
      });
    }
  }
}
