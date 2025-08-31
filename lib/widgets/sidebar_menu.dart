import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../constants/app_theme.dart';
import '../providers/ui_mode_provider.dart';

/// 侧边栏菜单组件
class SidebarMenu extends ConsumerWidget {
  const SidebarMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    
    return Container(
      width: 280,
      color: Colors.white,
      child: Column(
        children: [
          // 顶部Logo区域
          Container(
            height: 100,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.05),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.balance,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      l10n?.appTitle ?? '法律顾问',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const Text(
                      'AI',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // 菜单项列表
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildMenuItem(
                  icon: Icons.chat_bubble_outline,
                  title: l10n?.newChat ?? '新对话',
                  onTap: () {
                    // 开始新对话
                  },
                ),
                _buildMenuItem(
                  icon: Icons.history,
                  title: l10n?.chatHistory ?? '对话历史',
                  onTap: () {
                    // 查看对话历史
                  },
                ),
                const Divider(height: 1),
                _buildMenuItem(
                  icon: Icons.folder_special,
                  title: l10n?.personalDatabase ?? '个人数据库',
                  subtitle: 'SVIP',
                  isLocked: true,
                  onTap: () {
                    _showSvipDialog(context);
                  },
                ),
                _buildMenuItem(
                  icon: Icons.library_books,
                  title: l10n?.legalDatabase ?? '法律数据库',
                  onTap: () {
                    // 查看法律资料
                  },
                ),
                _buildMenuItem(
                  icon: Icons.quiz,
                  title: l10n?.legalQA ?? '法律问答',
                  onTap: () {
                    // 法律问答功能
                  },
                ),
                _buildMenuItem(
                  icon: Icons.school,
                  title: l10n?.legalStudy ?? '法律学习',
                  onTap: () {
                    // 法律学习功能
                  },
                ),
                const Divider(height: 1),
                // UI模式切换按钮
                _buildUIModeToggle(context, ref),
                _buildMenuItem(
                  icon: Icons.settings,
                  title: l10n?.settings ?? '设置',
                  onTap: () {
                    // 打开设置
                  },
                ),
                _buildMenuItem(
                  icon: Icons.help_outline,
                  title: l10n?.helpFeedback ?? '帮助与反馈',
                  onTap: () {
                    // 帮助与反馈
                  },
                ),
              ],
            ),
          ),
          
          // 底部账户管理
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Colors.grey[200]!,
                  width: 1,
                ),
              ),
            ),
            child: _buildMenuItem(
              icon: Icons.account_circle,
              title: '账户管理',
              onTap: () {
                _showAccountDialog(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 构建UI模式切换按钮
  Widget _buildUIModeToggle(BuildContext context, WidgetRef ref) {
    final currentMode = ref.watch(uiModeProvider);
    final uiModeNotifier = ref.read(uiModeProvider.notifier);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
        color: AppTheme.primaryColor.withOpacity(0.05),
      ),
      child: ListTile(
        leading: Icon(
          currentMode == UIMode.simple ? Icons.visibility : Icons.dashboard,
          color: AppTheme.primaryColor,
          size: 20,
        ),
        title: const Text(
          'UI模式',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        subtitle: Text(
          uiModeNotifier.currentModeName,
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Container(
          width: 60,
          height: 30,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: currentMode == UIMode.simple 
                ? Colors.grey[300] 
                : AppTheme.primaryColor,
          ),
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 200),
                left: currentMode == UIMode.simple ? 2 : 32,
                top: 2,
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    currentMode == UIMode.simple ? Icons.visibility : Icons.auto_awesome,
                    size: 16,
                    color: currentMode == UIMode.simple 
                        ? Colors.grey[600] 
                        : AppTheme.primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        onTap: () async {
          await uiModeNotifier.toggleUIMode();
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('已切换到${uiModeNotifier.currentModeName}'),
                duration: const Duration(seconds: 1),
                backgroundColor: AppTheme.primaryColor,
              ),
            );
          }
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }

  /// 构建菜单项
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    bool isLocked = false,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isLocked ? Colors.grey : AppTheme.primaryColor,
        size: 20,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: isLocked ? Colors.grey : AppTheme.textPrimary,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: isLocked ? Colors.grey : AppTheme.accentColor,
              ),
            )
          : null,
      trailing: isLocked
          ? Icon(
              Icons.lock,
              size: 16,
              color: Colors.grey,
            )
          : null,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }

  /// 显示SVIP提示对话框
  void _showSvipDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.diamond,
              color: AppTheme.accentColor,
              size: 24,
            ),
            const SizedBox(width: 8),
            const Text(
              'SVIP专享功能',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('个人数据库是SVIP用户的专享功能，包括：'),
            SizedBox(height: 12),
            Text('• 个人法律文档存储'),
            Text('• 案例收藏和整理'),
            Text('• 专属法律知识库'),
            Text('• 高级搜索功能'),
            SizedBox(height: 16),
            Text(
              '升级SVIP即可解锁全部功能！',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryColor,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('稍后再说'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // 跳转到升级页面
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('立即升级'),
          ),
        ],
      ),
    );
  }

  /// 显示账户管理对话框
  void _showAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('账户管理'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('个人信息'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pop(context);
                // 跳转到个人信息页面
              },
            ),
            ListTile(
              leading: const Icon(Icons.diamond),
              title: const Text('会员中心'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pop(context);
                // 跳转到会员中心
              },
            ),
            ListTile(
              leading: const Icon(Icons.security),
              title: const Text('账户安全'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pop(context);
                // 跳转到账户安全设置
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                '退出登录',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(context);
                _showLogoutDialog(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  /// 显示退出登录确认对话框
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认退出'),
        content: const Text('确定要退出登录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // 执行退出登录逻辑
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('确认退出'),
          ),
        ],
      ),
    );
  }
}