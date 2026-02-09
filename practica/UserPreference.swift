import Foundation

/// Estado de visualización: previsto ver, viendo, visto.
enum WatchStatus: String, Codable, CaseIterable {
    case toWatch = "previsto_ver"
    case watching = "viendo"
    case watched = "visto"
    
    var displayName: String {
        switch self {
        case .toWatch: return "Previsto ver"
        case .watching: return "Viendo"
        case .watched: return "Visto"
        }
    }
}

/// Preferencias del usuario por película/serie: favorito, nota y estado de visualización.
struct UserPreference: Codable {
    var isFavorite: Bool
    var personalNote: String
    /// Estado: previsto ver, viendo o visto.
    var watchStatus: WatchStatus
    
    init(isFavorite: Bool = false, personalNote: String = "", watchStatus: WatchStatus = .toWatch) {
        self.isFavorite = isFavorite
        self.personalNote = personalNote
        self.watchStatus = watchStatus
    }
}
