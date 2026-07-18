import SwiftUI

struct WelcomeView: View {
    @ObservedObject var viewModel: LobbyViewModel
    @State private var showingJoinSheet = false
    @State private var lobbyCode = ""
    
    var body: some View {
        ZStack {
            // Tabletop Linen Backdrop
            Image("texture_linen_table")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 40) {
                Spacer()
                
                // App Branding & Title
                VStack(spacing: 8) {
                    Text("Vibeat")
                        .font(.editorialHeader(size: 42))
                        .foregroundColor(.inkPaper)
                        .tracking(3)
                    
                    Text("DINE TOGETHER • COORDINATED PERFECTLY")
                        .font(.uiLabel(size: 11, weight: .bold))
                        .foregroundColor(.terracottaOrange)
                        .tracking(1.5)
                }
                
                // Welcome Mascot (Clochey Welcome)
                Image("clochey_welcome")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 220)
                    .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 8)
                
                Spacer()
                
                // CTA Action Buttons
                VStack(spacing: 16) {
                    // Create Lobby (Host)
                    Button(action: {
                        Task {
                            await viewModel.clearLobby() // Wipe any stale sessions
                            withAnimation(.spring()) {
                                viewModel.appState = .hostSetup
                            }
                        }
                    }) {
                        Text("Create a Dining Lobby")
                            .font(.uiLabel(size: 16, weight: .bold))
                            .foregroundColor(.carbonInk)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.inkPaper)
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 3)
                    }
                    
                    // Join Lobby (Guest)
                    Button(action: {
                        showingJoinSheet = true
                    }) {
                        Text("Join an Active Lobby")
                            .font(.uiLabel(size: 16, weight: .bold))
                            .foregroundColor(.inkPaper)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.clear)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.inkPaper.opacity(0.5), lineWidth: 1.5)
                            )
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 40)
            }
        }
        .sheet(isPresented: $showingJoinSheet) {
            ZStack {
                Color.tabletop.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 24) {
                    Text("Enter Invite Code")
                        .font(.editorialHeader(size: 24))
                        .foregroundColor(.inkPaper)
                    
                    TextField("Lobby Code (e.g. VIBE-123)", text: $lobbyCode)
                        .font(.uiLabel(size: 16, weight: .medium))
                        .foregroundColor(.carbonInk)
                        .padding()
                        .background(Color.inkPaper)
                        .cornerRadius(8)
                        .multilineTextAlignment(.center)
                        .autocorrectionDisabled()
                        .autocapitalization(.allCharacters)
                    
                    Button(action: {
                        showingJoinSheet = false
                        withAnimation(.spring()) {
                            viewModel.appState = .lobby
                        }
                    }) {
                        Text("Enter Dining Table")
                            .font(.uiLabel(size: 16, weight: .bold))
                            .foregroundColor(.inkPaper)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.terracottaOrange)
                            .cornerRadius(8)
                    }
                    .disabled(lobbyCode.isEmpty)
                    .opacity(lobbyCode.isEmpty ? 0.6 : 1.0)
                }
                .padding(30)
            }
            .presentationDetents([.fraction(0.35)])
        }
    }
}

#Preview {
    WelcomeView(viewModel: LobbyViewModel())
}
