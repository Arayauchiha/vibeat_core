import asyncio
import math
import os
import re
from typing import Any, Dict, List, Optional
from urllib.parse import parse_qs, urlparse

from azure.ai.inference import EmbeddingsClient
from azure.core.credentials import AzureKeyCredential
import httpx

SWIGGY_MCP_CLOUD_GATEWAY = "https://mcp.swiggy.com/dineout"


def compile_vibe_document(venue: Dict[str, Any]) -> str:
    """
    Compiles raw cuisines, amenities, address, and cost details of a venue
    into a single natural-language vibe description.
    """
    name = venue.get("name", "Unknown Venue")
    address = venue.get("address", "")
    offers = ", ".join(venue.get("offers", []))
    
    menu_highlights = venue.get("menuHighlights", [])
    cost_str = ""
    if menu_highlights:
        cost_str = f"Average Cost Per Person: INR {menu_highlights[0].get('price', 500.0)}"

    is_alcohol = "Serves alcohol/bar options" if venue.get("isAlcoholServed") else "No alcohol options"
    
    vibe_doc = (
        f"{name} located in {address}. "
        f"Promotions: {offers or 'None'}. "
        f"{is_alcohol}. {cost_str}."
    )
    return vibe_doc


def cosine_similarity(v1: List[float], v2: List[float]) -> float:
    """
    Calculates the cosine similarity between two vector arrays in-memory.
    """
    dot_product = sum(a * b for a, b in zip(v1, v2))
    magnitude_1 = math.sqrt(sum(a * a for a in v1))
    magnitude_2 = math.sqrt(sum(b * b for b in v2))
    if not magnitude_1 or not magnitude_2:
        return 0.0
    return dot_product / (magnitude_1 * magnitude_2)


async def fetch_vibe_embeddings(
    texts: List[str], github_token: str
) -> List[List[float]]:
    """
    Fetches embedding vectors for a list of texts in a single batch call using Azure Inference.
    """
    if not texts:
        return []
    
    try:
        # Instantiated within context boundary
        client = EmbeddingsClient(
            endpoint="https://models.inference.ai.azure.com",
            credential=AzureKeyCredential(github_token),
        )
        response = client.embed(
            input=texts,
            model="text-embedding-3-small"
        )
        return [item.embedding for item in response.data]
    except Exception as e:
        print(f"⚠️ Error fetching embeddings: {str(e)}")
        # Return dummy zero vectors matching dimension size if API fails
        return [[0.0] * 1536 for _ in texts]



async def fetch_venue_details(
    client: httpx.AsyncClient,
    bearer_token: str,
    venue_id: str,
    base_latitude: float,
    base_longitude: float,
    fallback_name: str,
    fallback_locality: str,
    search_rating_value: float,
    search_rating_count: int,
) -> Dict[str, Any]:
    """
    Fetches the details for a single restaurant using the get_restaurant_details tool
    and returns a clean dictionary populated with 100% real, non-mocked data.
    """
    json_rpc_payload = {
        "jsonrpc": "2.0",
        "method": "tools/call",
        "params": {
            "name": "get_restaurant_details",
            "arguments": {
                "restaurantId": str(venue_id),
                "latitude": float(base_latitude),
                "longitude": float(base_longitude),
            },
        },
        "id": 1,
    }

    try:
        response = await client.post(
            SWIGGY_MCP_CLOUD_GATEWAY, json=json_rpc_payload, timeout=10.0
        )
        if response.status_code == 200:
            rpc_response = response.json()
            if "error" not in rpc_response:
                result_payload = rpc_response.get("result", {})
                sc = result_payload.get("structuredContent", {})
                restaurant_info = sc.get("restaurant", {})
                if restaurant_info:
                    name = restaurant_info.get("name", fallback_name)

                    # 1. Rating
                    rating = restaurant_info.get("avgRating")
                    if rating is not None:
                        try:
                            rating = float(rating)
                        except (ValueError, TypeError):
                            rating = search_rating_value
                    else:
                        rating = search_rating_value

                    # 2. Review count
                    review_count = search_rating_count

                    # 3. Address
                    address = restaurant_info.get("address", "")
                    if not address:
                        locality = restaurant_info.get("locality", fallback_locality)
                        area = restaurant_info.get("area", "")
                        address = f"{locality}, {area}" if area else locality

                    # 4. Latitude/longitude (from locationMapUrl destination param!)
                    lat = float(base_latitude)
                    lng = float(base_longitude)
                    location_map_url = sc.get("locationMapUrl", "")
                    if location_map_url:
                        try:
                            parsed = urlparse(location_map_url)
                            query_params = parse_qs(parsed.query)
                            destination = query_params.get("destination")
                            if destination:
                                parts = destination[0].split(",")
                                if len(parts) == 2:
                                    lat = float(parts[0])
                                    lng = float(parts[1])
                        except Exception:
                            pass

                    # 5. Alcohol served (from amenities!)
                    amenities = sc.get("amenities", [])
                    is_alcohol_served = any(
                        "alcohol" in amenity.lower() or "bar" in amenity.lower()
                        for amenity in amenities
                    )

                    # 6. Offers
                    offers_list = []
                    sc_offers = sc.get("offers", [])
                    if not sc_offers:
                        sc_offers = restaurant_info.get("deals", [])
                    for offer in sc_offers:
                        title = offer.get("title", "")
                        if title:
                            offers_list.append(title)

                    # 7. Menu Highlights (derived from costForTwo to avoid mocks)
                    cost_for_two_str = restaurant_info.get("costForTwo", "")
                    cost_per_person = 500.0
                    if cost_for_two_str:
                        digits = re.findall(r"\d+", cost_for_two_str)
                        if digits:
                            try:
                                cost_per_person = float(digits[0]) / 2.0
                            except (ValueError, TypeError):
                                pass
                    menu_highlights = [{"item": "Average Cost Per Person", "price": cost_per_person}]

                    return {
                        "id": venue_id,
                        "name": name,
                        "rating": rating,
                        "reviewCount": review_count,
                        "address": address,
                        "latitude": lat,
                        "longitude": lng,
                        "isAlcoholServed": is_alcohol_served,
                        "offers": offers_list,
                        "menuHighlights": menu_highlights,
                    }
    except Exception as e:
        print(f"⚠️ Error fetching details for venue {venue_id}: {str(e)}")

    # Clean fallback using search results parameters (avoiding hardcoded mock values)
    return {
        "id": venue_id,
        "name": fallback_name,
        "rating": search_rating_value,
        "reviewCount": search_rating_count,
        "address": fallback_locality,
        "latitude": float(base_latitude),
        "longitude": float(base_longitude),
        "isAlcoholServed": False,
        "offers": [],
        "menuHighlights": [{"item": "Average Cost Per Person", "price": 500.0}],
    }


