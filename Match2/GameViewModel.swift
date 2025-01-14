import Foundation

enum GameResultType: Int, Identifiable {
    case win
    case lose

    var id: String {
       return "\(rawValue)"
    }
}

final class GameViewModel: ObservableObject {
    
    @Published var dataSource: [TileModel] = []
    
    @Published var isGame = false
    
    @Published var levelsDataSource: [LevelModel] = []
    
    @Published var levelModel: LevelModel? = nil
    @Published var lives = 0
    @Published var time = 0
    
    @Published var gameSheet: GameResultType? = nil
    @Published var gameId = UUID()
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    func decode(_ json: String) -> [LevelModel] {
        do {
            let jsonData = Data(json.utf8)
            
            let savedLevels = try JSONDecoder().decode([LevelModel].self, from: jsonData)
            
            return savedLevels
            
        } catch {
            print("Failed to decode JSON: \(error.localizedDescription)")
            
            return []
        }
    }
    
    func encode(_ list: [LevelModel]) -> String? {
        do {
            let jsonData = try JSONEncoder().encode(list)
            let jsonString = String(data: jsonData, encoding: .utf8)
            
            return jsonString
            
        } catch {
            print("Error encoding JSON: \(error.localizedDescription)")
            
            return nil
        }
    }
    
    func getAllLevels() {
        let allLevels = UserDefaultsWrapper.shared.getString()
        
        if let allLevels = allLevels {
            levelsDataSource = decode(allLevels)
            levelsDataSource[0].isCanPlay = true
        } else {
            let levelsToSave: [LevelModel] = [
                LevelModel(column: 2, title: "Beginner", lives: 1),
                LevelModel(column: 4, title: "Intermediate", lives: 4),
                LevelModel(column: 6, title: "Skilled", lives: 8),
                LevelModel(column: 8, title: "Advanced", lives: 16),
                LevelModel(column: 10, title: "Master", lives: 20),
            ]
            
            if let jsonString = encode(levelsToSave) {
                UserDefaultsWrapper.shared.set(jsonString)
                
                levelsDataSource = levelsToSave
                levelsDataSource[0].isCanPlay = true
            }
        }
    }
    
    func save() {
        if let levelModel {
            let levelIndex = currentLevelIndex(levelModel)
            
            guard !isLastLevel(levelIndex) else { return }
            levelsDataSource[levelIndex+1].isCanPlay = true
            
            guard let jsonString = encode(levelsDataSource) else {return}
            UserDefaultsWrapper.shared.set(jsonString)
             
        }
    }
    
    func levelDidTap(model: LevelModel, index: Int) {
        if model.isCanPlay {
            levelModel = model
            isGame = true
        } else {
            levelsDataSource[index].isShaking = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.levelsDataSource[index].isShaking = false
            }
        }
    }
    
    func currentLevelIndex(_ model: LevelModel) -> Int {
        levelsDataSource.enumerated().filter { $0.element.id == model.id }.first?.offset ?? levelsDataSource.count-1
    }
 
    func isLastLevel(_ index: Int) -> Bool {
        index+1 >= levelsDataSource.count
    }
    
    func nextLevel() {
        if let levelModel {
            let levelIndex = currentLevelIndex(levelModel)
            
            self.levelModel = isLastLevel(levelIndex) ? levelsDataSource[0] : levelsDataSource[levelIndex+1]
            
            gameId = UUID()
        }
    }
    
    func prepareForGame() {
        if let levelModel {
            time = 0
            lives = levelModel.lives
            gameSheet = nil
            
            let half = (levelModel.column*levelModel.column)/2
            dataSource = DataSource.shared.getRandom(half)
        }
    }
    
    func updateTime() {
        guard gameSheet == nil else { return }

        time += 1
    }
    
    func tileDidTap(_ model: TileModel) {
        guard !model.isMatched,
              lives > 0
        else { return }
        
        let tappedTilesCount = dataSource.filter { $0.isTapped && !$0.isMatched }.count
        
        if let index = dataSource.firstIndex(where: { $0.id == model.id }) {
            dataSource[index].isTapped.toggle()
        }
        
        if tappedTilesCount != 0 {
            let tappedTiles = dataSource.filter { $0.isTapped && !$0.isMatched }
            
            if tappedTiles[0].number == tappedTiles[1].number {
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
                
                lives -= 1
            }
        }
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { _ in
            let matchesTiles = self.dataSource.filter { $0.isMatched }
            
            if matchesTiles.count == self.dataSource.count {
                print("win")
                SoundManager.play(.win)
                self.gameSheet = .win
                self.save()
            } else if self.lives == 0 {
                print("lose")
                SoundManager.play(.lose)
                self.gameSheet = .lose
            }
        }
        
    }
    
}
