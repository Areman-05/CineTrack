import Foundation
import SwiftUI

// Movie ViewModel
@MainActor
class MovieViewModel: ObservableObject {
    @Published private(set) var movies: [Movie] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    @Published var userPreferences: [Int: UserPreference] = [:]
    
    private let tmdbService = TMDBService.shared
    
    func loadPopularMovies() {
        isLoading = true
        errorMessage = nil
        
        tmdbService.fetchPopularMovies { [weak self] result in
            Task { @MainActor in
                self?.isLoading = false
                switch result {
                case .success(let movies):
                    self?.movies = movies
                case .failure(let error):
                    self?.errorMessage = "Error al cargar películas: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func searchMovies(query: String) {
        guard !query.isEmpty else {
            loadPopularMovies()
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        tmdbService.searchMovies(query: query) { [weak self] result in
            Task { @MainActor in
                self?.isLoading = false
                switch result {
                case .success(let movies):
                    self?.movies = movies
                case .failure(let error):
                    self?.errorMessage = "Error en la búsqueda: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func toggleFavorite(movieId: Int) {
        if userPreferences[movieId] == nil {
            userPreferences[movieId] = UserPreference(isFavorite: true)
        } else {
            userPreferences[movieId]?.isFavorite.toggle()
        }
    }
    
    func isFavorite(movieId: Int) -> Bool {
        return userPreferences[movieId]?.isFavorite ?? false
    }
    
    var favoriteMovies: [Movie] {
        movies.filter { isFavorite(movieId: $0.id) }
    }
}
