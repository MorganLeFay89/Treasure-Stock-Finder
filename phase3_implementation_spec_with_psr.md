# Treasure Stock Finder Phase 3 実装仕様書

バージョン: PSR対応版

作成日: 2026-07-27
対象プロジェクト: Treasure Stock Finder
対象フェーズ: Phase 3
対象技術: Flutter / Dart / Riverpod / GoRouter / shared_preferences / flutter_dotenv / Gemini API

---

## 1. 目的

Phase 3では、現在モックまたはローカル中心で動作している Treasure Stock Finder に対して、以下の外部データ連携機能を追加する。

1. J-Quants API による日本株の株価・銘柄一覧・財務サマリー取得
2. EDINET API による有価証券報告書・四半期報告書・XBRLデータ取得
3. Gemini API による銘柄別のAI財務分析コメント生成
4. PER、PBR、PSR、PEG、配当利回り等の指標計算・表示
5. 検索履歴機能の実装
6. READMEへのAPIキー設定手順の明記

本フェーズの重要方針は、アプリ運営者がデータを収集して再配布するのではなく、ユーザー各自がJ-Quants API、EDINET API、Gemini APIのAPIキーを取得し、自分の端末・ローカル環境でデータ取得と分析を行う構成にすることである。

---

## 2. Phase 3 の基本方針

### 2.1 データ利用方針

本アプリは個人投資家向けの情報提供・分析支援ツールであり、以下の方針で実装する。

- J-Quants APIは、ユーザー本人の私的利用を前提に、各ユーザーが自分のAPIキーを登録して利用する。
- EDINET APIは、金融庁EDINETのAPIキーをユーザー各自が取得して利用する。
- Gemini APIは、ユーザー各自のGoogle AI StudioまたはGoogle Cloud等で取得したAPIキーを利用する。
- アプリ開発者・配布者は、J-Quants由来データ、EDINET由来データ、Gemini APIキーを同梱・再配布しない。
- APIキーはGitHub等に公開しない。
- 取得した株価・財務データは原則としてユーザー本人の端末内で利用する。
- 外部公開・第三者配信・ランキング配信・CSV配布等は本アプリの標準機能として実装しない。

### 2.2 アプリ設計方針

Phase 3では、外部APIの差し替えを容易にするため、データ取得層を抽象化する。

推奨構成:

- StockMasterProvider
  - 上場銘柄一覧を取得する抽象インターフェース
- MarketDataProvider
  - 株価四本値・終値・出来高等を取得する抽象インターフェース
- FinancialDataProvider
  - 財務サマリー・EPS・BPS・純資産・売上・利益等を取得する抽象インターフェース
- DisclosureProvider
  - EDINET書類一覧・XBRL ZIP・PDF等を取得する抽象インターフェース
- AiAnalysisProvider
  - Gemini APIを用いた分析コメント生成インターフェース

具体実装:

- JQuantsStockMasterProvider
- JQuantsMarketDataProvider
- JQuantsFinancialDataProvider
- EdinetDisclosureProvider
- GeminiAiAnalysisProvider

---

## 3. 採用API

## 3.1 J-Quants API

### 3.1.1 用途

J-Quants APIは、日本株スクリーニングの主データソースとして採用する。

取得対象:

- 上場銘柄一覧
- 株価四本値
- 財務情報サマリー
- 決算発表予定日
- 配当情報

Phase 3では主に以下に利用する。

- 銘柄一覧の更新
- 現在または過去の終値取得
- PER計算用の株価取得
- PBR計算用の株価取得
- PSR計算用の株価または時価総額算出補助
- PEG計算用のPER算出補助
- 売上高成長率や利益成長率等の基礎データ取得
- スクリーニング条件へのリアルデータ反映

### 3.1.2 APIキー管理

.env_secrets/.env に以下を追加する。

```env
JQUANTS_API_KEY=your_jquants_api_key
```

既存のSTOCK_API_KEYは将来的に廃止または互換用に残す。Phase 3以降はJQUANTS_API_KEYを優先する。

