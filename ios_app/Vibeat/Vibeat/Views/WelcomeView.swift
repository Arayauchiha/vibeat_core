import SwiftUI

struct WelcomeView: View {
    @ObservedObject var viewModel: LobbyViewModel
    @State private var showingCodeInput = false
    @State private var lobbyCode = ""
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Text("Vibeat")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            // Host Button (Native style)
            Button(action: {
                Task {
                    await viewModel.clearLobby() // Clear any stale backend states
                    withAnimation {
                        viewModel.path.append(.hostSetup)
                    }
                }
            }) {
                Text("Host a Lobby")
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            .buttonStyle(.borderedProminent)
            .tint(.blue)
            
            // Join Button (Native style)
            Button(action: {
                withAnimation {
                    showingCodeInput.toggle()
                }
            }) {
                Text("Join a Lobby")
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            .buttonStyle(.bordered)
            
            // Inline native input for 6-digit code
            if showingCodeInput {
                VStack(spacing: 12) {
                    TextField("Enter 6-digit code", text: $lobbyCode)
                        .textFieldStyle(.roundedBorder)
                        .multilineTextAlignment(.center)
                        .autocorrectionDisabled()
                        .onChange(of: lobbyCode) { oldValue, newValue in
                            let filtered = newValue.uppercased().filter { $0.isLetter || $0.isNumber }
                            lobbyCode = String(filtered.prefix(6))
                        }
                    
                    Button("Enter Dining Table") {
                        withAnimation {
                            viewModel.path.append(.lobby)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                    .disabled(lobbyCode.count != 6)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .transition(.opacity)
            }
            
            Spacer()
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

#Preview {
    WelcomeView(viewModel: LobbyViewModel())
}
