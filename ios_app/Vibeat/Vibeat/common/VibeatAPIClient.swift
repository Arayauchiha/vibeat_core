
import Foundation

actor VibeatAPIClient {
    // MARK: Lifecycle

    private init() {}

    // MARK: Internal

    nonisolated static let shared: VibeatAPIClient = .init()

    // MARK: - Auth

    @discardableResult
    func login(idToken: String) async throws -> LoginResponse {
        let body = LoginRequestBody(idToken: idToken)
        let data = try JSONEncoder().encode(body)

        let response: NetworkResponse<LoginResponse> = try await MCNetworkManager.shared.post(
            url: Endpoint.login.urlString,
            body: data
        )

        KeychainHelper.set(response.data.accessToken, forKey: .accessToken)
        KeychainHelper.set(response.data.refreshToken, forKey: .refreshToken)

        return response.data
    }

    @discardableResult
    func logout() async throws -> LogoutResponse {
        let response: NetworkResponse<LogoutResponse> = try await MCNetworkManager.shared.post(
            url: Endpoint.logout.urlString,
            headers: authHeaders()
        )

        KeychainHelper.purge()

        return response.data
    }

    @discardableResult
    func deleteAccount() async throws -> DeleteResponse {
        let response: NetworkResponse<DeleteResponse> = try await MCNetworkManager.shared.post(
            url: Endpoint.delete.urlString,
            headers: authHeaders()
        )

        KeychainHelper.purge()

        return response.data
    }

    func fetchCurrentUser() async throws -> User {
        let response: NetworkResponse<User> = try await MCNetworkManager.shared.post(
            url: Endpoint.me.urlString,
            headers: authHeaders()
        )
        return response.data
    }

    // MARK: - Preferences

    @discardableResult
    func updatePreference(_ preference: UserPreference) async throws -> Bool {
        let data = try JSONEncoder().encode(preference)

        let response: NetworkResponse<Bool> = try await MCNetworkManager.shared.put(
            url: Endpoint.update.urlString,
            body: data,
            headers: authHeaders()
        )

        return response.data
    }

    // MARK: - Lobby

    @discardableResult
    func createLobby(_ request: LobbyCreateRequest) async throws -> LobbyCreateResponse {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(request)

        let response: NetworkResponse<LobbyCreateResponse> = try await MCNetworkManager.shared.post(
            url: Endpoint.lobbyCreate.urlString,
            body: data,
            headers: authHeaders()
        )

        return response.data
    }

    func getLobbyInviteLink(lobbyCode: String) async throws -> LobbyInviteResponse {
        let response: NetworkResponse<LobbyInviteResponse> = try await MCNetworkManager.shared.get(
            url: Endpoint.lobbyGetInviteLink.urlString(with: lobbyCode),
            headers: authHeaders()
        )

        return response.data
    }

    func getLobbyUsers(lobbyCode: String) async throws -> [User] {
        let response: NetworkResponse<[User]> = try await MCNetworkManager.shared.get(
            url: Endpoint.lobbyUsers.urlString(with: lobbyCode),
            headers: authHeaders()
        )

        return response.data
    }

    @discardableResult
    func joinLobby(lobbyCode: String) async throws -> Bool {
        let response: NetworkResponse<Bool> = try await MCNetworkManager.shared.get(
            url: Endpoint.lobbyJoin.urlString(with: lobbyCode),
            headers: authHeaders()
        )

        return response.data
    }

    // MARK: - Swiggy / Restaurants

    @discardableResult
    func searchRestaurants(lobbyId: String, query: String, longitude: String, latitude: String) async throws -> VenueRecommendationResponse {
        let response: NetworkResponse<VenueRecommendationResponse> = try await MCNetworkManager.shared.post(
            url: Endpoint.restrurantSearch.urlString(with: lobbyId),
            queryParameters: [
                "query": query,
                "longitude": longitude,
                "latitude": latitude
            ],
            headers: authHeaders()
        )

        return response.data
    }

    @discardableResult
    func searchRestaurants(query: String, longitude: String, latitude: String) async throws -> VenueRecommendationResponse {
        let response: NetworkResponse<VenueRecommendationResponse> = try await MCNetworkManager.shared.post(
            url: Endpoint.restrurantSearch.urlString,
            queryParameters: [
                "query": query,
                "longitude": longitude,
                "latitude": latitude
            ],
        )

        return response.data
    }

    @discardableResult
    func userHasPreference(userId: String) async throws -> Bool {
        let response: NetworkResponse<Bool> = try await MCNetworkManager.shared.get(
            url: Endpoint.userHasPreference.urlString(with: userId),
            headers: authHeaders()
        )

        return response.data
    }

    // MARK: Private

    /// Attaches the bearer token from the Keychain to authenticated requests.
    /// Returns an empty dictionary if no token is stored yet.
    private func authHeaders() -> [String: String] {
        guard let token = KeychainHelper.get(.accessToken) else {
            return [:]
        }
        return ["Authorization": "Bearer \(token)"]
    }
}
