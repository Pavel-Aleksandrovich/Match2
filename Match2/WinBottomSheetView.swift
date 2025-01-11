import SwiftUI

struct WinBottomSheetView: View {
    
    @EnvironmentObject var viewModel: GameViewModel
    
    var body: some View {
        VStack(spacing: 24) {
            Text("You win!")
                .font(.system(size: 23, weight: .bold))
                .foregroundStyle(.black)

            Button("next level") {
                SoundManager.play(.click)
                viewModel.nextLevel()
            }
            .buttonStyle(.borderedProminent)
        }
    }
}
