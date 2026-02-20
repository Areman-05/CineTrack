import Foundation

/// Lista/grupo de favoritos con nombre y IDs de películas. Persistible.
struct FavoriteList: Identifiable, Codable, Equatable {
    var id: UUID
    var name: String
    var movieIds: [Int]

    init(id: UUID = UUID(), name: String, movieIds: [Int] = []) {
        self.id = id
        self.name = name
        self.movieIds = movieIds
    }
}
