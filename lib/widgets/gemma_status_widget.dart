import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/gemma_provider.dart';

class GemmaStatusWidget extends ConsumerWidget {
  const GemmaStatusWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gemmaState = ref.watch(gemmaProvider);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.psychology,
                size: 20,
                color: gemmaState.isConnected 
                    ? Colors.green 
                    : Colors.grey,
              ),
              const SizedBox(width: 8),
              Text(
                'Gemma 3 270M 模型状态',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (gemmaState.isLoading)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          const SizedBox(height: 8),
          
          // 连接状态
          _buildStatusItem(
            context,
            '连接状态',
            gemmaState.isConnected ? '已连接' : '未连接',
            gemmaState.isConnected ? Colors.green : Colors.red,
          ),
          
          // 模型状态
          _buildStatusItem(
            context,
            '模型状态',
            gemmaState.isModelLoaded ? '已加载' : '未加载',
            gemmaState.isModelLoaded ? Colors.green : Colors.orange,
          ),
          
          // 模型名称
          _buildStatusItem(
            context,
            '模型名称',
            gemmaState.modelName,
            Colors.blue,
          ),
          
          // 错误信息
          if (gemmaState.error != null)
            _buildStatusItem(
              context,
              '错误信息',
              gemmaState.error!,
              Colors.red,
            ),
          
          const SizedBox(height: 8),
          
          // 刷新按钮
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: gemmaState.isLoading 
                      ? null 
                      : () => ref.read(gemmaProvider.notifier).refreshStatus(),
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('刷新状态'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (!gemmaState.isConnected)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showSetupGuide(context),
                    icon: const Icon(Icons.help_outline, size: 16),
                    label: const Text('安装指南'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSetupGuide(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gemma 3 模型安装指南'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('1. 下载并安装 Ollama:'),
            Text('   https://ollama.ai/download'),
            SizedBox(height: 8),
            Text('2. 打开命令行，运行:'),
            Text('   ollama pull gemma2:2b'),
            SizedBox(height: 8),
            Text('3. 启动 Ollama 服务:'),
            Text('   ollama serve'),
            SizedBox(height: 8),
            Text('4. 重新启动应用'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('知道了'),
          ),
        ],
      ),
    );
  }
} 