### 3.1.3 実装要件

- EnvConfigにJQUANTS_API_KEY取得メソッドを追加する。
- APIキー未設定時は、ユーザーに設定方法を案内する画面またはエラーメッセージを表示する。
- APIレスポンスはモデルクラスに変換する。
- 通信失敗、API制限、認証エラー、データ欠損を区別して扱う。
- 取得データはshared_preferencesまたは将来のローカルDBにキャッシュ可能とする。
- J-Quants由来の生データを第三者配信する機能は実装しない。

### 3.1.4 想定モデル

```dart
class StockMaster {
  final String code;
  final String name;
  final String market;
  final String sector;
}

class DailyStockPrice {
  final String code;
  final DateTime date;
  final double? open;
  final double? high;
  final double? low;
  final double? close;
  final int? volume;
}

class FinancialSummary {
  final String code;
  final DateTime periodEnd;
  final double? revenue;
  final double? operatingProfit;
  final double? ordinaryProfit;
  final double? netIncome;
  final double? eps;
  final double? bps;
  final double? dividendPerShare;
  final int? issuedShares;
}

class ValuationMetrics {
  final String code;
  final double? per;
  final double? pbr;
  final double? psr;
  final double? peg;
  final double? dividendYield;
  final double? marketCap;
}
```

---

## 3.2 EDINET API

### 3.2.1 用途

EDINET APIは、財務データの原典確認およびGemini分析用の開示文書取得に利用する。

取得対象:

- 有価証券報告書
- 四半期報告書
- 半期報告書
- 訂正報告書
- XBRL ZIP
- PDF

Phase 3では主に以下に利用する。

- 対象企業の有価証券報告書検索
- XBRLから財務項目を抽出
- EPS、BPS、純資産、発行済株式数等の補完
- 事業等のリスク、経営方針、MD&A等をGemini分析へ渡す
- J-QuantsデータとEDINET開示データの突合

### 3.2.2 APIキー管理

.env_secrets/.env に以下を追加する。

```env
EDINET_API_KEY=your_edinet_api_key
```

### 3.2.3 実装要件

- EnvConfigにEDINET_API_KEY取得メソッドを追加する。
- 証券コードからEDINET書類を検索する処理を実装する。
- 書類一覧APIでdocIDを取得する。
- 書類取得APIでXBRL ZIPまたはPDFを取得できるようにする。
- XBRL解析処理はPhase 3では必要最低限とし、詳細解析はPhase 3.5またはPhase 4に分離可能とする。
- Geminiに投入するテキストは長すぎないように要約・抽出する。
- EDINETから取得した文書をそのまま再配布する機能は実装しない。

### 3.2.4 想定モデル

```dart
class EdinetDocument {
  final String docId;
  final String edinetCode;
  final String? secCode;
  final String filerName;
  final String docTypeCode;
  final String docDescription;
  final DateTime submitDateTime;
  final DateTime? periodStart;
  final DateTime? periodEnd;
}

class DisclosureTextExtract {
  final String code;
  final String docId;
  final String sectionName;
  final String text;
}
```

---

## 3.3 Gemini API

### 3.3.1 用途

Gemini APIは、既存の銘柄詳細画面におけるAI分析コメント生成を強化するために利用する。

Phase 3では、J-QuantsとEDINETから取得したデータを組み合わせ、以下の分析コメントを生成する。

- 企業概要
- 売上・利益成長率の評価
- PER、PBR、PSR、PEG、配当利回りの評価
- 財務安全性の評価
- 事業リスクの要約
- 決算内容の要約
- 長期投資観点での強み・弱み
- 注意すべきポイント

### 3.3.2 APIキー管理

既存READMEではGEMINI_API_KEYがすでに設定対象である。Phase 3ではこれを正式な必須APIキーとして扱う。

.env_secrets/.env に以下を設定する。

```env
GEMINI_API_KEY=your_gemini_api_key
```

### 3.3.3 実装要件

