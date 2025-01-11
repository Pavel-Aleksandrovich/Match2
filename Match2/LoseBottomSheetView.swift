import SwiftUI

struct LoseBottomSheetView: View {
    
    @EnvironmentObject var viewModel: GameViewModel
    
    var body: some View {
        VStack(spacing: 24) {
            Text("You lose!")
                .font(.system(size: 23, weight: .bold))
                .foregroundStyle(.black)

            Button("Restart") {
                SoundManager.play(.click)
                viewModel.prepareForGame()
            }
            .buttonStyle(.borderedProminent)
        }
    }
}
