import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../providers/locale_provider.dart';
import '../providers/ui_mode_provider.dart';
import '../constants/app_theme.dart';
import '../widgets/language_selector.dart';
import '../widgets/sidebar_menu.dart';
import '../services/gemma_service.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:yaml/yaml.dart';
import '../model/runner.dart';
import '../model/llama_runner.dart';
// import '../model/prompts.dart'; // 未使用
import '../rag/lawpack.dart';
import '../services/lawpack_init.dart';
import 'chat_flow_fixed.dart';

/// 主聊天界面 - 简约风格
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

/// Scaffold的GlobalKey，用于控制侧边栏
final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  Map<String, int>? _lawPackStats;

  @override
  void initState() {
    super.initState();
    _loadLawPackStats();
  }

  Future<void> _loadLawPackStats() async {
    try {
      final dbFile = await LawPackInit.copyDbFromAssetsIfNeeded();
      final lawPack = await LawPack.open(dbFile);
      final stats = await lawPack.stats();
      setState(() {
        _lawPackStats = stats;
      });
    } catch (e) {
      // 忽略错误，不影响界面显示
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final userMessage = _messageController.text.trim();
    _messageController.clear();

    setState(() {
      _messages.add(ChatMessage(
        text: userMessage,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isLoading = true;
    });

    try {
      // use ChatFlow entry
      final reply = await ChatFlow.onUserTurn(context, userMessage, ref);
      setState(() {
        _messages.add(ChatMessage(text: reply, isUser: false, timestamp: DateTime.now()));
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(
          text: '抱歉，我暂时无法回答您的问题。请稍后再试。',
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final uiMode = ref.watch(uiModeProvider);
    
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: uiMode == UIMode.simple 
          ? _buildSimpleLayout() 
          : _buildModernLayout(),
      // 侧边栏作为抽屉
      drawer: const Drawer(child: SidebarMenu()),
    );
  }

  /// 构建简洁布局（用户设计）
  Widget _buildSimpleLayout() {
    return Column(
      children: [
        // 顶部栏
        _buildTopBar(),
        
        // 聊天消息区域
        Expanded(
          child: _messages.isEmpty
              ? _buildEmptyState()
              : _buildMessageList(),
        ),
        
        // 输入区域
        _buildInputArea(),
      ],
    );
  }

  /// 构建现代布局（AI设计）
  Widget _buildModernLayout() {
    return Row(
      children: [
        // 左侧功能区域（现代模式显示更多功能）
        if (MediaQuery.of(context).size.width > 1200)
          Container(
            width: 300,
            color: Colors.grey[50],
            child: _buildModernSidebar(),
          ),
        
        // 主聊天区域
        Expanded(
          child: Column(
            children: [
              // 现代风格顶部栏
              _buildModernTopBar(),
              
              // 聊天消息区域
              Expanded(
                child: _messages.isEmpty
                    ? _buildModernEmptyState()
                    : _buildMessageList(),
              ),
              
              // 现代风格输入区域
              _buildModernInputArea(),
            ],
          ),
        ),
        
        // 右侧信息面板（现代模式）
        if (MediaQuery.of(context).size.width > 1400)
          Container(
            width: 250,
            color: Colors.grey[50],
            child: _buildModernInfoPanel(),
          ),
      ],
    );
  }

  /// 构建顶部栏
  Widget _buildTopBar() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 1,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          // 左上角菜单按钮
          IconButton(
            onPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
            icon: const Icon(Icons.menu, color: AppTheme.textPrimary),
          ),
          
          const Spacer(),
          
          // 法规数据统计显示
          if (_lawPackStats != null)
            Text(
              '法规条目：${_lawPackStats!['chunks']} | 文档：${_lawPackStats!['articles']}',
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
          
          const Spacer(),
          
          // 右上角语言选择
          const LanguageSelector(),
        ],
      ),
    );
  }

  /// 构建空状态（中间显示Logo）
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 中间Logo
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.balance,
              size: 50,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          
          Text(
            '法律顾问AI助手',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          
          Text(
            '我可以帮您解答法律问题，提供专业建议',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 40),
          
          // 示例问题
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildExampleChip('合同纠纷如何处理？'),
              _buildExampleChip('劳动法相关问题'),
              _buildExampleChip('房产买卖注意事项'),
              _buildExampleChip('知识产权保护'),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建示例问题芯片
  Widget _buildExampleChip(String text) {
    return GestureDetector(
      onTap: () {
        _messageController.text = text;
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  /// 构建消息列表
  Widget _buildMessageList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _messages.length && _isLoading) {
          return _buildLoadingMessage();
        }
        
        final message = _messages[index];
        return _buildMessageBubble(message);
      },
    );
  }

  /// 构建消息气泡
  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: message.isUser 
            ? MainAxisAlignment.end 
            : MainAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            // AI头像
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.balance,
                size: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
          ],
          
          // 消息内容
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: message.isUser 
                    ? AppTheme.primaryColor 
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: message.isUser 
                      ? Colors.white 
                      : AppTheme.textPrimary,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          
          if (message.isUser) ...[
            const SizedBox(width: 12),
            // 用户头像
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                size: 16,
                color: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 构建加载消息
  Widget _buildLoadingMessage() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.balance,
              size: 16,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '正在思考...',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建输入区域
  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 输入框
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 120),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: TextField(
                controller: _messageController,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                decoration: const InputDecoration(
                  hintText: '输入您的法律问题...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // 发送按钮
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: _sendMessage,
              icon: const Icon(
                Icons.send,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建现代风格侧边栏
  Widget _buildModernSidebar() {
    return Column(
      children: [
        // 快速功能区
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '快速功能',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              _buildQuickActionButton('文档分析', Icons.description, Colors.blue),
              const SizedBox(height: 8),
              _buildQuickActionButton('合同审查', Icons.gavel, Colors.green),
              const SizedBox(height: 8),
              _buildQuickActionButton('法条查询', Icons.search, Colors.orange),
              const SizedBox(height: 8),
              _buildQuickActionButton('案例研究', Icons.book, Colors.purple),
            ],
          ),
        ),
        
        const Divider(),
        
        // 最近对话
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '最近对话',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: const Icon(Icons.chat_bubble_outline, size: 20),
                        title: Text('对话 ${index + 1}'),
                        subtitle: const Text('2小时前'),
                        onTap: () {},
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 构建快速操作按钮
  Widget _buildQuickActionButton(String title, IconData icon, Color color) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {},
        icon: Icon(icon, size: 18),
        label: Text(title),
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withOpacity(0.1),
          foregroundColor: color,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ),
      ),
    );
  }

  /// 构建现代风格顶部栏
  Widget _buildModernTopBar() {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 左上角菜单按钮
          IconButton(
            onPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
            icon: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 20,
                  height: 3,
                  color: AppTheme.textPrimary,
                ),
                const SizedBox(height: 3),
                Container(
                  width: 14,
                  height: 2,
                  color: AppTheme.textPrimary,
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 16),
          
          // 标题区域
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '法律顾问AI助手',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                '专业版 • 在线',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          
          const Spacer(),
          
          // 功能按钮组
          Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.history),
                tooltip: '对话历史',
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.bookmark_border),
                tooltip: '收藏',
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.share),
                tooltip: '分享',
              ),
              const SizedBox(width: 8),
              const LanguageSelector(),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建现代风格空状态
  Widget _buildModernEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 动画Logo
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryColor,
                  AppTheme.primaryColor.withOpacity(0.7),
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.balance,
              size: 50,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          
          const Text(
            '法律顾问AI助手 • 专业版',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          
          const Text(
            '我可以帮您解答法律问题，提供专业建议',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          
          // 现代风格示例问题
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildModernSampleQuestion('劳动合同纠纷处理'),
              _buildModernSampleQuestion('房产买卖注意事项'),
              _buildModernSampleQuestion('知识产权保护'),
              _buildModernSampleQuestion('公司法律合规'),
              _buildModernSampleQuestion('民事诉讼程序'),
              _buildModernSampleQuestion('税务法律问题'),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建现代风格示例问题
  Widget _buildModernSampleQuestion(String question) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          _messageController.text = question;
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(20),
            color: AppTheme.primaryColor.withOpacity(0.05),
          ),
          child: Text(
            question,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  /// 构建现代风格输入区域
  Widget _buildModernInputArea() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 附件按钮
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.attach_file),
            style: IconButton.styleFrom(
              backgroundColor: Colors.grey[100],
            ),
          ),
          const SizedBox(width: 12),
          
          // 输入框
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(24),
                color: Colors.grey[50],
              ),
              child: TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  hintText: '请输入您的法律问题...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                maxLines: null,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // 发送按钮
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primaryColor, AppTheme.primaryColor.withOpacity(0.8)],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: IconButton(
              onPressed: _isLoading ? null : _sendMessage,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.send),
              style: IconButton.styleFrom(
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建现代风格信息面板
  Widget _buildModernInfoPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '相关信息',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          
          // 法律条文卡片
          _buildInfoCard(
            '相关法条',
            '《民法典》第三编 合同\n第四百六十九条...',
            Icons.gavel,
            Colors.blue,
          ),
          const SizedBox(height: 12),
          
          // 案例参考卡片
          _buildInfoCard(
            '相似案例',
            '张某诉李某合同纠纷案\n(2023)京0105民初...',
            Icons.book,
            Colors.green,
          ),
          const SizedBox(height: 12),
          
          // 专家建议卡片
          _buildInfoCard(
            '专家建议',
            '建议收集相关证据材料\n准备诉讼文书...',
            Icons.lightbulb,
            Colors.orange,
          ),
        ],
      ),
    );
  }

  /// 构建信息卡片
  Widget _buildInfoCard(String title, String content, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
        color: color.withOpacity(0.05),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// 聊天消息模型
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}