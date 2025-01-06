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

struct GameView: View {
    
    @EnvironmentObject var viewModel: GameViewModel
    
    @State var columns: [GridItem] = []
    
    var body: some View {
        ZStack {
            Color.gray.opacity(0.1).ignoresSafeArea()
            
            VStack {
                if let levelModel = viewModel.levelModel {
                    Text("Level: " + levelModel.title)
                        .font(.system(size: 19, weight: .semibold))
                        .foregroundStyle(.black)
                }
                
                LazyVGrid(columns: columns, spacing: 1) {
                    ForEach(viewModel.dataSource) { model in
                        Rectangle()
                            .fill(model.isTapped ? model.color : .gray)
                            .frame(width: 50, height: 50)
                            .onTapGesture {
                                viewModel.tileDidTap(model)
                            }
                    }
                }
                
                RestartView()
                
            }
         
        }
        .onAppear() {
            if let levelModel = viewModel.levelModel {
                columns = Array(repeating: GridItem(.fixed(50), spacing: 1), count: levelModel.column)
            }
            
            viewModel.onAppear()
        }
    }
    
}

private struct RestartView: View {
    
    @EnvironmentObject var viewModel: GameViewModel
    
    @State private var isTapped = false
    
    var body: some View {
        let isEmpty = viewModel.dataSource.filter { $0.isTapped }.isEmpty
        
        Button(action: {
            if !isEmpty {
                viewModel.onAppear()
                
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
        .opacity(isEmpty ? 0.6 : 1)
    }
    
}

#Preview {
    GameView()
        .environmentObject(GameViewModel())
}