- 既存のAiAnalysisServiceを拡張する。
- 入力データとしてJ-Quantsの財務サマリー、株価、EDINETの開示文書要約を受け取る。
- プロンプトテンプレートを分離管理する。
- 投資助言ではなく情報提供であることを分析コメント内に明記する。
- Gemini APIエラー時は、AI分析なしでも銘柄詳細画面を表示できるようにする。
- APIキー未設定時はAI分析ボタンを無効化し、設定案内を表示する。

### 3.3.4 Geminiプロンプト方針

Geminiには以下の形式で入力する。

```text
あなたは個人投資家向けの財務分析アシスタントです。
以下の企業データをもとに、投資判断を断定せず、情報提供として分析してください。

銘柄コード: {code}
企業名: {name}
市場: {market}
業種: {sector}
株価: {closePrice}
PER: {per}
PBR: {pbr}
PSR: {psr}
PEG: {peg}
売上高成長率: {revenueGrowth}
EPS成長率: {epsGrowth}
配当利回り: {dividendYield}
自己資本比率: {equityRatio}
EDINET開示要約: {disclosureSummary}

出力形式:
1. 総合コメント
2. 割安性
3. 成長性
4. 財務安全性
5. リスク要因
6. 注意点
7. 免責文
```

---

## 4. 指標計算仕様

## 4.1 PER

```text
PER = 株価 / EPS
```

- 株価はJ-Quantsの終値を優先する。
- EPSはJ-Quants財務サマリーを優先する。
- J-Quantsで取得できない場合はEDINET XBRLから補完する。
- EPSが0以下または欠損の場合、PERはnullとする。

## 4.2 PBR

```text
PBR = 株価 / BPS
```

または、時価総額が計算できる場合は以下でも算出可能とする。

```text
PBR = 時価総額 / 純資産
```

- 株価はJ-Quantsの終値を優先する。
- BPSはJ-Quants財務サマリーを優先する。
- BPSが取得できない場合、EDINETから純資産と発行済株式数を取得して計算する。
- BPSが0以下または欠損の場合、PBRはnullとする。

## 4.3 PSR

```text
PSR = 時価総額 / 売上高
```

時価総額がAPIから直接取得できない場合は、以下の式で簡易算出する。

```text
時価総額 = 株価 * 発行済株式数
```

- 株価はJ-Quantsの終値を優先する。
- 売上高はJ-Quants財務サマリーを優先する。
- 発行済株式数がJ-Quantsで取得できない場合は、EDINET XBRLから補完する。
- 売上高が0以下または欠損の場合、PSRはnullとする。
- 発行済株式数が取得できず時価総額を算出できない場合、PSRはnullとする。
- UIには、PSRが直近決算売上高ベースか、通期換算売上高ベースかを明記する。
- Phase 3では、原則として直近通期売上高ベースのPSRを優先する。

## 4.4 PEGレシオ

```text
PEG = PER / EPS成長率
```

- Phase 3では、将来予想成長率ではなく過去実績ベースの簡易PEGを採用する。
- EPS成長率は、直近年度と過去年度のEPSから年率成長率として計算する。
- EPS成長率が0以下または欠損の場合、PEGはnullとする。
- UIには「PEGは過去実績ベースの簡易計算」と明記する。

## 4.5 配当利回り

```text
配当利回り = 1株配当 / 株価 * 100
```

- 配当情報はJ-Quantsを優先する。
- 欠損時はnullとする。

## 4.6 売上高成長率

```text
売上高成長率 = (直近期売上高 / 比較対象期売上高 - 1) * 100
```

- 年次または四半期の比較単位を明確にする。
- 欠損時はnullとする。

---

## 5. UI仕様

## 5.1 APIキー設定画面

Phase 3では、設定画面または初回起動時ガイドを追加する。

表示項目:

- J-Quants APIキー入力欄
- EDINET APIキー入力欄
- Gemini APIキー入力欄
- APIキー保存ボタン
- APIキー削除ボタン
- 接続テストボタン
- 各APIの取得方法説明リンクまたは説明文

注意:

