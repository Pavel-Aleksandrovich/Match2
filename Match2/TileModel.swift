import SwiftUI

struct TileModel: Identifiable {
    let id: UUID = UUID()
    let color: Color
    var isTapped: Bool = false
    var isMatched: Bool = false
}
