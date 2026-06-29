import pprint
from fastapi.testclient import TestClient
from dotenv import load_dotenv

# Load credentials (.env)
load_dotenv(".env")

from main import app, simulated_lobby, party_timeline

client = TestClient(app)

def run_predefined_test():
    print("🧹 1. Clearing lobby...")
    client.post("/clear")

    print("\n⚙️ 2. Setting Host Settings (Predefined Spot + Strict Variance)...")
    # CP coordinate is approx: 28.6304, 77.2177
    client.post("/update-settings", data={
        "travel_variance_mode": "strict",
        "predefined_name": "Connaught Place",
        "predefined_lat": 28.6304,
        "predefined_lng": 77.2177
    })
    print(f"Settings state: {party_timeline}")

    print("\n👥 3. Adding players (located far away)...")
    # Add Ayush (Noida)
    client.post("/add-friend", data={
        "party_date": "2026-06-30",
        "party_time": "20:00",
        "name": "Ayush",
        "lat": 28.6273,
        "lng": 77.3725,
        "budget": 1500,
        "cuisine_1": "Italian",
        "cuisine_2": "Chinese",
        "cuisine_3": "North Indian",
        "cards": ["HDFC"],
        "wants_alcohol": "true",
        "atmosphere": "cozy indoor",
        "specific_dish": "Pizza"
    })
    
    # Add Aryan (Gurgaon)
    client.post("/add-friend", data={
        "party_date": "2026-06-30",
        "party_time": "20:00",
        "name": "Aryan",
        "lat": 28.4595,
        "lng": 77.0266,
        "budget": 1200,
        "cuisine_1": "Italian",
        "cuisine_2": "Continental",
        "cuisine_3": "Chinese",
        "cards": ["HDFC", "SBI"],
        "wants_alcohol": "false",
        "atmosphere": "live music",
        "specific_dish": "Pasta"
    })
    print(f"Lobby setup completed. Active players: {[p['name'] for p in simulated_lobby]}")

    print("\n🚗 4. Running calculation payload...")
    response = client.post("/calculate-matrices")
    
    print(f"Status Code: {response.status_code}")
    print("\n✨ AI Recommendation Results with Predefined Location & Wallet Attribute:")
    data = response.json()
    print("Response Keys:", list(data.keys()))
    if "leaderboard" in data:
        print("Leaderboard Content:")
        pprint.pprint(data["leaderboard"])
    else:
        print("❌ LEADERBOARD KEY MISSING!")
    
    print("\nTop choices awards:")
    for choice in data.get("top_choices", []):
        print(f"- {choice.get('name')}: award_tag={choice.get('award_tag')}")

if __name__ == "__main__":
    run_predefined_test()
