# Vibeat Core Backend

Vibeat Core is a stateless dining coordination API built with Python, FastAPI, and Azure AI Inference (GPT-4o). It aggregates multiplayer lobby parameters, fetches real-time dining coordinates via Swiggy Dineout, resolves travel matrices, and returns ranked venue recommendations with dynamic credit card discount attribution.

---

## 🛠️ Tech Stack & Key Integrations
* **Backend Framework**: FastAPI & Uvicorn (ASGI Server)
* **AI Engine**: Azure AI Inference SDK (using `gpt-4o` and `text-embedding-3-small` models)
* **Data Sources**: Swiggy Dineout (JSON-RPC Gateway)
* **Travel Matrix**: Distancematrix.ai (Driving transit durations)

---

## 🚀 Local Quickstart

### 1. Configure Environment Variables
Create a `.env` file in the root directory (this is ignored by Git):
```ini
GITHUB_TOKEN=your_azure_inference_github_token
SWIGGY_BEARER_TOKEN=your_swiggy_builders_club_token
DISTANCE_MATRIX_KEY=your_distancematrix_ai_api_key
```

### 2. Setup Virtual Environment & Run
```bash
# Create and activate virtual environment
python3 -m venv venv
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Run the local uvicorn server
python3 main.py
```
The server will start running locally at: `http://127.0.0.1:8000`

---

## 🔌 API Documentation

### 1. `POST /add-friend`
Adds a player to the active coordinate lobby.
* **Payload Format**: Form-Data
* **Keys**:
  * `name`: String (e.g. `Ayush`)
  * `lat` / `lng`: Float coordinates
  * `budget`: Float (Personal budget ceiling in INR)
  * `cuisine_1` / `cuisine_2` / `cuisine_3`: String preferences
  * `cards`: Optional List of bank card names (`HDFC`, `SBI`, `ICICI`, `AXIS`)
  * `wants_alcohol`: Boolean
  * `atmosphere` / `specific_dish`: Optional Strings

### 2. `POST /clear`
Resets the active simulated lobby and clears player variables.
* **Response**: Redirects to home staging template.

### 3. `POST /update-settings`
Sets host-controlled variables.
* **Keys**:
  * `travel_variance_mode`: `default` (45m max difference) | `strict` (20m max difference) | `perfect_vibe_only` (ignore variance)
  * `predefined_name` / `predefined_lat` / `predefined_lng`: Optional coordinates to lock a specific meeting spot, bypassing the geometric midway calculation.

### 4. `POST /calculate-matrices`
Calculates routes and fetches AI recommendations.
* **Response**: Returns a JSON object containing the recommendations, award leaderboard, and trade-offs.

#### Output JSON Schema (For iOS SwiftUI Codable Mapping):
```json
{
  "top_choices": [
    {
      "ranking_position": 1,
      "name": "Restaurant Name",
      "rating": 4.5,
      "travel_time_variance_minutes": 12,
      "applied_wallet_promotions": ["Flat 15% off"],
      "safety_warning_tags": [],
      "player_commute_breakdown": { "Ayush": 24, "Aryan": 35 },
      "award_tag": "gold_medalist | budget_saver | foodie_favorite | fair_commute | null",
      "group_fit_context": {
        "headline_why_it_fits": "...",
        "individual_craving_matches": "...",
        "vibe_and_card_alignment": "..."
      }
    }
  ],
  "alternative_suggestions": [],
  "disqualified_venues": [
    {
      "name": "Dry Venue",
      "primary_reason_for_disqualification": "Exceeds Aryan's budget cap"
    }
  ],
  "leaderboard": {
    "gold_medalist": "Amido Truly Italian",
    "budget_saver": "Italian Creamery",
    "foodie_favorite": "Moonstone Italian Restaurant",
    "fair_commute": "Sicilia Point Italian Bistro"
  },
  "smart_tradeoffs": [
    {
      "premium_choice": "Moonstone Italian Restaurant",
      "value_alternative": "Italian Creamery",
      "savings_per_person": 225,
      "ui_copy": "Swap to Italian Creamery: Saves ₹225 per person while offering a similar cozy vibe!"
    }
  ]
}
```
