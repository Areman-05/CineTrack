import Foundation

/// Modelo que representa las preferencias del usuario para una película
struct UserPreference: Codable {
    var isFavorite: Bool
    var personalNote: String
    
    init(isFavorite: Bool = false, personalNote: String = "") {
        self.isFavorite = isFavorite
        self.personalNote = personalNote
    }
}
