import Foundation
import SwiftUI

/// ViewModel que gestiona el estado y lógica de las películas
/// Implementa el patrón MVVM siguiendo las directrices de teoría
class MovieViewModel: ObservableObject {
    @Published var movies: [Movie] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var userPreferences: [Int: UserPreference] = [:]
    
    private let tmdbService = TMDBService.shared
    
    /// Carga las películas populares desde TMDB
    func loadPopularMovies() {
        isLoading = true
        errorMessage = nil
        
        tmdbService.fetchPopularMovies { [weak self] result in
            DispatchQueue.main.async {
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
    
    /// Busca películas por título
    /// - Parameter query: Texto de búsqueda
    func searchMovies(query: String) {
        guard !query.isEmpty else {
            loadPopularMovies()
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        tmdbService.searchMovies(query: query) { [weak self] result in
            DispatchQueue.main.async {
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
    
    /// Marca o desmarca una película como favorita
    /// - Parameter movieId: ID de la película
    func toggleFavorite(movieId: Int) {
        if userPreferences[movieId] == nil {
            userPreferences[movieId] = UserPreference(isFavorite: true)
        } else {
            userPreferences[movieId]?.isFavorite.toggle()
        }
    }
    
    /// Verifica si una película está marcada como favorita
    /// - Parameter movieId: ID de la película
    /// - Returns: true si es favorita, false en caso contrario
    func isFavorite(movieId: Int) -> Bool {
        return userPreferences[movieId]?.isFavorite ?? false
    }
    
    /// Propiedad computada que retorna solo las películas favoritas
    var favoriteMovies: [Movie] {
        movies.filter { isFavorite(movieId: $0.id) }
    }
}
