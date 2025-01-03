import SwiftUI

// Game Rules:
// if we tapped on two same colors we should match this colors, else we should set desault state
// main task is found all matches

// Blueprint:
// Create ViewModel
// Code update
// Create restart button

struct GameView: View {
    
    @StateObject private var viewModel = GameViewModel()
    
    let columns: [GridItem] = [
        GridItem(.fixed(50), spacing: 1),
        GridItem(.fixed(50), spacing: 1),
        GridItem(.fixed(50), spacing: 1),
        GridItem(.fixed(50), spacing: 1),
    ]
    
    var body: some View {
        VStack {
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
                .environmentObject(viewModel)
            
        }
        .onAppear() {
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
                viewModel.restart()
                
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
}
