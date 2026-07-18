import Foundation

nonisolated private let baseURLString = "http://10.13.1.88:8000"

enum Endpoint: String, Sendable {
    case login = "/auth/login"
    case logout = "/auth/logout"
    case delete = "/auth/delete"
    case update = "/update/preference"
    case me = "/auth/me"
    case lobbyCreate = "/lobby/create"
    case lobbyGetInviteLink = "/lobby/@s/get-invite-link"
    case lobbyUsers = "/lobby/@s/users"
    case lobbyJoin = "/lobby/@s/join"
    case restrurantSearch = "/restrurant/search"
}

extension Endpoint {
    nonisolated var urlString: String {
        baseURLString + rawValue
    }

    nonisolated func urlString(with parameters: String...) -> String {
        return unsafe String(format: urlString, arguments: parameters)
    }
}
