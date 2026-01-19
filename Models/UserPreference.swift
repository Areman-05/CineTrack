import Foundation

// User Preference Model
struct UserPreference: Codable {
    var isFavorite: Bool
    var personalNote: String
    
    init(isFavorite: Bool = false, personalNote: String = "") {
        self.isFavorite = isFavorite
        self.personalNote = personalNote
    }
}
