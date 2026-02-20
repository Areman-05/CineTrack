import Foundation
import SwiftUI

/// ViewModel que gestiona el estado y lógica de las películas
/// Implementa el patrón MVVM siguiendo las directrices de teoría
class MovieViewModel: ObservableObject {
    @Published var movies: [Movie] = []
    @Published var popularMovies: [Movie] = []
    /// Películas para Explorar (mejor valoradas), distinto del discover de Inicio.
    @Published var exploreMovies: [Movie] = []
    @Published var genres: [Genre] = []
    @Published var isLoading = false
    @Published var isLoadingPopular = false
    @Published var isLoadingExplore = false
    @Published var errorMessage: String?
    @Published var popularErrorMessage: String?
    @Published var exploreErrorMessage: String?
    @Published var userPreferences: [Int: UserPreference] = [:]
    @Published var favoriteLists: [FavoriteList] = []
    /// Caché de películas (favoritas y en listas) para persistir y mostrar tras reinicio.
    @Published var movieCache: [Movie] = []

    private let tmdbService = TMDBService.shared
    private let favoriteListsKey = "cineTrack.favoriteLists"
    private let preferencesKey = "cineTrack.userPreferences"
    private let movieCacheKey = "cineTrack.movieCache"

    init() {
        loadFavoriteLists()
        loadUserPreferences()
        loadMovieCache()
    }

    private struct SavedPreference: Codable {
        let movieId: Int
        let preference: UserPreference
    }

    private func loadUserPreferences() {
        guard let data = UserDefaults.standard.data(forKey: preferencesKey),
              let decoded = try? JSONDecoder().decode([SavedPreference].self, from: data) else {
            userPreferences = [:]
            return
        }
        var prefs: [Int: UserPreference] = [:]
        for item in decoded {
            prefs[item.movieId] = item.preference
        }
        userPreferences = prefs
    }

    private func saveUserPreferences() {
        let arr = userPreferences.map { SavedPreference(movieId: $0.key, preference: $0.value) }
        guard let data = try? JSONEncoder().encode(arr) else { return }
        UserDefaults.standard.set(data, forKey: preferencesKey)
    }

    private func loadFavoriteLists() {
        guard let data = UserDefaults.standard.data(forKey: favoriteListsKey),
              let decoded = try? JSONDecoder().decode([FavoriteList].self, from: data) else {
            favoriteLists = []
            return
        }
        favoriteLists = decoded
    }

    private func saveFavoriteLists() {
        guard let data = try? JSONEncoder().encode(favoriteLists) else { return }
        UserDefaults.standard.set(data, forKey: favoriteListsKey)
    }

    private func loadMovieCache() {
        guard let data = UserDefaults.standard.data(forKey: movieCacheKey) else {
            movieCache = []
            return
        }
        do {
            movieCache = try JSONDecoder().decode([Movie].self, from: data)
        } catch {
            movieCache = []
        }
    }

    private func saveMovieCache() {
        guard let data = try? JSONEncoder().encode(movieCache) else { return }
        UserDefaults.standard.set(data, forKey: movieCacheKey)
    }

    private func addToCacheIfNeeded(_ movie: Movie) {
        if !movieCache.contains(where: { $0.id == movie.id }) {
            movieCache.append(movie)
            saveMovieCache()
        }
    }

    private func removeFromCache(movieId: Int) {
        movieCache.removeAll { $0.id == movieId }
        saveMovieCache()
    }

    func addFavoriteList(name: String) {
        let list = FavoriteList(name: name.trimmingCharacters(in: .whitespacesAndNewlines))
        guard !list.name.isEmpty else { return }
        favoriteLists.append(list)
        saveFavoriteLists()
    }

    func removeFavoriteList(id: UUID) {
        favoriteLists.removeAll { $0.id == id }
        saveFavoriteLists()
    }

