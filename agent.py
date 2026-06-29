import json
import os

from azure.ai.inference import ChatCompletionsClient
from azure.core.credentials import AzureKeyCredential

from tools import (
    call_mapbox_travel_matrix,
    fetch_live_swiggy_dineout_venues,
    compile_vibe_document,
    cosine_similarity,
    fetch_vibe_embeddings,
)


async def run_vibeat_orchestrator(matrix_payload: dict) -> dict:
    """
    Core AI Orchestration Layer. Parses group parameters dynamically
    and handles missing structural payload variables gracefully.
    """
    # 🌟 TSK-01 / Senior Refactor: Validate token ONLY when orchestrator is invoked
    github_token = os.environ.get("GITHUB_TOKEN")
    if not github_token:
        print(
            "❌ ERROR: GITHUB_TOKEN environment variable is missing in active execution scope!"
        )
        return {
            "status": "error",
            "message": "Backend environment unconfigured: Missing GITHUB_TOKEN.",
        }

    # Instantiated on call inside function boundary scope
    client = ChatCompletionsClient(
        endpoint="https://models.inference.ai.azure.com",
        credential=AzureKeyCredential(github_token),
    )

    metadata = matrix_payload.get("starting_calculation_metadata", {})
    players = matrix_payload.get("raw_player_starting_points", [])
    cravings = matrix_payload.get("group_cravings_profile", {})

    # 🌟 TSK-03: Dynamically extract top cuisine to pass to Swiggy API query slot
    target_query = "food"
    rankings = cravings.get("weighted_cuisine_rankings", [])
    if rankings and isinstance(rankings, list):
        target_query = rankings[0].get("cuisine", "food")

    # Dynamic protection query fallback in case engine.py strips spatial keys
    if "initial_latitude" in metadata and "initial_longitude" in metadata:
        lat = metadata["initial_latitude"]
        lng = metadata["initial_longitude"]
    elif players:
        lat = players[0]["lat"]
        lng = players[0]["lng"]
    else:
        lat, lng = 28.6139, 77.2090  # Absolute root staging anchor fallback

    # Pass dynamic query down to Swiggy client layer
    raw_venues = await fetch_live_swiggy_dineout_venues(
        latitude=lat, longitude=lng, search_query=target_query
    )
    target_epoch = metadata.get("target_party_epoch_seconds")

    # 🌟 Vibe Embedding Calculations
    if raw_venues:
        vibe_sentiments = cravings.get("vibe_tags_sentiment", [])
        cravings_list = cravings.get("specific_target_dishes", [])
        cuisines_list = [r.get("cuisine", "") for r in rankings]
        
        vibe_query_parts = []
        if vibe_sentiments:
            vibe_query_parts.append(f"Atmosphere: {', '.join(vibe_sentiments)}")
        if cravings_list:
            vibe_query_parts.append(f"Cravings: {', '.join(cravings_list)}")
        if cuisines_list:
            vibe_query_parts.append(f"Cuisines: {', '.join(cuisines_list)}")
            
        vibe_query = ". ".join(vibe_query_parts) if vibe_query_parts else "Good food and pleasant atmosphere"
        
        venue_vibe_docs = [compile_vibe_document(v) for v in raw_venues]
        all_texts = [vibe_query] + venue_vibe_docs
        
        embeddings = await fetch_vibe_embeddings(all_texts, github_token)
        if embeddings and len(embeddings) == len(all_texts):
            query_vector = embeddings[0]
            venue_vectors = embeddings[1:]
            for idx, venue in enumerate(raw_venues):
                similarity = cosine_similarity(query_vector, venue_vectors[idx])
                venue["vibe_match_score"] = round(similarity, 3)
        else:
            for venue in raw_venues:
                venue["vibe_match_score"] = 0.5
    else:
        pass

    commute_durations = call_mapbox_travel_matrix(
        player_points=players, target_venues=raw_venues, departure_time=target_epoch
    )

    real_world_context = {
        "available_swiggy_dineout_venues": raw_venues,
        "historical_predictive_commute_durations_minutes": commute_durations,
    }

    system_instruction = (
        "You are the Flagship Core AI Agent Engine for 'Vibeat' (Swiggy Builders Club Production Layer).\n"
        "Your goal is to parse player arrays, Swiggy listings, and travel time matrices and return a single, strictly valid raw JSON object matching the Swiggy Spec keys natively. "
        "Do NOT return any markdown wrapping, code block formatting, backticks, or text outside the JSON structure.\n\n"
        "CRITICAL ARCHITECTURE RULES TO ENFORCE:\n"
        "1. ABSOLUTE DISQUALIFICATION TRIAGE (HARD GATE):\n"
        "   - Read 'is_predefined_location' and 'travel_variance_mode' from 'starting_calculation_metadata'.\n"
        "   - Calculate Travel Variance for each venue: Max Travel Time - Min Travel Time across all players.\n"
        "   - If 'is_predefined_location' is True, DO NOT disqualify any venue for high travel variance (regardless of how far any player travels).\n"
        "   - If 'is_predefined_location' is False, apply variance limits based on 'travel_variance_mode':\n"
        "     * 'strict': Disqualify if Travel Variance > 20 minutes.\n"
        "     * 'default': Disqualify if Travel Variance > 45 minutes.\n"
        "     * 'perfect_vibe_only': DO NOT disqualify any venue for travel variance.\n"
        "   - Budget Disqualification: If a venue's average cost per person (costForTwo / 2) exceeds any player's budget cap, check if any group member's card can unlock a discount to bring it under the cap. If not, it must be placed in 'disqualified_venues'.\n"
        "   - CRITICAL: A venue placed in 'disqualified_venues' CANNOT, under any circumstances, appear in 'top_choices' or 'alternative_suggestions'.\n\n"
        "2. CARD DISCOUNT ATTRIBUTION & ALCOHOL THRESHOLDS:\n"
        "   - The 'group_payment_cards_wallet' is a dictionary mapping player names to their cards (e.g. {'Aryan': ['HDFC']}).\n"
        "   - Scan the venue's 'offers' array (e.g., '20% off using HDFC Cards'). If any group member has the required card, apply it: list the deal in 'applied_wallet_promotions', and credit them in the 'group_fit_context' text.\n"
        "   - Evaluate the native 'isAlcoholServed' boolean flag. If alcohol interest ratio < 0.40 and the venue is dry, allow it but append an explicit tag.\n\n"
        "3. SOCIAL PRIVACY BUDGET RULE:\n"
        "   - When explaining budget alignment in 'group_fit_context', frame it collectively (e.g., 'fits the group\\'s budget criteria' or 'fits everyone\\'s budget').\n"
        "   - NEVER mention any player's name regarding budget caps or having a lower budget. Maintain complete social privacy.\n"
        "   - Praise the cardholder by name for the discount (e.g., 'Because Aryan has an HDFC Card, the group gets a 20% discount, making it fit everyone\\'s budget!').\n\n"
        "4. DYNAMIC SCORING, LEADERBOARDS & THE SMART LIST PRESENTATION LAYER:\n"
        "   - Score all valid, non-disqualified venues natively utilizing their 'rating' and 'reviewCount' metrics, combined with the pre-calculated 'vibe_match_score' (acting as a primary ranking multiplier/weight where a higher vibe boosts the score and lower vibe pulls it down, but never disqualifies the venue).\n"
        "   - Sort all valid venues cleanly by their final score.\n"
        "   - Take the top 3 highest scoring venues and place them in the 'top_choices' array.\n"
        "   - Place all other remaining valid venues into the 'alternative_suggestions' array.\n"
        "   - Identify and assign exactly one non-disqualified venue to each of the following 'award_tag' categories (can appear in 'top_choices' or 'alternative_suggestions'):\n"
        "     * 'gold_medalist': Best overall score balancing vibe, budget, rating, and commute.\n"
        "     * 'budget_saver': Maximizes card discounts (highest percentage or absolute save) and under budget caps.\n"
        "     * 'foodie_favorite': Highest customer rating on Swiggy Dineout (average rating and review count).\n"
        "     * 'fair_commute': Lowest travel time variance between players.\n"
        "   - Add the assigned value as an 'award_tag' field (string or null) on the respective venue objects.\n"
        "   - Provide a root-level 'leaderboard' dictionary mapping these four categories to the selected venue names.\n\n"
        "5. SMART VALUE-VIBE TRADE-OFF DETECTION:\n"
        "   - Identify cases where a venue in 'alternative_suggestions' is significantly cheaper (>35% cost savings per person) but maintains a very similar vibe match (its 'vibe_match_score' is within 0.15 of a top choice venue's score).\n"
        "   - If found, populate the root-level 'smart_tradeoffs' array. Provide the premium venue name, the cheap alternative venue name, the savings amount per person, and a friendly action-oriented message for the UI (e.g. 'Swap to Skydeck Lounge: Saves ₹600 per person with a similar cozy rooftop atmosphere!').\n\n"
        "6. HYPER-PERSONALIZED GROUP CONTEXT COPYWRITING:\n"
        "   - For every recommended venue, you must construct a detailed 'group_fit_context' object connecting the dots using player names.\n\n"
        "OUTPUT JSON STRUCTURAL SCHEMA REQUIREMENT (NATIVE SWIGGY DOCKING):\n"
        "{\n"
        '  "top_choices": [\n'
        "    {\n"
        '      "ranking_position": 1,\n'
        '      "name": "string",\n'
        '      "rating": 0.0,\n'
        '      "travel_time_variance_minutes": 0,\n'
        '      "applied_wallet_promotions": ["string"],\n'
        '      "safety_warning_tags": ["string"],\n'
        '      "player_commute_breakdown": { "playerName": 0 },\n'
        '      "award_tag": "gold_medalist | budget_saver | foodie_favorite | fair_commute | null",\n'
        '      "group_fit_context": {\n'
        '        "headline_why_it_fits": "string",\n'
        '        "individual_craving_matches": "string",\n'
        '        "vibe_and_card_alignment": "string"\n'
        '      }\n'
        '    }\n'
        '  ],\n'
        '  "alternative_suggestions": [\n'
        '    {\n'
        '      "name": "string",\n'
        '      "rating": 0.0,\n'
        '      "travel_time_variance_minutes": 0,\n'
        '      "player_commute_breakdown": { "playerName": 0 },\n'
        '      "award_tag": "gold_medalist | budget_saver | foodie_favorite | fair_commute | null",\n'
        '      "group_fit_context": {\n'
        '        "headline_why_it_fits": "string",\n'
        '        "individual_craving_matches": "string",\n'
        '        "vibe_and_card_alignment": "string"\n'
        '      }\n'
        '    }\n'
        '  ],\n'
        '  "disqualified_venues": [\n'
        '    {\n'
        '      "name": "string",\n'
        '      "primary_reason_for_disqualification": "string"\n'
        '    }\n'
        '  ],\n'
        '  "leaderboard": {\n'
        '    "gold_medalist": "string",\n'
        '    "budget_saver": "string",\n'
        '    "foodie_favorite": "string",\n'
        '    "fair_commute": "string"\n'
        '  },\n'
        '  "smart_tradeoffs": [\n'
        '    {\n'
        '      "premium_choice": "string",\n'
        '      "value_alternative": "string",\n'
        '      "savings_per_person": 0,\n'
        '      "ui_copy": "string"\n'
        '    }\n'
        '  ]\n'
        "}"
    )

    user_prompt = f"PLAYER INPUT MATRIX:\n{matrix_payload}\n\nLIVE SEARCH & TRAVEL MATRIX TOOL METRICS:\n{real_world_context}"

    try:
        response = client.complete(
            messages=[
                {"role": "system", "content": system_instruction},
                {"role": "user", "content": user_prompt},
            ],
            model="gpt-4o",
            temperature=0.1,
        )

        raw_content = response.choices[0].message.content.strip()
        if raw_content.startswith("```json"):
            raw_content = raw_content[7:]
        if raw_content.endswith("```"):
            raw_content = raw_content[:-3]
        raw_content = raw_content.strip()

        return json.loads(raw_content)

    except Exception as e:
        return {"error": f"Agent Extraction Core Drop: {str(e)}"}
