import Foundation

struct MockData {
    static let venueRecommendation = VenueRecommendationResponse(
        topChoices: [
            TopChoice(
                rankingPosition: 1,
                name: "Gusto Italiano",
                rating: 4.8,
                travelTimeVarianceMinutes: 5,
                appliedWalletPromotions: ["10% Group Discount", "Free Appetizer via Amex Gold"],
                safetyWarningTags: ["Very Busy at 8 PM"],
                playerCommuteBreakdown: ["Alice": 12, "Bob": 15, "Charlie": 8],
                awardTag: .goldMedalist,
                groupFitContext: GroupFitContext(
                    headlineWhyItFits: "Perfect consensus: matches Alice's craving for pasta & Bob's budget.",
                    individualCravingMatches: "Alice wanted Italian (100% match). Charlie wanted wine options (8/10 match).",
                    vibeAndCardAlignment: "Saves the group 15% overall via collaborative wallet optimization."
                )
            ),
            TopChoice(
                rankingPosition: 2,
                name: "Sushi Zen",
                rating: 4.6,
                travelTimeVarianceMinutes: 12,
                appliedWalletPromotions: ["BOGO Draft Beer"],
                safetyWarningTags: [],
                playerCommuteBreakdown: ["Alice": 20, "Bob": 8, "Charlie": 15],
                awardTag: .foodieFavorite,
                groupFitContext: GroupFitContext(
                    headlineWhyItFits: "High-grade sushi with an intimate atmosphere that Bob loves.",
                    individualCravingMatches: "Bob got his sashimi fix. Charlie's vibe request matches perfectly.",
                    vibeAndCardAlignment: "Utilizes Bob's local dining perk for free edamame."
                )
            ),
            TopChoice(
                rankingPosition: 3,
                name: "The Green Tavern",
                rating: 4.5,
                travelTimeVarianceMinutes: 4,
                appliedWalletPromotions: ["$5 off over $30"],
                safetyWarningTags: ["Limited parking"],
                playerCommuteBreakdown: ["Alice": 10, "Bob": 10, "Charlie": 10],
                awardTag: .fairCommute,
                groupFitContext: GroupFitContext(
                    headlineWhyItFits: "Equidistant for all diners with a solid casual American menu.",
                    individualCravingMatches: "Everyone gets a healthy selection, satisfying Charlie's vegan requirement.",
                    vibeAndCardAlignment: "Basic card cashbacks apply (3% back)."
                )
            )
        ],
        alternativeSuggestions: [
            AlternativeSuggestion(
                name: "Taco Express",
                rating: 4.2,
                travelTimeVarianceMinutes: 8,
                playerCommuteBreakdown: ["Alice": 5, "Bob": 18, "Charlie": 12],
                awardTag: .budgetSaver,
                groupFitContext: GroupFitContext(
                    headlineWhyItFits: "Extremely affordable option under $15 per person.",
                    individualCravingMatches: "Fast-casual tacos, fits Bob's budget preference perfectly.",
                    vibeAndCardAlignment: "No active promotions, but base price is low."
                )
            ),
            AlternativeSuggestion(
                name: "Le Bistrot",
                rating: 4.4,
                travelTimeVarianceMinutes: 18,
                playerCommuteBreakdown: ["Alice": 22, "Bob": 25, "Charlie": 10],
                awardTag: nil,
                groupFitContext: GroupFitContext(
                    headlineWhyItFits: "Classic French cozy bistro, though a bit out of the way.",
                    individualCravingMatches: "Charlie's top choice for romantic vibes, but long travel time for Bob.",
                    vibeAndCardAlignment: "2% dining rewards on premium travel cards."
                )
            )
        ],
        disqualifiedVenues: [
            DisqualifiedVenue(
                name: "Burger Joint",
                primaryReasonForDisqualification: "Exceeds the group budget limit ($45/person vs $30/person limit)."
            ),
            DisqualifiedVenue(
                name: "Pizzeria Napoletana",
                primaryReasonForDisqualification: "Closed on Sundays (the selected day for this meetup)."
            ),
            DisqualifiedVenue(
                name: "Spice Symphony",
                primaryReasonForDisqualification: "Too far for Alice (commute time would exceed 45 minutes)."
            )
        ],
        leaderboard: Leaderboard(
            goldMedalist: "Gusto Italiano",
            budgetSaver: "Taco Express",
            foodieFavorite: "Sushi Zen",
            fairCommute: "The Green Tavern"
        ),
        smartTradeoffs: [
            SmartTradeoff(
                premiumChoice: "Sushi Zen",
                valueAlternative: "Taco Express",
                savingsPerPerson: 18,
                uiCopy: "Switching from Sushi Zen to Taco Express saves the group $18 per person, with only a 0.4 drop in rating."
            ),
            SmartTradeoff(
                premiumChoice: "Gusto Italiano",
                valueAlternative: "The Green Tavern",
                savingsPerPerson: 8,
                uiCopy: "The Green Tavern reduces average commute variance by 4 minutes compared to Gusto Italiano, but has a slightly lower rating."
            )
        ]
    )
}
