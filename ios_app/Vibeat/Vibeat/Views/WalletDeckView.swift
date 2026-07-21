import SwiftUI
import Combine
import MapKit
import CoreLocation

struct WalletDeckView: View {
    @ObservedObject var viewModel: LobbyViewModel
    
    // State to persist guest player name across quiz and staging orbit view
    @State private var playerName = ""
    
    // Wallet / Credit Card deck gesture state
    @State private var availableCards = ["HDFC", "SBI", "AXIS", "ICICI"]
    @State private var selectedCards: [String] = []
    @State private var cardOffsets: [String: CGSize] = [:]
    
    // Orbit Lobby animations and alerts
    @State private var showingStartAlert = false
    @State private var copiedCode = false
    
    var body: some View {
        ZStack {
            Color.inkPaper
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                if viewModel.isQuizStarted {
                    GuestQuizView(viewModel: viewModel, playerName: $playerName)
                } else {
                    // MODE 2: Staging Orbit Lobby
                    VStack(spacing: 0) {
                        // Small spacer to push title below status bar
                        Spacer()
                            .frame(height: 15)
                        
                        // Lobby Info Header
                        VStack(spacing: 12) {
                            Text(viewModel.lobbyTitle.isEmpty ? "VIBEAT" : viewModel.lobbyTitle.uppercased())
                                .font(.custom("Georgia-Bold", size: 36))
                                .foregroundColor(.carbonInk)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 24)
                            
                            HStack(spacing: 12) {
                                Button(action: {
                                    UIPasteboard.general.string = viewModel.lobbyCode.isEmpty ? "847293" : viewModel.lobbyCode
                                    copiedCode = true
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                        copiedCode = false
                                    }
                                }) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "doc.on.doc.fill")
                                            .font(.caption2)
                                        Text(copiedCode ? "COPIED! ✓" : "CODE: \(viewModel.lobbyCode.isEmpty ? "847293" : viewModel.lobbyCode)")
                                            .font(.system(size: 13, weight: .bold, design: .monospaced))
                                    }
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 14)
                                    .background(Color.carbonInk.opacity(0.08))
                                    .cornerRadius(20)
                                    .foregroundColor(.carbonInk)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.carbonInk.opacity(0.15), lineWidth: 1)
                                    )
                                }
                                
                                Button(action: {
                                    let inviteLink = "Join my Vibeat Dining Table! Let's match: https://vibeat-backend-jn0q.onrender.com/\(viewModel.lobbyCode)"
                                    let av = UIActivityViewController(activityItems: [inviteLink], applicationActivities: nil)
                                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                                       let rootVC = windowScene.windows.first?.rootViewController {
                                        rootVC.present(av, animated: true, completion: nil)
                                    }
                                }) {
                                    Image(systemName: "square.and.arrow.up")
                                        .font(.system(size: 15, weight: .bold))
                                        .padding(10)
                                        .background(Color.carbonInk.opacity(0.08))
                                        .clipShape(Circle())
                                        .foregroundColor(.carbonInk)
                                        .overlay(
                                            Circle().stroke(Color.carbonInk.opacity(0.15), lineWidth: 1)
                                        )
                                }
                            }
                        }
                        .padding(.top, 10)
                        
                        Spacer()
                        
                        // Dynamic concentric orbits
                        OrbitLobbyView(players: viewModel.activePlayers) { name in
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        }
                        .padding(.vertical, 10)
                        
                        Spacer()
                        
                        // Action Buttons Area
                        if viewModel.isHost {
                            // Host Start Matching button
                            Button(action: {
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                // Trigger the alert that lets the host start the quiz
                                showingStartAlert = true
                            }) {
                                Text("START MATCHING 🍽️")
                                    .font(.uiLabel(size: 14, weight: .black))
                                    .foregroundColor(.inkPaper)
                                    .tracking(1.5)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 15)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.terracottaOrange)
                                    )
                                    .shadow(color: Color.terracottaOrange.opacity(0.4), radius: 6, x: 0, y: 4)
                            }
                            .padding(.horizontal, 24)
                            .padding(.bottom, 36)
                            .alert("Not Everyone is Ready", isPresented: $showingStartAlert) {
                                Button("Wait", role: .cancel) { }
                                Button("Start Anyway", role: .destructive) {
                                    withAnimation(.spring()) {
                                        viewModel.isQuizStarted = true
                                    }
                                }
                            } message: {
                                Text("Some diners haven't marked themselves as ready. Do you want to start preference matching anyway?")
                            }
                        } else {
                            let myReadyState = true
                            Button(action: {
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            }) {
                                Text(myReadyState ? "READY TO START ✓" : "MARK READY TO DECIDE 🍽️")
                                    .font(.uiLabel(size: 14, weight: .black))
                                    .foregroundColor(myReadyState ? .white : .inkPaper)
                                    .tracking(1.5)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 15)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(myReadyState ? Color.green : Color.terracottaOrange)
                                    )
                                    .shadow(color: (myReadyState ? Color.green : Color.terracottaOrange).opacity(0.3), radius: 6, x: 0, y: 4)
                            }
                            .padding(.horizontal, 24)
                            .padding(.bottom, 36)
                        }
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(viewModel.isQuizStarted)
    }
}

