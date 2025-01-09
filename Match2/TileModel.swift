import SwiftUI

struct TileModel: Identifiable {
    let id: UUID = UUID()
    let number: Int
    var isTapped: Bool = false
    var isMatched: Bool = false
}
