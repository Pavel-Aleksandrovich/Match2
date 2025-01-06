import SwiftUI

struct ListLevelsView: View {
    
    @StateObject private var viewModel = GameViewModel()
    
    @State var isGame = false
    
    @State var dataSource: [LevelModel] = [
        LevelModel(column: 2, title: "Beginner"),
        LevelModel(column: 4, title: "Intermediate"),
        LevelModel(column: 6, title: "Skilled"),
        LevelModel(column: 8, title: "Advanced"),
        LevelModel(column: 10, title: "Master"),
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 8) {
                    ForEach(dataSource.indices, id: \.self) { index in
                        let model = dataSource[index]
                        
                        ListLevelsItemView(index: index, title: model.title)
                            .onTapGesture {
                                viewModel.levelModel = model
                                isGame = true
                            }
                    }
                }
                .padding(.horizontal, 16)
            }
            .navigationDestination(isPresented: $isGame) {
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
