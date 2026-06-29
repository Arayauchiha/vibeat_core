from contextlib import asynccontextmanager
from datetime import datetime
from typing import Dict, List, Optional

import uvicorn
from dotenv import load_dotenv
from fastapi import FastAPI, Form
from fastapi.responses import HTMLResponse

from agent import run_vibeat_orchestrator
from engine import process_vibeat_group_matrices


@asynccontextmanager
async def lifespan(app: FastAPI):
    """
    Deterministic Lifespan Context Manager.
    Guarantees environmental variables mount before application binds to ports.
    """
    load_dotenv()
    print("🚀 Vibeat Production Core Context Successfully Activated.")
    yield


app = FastAPI(title="Vibeat iOS Staging Core", lifespan=lifespan)

simulated_lobby: List[Dict] = []
party_timeline = {
    "date": "",
    "time": "",
    "predefined_lat": None,
    "predefined_lng": None,
    "predefined_name": "",
    "travel_variance_mode": "default",
}


@app.get("/", response_class=HTMLResponse)
async def home_interface():
    total_players = len(simulated_lobby)
    current_moment = datetime.now()
    default_date = (
        party_timeline["date"]
        if party_timeline["date"]
        else current_moment.strftime("%Y-%m-%d")
    )
    default_time = (
        party_timeline["time"]
        if party_timeline["time"]
        else current_moment.strftime("%H:%M")
    )

    predefined_name = party_timeline.get("predefined_name", "")
    predefined_lat = party_timeline.get("predefined_lat")
    predefined_lng = party_timeline.get("predefined_lng")
    travel_variance_mode = party_timeline.get("travel_variance_mode", "default")

    lobby_items = "".join(
        [
            f"""<li>
            👤 <strong>{p["name"]}</strong> | Budget: ₹{p["budget"]} | 🍻 Drinks: {"Yes" if p["wants_alcohol"] else "No"}<br/>
            &nbsp;&nbsp;&nbsp;&nbsp;💳 Wallet: {", ".join(p["cards"]) if p["cards"] else "Cash/None"}<br/>
            &nbsp;&nbsp;&nbsp;&nbsp;🥇 1st: {p["cuisine_1"]} | 🥈 2nd: {p["cuisine_2"]} | 🥉 3rd: {p["cuisine_3"]}<br/>
            &nbsp;&nbsp;&nbsp;&nbsp;✨ Vibe: '{p["atmosphere"]}' | 🍳 Craving: '{p["specific_dish"] if p["specific_dish"] else "None"}'
        </li><br/>"""
            for p in simulated_lobby
        ]
    )

    html_content = f"""
    <html>
        <head>
            <title>Vibeat Engine Testbed</title>
            <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
            <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
            <style>
                body {{ font-family: -apple-system, sans-serif; max-width: 950px; margin: 30px auto; padding: 20px; background: #fdfdfd; color: #222; }}
                input, select {{ width: 100%; padding: 8px; margin: 6px 0 14px 0; border: 1px solid #ccc; border-radius: 4px; box-sizing: border-box; }}
                button {{ background: #ff9800; color: white; border: none; padding: 12px 20px; font-weight: bold; border-radius: 4px; cursor: pointer; font-size: 14px; }}
                button:hover {{ background: #f57c00; }}
                #map {{ height: 220px; width: 100%; border-radius: 6px; border: 1px solid #ddd; margin-bottom: 16px; }}
                .container {{ background: white; padding: 20px; border-radius: 8px; border: 1px solid #eee; box-shadow: 0 2px 4px rgba(0,0,0,0.05); }}
                .flex-grid {{ display: flex; gap: 24px; margin-top: 20px; }}
                .col {{ flex: 1; }}
                .rank-box {{ background: #fcfcfc; padding: 10px; border: 1px dashed #ddd; border-radius: 6px; margin-bottom: 14px; }}
                .checkbox-group {{ display: flex; gap: 12px; margin: 6px 0 14px 0; font-size: 13px; }}
                .checkbox-group label {{ display: flex; align-items: center; gap: 4px; cursor: pointer; }}
            </style>
            <script>
                function searchPredefined() {{
                    var query = document.getElementById('predefined-search').value;
                    if(!query) return;
                    document.getElementById('predefined-status').innerText = '🔍 Searching...';
                    fetch('https://nominatim.openstreetmap.org/search?format=json&q=' + encodeURIComponent(query))
                        .then(response => response.json())
                        .then(data => {{
                            if(data && data.length > 0) {{
                                var lat = parseFloat(data[0].lat);
                                var lon = parseFloat(data[0].lon);
                                document.getElementById('predefined-lat').value = lat;
                                document.getElementById('predefined-lng').value = lon;
                                document.getElementById('predefined-status').innerHTML = '📍 Locked to: <strong>' + data[0].display_name.split(',')[0] + '</strong> (' + lat.toFixed(4) + ', ' + lon.toFixed(4) + ')';
                                document.getElementById('predefined-search').value = data[0].display_name.split(',')[0];
                            }} else {{
                                document.getElementById('predefined-status').innerText = '❌ Location not found';
                                alert('Location not found');
                            }}
                        }});
                }}
                function clearPredefined() {{
                    document.getElementById('predefined-search').value = '';
                    document.getElementById('predefined-lat').value = '';
                    document.getElementById('predefined-lng').value = '';
                    document.getElementById('predefined-status').innerHTML = '📍 No predefined location locked (Using midway centroid).';
                    setTimeout(() => {{ document.getElementById('settings-form').submit(); }}, 100);
                }}
            </script>
        </head>
        <body>
            <h2>🚀 Vibeat iOS Engine Staging Core</h2>
            <p style="color:#666;">Staging crowd-sourced discount wallets, variance routing math, and alcohol consensus rules.</p>
            <hr style="border: 0; border-top: 1px solid #eee; margin: 20px 0;" />

            <div class="flex-grid">
                <div class="col" style="flex: 1.1;">
                    <h3>👥 Active Lobby Group ({total_players} friends)</h3>
                    <div style="background: #eef2f3; padding: 12px 18px; border-radius: 6px; margin-bottom: 14px; border-left: 5px solid #009688;">
                        📅 <strong>Target Event Window:</strong> {default_date} at {default_time}
                    </div>
                    <ul style="background: #f9f9f9; padding: 20px 25px; border-radius: 6px; border: 1px solid #e0e0e0; min-height: 150px; list-style-type: none; margin: 0 0 20px 0;">
                        {lobby_items if lobby_items else "<li style='color:#888;'>No friends added yet. Build your pool below.</li>"}
                    </ul>
                    <div style="margin-bottom: 25px;">
                        <form action="/clear" method="post" style="display:inline;">
                            <button type="submit" style="background:#e53935;">Reset Lobby</button>
                        </form>
                        <form action="/calculate-matrices" method="post" style="display:inline; margin-left:10px;">
                            <button type="submit" style="background:#009688;" {"disabled" if total_players == 0 else ""}>🎯 Compute & Extract iOS JSON</button>
                        </form>
                    </div>

                    <form id="settings-form" action="/update-settings" method="post" style="background: #f1f5f9; padding: 20px; border-radius: 8px; border: 1px solid #e2e8f0; margin-bottom: 20px;">
                        <h4 style="margin-top:0; color:#1e293b; font-size:16px; border-bottom:1px solid #cbd5e1; padding-bottom:8px;">⚙️ Lobby Settings (Host Controls)</h4>
                        
                        <label style="font-size:13px; font-weight:bold; color:#475569;">🚗 Travel Variance Compromise Rule:</label>
                        <select name="travel_variance_mode" onchange="this.form.submit()" style="margin-top:4px;">
                            <option value="default" {"selected" if travel_variance_mode == "default" else ""}>Default compromise (Max 45m difference)</option>
                            <option value="strict" {"selected" if travel_variance_mode == "strict" else ""}>Strict Midway (Max 20m difference)</option>
                            <option value="perfect_vibe_only" {"selected" if travel_variance_mode == "perfect_vibe_only" else ""}>Perfect Vibe Only (Ignore travel variance)</option>
                        </select>

                        <label style="font-size:13px; font-weight:bold; color:#475569;">📍 Pre-Lock Destination (Optional):</label>
                        <div style="display:flex; gap:8px; margin-top:4px; margin-bottom:8px;">
                            <input type="text" id="predefined-search" name="predefined_name" placeholder="e.g. Connaught Place, Hauz Khas" value="{predefined_name}" style="margin:0;" />
                            <button type="button" onclick="searchPredefined()" style="background:#2196F3; padding: 0 15px; font-size:12px; height:36px; border-radius:4px; color:white; border:none; cursor:pointer;">Search Spot</button>
                        </div>
                        
                        <div id="predefined-status" style="font-size:12px; color:#64748b; margin-bottom:12px; line-height:1.4;">
                            {f"📍 Locked to: <strong>{predefined_name}</strong> ({predefined_lat:.4f}, {predefined_lng:.4f})" if predefined_lat else "📍 No predefined location locked (Using midway centroid)."}
                        </div>
                        
                        <input type="hidden" id="predefined-lat" name="predefined_lat" value="{predefined_lat or ''}" />
                        <input type="hidden" id="predefined-lng" name="predefined_lng" value="{predefined_lng or ''}" />
                        
                        <div style="display:flex; gap:10px;">
                            <button type="submit" style="background:#475569; padding: 8px 12px; font-size:12px; flex:1; height:34px; border-radius:4px; color:white; border:none; cursor:pointer;">Save Settings</button>
                            <button type="button" onclick="clearPredefined()" style="background:#ef4444; padding: 8px 12px; font-size:12px; color:white; border:none; border-radius:4px; cursor:pointer; height:34px;">Clear Locked Spot</button>
                        </div>
                    </form>
                </div>

                <div class="col container">
                    <h3>➕ Add Friend Workspace</h3>
                    <form action="/add-friend" method="post">
                        <div style="background: #fff8e1; padding: 12px; border-radius: 6px; margin-bottom: 16px; border: 1px solid #ffe082;">
                            <label><strong>📅 Date of Party:</strong></label>
                            <input type="date" name="party_date" value="{default_date}" required />
                            <label><strong>⏰ Time of Party:</strong></label>
                            <input type="time" name="party_time" value="{default_time}" required />
                        </div>

                        <label><strong>Friend's Name:</strong></label>
                        <input type="text" name="name" placeholder="e.g. Ayush" required />

                        <label><strong>Search & Set Location:</strong></label>
                        <div style="display:flex; gap:8px; margin-bottom:8px;">
                            <input type="text" id="search-box" placeholder="Neighborhood (e.g. Noida Sec 62, CP)" style="margin:0;" />
                            <button type="button" onclick="searchLocation()" style="background:#2196F3; padding: 0 15px;">Search</button>
                        </div>
                        <div id="map"></div>
                        <input type="hidden" id="lat-input" name="lat" value="28.6139" />
                        <input type="hidden" id="lng-input" name="lng" value="77.2090" />

                        <label><strong>Personal Budget Ceiling (INR):</strong></label>
                        <input type="number" name="budget" value="1200" step="100" required />

                        <label><strong>💳 Cards in Your Wallet:</strong></label>
                        <div class="checkbox-group">
                            <label><input type="checkbox" name="cards" value="HDFC"> HDFC</label>
                            <label><input type="checkbox" name="cards" value="SBI"> SBI</label>
                            <label><input type="checkbox" name="cards" value="ICICI"> ICICI</label>
                            <label><input type="checkbox" name="cards" value="AXIS"> AXIS</label>
                        </div>

                        <label><strong>🍻 Do you want alcohol options at the venue?</strong></label>
                        <div class="checkbox-group">
                            <label><input type="checkbox" name="wants_alcohol" value="true"> Yes, I plan to order drinks</label>
                        </div>

                        <div class="rank-box">
                            <label><strong>🥇 1st Cuisine Preference:</strong></label>
                            <select name="cuisine_1">
                                <option value="Italian" selected>Italian</option>
                                <option value="Chinese">Chinese</option>
                                <option value="North Indian">North Indian</option>
                                <option value="Asian">Asian / Sushi</option>
                                <option value="Continental">Continental</option>
                            </select>
                            <label><strong>🥈 2nd Cuisine Preference:</strong></label>
                            <select name="cuisine_2">
                                <option value="Chinese" selected>Chinese</option>
                                <option value="Italian">Italian</option>
                                <option value="North Indian">North Indian</option>
                                <option value="Asian">Asian / Sushi</option>
                            </select>
                            <label><strong>🥉 3rd Cuisine Preference:</strong></label>
                            <select name="cuisine_3">
                                <option value="North Indian" selected>North Indian</option>
                                <option value="Chinese">Chinese</option>
                                <option value="Italian">Italian</option>
                                <option value="Continental">Continental</option>
                            </select>
                        </div>

                        <label><strong>🍳 Specific Item Craving (Optional):</strong></label>
                        <input type="text" name="specific_dish" placeholder="e.g. Ramen, Chola Kulcha" value="" />

                        <label><strong>Ambiance Tag (Optional):</strong></label>
                        <input type="text" name="atmosphere" placeholder="e.g. cozy indoor, live sports" value="cozy indoor" />

                        <button type="submit" style="width: 100%;">Save Profile into Loop</button>
                    </form>
                </div>
            </div>

            <script>
                var map = L.map('map').setView([28.6139, 77.2090], 11);
                L.tileLayer('https://{{s}}.tile.openstreetmap.org/{{z}}/{{x}}/{{y}}.png').addTo(map);
                var marker = L.marker([28.6139, 77.2090], {{ draggable: true }}).addTo(map);

                function updateCoordinates(lat, lng) {{
                    document.getElementById('lat-input').value = lat;
                    document.getElementById('lng-input').value = lng;
                }}
                marker.on('dragend', function(e) {{
                    var position = marker.getLatLng();
                    updateCoordinates(position.lat, position.lng);
                }});
                function searchLocation() {{
                    var query = document.getElementById('search-box').value;
                    if(!query) return;
                    fetch('https://nominatim.openstreetmap.org/search?format=json&q=' + encodeURIComponent(query))
                        .then(response => response.json())
                        .then(data => {{
                            if(data && data.length > 0) {{
                                var lat = parseFloat(data[0].lat); var lon = parseFloat(data[0].lon);
                                map.setView([lat, lon], 14); marker.setLatLng([lat, lon]);
                                updateCoordinates(lat, lon);
                            }}
                        }});
                }}
            </script>
        </body>
    </html>
    """
    return html_content


