import pprint
from fastapi.testclient import TestClient
from dotenv import load_dotenv

# Load credentials (.env)
load_dotenv(".env")

from main import app, simulated_lobby

client = TestClient(app)

def run_lobby_test():
    print("🧹 1. Clearing lobby...")
    client.post("/clear")
    print(f"Lobby cleared. Active players: {len(simulated_lobby)}")

    print("\n👥 2. Adding active players with starting locations...")
    # Add Ayush
    client.post("/add-friend", data={
        "party_date": "2026-06-30",
        "party_time": "20:00",
        "name": "Ayush",
        "lat": 12.9719,
        "lng": 77.6412,
        "budget": 1500,
        "cuisine_1": "Italian",
        "cuisine_2": "Chinese",
        "cuisine_3": "North Indian",
        "cards": ["HDFC", "ICICI"],
        "wants_alcohol": "true",
        "atmosphere": "cozy indoor",
        "specific_dish": "Pizza"
    })
    
    # Add Aryan
    client.post("/add-friend", data={
        "party_date": "2026-06-30",
        "party_time": "20:00",
        "name": "Aryan",
        "lat": 12.9116,
        "lng": 77.6389,
        "budget": 1200,
        "cuisine_1": "Italian",
        "cuisine_2": "Continental",
        "cuisine_3": "Chinese",
        "cards": ["HDFC"],
        "wants_alcohol": "false",
        "atmosphere": "live music",
        "specific_dish": "Pasta"
    })
    print(f"Lobby setup completed. Active players: {[p['name'] for p in simulated_lobby]}")

    print("\n🚗 3. Querying Swiggy Dineout & Executing Centroid Travel Matrix...")
    response = client.post("/calculate-matrices")
    
    print(f"Status Code: {response.status_code}")
    print("\n✨ AI Recommendation Results:")
    data = response.json()
    print("Response Keys:", list(data.keys()))
    if "leaderboard" in data:
        print("Leaderboard Content:")
        pprint.pprint(data["leaderboard"])
    else:
        print("❌ LEADERBOARD KEY MISSING!")
    
    if "smart_tradeoffs" in data:
        print("\nSmart Trade-offs:")
        pprint.pprint(data["smart_tradeoffs"])
    else:
        print("❌ SMART TRADEOFFS KEY MISSING!")
        
    print("\nTop choices awards:")
    for choice in data.get("top_choices", []):
        print(f"- {choice.get('name')}: award_tag={choice.get('award_tag')}")

if __name__ == "__main__":
    run_lobby_test()
