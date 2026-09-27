# CoffeeLog

飲んだコーヒーを記録して比べる iOS アプリ。Qiita 記事「Web エンジニアが iOS アプリを実機で動かすまでの記録」2 本目の題材。

## 要件・決定事項の置き場所

要件はこのリポジトリではなく org 側にある。実装前に該当箇所を読むこと。

- `~/Library/CloudStorage/Dropbox/org/yaritai.org`
  - 「アプリ案 > 自分が飲んだコーヒーの比較ができるアプリ」の下
    - `デザイン決定（2026-09-27）`: 画面構成・見た目・一覧／詳細／入力の仕様
    - `データモデル（2026-09-27）`: 項目の一覧、空欄の扱い、並び順のルール、スキーマ管理方針
  - 「記事案 > Web エンジニアが iOS アプリを実機で動かすまでの記録」: 記事の構成
- デザインモック（Claude Design キャンバス）: https://claude.ai/artifact/8vm6H54iHK4xxYiq96NvuY
  - 採用案は「決定案」行と「詳細画面: 写真ヒーロー × フォント案」の A

## 技術構成

- SwiftUI + SwiftData（端末内保存のみ。バックエンド・iCloud 同期なし）
- iOS 26 以降、iPhone のみ、縦画面のみ
- Xcode 27、Swift 5 言語モード、`SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`
- テストは Swift Testing（`@Test` / `#expect`）
- 署名は無料 Apple ID の Personal Team（Hello World と同じ Team）

## プロジェクト構成

- `CoffeeLog/`: アプリ本体。`CoffeeLogTests/`: ユニットテスト
- どちらも Xcode のフォルダ同期（`PBXFileSystemSynchronizedRootGroup`）なので、フォルダにファイルを置けばターゲットに入る。pbxproj の編集は不要
- `CoffeeLog.xcodeproj` は Xcode の新規作成ウィザードではなく、`../HelloWorld` の pbxproj から生成したもの（macOS / visionOS 向け設定は削除済み）

## テストの実行

```bash
scripts/test.sh
```

- 失敗時に `xcodebuild` がプロセスを終了しないことがある（原因未調査）。スクリプトは 300 秒で強制終了する
- 出力が `** TEST SUCCEEDED/FAILED **` を含まずに終わったら、強制終了されたと判断する
- 絞り込みで原因が見えないときは、`xcodebuild test ...` を直接実行してログ全体を見る。テスト実行アプリのクラッシュは `~/Library/Logs/DiagnosticReports/CoffeeLog-*.ips` に残る

## 開発の進め方

- t-wada 流の TDD。
- テストファイルの先頭に `// TODO（…）` のチェックリストを置き、完了したら `[x]` にする
- 最初から通るテスト（Red にならないもの）は、仕様を記録するテストとして追加してよい。ただし報告では Red がなかったことを明記する
- テスト名・コメントは日本語
- 要件が曖昧なら実装に入る前に確認する

## ハマりどころ

- SwiftData のテストでは `ModelContainer` を保持し続けること。`container.mainContext` だけを返すヘルパーにすると、container が解放されて SwiftData 内部でクラッシュする
- `@Model` を扱うテストの struct には `@MainActor` を付ける（アプリ側の既定の isolation が MainActor のため）
- `~/dev` は `~/Documents/develop` へのシンボリックリンク。「デスクトップと書類」の iCloud 同期の対象なので、`-derivedDataPath` をプロジェクト内に置かない（既定の `~/Library/Developer/Xcode/DerivedData` を使う）
- 保存スキーマを変えるときは `CoffeeSchemaV1` を直接いじらず、V2 を追加して `CoffeeMigrationPlan` に移行手順を足す
