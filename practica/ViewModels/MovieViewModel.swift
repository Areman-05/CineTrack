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
    func toggleFavorite(movieId: Int) {
        if userPreferences[movieId] == nil {
            userPreferences[movieId] = UserPreference(isFavorite: true)
        } else {
            userPreferences[movieId]?.isFavorite.toggle()
        }
    }
    
    /// Actualiza el estado de visualización (previsto ver, viendo, visto)
    func setWatchStatus(movieId: Int, status: WatchStatus) {
        if userPreferences[movieId] == nil {
            userPreferences[movieId] = UserPreference(watchStatus: status)
        } else {
            userPreferences[movieId]?.watchStatus = status
        }
    }
    
    /// Actualiza la nota personal de una película/serie
    func updatePersonalNote(movieId: Int, note: String) {
        if userPreferences[movieId] == nil {
            userPreferences[movieId] = UserPreference(personalNote: note)
        } else {
            userPreferences[movieId]?.personalNote = note
        }
    }
    
    /// Elimina una película/serie de la lista del usuario (quitar de favoritos y preferencias)
    func removeFromList(movieId: Int) {
        userPreferences.removeValue(forKey: movieId)
    }
    
    func isFavorite(movieId: Int) -> Bool {
        return userPreferences[movieId]?.isFavorite ?? false
    }
    
    func watchStatus(for movieId: Int) -> WatchStatus {
        return userPreferences[movieId]?.watchStatus ?? .toWatch
    }
    
    func personalNote(for movieId: Int) -> String {
        return userPreferences[movieId]?.personalNote ?? ""
    }
    
    /// Lista de favoritos del usuario
    var favoriteMovies: [Movie] {
        movies.filter { isFavorite(movieId: $0.id) }
    }
}