struct MenuBoardStyleModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.carbonInk.opacity(0.12), lineWidth: 1.5)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.terracottaOrange.opacity(0.35), lineWidth: 2)
                            .padding(6)
                    )
                    .overlay(
                        GeometryReader { geo in
                            Image("texture_recycled_paper")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: geo.size.width, height: geo.size.height)
                                .clipped()
                                .blendMode(.multiply)
                                .opacity(0.10)
                        }
                    )
            )
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 5)
    }
}

extension View {
    func menuBoardStyle() -> some View {
        self.modifier(MenuBoardStyleModifier())
    }
}

// MARK: - Mini Card Component
struct CardMiniView: View {
    let bank: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(bank)
                .font(.uiLabel(size: 11, weight: .bold))
                .foregroundColor(.white)
            Spacer()
            Image(systemName: "simcard.fill")
                .font(.caption2)
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(8)
        .frame(width: 75, height: 50)
        .background(
            LinearGradient(
                colors: getGradient(),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(6)
        .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 2)
    }
    
    private func getGradient() -> [Color] {
        switch bank.uppercased() {
        case "HDFC":
            return [Color(hex: "0F5499"), Color(hex: "003366")]
        case "ICICI":
            return [Color(hex: "A30000"), Color(hex: "5A0000")]
        case "SBI":
            return [Color(hex: "009688"), Color(hex: "004D40")]
        case "AXIS":
            return [Color(hex: "880E4F"), Color(hex: "4A0033")]
        default:
            return [.gray, .black]
        }
    }
}

// MARK: - Simple FlowLayout for Bubble Chips
struct FlowLayout: View {
    let items: [String]
    var spacing: CGFloat = 8
    let viewMapping: (String) -> AnyView
    
    init<V: View>(items: [String], spacing: CGFloat = 8, @ViewBuilder content: @escaping (String) -> V) {
        self.items = items
        self.spacing = spacing
        self.viewMapping = { AnyView(content($0)) }
    }
    
    var body: some View {
        var width = CGFloat.zero
        var height = CGFloat.zero
        
        return GeometryReader { geo in
            ZStack(alignment: .topLeading) {
                ForEach(items, id: \.self) { item in
                    viewMapping(item)
                        .padding(.all, 4)
                        .alignmentGuide(.leading) { d in
                            if abs(width - d.width) > geo.size.width {
                                width = 0
                                height -= d.height
                            }
                            let result = width
                            if item == items.last {
                                width = 0 // Last item reset
                            } else {
                                width -= d.width
                            }
                            return result
                        }
                        .alignmentGuide(.top) { _ in
                            let result = height
                            if item == items.last {
                                height = 0 // Last item reset
                            }
                            return result
                        }
                }
            }
        }
        .frame(minHeight: 80) // Restrict layout size
    }
}

// MARK: - Dynamic Concentric Orbit View
struct OrbitLobbyView: View {
    let players: [User]
    let onPlayerTap: (String) -> Void
    
