import SwiftUI


struct RevealPodiumView: View {
    @ObservedObject var viewModel: LobbyViewModel
    @State private var expandedRestaurant: String? = nil

    var body: some View {
        ZStack {
            PodiumBackground()

            ScrollView(.vertical, showsIndicators: true) {
                VStack(spacing: 24) {
                    PodiumHeaderView(
                        onBack: { viewModel.path.removeLast() },
                        onReset: { withAnimation(.spring()) { viewModel.resetLobbyState() } }
                    )

                    PodiumMascotView()

                    if let recommendations = viewModel.recommendations {
                        LeaderboardAwardsSection(leaderboard: recommendations.leaderboard)

                        TopChoicesSection(
                            topChoices: recommendations.topChoices,
                            expandedRestaurant: $expandedRestaurant
                        )

                        SmartTradeoffsSection(tradeoffs: recommendations.smartTradeoffs)

                        AlternativeSuggestionsSection(
                            alternatives: recommendations.alternativeSuggestions,
                            expandedRestaurant: $expandedRestaurant
                        )

                        DisqualifiedVenuesSection(venues: recommendations.disqualifiedVenues)
                    } else {
                        PodiumEmptyStateView()
                    }

                    StartNewTableButton {
                        withAnimation(.spring()) { viewModel.resetLobbyState() }
                    }
                }
                .padding(.vertical, 20)
            }
        }
    }
}

// MARK: - Background

private struct PodiumBackground: View {
    var body: some View {
        SwiftUI.Image("texture_linen_table")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .edgesIgnoringSafeArea(.all)
    }
}

// MARK: - Header

private struct PodiumHeaderView: View {
    let onBack: () -> Void
    let onReset: () -> Void

    var body: some View {
        HStack {
            Button(action: onBack) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.inkPaper)
            }

            Spacer()

            Text("Matched Diners")
                .font(.editorialSubheader(size: 20))
                .foregroundColor(.inkPaper)

            Spacer()

            Button(action: onReset) {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.inkPaper)
            }
        }
        .padding(.horizontal)
        .padding(.top, 10)
    }
}

// MARK: - Mascot

private struct PodiumMascotView: View {
    var body: some View {
        VStack(spacing: 8) {
            SwiftUI.Image("clochey_reveal")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 120)
                .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 5)

            Text("THE PODIUM")
                .font(.uiLabel(size: 12, weight: .black))
                .foregroundColor(.terracottaOrange)
                .tracking(3)
        }
    }
}

// MARK: - 1. Leaderboard Awards

private struct LeaderboardAwardsSection: View {
    let leaderboard: Leaderboard

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: "trophy.fill")
                    .foregroundColor(.goldStamp)
                Text("Leaderboard Awards")
                    .font(.uiLabel(size: 13, weight: .black))
                    .foregroundColor(.carbonInk)
                    .tracking(1)
            }
            .padding(.bottom, 2)

            VStack(spacing: 10) {
                if let gold = leaderboard.goldMedalist {
                    LeaderboardRow(icon: "🏆", category: "Gold Medalist", name: gold, color: .goldStamp)
                }
                if let budget = leaderboard.budgetSaver {
                    LeaderboardRow(icon: "💰", category: "Budget Saver", name: budget, color: .budgetStamp)
                }
                if let foodie = leaderboard.foodieFavorite {
                    LeaderboardRow(icon: "❤️", category: "Foodie Favorite", name: foodie, color: .foodieStamp)
                }
                if let commute = leaderboard.fairCommute {
                    LeaderboardRow(icon: "🚗", category: "Fair Commute", name: commute, color: .blue)
                }
            }
        }
        .padding(20)
        .menuBoardStyle()
        .padding(.horizontal, 20)
    }
}

// MARK: - 2. Top Choices (Podium Deck)

private struct TopChoicesSection: View {
    let topChoices: [TopChoice]
    @Binding var expandedRestaurant: String?