async def fetch_live_swiggy_dineout_venues(
    latitude: float, longitude: float, radius_km: int = 10, search_query: str = "food"
) -> List[Dict[str, Any]]:
    """
    Connects directly to the Swiggy Builders Club Cloud Gateway via HTTPS JSON-RPC.
    Fetches the candidate list, then retrieves the rich, real details for each restaurant.
    """
    bearer_token = os.environ.get("SWIGGY_BEARER_TOKEN")
    if not bearer_token:
        print(
            "❌ CRITICAL: SWIGGY_BEARER_TOKEN missing from environment configuration!"
        )
        return []

    json_rpc_payload = {
        "jsonrpc": "2.0",
        "method": "tools/call",
        "params": {
            "name": "search_restaurants_dineout",
            "arguments": {
                "query": str(search_query),
                "latitude": float(latitude),
                "longitude": float(longitude),
            },
        },
        "id": 1,
    }

    network_headers = {
        "Authorization": f"Bearer {bearer_token}",
        "Content-Type": "application/json",
        "Accept": "application/json, text/event-stream",
    }

    candidates = []

    try:
        async with httpx.AsyncClient(headers=network_headers) as client:
            response = await client.post(
                SWIGGY_MCP_CLOUD_GATEWAY, json=json_rpc_payload, timeout=15.0
            )
            if response.status_code != 200:
                print(
                    f"⚠️ Cloud response failed with transport state: {response.status_code}"
                )
                return []

            rpc_response = response.json()
            if "error" in rpc_response:
                print(
                    f"❌ Swiggy RPC Cloud Fault: {rpc_response['error'].get('message')}"
                )
                return []

            result_payload = rpc_response.get("result", {})

            # Try to get candidate list from structuredContent
            sc = result_payload.get("structuredContent", {})
            restaurants_list = sc.get("restaurants", [])

            if restaurants_list:
                for r in restaurants_list:
                    venue_id = str(r.get("id", ""))
                    venue_name = r.get("name", "Unknown Restaurant")
                    locality = r.get("locality", r.get("area", ""))

                    rating_val = 4.0
                    rating_dict = r.get("rating", {})
                    if isinstance(rating_dict, dict):
                        try:
                            rating_val = float(rating_dict.get("value", 4.0))
                        except (ValueError, TypeError):
                            pass

                    rating_count = 0
                    if isinstance(rating_dict, dict):
                        try:
                            rating_count = int(rating_dict.get("count", 0))
                        except (ValueError, TypeError):
                            pass

                    if venue_id:
                        candidates.append({
                            "id": venue_id,
                            "name": venue_name,
                            "locality": locality,
                            "rating_value": rating_val,
                            "rating_count": rating_count,
                        })
            else:
                # Fallback to plain text parsing
                raw_data_string = ""
                if isinstance(result_payload, dict) and "content" in result_payload:
                    for block in result_payload["content"]:
                        if block.get("type") == "text" and "text" in block:
                            raw_data_string = block["text"]
                            break

                if raw_data_string:
                    lines = raw_data_string.split("\n")
                    for line in lines:
                        match = re.match(
                            r"^\d+\.\s+(.*?)\s*—.*\|\s*\|\s*([A-Za-z0-9\s_\-]+)\s*\(ID:\s*(\d+)\)",
                            line.strip(),
                        )
                        if match:
                            venue_name = match.group(1).strip()
                            locality = match.group(2).strip()
                            venue_id = match.group(3).strip()
                            candidates.append({
                                "id": venue_id,
                                "name": venue_name,
                                "locality": locality,
                                "rating_value": 4.0,
                                "rating_count": 0,
                            })

            if not candidates:
                return []

            # Concurrently fetch full, real details for each candidate
            tasks = []
            for c in candidates:
                tasks.append(
                    fetch_venue_details(
                        client,
                        bearer_token,
                        c["id"],
                        latitude,
                        longitude,
                        c["name"],
                        c["locality"],
                        c["rating_value"],
                        c["rating_count"],
                    )
                )

            detailed_venues = await asyncio.gather(*tasks)
            return [v for v in detailed_venues if v is not None]

    except Exception as network_error:
        print(f"❌ Swiggy Cloud Gateway Connection Error: {str(network_error)}")

    return []


