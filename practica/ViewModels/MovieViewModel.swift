import Foundation

// Struct auxiliar para persistir preferencias
private struct SavedPref: Codable {
    let id: Int
    let pref: UserPreference
}

// MARK: - ViewModel (MVVM)

class MovieViewModel: ObservableObject {

    @Published var movies: [Movie] = []
    @Published var exploreMovies: [Movie] = []
    @Published var genres: [Genre] = []
    @Published var isLoading = false
    @Published var isLoadingExplore = false
    @Published var errorMessage: String?
    @Published var exploreErrorMessage: String?
    @Published var userPreferences: [Int: UserPreference] = [:]
    @Published var savedMovies: [Movie] = []
    @Published var favoriteLists: [FavoriteList] = []

    var favoriteMovies: [Movie] {
        savedMovies.filter { isFavorite(movieId: $0.id) }
    }

    private let service = TMDBService.shared

    private let prefsKey = "prefs"
    private let savedMoviesKey = "savedMovies"
    private let listsKey = "favoriteLists"

    init() {
        loadPreferences()
        loadSavedMovies()
        loadFavoriteLists()
    }

    // MARK: - Cargar películas

    func loadExploreMovies() {
        isLoadingExplore = true
        exploreErrorMessage = nil
        service.fetchPopularMovies { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoadingExplore = false
                switch result {
                case .success(let movies):
                    self?.exploreMovies = movies
                case .failure(let error):
                    self?.exploreErrorMessage = "Error: \(error.localizedDescription)"
                }
            }
        }
    }

    func loadGenres() {
        service.fetchMovieGenres { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let genres):
                    self?.genres = genres
                case .failure:
                    break
                }
            }
        }
    }

    func searchMovies(query: String, minRating: Double? = nil, genreIds: [Int]? = nil) {
        isLoading = true
        errorMessage = nil
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmed.isEmpty {
            service.discoverMovies(minRating: minRating, genreIds: genreIds) { [weak self] result in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    switch result {
                    case .success(let movies):
                        self?.movies = movies
                    case .failure(let error):
                        self?.errorMessage = "Error: \(error.localizedDescription)"
                    }
                }
            }
        } else {
            service.searchMovies(query: trimmed) { [weak self] result in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    switch result {
                    case .success(var movies):
                        if let min = minRating, min > 0 {
                            movies = movies.filter { $0.voteAverage >= min }
                        }
                        self?.movies = movies
                    case .failure(let error):
                        self?.errorMessage = "Error: \(error.localizedDescription)"
                    }
                }
            }
        }
    }

    // MARK: - Favoritos

    func isFavorite(movieId: Int) -> Bool {
        return userPreferences[movieId]?.isFavorite ?? false
    }

    func toggleFavorite(movie: Movie) {
        if isFavorite(movieId: movie.id) {
            userPreferences[movie.id]?.isFavorite = false
            let enAlgunaLista = favoriteLists.contains { $0.movieIds.contains(movie.id) }
            if !enAlgunaLista {
                savedMovies.removeAll { $0.id == movie.id }
            }
        } else {
            if userPreferences[movie.id] == nil {
                userPreferences[movie.id] = UserPreference(isFavorite: true)
            } else {
                userPreferences[movie.id]?.isFavorite = true
            }
            if !savedMovies.contains(where: { $0.id == movie.id }) {
                savedMovies.append(movie)
            }
        }
        savePreferences()
        saveSavedMovies()
    }

    func removeFromFavorites(movieId: Int) {
        userPreferences[movieId]?.isFavorite = false
        let enAlgunaLista = favoriteLists.contains { $0.movieIds.contains(movieId) }
        if !enAlgunaLista {
            savedMovies.removeAll { $0.id == movieId }
        }
        savePreferences()
        saveSavedMovies()
    }

    // MARK: - Estado de visualización

    func watchStatus(for movieId: Int) -> WatchStatus {
        return userPreferences[movieId]?.watchStatus ?? .toWatch
    }

    func setWatchStatus(movieId: Int, status: WatchStatus) {
        if userPreferences[movieId] == nil {
            userPreferences[movieId] = UserPreference(watchStatus: status)
        } else {
            userPreferences[movieId]?.watchStatus = status
        }
        savePreferences()
    }

    // MARK: - Nota personal

    func personalNote(for movieId: Int) -> String {
        return userPreferences[movieId]?.personalNote ?? ""
    }

    func updatePersonalNote(movieId: Int, note: String) {
        if userPreferences[movieId] == nil {
            userPreferences[movieId] = UserPreference(personalNote: note)
        } else {
            userPreferences[movieId]?.personalNote = note
        }
        savePreferences()
    }

    // MARK: - Listas personalizadas

    func isInList(movieId: Int, listId: UUID) -> Bool {
        return favoriteLists.first(where: { $0.id == listId })?.movieIds.contains(movieId) ?? false
    }

    func addFavoriteList(name: String) {
        let list = FavoriteList(name: name.trimmingCharacters(in: .whitespacesAndNewlines))
        favoriteLists.append(list)
        saveFavoriteLists()
    }

    func removeFavoriteList(id: UUID) {
        favoriteLists.removeAll { $0.id == id }
        saveFavoriteLists()
        savedMovies = savedMovies.filter { movie in
            isFavorite(movieId: movie.id) || favoriteLists.contains { $0.movieIds.contains(movie.id) }
        }
        saveSavedMovies()
    }

    func addMovieToList(movieId: Int, listId: UUID, movie: Movie) {
        guard favoriteLists.contains(where: { $0.id == listId }) else { return }
        let newLists: [FavoriteList] = favoriteLists.map { list in
            guard list.id == listId else { return list }
            if list.movieIds.contains(movieId) { return list }
            return FavoriteList(id: list.id, name: list.name, movieIds: list.movieIds + [movieId])
        }
        favoriteLists = newLists
        saveFavoriteLists()
        if !savedMovies.contains(where: { $0.id == movie.id }) {
            savedMovies.append(movie)
            saveSavedMovies()
        }
    }

    func removeMovieFromList(movieId: Int, listId: UUID) {
        guard favoriteLists.contains(where: { $0.id == listId }) else { return }
        let newLists: [FavoriteList] = favoriteLists.map { list in
            guard list.id == listId else { return list }
            return FavoriteList(id: list.id, name: list.name, movieIds: list.movieIds.filter { $0 != movieId })
        }
        favoriteLists = newLists
        saveFavoriteLists()
        let sigueEnOtraLista = favoriteLists.contains { $0.movieIds.contains(movieId) }
        if !sigueEnOtraLista && !isFavorite(movieId: movieId) {
            savedMovies.removeAll { $0.id == movieId }
            saveSavedMovies()
        }
    }

    func moviesInList(_ listId: UUID) -> [Movie] {
        guard let list = favoriteLists.first(where: { $0.id == listId }) else { return [] }
        let todasDisponibles = savedMovies + movies + exploreMovies
        return list.movieIds.compactMap { id in
            todasDisponibles.first { $0.id == id }
        }
    }

    var todasLasPeliculas: [Movie] {
        var seen = Set<Int>()
        return (savedMovies + movies + exploreMovies).filter { seen.insert($0.id).inserted }
    }

    // MARK: - Persistencia

    private func savePreferences() {
        let arr = userPreferences.map { SavedPref(id: $0.key, pref: $0.value) }
        if let data = try? JSONEncoder().encode(arr) {
            UserDefaults.standard.set(data, forKey: prefsKey)
        }
    }

    private func loadPreferences() {
        guard let data = UserDefaults.standard.data(forKey: prefsKey),
              let decoded = try? JSONDecoder().decode([SavedPref].self, from: data) else { return }
        for item in decoded {
            userPreferences[item.id] = item.pref
        }
    }

    private func saveSavedMovies() {
        if let data = try? JSONEncoder().encode(savedMovies) {
            UserDefaults.standard.set(data, forKey: savedMoviesKey)
        }
    }

    private func loadSavedMovies() {
        guard let data = UserDefaults.standard.data(forKey: savedMoviesKey),
              let decoded = try? JSONDecoder().decode([Movie].self, from: data) else { return }
        savedMovies = decoded
    }

    private func saveFavoriteLists() {
        if let data = try? JSONEncoder().encode(favoriteLists) {
            UserDefaults.standard.set(data, forKey: listsKey)
        }
    }

    private func loadFavoriteLists() {
        guard let data = UserDefaults.standard.data(forKey: listsKey),
              let decoded = try? JSONDecoder().decode([FavoriteList].self, from: data) else { return }
        favoriteLists = decoded
    }
}
