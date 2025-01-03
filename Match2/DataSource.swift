import SwiftUI

final class DataSource {
    
    static let shared = DataSource()
    
    private init() { }
    
    func getRandom() -> [TileModel] {
        let uniqueColors: [Color] = [.red, .blue, .green, .yellow, .orange, .purple, .pink, .brown]
        
        var tileColors = uniqueColors + uniqueColors
        tileColors.shuffle()
        
        return tileColors.map { TileModel(color: $0) }
    }
    
}
