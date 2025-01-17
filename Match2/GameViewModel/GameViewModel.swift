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
    
    private var tappedTiles: [TileModel] = []
    private var isCanPlay = true
    
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
    
    func setInitialState() {
        if let levelModel {
            time = 0
            lives = levelModel.lives
            gameSheet = nil
            
            let half = (levelModel.column*levelModel.column)/2
            dataSource = GameDataSource.shared.getRandom(half)
            
            tappedTiles.removeAll()
            isCanPlay = false
            
            dataSource = dataSource.map({ TileModel(number: $0.number, isMatched: true) })
            
            Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { [ weak self ] _ in
                guard let self else { return }

                for i in 0..<self.dataSource.count {
                    dataSource[i].scale = 0.01
                }
            }
            
            Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { [ weak self ] _ in
                guard let self else { return }
                self.isCanPlay = true
                for i in 0..<self.dataSource.count {
                    dataSource[i].scale = 1
                    dataSource[i].isMatched = false
                }
            }
        }
    }
    
    func updateTime() {
        guard gameSheet == nil else { return }

        time += 1
    }
    
    func tileDidTap(_ model: TileModel) {
        guard !model.isMatched, lives > 0, isCanPlay else { return }
        
        func setTappedState(_ model: TileModel) {
            tappedTiles.append(model)
            if let index = dataSource.firstIndex(where: { $0.id == model.id }) {
                dataSource[index].isTapped = true
                dataSource[index].scale = 0.9
            }
        }
        
        func setMatchedState(_ model: TileModel) {
            if let index = dataSource.firstIndex(where: { $0.id == model.id }) {
                dataSource[index].isMatched = true
                Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [ weak self ] _ in
                    self?.dataSource[index].scale = 1.05
                }
                
                Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { [ weak self ] _ in
                    self?.dataSource[index].scale = 1
                }
            }
        }
        
        func setInititalState(_ model: TileModel, withTimeInterval: CGFloat) {
            if let index = dataSource.firstIndex(where: { $0.id == model.id }) {
                dataSource[index].isTapped = false
                Timer.scheduledTimer(withTimeInterval: withTimeInterval, repeats: false) { [ weak self ] _ in
                    self?.dataSource[index].scale = 1
                }
            }
        }
        
        if tappedTiles.isEmpty {
            setTappedState(model)
        } else if tappedTiles.count == 1 {
            if tappedTiles[0].id == model.id {
                setInititalState(model, withTimeInterval: 0)
            } else {
                setTappedState(model)
                
                if tappedTiles[0].number == tappedTiles[1].number {
                    // Matched
                    setMatchedState(tappedTiles[0])
                    setMatchedState(tappedTiles[1])
                } else {
                    // Not matched
                    setInititalState(tappedTiles[0], withTimeInterval: 0.2)
                    setInititalState(tappedTiles[1], withTimeInterval: 0.5)
                    
                    lives -= 1
                }
                
                var gameSheet: GameResultType? = nil
                
                let matchesTiles = self.dataSource.filter { $0.isMatched }

                if matchesTiles.count == self.dataSource.count {
                    print("win")
                    gameSheet = .win
                    isCanPlay = false
                    self.save()
                } else if self.lives == 0 {
                    print("lose")
                    gameSheet = .lose
                    isCanPlay = false
                }
                
                Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { [ weak self ] _ in
                    guard let self else { return }
                    
                    if gameSheet == .win {
                        SoundManager.play(.win)
                        self.gameSheet = gameSheet
                    } else if gameSheet == .lose {
                        SoundManager.play(.lose)
                        self.gameSheet = gameSheet
                    }
                }
            }
            
            tappedTiles.removeAll()
        }
    }
    
}
