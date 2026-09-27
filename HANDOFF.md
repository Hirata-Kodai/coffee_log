# 引き継ぎメモ（2026-09-28 時点）

## できていること

| 内容 | 主なファイル | テスト |
|---|---|---|
| 保存可否の判定（名称が空白以外、評価 1〜5） | `CoffeeLog/RecordDraft.swift` | `RecordDraftTests` |
| 空欄を nil にそろえる（前後の空白除去、全角スペース・改行も対象） | `CoffeeLog/String+NilIfBlank.swift` | `NilIfBlankTests` |
| スキーマ v1 の `CoffeeRecord`（全項目）と空の移行計画 | `CoffeeLog/CoffeeSchemaV1.swift` | `CoffeeRecordTests` |
| 購入形態・焙煎度の enum（保存は rawValue の文字列、日本語ラベル付き） | `CoffeeLog/CoffeeRecord+Choices.swift` | `CoffeeRecordTests` |
| `RecordDraft` → `CoffeeRecord` の変換（新規作成のみ）と価格の妥当性チェック | `CoffeeLog/RecordDraft.swift` | `MakeRecordTests`, `RecordDraftTests` |

テストは 21 本、すべて成功。画面は `ContentView` に「COFFEE LOG」と表示するだけの仮のもの。

## 次にやること（この順を推奨）

1. **並び順の比較**: 評価順は rating 降順 → date 降順 → createdAt 降順。新しい順は date 降順 → createdAt 降順
2. **日付ごとのまとめ方**: date の日単位でグループ化（新しい順の表示用）
3. **アプリに `ModelContainer` を設定**: `CoffeeLogApp` で `Schema(versionedSchema: CoffeeSchemaV1.self)` と `CoffeeMigrationPlan` を使う
4. **画面の実装**: 一覧 → 入力シート → 詳細の順。仕様は org の「デザイン決定」とモック参照
   - 編集（記録 → 下書き、下書き → 既存の記録へ反映）は入力シートを作るときに TDD で足す

## 変換で決めたこと（2026-09-28）

- `makeRecord(now:calendar:) -> CoffeeRecord?`。`canSave == false` なら nil
- 日付は `calendar.startOfDay(for:)` でその日の 0 時にそろえて保存する（並び順の date → createdAt を時刻に左右させないため）
- 価格は下書きが文字列（`priceText`）で持つ。空欄は nil。入力があって 0 以上の整数として読めない（負、カンマ、小数、全角数字など）なら保存不可。画面は `TextField(text:)` + numberPad を想定

## 未解決・注意

- 最初から通ったテスト（`名称が空か空白だけなら保存できない` の空文字・全角ケース、`途中の空白は残す`）は、実装を壊して失敗することを確かめていない
- テストしていないもの: enum の `label`、未知の raw 文字列が nil になること
- 評価の 1〜5 制限はモデル側では持たず、`RecordDraft.canSave` だけで弾いている。味 6 軸の 1〜5 は下書きでも検査していない（画面の 5 段階入力で制限する前提）
- `RecordDraft.date` の初期値（今日）はテストしていない
- `xcodebuild` が失敗時に終了しない原因は未調査（記事で CLI からのテスト実行を書くなら要調査）
- 実装しながら決めること: 検索対象（名称・店だけか、メモも含めるか）、Preview 用サンプルデータ
- 写真の縮小（長辺 2048px、JPEG 画質 0.8）は未実装
- 見送り（3 本目以降）: 国旗サジェスト、画像カードでの共有、SNS 共有、豆カードの OCR
