import SwiftData
import SwiftUI

/// 一覧画面。並べ替えの選択は次回起動時も覚えておく
struct RecordListScreen: View {
    @AppStorage("recordSortOrder") private var sortOrder: RecordSortOrder = .rating
    @State private var searchText = ""
    @State private var addsRecord = false

    var body: some View {
        NavigationStack {
            RecordList(sortOrder: sortOrder, searchText: searchText)
                .searchable(text: $searchText, prompt: "豆の名前で検索")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Menu {
                            Picker("並べ替え", selection: $sortOrder) {
                                ForEach(RecordSortOrder.allCases) { order in
                                    Text(order.menuLabel).tag(order)
                                }
                            }
                        } label: {
                            Label("並べ替え", systemImage: "arrow.up.arrow.down")
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("記録を追加", systemImage: "plus") { addsRecord = true }
                            .buttonStyle(.glassProminent)
                            .tint(.coffeeAccent)
                    }
                }
                .sheet(isPresented: $addsRecord) {
                    RecordEditorSheet()
                }
                .navigationDestination(for: CoffeeRecord.self) { record in
                    RecordDetailScreen(record: record)
                }
        }
    }
}

/// 並び順と検索条件で取り出した記録の一覧。行を左にスワイプすると削除できる
struct RecordList: View {
    let sortOrder: RecordSortOrder
    let searchText: String
    @Query private var records: [CoffeeRecord]
    @Environment(\.modelContext) private var modelContext
    /// スワイプで削除を選び、確認待ちの記録
    @State private var pendingDelete: CoffeeRecord?

    init(sortOrder: RecordSortOrder, searchText: String) {
        self.sortOrder = sortOrder
        self.searchText = searchText
        _records = Query(filter: RecordSearch.predicate(matching: searchText), sort: sortOrder.sortDescriptors)
    }

    var body: some View {
        List {
            // タイトルは行ではなく見出しに置く（行に置くと List の切り抜きで文字の左端が欠ける）
            Section {
                if records.isEmpty {
                    emptyView
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                }
            } header: {
                VStack(alignment: .leading, spacing: 4) {
                    Text("COFFEE LOG")
                        .font(.coffeeCondensed(size: 44, weight: .bold))
                        .foregroundStyle(Color.coffeeAccent)
                    Text("\(sortOrder.label) · \(records.count)杯")
                        .font(.subheadline)
                        .foregroundStyle(Color.coffeeSecondaryText)
                }
                .textCase(nil)
                .padding(.leading, -16)
                .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
            }

            switch sortOrder {
            case .rating:
                Section {
                    rows(records, showsDate: true)
                }
            case .newest:
                ForEach(DaySection.group(records, calendar: .current)) { section in
                    Section {
                        rows(section.records, showsDate: false)
                    } header: {
                        Text(CoffeeDateFormat.long(section.day))
                            .font(.coffeeCondensed(size: 15, weight: .medium))
                            .tracking(1.8)
                            .foregroundStyle(Color.coffeeSecondaryText)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .listSectionSpacing(18)
        .scrollContentBackground(.hidden)
        .background(Color.coffeeBackground)
        .foregroundStyle(Color.coffeeText)
        .confirmationDialog(
            "この記録を削除しますか？",
            isPresented: Binding(get: { pendingDelete != nil }, set: { if !$0 { pendingDelete = nil } }),
            titleVisibility: .visible,
            presenting: pendingDelete
        ) { record in
            Button("削除", role: .destructive) {
                modelContext.delete(record)
                pendingDelete = nil
            }
        } message: { record in
            Text("「\(record.name)」を削除すると元に戻せません。")
        }
    }

    private func rows(_ records: [CoffeeRecord], showsDate: Bool) -> some View {
        ForEach(records) { record in
            // NavigationLink をそのまま行にすると右に「>」が付くので、透明にして重ねる
            RecordRow(record: record, showsDate: showsDate)
                .background {
                    NavigationLink(value: record) { EmptyView() }.opacity(0)
                }
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.coffeeCard)
                .listRowSeparatorTint(Color.coffeeSeparator)
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    // role: .destructive にすると確認前に行が消えるアニメーションになるので、色だけ赤にする
                    Button("削除", systemImage: "trash") { pendingDelete = record }
                        .tint(.red)
                }
        }
    }

    @ViewBuilder private var emptyView: some View {
        if searchText.nilIfBlank != nil {
            ContentUnavailableView.search(text: searchText)
        } else {
            ContentUnavailableView(
                "まだ記録がありません",
                systemImage: "cup.and.saucer",
                description: Text("右上の + から飲んだコーヒーを記録できます")
            )
        }
    }
}

private struct RecordRow: View {
    let record: CoffeeRecord
    let showsDate: Bool

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text(record.name)
                    .font(.coffeeName(size: 18))
                if let subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(Color.coffeeSecondaryText)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            VStack(alignment: .trailing, spacing: 4) {
                RatingStars(rating: record.rating)
                if showsDate {
                    Text(CoffeeDateFormat.short(record.date))
                        .font(.coffeeCondensed(size: 14, weight: .medium))
                        .tracking(1.4)
                        .foregroundStyle(Color.coffeeSecondaryText)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
        .background(Color.coffeeCard)
        .accessibilityElement(children: .combine)
    }

    /// 店と焙煎度のうち入力済みのものを「·」でつなぐ
    private var subtitle: String? {
        let parts = [record.shop, record.roast?.label].compactMap { $0 }
        return parts.isEmpty ? nil : parts.joined(separator: " · ")
    }
}

struct RatingStars: View {
    let rating: Int

    var body: some View {
        let on = Text(String(repeating: "★", count: rating)).foregroundStyle(Color.coffeeAccent)
        let off = Text(String(repeating: "★", count: max(0, 5 - rating))).foregroundStyle(Color.coffeeStarOff)
        Text("\(on)\(off)")
            .font(.system(size: 14))
            .tracking(1)
            .accessibilityLabel("評価 \(rating) / 5")
    }
}

#Preview("評価の高い順", traits: .sampleRecords) {
    RecordListScreen()
}

#Preview("新しい順", traits: .sampleRecords) {
    NavigationStack {
        RecordList(sortOrder: .newest, searchText: "")
    }
}

#Preview("0 件") {
    RecordListScreen()
        .modelContainer(try! .coffeeLog(inMemory: true))
}
