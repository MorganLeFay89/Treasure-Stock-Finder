# 💎 Treasure Stock Finder

**個人投資家のための AI 搭載 株式スクリーニングアプリ**

財務指標を入力するだけで、条件に合致する「お宝株」を素早く見つけ出します。
Gemini AIを活用した銘柄ごとの本格的な財務分析コメントの自動生成にも対応しています。

---

## ✨ 主な機能

| 機能 | 状態 | 説明 |
|------|------|------|
| 📊 条件検索 | ✅ 実装済 | 売上高成長率・PER・配当利回り等を範囲指定して銘柄をスクリーニング |
| 📋 検索結果一覧 | ✅ 実装済 | 条件に合致した銘柄をリスト表示（AIスコア付き） |
| 📈 銘柄詳細画面 | ✅ 実装済 | 各種財務指標を表示 |
| 🔑 APIキー安全管理 | ✅ 実装済 | `.env_secrets/.env` + `.gitignore` による GitHub 公開対策 |
| 🤖 Gemini AI 連携 | ✅ 実装済 | 銘柄の財務データを元にAIが分析・解説コメントを自動生成 |
| ⭐ お気に入り | ✅ 実装済 | 気になる銘柄をブックマーク（ローカルストレージ保存） |
| 🕐 検索履歴 | 🔜 次フェーズ | 過去の検索条件を再利用（ローカル保存予定） |

> 📖 詳しい仕様は [`docs/SPECIFICATION.md`](docs/SPECIFICATION.md) を参照してください。

---

## 🛠️ 技術スタック

| カテゴリ | 技術 |
|----------|------|
| フレームワーク | Flutter (Dart) |
| 状態管理 | Riverpod |
| コード生成 | Freezed + json_serializable |
| ルーティング | GoRouter |
| グラフ描画 | fl_chart |
| データベース | shared_preferences (完全ローカル構成) |
| AI | Gemini API (google_generative_ai) |
| フォント | Google Fonts (Noto Sans JP) |
| 環境変数管理 | flutter_dotenv |

---

## 📂 ディレクトリ構成

```
finance/
├── lib/
│   ├── main.dart                   # アプリのエントリポイント
│   ├── app.dart                    # MaterialApp の設定（テーマ・ルーター）
│   ├── core/
│   │   ├── router.dart             # GoRouter によるルーティング定義
│   │   └── env_config.dart         # APIキー取得ヘルパー
│   ├── features/
│   │   ├── stock_search/           # 【検索機能】
│   │   ├── stock_detail/           # 【銘柄詳細機能】
│   │   │   ├── domain/
│   │   │   ├── data/               #   AiAnalysisService
│   │   │   ├── application/        #   AIプロバイダ
│   │   │   └── presentation/       #   UI (StockDetailPage)
│   │   └── favorite/               # 【お気に入り機能】
│   │       ├── data/               #   FavoriteRepository
│   │       ├── application/        #   FavoriteController
│   │       └── presentation/       #   UI (FavoritePage)
│   └── shared/
│       ├── widgets/                # 共通ウィジェット (RangeInputWidget)
│       └── theme/                  # 共通テーマ設定
├── .env_secrets/                   # ⚠️ APIキー格納 (Git管理対象外)
│   └── .env
├── 絶対にGitHubに上げない秘密の設定/  # ⚠️ Git管理対象外を保証するためのダミーフォルダ
├── docs/
│   └── SPECIFICATION.md            # 詳細仕様書
├── pubspec.yaml
├── .gitignore
└── README.md                       # ← このファイル
```

---

## 🚀 セットアップ手順

### 前提条件
- Flutter SDK がインストール済みであること
- Dart SDK >= 3.2.0

### 1. リポジトリのクローン
```bash
git clone https://github.com/<your-username>/finance.git
cd finance
```

### 2. APIキーの設定
プロジェクトルートに `.env_secrets` フォルダと `.env` ファイルを作成してください。
※Windowsの文字コード問題に対処するため、必ず半角英数字のフォルダ名にしています。
```
.env_secrets/.env
```
ファイルの中身：
```env
GEMINI_API_KEY=あなたのGeminiAPIキー
STOCK_API_KEY=あなたの株価APIキー
```
> ⚠️ `.env_secrets` フォルダおよび `絶対にGitHubに上げない秘密の設定` フォルダは `.gitignore` で除外されているため、GitHubリポジトリには含まれません。

### 3. パッケージの取得とコード生成
```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### 4. アプリの起動
```bash
flutter run -d chrome
```

---

## 🗺️ 開発ロードマップ

| フェーズ | 内容 | 状態 |
|----------|------|------|
| Phase 1 | UI構築 + モックデータによる検索 | ✅ 完了 |
| Phase 2 | ローカルDB移行(Firebase撤廃) + Gemini AI連携 + お気に入り機能 | ✅ 完了 |
| Phase 3 | リアルタイム株価API連携 + 検索履歴機能 | 📋 計画中 |
| Phase 4 | UI/UXの洗練 + パフォーマンス最適化 | 📋 計画中 |

---

## ⚖️ 免責事項

本アプリは投資判断を支援する **情報提供ツール** です。
特定の金融商品の売買を推奨するものではありません。
投資判断はご自身の責任で行ってください。

---

## 📄 ライセンス

MIT License
