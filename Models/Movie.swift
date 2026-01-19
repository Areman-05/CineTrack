import Foundation

/// Modelo que representa una película de TMDB
struct Movie: Identifiable, Codable {
    let id: Int
    let title: String
    let overview: String
    let posterPath: String?
    let voteAverage: Double
    let releaseDate: String
    
    /// URL completa del póster de la película
    var posterURL: URL? {
        guard let posterPath = posterPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)")
    }
    
    /// Año de lanzamiento extraído de releaseDate
    var releaseYear: String {
        let components = releaseDate.components(separatedBy: "-")
        return components.first ?? releaseDate
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case title
        case overview
        case posterPath = "poster_path"
        case voteAverage = "vote_average"
        case releaseDate = "release_date"
    }
}

/// Respuesta de la API de TMDB que contiene un array de películas
struct MovieResponse: Codable {
    let results: [Movie]
}

/// Modelo detallado de una película incluyendo géneros
struct MovieDetail: Codable {
    let id: Int
    let title: String
    let overview: String
    let posterPath: String?
    let voteAverage: Double
    let releaseDate: String
    let genres: [Genre]?
    
    /// Género cinematográfico
    struct Genre: Codable {
        let id: Int
        let name: String
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case title
        case overview
        case posterPath = "poster_path"
        case voteAverage = "vote_average"
        case releaseDate = "release_date"
        case genres
    }
}
