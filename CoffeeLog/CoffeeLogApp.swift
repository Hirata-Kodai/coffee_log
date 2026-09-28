import SwiftData
import SwiftUI

@main
struct CoffeeLogApp: App {
    let container: ModelContainer

    init() {
        do {
            container = try .coffeeLog()
        } catch {
            // 保存先を開けないと何も記録できないので、起動を止めて原因を残す
            fatalError("ModelContainer を作れませんでした: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
    }
}