- APIキーは.env_secrets/.envを基本とするが、将来的にユーザー入力保存にも対応可能な設計にする。
- Web版でユーザー入力保存する場合は、ローカルストレージ保存であることを明示する。
- APIキーをGitHubに公開しない旨をUIにも表示する。

## 5.2 検索画面

既存の条件検索に以下の実データ項目を接続する。

- PER範囲
- PBR範囲
- PSR範囲
- PEG範囲
- 配当利回り範囲
- 売上高成長率範囲
- EPS成長率範囲
- 時価総額範囲
- 業種
- 市場区分

## 5.3 検索結果一覧

表示項目:

- 銘柄コード
- 企業名
- 市場
- 業種
- 株価
- PER
- PBR
- PSR
- PEG
- 配当利回り
- 売上高成長率
- AIスコア
- 最終データ更新日

注意:

- 欠損値は「--」表示にする。
- PEGが簡易計算であることをツールチップ表示する。

## 5.4 銘柄詳細画面

表示項目:

- 株価推移
- 財務サマリー
- PER/PBR/PSR/PEG
- 売上・利益推移
- EDINET書類一覧
- AI分析コメント
- 免責事項

---

## 6. 検索履歴機能

README上でPhase 3の次フェーズ機能として記載されている検索履歴を実装する。

### 6.1 保存対象

- 検索日時
- 検索条件
- 並び替え条件
- 該当件数
- 表示名

### 6.2 保存先

Phase 3ではshared_preferencesを利用する。

### 6.3 UI

- 検索履歴一覧ページを追加する。
- 検索条件の再適用ボタンを追加する。
- 履歴削除ボタンを追加する。
- 全履歴削除ボタンを追加する。

---

## 7. ディレクトリ構成案

```text
lib/
  core/
    env_config.dart
    api_client.dart
    api_error.dart
  features/
    api_settings/
      data/
      application/
      presentation/
    stock_data/
      domain/
        stock_master.dart
        daily_stock_price.dart
        financial_summary.dart
        valuation_metrics.dart
      data/
        jquants_api_client.dart
        jquants_stock_repository.dart
        edinet_api_client.dart
        edinet_repository.dart
      application/
        stock_data_controller.dart
        valuation_calculator.dart
    stock_search/
      application/
      presentation/
    stock_detail/
      data/
        ai_analysis_service.dart
      application/
      presentation/
    search_history/
      data/
        search_history_repository.dart
      application/
        search_history_controller.dart
      presentation/
        search_history_page.dart
```

---

## 8. README更新指示

Phase 3実装時に README.md を更新し、ユーザーが各自で以下のAPIキーを取得・設定する必要があることを明記する。

### 8.1 READMEに追加する内容

READMEの「APIキーの設定」セクションを以下のように更新する。

```markdown
#### 2. APIキーの設定

本アプリでは、実データ取得とAI分析のため、以下のAPIキーをユーザー各自で取得して設定してください。

- J-Quants APIキー
  - 日本株の銘柄一覧、株価四本値、財務サマリー取得に使用します。
  - J-Quants APIは個人の私的利用を前提としたサービスです。
  - 取得したデータを第三者へ配信・共有する用途では使用しないでください。

- EDINET APIキー
  - 有価証券報告書、四半期報告書、XBRLデータ取得に使用します。
  - 金融庁EDINETにてAPIキーを取得してください。

- Gemini APIキー
  - 銘柄ごとのAI財務分析コメント生成に使用します。
  - Google AI Studio等でAPIキーを取得してください。

プロジェクトルートに `.env_secrets` フォルダと `.env` ファイルを作成してください。

.env_secrets/.env の例:

```env
GEMINI_API_KEY=your_gemini_api_key
JQUANTS_API_KEY=your_jquants_api_key
EDINET_API_KEY=your_edinet_api_key
```

⚠️ `.env_secrets` フォルダは `.gitignore` によりGit管理対象外です。APIキーをGitHub等に公開しないでください。

⚠️ 本アプリは、ユーザー各自のAPIキーを使ってユーザー本人の端末上でデータを取得・分析する設計です。アプリ開発者はJ-Quants、EDINET、Gemini由来のデータやAPIキーを同梱・再配布しません。
```