    var body: some View {
        VStack(spacing: 24) {
            ForEach(topChoices) { restaurant in
                PodiumTicketView(
                    restaurant: restaurant,
                    isExpanded: expandedRestaurant == restaurant.id
                )
                .onTapGesture {
                    withAnimation(.spring()) {
                        expandedRestaurant = (expandedRestaurant == restaurant.id) ? nil : restaurant.id
                    }
                }
            }
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - 3. Smart Tradeoffs

private struct SmartTradeoffsSection: View {
    let tradeoffs: [SmartTradeoff]

    var body: some View {
        if !tradeoffs.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "arrow.left.and.right.circle.fill")
                        .foregroundColor(.terracottaOrange)
                    Text("Smart Tradeoffs")
                        .font(.uiLabel(size: 14, weight: .bold))
                        .foregroundColor(.carbonInk)
                }

                ForEach(tradeoffs) { tradeoff in
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
    }
}

// MARK: - 4. Alternative Suggestions

private struct AlternativeSuggestionsSection: View {
    let alternatives: [AlternativeSuggestion]
    @Binding var expandedRestaurant: String?

    var body: some View {
        if !alternatives.isEmpty {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "list.bullet.circle.fill")
                        .foregroundColor(.inkPaper)
                    Text("Alternative Recommendations")
                        .font(.uiLabel(size: 14, weight: .bold))
                        .foregroundColor(.inkPaper)
                        .tracking(1)
                }
                .padding(.horizontal, 24)

                VStack(spacing: 16) {
                    ForEach(alternatives) { restaurant in
                        AlternativeTicketView(
                            restaurant: restaurant,
                            isExpanded: expandedRestaurant == restaurant.id
                        )
                        .onTapGesture {
                            withAnimation(.spring()) {
                                expandedRestaurant = (expandedRestaurant == restaurant.id) ? nil : restaurant.id
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(.vertical, 8)
        }
    }
}

// MARK: - 5. Disqualified Venues

private struct DisqualifiedVenuesSection: View {
    let venues: [DisqualifiedVenue]

    var body: some View {
        if !venues.isEmpty {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "exclamationmark.octagon.fill")
                        .foregroundColor(.foodieStamp)
                    Text("Disqualified Contenders")
                        .font(.uiLabel(size: 14, weight: .bold))
                        .foregroundColor(.carbonInk)
                }

                ForEach(venues) { venue in
                    DisqualifiedVenueRow(venue: venue)
                    Divider().background(Color.subtleDottedLine)
                }
            }
            .padding(20)
            .ticketStubStyle()
            .padding(.horizontal, 20)
        }
    }
}

private struct DisqualifiedVenueRow: View {
    let venue: DisqualifiedVenue

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            SwiftUI.Image("stamp_disqualified")
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
    }
}

// MARK: - Empty State

private struct PodiumEmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            SwiftUI.Image("clochey_empty")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 120)
            Text("No recommendations found.")
                .font(.uiLabel(size: 14))
                .foregroundColor(.inkPaper.opacity(0.6))
        }
    }
}

// MARK: - Start New Table Button

private struct StartNewTableButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
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
}

// MARK: - LeaderboardRow Component
struct LeaderboardRow: View {
    let icon: String
    let category: String
    let name: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Text(icon)
                .font(.title3)
            VStack(alignment: .leading, spacing: 2) {
                Text(category.uppercased())
                    .font(.uiLabel(size: 9, weight: .black))
                    .foregroundColor(color)
                    .tracking(1)
                Text(name)
                    .font(.editorialHeader(size: 16))
                    .foregroundColor(.carbonInk)
            }
            Spacer()
        }
        .padding(10)
        .background(Color.white.opacity(0.75))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.carbonInk.opacity(0.08), lineWidth: 1)
        )
    }
}

// MARK: - Individual Podium Ticket View
struct PodiumTicketView: View {
    let restaurant: TopChoice
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
                    
