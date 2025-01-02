import SwiftUI

// Rules:
// if we tapped on two same colors we should match this colors, else we should set desault state
// main task is found all matches

struct GameView: View {
    
    struct TileModel: Identifiable {
        let id: UUID = UUID()
        let color: Color
        var isTapped: Bool = false
        var isMatched: Bool = false
    }
    
    @State var dataSource: [TileModel] = []
    
    let columns: [GridItem] = [
        GridItem(.fixed(50), spacing: 1),
        GridItem(.fixed(50), spacing: 1),
        GridItem(.fixed(50), spacing: 1),
        GridItem(.fixed(50), spacing: 1),
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 1) {
             ForEach(dataSource) { model in
                 Rectangle()
                     .fill(model.isTapped ? model.color : .gray)
                     .frame(width: 50, height: 50)
                     .onTapGesture {
                         guard !model.isMatched else { return }
                         
                         let tappedTilesCount = dataSource.filter { $0.isTapped && !$0.isMatched }.count
                         
                         if let index = dataSource.firstIndex(where: { $0.id == model.id }) {
                             dataSource[index].isTapped.toggle()
                         }
                         
                         if tappedTilesCount != 0 {
                             let tappedTiles = dataSource.filter { $0.isTapped && !$0.isMatched }
                             
                             if tappedTiles[0].color == tappedTiles[1].color {
                                 if let index = dataSource.firstIndex(where: { $0.id == tappedTiles[0].id }) {
                                     dataSource[index].isMatched = true
                                 }
                                 
                                 if let index = dataSource.firstIndex(where: { $0.id == tappedTiles[1].id }) {
                                     dataSource[index].isMatched = true
                                 }
                             } else {
                                 if let index = dataSource.firstIndex(where: { $0.id == tappedTiles[0].id }) {
                                     Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { _ in
                                         dataSource[index].isTapped = false
                                     }
                                 }
                                 
                                 if let index = dataSource.firstIndex(where: { $0.id == tappedTiles[1].id }) {
                                     Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { _ in
                                         dataSource[index].isTapped = false
                                     }
                                 }
                             }
                         }
                         
                         Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { _ in
                             let matchesTiles = dataSource.filter { $0.isMatched }
                             
                             if matchesTiles.count == 16 {
                                 print("win")
                             }
                         }
                     }
             }
         }
        .onAppear() {
            dataSource = createDataSource()
        }
    }
    
    func createDataSource() -> [TileModel] {
        let uniqueColors: [Color] = [.red, .blue, .green, .yellow, .orange, .purple, .pink, .brown]
        
        var tileColors = uniqueColors + uniqueColors
        tileColors.shuffle()
        
        return tileColors.map { TileModel(color: $0) }
    }
    
}

#Preview {
    GameView()
}
