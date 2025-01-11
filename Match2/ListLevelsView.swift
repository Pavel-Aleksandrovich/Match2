import SwiftUI


struct ListLevelsView: View {
    
    @StateObject private var viewModel = GameViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 8) {
                    ForEach(viewModel.levelsDataSource.indices, id: \.self) { index in
                        let model = viewModel.levelsDataSource[index]
                        
                        ListLevelsItemView(index: index, title: model.title)
                            .onTapGesture {
                                SoundManager.play(.click)
                                viewModel.levelDidTap(model)
                            }
                    }
                }
                .padding(.horizontal, 16)
            }
            .navigationDestination(isPresented: $viewModel.isGame) {
                GameView()
                    .environmentObject(viewModel)
            }
        }
    }
    

    
}

private struct ListLevelsItemView: View {
    
    let index: Int
    let title: String
    
    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(.blue)
            .frame(height: 140)
            .overlay {
                HStack {
                    Text("#\(index+1). " + title.uppercased())
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(.white)
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
            }
    }
}


#Preview {
    ListLevelsView()
}
