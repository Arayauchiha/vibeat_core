import SwiftUI

struct RevealPodiumView: View {
    @ObservedObject var viewModel: LobbyViewModel
    @State private var expandedRestaurant: String? = nil
    
    var body: some View {
        ZStack {
            // Tabletop Linen Backdrop
            Image("texture_linen_table")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    HStack {
                        Button(action: {
                            withAnimation(.spring()) {
                                viewModel.path.removeLast()
                            }
                        }) {
                            Image(systemName: "arrow.left")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.inkPaper)
                        }
                        
                        Spacer()
                        
                        Text("Matched Diners")
                            .font(.editorialSubheader(size: 20))
                            .foregroundColor(.inkPaper)
                        
                        Spacer()
                        
                        // Close/Reset Button
                        Button(action: {
                            Task {
                                await viewModel.clearLobby()
                            }
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.inkPaper)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    // Reveal Mascot
                    Image("clochey_reveal")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 120)
                        .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 5)
                    
                    Text("THE PODIUM")
                        .font(.uiLabel(size: 12, weight: .black))
                        .foregroundColor(.terracottaOrange)
                        .tracking(3)
                    
                    if let recommendations = viewModel.recommendations {
                        // 1. TOP CHOICES LIST (PODIUM DECK)
                        VStack(spacing: 24) {
                            ForEach(recommendations.topChoices) { restaurant in
                                PodiumTicketView(
                                    restaurant: restaurant,
                                    isExpanded: expandedRestaurant == restaurant.id
                                )
                                .onTapGesture {
                                    withAnimation(.spring()) {
                                        if expandedRestaurant == restaurant.id {
                                            expandedRestaurant = nil
                                        } else {
                                            expandedRestaurant = restaurant.id
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // 2. SMART TRADEOFF PANEL
                        if !recommendations.smartTradeoffs.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "arrow.left.and.right.circle.fill")
                                        .foregroundColor(.terracottaOrange)
                                    Text("Smart Tradeoffs")
                                        .font(.uiLabel(size: 14, weight: .bold))
                                        .foregroundColor(.carbonInk)
                                }
                                
                                ForEach(recommendations.smartTradeoffs) { tradeoff in
                                    Text(tradeoff.uiCopy)
                                        .font(.uiLabel(size: 13, weight: .medium))
                                        .foregroundColor(.carbonInk.opacity(0.8))
                                        .padding(12)
                                        .background(Color.terracottaOrange.opacity(0.08))
                                        .cornerRadius(8)
                                }
                            }
                            .padding(20)
                            .ticketStubStyle()
                            .padding(.horizontal, 20)
                        }
                        
                        // 3. DISQUALIFIED VENUES PANEL
                        if !recommendations.disqualifiedVenues.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    Image(systemName: "exclamationmark.octagon.fill")
                                        .foregroundColor(.foodieStamp)
                                    Text("Disqualified Contenders")
                                        .font(.uiLabel(size: 14, weight: .bold))
                                        .foregroundColor(.carbonInk)
                                }
                                
                                ForEach(recommendations.disqualifiedVenues) { venue in
                                    HStack(alignment: .top, spacing: 12) {
                                        // Red disqualified stamp
                                        Image("stamp_disqualified")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 44, height: 44)
                                            .rotationEffect(.degrees(-5))
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(venue.name)
                                                .font(.uiLabel(size: 14, weight: .bold))
                                                .foregroundColor(.carbonInk)
                                            Text(venue.primaryReasonForDisqualification)
                                                .font(.uiLabel(size: 12))
                                                .foregroundColor(.foodieStamp.opacity(0.85))
                                        }
                                    }
                                    Divider().background(Color.subtleDottedLine)
                                }
                            }
                            .padding(20)
                            .ticketStubStyle()
                            .padding(.horizontal, 20)
                        }
                    } else {
                        // Empty State if no data parsed
                        VStack(spacing: 16) {
                            Image("clochey_empty")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 120)
                            Text("No recommendations found.")
                                .font(.uiLabel(size: 14))
                                .foregroundColor(.inkPaper.opacity(0.6))
                        }
                    }
                    
                    // Reset Button at bottom
                    Button(action: {
                        Task {
                            await viewModel.clearLobby()
                        }
                    }) {
                        Text("Start a New Table")
                            .font(.uiLabel(size: 16, weight: .bold))
                            .foregroundColor(.inkPaper)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.clear)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.inkPaper.opacity(0.5), lineWidth: 1.5)
                            )
                            .padding(.horizontal, 20)
                    }
                    .padding(.bottom, 40)
                }
                .padding(.vertical, 20)
            }
        }
    }
}

