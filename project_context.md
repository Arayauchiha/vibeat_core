# 🛸 Project Vibeat: System Context & AI Blueprint

## 1. Project Overview
Vibeat is a dining coordination service backend built using Python and FastAPI. It collects real-time location markers and cuisine preferences from multiple users in a shared lobby, queries live dining options using the Swiggy Dineout MCP cloud gateway, calculates travel runtimes, and processes an optimization matcher algorithm to surface the ultimate compromise dining venue.

## 📂 2. Active Workspace File Map
* **`tools.py`**: External service I/O layer. Holds the connection code for `fetch_live_swiggy_dineout_venues` and the travel time logic for `call_mapbox_travel_matrix`.
* **`main.py`**: API endpoint layer. Controls FastAPI route lifecycle hooks, entry points, and lobby memory state.
* **`agent.py`**: Orchestration loop engine. Consumes arrays from your external tools, processes preference weights, and controls final recommendations.

## ⚠️ 3. Solved Traps & Hard Gateway Constraints
* **Swiggy JSON & Fallback Parsing:** The gateway supports structured responses under `structuredContent`. We first parse `structuredContent` directly to retrieve candidate restaurant IDs. If empty, the system falls back to a custom regular expression filter (`_parse_raw_text_payload_to_dict_array`) to extract IDs from the plain-text payload.
* **Concurrent Detail Extraction:** For each candidate, we concurrently execute the `get_restaurant_details` RPC method to retrieve 100% real ratings, exact street addresses, deals, and precise geo-coordinates (extracted from the `locationMapUrl` parameter).
* **Precise Travel Matrix Routing:** `call_mapbox_travel_matrix` queries DistanceMatrix.ai with players as origins and individual restaurant coordinates as destinations. When API limits are reached, the engine falls back to a clean coordinate-based city-block Manhattan distance to compute individual travel runtimes.
* **Required Network Headers:** Outbound HTTPS requests to `mcp.swiggy.com/dineout` must pass `{"Content-Type": "application/json", "Accept": "application/json, text/event-stream"}` or the gateway drops the connection.

## 📱 4. Mobile Layer Requirements
The system is built to feed data straight to a SwiftUI native iOS mobile client using the MVVM pattern. Every dictionary returned by your algorithms must maintain clean snake_case typing to ensure frictionless compatibility with Swift's `Decodable` parsing structs.

## 🛠️ 5. Next Steps Checklist
- [x] Connect the parsed Swiggy restaurant array outputs directly into the `call_mapbox_travel_matrix` data loop.
- [x] Implement a fallback calculation inside the travel matrix function to gracefully generate travel parameters when the distance matrix API token is missing or limited.
- [x] Eliminate all static mock data by implementing concurrent `get_restaurant_details` queries and parsing real coordinates and ratings.