                    // Safety / Warning Tags (NEW!)
                    if !restaurant.safetyWarningTags.isEmpty {
                        HStack(spacing: 6) {
                            ForEach(restaurant.safetyWarningTags, id: \.self) { tag in
                                HStack(spacing: 3) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .font(.system(size: 8))
                                    Text(tag)
                                        .font(.uiLabel(size: 9, weight: .bold))
                                }
                                .foregroundColor(.foodieStamp)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.foodieStamp.opacity(0.1))
                                .cornerRadius(4)
                            }
                        }
                        .padding(.top, 4)
                    }
                }
                
                Spacer()
                
                // Ink Stamp Overlay (If awarded tag exists)
                if let stamp = restaurant.awardTag {
                    SwiftUI.Image(getStampImageName(stamp.rawValue))
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
                    
                    // 1. Group Fit Context (Why It Fits)
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
                            .lineSpacing(2)
                    }
                    
                    // 2. Vibe & Card Alignment (NEW!)
                    VStack(alignment: .leading, spacing: 6) {
                        Text("VIBE & WALLET ALIGNMENT")
                            .font(.uiLabel(size: 11, weight: .black))
                            .foregroundColor(.terracottaOrange)
                            .tracking(1)
                        
                        Text(restaurant.groupFitContext.vibeAndCardAlignment)
                            .font(.uiLabel(size: 12))
                            .foregroundColor(.carbonInk.opacity(0.7))
                            .lineSpacing(2)
                    }
                    
                    // 3. Applied Promotions
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
                    
                    // 4. Commute Breakdown Table
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

// MARK: - Alternative Recommendation Ticket View (NEW!)
struct AlternativeTicketView: View {
    let restaurant: AlternativeSuggestion
    let isExpanded: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(restaurant.name)
                        .font(.editorialHeader(size: 18))
                        .foregroundColor(.carbonInk)
                    
                    HStack(spacing: 12) {
                        HStack(spacing: 3) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.goldStamp)
                                .font(.caption2)
                            Text(String(format: "%.1f", restaurant.rating))
                                .font(.uiNumber(size: 12))
                        }
                        
                        HStack(spacing: 3) {
                            Image(systemName: "clock")
                                .foregroundColor(.carbonInk.opacity(0.5))
                                .font(.caption2)
                            Text("\(restaurant.travelTimeVarianceMinutes)m variance")
                                .font(.uiLabel(size: 11))
                                .foregroundColor(.carbonInk.opacity(0.6))
                        }
                    }
                }
                
                Spacer()
                
                if let stamp = restaurant.awardTag {
                    SwiftUI.Image(getStampImageName(stamp.rawValue))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50)
                        .rotationEffect(.degrees(-8))
                }
            }
            .padding(.bottom, isExpanded ? 12 : 0)
            
            if isExpanded {
                VStack(alignment: .leading, spacing: 12) {
                    Divider().background(Color.subtleDottedLine)
                    
                    // Why it fits
                    VStack(alignment: .leading, spacing: 4) {
                        Text("WHY IT FITS")
                            .font(.uiLabel(size: 10, weight: .black))
                            .foregroundColor(.terracottaOrange)
                            .tracking(1)
                        Text(restaurant.groupFitContext.headlineWhyItFits)
                            .font(.editorialSubheader(size: 13))
                            .foregroundColor(.carbonInk)
                        Text(restaurant.groupFitContext.individualCravingMatches)
                            .font(.uiLabel(size: 12))
                            .foregroundColor(.carbonInk.opacity(0.7))
                            .lineSpacing(2)
                    }
                    
                    // Vibe & Card Alignment
                    VStack(alignment: .leading, spacing: 4) {
                        Text("VIBE & WALLET ALIGNMENT")
                            .font(.uiLabel(size: 10, weight: .black))
                            .foregroundColor(.terracottaOrange)
                            .tracking(1)
                        Text(restaurant.groupFitContext.vibeAndCardAlignment)
                            .font(.uiLabel(size: 12))
                            .foregroundColor(.carbonInk.opacity(0.7))
                            .lineSpacing(2)
                    }
                    
                    // Commute Table
                    VStack(alignment: .leading, spacing: 4) {
                        Text("COMMUTE TIMES")
                            .font(.uiLabel(size: 10, weight: .black))
                            .foregroundColor(.carbonInk.opacity(0.8))
                            .tracking(1)
                        
                        ForEach(restaurant.playerCommuteBreakdown.sorted(by: { $0.key < $1.key }), id: \.key) { name, minutes in
                            HStack {
                                Text(name)
                                    .font(.uiLabel(size: 12))
                                    .foregroundColor(.carbonInk.opacity(0.7))
                                Spacer()
                                Text("\(minutes) mins")
                                    .font(.uiNumber(size: 12))
                                    .foregroundColor(.carbonInk)
                            }
                        }
                    }
                }
                .transition(.opacity)
            }
        }
        .padding(16)
        .ticketStubStyle(cutoutRatio: 0.8, cutoutRadius: 8)
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
