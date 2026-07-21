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
                        // 1. Compact Leaderboard Row
                        LeaderboardAwardsSection(leaderboard: recommendations.leaderboard)

                        // 2. Main Top 3 Recommendations Card
                        TopChoicesSection(
                            topChoices: recommendations.topChoices,
                            expandedRestaurant: $expandedRestaurant
                        )

                        // 3. AI Tradeoffs
                        SmartTradeoffsSection(tradeoffs: recommendations.smartTradeoffs)

                        // 4. Alternative Suggestions
                        AlternativeSuggestionsSection(
                            alternatives: recommendations.alternativeSuggestions,
                            expandedRestaurant: $expandedRestaurant
                        )

                        // 5. Collapsible Disqualified Contenders
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
        Color.tabletop
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
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(Color.white.opacity(0.12))
                    .clipShape(Circle())
                    .overlay(
                        Circle().stroke(Color.white.opacity(0.15), lineWidth: 1)
                    )
            }

            Spacer()

            Text("Matched Diners")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            Spacer()

            Button(action: onReset) {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(Color.white.opacity(0.12))
                    .clipShape(Circle())
                    .overlay(
                        Circle().stroke(Color.white.opacity(0.15), lineWidth: 1)
                    )
            }
        }
        .padding(.horizontal, 20)
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
                .frame(height: 70)
                .shadow(color: .black.opacity(0.25), radius: 6, x: 0, y: 4)

            Text("THE PODIUM")
                .font(.uiLabel(size: 11, weight: .black))
                .foregroundColor(.terracottaOrange)
                .tracking(3)
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Reusable Custom Card Layout Container

struct ResultsCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .frame(maxWidth: .infinity, alignment: .leading)
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
            .shadow(color: Color.black.opacity(0.25), radius: 10, x: 0, y: 6)
            .padding(.horizontal, 16)
    }
}

// MARK: - Helpers

private func getStampAsset(for award: AwardTag) -> String {
    switch award {
    case .goldMedalist: return "stamp_gold_medalist"
    case .budgetSaver: return "stamp_budget_saver"
    case .foodieFavorite: return "stamp_foodie_favorite"
    case .fairCommute: return "stamp_fair_commute"
    }
}

private func getCuisineImage(for name: String) -> String {
    let lower = name.lowercased()
    if lower.contains("pizza") || lower.contains("pasta") || lower.contains("italian") || lower.contains("toscano") {
        return "cuisine_italian"
    } else if lower.contains("burger") || lower.contains("american") || lower.contains("deli") {
        return "cuisine_american"
    } else if lower.contains("sushi") || lower.contains("japanese") || lower.contains("ramen") {
        return "cuisine_japanese"
    } else if lower.contains("dim sum") || lower.contains("chinese") || lower.contains("wok") || lower.contains("mandarin") {
        return "cuisine_chinese"
    } else if lower.contains("tandoori") || lower.contains("indian") || lower.contains("curry") || lower.contains("punjab") {
        return "cuisine_north_indian"
    } else if lower.contains("taco") || lower.contains("mexican") || lower.contains("burrito") {
        return "cuisine_mexican"
    } else if lower.contains("mediterranean") || lower.contains("greek") || lower.contains("olive") {
        return "cuisine_mediterranean"
    } else if lower.contains("dosa") || lower.contains("idli") || lower.contains("south") {
        return "cuisine_south_indian"
    } else {
        return "cuisine_continental"
    }
}

// MARK: - 1. Compact Leaderboard Awards Scroll

private struct LeaderboardAwardsSection: View {
    let leaderboard: Leaderboard

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                if let gold = leaderboard.goldMedalist {
                    LeaderboardPill(icon: "🏆", category: "Gold Medalist", name: gold, color: .goldStamp)
                }
                if let budget = leaderboard.budgetSaver {
                    LeaderboardPill(icon: "💰", category: "Budget Saver", name: budget, color: .budgetStamp)
                }
                if let foodie = leaderboard.foodieFavorite {
                    LeaderboardPill(icon: "❤️", category: "Foodie Favorite", name: foodie, color: .foodieStamp)
                }
                if let commute = leaderboard.fairCommute {
                    LeaderboardPill(icon: "🚗", category: "Fair Commute", name: commute, color: .blue)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 4)
        }
    }
}

