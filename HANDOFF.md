# 引き継ぎメモ（2026-09-28 時点）

## できていること

| 内容 | 主なファイル | テスト |
|---|---|---|
| 保存可否の判定（名称が空白以外、評価 1〜5） | `CoffeeLog/RecordDraft.swift` | `RecordDraftTests` |
| 空欄を nil にそろえる（前後の空白除去、全角スペース・改行も対象） | `CoffeeLog/String+NilIfBlank.swift` | `NilIfBlankTests` |
| スキーマ v1 の `CoffeeRecord`（全項目）と空の移行計画 | `CoffeeLog/CoffeeSchemaV1.swift` | `CoffeeRecordTests` |
| 購入形態・焙煎度の enum（保存は rawValue の文字列、日本語ラベル付き） | `CoffeeLog/CoffeeRecord+Choices.swift` | `CoffeeRecordTests` |

テストは 11 本、すべて成功。画面は `ContentView` に「COFFEE LOG」と表示するだけの仮のもの。

## 次にやること（この順を推奨）

1. **`RecordDraft` → `CoffeeRecord` の変換**（TDD）
   - `RecordDraft` は今 `name` と `rating` しか持っていない。入力画面の全項目（日付、店、購入形態、焙煎度、価格、容量、写真、味 6 軸、生産国、品種、メモ）を足す
   - TODO 案
     - 名称は前後の空白を除いて保存する
     - 任意の文字列項目は `nilIfBlank` で空欄を nil にする
     - 作成日時はテストから注入できるようにする（例: `makeRecord(now:)`）
     - 保存できない下書きからは作れない（`canSave == false` のとき）
   - 未決: 価格の入力値（文字列）を `Int?` にする変換をどこで行うか
2. **並び順の比較**: 評価順は rating 降順 → date 降順 → createdAt 降順。新しい順は date 降順 → createdAt 降順
3. **日付ごとのまとめ方**: date の日単位でグループ化（新しい順の表示用）
4. **アプリに `ModelContainer` を設定**: `CoffeeLogApp` で `Schema(versionedSchema: CoffeeSchemaV1.self)` と `CoffeeMigrationPlan` を使う
5. **画面の実装**: 一覧 → 入力シート → 詳細の順。仕様は org の「デザイン決定」とモック参照

## 未解決・注意

- 最初から通ったテスト（`名称が空か空白だけなら保存できない` の空文字・全角ケース、`途中の空白は残す`）は、実装を壊して失敗することを確かめていない
- テストしていないもの: enum の `label`、未知の raw 文字列が nil になること
- 評価の 1〜5 制限はモデル側では持たず、`RecordDraft.canSave` だけで弾いている
- `xcodebuild` が失敗時に終了しない原因は未調査（記事で CLI からのテスト実行を書くなら要調査）
- 実装しながら決めること: 検索対象（名称・店だけか、メモも含めるか）、Preview 用サンプルデータ
- 写真の縮小（長辺 2048px、JPEG 画質 0.8）は未実装
- 見送り（3 本目以降）: 国旗サジェスト、画像カードでの共有、SNS 共有、豆カードの OCR
