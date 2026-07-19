import Foundation
import SwiftUI
import Combine
import MapKit

enum AppScreen: Hashable {
    case hostSetup
    case joinSetup
    case lobby
    case loading
    case results
}

@MainActor
class LocationSearchService: NSObject, ObservableObject {
    @Published var searchQuery: String = "" {
        didSet { completer.queryFragment = searchQuery }
    }
    @Published var completions: [MKLocalSearchCompletion] = []
    @Published var selectedLocation: String? = nil
    @Published var selectedSubtitle: String? = nil

    private let completer = MKLocalSearchCompleter()

    override init() {
        super.init()
        completer.delegate = self
        completer.resultTypes = [.address, .pointOfInterest]
    }
}

extension LocationSearchService: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        completions = completer.results
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Location search error: \(error.localizedDescription)")
    }
}

@MainActor
class LobbyViewModel: ObservableObject {
    
    // UI State
    @Published var path: [AppScreen] = []
    @Published var activePlayers: [User] = []
    @Published var recommendations: VibeatResponse?
    @Published var errorMessage: String? = nil
    @Published var isTicketSubmitted: Bool = false
    
    // Global Lobby Settings
    @Published var lobbyTitle: String = ""
    @Published var occasionType: String = "Birthday"
    @Published var minimumBudget: Double = 500
    @Published var lobbyCode: String = ""
    @Published var isHost: Bool = false
    
    // Location Settings
    @Published var travelVarianceMode: String = "default"
    @Published var predefinedName: String = ""
    @Published var predefinedLat: Double? = nil
    @Published var predefinedLng: Double? = nil
    
    @Published var searchCompleter = LocationSearchService()
    
    private var pollingTask: Task<Void, Never>?

    func startPollingPlayers() {
        pollingTask?.cancel()

        pollingTask = Task {
            while !Task.isCancelled {
                await fetchPlayersForLobby()

                do {
                    try await Task.sleep(for: .seconds(2))
                } catch {
                    break
                }
            }
        }
    }
    
    deinit {
        pollingTask?.cancel()
    }

    func stopPollingPlayers() {
        pollingTask?.cancel()
        pollingTask = nil
    }
    
    func fetchPlayersForLobby() async {
        if !lobbyCode.isEmpty, let users = try? await VibeatAPIClient.shared.getLobbyUsers(lobbyCode: lobbyCode) {
            await MainActor.run {
                self.activePlayers = users
            }
        }
    }

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

    func resetLobbyState() {
        self.activePlayers = []
        self.recommendations = nil
        self.errorMessage = nil
        
        // Reset to default variables
        self.lobbyTitle = ""
        self.occasionType = "Birthday"
        self.minimumBudget = 500
        self.predefinedName = ""
        self.predefinedLat = nil
        self.predefinedLng = nil
        self.searchCompleter.searchQuery = ""
        self.isTicketSubmitted = false
    }
}
