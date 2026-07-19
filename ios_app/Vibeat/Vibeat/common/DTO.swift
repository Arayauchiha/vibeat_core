//
//  VibeatModels.swift
//  Vibeat
//
//  Generated from the API's OpenAPI schema.
//

import Foundation

// MARK: - Auth

struct LoginRequestBody: Codable, Sendable {
    let idToken: String

    enum CodingKeys: String, CodingKey {
        case idToken = "id_token"
    }
}

struct LoginResponse: Codable, Sendable {
    enum CodingKeys: String, CodingKey {
        case statusCode = "status_code"
        case detail
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case expiresAtTimestamp = "expires_at_timestamp"
    }

    let statusCode: Int
    let detail: String
    let accessToken: String
    let refreshToken: String
    let expiresAtTimestamp: Double
}

struct LogoutResponse: Codable, Sendable {
    enum CodingKeys: String, CodingKey {
        case statusCode = "status_code"
        case detail
    }

    let statusCode: Int
    let detail: String
}

struct DeleteResponse: Codable, Sendable {
    enum CodingKeys: String, CodingKey {
        case statusCode = "status_code"
        case detail
    }

    let statusCode: Int
    let detail: String
}

// MARK: - User / Preferences

enum UserCuisinePreference: String, Codable, Sendable {
    case continental
    case northIndian = "north_indian"
    case southIndian = "south_indian"
    case chinese
    case italian
    case mexican
    case korean
}

enum UserFoodPreference: String, Codable, Sendable {
    case veg
    case nonVeg = "non_veg"
}

struct UserPreference: Codable, Sendable {
    enum CodingKeys: String, CodingKey {
        case budget
        case preferedDish = "prefered_dish"
        case cuisine
        case vibe
        case foodPreference = "food_preference"
        case alcoholPreference = "alcohol_preference"
        case cards
        case latitute
        case longitude
    }

    var budget: Double = 500
    var preferedDish: String = ""
    var cuisine: UserCuisinePreference = .continental
    var vibe: String = ""
    var foodPreference: UserFoodPreference = .veg
    var alcoholPreference: Bool = false
    var cards: [String] = []
    var latitute: Double = 28.6139
    var longitude: Double = 77.2090
}

struct User: Codable, Sendable {
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case fullName = "full_name"
        case contactNumber = "contact_number"
        case userPreference = "user_preference"
    }

    let id: String
    let fullName: String
    let contactNumber: String
    let userPreference: UserPreference?
}

// MARK: - Lobby

enum EventType: String, Codable, Sendable {
    case birthday
    case casual
    case business
    case romanticDate = "romantic_date"
}

struct EventLocation: Codable, Sendable {
    enum CodingKeys: String, CodingKey {
        case longitute
        case latitude
    }

    let longitute: Double
    let latitude: Double
}

struct LobbyCreateRequest: Codable, Sendable {
    enum CodingKeys: String, CodingKey {
        case name
        case type
        case eventAt = "event_at"
        case minimumBudget = "minimum_budget"
        case eventLocation = "event_location"
    }

    let name: String
    let type: EventType
    let eventAt: Date
    let minimumBudget: Double
    let eventLocation: EventLocation
}

struct LobbyCreateResponse: Codable, Sendable {
    enum CodingKeys: String, CodingKey {
        case statusCode = "status_code"
        case detail
        case lobbyCode = "lobby_code"
    }

    let statusCode: Int
    let detail: String
    let lobbyCode: String
}

struct LobbyInviteResponse: Codable, Sendable {
    enum CodingKeys: String, CodingKey {
        case statusCode = "status_code"
        case detail
        case lobbyCode = "lobby_code"
    }

    let statusCode: Int
    let detail: String
    let lobbyCode: String
}

// MARK: - Misc / catch-all empty responses

/// Used for endpoints whose OpenAPI response schema is an empty object (`{}`),
/// e.g. Swiggy login/callback/search and lobby join.
struct EmptyResponse: Codable, Sendable {}
