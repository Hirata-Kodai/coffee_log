import SwiftData
import SwiftUI

@main
struct CoffeeLogApp: App {
    let container: ModelContainer

    init() {
        do {
            #if DEBUG
            // 起動引数 -sampleData でサンプル入りのメモリ上のコンテナを使う（端末の保存データには触れない）
            if CommandLine.arguments.contains("-sampleData") {
                container = try SampleRecords.makeSharedContext()
                return
            }
            #endif
            container = try .coffeeLog()
        } catch {
            // 保存先を開けないと何も記録できないので、起動を止めて原因を残す
            fatalError("ModelContainer を作れませんでした: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            RecordListScreen()
        }
        .modelContainer(container)
    }
}
