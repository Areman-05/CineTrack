import Foundation
import SwiftUI

/// ViewModel que gestiona el estado y lógica de las películas
/// Implementa el patrón MVVM siguiendo las directrices de teoría
class MovieViewModel: ObservableObject {
    @Published var movies: [Movie] = []
    @Published var popularMovies: [Movie] = []
    @Published var genres: [Genre] = []
    @Published var isLoading = false
    @Published var isLoadingPopular = false
    @Published var errorMessage: String?
    @Published var popularErrorMessage: String?
    @Published var userPreferences: [Int: UserPreference] = [:]
    
    private let tmdbService = TMDBService.shared
    
    /// Carga la lista de géneros (para filtros de búsqueda)
    func loadGenres() {
        tmdbService.fetchMovieGenres { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let list):
                    self?.genres = list
                case .failure:
                    self?.genres = []
                }
            }
        }
    }
    
    /// Carga las películas populares (para la pestaña Explorar).
    func loadPopularMovies() {
        isLoadingPopular = true
        popularErrorMessage = nil
        tmdbService.fetchPopularMovies { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoadingPopular = false
                switch result {
                case .success(let movies):
                    self?.popularMovies = movies
                case .failure(let error):
                    self?.popularErrorMessage = "Error al cargar: \(error.localizedDescription)"
                }
            }
        }
    }
    
    /// Busca películas por título (sin filtros adicionales)
    func searchMovies(query: String) {
        searchWithFilters(query: query, minRating: nil, genreIds: nil)
    }
    
    /// Búsqueda con criterios: título, puntuación mínima y/o género(s).
    /// Si no hay texto, usa discover con filtros. Si hay texto, busca por título y filtra por puntuación.
    func searchWithFilters(query: String, minRating: Double?, genreIds: [Int]?) {
        isLoading = true
        errorMessage = nil
        
        if query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            tmdbService.discoverMovies(minRating: minRating, genreIds: genreIds) { [weak self] result in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    switch result {
                    case .success(let movies):
                        self?.movies = movies
                    case .failure(let error):
                        self?.errorMessage = "Error al cargar: \(error.localizedDescription)"
                    }
                }
            }
        } else {
            tmdbService.searchMovies(query: query) { [weak self] result in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    switch result {
                    case .success(var movies):
                        if let min = minRating, min > 0 {
                            movies = movies.filter { $0.voteAverage >= min }
                        }
                        self?.movies = movies
                    case .failure(let error):
                        self?.errorMessage = "Error en la búsqueda: \(error.localizedDescription)"
                    }
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
    
    /// Todas las películas cargadas (buscador + populares) sin duplicados por id.
    private var allLoadedMovies: [Movie] {
        var seen = Set<Int>()
        return (movies + popularMovies).filter { seen.insert($0.id).inserted }
    }

    /// Lista de favoritos del usuario (desde buscador y explorar).
    var favoriteMovies: [Movie] {
        allLoadedMovies.filter { isFavorite(movieId: $0.id) }
    }
}