private struct LeaderboardPill: View {
    let icon: String
    let category: String
    let name: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 8) {
            Text(icon)
                .font(.system(size: 14))
            VStack(alignment: .leading, spacing: 2) {
                Text(category.uppercased())
                    .font(.uiLabel(size: 8, weight: .black))
                    .foregroundColor(color)
                    .tracking(0.5)
                Text(name)
                    .font(.editorialSubheader(size: 13))
                    .foregroundColor(.carbonInk)
                    .lineLimit(1)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.85))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.12), radius: 4, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.carbonInk.opacity(0.06), lineWidth: 1)
        )
    }
}

// MARK: - 2. Top Choices Consolidated Card

private struct TopChoicesSection: View {
    let topChoices: [TopChoice]
    @Binding var expandedRestaurant: String?

    var body: some View {
        ResultsCard {
            VStack(alignment: .leading, spacing: 0) {
                // Card Title Header
                HStack {
                    Image(systemName: "crown.fill")
                        .foregroundColor(.goldStamp)
                        .font(.subheadline)
                    Text("TOP RECOMMENDATIONS")
                        .font(.uiLabel(size: 12, weight: .black))
                        .foregroundColor(.carbonInk)
                        .tracking(1.5)
                    Spacer()
                    
                    // Styled Wax Seal Accent
                    Image("ui_wax_seal_red")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 32, height: 32)
                        .shadow(color: Color.black.opacity(0.15), radius: 2, x: 0, y: 1.5)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 16)
                
                Divider()
                    .background(Color.carbonInk.opacity(0.08))
                    .padding(.horizontal, 20)
                
                // List of Top 3 Choices
                VStack(spacing: 0) {
                    ForEach(Array(topChoices.prefix(3).enumerated()), id: \.element.id) { index, restaurant in
                        VStack(spacing: 0) {
                            PodiumRowView(
                                rank: index + 1,
                                restaurant: restaurant,
                                isExpanded: expandedRestaurant == restaurant.id
                            )
                            .onTapGesture {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                                    expandedRestaurant = (expandedRestaurant == restaurant.id) ? nil : restaurant.id
                                }
                            }
                            
                            if index < min(2, topChoices.count - 1) {
                                Divider()
                                    .background(Color.carbonInk.opacity(0.06))
                                    .padding(.leading, 68)
                            }
                        }
                    }
                }
            }
        }
    }
}