@app.post("/add-friend")
async def add_friend(
    party_date: str = Form(...),
    party_time: str = Form(...),
    name: str = Form(...),
    lat: float = Form(...),
    lng: float = Form(...),
    budget: float = Form(...),
    cuisine_1: str = Form(...),
    cuisine_2: str = Form(...),
    cuisine_3: str = Form(...),
    cards: Optional[List[str]] = Form(None),
    wants_alcohol: Optional[bool] = Form(False),
    atmosphere: Optional[str] = Form(None),
    specific_dish: Optional[str] = Form(None),
):
    party_timeline["date"] = party_date
    party_timeline["time"] = party_time

    selected_cards = cards if cards else []

    simulated_lobby.append(
        {
            "name": name,
            "lat": lat,
            "lng": lng,
            "budget": budget,
            "cards": selected_cards,
            "wants_alcohol": wants_alcohol,
            "cuisine_1": cuisine_1,
            "cuisine_2": cuisine_2,
            "cuisine_3": cuisine_3,
            "atmosphere": atmosphere if atmosphere else "casual",
            "specific_dish": specific_dish if specific_dish else "",
        }
    )
    return HTMLResponse("<script>window.location.href='/';</script>")


@app.post("/clear")
async def clear_lobby():
    simulated_lobby.clear()
    party_timeline["date"] = ""
    party_timeline["time"] = ""
    party_timeline["predefined_lat"] = None
    party_timeline["predefined_lng"] = None
    party_timeline["predefined_name"] = ""
    party_timeline["travel_variance_mode"] = "default"
    return HTMLResponse("<script>window.location.href='/';</script>")


