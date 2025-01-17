import Foundation

struct LevelModel: Identifiable, Codable {
    var id: UUID = UUID()
    let column: Int
    let title: String
    let lives: Int
    var isCanPlay: Bool
    var isShaking: Bool
    
    init(column: Int, title: String, lives: Int, isOpen: Bool = false, isShaking: Bool = false) {
        self.column = column
        self.title = title
        self.lives = lives
        self.isCanPlay = isOpen
        self.isShaking = isShaking
    }
    
}