struct PodiumRowView: View {
    let rank: Int
    let restaurant: TopChoice
    let isExpanded: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 16) {
                // Rank Number
                Text(String(format: "%02d", rank))
                    .font(.editorialHeader(size: 26))
                    .foregroundColor(rank == 1 ? .terracottaOrange : .carbonInk.opacity(0.35))
                    .frame(width: 32, alignment: .leading)
                    .padding(.top, 2)
                
                // Restaurant Info
                VStack(alignment: .leading, spacing: 6) {
                    Text(restaurant.name)
                        .font(.editorialHeader(size: 18))
                        .foregroundColor(.carbonInk)
                    
                    HStack(spacing: 12) {
                        HStack(spacing: 3) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.goldStamp)
                                .font(.caption2)
                            Text(String(format: "%.1f", restaurant.rating))
                                .font(.uiNumber(size: 12, weight: .bold))
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
                    
                    // Safety tags
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
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.foodieStamp.opacity(0.08))
                                .cornerRadius(4)
                            }
                        }
                    }
                }
                
                Spacer()
                
                // Award and chevron
                VStack(alignment: .trailing, spacing: 8) {
                    if let award = restaurant.awardTag {
                        // Compact stamp indicator in list
                        Image(getStampAsset(for: award))
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 36, height: 36)
                            .rotationEffect(.degrees(-5))
                    } else {
                        Spacer().frame(width: 36, height: 36)
                    }
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.carbonInk.opacity(0.3))
                        .padding(.top, 4)
                }
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
            .background(isExpanded ? Color.carbonInk.opacity(0.02) : Color.clear)
            
            // Expanded Info
            if isExpanded {
                VStack(alignment: .leading, spacing: 16) {
                    Divider()
                        .background(Color.carbonInk.opacity(0.08))
                        .padding(.horizontal, 20)
                    
                    // High-fidelity Cuisine Cover Image + Stamp Overlay
                    ZStack(alignment: .topTrailing) {
                        let cuisineImageName = getCuisineImage(for: restaurant.name)
                        Image(cuisineImageName)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 130)
                            .clipped()
                            .cornerRadius(10)
                            .padding(.horizontal, 20)
                            .padding(.top, 4)
                        
                        // Stamp Overlay (realistic paper-stamped ink look)
                        if let award = restaurant.awardTag {
                            Image(getStampAsset(for: award))
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 80, height: 80)
                                .rotationEffect(.degrees(12))
                                .shadow(color: Color.black.opacity(0.18), radius: 3, x: 1, y: 2)
                                .offset(x: -8, y: -6)
                        }
                    }
                    
                    // 1. Fit context block (typewriter callout style)
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 6) {
                            Image(systemName: "quote.opening")
                                .font(.caption2)
                                .foregroundColor(.terracottaOrange)
                            Text("WHY IT FITS")
                                .font(.uiLabel(size: 10, weight: .black))
                                .foregroundColor(.terracottaOrange)
                                .tracking(1)
                        }
                        
                        Text(restaurant.groupFitContext.headlineWhyItFits)
                            .font(.editorialSubheader(size: 14))
                            .foregroundColor(.carbonInk)
                            .lineSpacing(2)
                            .italic()
                        
                        Text(restaurant.groupFitContext.individualCravingMatches)
                            .font(.uiLabel(size: 12))
                            .foregroundColor(.carbonInk.opacity(0.65))
                            .lineSpacing(2)
                    }
                    .padding(14)
                    .background(Color.inkPaper.opacity(0.7))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.carbonInk.opacity(0.06), lineWidth: 1)
                    )
                    .padding(.horizontal, 20)
                    
                    // 2. Vibe alignment
                    VStack(alignment: .leading, spacing: 4) {
                        Text("VIBE & WALLET ALIGNMENT")
                            .font(.uiLabel(size: 10, weight: .black))
                            .foregroundColor(.carbonInk.opacity(0.8))
                            .tracking(0.5)
                        
                        Text(restaurant.groupFitContext.vibeAndCardAlignment)
                            .font(.uiLabel(size: 12))
                            .foregroundColor(.carbonInk.opacity(0.65))
                            .lineSpacing(2)
                    }
                    .padding(.horizontal, 20)
                    
                    // 3. CC Perks
                    if !restaurant.appliedWalletPromotions.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("CREDIT CARD PERKS")
                                .font(.uiLabel(size: 10, weight: .black))
                                .foregroundColor(.budgetStamp)
                                .tracking(0.5)
                            
                            ForEach(restaurant.appliedWalletPromotions, id: \.self) { promo in
                                HStack(spacing: 6) {
                                    Image(systemName: "checkmark.seal.fill")
                                        .font(.caption2)
                                        .foregroundColor(.budgetStamp)
                                    Text(promo)
                                        .font(.uiLabel(size: 12, weight: .semibold))
                                        .foregroundColor(.carbonInk.opacity(0.85))
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // 4. Commute Table
                    VStack(alignment: .leading, spacing: 8) {
                        Text("COMMUTE TIMES")
                            .font(.uiLabel(size: 10, weight: .black))
                            .foregroundColor(.carbonInk.opacity(0.8))
                            .tracking(0.5)
                        
                        VStack(spacing: 8) {
                            ForEach(restaurant.playerCommuteBreakdown.sorted(by: { $0.key < $1.key }), id: \.key) { name, minutes in
                                HStack {
                                    Text(name)
                                        .font(.uiLabel(size: 12))
                                        .foregroundColor(.carbonInk.opacity(0.6))
                                    Spacer()
                                    Text("\(minutes) mins")
                                        .font(.uiNumber(size: 12, weight: .bold))
                                        .foregroundColor(.carbonInk)
                                }
                            }
                        }
                        .padding(12)
                        .background(Color.carbonInk.opacity(0.03))
                        .cornerRadius(8)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
                .background(Color.carbonInk.opacity(0.01))
            }
        }
    }
}

// MARK: - 3. Smart Tradeoffs (Unified Card)

private struct SmartTradeoffsSection: View {
    let tradeoffs: [SmartTradeoff]

