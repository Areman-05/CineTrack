import Foundation

/// Errores específicos del servicio TMDB (conforme a LocalizedError, teoría S06).
enum TMDBError: LocalizedError {
    case invalidURL
    case invalidResponse
    case noData
    case decodingError
    case networkError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "URL inválida"
        case .invalidResponse:
            return "Respuesta inválida del servidor"
        case .noData:
            return "No se recibieron datos del servidor"
        case .decodingError:
            return "Error al procesar los datos"
        case .networkError(let error):
            return "Error de red: \(error.localizedDescription)"
        }
    }
}
class TMDBService {
    static let shared = TMDBService()
    
    private let apiKey = "ba232569da1aac2f9b80a35300d0b04f"
    private let baseURL = "https://api.themoviedb.org/3"
    private let language = "es-ES"
    
    private init() {}
    
    /// Obtiene las películas populares de TMDB
    func fetchPopularMovies(completion: @escaping (Result<[Movie], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/movie/popular?api_key=\(apiKey)&language=\(language)") else {
            completion(.failure(TMDBError.invalidURL))
            return
        }
        performRequest(url: url, completion: completion)
    }

    /// Obtiene las películas mejor valoradas (para Explorar, distinto de discover de Inicio).
    func fetchTopRatedMovies(completion: @escaping (Result<[Movie], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/movie/top_rated?api_key=\(apiKey)&language=\(language)") else {
            completion(.failure(TMDBError.invalidURL))
            return
        }
        performRequest(url: url, completion: completion)
    }
    
    /// Lista de géneros de películas (para filtros)
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
            if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
                completion(.failure(TMDBError.invalidResponse))
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
    
    /// Descubre películas por puntuación mínima y/o género(s)
    func discoverMovies(minRating: Double?, genreIds: [Int]?, completion: @escaping (Result<[Movie], Error>) -> Void) {
        guard var components = URLComponents(string: "\(baseURL)/discover/movie") else {
            completion(.failure(TMDBError.invalidURL))
            return
        }
        var queryItems = [
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "language", value: language)
        ]
        if let min = minRating, min > 0 {
            queryItems.append(URLQueryItem(name: "vote_average.gte", value: String(min)))
        }
        if let ids = genreIds, !ids.isEmpty {
            queryItems.append(URLQueryItem(name: "with_genres", value: ids.map { String($0) }.joined(separator: ",")))
        }
        components.queryItems = queryItems
        guard let url = components.url else {
            completion(.failure(TMDBError.invalidURL))
            return
        }
        performRequest(url: url, completion: completion)
    }
    
    /// Busca películas por título
    func searchMovies(query: String, completion: @escaping (Result<[Movie], Error>) -> Void) {
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(baseURL)/search/movie?api_key=\(apiKey)&language=\(language)&query=\(encodedQuery)") else {
            completion(.failure(TMDBError.invalidURL))
            return
        }
        performRequest(url: url, completion: completion)
    }
    
    /// Obtiene los detalles completos de una película
    func fetchMovieDetails(id: Int, completion: @escaping (Result<MovieDetail, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/movie/\(id)?api_key=\(apiKey)&language=\(language)") else {
            completion(.failure(TMDBError.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(TMDBError.networkError(error)))
                return
            }
            if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
                completion(.failure(TMDBError.invalidResponse))
                return
            }
            guard let data = data else {
                completion(.failure(TMDBError.noData))
                return
            }
            do {
                let movieDetail = try JSONDecoder().decode(MovieDetail.self, from: data)
                completion(.success(movieDetail))
            } catch {
                completion(.failure(TMDBError.decodingError))
            }
        }.resume()
    }

    /// Método privado para realizar peticiones HTTP genéricas (data, response, error según S06).
    private func performRequest(url: URL, completion: @escaping (Result<[Movie], Error>) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(TMDBError.networkError(error)))
                return
            }
            if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
                completion(.failure(TMDBError.invalidResponse))
                return
            }
            guard let data = data else {
                completion(.failure(TMDBError.noData))
                return
            }
            do {
                let movieResponse = try JSONDecoder().decode(MovieResponse.self, from: data)
                completion(.success(movieResponse.results))
            } catch {
                completion(.failure(TMDBError.decodingError))
            }
        }.resume()
    }
}