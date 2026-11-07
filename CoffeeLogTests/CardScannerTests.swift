import Testing
import UIKit
@testable import CoffeeLog

// TODO（Gemini で読み、だめなら端末内の読み取りに切り替える）
// - [x] Gemini が使えれば、その結果を使う
// - [x] Gemini が失敗したら端末内の読み取りに切り替え、切り替えたことを返す
// - [x] Gemini が使えない（API キーがない）なら、端末内の読み取りだけを使う
struct CardScannerTests {
    private struct Failure: Error {}

    private let image = UIImage()
    private let geminiFields = CardFields(farm: "エルインヘルト農園")
    private let onDeviceFields = CardFields(farm: "El Injerto")

    @Test func Geminiが使えればその結果を使う() async throws {
        let scanner = CardScanner(
            gemini: { _ in geminiFields },
            onDevice: { _ in onDeviceFields }
        )

        let result = try await scanner.read(image)

        #expect(result == CardScanResult(fields: geminiFields, source: .gemini))
    }

    @Test func Geminiが失敗したら端末内の読み取りに切り替え切り替えたことを返す() async throws {
        let scanner = CardScanner(
            gemini: { _ in throw Failure() },
            onDevice: { _ in onDeviceFields }
        )

        let result = try await scanner.read(image)

        #expect(result == CardScanResult(fields: onDeviceFields, source: .onDeviceFallback))
    }

    @Test func Geminiが使えなければ端末内の読み取りだけを使う() async throws {
        let scanner = CardScanner(gemini: nil, onDevice: { _ in onDeviceFields })

        let result = try await scanner.read(image)

        #expect(result == CardScanResult(fields: onDeviceFields, source: .onDevice))
    }
}
