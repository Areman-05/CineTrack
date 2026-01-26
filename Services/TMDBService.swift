import Foundation

/// Errores específicos del servicio TMDB
enum TMDBError: Error {
    case invalidURL
    case noData
    case decodingError
    case networkError(Error)
    
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "URL inválida"
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
    
    /// Método privado para realizar peticiones HTTP genéricas
    private func performRequest(url: URL, completion: @escaping (Result<[Movie], Error>) -> Void) {
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
                let movieResponse = try JSONDecoder().decode(MovieResponse.self, from: data)
                completion(.success(movieResponse.results))
            } catch {
                completion(.failure(TMDBError.decodingError))
            }
        }.resume()
    }
}