### 8.2 READMEのPhase 3表記変更

現在のREADMEではPhase 3が「リアルタイム株価API連携 + 検索履歴機能」となっている。

Phase 3では以下のように更新する。

```markdown
Phase 3
J-Quants API + EDINET API + Gemini API連携、実データ取得、AI分析強化、検索履歴機能
```

---

## 9. セキュリティ要件

- APIキーはGit管理しない。
- .env_secrets/.envを利用する。
- .gitignoreに.env_secrets/を明記する。
- エラーログにAPIキーを出力しない。
- HTTPリクエストログに認証ヘッダーを出力しない。
- ユーザー入力APIキーを保存する場合は、少なくともローカル保存であることを明示する。
- 将来的にはflutter_secure_storage等への移行を検討する。

---

## 10. エラーハンドリング

### 10.1 共通エラー

- APIキー未設定
- 認証失敗
- レート制限
- ネットワークエラー
- データ欠損
- JSONパース失敗
- API仕様変更
- 対象銘柄未対応

### 10.2 UI表示例

- 「J-Quants APIキーが設定されていません。設定画面でAPIキーを登録してください。」
- 「EDINET書類が見つかりませんでした。」
- 「Gemini APIで分析を生成できませんでした。時間をおいて再試行してください。」
- 「PEGはEPS成長率が取得できないため計算できません。」
- 「PSRは売上高または時価総額が取得できないため計算できません。」

---

## 11. テスト仕様

### 11.1 単体テスト

- EnvConfigのAPIキー取得テスト
- J-Quantsレスポンスのパーステスト
- EDINETレスポンスのパーステスト
- PER計算テスト
- PBR計算テスト
- PSR計算テスト
- PEG計算テスト
- 配当利回り計算テスト
- 検索条件フィルタリングテスト
- 検索履歴保存・削除テスト

### 11.2 結合テスト

- APIキー設定から銘柄一覧取得まで
- 銘柄選択から株価・財務・EDINET書類取得まで
- Gemini分析生成まで
- 検索条件保存と再適用

### 11.3 異常系テスト

- APIキー未設定
- 無効APIキー
- レート制限到達
- 通信失敗
- 欠損データ
- Gemini API失敗

---

## 12. 完了条件

Phase 3の完了条件は以下とする。

- READMEにJ-Quants API、EDINET API、Gemini APIをユーザー各自が設定する旨が明記されている。
- .env_secrets/.envに3種類のAPIキーを設定できる。
- J-Quants APIから銘柄一覧・株価・財務サマリーを取得できる。
- EDINET APIから対象企業の書類一覧を取得できる。
- 銘柄詳細画面でGemini AI分析を生成できる。
- PER、PBR、PSR、PEG、配当利回りの計算ロジックが実装されている。
- 検索履歴を保存・再利用・削除できる。
- APIキー未設定・通信エラー・欠損データのエラー表示が実装されている。
- J-Quants由来データを第三者配信しない設計になっている。

---

## 13. 今後の拡張候補

Phase 3完了後、以下を検討する。

- flutter_secure_storageによるAPIキー保存強化
- ローカルDBをshared_preferencesからSQLite/Isar/Hiveへ移行
- EDINET XBRL解析の高度化
- Geminiによる有価証券報告書全文要約
- kabuステーションAPIによる上級者向けリアルタイム連携
- Stooq等による過去株価補完
- AIスコア算出ロジックの透明化
- スクリーニング条件テンプレート機能
- バックテスト機能

---

## 14. 免責事項

本アプリは投資判断を支援する情報提供ツールであり、特定の金融商品の売買を推奨するものではない。表示される財務指標、AI分析コメント、スコア、ランキング等は参考情報であり、投資判断はユーザー自身の責任で行うものとする。

また、外部APIから取得されるデータの正確性、完全性、更新タイミングは各API提供元に依存する。API仕様変更、データ欠損、通信障害等により、表示内容が不正確または取得不能となる場合がある。
