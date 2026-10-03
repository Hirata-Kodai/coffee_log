import PhotosUI
import SwiftData
import SwiftUI

/// 記録の入力シート。新規作成と編集で使い回す
struct RecordEditorSheet: View {
    /// 編集する記録。nil なら新規作成
    let record: CoffeeRecord?

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var draft: RecordDraft
    @State private var original: RecordDraft
    @State private var showsDetails: Bool
    @State private var confirmsDiscard = false

    init(record: CoffeeRecord? = nil) {
        self.record = record
        let draft = record.map(RecordDraft.init(record:)) ?? RecordDraft()
        _draft = State(initialValue: draft)
        _original = State(initialValue: draft)
        // 詳細は初期は閉じる。編集時に詳細の項目が入っていれば開いておく
        _showsDetails = State(initialValue: draft.hasDetails)
    }

    private var hasChanges: Bool { draft != original }

    var body: some View {
        NavigationStack {
            Form {
                Section("必須") {
                    LabeledTextField(label: "名称", text: $draft.name, prompt: "例：ケニア AB")
                    RatingPicker(rating: $draft.rating)
                    DatePicker("日付", selection: $draft.date, displayedComponents: .date)
                }
                .listRowBackground(Color.coffeeCard)
                Section("基本") {
                    LabeledTextField(label: "店", text: $draft.shop, prompt: "例：村上コーヒー")
                    Picker("購入形態", selection: $draft.purchaseType) {
                        Text("未選択").tag(PurchaseType?.none)
                        ForEach(PurchaseType.allCases, id: \.self) { type in
                            Text(type.label).tag(Optional(type))
                        }
                    }
                    .tint(.coffeeAccent)
                    RoastPicker(roast: $draft.roast)
                    LabeledContent("価格") {
                        HStack(spacing: 4) {
                            Text("¥").foregroundStyle(Color.coffeeSecondaryText)
                            TextField("価格", text: $draft.priceText, prompt: Text("例：520"))
                                .keyboardType(.numberPad)
                        }
                    }
                    LabeledTextField(label: "容量", text: $draft.volume, prompt: "例：200g、R")
                    PhotoField(photo: $draft.photo)
                }
                .listRowBackground(Color.coffeeCard)
                Section {
                    DisclosureGroup("詳細（味・産地・メモ）", isExpanded: $showsDetails) {
                        TasteFields(draft: $draft)
                        LabeledTextField(label: "生産国", text: $draft.origin, prompt: "例：エチオピア")
                        LabeledTextField(label: "品種", text: $draft.variety, prompt: "例：ゲイシャ")
                        TextField("メモ", text: $draft.memo, prompt: Text("香りや淹れ方の気づきなど"), axis: .vertical)
                            .lineLimit(3...)
                    }
                    .tint(.coffeeText)
                }
                .listRowBackground(Color.coffeeCard)
            }
            .scrollContentBackground(.hidden)
            .background(Color.coffeeBackground)
            .foregroundStyle(Color.coffeeText)
            .navigationTitle(record == nil ? "新しい記録" : "記録を編集")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル", systemImage: "xmark", role: .cancel) {
                        if hasChanges { confirmsDiscard = true } else { dismiss() }
                    }
                    .confirmationDialog("入力した内容を破棄しますか？", isPresented: $confirmsDiscard, titleVisibility: .visible) {
                        Button("変更を破棄", role: .destructive) { dismiss() }
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存", systemImage: "checkmark", role: .confirm, action: save)
                        .disabled(!draft.canSave)
                        .tint(.coffeeAccent)
                }
            }
        }
        // 入力途中に下スワイプで消えないようにする
        .interactiveDismissDisabled(hasChanges)
    }

    private func save() {
        if let record {
            guard draft.apply(to: record) else { return }
        } else {
            guard let newRecord = draft.makeRecord(now: .now) else { return }
            modelContext.insert(newRecord)
        }
        dismiss()
    }
}

private extension RecordDraft {
    /// 詳細欄（味・生産国・品種・メモ）に何か入っているか
    var hasDetails: Bool {
        let tastes = [aroma, acidity, sweetness, body, aftertaste, bitterness]
        return tastes.contains { $0 != nil }
            || [origin, variety, memo].contains { $0.nilIfBlank != nil }
    }
}

private struct LabeledTextField: View {
    let label: String
    @Binding var text: String
    let prompt: String

    var body: some View {
        LabeledContent(label) {
            TextField(label, text: $text, prompt: Text(prompt))
        }
    }
}

/// 総合評価の星。未選択から始める
private struct RatingPicker: View {
    @Binding var rating: Int?

