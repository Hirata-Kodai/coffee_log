import SwiftData
import SwiftUI

/// 詳細画面。写真があれば上部に大きく出し、入力済みの項目だけを並べる
struct RecordDetailScreen: View {
    let record: CoffeeRecord

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var edits = false
    @State private var confirmsDelete = false

    var body: some View {
        let photo = record.photo.flatMap(UIImage.init(data:))
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                if let photo {
                    Color.clear
                        .frame(height: 360)
                        .overlay {
                            Image(uiImage: photo)
                                .resizable()
                                .scaledToFill()
                        }
                        .clipped()
                        .accessibilityLabel("写真")
                }
                header
                    .padding(.horizontal, 20)
                    .padding(.top, 24)

                let rows = RecordDetail.infoRows(for: record)
                if !rows.isEmpty {
                    SectionHeading("基本情報")
                    VStack(spacing: 1) {
                        ForEach(rows, id: \.label) { row in
                            HStack {
                                Text(row.label)
                                Spacer()
                                Text(row.value)
                            }
                            .padding(.horizontal, 16)
                            .frame(minHeight: 46)
                            .background(Color.coffeeCard)
                            .accessibilityElement(children: .combine)
                        }
                    }
                    .background(Color.coffeeSeparator)
                    .clipShape(.rect(cornerRadius: 12))
                    .padding(.horizontal, 16)
                }

                if let taste = RecordDetail.taste(for: record) {
                    SectionHeading("味")
                    VStack(spacing: 8) {
                        TasteChart(taste: taste)
                            .frame(width: 320, height: 260)
                        Text(taste.summary)
                            .font(.footnote)
                            .foregroundStyle(Color.coffeeSecondaryText)
                            .accessibilityHidden(true)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 12)
                    .padding(.bottom, 16)
                    .background(Color.coffeeCard, in: .rect(cornerRadius: 12))
                    .padding(.horizontal, 16)
                }

                if let memo = record.memo {
                    SectionHeading("メモ")
                    Text(memo)
                        .lineSpacing(6)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(Color.coffeeCard, in: .rect(cornerRadius: 12))
                        .padding(.horizontal, 16)
                }

                Button("この記録を削除", role: .destructive) { confirmsDelete = true }
                    // 画面全体の文字色に上書きされないよう、削除の赤を明示する
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, minHeight: 46)
                    .background(Color.coffeeCard, in: .rect(cornerRadius: 12))
                    .padding(.horizontal, 16)
                    .padding(.top, 36)
                    .confirmationDialog("この記録を削除しますか？", isPresented: $confirmsDelete, titleVisibility: .visible) {
                        Button("削除", role: .destructive, action: delete)
                    } message: {
                        Text("削除すると元に戻せません。")
                    }
            }
            .padding(.bottom, 32)
        }
        .ignoresSafeArea(edges: photo == nil ? [] : .top)
        .background(Color.coffeeBackground)
        .foregroundStyle(Color.coffeeText)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("編集") { edits = true }
            }
        }
        .sheet(isPresented: $edits) {
            RecordEditorSheet(record: record)
        }
    }

    /// 日付・店、名称、総合評価
    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text([CoffeeDateFormat.long(record.date), record.shop].compactMap { $0 }.joined(separator: " · "))
                .font(.coffeeCondensed(size: 15, weight: .medium))
                .tracking(1.8)
                .foregroundStyle(Color.coffeeSecondaryText)
            Text(record.name)
                .font(.coffeeName(size: 30))
                .lineSpacing(6)
                .accessibilityAddTraits(.isHeader)
            Text(String(repeating: "★", count: record.rating))
                .font(.system(size: 24))
                .tracking(3)
                .foregroundStyle(Color.coffeeAccent)
                .accessibilityLabel("総合評価 \(record.rating) / 5")
        }
    }

    private func delete() {
        modelContext.delete(record)
        dismiss()
    }
}

private struct SectionHeading: View {
    let title: String

    init(_ title: String) { self.title = title }

    var body: some View {
        Text(title)
            .font(.custom("HiraMinProN-W6", size: 15, relativeTo: .subheadline))
            .tracking(0.6)
            .foregroundStyle(Color.coffeeSecondaryText)
            .padding(.horizontal, 36)
            .padding(.top, 28)
            .padding(.bottom, 6)
            .accessibilityAddTraits(.isHeader)
    }
}

/// 味 6 軸のレーダーチャート。未入力の軸は中心に置く
private struct TasteChart: View {
    let taste: RecordDetail.Taste

    var body: some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let radius: CGFloat = 96
            let count = taste.values.count

            func point(axis: Int, ratio: CGFloat) -> CGPoint {
                // 香りを真上に置き、時計回りに並べる
                let angle = -CGFloat.pi / 2 + CGFloat(axis) * 2 * .pi / CGFloat(count)
                return CGPoint(x: center.x + cos(angle) * radius * ratio,
                               y: center.y + sin(angle) * radius * ratio)
            }

            func polygon(_ ratios: [CGFloat]) -> Path {
                Path { path in
                    for (axis, ratio) in ratios.enumerated() {
                        let p = point(axis: axis, ratio: ratio)
                        axis == 0 ? path.move(to: p) : path.addLine(to: p)
                    }
                    path.closeSubpath()
                }
            }

            // 目盛り（1〜5）と軸
            for level in 1...5 {
                let ratio = CGFloat(level) / 5
                context.stroke(polygon(Array(repeating: ratio, count: count)), with: .color(.coffeeStarOff), lineWidth: 1)
            }
            for axis in 0..<count {
                var line = Path()
                line.move(to: center)
                line.addLine(to: point(axis: axis, ratio: 1))
                context.stroke(line, with: .color(.coffeeStarOff), lineWidth: 1)
            }

            // 値
            let values = polygon(taste.values.map { CGFloat($0.value ?? 0) / 5 })
            context.fill(values, with: .color(Color.coffeeAccent.opacity(0.22)))
            context.stroke(values, with: .color(.coffeeAccent), style: StrokeStyle(lineWidth: 2, lineJoin: .round))

            // 軸の名前
            for (axis, item) in taste.values.enumerated() {
                let label = Text(item.name).font(.subheadline).foregroundStyle(Color.coffeeText)
                let p = point(axis: axis, ratio: 1.22)
                context.draw(label, at: p)
            }
        }
        .accessibilityElement()
        .accessibilityLabel("味のチャート：\(taste.summary)")
    }
}

#if DEBUG
#Preview("写真なし", traits: .sampleRecords) {
    @Previewable @Query(sort: \CoffeeRecord.rating, order: .reverse) var records: [CoffeeRecord]
    NavigationStack {
        if let record = records.first {
            RecordDetailScreen(record: record)
        }
    }
}
#endif
