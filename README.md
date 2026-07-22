# 💎 Treasure Stock Finder

**大学生・個人投資家のための AI 搭載 株式スクリーニングアプリ**

財務指標を入力するだけで、条件に合致する「お宝株」を素早く見つけ出します。
将来的には Gemini AI による銘柄分析コメントの自動生成にも対応予定です。

---

## ✨ 主な機能

| 機能 | 状態 | 説明 |
|------|------|------|
| 📊 条件検索 | ✅ 実装済 | 売上高成長率・PER・配当利回り等を範囲指定して銘柄をスクリーニング |
| 📋 検索結果一覧 | ✅ 実装済 | 条件に合致した銘柄をリスト表示（AIスコア付き） |
| 📈 銘柄詳細画面 | ✅ 実装済 | 各種財務指標とAIコメント（モック）を表示 |
| 🔑 APIキー安全管理 | ✅ 実装済 | `.env` + `.gitignore` による GitHub 公開対策 |
| 🔥 Firebase連携 | 🔜 次フェーズ | Firestore / Authentication の導入 |
| 🤖 Gemini AI 連携 | 🔜 次フェーズ | 銘柄のAI分析コメント・リスク要因を自動生成 |
| ⭐ お気に入り | 🔜 次フェーズ | 気になる銘柄をブックマーク（Firestore保存） |
| 🕐 検索履歴 | 🔜 次フェーズ | 過去の検索条件を再利用 |

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
| フォント | Google Fonts (Noto Sans JP) |
| 環境変数管理 | flutter_dotenv |
| バックエンド（予定） | Firebase (Spark プラン / 無料) |
| AI（予定） | Gemini API |

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
│   │   │   ├── domain/             #   データモデル (Stock, StockSearchCondition)
│   │   │   ├── data/               #   リポジトリ (MockStockRepository)
│   │   │   ├── application/        #   状態管理 (Riverpod プロバイダ)
│   │   │   └── presentation/       #   UI (HomePage, SearchResultsPage)
│   │   ├── stock_detail/           # 【銘柄詳細機能】
│   │   │   └── presentation/       #   UI (StockDetailPage)
│   │   └── favorite/               # 【お気に入り機能】(Phase 2 で実装)
│   │       └── presentation/
│   └── shared/
│       ├── widgets/                # 共通ウィジェット (RangeInputWidget)
│       └── theme/                  # 共通テーマ設定
├── 絶対にGitHubに上げない秘密の設定/  # ⚠️ APIキー格納 (Git管理対象外)
│   └── .env
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
プロジェクトルートに `絶対にGitHubに上げない秘密の設定` フォルダと `.env` ファイルを作成してください。
```
絶対にGitHubに上げない秘密の設定/.env
```
ファイルの中身：
```env
GEMINI_API_KEY=あなたのGeminiAPIキー
STOCK_API_KEY=あなたの株価APIキー
```
> ⚠️ このフォルダは `.gitignore` で除外されているため、GitHubリポジトリには含まれません。

### 3. パッケージの取得とコード生成
```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### 4. アプリの起動
```bash
flutter run
```

---

## 🗺️ 開発ロードマップ

| フェーズ | 内容 | 状態 |
|----------|------|------|
| Phase 1 | UI構築 + モックデータによる検索 | ✅ 完了 |
| Phase 2 | Firebase連携 + Gemini AI連携 + お気に入り | 🔧 作業中 |
| Phase 3 | リアルタイム株価API連携 + プッシュ通知 | 📋 計画中 |
| Phase 4 | UI/UXの洗練 + パフォーマンス最適化 | 📋 計画中 |

---

## ⚖️ 免責事項

本アプリは投資判断を支援する **情報提供ツール** です。
特定の金融商品の売買を推奨するものではありません。
投資判断はご自身の責任で行ってください。

---

## 📄 ライセンス

MIT License
