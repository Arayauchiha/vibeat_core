import Foundation

// MARK: - AwardTag

enum AwardTag: String, Codable {
    case goldMedalist = "gold_medalist"
    case budgetSaver = "budget_saver"
    case foodieFavorite = "foodie_favorite"
    case fairCommute = "fair_commute"
}

// MARK: - GroupFitContext

struct GroupFitContext: Codable {
    let headlineWhyItFits: String
    let individualCravingMatches: String
    let vibeAndCardAlignment: String

    enum CodingKeys: String, CodingKey {
        case headlineWhyItFits = "headline_why_it_fits"
        case individualCravingMatches = "individual_craving_matches"
        case vibeAndCardAlignment = "vibe_and_card_alignment"
    }
}

// MARK: - TopChoice

struct TopChoice: Identifiable, Codable {
    var id: String {
        name
    }
    let rankingPosition: Int
    let name: String
    let rating: Double
    let travelTimeVarianceMinutes: Int
    let appliedWalletPromotions: [String]
    let safetyWarningTags: [String]
    let playerCommuteBreakdown: [String: Int]
    let awardTag: AwardTag?
    let groupFitContext: GroupFitContext

    enum CodingKeys: String, CodingKey {
        case rankingPosition = "ranking_position"
        case name
        case rating
        case travelTimeVarianceMinutes = "travel_time_variance_minutes"
        case appliedWalletPromotions = "applied_wallet_promotions"
        case safetyWarningTags = "safety_warning_tags"
        case playerCommuteBreakdown = "player_commute_breakdown"
        case awardTag = "award_tag"
        case groupFitContext = "group_fit_context"
    }
}

// MARK: - AlternativeSuggestion

struct AlternativeSuggestion: Identifiable, Codable {
    var id: String {
        name
    }
    let name: String
    let rating: Double
    let travelTimeVarianceMinutes: Int
    let playerCommuteBreakdown: [String: Int]
    let awardTag: AwardTag?
    let groupFitContext: GroupFitContext

    enum CodingKeys: String, CodingKey {
        case name
        case rating
        case travelTimeVarianceMinutes = "travel_time_variance_minutes"
        case playerCommuteBreakdown = "player_commute_breakdown"
        case awardTag = "award_tag"
        case groupFitContext = "group_fit_context"
    }
}

// MARK: - DisqualifiedVenue

struct DisqualifiedVenue: Identifiable, Codable {
    let name: String
    var id: String {
        name
    }
    let primaryReasonForDisqualification: String

    enum CodingKeys: String, CodingKey {
        case name
        case primaryReasonForDisqualification = "primary_reason_for_disqualification"
    }
}

// MARK: - Leaderboard

struct Leaderboard: Codable {
    let goldMedalist: String?
    let budgetSaver: String?
    let foodieFavorite: String?
    let fairCommute: String?

    enum CodingKeys: String, CodingKey {
        case goldMedalist = "gold_medalist"
        case budgetSaver = "budget_saver"
        case foodieFavorite = "foodie_favorite"
        case fairCommute = "fair_commute"
    }
}

// MARK: - SmartTradeoff

struct SmartTradeoff: Identifiable, Codable {
    var id: UUID {
        UUID()
    }
    let premiumChoice: String
    let valueAlternative: String
    let savingsPerPerson: Int
    let uiCopy: String

    enum CodingKeys: String, CodingKey {
        case premiumChoice = "premium_choice"
        case valueAlternative = "value_alternative"
        case savingsPerPerson = "savings_per_person"
        case uiCopy = "ui_copy"
    }
}

// MARK: - VenueRecommendationResponse

struct VenueRecommendationResponse: Codable {
    let topChoices: [TopChoice]
    let alternativeSuggestions: [AlternativeSuggestion]
    let disqualifiedVenues: [DisqualifiedVenue]
    let leaderboard: Leaderboard
    let smartTradeoffs: [SmartTradeoff]

    enum CodingKeys: String, CodingKey {
        case topChoices = "top_choices"
        case alternativeSuggestions = "alternative_suggestions"
        case disqualifiedVenues = "disqualified_venues"
        case leaderboard
        case smartTradeoffs = "smart_tradeoffs"
    }
}
