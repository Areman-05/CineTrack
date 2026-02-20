import Foundation

// MARK: - Estado de visualización

enum WatchStatus: String, Codable, CaseIterable {
    case toWatch = "toWatch"
    case watching = "watching"
    case watched = "watched"

    var displayName: String {
        switch self {
        case .toWatch: return "Por ver"
        case .watching: return "Viendo"
        case .watched: return "Visto"
        }
    }
}

// MARK: - Preferencias por película

struct UserPreference: Codable {
    var isFavorite: Bool = false
    var personalNote: String = ""
    var watchStatus: WatchStatus = .toWatch
}