    var body: some View {
        if !tradeoffs.isEmpty {
            ResultsCard {
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        Image(systemName: "arrow.left.and.right.circle.fill")
                            .foregroundColor(.terracottaOrange)
                            .font(.subheadline)
                        Text("AI SMART TRADEOFFS")
                            .font(.uiLabel(size: 12, weight: .black))
                            .foregroundColor(.carbonInk)
                            .tracking(1.5)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 18)
                    
                    Divider()
                        .background(Color.carbonInk.opacity(0.08))
                        .padding(.horizontal, 20)
                    
                    VStack(spacing: 12) {
                        ForEach(tradeoffs) { tradeoff in
                             HStack(alignment: .top, spacing: 12) {
                                 RoundedRectangle(cornerRadius: 2)
                                     .fill(Color.terracottaOrange.opacity(0.4))
                                     .frame(width: 3.5, height: 42)
                                 
                                 Text(tradeoff.uiCopy)
                                     .font(.uiLabel(size: 12, weight: .medium))
                                     .foregroundColor(.carbonInk.opacity(0.8))
                                     .lineSpacing(2)
                             }
                             .padding(12)
                             .frame(maxWidth: .infinity, alignment: .leading)
                             .background(Color.terracottaOrange.opacity(0.04))
                             .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
        }
    }
}

// MARK: - 4. Alternative Suggestions

private struct AlternativeSuggestionsSection: View {
    let alternatives: [AlternativeSuggestion]
    @Binding var expandedRestaurant: String?

    var body: some View {
        if !alternatives.isEmpty {
            ResultsCard {
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Image(systemName: "list.bullet.circle.fill")
                            .foregroundColor(.carbonInk)
                            .font(.subheadline)
                        Text("ALTERNATIVE RECOMMENDATIONS")
                            .font(.uiLabel(size: 12, weight: .black))
                            .foregroundColor(.carbonInk)
                            .tracking(1.5)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 16)
                    
                    Divider()
                        .background(Color.carbonInk.opacity(0.08))
                        .padding(.horizontal, 20)
                    
                    VStack(spacing: 0) {
                        ForEach(Array(alternatives.enumerated()), id: \.element.id) { index, restaurant in
                            VStack(spacing: 0) {
                                AlternativeRowView(
                                    restaurant: restaurant,
                                    isExpanded: expandedRestaurant == restaurant.id
                                )
                                .onTapGesture {
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                                        expandedRestaurant = (expandedRestaurant == restaurant.id) ? nil : restaurant.id
                                    }
                                }
                                
                                if index < alternatives.count - 1 {
                                    Divider()
                                        .background(Color.carbonInk.opacity(0.06))
                                        .padding(.leading, 20)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

struct AlternativeRowView: View {
    let restaurant: AlternativeSuggestion
    let isExpanded: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(restaurant.name)
                        .font(.editorialHeader(size: 16))
                        .foregroundColor(.carbonInk.opacity(0.9))
                    
                    HStack(spacing: 12) {
                        HStack(spacing: 3) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.goldStamp)
                                .font(.caption2)
                            Text(String(format: "%.1f", restaurant.rating))
                                .font(.uiNumber(size: 11, weight: .bold))
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
                
                HStack(spacing: 10) {
                    if let award = restaurant.awardTag {
                        // Compact stamp indicator in list
                        Image(getStampAsset(for: award))
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 28, height: 28)
                            .rotationEffect(.degrees(-5))
                    }
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.carbonInk.opacity(0.3))
                }
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 20)
            .background(isExpanded ? Color.carbonInk.opacity(0.02) : Color.clear)
            
            if isExpanded {
                VStack(alignment: .leading, spacing: 14) {
                    Divider()
                        .background(Color.carbonInk.opacity(0.08))
                        .padding(.horizontal, 20)
                    
                    // High-fidelity Cuisine Cover Image + Stamp Overlay
                    ZStack(alignment: .topTrailing) {
                        let cuisineImageName = getCuisineImage(for: restaurant.name)
                        Image(cuisineImageName)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 110)
                            .clipped()
                            .cornerRadius(10)
                            .padding(.horizontal, 20)
                            .padding(.top, 4)
                        
                        // Stamp Overlay
                        if let award = restaurant.awardTag {
                            Image(getStampAsset(for: award))
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 65, height: 65)
                                .rotationEffect(.degrees(12))
                                .shadow(color: Color.black.opacity(0.18), radius: 2.5, x: 1, y: 1.5)
                                .offset(x: -8, y: -4)
                        }
                    }
                    
                    // Why it fits
                    VStack(alignment: .leading, spacing: 8) {
                        Text("WHY IT FITS")
                            .font(.uiLabel(size: 9, weight: .black))
                            .foregroundColor(.terracottaOrange)
                            .tracking(1)
                        Text(restaurant.groupFitContext.headlineWhyItFits)
                            .font(.editorialSubheader(size: 13))
                            .foregroundColor(.carbonInk)
                        Text(restaurant.groupFitContext.individualCravingMatches)
                            .font(.uiLabel(size: 12))
                            .foregroundColor(.carbonInk.opacity(0.65))
                            .lineSpacing(2)
                    }
                    .padding(.horizontal, 20)
                    
                    // Vibe
                    VStack(alignment: .leading, spacing: 4) {
                        Text("VIBE & WALLET ALIGNMENT")
                            .font(.uiLabel(size: 9, weight: .black))
                            .foregroundColor(.carbonInk.opacity(0.8))
                            .tracking(0.5)
                        Text(restaurant.groupFitContext.vibeAndCardAlignment)
                            .font(.uiLabel(size: 12))
                            .foregroundColor(.carbonInk.opacity(0.65))
                            .lineSpacing(2)
                    }
                    .padding(.horizontal, 20)
                    
                    // Commute
                    VStack(alignment: .leading, spacing: 6) {
                        Text("COMMUTE TIMES")
                            .font(.uiLabel(size: 9, weight: .black))
                            .foregroundColor(.carbonInk.opacity(0.8))
                            .tracking(0.5)
                        
                        VStack(spacing: 6) {
                            ForEach(restaurant.playerCommuteBreakdown.sorted(by: { $0.key < $1.key }), id: \.key) { name, minutes in
                                HStack {
                                    Text(name)
                                        .font(.uiLabel(size: 11))
                                        .foregroundColor(.carbonInk.opacity(0.6))
                                    Spacer()
                                    Text("\(minutes) mins")
                                        .font(.uiNumber(size: 11, weight: .bold))
                                        .foregroundColor(.carbonInk)
                                }
                            }
                        }
                        .padding(10)
                        .background(Color.carbonInk.opacity(0.03))
                        .cornerRadius(8)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)
                }
                .background(Color.carbonInk.opacity(0.01))
            }
        }
    }
}

// MARK: - 5. Collapsible Disqualified Contenders

private struct DisqualifiedVenuesSection: View {
    let venues: [DisqualifiedVenue]
    @State private var isCollapsed = true

