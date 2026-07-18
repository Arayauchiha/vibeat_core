import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = LobbyViewModel()
    
    var body: some View {
        Group {
            switch viewModel.appState {
            case .welcome:
                WelcomeView(viewModel: viewModel)
                    .transition(.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .trailing)))
            case .hostSetup:
                LobbySetupView(viewModel: viewModel)
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            case .lobby:
                WalletDeckView(viewModel: viewModel)
                    .transition(.opacity)
            case .loading:
                LoadingScreen()
                    .transition(.opacity)
            case .results:
                RevealPodiumView(viewModel: viewModel)
                    .transition(.move(edge: .bottom))
            }
        }
        .animation(.spring(response: 0.45, dampingFraction: 0.8), value: viewModel.appState)
    }
}

#Preview {
    ContentView()
}
