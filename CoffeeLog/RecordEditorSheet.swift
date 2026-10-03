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
    @FocusState private var focusedField: EditorField?

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
                        .focused($focusedField, equals: .name)
                    RatingPicker(rating: $draft.rating)
                    DatePicker("日付", selection: $draft.date, displayedComponents: .date)
                }
                .listRowBackground(Color.coffeeCard)
                Section("基本") {
                    LabeledTextField(label: "店", text: $draft.shop, prompt: "例：村上コーヒー")
                        .focused($focusedField, equals: .shop)
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
                                .focused($focusedField, equals: .price)
                        }
                    }
                    LabeledContent("容量") {
                        HStack(spacing: 4) {
                            TextField("容量", text: $draft.volume, prompt: Text("例：200"))
                                .keyboardType(.numberPad)
                                .focused($focusedField, equals: .volume)
                            Text(RecordDraft.volumeUnit).foregroundStyle(Color.coffeeSecondaryText)
                        }
                    }
                    PhotoField(photo: $draft.photo)
                }
                .listRowBackground(Color.coffeeCard)
                Section {
                    DisclosureGroup("詳細（味・産地・メモ）", isExpanded: $showsDetails) {
                        TasteFields(draft: $draft)
                        LabeledTextField(label: "生産国", text: $draft.origin, prompt: "例：エチオピア")
                            .focused($focusedField, equals: .origin)
                        LabeledTextField(label: "品種", text: $draft.variety, prompt: "例：ゲイシャ")
                            .focused($focusedField, equals: .variety)
                        TextField("メモ", text: $draft.memo, prompt: Text("香りや淹れ方の気づきなど"), axis: .vertical)
                            .lineLimit(3...)
                            .focused($focusedField, equals: .memo)
                    }
                    .tint(.coffeeText)
                }
                .listRowBackground(Color.coffeeCard)
            }
            // 入力欄以外をタップしたらキーボードを閉じる。スクロールでは閉じない
            .background(KeyboardDismissOnTap())
            .scrollDismissesKeyboard(.never)
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
                // iOS 標準のフォームと同じく、キーボードの上に前後の欄への移動と閉じるボタンを置く
                ToolbarItemGroup(placement: .keyboard) {
                    Button("前の項目", systemImage: "chevron.up") {
                        focusedField = focusedField?.previous(showsDetails: showsDetails)
                    }
                    .disabled(focusedField?.previous(showsDetails: showsDetails) == nil)
                    Button("次の項目", systemImage: "chevron.down") {
                        focusedField = focusedField?.next(showsDetails: showsDetails)
                    }
                    .disabled(focusedField?.next(showsDetails: showsDetails) == nil)
                    Spacer()
                    Button("キーボードを閉じる", systemImage: "checkmark") { focusedField = nil }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(role: .confirm, action: save) {
                        // 明るいプラムの上でも見えるよう、記号に直接色を付ける（保存できない間はシステムの薄い色）
                        Image(systemName: "checkmark")
                            .foregroundStyle(draft.canSave ? Color.coffeeOnAccent : Color.secondary)
                    }
                    .accessibilityLabel("保存")
                    .disabled(!draft.canSave)
                    .buttonStyle(.glassProminent)
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
                            .background(selected ? Color.coffeeSelectedFill : Color.clear, in: .rect(cornerRadius: 8))
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
                Button {
                    // 選んでいる値をもう一度押すと未入力に戻す
                    value = value == level ? nil : level
                } label: {
                    CoffeeBeanMark(filled: level <= (value ?? 0))
                        .frame(width: 16, height: 21)
                        .frame(maxWidth: .infinity, minHeight: 44)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("\(name) \(level)")
                .accessibilityAddTraits(value == level ? .isSelected : [])
            }
        }
    }
}

/// コーヒー豆のマーク。値以下の豆を塗りつぶす
private struct CoffeeBeanMark: View {
    let filled: Bool

    var body: some View {
        ZStack {
            if filled {
                Ellipse().fill(Color.coffeeAccent)
                BeanCrease().stroke(Color.coffeeCard, style: StrokeStyle(lineWidth: 1.6, lineCap: .round))
            } else {
                Ellipse().strokeBorder(Color.coffeeAccent, lineWidth: 1.6)
                BeanCrease().stroke(Color.coffeeAccent, style: StrokeStyle(lineWidth: 1.6, lineCap: .round))
            }
        }
        .rotationEffect(.degrees(20))
    }
}

/// 豆の中央の S 字の溝
private struct BeanCrease: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.midX, y: rect.minY + rect.height * 0.12))
            path.addCurve(
                to: CGPoint(x: rect.midX, y: rect.maxY - rect.height * 0.12),
                control1: CGPoint(x: rect.midX - rect.width * 0.32, y: rect.minY + rect.height * 0.42),
                control2: CGPoint(x: rect.midX + rect.width * 0.32, y: rect.minY + rect.height * 0.58)
            )
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

/// 入力欄以外のタップでキーボードを閉じる。
/// SwiftUI の TapGesture を Form に付けると開閉ボタンなどのタップを奪うので、
/// 他の操作を止めない UIKit のタップ認識をウインドウに付ける
private struct KeyboardDismissOnTap: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.isUserInteractionEnabled = false
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        // ウインドウに載るのを待ってから付ける
        DispatchQueue.main.async {
            guard context.coordinator.recognizer == nil, let window = uiView.window else { return }
            let recognizer = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap))
            recognizer.cancelsTouchesInView = false
            recognizer.delegate = context.coordinator
            window.addGestureRecognizer(recognizer)
            context.coordinator.recognizer = recognizer
        }
    }

    static func dismantleUIView(_ uiView: UIView, coordinator: Coordinator) {
        if let recognizer = coordinator.recognizer {
            recognizer.view?.removeGestureRecognizer(recognizer)
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator() }

    final class Coordinator: NSObject, UIGestureRecognizerDelegate {
        var recognizer: UITapGestureRecognizer?

        @objc func handleTap(_ recognizer: UITapGestureRecognizer) {
            recognizer.view?.endEditing(true)
        }

        /// 入力欄そのもののタップでは閉じない（別の入力欄への移動を邪魔しない）
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
            var view = touch.view
            while let current = view {
                if current is UITextField || current is UITextView { return false }
                view = current.superview
            }
            return true
        }

        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                               shouldRecognizeSimultaneouslyWith other: UIGestureRecognizer) -> Bool {
            true
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
