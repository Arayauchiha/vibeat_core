import SwiftUI

struct JoinSetupView: View {
    @ObservedObject var viewModel: LobbyViewModel
    @State private var inviteCode: String = ""
    
    var body: some View {
        ZStack {
            // Solid dark slate background
            Color(red: 0.08, green: 0.10, blue: 0.13)
                .edgesIgnoringSafeArea(.all)
                .ignoresSafeArea(.keyboard)
            
            VStack {
                Spacer()
                
                // JOIN TICKET HERO (Adaptive Size)
                VStack(spacing: 0) {
                    
                    // UPPER TICKET (above perforation): Mascot & Invite Code Input
                    VStack(spacing: 24) {
                        // Mascot Cue
                        HStack(alignment: .center, spacing: 16) {
                            Image("clochey_welcome")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 80, height: 80)
                                .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
                            
                            Text("Enter the 6-digit invite code to join your friends' dining table!")
                                .font(.editorialSubheader(size: 13))
                                .foregroundColor(.carbonInk)
                                .lineSpacing(3)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.carbonInk.opacity(0.15), lineWidth: 1)
                                        .background(Color.inkPaper.opacity(0.95))
                                )
                                .overlay(
                                    Image(systemName: "triangle.fill")
                                        .font(.system(size: 10))
                                        .foregroundColor(.inkPaper)
                                        .overlay(
                                            Image(systemName: "triangle")
                                                .font(.system(size: 10))
                                                .foregroundColor(.carbonInk.opacity(0.15))
                                        )
                                        .rotationEffect(.degrees(-90))
                                        .offset(x: -14)
                                    , alignment: .leading
                                )
                        }
                        
                        // Input Field
                        VStack(alignment: .leading, spacing: 4) {
                            Text("INVITE CODE")
                                .font(.uiLabel(size: 10, weight: .bold))
                                .foregroundColor(.carbonInk.opacity(0.4))
                                .tracking(1.5)
                            
                            ZStack(alignment: .leading) {
                                if inviteCode.isEmpty {
                                    Text("VIBE-XXXXXX")
                                        .font(.uiNumber(size: 18, weight: .bold))
                                        .foregroundColor(.carbonInk.opacity(0.25))
                                }
                                
                                TextField("", text: $inviteCode)
                                    .font(.uiNumber(size: 18, weight: .bold))
                                    .foregroundColor(.carbonInk)
                                    .tint(.terracottaOrange)
                                    .autocorrectionDisabled()
                                    .autocapitalization(.allCharacters)
                                    .keyboardType(.asciiCapable)
                                    .onChange(of: inviteCode) { oldValue, newValue in
                                        let filtered = newValue.uppercased().filter { $0.isLetter || $0.isNumber }
                                        inviteCode = String(filtered.prefix(6))
                                    }
                            }
                            
                            // Dotted line
                            Line()
                                .stroke(Color.carbonInk.opacity(0.2), style: StrokeStyle(lineWidth: 1, dash: [2, 3]))
                                .frame(height: 1)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                    .padding(.bottom, 20)
                    
                    // LOWER TICKET (below perforation): Submit Action Button
                    VStack {
                        Spacer()
                        
                        Button(action: {
                            withAnimation(.spring()) {
                                viewModel.path.append(.lobby)
                            }
                        }) {
                            HStack {
                                Text("ENTER TABLE")
                                    .font(.uiLabel(size: 14, weight: .black))
                                    .foregroundColor(.inkPaper)
                                    .tracking(2)
                                
                                Image(systemName: "arrow.right")
                                    .font(.footnote)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(inviteCode.count == 6 ? Color.terracottaOrange : Color.carbonInk.opacity(0.25))
                            )
                            .shadow(color: .black.opacity(inviteCode.count == 6 ? 0.2 : 0), radius: 4, x: 0, y: 3)
                        }
                        .disabled(inviteCode.count != 6)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    .padding(.bottom, 24)
                }
                .ticketStubStyle(cutoutRatio: 0.70, cutoutRadius: 10)
                .padding(.horizontal, 24)
                .padding(.vertical, 32)
                
                Spacer()
            }
        }
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
}

#Preview {
    JoinSetupView(viewModel: LobbyViewModel())
}
