import Foundation

// MARK: - Errores del servicio

enum TMDBError: Error, LocalizedError {
    case invalidURL
    case networkError(Error)
    case noData
    case decodingError

    var errorDescription: String? {
        localizedDescription
    }

    var localizedDescription: String {
        switch self {
        case .invalidURL: return "URL no válida"
        case .networkError(let e): return "Error de red: \(e.localizedDescription)"
        case .noData: return "No se recibieron datos"
        case .decodingError: return "Error al leer los datos"
        }
    }
}

// MARK: - Servicio TMDB

class TMDBService {
    static let shared = TMDBService()

    private let apiKey = "ba232569da1aac2f9b80a35300d0b04f"
    private let baseURL = "https://api.themoviedb.org/3"
    private let language = "es-ES"

    private init() {}

    func fetchPopularMovies(completion: @escaping (Result<[Movie], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/movie/popular?api_key=\(apiKey)&language=\(language)") else {
            completion(.failure(TMDBError.invalidURL))
            return
        }
        fetchMovies(url: url, completion: completion)
    }

    func searchMovies(query: String, completion: @escaping (Result<[Movie], Error>) -> Void) {
        guard let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(baseURL)/search/movie?api_key=\(apiKey)&language=\(language)&query=\(encoded)") else {
            completion(.failure(TMDBError.invalidURL))
            return
        }
        fetchMovies(url: url, completion: completion)
    }

    func discoverMovies(minRating: Double?, genreIds: [Int]?, completion: @escaping (Result<[Movie], Error>) -> Void) {
        var urlString = "\(baseURL)/discover/movie?api_key=\(apiKey)&language=\(language)"
        if let min = minRating, min > 0 {
            urlString += "&vote_average.gte=\(min)"
        }
        if let ids = genreIds, !ids.isEmpty {
            urlString += "&with_genres=\(ids.map { String($0) }.joined(separator: ","))"
        }
        guard let url = URL(string: urlString) else {
            completion(.failure(TMDBError.invalidURL))
            return
        }
        fetchMovies(url: url, completion: completion)
    }

    func fetchMovieGenres(completion: @escaping (Result<[Genre], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/genre/movie/list?api_key=\(apiKey)&language=\(language)") else {
            completion(.failure(TMDBError.invalidURL))
            return
        }
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(TMDBError.networkError(error)))
                return
            }
            guard let data = data else {
                completion(.failure(TMDBError.noData))
                return
            }
            do {
                let decoded = try JSONDecoder().decode(GenreListResponse.self, from: data)
                completion(.success(decoded.genres))
            } catch {
                completion(.failure(TMDBError.decodingError))
            }
        }.resume()
    }

    private func fetchMovies(url: URL, completion: @escaping (Result<[Movie], Error>) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(TMDBError.networkError(error)))
                return
            }
            guard let data = data else {
                completion(.failure(TMDBError.noData))
                return
            }
            do {
                let decoded = try JSONDecoder().decode(MovieResponse.self, from: data)
                completion(.success(decoded.results))
            } catch {
                completion(.failure(TMDBError.decodingError))
            }
        }.resume()
    }
}
