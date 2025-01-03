import Foundation

final class GameViewModel: ObservableObject {
    
    @Published var dataSource: [TileModel] = []
    
    func onAppear() {
        dataSource = DataSource.shared.getRandom()
    }
    
    func restart() {
        dataSource = DataSource.shared.getRandom()
    }
    
    func tileDidTap(_ model: TileModel) {
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
                        self.dataSource[index].isTapped = false
                    }
                }
                
                if let index = dataSource.firstIndex(where: { $0.id == tappedTiles[1].id }) {
                    Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { _ in
                        self.dataSource[index].isTapped = false
                    }
                }
            }
        }
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { _ in
            let matchesTiles = self.dataSource.filter { $0.isMatched }
            
            if matchesTiles.count == self.dataSource.count {
                print("win")
            }
        }
        
    }
    
}
