import SwiftUI

struct ContentView: View {
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false

    @StateObject private var viewModel = LobbyViewModel()
    
    var body: some View {
        Group {
            if isLoggedIn {
                NavigationStack(path: $viewModel.path) {
                    WelcomeView(viewModel: viewModel)
                        .navigationDestination(for: AppScreen.self) { screen in
                            switch screen {
                            case .hostSetup:
                                LobbySetupView(viewModel: viewModel)
                            case .joinSetup:
                                JoinSetupView(viewModel: viewModel)
                            case .lobby:
                                WalletDeckView(viewModel: viewModel)
                            case .loading:
                                LoadingScreen()
                            case .results:
                                RevealPodiumView(viewModel: viewModel)
                            }
                        }
                }
            } else {
                NavigationStack(path: $viewModel.path) {
                    OnboardingView()
                }
            }
        }
    }
}
