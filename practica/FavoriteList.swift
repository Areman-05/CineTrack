import Foundation

// MARK: - Lista de favoritos

struct FavoriteList: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
    var movieIds: [Int] = []
}
