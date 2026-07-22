# Treasure Stock Finder — 詳細仕様書

> **最終更新日**: 2026-07-21
> **バージョン**: 1.0.0 (Phase 1 完了 / Phase 2 作業中)

---

## 1. プロジェクト概要

### 1.1 アプリ名
**Treasure Stock Finder**（お宝株ファインダー）

### 1.2 コンセプト
大学生や個人投資家が、複雑な財務データに圧倒されることなく、自分だけの「お宝株」を見つけられる株式スクリーニングアプリ。
AIによる銘柄分析コメントの自動生成や、直感的なフィルタリングUIにより、投資の第一歩をサポートします。

### 1.3 対象ユーザー
- 投資初心者の大学生
- 副業として株式投資を始めた社会人
- 財務指標を比較しながら効率よく銘柄を探したい個人投資家

### 1.4 対応プラットフォーム
- iOS
- Android
- Web（PCブラウザ）

---

## 2. 技術アーキテクチャ

### 2.1 フロントエンド
| 技術 | バージョン | 用途 |
|------|-----------|------|
| Flutter | 3.x | クロスプラットフォームUI |
| Dart | >= 3.2.0 | プログラミング言語 |
| Riverpod | ^2.4.9 | 状態管理 |
| Freezed | ^2.4.5 | イミュータブルなデータモデル生成 |
| json_serializable | ^6.9.5 | JSON シリアライズ/デシリアライズ |
| GoRouter | ^13.1.0 | 宣言的ルーティング |
| fl_chart | ^0.65.0 | グラフ・チャート描画 |
| Google Fonts | ^6.1.0 | Noto Sans JP フォント適用 |
| flutter_dotenv | ^5.1.0 | 環境変数(.env)の読み込み |

### 2.2 バックエンド（Phase 2 以降で導入予定）
| 技術 | 用途 |
|------|------|
| Firebase Authentication | ユーザー認証（Google / メール / ゲスト） |
| Cloud Firestore | お気に入り・検索履歴の保存 |
| Gemini API | 銘柄のAI分析コメント・リスク評価の生成 |

> **重要**: Firebase は **Spark プラン（完全無料）** のみで運用します。
> Cloud Functions は Spark プランでは利用できないため使用しません。
> AI/外部APIの呼び出しは Flutter アプリから直接行います（使用者は1名のみ）。

### 2.3 設計方針
- **Clean Architecture** を採用し、UI・ロジック・データアクセスを分離
- 各機能は `features/` ディレクトリ配下に独立して配置（Feature-first 構成）
- テスタビリティ・拡張性・保守性を重視

---

## 3. 機能仕様

### 3.1 株式スクリーニング（検索）機能 — ✅ Phase 1 で実装済

#### 3.1.1 検索条件入力（ホーム画面）
ユーザーは以下の財務指標に対して **最小値〜最大値** の範囲を指定して検索できます。

| 指標 | 単位 | 説明 |
|------|------|------|
| 売上高成長率 | % | 前年比の売上成長率 |
| 営業利益成長率 | % | 前年比の営業利益成長率 |
| 利益率 | % | 売上高に対する純利益の割合 |
| 予想PER | 倍 | 株価収益率（株価の割安度） |
| PBR | 倍 | 株価純資産倍率 |
| 予想配当利回り | % | 年間配当金 ÷ 株価 |

また、以下のドロップダウンで市場を絞り込めます：
- 全市場
- 東証プライム
- 東証スタンダード
- 東証グロース
- 米国株

#### 3.1.2 検索結果画面
- 条件に合致した銘柄がリスト形式で表示されます
- 各項目には **銘柄コード、銘柄名、市場、業種、AIスコア、主要指標** が表示されます
- タップすると銘柄詳細画面に遷移します

#### 3.1.3 銘柄詳細画面
- 選択した銘柄の全財務指標を一覧表示
- **AIコメント**（Phase 1 ではモックテキスト）を表示
- **リスク要因**（Phase 1 ではモックテキスト）を表示
- お気に入りボタン（Phase 2 で機能接続）

### 3.2 AIによる銘柄分析 — 🔜 Phase 2 で実装予定

#### 3.2.1 Gemini API 連携
- `google_generative_ai` パッケージを使用
- 銘柄の財務データをプロンプトに含めて Gemini API に送信
- 以下の要素を含む分析コメントを自動生成：
  - 銘柄の総合評価（ポジティブ / ニュートラル / ネガティブ）
  - 成長性の分析
  - 割安度の評価
  - リスク要因のハイライト

#### 3.2.2 AIスコア
- 各銘柄に対して 0〜100 の AI スコアを算出（将来実装）
- スコアの根拠をテキストで表示

### 3.3 お気に入り機能 — 🔜 Phase 2 で実装予定
- 銘柄詳細画面のハートアイコンをタップしてお気に入り登録
- Firestore にユーザーごとのお気に入りリストを保存
- お気に入り一覧画面で保存済み銘柄を確認

### 3.4 検索履歴機能 — 🔜 Phase 2 で実装予定
- 過去に実行した検索条件を Firestore に自動保存
- 履歴から条件をワンタップで復元して再検索