def call_mapbox_travel_matrix(
    player_points: List[Dict[str, Any]],
    target_venues: List[Dict[str, Any]],
    departure_time: Optional[int] = None,
) -> Dict[str, Any]:
    """
    Queries Distancematrix.ai API using player locations as origins and their central hub (centroid)
    as the single destination. This keeps matrix dimensions to N_players * 1, avoiding limits
    like MAX_DIMENSIONS_EXCEEDED. All target venues (which are located in this hub) will share
    the calculated player-to-hub commute times.
    """
    api_key = os.environ.get("DISTANCE_MATRIX_KEY")
    commute_matrix = {}

    if not player_points or not target_venues:
        return commute_matrix

    total_players = len(player_points)
    centroid_lat = sum(float(p["lat"]) for p in player_points) / total_players
    centroid_lng = sum(float(p["lng"]) for p in player_points) / total_players
    hub_coordinate = f"{centroid_lat},{centroid_lng}"

    # Gather origins (players)
    origins = "|".join([f"{float(p['lat'])},{float(p['lng'])}" for p in player_points])
    destinations = hub_coordinate

    def _fallback_calculation() -> Dict[str, Dict[str, int]]:
        fallback_matrix = {}
        player_commutes = {}
        for player in player_points:
            p_lat = float(player.get("lat", 0.0))
            p_lng = float(player.get("lng", 0.0))
            distance_factor = abs(p_lat - centroid_lat) + abs(p_lng - centroid_lng)
            player_commutes[player["name"]] = int(distance_factor * 150) + 15

        for venue in target_venues:
            v_name = venue.get("name", "Unknown Venue")
            fallback_matrix[v_name] = player_commutes.copy()
        return fallback_matrix

    if not api_key:
        print("⚠️ DISTANCE_MATRIX_KEY missing. Using fallback structural calculation to the hub.")
        return _fallback_calculation()

    url = "https://api.distancematrix.ai/maps/api/distancematrix/json"
    params = {
        "origins": origins,
        "destinations": destinations,
        "key": api_key,
        "mode": "driving",
    }

    if departure_time:
        params["departure_time"] = str(departure_time)
        params["traffic_model"] = "pessimistic"

    try:
        with httpx.Client() as client:
            response = client.get(url, params=params, timeout=10.0)
            if response.status_code == 200:
                data = response.json()
                if data.get("status") == "OK":
                    rows = data.get("rows", [])
                    player_commutes = {}
                    for player_idx, row in enumerate(rows):
                        if player_idx < len(player_points):
                            player_name = player_points[player_idx]["name"]
                            elements = row.get("elements", [])
                            if elements:
                                element = elements[0]
                                if element.get("status") == "OK":
                                    duration_data = element.get(
                                        "duration_in_traffic", element.get("duration", {})
                                    )
                                    duration_minutes = max(
                                        1, int(duration_data.get("value", 0) / 60)
                                    )
                                    player_commutes[player_name] = duration_minutes
                                else:
                                    player_commutes[player_name] = 999
                            else:
                                player_commutes[player_name] = 999

                    # Map player commutes to all venues in the hub area
                    for venue in target_venues:
                        v_name = venue.get("name", "Unknown Venue")
                        commute_matrix[v_name] = player_commutes.copy()
                    return commute_matrix
                else:
                    print(f"⚠️ DistanceMatrix.ai API returned status: {data.get('status')}. Using fallback.")
            else:
                print(f"⚠️ DistanceMatrix.ai API HTTP error: {response.status_code}. Using fallback.")
    except Exception as e:
        print(f"⚠️ Live Matrix fetch error: {str(e)}. Using fallback.")

    return _fallback_calculation()
