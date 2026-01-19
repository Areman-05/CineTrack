//
//  Movie.swift
//  CineTrack
//
//  Modelo para los datos de la API TMDB
//

import Foundation

struct Movie: Identifiable, Codable {
    let id: Int
    let title: String
    let overview: String
    let posterPath: String?
    let voteAverage: Double
    let releaseDate: String
    
    // Propiedades computadas para facilitar el uso
    var posterURL: URL? {
        guard let posterPath = posterPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)")
    }
    
    var releaseYear: String {
        let components = releaseDate.components(separatedBy: "-")
        return components.first ?? releaseDate
    }
    
    // Mapeo personalizado para la API
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case overview
        case posterPath = "poster_path"
        case voteAverage = "vote_average"
        case releaseDate = "release_date"
    }
}

// Respuesta de la API para listado de películas
struct MovieResponse: Codable {
    let results: [Movie]
}

// Detalles adicionales que se pueden obtener en el detalle
struct MovieDetail: Codable {
    let id: Int
    let title: String
    let overview: String
    let posterPath: String?
    let voteAverage: Double
    let releaseDate: String
    let genres: [Genre]?
    
    struct Genre: Codable {
        let id: Int
        let name: String
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case overview
        case posterPath = "poster_path"
        case voteAverage = "vote_average"
        case releaseDate = "release_date"
        case genres
    }
}