### 3.5 ユーザー認証 — 🔜 Phase 2 で実装予定
- Firebase Authentication を使用
- 対応する認証方式：
  - Google ログイン
  - メール + パスワード
  - 匿名（ゲスト）ログイン

---

## 4. データモデル

### 4.1 Stock（銘柄）
```dart
class Stock {
  String stockCode;            // 銘柄コード（例: "7203"）
  String stockName;            // 銘柄名（例: "トヨタ自動車"）
  String market;               // 上場市場（例: "東証プライム"）
  String industry;             // 業種（例: "輸送用機器"）
  double revenueGrowthRate;    // 売上高成長率 (%)
  double operatingProfitGrowthRate; // 営業利益成長率 (%)
  double profitMargin;         // 利益率 (%)
  double forecastPER;          // 予想PER (倍)
  double pbr;                  // PBR (倍)
  double forecastDividendYield; // 予想配当利回り (%)
  double roe;                  // ROE (%)
  double roa;                  // ROA (%)
  double equityRatio;          // 自己資本比率 (%)
  int marketCap;               // 時価総額 (円)
  double? aiScore;             // AIスコア (0-100, nullable)
}
```

### 4.2 StockSearchCondition（検索条件）
```dart
class StockSearchCondition {
  String? market;
  String? industry;
  double? revenueGrowthRateMin;
  double? revenueGrowthRateMax;
  double? operatingProfitGrowthRateMin;
  double? operatingProfitGrowthRateMax;
  double? profitMarginMin;
  double? profitMarginMax;
  double? forecastPERMin;
  double? forecastPERMax;
  double? pbrMin;
  double? pbrMax;
  double? forecastDividendYieldMin;
  double? forecastDividendYieldMax;
}
```

---

## 5. 画面遷移

```
┌──────────────┐
│  ホーム画面    │  検索条件を入力
│  (/)         │  「検索する」ボタン
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ 検索結果画面   │  銘柄リスト表示
│ (/search_results) │  銘柄タップで詳細へ
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ 銘柄詳細画面   │  財務指標 + AIコメント
│ (/stock_detail) │  お気に入りボタン
└──────────────┘
```

---

## 6. APIキー管理方針

### 6.1 セキュリティ要件
- APIキー（Gemini API, 株価APIなど）をソースコードに直接記述しない
- GitHub にAPIキーが漏洩しないよう `.gitignore` で確実に除外する

### 6.2 実装方法
1. プロジェクトルートに `絶対にGitHubに上げない秘密の設定/` フォルダを作成
2. その中に `.env` ファイルを作成し、APIキーを記述
3. `.gitignore` でこのフォルダ全体を除外
4. `flutter_dotenv` パッケージでアプリ起動時に `.env` を読み込み
5. `EnvConfig` クラス経由でアプリ内から安全にキーを取得

```dart
// 使用例
import 'package:finance/core/env_config.dart';

final geminiKey = EnvConfig.geminiApiKey;
```

### 6.3 GitHubリポジトリにクローンした人向け
リポジトリをクローンした後、以下のフォルダとファイルを自分で作成する必要があります：
```
絶対にGitHubに上げない秘密の設定/.env
```

---

## 7. 開発ロードマップ

### Phase 1: MVP（UI + モックデータ）— ✅ 完了
- Flutterプロジェクトの作成
- Clean Architecture ベースのディレクトリ構成
- Freezed によるデータモデル定義
- モックデータを用いた検索ロジック
- ホーム画面・検索結果画面・銘柄詳細画面のUI実装
- GoRouter によるルーティング
- Riverpod による状態管理
- 免責事項の表示

### Phase 2: バックエンド連携 — 🔧 作業中
- ✅ APIキー安全管理基盤の構築（flutter_dotenv + .gitignore）
- 🔜 Firebase (Firestore / Authentication) の導入
- 🔜 Gemini API 連携（銘柄分析コメントの自動生成）
- 🔜 お気に入り・検索履歴機能の実装
- 🔜 外部株価API との連携

### Phase 3: リアルタイムデータ連携（計画中）
- リアルタイム株価の取得と表示
- プッシュ通知（お気に入り銘柄の急変動アラート）
- チャート機能の拡充（株価推移グラフ等）

### Phase 4: UI/UX の洗練（計画中）
- レスポンシブデザイン（PC向けワイドレイアウト対応）
- ダークモードの最適化
- アニメーション・マイクロインタラクションの追加
- パフォーマンス最適化

---

## 8. コスト方針

| 項目 | 方針 |
|------|------|
| Firebase | Spark プラン（無料）のみ使用 |
| Gemini API | 無料枠内での利用を想定 |
| Cloud Functions | **使用しない**（Sparkプランでは利用不可のため） |
| サーバー費用 | **0円**（サーバーレス + 無料枠で運用） |

> 使用者は開発者本人1名のみを想定しているため、
> 無料枠を超過するリスクは極めて低い。

---

## 9. 免責事項

本アプリは投資判断を支援する **情報提供ツール** です。
特定の金融商品の売買を推奨するものではありません。
投資判断はご自身の責任で行ってください。

AIによる分析コメントは参考情報であり、投資の成果を保証するものではありません。
