import SwiftUI

struct LevelModel: Identifiable {
    let id: UUID = UUID()
    let column: Int
    let title: String
    
    init(column: Int, title: String) {
        self.column = column
        self.title = title
    }
    
}