// MARK: - Individual Podium Ticket View
struct PodiumTicketView: View {
    let restaurant: Restaurant
    let isExpanded: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // MAIN TICKET FRONT
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    // Ranking Position Tag
                    Text("NO. \(restaurant.rankingPosition) CHOICE")
                        .font(.uiLabel(size: 10, weight: .bold))
                        .foregroundColor(.terracottaOrange)
                        .tracking(1)
                    
                    Text(restaurant.name)
                        .font(.editorialHeader(size: 22))
                        .foregroundColor(.carbonInk)
                    
                    HStack(spacing: 12) {
                        // Star Rating
                        HStack(spacing: 3) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.goldStamp)
                                .font(.caption2)
                            Text(String(format: "%.1f", restaurant.rating))
                                .font(.uiNumber(size: 13))
                        }
                        
                        // Travel variance
                        HStack(spacing: 3) {
                            Image(systemName: "clock")
                                .foregroundColor(.carbonInk.opacity(0.6))
                                .font(.caption2)
                            Text("\(restaurant.travelTimeVarianceMinutes)m variance")
                                .font(.uiLabel(size: 12))
                                .foregroundColor(.carbonInk.opacity(0.7))
                        }
                    }
                }
                
                Spacer()
                
                // Ink Stamp Overlay (If awarded tag exists)
                if let stamp = restaurant.awardTag {
                    Image(getStampImageName(stamp))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 75, height: 75)
                        .rotationEffect(.degrees(-10))
                        .shadow(color: .black.opacity(0.08), radius: 2, x: 1, y: 1)
                }
            }
            .padding(.bottom, 16)
            
            // EXPANDABLE TICKET SECTION
            if isExpanded {
                VStack(alignment: .leading, spacing: 16) {
                    Divider().background(Color.subtleDottedLine)
                    
                    // 1. Group Fit Context
                    VStack(alignment: .leading, spacing: 6) {
                        Text("WHY IT FITS")
                            .font(.uiLabel(size: 11, weight: .black))
                            .foregroundColor(.terracottaOrange)
                            .tracking(1)
                        
                        Text(restaurant.groupFitContext.headlineWhyItFits)
                            .font(.editorialSubheader(size: 14))
                            .foregroundColor(.carbonInk)
                        
                        Text(restaurant.groupFitContext.individualCravingMatches)
                            .font(.uiLabel(size: 12))
                            .foregroundColor(.carbonInk.opacity(0.7))
                    }
                    
                    // 2. Applied Promotions
                    if !restaurant.appliedWalletPromotions.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("CREDIT CARD OFFERS")
                                .font(.uiLabel(size: 11, weight: .black))
                                .foregroundColor(.budgetStamp)
                                .tracking(1)
                            
                            ForEach(restaurant.appliedWalletPromotions, id: \.self) { promo in
                                HStack {
                                    Image(systemName: "tag.fill")
                                        .font(.caption2)
                                        .foregroundColor(.budgetStamp)
                                    Text(promo)
                                        .font(.uiLabel(size: 12, weight: .semibold))
                                        .foregroundColor(.carbonInk.opacity(0.8))
                                }
                            }
                        }
                    }
                    
                    // 3. Commute Breakdown Table
                    VStack(alignment: .leading, spacing: 6) {
                        Text("COMMUTE TIMES")
                            .font(.uiLabel(size: 11, weight: .black))
                            .foregroundColor(.carbonInk.opacity(0.8))
                            .tracking(1)
                        
                        ForEach(restaurant.playerCommuteBreakdown.sorted(by: { $0.key < $1.key }), id: \.key) { name, minutes in
                            HStack {
                                Text(name)
                                    .font(.uiLabel(size: 13))
                                    .foregroundColor(.carbonInk.opacity(0.7))
                                Spacer()
                                Text("\(minutes) mins")
                                    .font(.uiNumber(size: 13))
                                    .foregroundColor(.carbonInk)
                            }
                        }
                    }
                }
                .padding(.top, 4)
                .transition(.opacity)
            }
        }
        .padding(20)
        .ticketStubStyle(cutoutRatio: 0.75, cutoutRadius: 12)
    }
    
    private func getStampImageName(_ tag: String) -> String {
        switch tag.lowercased() {
        case "gold_medalist":
            return "stamp_gold_medalist"
        case "budget_saver":
            return "stamp_budget_saver"
        case "foodie_favorite":
            return "stamp_foodie_favorite"
        case "fair_commute":
            return "stamp_fair_commute"
        default:
            return "stamp_fair_commute"
        }
    }
}

#Preview {
    RevealPodiumView(viewModel: LobbyViewModel())
}
