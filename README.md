# 💎 Treasure Stock Finder

**個人投資家のための AI 搭載 株式スクリーニングアプリ**

財務指標を入力するだけで、条件に合致する「お宝株」を素早く見つけ出します。
J-Quants API / EDINET API との連携、および Gemini AI を活用した銘柄ごとの本格的な財務分析コメントの自動生成に対応しています。

---

## ✨ 主な機能

| 機能 | 状態 | 説明 |
|------|------|------|
| 📊 条件検索 | ✅ 実装済 | 売上高成長率・PER・PBR・PSR・PEG・配当利回り等を範囲指定してスクリーニング |
| 📋 検索結果一覧 | ✅ 実装済 | 条件に合致した銘柄をリスト表示（AIスコア・バリュエーション指標付き） |
| 📈 銘柄詳細画面 | ✅ 実装済 | 各種財務指標・株価情報・EDINET開示情報・統合AI分析を表示 |
| 🔑 APIキー安全管理 | ✅ 実装済 | `.env_secrets/.env` + `.gitignore` による GitHub 公開対策 |
| 🤖 Gemini AI 連携 | ✅ 実装済 | 銘柄の財務データ・開示情報からAIが分析・解説コメントを自動生成 |
| ⭐ お気に入り | ✅ 実装済 | 気になる銘柄をブックマーク（ローカルストレージ保存） |
| 🕐 検索履歴 | ✅ 実装済 | 過去の検索条件を保存・再利用（ローカル保存） |
| ⚙️ APIキー設定ガイド | ✅ 実装済 | J-Quants / EDINET / Gemini APIキーの設定状態確認とガイド画面 |

> 📖 詳しい仕様は [`docs/SPECIFICATION.md`](docs/SPECIFICATION.md) および [`phase3_implementation_spec_with_psr.md`](phase3_implementation_spec_with_psr.md) を参照してください。

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
| 外部API | J-Quants API / EDINET API |
| AI | Gemini API (google_generative_ai) |
| 通信 | http / flutter_dotenv |

---

## 📂 ディレクトリ構成

```
finance/
├── lib/
│   ├── main.dart                   # アプリのエントリポイント
│   ├── app.dart                    # MaterialApp の設定（テーマ・ルーター）
│   ├── core/
│   │   ├── router.dart             # GoRouter によるルーティング定義
│   │   ├── env_config.dart         # APIキー取得ヘルパー
│   │   ├── api_client.dart         # HTTP共通クライアント
│   │   └── api_error.dart          # API例外定義
│   ├── features/
│   │   ├── api_settings/           # 【APIキー設定・ガイド画面】
│   │   │   └── presentation/       #   ApiSettingsPage
│   │   ├── stock_data/             # 【J-Quants / EDINET 実データ連携・計算】
│   │   │   ├── domain/             #   StockMaster, DailyStockPrice, FinancialSummary, ValuationMetrics, EdinetDocument
│   │   │   ├── data/               #   JQuantsApiClient, EdinetApiClient, JQuantsStockRepository, EdinetRepository
│   │   │   └── application/        #   ValuationCalculator, StockDataController
│   │   ├── search_history/         # 【検索履歴機能】
│   │   │   ├── domain/             #   SearchHistoryItem
│   │   │   ├── data/               #   SearchHistoryRepository
│   │   │   ├── application/        #   SearchHistoryController
│   │   │   └── presentation/       #   SearchHistoryPage
│   │   ├── stock_search/           # 【検索機能】
│   │   ├── stock_detail/           # 【銘柄詳細機能】
│   │   └── favorite/               # 【お気に入り機能】
│   └── shared/
├── .env_secrets/                   # ⚠️ APIキー格納 (Git管理対象外)
│   └── .env
├── phase3_implementation_spec_with_psr.md # Phase 3 実装仕様書
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

本アプリでは、実データ取得とAI分析のため、以下のAPIキーをユーザー各自で取得して設定してください。

- **J-Quants APIキー**
  - 日本株の銘柄一覧、株価四本値、財務サマリー取得に使用します。
  - J-Quants APIは個人の私的利用を前提としたサービスです。取得したデータを第三者へ配信・共有する用途では使用しないでください。
- **EDINET APIキー**
  - 有価証券報告書、四半期報告書、XBRLデータ取得に使用します。金融庁EDINETにてAPIキーを取得してください。
- **Gemini APIキー**
  - 銘柄ごとのAI財務分析コメント生成に使用します。Google AI Studio等でAPIキーを取得してください。

プロジェクトルートに `.env_secrets` フォルダと `.env` ファイルを作成してください。
※Windowsの文字コード問題に対処するため、必ず半角英数字のフォルダ名にしています。

`.env_secrets/.env` の記述例:
```env
GEMINI_API_KEY=your_gemini_api_key
JQUANTS_API_KEY=your_jquants_api_key
EDINET_API_KEY=your_edinet_api_key
```

> ⚠️ `.env_secrets` フォルダは `.gitignore` によりGit管理対象外です。APIキーをGitHub等に公開しないでください。  
> ⚠️ 本アプリは、ユーザー各自のAPIキーを使ってユーザー本人の端末上でデータを取得・分析する設計です。アプリ開発者はJ-Quants、EDINET、Gemini由来のデータやAPIキーを同梱・再配布しません。

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
| Phase 3 | J-Quants + EDINET + Gemini連携、実データ取得、指標計算(PER/PBR/PSR/PEG)、検索履歴 | ✅ 完了 |
| Phase 4 | UI/UXの洗練 + パフォーマンス最適化 | 📋 計画中 |

---

## ⚖️ 免責事項

本アプリは投資判断を支援する **情報提供ツール** です。
特定の金融商品の売買を推奨するものではありません。
表示される財務指標、AI分析コメント、スコア等は参考情報であり、投資判断はご自身の責任で行ってください。

---

## 📄 ライセンス

MIT License