    func addMovieToList(movieId: Int, listId: UUID, movie: Movie? = nil) {
        guard let index = favoriteLists.firstIndex(where: { $0.id == listId }),
              index < favoriteLists.count else { return }
        var copy = favoriteLists
        var list = copy[index]
        if list.movieIds.contains(movieId) { return }
        list.movieIds.append(movieId)
        copy[index] = list
        let newValue = copy
        let movieToCache = movie
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.favoriteLists = newValue
            self.saveFavoriteLists()
            if let m = movieToCache { self.addToCacheIfNeeded(m) }
        }
    }

    func removeMovieFromList(movieId: Int, listId: UUID) {
        guard let index = favoriteLists.firstIndex(where: { $0.id == listId }),
              index < favoriteLists.count else { return }
        var copy = favoriteLists
        var list = copy[index]
        list.movieIds.removeAll { $0 == movieId }
        copy[index] = list
        let newValue = copy
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.favoriteLists = newValue
            self.saveFavoriteLists()
        }
    }

    func movies(in listId: UUID) -> [Movie] {
        guard let list = favoriteLists.first(where: { $0.id == listId }) else { return [] }
        return list.movieIds.compactMap { id in
            movieCache.first { $0.id == id } ?? allLoadedMovies.first { $0.id == id }
        }
    }
    
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
    
    /// Carga las películas populares (reservado si se usa en otro sitio).
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

    /// Carga películas para la pestaña Explorar (usa populares; distinto del discover de Inicio).
    func loadExploreMovies() {
        isLoadingExplore = true
        exploreErrorMessage = nil
        tmdbService.fetchPopularMovies { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoadingExplore = false
                switch result {
                case .success(let movies):
                    self?.exploreMovies = movies
                case .failure(let error):
                    self?.exploreErrorMessage = "Error al cargar: \(error.localizedDescription)"
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
    
    /// Marca o desmarca una película como favorita. Pasar movie al marcar para guardarla en caché.
    func toggleFavorite(movieId: Int, movie: Movie? = nil) {
        if userPreferences[movieId] == nil {
            userPreferences[movieId] = UserPreference(isFavorite: true)
            if movie != nil { addToCacheIfNeeded(movie!) }
        } else {
            let wasFavorite = userPreferences[movieId]?.isFavorite ?? false
            userPreferences[movieId]?.isFavorite.toggle()
            if wasFavorite {
                let stillInList = favoriteLists.contains { $0.movieIds.contains(movieId) }
                if !stillInList { removeFromCache(movieId: movieId) }
            }
        }
        saveUserPreferences()
    }

    /// Actualiza el estado de visualización (previsto ver, viendo, visto)
    func setWatchStatus(movieId: Int, status: WatchStatus) {
        if userPreferences[movieId] == nil {
            userPreferences[movieId] = UserPreference(watchStatus: status)
        } else {
            userPreferences[movieId]?.watchStatus = status
        }
        saveUserPreferences()
    }

    /// Actualiza la nota personal de una película/serie
    func updatePersonalNote(movieId: Int, note: String) {
        if userPreferences[movieId] == nil {
            userPreferences[movieId] = UserPreference(personalNote: note)
        } else {
            userPreferences[movieId]?.personalNote = note
        }
        saveUserPreferences()
    }

    /// Elimina una película/serie de la lista del usuario (quitar de favoritos y preferencias)
    func removeFromList(movieId: Int) {
        userPreferences.removeValue(forKey: movieId)
        // Quitar del caché solo si ya no está en ninguna lista
        let stillInList = favoriteLists.contains { $0.movieIds.contains(movieId) }
        if !stillInList { removeFromCache(movieId: movieId) }
        saveUserPreferences()
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
    
    /// Todas las películas cargadas (buscador + populares + explorar) sin duplicados por id.
    var allLoadedMovies: [Movie] {
        var seen = Set<Int>()
        return (movies + popularMovies + exploreMovies).filter { seen.insert($0.id).inserted }
    }

    /// Lista de favoritos (caché persistido + cargadas en sesión, sin duplicados).
    var favoriteMovies: [Movie] {
        let fromCache = movieCache.filter { isFavorite(movieId: $0.id) }
        let cacheIds = Set(fromCache.map(\.id))
        let fromLoaded = allLoadedMovies.filter { isFavorite(movieId: $0.id) && !cacheIds.contains($0.id) }
        return fromCache + fromLoaded
    }

}
