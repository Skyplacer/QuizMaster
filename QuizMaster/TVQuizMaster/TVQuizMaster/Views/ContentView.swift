import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: QuizViewModel
    
    var body: some View {
        Group {
            switch viewModel.gameState {
            case .menu:
                HomeView()
            case .playing:
                QuizView()
            case .result:
                ResultsView()
            }
        }
        .animation(.spring(), value: viewModel.gameState)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(QuizViewModel())
    }
}