@app.post("/update-settings")
async def update_settings(
    travel_variance_mode: str = Form("default"),
    predefined_name: Optional[str] = Form(""),
    predefined_lat: Optional[str] = Form(""),
    predefined_lng: Optional[str] = Form(""),
):
    party_timeline["travel_variance_mode"] = travel_variance_mode
    party_timeline["predefined_name"] = predefined_name.strip() if predefined_name else ""
    
    if predefined_lat and predefined_lng:
        try:
            party_timeline["predefined_lat"] = float(predefined_lat)
            party_timeline["predefined_lng"] = float(predefined_lng)
        except ValueError:
            party_timeline["predefined_lat"] = None
            party_timeline["predefined_lng"] = None
    else:
        party_timeline["predefined_lat"] = None
        party_timeline["predefined_lng"] = None
        
    return HTMLResponse("<script>window.location.href='/';</script>")


@app.post("/calculate-matrices")
async def calculate_matrices():
    if not simulated_lobby:
        return {"error": "Lobby is empty"}

    processed_output_payload = process_vibeat_group_matrices(
        simulated_lobby,
        predefined_lat=party_timeline.get("predefined_lat"),
        predefined_lng=party_timeline.get("predefined_lng"),
        predefined_name=party_timeline.get("predefined_name"),
        travel_variance_mode=party_timeline.get("travel_variance_mode", "default"),
    )

    try:
        combined_dt_str = f"{party_timeline['date']} {party_timeline['time']}"
        parsed_dt = datetime.strptime(combined_dt_str, "%Y-%m-%d %H:%M")
        epoch_timestamp = int(parsed_dt.timestamp())
    except Exception:
        epoch_timestamp = int(datetime.now().timestamp())

    processed_output_payload["starting_calculation_metadata"][
        "target_party_epoch_seconds"
    ] = epoch_timestamp

    structured_json_response = await run_vibeat_orchestrator(processed_output_payload)
    return structured_json_response


if __name__ == "__main__":
    uvicorn.run("main:app", host="127.0.0.1", port=8000, reload=True)
