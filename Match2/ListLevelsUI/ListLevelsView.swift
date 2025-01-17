import SwiftUI


struct ListLevelsView: View {
    
    @StateObject private var viewModel = GameViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 8) {
                    ForEach(viewModel.levelsDataSource.indices, id: \.self) { index in
                        let model = viewModel.levelsDataSource[index]
                        
                        ListLevelsItemView(index: index, title: model.title, isCanPlay: model.isCanPlay, isShaking: model.isShaking)
                            .onTapGesture {
                                SoundManager.play(.click)
                                viewModel.levelDidTap(model: model, index: index)
                            }
                    }
                }
                .padding(.horizontal, 16)
            }
            .navigationDestination(isPresented: $viewModel.isGame) {
                GameView()
                    .environmentObject(viewModel)
            }
            .onAppear() {
                viewModel.getAllLevels()
            }
        }
    }
    

    
}

private struct ListLevelsItemView: View {
    
    let index: Int
    let title: String
    let isCanPlay: Bool
    let isShaking: Bool
    
    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(.blue)
            .frame(height: 140)
            .overlay {
                HStack {
                    Text("#\(index+1). " + title.uppercased())
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(.white)
                    
                    if !isCanPlay {
                        Image(systemName: "lock.fill")
                            .resizable()
                            .renderingMode(.template)
                            .aspectRatio(contentMode: .fit)
                            .foregroundStyle(.gray)
                            .frame(width: 24)
                            .offset(x: isShaking ? -12 : 0)
                            .animation(.easeInOut(duration: 0.1).repeatCount(3, autoreverses: true),
                                       value: isShaking)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
            }
    }
}


#Preview {
    ListLevelsView()
}
