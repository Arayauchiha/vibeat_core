import SwiftUI

struct WalletDeckView: View {
    @ObservedObject var viewModel: LobbyViewModel
    
    // Form Inputs
    @State private var playerName = ""
    @State private var budget: Double = 1200
    @State private var selectedCuisines: [String] = []
    @State private var selectedAtmosphere: String = "cozy"
    @State private var wantsAlcohol = false
    
    // Wallet / Credit Card deck gesture state
    @State private var availableCards = ["HDFC", "SBI", "AXIS", "ICICI"]
    @State private var selectedCards: [String] = []
    @State private var cardOffsets: [String: CGSize] = [:]
    
    // Toggle between Ticket Entry and the Dining Table list
    @State private var isTicketSubmitted = false
    
    let cuisinesList = ["Italian", "Chinese", "Continental", "Asian", "North Indian", "South Indian"]
    
    var body: some View {
        ZStack {
            // Tabletop Linen Backdrop
            Image("texture_linen_table")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                // Header
                HStack {
                    Button(action: {
                        Task {
                            await viewModel.clearLobby()
                        }
                    }) {
                        Text("Reset Table")
                            .font(.uiLabel(size: 14, weight: .bold))
                            .foregroundColor(.terracottaOrange)
                    }
                    
                    Spacer()
                    
                    Text(isTicketSubmitted ? "Vibeat Dining Table" : "Fill Your Plate")
                        .font(.editorialSubheader(size: 20))
                        .foregroundColor(.inkPaper)
                    
                    Spacer()
                    
                    // Share Postmark Button (Circular stamp icon)
                    Button(action: {
                        let text = "Join my Vibeat Dining Table! Let's match: https://vibeat-backend-jn0q.onrender.com"
                        let av = UIActivityViewController(activityItems: [text], applicationActivities: nil)
                        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                           let rootVC = windowScene.windows.first?.rootViewController {
                            rootVC.present(av, animated: true, completion: nil)
                        }
                    }) {
                        Image("stamp_airmail_invite")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 44, height: 44)
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                if !isTicketSubmitted {
                    // MODE 1: Fill out your entrance ticket
                    ScrollView {
                        VStack(spacing: 20) {
                            // Mascot waiting
                            Image("clochey_waiting")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 120)
                                .padding(.top, 5)
                            
                            // Guest Ticket Form
                            VStack(spacing: 16) {
                                Text("DINING VIBE TICKET")
                                    .font(.uiLabel(size: 13, weight: .bold))
                                    .foregroundColor(.terracottaOrange)
                                    .tracking(2)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                TextField("Your Name", text: $playerName)
                                    .font(.uiLabel(size: 16, weight: .semibold))
                                    .padding()
                                    .background(Color.tabletop.opacity(0.05))
                                    .cornerRadius(8)
                                    .autocorrectionDisabled()
                                
                                // Budget Slider
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text("Max Budget Per Person")
                                            .font(.uiLabel(size: 14, weight: .bold))
                                            .foregroundColor(.carbonInk)
                                        Spacer()
                                        Text("₹\(Int(budget))")
                                            .font(.uiNumber())
                                            .foregroundColor(.terracottaOrange)
                                    }
                                    Slider(value: $budget, in: 300...3000, step: 50)
                                        .tint(.terracottaOrange)
                                }
                                
                                // Cuisines Chips Selection
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Select Preferred Cuisines")
                                        .font(.uiLabel(size: 14, weight: .bold))
                                        .foregroundColor(.carbonInk)
                                    
                                    // Cuisine Bubble Layout
                                    FlowLayout(items: cuisinesList) { cuisine in
                                        let isSelected = selectedCuisines.contains(cuisine)
                                        Button(action: {
                                            if isSelected {
                                                selectedCuisines.removeAll { $0 == cuisine }
                                            } else {
                                                if selectedCuisines.count < 3 {
                                                    selectedCuisines.append(cuisine)
                                                }
                                            }
                                        }) {
                                            Text(cuisine)
                                                .font(.uiLabel(size: 12, weight: .bold))
                                                .foregroundColor(isSelected ? .inkPaper : .carbonInk)
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 6)
                                                .background(isSelected ? Color.terracottaOrange : Color.carbonInk.opacity(0.08))
                                                .cornerRadius(20)
                                        }
                                    }
                                }
                                
                                // Card Selector & Throwing Gesture
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Swipe Up Card to Add Benefits")
                                        .font(.uiLabel(size: 14, weight: .bold))
                                        .foregroundColor(.carbonInk)
                                    
                                    ZStack {
                                        // Leather Wallet Card Sleeve Background
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.tabletop.opacity(0.12))
                                            .frame(height: 110)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(Color.carbonInk.opacity(0.15), lineWidth: 1)
                                            )
                                        
                                        HStack(spacing: -12) {
                                            ForEach(availableCards, id: \.self) { card in
                                                CardMiniView(bank: card)
                                                    .offset(cardOffsets[card] ?? .zero)
                                                    .gesture(
                                                        DragGesture()
                                                            .onChanged { gesture in
                                                                cardOffsets[card] = CGSize(width: 0, height: min(0, gesture.translation.height))
                                                            }
                                                            .onEnded { gesture in
                                                                if gesture.translation.height < -70 {
                                                                    // Thrown! Animates off the top
                                                                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                                                    withAnimation(.spring()) {
                                                                        cardOffsets[card] = CGSize(width: 0, height: -350)
                                                                        selectedCards.append(card)
                                                                        availableCards.removeAll { $0 == card }
                                                                    }
                                                                } else {
                                                                    // Snaps back
                                                                    withAnimation(.spring()) {
                                                                        cardOffsets[card] = .zero
                                                                    }
                                                                }
                                                            }
                                                    )
                                            }
                                        }
                                    }
                                }
                                
                                Toggle("Wants Alcohol", isOn: $wantsAlcohol)
                                    .font(.uiLabel(size: 14, weight: .bold))
                                    .foregroundColor(.carbonInk)
                                    .tint(.terracottaOrange)
                            }
                            .padding(20)
                            .ticketStubStyle()
                            .padding(.horizontal, 20)
                            
                            // Toss Ticket Action Button
                            Button(action: {
                                guard !playerName.isEmpty else { return }
                                let player = Player(
                                    name: playerName,
                                    lat: 28.6139, // Simulated coordinate
                                    lng: 77.2090,
                                    budget: budget,
                                    cuisines: selectedCuisines,
                                    cards: selectedCards,
                                    wantsAlcohol: wantsAlcohol,
                                    atmosphere: selectedAtmosphere,
                                    specificDish: nil
                                )
                                Task {
                                    await viewModel.addPlayer(player)
                                    withAnimation(.spring()) {
                                        isTicketSubmitted = true
                                    }
                                }
                            }) {
                                Text("Toss Ticket to Table 🍽️")
                                    .font(.uiLabel(size: 16, weight: .bold))
                                    .foregroundColor(.carbonInk)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(Color.inkPaper)
                                    .cornerRadius(12)
                                    .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 3)
                            }
                            .padding(.horizontal, 20)
                            .disabled(playerName.isEmpty)
                            .opacity(playerName.isEmpty ? 0.5 : 1.0)
                        }
                    }
                } else {
                    // MODE 2: Staging Lobby / Dining Table Active List
                    VStack(spacing: 24) {
                        Spacer()
                        
                        // Active Table list
                        VStack(spacing: 16) {
                            Text("ACTIVE GUESTS")
                                .font(.uiLabel(size: 13, weight: .bold))
                                .foregroundColor(.terracottaOrange)
                                .tracking(2)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            ScrollView {
                                ForEach(viewModel.activePlayers) { player in
                                    HStack {
                                        Image(systemName: "person.circle.fill")
                                            .font(.title2)
                                            .foregroundColor(.carbonInk.opacity(0.4))
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(player.name)
                                                .font(.uiLabel(size: 15, weight: .bold))
                                                .foregroundColor(.carbonInk)
                                            Text("Limit: ₹\(Int(player.budget)) • Cards: \(player.cards.joined(separator: ", "))")
                                                .font(.uiLabel(size: 11))
                                                .foregroundColor(.carbonInk.opacity(0.6))
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "checkmark.seal.fill")
                                            .foregroundColor(.budgetStamp)
                                    }
                                    .padding(.vertical, 8)
                                    Divider().background(Color.subtleDottedLine)
                                }
                            }
                            .frame(height: 220)
                        }
                        .padding(24)
                        .ticketStubStyle()
                        .padding(.horizontal, 20)
                        
                        Spacer()
                        
                        // Compute Vibe & Match (Represented by Red Wax Seal!)
                        VStack(spacing: 8) {
                            Button(action: {
                                Task {
                                    UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                                    await viewModel.calculateRecommendations()
                                }
                            }) {
                                Image("ui_wax_seal_red")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 100, height: 100)
                                    .shadow(color: .black.opacity(0.4), radius: 8, x: 0, y: 5)
                            }
                            
                            Text("SEAL LOBBY & COMPUTE")
                                .font(.uiLabel(size: 12, weight: .black))
                                .foregroundColor(.inkPaper)
                                .tracking(1)
                        }
                        .padding(.bottom, 40)
                    }
                }
            }
        }
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
