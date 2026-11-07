import CoreGraphics

/// 文字認識で見つかった文字のかたまり。box は画像に対する割合で、Vision と同じく左下が原点
struct RecognizedText: Equatable {
    let text: String
    let box: CGRect
}
