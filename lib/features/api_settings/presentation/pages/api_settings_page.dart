import 'package:flutter/material.dart';
import 'package:finance/core/env_config.dart';

class ApiSettingsPage extends StatelessWidget {
  const ApiSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isJquantsSet = EnvConfig.isJquantsApiKeySet;
    final isEdinetSet = EnvConfig.isEdinetApiKeySet;
    final isGeminiSet = EnvConfig.isGeminiApiKeySet;

    return Scaffold(
      appBar: AppBar(
        title: const Text('APIキー設定・ガイド'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: Colors.amber.shade100,
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(Icons.shield, size: 32, color: Colors.amber),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '本アプリは、ユーザー各自が取得したAPIキーを用いて端末内でデータを直接取得・分析する完全ローカル設計です。APIキーは絶対にGitHub等に公開しないでください。',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '設定ステータス (.env_secrets/.env)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // J-Quants
            _buildApiStatusCard(
              title: 'J-Quants API',
              description: '日本株の銘柄一覧、株価四本値、財務サマリーの取得に使用します。',
              isSet: isJquantsSet,
              guideUrl: 'https://jquants.com/',
            ),
            const SizedBox(height: 12),

            // EDINET
            _buildApiStatusCard(
              title: 'EDINET API v2',
              description: '金融庁EDINETより有価証券報告書・四半期報告書などの開示文書情報を取得します。',
              isSet: isEdinetSet,
              guideUrl: 'https://disclosure.edinet-fsa.go.jp/',
            ),
            const SizedBox(height: 12),

            // Gemini
            _buildApiStatusCard(
              title: 'Gemini API',
              description: '財務指標および開示要約を元に、AIが銘柄分析コメントを自動生成します。',
              isSet: isGeminiSet,
              guideUrl: 'https://aistudio.google.com/app/apikey',
            ),

            const SizedBox(height: 24),
            const Text(
              'APIキーの設定方法',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const SelectableText(
                '1. プロジェクトフォルダ直下の `.env_secrets` フォルダ内の `.env` ファイルを開きます。\n'
                '2. 各APIのキーを以下のように記述して保存してください:\n\n'
                'GEMINI_API_KEY=your_gemini_key\n'
                'JQUANTS_API_KEY=your_jquants_refresh_token\n'
                'EDINET_API_KEY=your_edinet_subscription_key\n\n'
                '※未設定のAPIがある場合は、モックデータまたは一部制限モードで自動的に動作します。',
                style: TextStyle(fontSize: 14),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildApiStatusCard({
    required String title,
    required String description,
    required bool isSet,
    required String guideUrl,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Chip(
                  avatar: Icon(
                    isSet ? Icons.check_circle : Icons.warning,
                    color: isSet ? Colors.green : Colors.orange,
                    size: 18,
                  ),
                  label: Text(
                    isSet ? '設定済み' : '未設定 (モック/制限動作)',
                    style: TextStyle(
                      color: isSet ? Colors.green.shade900 : Colors.orange.shade900,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  backgroundColor: isSet ? Colors.green.shade50 : Colors.orange.shade50,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(description, style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 8),
            SelectableText(
              '取得元: $guideUrl',
              style: const TextStyle(fontSize: 12, color: Colors.blue),
            ),
          ],
        ),
      ),
    );
  }
}
