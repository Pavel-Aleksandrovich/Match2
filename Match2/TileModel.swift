import SwiftUI

struct TileModel: Identifiable, Equatable {
    let id: UUID = UUID()
    let number: Int
    var isTapped: Bool = false
    var isMatched: Bool = false
    var scale: CGFloat = 1
}