    var body: some View {
        LabeledContent("総合評価") {
            HStack(spacing: 0) {
                ForEach(RecordDraft.ratingRange, id: \.self) { value in
                    Button {
                        rating = value
                    } label: {
                        Text("★")
                            .font(.system(size: 26))
                            .foregroundStyle(value <= (rating ?? 0) ? Color.coffeeAccent : Color.coffeeStarOff)
                            .frame(width: 40, height: 44)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("星 \(value)")
                    .accessibilityAddTraits(value == rating ? .isSelected : [])
                }
            }
        }
    }
}

/// 焙煎度。選択中をもう一度押すと未選択に戻す
private struct RoastPicker: View {
    @Binding var roast: Roast?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("焙煎度")
            HStack(spacing: 2) {
                ForEach(Roast.allCases, id: \.self) { value in
                    let selected = roast == value
                    Button {
                        roast = selected ? nil : value
                    } label: {
                        Text(value.label)
                            .font(.subheadline.weight(selected ? .bold : .regular))
                            .frame(maxWidth: .infinity, minHeight: 36)
                            .background(selected ? Color.white : Color.clear, in: .rect(cornerRadius: 8))
                            .shadow(color: selected ? .black.opacity(0.15) : .clear, radius: 2, y: 1)
                    }
                    .buttonStyle(.plain)
                    .accessibilityAddTraits(selected ? .isSelected : [])
                }
            }
            .padding(2)
            .background(Color.coffeeSeparator.opacity(0.6), in: .rect(cornerRadius: 10))
        }
        .padding(.vertical, 4)
    }
}

/// 味 6 軸の 5 段階。選択中をもう一度押すと未入力に戻す
private struct TasteFields: View {
    @Binding var draft: RecordDraft

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text("味（5段階）")
                Spacer()
                Text("弱い → 強い")
            }
            .font(.footnote)
            .foregroundStyle(Color.coffeeSecondaryText)
            TasteRow(name: "香り", value: $draft.aroma)
            TasteRow(name: "酸味", value: $draft.acidity)
            TasteRow(name: "甘さ", value: $draft.sweetness)
            TasteRow(name: "コク", value: $draft.body)
            TasteRow(name: "後味", value: $draft.aftertaste)
            TasteRow(name: "苦味", value: $draft.bitterness)
        }
    }
}

private struct TasteRow: View {
    let name: String
    @Binding var value: Int?

    var body: some View {
        HStack(spacing: 0) {
            Text(name).frame(width: 56, alignment: .leading)
            ForEach(1...5, id: \.self) { level in
                let selected = value == level
                Button {
                    value = selected ? nil : level
                } label: {
                    Circle()
                        .strokeBorder(Color.coffeeAccent, lineWidth: 2)
                        .background(Circle().fill(selected ? Color.coffeeAccent : .clear))
                        .frame(width: 18, height: 18)
                        .frame(maxWidth: .infinity, minHeight: 44)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("\(name) \(level)")
                .accessibilityAddTraits(selected ? .isSelected : [])
            }
        }
    }
}

/// 写真 1 枚。撮影かライブラリから選び、保存用に縮小する
private struct PhotoField: View {
    @Binding var photo: Data?
    @State private var showsLibrary = false
    @State private var showsCamera = false
    @State private var libraryItem: PhotosPickerItem?

    var body: some View {
        LabeledContent("写真") {
            HStack(spacing: 12) {
                if let photo, let image = UIImage(data: photo) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 44, height: 44)
                        .clipShape(.rect(cornerRadius: 6))
                        .accessibilityHidden(true)
                }
                Menu {
                    if UIImagePickerController.isSourceTypeAvailable(.camera) {
                        Button("写真を撮る", systemImage: "camera") { showsCamera = true }
                    }
                    Button("ライブラリから選ぶ", systemImage: "photo.on.rectangle") { showsLibrary = true }
                    if photo != nil {
                        Button("写真を削除", systemImage: "trash", role: .destructive) { photo = nil }
                    }
                } label: {
                    Label(photo == nil ? "追加" : "変更", systemImage: "camera")
                        .foregroundStyle(Color.coffeeAccent)
                }
            }
        }
        .photosPicker(isPresented: $showsLibrary, selection: $libraryItem, matching: .images)
        .onChange(of: libraryItem) { _, item in
            guard let item else { return }
            Task {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    photo = PhotoResizer.jpegData(from: image)
                }
                libraryItem = nil
            }
        }
        .fullScreenCover(isPresented: $showsCamera) {
            CameraPicker { image in
                photo = PhotoResizer.jpegData(from: image)
            }
            .ignoresSafeArea()
        }
    }
}

/// UIKit のカメラ画面。撮影したら画像を渡して閉じる
private struct CameraPicker: UIViewControllerRepresentable {
    let onCapture: (UIImage) -> Void
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraPicker

        init(_ parent: CameraPicker) { self.parent = parent }

        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.onCapture(image)
            }
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

#Preview("新しい記録") {
    RecordEditorSheet()
        .modelContainer(try! .coffeeLog(inMemory: true))
}
