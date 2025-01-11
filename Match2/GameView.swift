import SwiftUI

// Game Rules:
// if we tapped on two same colors we should match this colors, else we should set desault state
// main task is found all matches

// Lesson 1 blueprint:
// Create game field
// Win conditions

// Lesson 2 blueprint:
// Create ViewModel
// Code update
// Create restart button

// Lesson 3 blueprint:
// Building new screen: List levels
// Move from first screen to second and back
// Passed data between to screens using ViewModel

// Lesson 4 blueprint:
// Update size of tile
// Update data source
// Create lives
// Create Timer
// Update code

// Lesson 5 blueprint
// Move timer from View to ViewModel
// Update restart button logic
// Create Win and Lose screens
// Move to next level logic
// Sound

struct GameView: View {
    
    @EnvironmentObject var viewModel: GameViewModel
    
    @State var columns: [GridItem] = []
    @State var tileWidth: CGFloat = 0
    
    var body: some View {
        ZStack {
            Color.gray.opacity(0.1).ignoresSafeArea()
            
            VStack {
                
                Text(TimeConverter.formatTime(viewModel.time))
                    .font(.system(size: 19, weight: .semibold))
                    .foregroundStyle(.black)
                
                HStack {
                    Text("\(viewModel.lives)/\(viewModel.levelModel?.lives ?? 0)")
                        .font(.system(size: 19, weight: .semibold))
                        .foregroundStyle(.black)
                    
                    Image(systemName: "heart.fill")
                        .resizable()
                        .renderingMode(.template)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30)
                        .foregroundColor(.red)
                }
                
                if let levelModel = viewModel.levelModel {
                    Text("Level: " + levelModel.title)
                        .font(.system(size: 19, weight: .semibold))
                        .foregroundStyle(.black)
                }
                
                LazyVGrid(columns: columns, spacing: 1) {
                    ForEach(viewModel.dataSource) { model in
                        RoundedRectangle(cornerRadius: 4)
                            .fill(model.isTapped ? .blue : .gray)
                            .frame(width: tileWidth, height: tileWidth)
                            .overlay {
                                Text("\(model.number)")
                                    .font(.system(size: 17, weight: .medium))
                                    .foregroundColor(.white)
                                    .opacity(model.isTapped ? 1 : 0)
                            }
                            .onTapGesture {
                                SoundManager.play(.click)
                                viewModel.tileDidTap(model)
                            }
                    }
                }
                
                RestartView()
                
            }
         
        }
        .onReceive(viewModel.timer) { _ in
            viewModel.updateTime()
        }
        .sheet(item: $viewModel.gameSheet, content: { screen in
            switch screen {
            case .win:
                WinBottomSheetView()
                    .environmentObject(viewModel)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.hidden)
            case .lose:
                LoseBottomSheetView()
                    .environmentObject(viewModel)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.hidden)
            }
        })
        .onAppear() {
            if let levelModel = viewModel.levelModel {
                let column = CGFloat(levelModel.column)
                let screenWidth = UIScreen.main.bounds.width
                let leftPadding: CGFloat = 16
                tileWidth = (screenWidth-leftPadding*2-(column-1))/column
                
                columns = Array(repeating: GridItem(.fixed(tileWidth), spacing: 1), count: levelModel.column)
            }
            
            viewModel.prepareForGame()
        }
        .id(viewModel.gameId)
    }
    
}

private struct RestartView: View {
    
    @EnvironmentObject var viewModel: GameViewModel
    
    @State private var isTapped = false
    
    var body: some View {
        let isCanRestart = viewModel.time > 0
        
        Button(action: {
            if isCanRestart {
                SoundManager.play(.click)
                
                viewModel.prepareForGame()
                
                isTapped.toggle()
                
                Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { _ in
                    isTapped.toggle()
                }
            }
        }, label: {
            HStack(spacing: 16) {
                Text("Restart")
                    .foregroundColor(.white)
                
                Image(systemName: isTapped ? "checkmark" : "arrow.clockwise")
                    .renderingMode(.template)
                    .foregroundColor(.white)
            }
        })
        .frame(height: 44)
        .frame(maxWidth: .infinity)
        .background(Color.blue)
        .cornerRadius(8)
        .padding(.horizontal)
        .opacity(isCanRestart ? 1 : 0.6)
    }
    
}

#Preview {
    GameView()
        .environmentObject(GameViewModel())
}
