import Foundation
import SwiftUI
import Combine
import MapKit

enum AppState {
    case welcome
    case hostSetup
    case lobby
    case loading
    case results
}

// MARK: - MapKit Search Completer Helper
class LocationSearchCompleter: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    @Published var searchQuery = ""
    @Published var results: [MKLocalSearchCompletion] = []
    
    private var completer: MKLocalSearchCompleter
    private var cancellable: AnyCancellable?
    
    override init() {
        completer = MKLocalSearchCompleter()
        super.init()
        completer.delegate = self
        // Focus search on addresses and neighborhoods
        completer.resultTypes = .address
        
        cancellable = $searchQuery
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] query in
                if query.isEmpty {
                    self?.results = []
                } else {
                    self?.completer.queryFragment = query
                }
            }
    }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        self.results = completer.results
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Completer failed with error: \(error.localizedDescription)")
    }
}

// MARK: - Main ViewModel
@MainActor
class LobbyViewModel: ObservableObject {
    // API Configurations
    private let baseURL = "https://vibeat-backend-jn0q.onrender.com"
    
    // UI State
    @Published var appState: AppState = .welcome
    @Published var activePlayers: [Player] = []
    @Published var recommendations: VibeatResponse?
    @Published var errorMessage: String? = nil
    
    // Global Lobby Settings
    @Published var lobbyTitle: String = ""
    @Published var occasionType: String = "Casual"
    @Published var minimumBudget: Double = 500
    
    // Location Settings
    @Published var travelVarianceMode: String = "default"
    @Published var predefinedName: String = ""
    @Published var predefinedLat: Double? = nil
    @Published var predefinedLng: Double? = nil
    
    // MapKit Autocomplete Search Engine
    @Published var searchCompleter = LocationSearchCompleter()
    
    // MARK: - Geocode MapKit Selection
    func selectLocation(_ completion: MKLocalSearchCompletion) async {
        self.predefinedName = completion.title
        
        let searchRequest = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: searchRequest)
        
        do {
            let response = try await search.start()
            if let coord = response.mapItems.first?.placemark.coordinate {
                self.predefinedLat = coord.latitude
                self.predefinedLng = coord.longitude
                self.errorMessage = nil
            } else {
                self.errorMessage = "Could not resolve coordinate for selected place."
            }
        } catch {
            self.errorMessage = "Map search failed: \(error.localizedDescription)"
        }
    }
    
    // MARK: - API Action: Clear Lobby
    func clearLobby() async {
        guard let url = URL(string: "\(baseURL)/clear") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        do {
            let (_, _) = try await URLSession.shared.data(for: request)
            self.activePlayers = []
            self.recommendations = nil
            self.errorMessage = nil
            
            // Reset to default variables
            self.lobbyTitle = ""
            self.occasionType = "Casual"
            self.minimumBudget = 500
            self.predefinedName = ""
            self.predefinedLat = nil
            self.predefinedLng = nil
            self.searchCompleter.searchQuery = ""
            
            self.appState = .welcome
        } catch {
            self.errorMessage = "Failed to clear lobby: \(error.localizedDescription)"
        }
    }
    
    // MARK: - API Action: Update Settings
    func updateSettings() async {
        guard let url = URL(string: "\(baseURL)/update-settings") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        // Add travel_variance_mode
        body.append(formField(name: "travel_variance_mode", value: travelVarianceMode, boundary: boundary))
        
        // Add predefined location details if set
        if !predefinedName.isEmpty, let lat = predefinedLat, let lng = predefinedLng {
            body.append(formField(name: "predefined_name", value: predefinedName, boundary: boundary))
            body.append(formField(name: "predefined_lat", value: String(lat), boundary: boundary))
            body.append(formField(name: "predefined_lng", value: String(lng), boundary: boundary))
        }
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body
        
        do {
            let (_, _) = try await URLSession.shared.data(for: request)
            self.errorMessage = nil
        } catch {
            self.errorMessage = "Failed to save settings: \(error.localizedDescription)"
        }
    }
    
    // MARK: - API Action: Add Friend / Player
    func addPlayer(_ player: Player) async {
        guard let url = URL(string: "\(baseURL)/add-friend") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        // Setup Date & Time formatted string for backend
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: Date())
        formatter.dateFormat = "HH:mm"
        let timeString = formatter.string(from: Date())
        
        body.append(formField(name: "party_date", value: dateString, boundary: boundary))
        body.append(formField(name: "party_time", value: timeString, boundary: boundary))
        body.append(formField(name: "name", value: player.name, boundary: boundary))
        body.append(formField(name: "lat", value: String(player.lat), boundary: boundary))
        body.append(formField(name: "lng", value: String(player.lng), boundary: boundary))
        body.append(formField(name: "budget", value: String(player.budget), boundary: boundary))
        
        // Cuisines (cuisines 1, 2, 3)
        let c1 = player.cuisines.indices.contains(0) ? player.cuisines[0] : "Italian"
        let c2 = player.cuisines.indices.contains(1) ? player.cuisines[1] : "Chinese"
        let c3 = player.cuisines.indices.contains(2) ? player.cuisines[2] : "North Indian"
        body.append(formField(name: "cuisine_1", value: c1, boundary: boundary))
        body.append(formField(name: "cuisine_2", value: c2, boundary: boundary))
        body.append(formField(name: "cuisine_3", value: c3, boundary: boundary))
        
        // Cards (FastAPI expects multiple repeated fields for lists)
        for card in player.cards {
            body.append(formField(name: "cards", value: card, boundary: boundary))
        }
        
        // Wants Alcohol & Atmospheres
        body.append(formField(name: "wants_alcohol", value: player.wantsAlcohol ? "true" : "false", boundary: boundary))
        if let atmosphere = player.atmosphere {
            body.append(formField(name: "atmosphere", value: atmosphere, boundary: boundary))
        }
        if let specificDish = player.specificDish {
            body.append(formField(name: "specific_dish", value: specificDish, boundary: boundary))
        }
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body
        
        do {
            let (_, _) = try await URLSession.shared.data(for: request)
            self.activePlayers.append(player)
            self.errorMessage = nil
        } catch {
            self.errorMessage = "Failed to add player: \(error.localizedDescription)"
        }
    }
    
    // MARK: - API Action: Calculate Matrix (Find Matches)
    func calculateRecommendations() async {
        self.appState = .loading
        self.errorMessage = nil
        
        guard let url = URL(string: "\(baseURL)/calculate-matrices") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                self.appState = .lobby
                self.errorMessage = "Calculation failed on server side (status code != 200)."
                return
            }
            
            let decoded = try JSONDecoder().decode(VibeatResponse.self, from: data)
            self.recommendations = decoded
            self.appState = .results
        } catch {
            self.appState = .lobby
            self.errorMessage = "Failed to fetch results: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Multipart Form Field Helper
    private func formField(name: String, value: String, boundary: String) -> Data {
        var data = Data()
        data.append("--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n".data(using: .utf8)!)
        data.append("\(value)\r\n".data(using: .utf8)!)
        return data
    }
}
