import SwiftUI

struct WelcomeView: View {
    @ObservedObject var viewModel: LobbyViewModel
    @State private var showingJoinSheet = false
    
    var body: some View {
        ZStack {
            // Elegant paper background
            Color.inkPaper
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 24) {
                Spacer()
                
                // Title Header (More prominent & heavier logo typography)
                VStack(spacing: 6) {
                    Text("VIBEAT")
                        .font(.custom("Georgia-Bold", size: 48))
                        .foregroundColor(.carbonInk)
                        .tracking(4)

                    Text("DINING WITH FRIENDS")
                        .font(.uiLabel(size: 11, weight: .black))
                        .foregroundColor(.terracottaOrange)
                        .tracking(2.5)

                }
                .padding(.top, 30)
                
                Spacer()
                
                // Mascot Card (Ornate detailed woodcut board illustration - Heavier focus)
                VStack(spacing: 20) {
                    Image("welcome_mascot_card")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 250)
                        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
                    
                    // Mascot Speech Bubble
                    VStack(spacing: 6) {
                        Text("CLOCHEY")
                            .font(.uiLabel(size: 11, weight: .black))
                            .foregroundColor(.terracottaOrange)
                            .tracking(1.5)
                        
                        Text("Bonjour! Ready to discover the perfect dining spot with your friends today?")
                            .font(.editorialSubheader(size: 14))
                            .foregroundColor(.carbonInk)
                            .multilineTextAlignment(.center)
                            .lineSpacing(2)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 20)
                    .background(Color.white.opacity(0.85))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.terracottaOrange.opacity(0.25), lineWidth: 1)
                    )
                }
                .padding(.horizontal, 28)
                
                Spacer()
                
                // Button Actions (Using custom high-fidelity letterpress assets, narrowed for light weight)
                VStack(spacing: 12) {
                    // Host Button
                    Button(action: {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        viewModel.resetLobbyState()
                        viewModel.isHost = true
                        withAnimation(.spring()) {
                            viewModel.path.append(.hostSetup)
                        }
                    }) {
                        Image("btn_host_table")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity)
                            .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 2)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // Join Button
                    Button(action: {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        showingJoinSheet = true
                    }) {
                        Image("btn_join_table")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity)
                            .shadow(color: Color.black.opacity(0.02), radius: 3, x: 0, y: 2)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal, 54)
                .padding(.bottom, 40)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showingJoinSheet) {
            JoinLobbySheetView(viewModel: viewModel, isPresented: $showingJoinSheet)
                .presentationDetents([.fraction(0.45)])
                .presentationDragIndicator(.visible)
        }
    }
}

// MARK: - JoinLobbySheetView
struct JoinLobbySheetView: View {
    @ObservedObject var viewModel: LobbyViewModel
    @Binding var isPresented: Bool
    @State private var lobbyCode = ""
    @FocusState private var isCodeFocused: Bool
    
    var body: some View {
        ZStack {
            // Sheet background color matching paper texture
            Color.inkPaper
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                // Drag handle spacing / Header
                VStack(spacing: 4) {
                    Text("ENTER TABLE CODE")
                        .font(.uiLabel(size: 12, weight: .black))
                        .foregroundColor(.terracottaOrange)
                        .tracking(1.5)
                        .padding(.top, 14)
                    
                    Text("Enter the 6-digit invite code to join the dining table.")
                        .font(.editorialSubheader(size: 13))
                        .foregroundColor(.carbonInk.opacity(0.6))
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 24)
                
                // Code Input Field
                VStack(spacing: 8) {
                    ZStack {
                        if lobbyCode.isEmpty {
                            Text("000000")
                                .font(.custom("Georgia-Bold", size: 28))
                                .foregroundColor(.carbonInk.opacity(0.15))
                                .tracking(6)
                        }
                        
                        TextField("", text: $lobbyCode)
                            .font(.custom("Georgia-Bold", size: 28))
                            .foregroundColor(.carbonInk)
                            .tracking(6)
                            .multilineTextAlignment(.center)
                            .keyboardType(.numberPad)
                            .focused($isCodeFocused)
                            .autocorrectionDisabled()
                            .onChange(of: lobbyCode) { oldValue, newValue in
                                let filtered = newValue.filter { $0.isNumber }
                                lobbyCode = String(filtered.prefix(6))
                            }
                    }
                    .frame(height: 50)
                    
                    // Dashed Underline
                    Line()
                        .stroke(Color.terracottaOrange.opacity(0.4), style: StrokeStyle(lineWidth: 1.5, dash: [4, 4]))
                        .frame(height: 1)
                        .padding(.horizontal, 40)
                }
                .padding(.vertical, 10)
                
                // Join Action Button
                Button(action: {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    // Setup Guest Player joined settings
                    viewModel.isHost = false
                    viewModel.lobbyCode = lobbyCode
                    
                    isPresented = false
                    withAnimation(.spring()) {
                        viewModel.path.append(.lobby)
                    }
                }) {
                    HStack {
                        Text("JOIN THE TABLE")
                            .font(.uiLabel(size: 14, weight: .black))
                            .tracking(1.5)
                        Image(systemName: "arrow.right")
                            .font(.footnote)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(lobbyCode.count == 6 ? Color.terracottaOrange : Color.terracottaOrange.opacity(0.5))
                    )
                    .shadow(color: Color.terracottaOrange.opacity(lobbyCode.count == 6 ? 0.3 : 0), radius: 6, x: 0, y: 4)
                }
                .disabled(lobbyCode.count != 6)
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
            }
        }
        .onAppear {
            isCodeFocused = true
        }
    }
}

#Preview {
    WelcomeView(viewModel: LobbyViewModel())
}
