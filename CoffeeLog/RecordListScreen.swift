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
        }
    }
}

/// 並び順と検索条件で取り出した記録の一覧
struct RecordList: View {
    let sortOrder: RecordSortOrder
    let searchText: String
    @Query private var records: [CoffeeRecord]

    init(sortOrder: RecordSortOrder, searchText: String) {
        self.sortOrder = sortOrder
        self.searchText = searchText
        _records = Query(filter: RecordSearch.predicate(matching: searchText), sort: sortOrder.sortDescriptors)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text("COFFEE LOG")
                    .font(.coffeeCondensed(size: 44, weight: .bold))
                    .foregroundStyle(Color.coffeeAccent)
                    .padding(.horizontal, 20)
                Text("\(sortOrder.label) · \(records.count)杯")
                    .font(.subheadline)
                    .foregroundStyle(Color.coffeeSecondaryText)
                    .padding(.horizontal, 20)
                    .padding(.top, 4)
                    .padding(.bottom, 14)

                if records.isEmpty {
                    emptyView
                } else {
                    switch sortOrder {
                    case .rating:
                        RecordCard(records: records, showsDate: true)
                            .padding(.horizontal, 16)
                    case .newest:
                        VStack(alignment: .leading, spacing: 18) {
                            ForEach(DaySection.group(records, calendar: .current)) { section in
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(CoffeeDateFormat.long(section.day))
                                        .font(.coffeeCondensed(size: 15, weight: .medium))
                                        .tracking(1.8)
                                        .foregroundStyle(Color.coffeeSecondaryText)
                                        .padding(.horizontal, 4)
                                        .accessibilityAddTraits(.isHeader)
                                    RecordCard(records: section.records, showsDate: false)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
            }
            .padding(.bottom, 24)
        }
        .background(Color.coffeeBackground)
        .foregroundStyle(Color.coffeeText)
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

/// 角丸のカードに行を区切り線つきで並べる
private struct RecordCard: View {
    let records: [CoffeeRecord]
    let showsDate: Bool

    var body: some View {
        VStack(spacing: 1) {
            ForEach(records) { record in
                RecordRow(record: record, showsDate: showsDate)
            }
        }
        .background(Color.coffeeSeparator)
        .clipShape(.rect(cornerRadius: 12))
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