    private let orbitColors: [Color] = [
        Color(red: 254/255, green: 110/255, blue: 23/255),
        Color(red: 255/255, green: 55/255,  blue: 95/255),
        Color(red: 155/255, green: 89/255,  blue: 182/255),
        Color(red: 46/255,  green: 204/255, blue: 113/255),
        Color(red: 52/255,  green: 152/255, blue: 219/255),
        Color(red: 241/255, green: 196/255, blue: 15/255),
        Color(red: 231/255, green: 76/255,  blue: 60/255)
    ]
    
    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate * 0.35
            let memberCount = players.count
            let ringRadii: [CGFloat] = [80, 130, 170]
            
            ZStack {
                // Concentric rings
                ForEach(0..<3, id: \.self) { ring in
                    let diameter = ringRadii[ring] * 2
                    Circle()
                        .stroke(Color.carbonInk.opacity(Double(ring + 1) * 0.04), lineWidth: 1.2)
                        .frame(width: diameter, height: diameter)
                }
                
                // Center hub — the vibeat logo
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.carbonInk)
                    .frame(width: 68, height: 68)
                    .overlay(
                        Text("vb")
                            .font(.system(size: 26, weight: .bold, design: .serif))
                            .foregroundColor(Color.inkPaper)
                    )
                
                // Orbiting players
                if memberCount == 0 {
                    // Solo — just "You" on inner ring
                    MemberOrb(initials: "You", color: orbitColors[0], size: 48, isReady: true)
                        .offset(
                            x: ringRadii[0] * cos(t),
                            y: ringRadii[0] * sin(t)
                        )
                } else {
                    ForEach(Array(players.enumerated()), id: \.element.id) { index, player in
                        let ringIndex: Int = {
                            if memberCount <= 4 {
                                return 0
                            } else if memberCount <= 8 {
                                return index < 4 ? 0 : 1
                            } else {
                                if index < 4 { return 0 }
                                else if index < 8 { return 1 }
                                else { return 2 }
                            }
                        }()
                        
                        let distance = ringRadii[ringIndex]
                        
                        let membersOnSameRing: Int = {
                            if memberCount <= 4 {
                                return memberCount
                            } else if memberCount <= 8 {
                                return ringIndex == 0 ? 4 : memberCount - 4
                            } else {
                                if ringIndex == 0 { return 4 }
                                else if ringIndex == 1 { return min(4, memberCount - 4) }
                                else { return memberCount - 8 }
                            }
                        }()
                        
                        let indexOnRing: Int = {
                            if memberCount <= 4 {
                                return index
                            } else if memberCount <= 8 {
                                return ringIndex == 0 ? index : index - 4
                            } else {
                                if ringIndex == 0 { return index }
                                else if ringIndex == 1 { return index - 4 }
                                else { return index - 8 }
                            }
                        }()
                        
                        let speed: Double = ringIndex == 0 ? 1.0 : (ringIndex == 1 ? 0.7 : 0.5)
                        let angle = Double(indexOnRing) * (2 * .pi / Double(max(1, membersOnSameRing))) + (t * speed)
                        let orbSize: CGFloat = ringIndex == 0 ? 48 : (ringIndex == 1 ? 42 : 38)
                        
                        Button(action: {
                            onPlayerTap(player.fullName)
                        }) {
                            MemberOrb(
                                initials: String(player.fullName.prefix(2)).uppercased(),
                                color: orbitColors[index % orbitColors.count],
                                size: orbSize,
                                isReady: true
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        .offset(
                            x: distance * cos(angle),
                            y: distance * sin(angle)
                        )
                    }
                }
            }
            .frame(width: 360, height: 360)
        }
    }
}

// MARK: - MemberOrb
struct MemberOrb: View {
    let initials: String
    let color: Color
    let size: CGFloat
    let isReady: Bool
    
    var body: some View {
        ZStack {
            Circle()
                .fill(color)
                .frame(width: size, height: size)
            
            if isReady {
                Circle()
                    .stroke(Color.green, lineWidth: 3)
                    .frame(width: size, height: size)
                    .shadow(color: .green.opacity(0.6), radius: 4)
            }
            
            Text(initials)
                .font(.system(size: size * 0.28, weight: .bold))
                .foregroundColor(.white)
        }
    }
}
