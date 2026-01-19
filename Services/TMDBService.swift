//
//  TMDBService.swift
//  CineTrack
//
//  Servicio para consumir la API de The Movie Database
//

import Foundation

class TMDBService {
    static let shared = TMDBService()
    
    // TODO: Reemplazar con tu API key de TMDB
    private let apiKey = "TU_API_KEY_AQUI"
    private let baseURL = "https://api.themoviedb.org/3"
    
    private init() {}
    
    // Obtener películas populares
    func fetchPopularMovies(completion: @escaping (Result<[Movie], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/movie/popular?api_key=\(apiKey)&language=es-ES") else {
            completion(.failure(URLError(.badURL)))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(URLError(.badServerResponse)))
                return
            }
            
            do {
                let movieResponse = try JSONDecoder().decode(MovieResponse.self, from: data)
                completion(.success(movieResponse.results))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    // Buscar películas
    func searchMovies(query: String, completion: @escaping (Result<[Movie], Error>) -> Void) {
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(baseURL)/search/movie?api_key=\(apiKey)&language=es-ES&query=\(encodedQuery)") else {
            completion(.failure(URLError(.badURL)))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(URLError(.badServerResponse)))
                return
            }
            
            do {
                let movieResponse = try JSONDecoder().decode(MovieResponse.self, from: data)
                completion(.success(movieResponse.results))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    // Obtener detalles de una película
    func fetchMovieDetails(id: Int, completion: @escaping (Result<MovieDetail, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/movie/\(id)?api_key=\(apiKey)&language=es-ES") else {
            completion(.failure(URLError(.badURL)))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(URLError(.badServerResponse)))
                return
            }
            
            do {
                let movieDetail = try JSONDecoder().decode(MovieDetail.self, from: data)
                completion(.success(movieDetail))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
