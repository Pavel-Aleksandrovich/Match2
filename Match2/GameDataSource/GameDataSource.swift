import SwiftUI

final class GameDataSource {
    
    static let shared = GameDataSource()
    
    private init() { }
    
    func getRandom(_ count: Int) -> [TileModel] {
        let listOfNumbers: [Int] = Array(0...100).shuffled()
        
        let resultWithPrefix = listOfNumbers.prefix(count)
        
        var tileColors = resultWithPrefix + resultWithPrefix
        tileColors.shuffle()
        
        return tileColors.map { TileModel(number: $0) }
    }
    
}
