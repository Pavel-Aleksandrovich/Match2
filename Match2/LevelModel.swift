import SwiftUI

struct LevelModel: Identifiable {
    let id: UUID = UUID()
    let column: Int
    let title: String
    let lives: Int
    
    init(column: Int, title: String, lives: Int) {
        self.column = column
        self.title = title
        self.lives = lives
    }
    
}
