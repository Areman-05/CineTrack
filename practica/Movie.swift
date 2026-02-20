import Foundation

// MARK: - Tipo de contenido (película o serie)
/// Permite distinguir si el contenido es una película o una serie.
enum MediaType: String, Codable, CaseIterable {
    case movie = "movie"
    case tv = "tv"
    
    var displayName: String {
        switch self {
        case .movie: return "Película"
        case .tv: return "Serie"
        }
    }
}

/// Modelo que representa una película o serie de TMDB.
/// Incluye datos de la API y permite distinguir entre movie y tv.
struct Movie: Identifiable, Codable {
    let id: Int
    let title: String
    let overview: String
    let posterPath: String?
    let voteAverage: Double
    let releaseDate: String
    /// Indica si es película o serie. Por defecto "movie" si la API no lo envía.
    var mediaType: MediaType?
    
    /// URL completa del póster
    var posterURL: URL? {
        guard let posterPath = posterPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)")
    }
    
    /// Año de estreno extraído de releaseDate
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
        case mediaType = "media_type"
    }
    
    init(id: Int, title: String, overview: String, posterPath: String?, voteAverage: Double, releaseDate: String, mediaType: MediaType? = .movie) {
        self.id = id
        self.title = title
        self.overview = overview
        self.posterPath = posterPath
        self.voteAverage = voteAverage
        self.releaseDate = releaseDate
        self.mediaType = mediaType
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(Int.self, forKey: .id)
        title = try c.decode(String.self, forKey: .title)
        overview = try c.decodeIfPresent(String.self, forKey: .overview) ?? ""
        posterPath = try c.decodeIfPresent(String.self, forKey: .posterPath)
        voteAverage = try c.decode(Double.self, forKey: .voteAverage)
        releaseDate = try c.decodeIfPresent(String.self, forKey: .releaseDate) ?? ""
        mediaType = try c.decodeIfPresent(MediaType.self, forKey: .mediaType) ?? .movie
    }
}

/// Respuesta de la API de TMDB: envuelve el array de resultados.
struct MovieResponse: Codable {
    let results: [Movie]
}

/// Género cinematográfico (usado en detalles y filtros).
struct Genre: Codable, Identifiable {
    let id: Int
    let name: String
}

/// Respuesta de la API de géneros de películas.
struct GenreListResponse: Codable {
    let genres: [Genre]
}

/// Modelo detallado de una película/serie con géneros.
struct MovieDetail: Codable {
    let id: Int
    let title: String
    let overview: String
    let posterPath: String?
    let voteAverage: Double
    let releaseDate: String
    let genres: [Genre]?
    
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
