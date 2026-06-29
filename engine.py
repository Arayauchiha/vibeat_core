from typing import Any, Dict, List, Optional


def process_vibeat_group_matrices(
    lobby_friends: List[Dict[str, Any]],
    predefined_lat: Optional[float] = None,
    predefined_lng: Optional[float] = None,
    predefined_name: Optional[str] = None,
    travel_variance_mode: str = "default",
) -> Dict[str, Any]:
    """
    Processes the raw multiplayer lobby array into an aggregate structural matrix payload.
    Calculates geometric centroids (or respects predefined destination coordinate hubs),
    maps personal budget caps, compiles the group card wallet, and extracts vibe consensus text tokens.
    """
    total_members = len(lobby_friends)
    if total_members == 0:
        return {}

    # 1. Compute physical location geometric base points or respect predefined lock
    if predefined_lat is not None and predefined_lng is not None:
        centroid_lat = float(predefined_lat)
        centroid_lng = float(predefined_lng)
        strategy = f"Predefined Destination: {predefined_name}" if predefined_name else "Predefined Destination"
        is_predefined = True
    else:
        sum_lat = sum(p["lat"] for p in lobby_friends)
        sum_lng = sum(p["lng"] for p in lobby_friends)
        centroid_lat = sum_lat / total_members
        centroid_lng = sum_lng / total_members
        strategy = "Calculated Geometric Centroid Base Point"
        is_predefined = False

    # 2. Extract personal budget properties and group card vectors
    individual_budgets = {}
    player_payment_wallets = {}
    alcohol_requests_count = 0

    for p in lobby_friends:
        name_key = p["name"]
        individual_budgets[name_key] = float(p["budget"])

        # Map credit card assets to the player
        player_cards = []
        if "cards" in p and isinstance(p["cards"], list):
            for card in p["cards"]:
                player_cards.append(str(card).upper())
        player_payment_wallets[name_key] = player_cards

        # Aggregate alcohol interest metrics
        if p.get("wants_alcohol"):
            alcohol_requests_count += 1

    # 3. Compute structural group cuisine weights
    cuisine_scores: Dict[str, int] = {}
    for p in lobby_friends:
        # 1st preference choice gets 3 points
        c1 = p.get("cuisine_1")
        if c1:
            cuisine_scores[c1] = cuisine_scores.get(c1, 0) + 3

        # 2nd preference choice gets 2 points
        c2 = p.get("cuisine_2")
        if c2:
            cuisine_scores[c2] = cuisine_scores.get(c2, 0) + 2

        # 3rd preference choice gets 1 point
        c3 = p.get("cuisine_3")
        if c3:
            cuisine_scores[c3] = cuisine_scores.get(c3, 0) + 1

    # Sort rankings in descending order
    sorted_cuisines = [
        {"cuisine": k, "group_priority_score": v}
        for k, v in sorted(
            cuisine_scores.items(), key=lambda item: item[1], reverse=True
        )
    ]

    # 4. Gather ambiance sentiments and individual craving strings
    vibe_tokens = [p["atmosphere"] for p in lobby_friends if p.get("atmosphere")]
    specific_cravings = [
        f"{p['name']} is explicitly craving: '{p['specific_dish']}'"
        for p in lobby_friends
        if p.get("specific_dish")
    ]

    # 5. Build the unified payload map matching our design spec
    matrix_payload = {
        "starting_calculation_metadata": {
            "initial_latitude": centroid_lat,
            "initial_longitude": centroid_lng,
            "calculation_strategy": strategy,
            "is_predefined_location": is_predefined,
            "predefined_location_name": predefined_name,
            "travel_variance_mode": travel_variance_mode,
            "mcp_routing_optimization_required": True,
            "total_lobby_size": total_members,
            "alcohol_interest_count": alcohol_requests_count,
            "group_payment_cards_wallet": player_payment_wallets,
        },
        "individual_player_budget_caps": individual_budgets,
        "group_cravings_profile": {
            "weighted_cuisine_rankings": sorted_cuisines,
            "vibe_tags_sentiment": vibe_tokens,
            "specific_target_dishes": specific_cravings,
        },
        "raw_player_starting_points": [
            {"name": p["name"], "lat": p["lat"], "lng": p["lng"]} for p in lobby_friends
        ],
    }

    return matrix_payload
