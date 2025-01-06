import SwiftUI

final class DataSource {
    
    static let shared = DataSource()
    
    private init() { }
    
    func getRandom(_ count: Int) -> [TileModel] {
        let uniqueColors: [Color] = [.red, .blue, .green, .yellow, .orange, .purple, .pink, .brown].shuffled()
        
        let resultWithPrefix = uniqueColors.prefix(count)
        
        var tileColors = resultWithPrefix + resultWithPrefix
        tileColors.shuffle()
        
        return tileColors.map { TileModel(color: $0) }
    }
    
}
