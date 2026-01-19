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


Showing Recent Messages
Build input files cannot be found: '/Users/alumne/Documents/CineTrack6/CineTrack/Views/DetailView.swift', '/Users/alumne/Documents/CineTrack6/CineTrack/Views/ExplorarView.swift', '/Users/alumne/Documents/CineTrack6/CineTrack/Services/TMDBService.swift', '/Users/alumne/Documents/CineTrack6/CineTrack/ViewModels/MovieViewModel.swift', '/Users/alumne/Documents/CineTrack6/CineTrack/Views/BuscarView.swift', '/Users/alumne/Documents/CineTrack6/CineTrack/ContentView.swift', '/Users/alumne/Documents/CineTrack6/CineTrack/CineTrackApp.swift', '/Users/alumne/Documents/CineTrack6/CineTrack/Views/FavoritosView.swift', '/Users/alumne/Documents/CineTrack6/CineTrack/Models/UserPreference.swift', '/Users/alumne/Documents/CineTrack6/CineTrack/Models/Movie.swift'

