import Foundation

// MARK: - Tipo de contenido

enum MediaType: String, Codable {
    case movie = "movie"
    case tv = "tv"

    var displayName: String {
        switch self {
        case .movie: return "Película"
        case .tv: return "Serie"
        }
    }
}

// MARK: - Modelo principal

struct Movie: Identifiable, Codable {
    let id: Int
    let title: String
    let overview: String
    let posterPath: String?
    let voteAverage: Double
    let releaseDate: String
    var mediaType: MediaType?

    var posterURL: URL? {
        guard let posterPath = posterPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)")
    }

    var releaseYear: String {
        return String(releaseDate.prefix(4))
    }

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case overview
        case posterPath = "poster_path"
        case voteAverage = "vote_average"
        case releaseDate = "release_date"
        case mediaType = "media_type"
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

    init(id: Int, title: String, overview: String, posterPath: String?,
         voteAverage: Double, releaseDate: String, mediaType: MediaType? = .movie) {
        self.id = id
        self.title = title
        self.overview = overview
        self.posterPath = posterPath
        self.voteAverage = voteAverage
        self.releaseDate = releaseDate
        self.mediaType = mediaType
    }
}

// MARK: - Respuesta de la API

struct MovieResponse: Codable {
    let results: [Movie]
}

// MARK: - Género

struct Genre: Identifiable, Codable {
    let id: Int
    let name: String
}

struct GenreListResponse: Codable {
    let genres: [Genre]
}
