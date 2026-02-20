import SwiftUI

/// Pantalla de Favoritos: lista de películas/series guardadas por el usuario.
/// Cumple requisito de pantalla Favoritos del prototipo. CRUD: ver y eliminar.
/// Compatible con iOS 14.4.
struct FavoritosView: View {
    @EnvironmentObject private var viewModel: MovieViewModel

    var body: some View {
        NavigationView {
            Group {
                if viewModel.favoriteMovies.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "heart.slash")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                        Text("No tienes favoritos")
                            .foregroundColor(.gray)
                        Text("Marca como favorito en Buscador para verlos aquí.")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(viewModel.favoriteMovies) { movie in
                            NavigationLink(destination: DetailView(movie: movie)) {
                                FavoritoRowView(movie: movie, viewModel: viewModel)
                            }
                        }
                        .onDelete(perform: eliminarFavorito)
                    }
                }
            }
            .navigationTitle("Favoritos")
        }
    }

    private func eliminarFavorito(at offsets: IndexSet) {
        let favoritos = viewModel.favoriteMovies
        for index in offsets where index < favoritos.count {
            viewModel.removeFromList(movieId: favoritos[index].id)
        }
    }
}

/// Fila de un favorito: título, tipo (Película/Serie), puntuación y estado de visualización.
struct FavoritoRowView: View {
    let movie: Movie
    @ObservedObject var viewModel: MovieViewModel

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(movie.title)
                    .font(.headline)
                HStack(spacing: 8) {
                    Text(movie.mediaType?.displayName ?? "Película")
                        .font(.caption)
                        .foregroundColor(.blue)
                    Text("·")
                    Text(viewModel.watchStatus(for: movie.id).displayName)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            Spacer()
            Text(String(format: "%.1f", movie.voteAverage))
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 4)
    }
}

#if DEBUG
struct FavoritosView_Previews: PreviewProvider {
    static var previews: some View {
        FavoritosView()
            .environmentObject(MovieViewModel())
    }
}
#endif