    var body: some View {
        if !venues.isEmpty {
            VStack(spacing: 0) {
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        isCollapsed.toggle()
                    }
                }) {
                    HStack {
                        // Stamp icon replacement
                        Image("stamp_disqualified")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                            .padding(.trailing, 2)
                        
                        Text("DISQUALIFIED CONTENDERS (\(venues.count))")
                            .font(.uiLabel(size: 11, weight: .black))
                            .foregroundColor(.carbonInk)
                            .tracking(1)
                        Spacer()
                        Image(systemName: isCollapsed ? "chevron.down" : "chevron.up")
                            .font(.caption2)
                            .foregroundColor(.carbonInk.opacity(0.4))
                    }
                    .padding(16)
                }
                .buttonStyle(PlainButtonStyle())
                
                if !isCollapsed {
                    Divider()
                        .background(Color.carbonInk.opacity(0.08))
                        .padding(.horizontal, 16)
                    
                    VStack(spacing: 12) {
                        ForEach(venues) { venue in
                            DisqualifiedVenueRow(venue: venue)
                            if venue.id != venues.last?.id {
                                Divider().background(Color.subtleDottedLine)
                            }
                        }
                    }
                    .padding(16)
                    .transition(.opacity)
                }
            }
            .background(Color.white.opacity(0.95))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.12), radius: 4, x: 0, y: 2)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.carbonInk.opacity(0.08), lineWidth: 1)
            )
            .padding(.horizontal, 16) // Pad to align with ResultsCard
        }
    }
}

private struct DisqualifiedVenueRow: View {
    let venue: DisqualifiedVenue

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image("stamp_disqualified")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 44, height: 44)
                .rotationEffect(.degrees(-8))

            VStack(alignment: .leading, spacing: 4) {
                Text(venue.name)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.carbonInk)
                Text(venue.primaryReasonForDisqualification)
                    .font(.uiLabel(size: 12))
                    .foregroundColor(.foodieStamp.opacity(0.85))
                    .lineSpacing(2)
            }
            Spacer()
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
                .foregroundColor(.carbonInk.opacity(0.5))
        }
    }
}

// MARK: - Start New Table Button

private struct StartNewTableButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("Start a New Table")
                .font(.uiLabel(size: 14, weight: .black))
                .foregroundColor(.inkPaper)
                .tracking(1)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.carbonInk)
                .cornerRadius(12)
                .shadow(color: Color.carbonInk.opacity(0.3), radius: 6, x: 0, y: 3)
                .padding(.horizontal, 16) // Pad to align with ResultsCard
        }
        .padding(.bottom, 40)
    }
}
